import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_runner.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

/// `flutter_pty` の `Pty.start` で `claude` を擬似端末上に起動する実装。
class PtySkillRunner implements SkillRunner {
  PtySkillRunner({
    required this.repositoryPath,
    required this.skillName,
    this.executable = 'claude',
    this.idleThreshold = const Duration(seconds: 2),
    Terminal? terminal,
  }) : terminal = terminal ?? Terminal() {
    // Terminal → PTY 方向の配線。`start` で PTY が生成されてから書き込みが
    // 走るよう、_pty を late に参照する。`start` 前のキー入力は破棄される
    // （まだプロセスが居ない正常な状態）。
    this.terminal.onOutput = _onTerminalOutput;
    this.terminal.onResize = _onTerminalResize;
  }

  /// 子プロセスの作業ディレクトリ。
  final String repositoryPath;

  /// 実行する Skill 名（`claude` への引数として渡す）。
  final String skillName;

  /// 起動するコマンド名。テストでは `bash` など差し替え可。
  final String executable;

  /// PTY 出力が止まってから `waitingInput` 状態へ遷移するまでの時間。
  /// 短すぎると claude の通常思考中も「入力待ち」と表示されてしまうため、
  /// 既定 2 秒。出力が再開すれば即 `running` に戻る。
  final Duration idleThreshold;

  @override
  final Terminal terminal;

  Pty? _pty;
  Timer? _idleTimer;
  final _stateController = StreamController<SkillRunState>.broadcast();
  // output は構築直後に View 側から subscribe されるため、`_pty` 生成より
  // 早いタイミングで安定した Stream を返す必要がある。`_pty.output` を直接
  // 公開すると start 前の subscribe が空 Stream に紐づき、PTY 出力が
  // ターミナルに流れない（ログが何も出ない症状になる）。
  final _outputController = StreamController<Uint8List>.broadcast();
  StreamSubscription<Uint8List>? _ptyOutputSub;
  SkillRunState _currentState = const SkillRunState.idle();
  bool _started = false;
  bool _disposed = false;

  @override
  SkillRunState get currentState => _currentState;

  @override
  Stream<SkillRunState> get state => _stateController.stream;

  @override
  Stream<Uint8List> get output => _outputController.stream;

  @override
  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    _emit(const SkillRunState.starting());

    if (!Directory(repositoryPath).existsSync()) {
      _emit(SkillRunState.failed('リポジトリディレクトリが見つかりません: $repositoryPath'));
      return;
    }

    try {
      _pty = Pty.start(
        executable,
        arguments: _buildArguments(),
        workingDirectory: repositoryPath,
      );
    } on Object catch (e) {
      _emit(SkillRunState.failed(_formatStartError(e)));
      return;
    }

    _ptyOutputSub = _pty!.output.listen((bytes) {
      if (!_outputController.isClosed) {
        _outputController.add(bytes);
      }
      terminal.write(utf8.decode(bytes, allowMalformed: true));
      // 新しい出力が来た = 「処理中」と判定。waitingInput からも復帰
      if (_currentState is SkillRunWaitingInput) {
        _emit(const SkillRunState.running());
      }
      _scheduleIdleCheck();
    });

    _emit(const SkillRunState.running());
    _scheduleIdleCheck();

    unawaited(
      _pty!.exitCode.then((code) {
        if (_currentState is SkillRunCancelled) {
          return;
        }
        _idleTimer?.cancel();
        _emit(SkillRunState.completed(code));
      }),
    );
  }

  /// PTY 出力が止まったら `waitingInput` に遷移するためのタイマーを
  /// 仕掛け直す。出力受信のたびに呼び、`idleThreshold` 経過時点でまだ
  /// `running` のままなら入力待ち推定に切り替える。
  void _scheduleIdleCheck() {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleThreshold, () {
      if (_currentState is SkillRunRunning) {
        _emit(const SkillRunState.waitingInput());
      }
    });
  }

  @override
  void write(Uint8List data) {
    _pty?.write(data);
  }

  @override
  void resize({required int cols, required int rows}) {
    _pty?.resize(rows, cols);
  }

  @override
  Future<void> cancel() async {
    final pty = _pty;
    if (pty == null) {
      return;
    }
    if (_currentState is SkillRunCancelled ||
        _currentState is SkillRunCompleted) {
      return;
    }
    _idleTimer?.cancel();
    pty.kill();
    _emit(const SkillRunState.cancelled());
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _idleTimer?.cancel();
    _idleTimer = null;
    final pty = _pty;
    if (pty != null &&
        _currentState is! SkillRunCancelled &&
        _currentState is! SkillRunCompleted) {
      pty.kill();
    }
    await _ptyOutputSub?.cancel();
    _ptyOutputSub = null;
    await _outputController.close();
    await _stateController.close();
    terminal.onOutput = null;
    terminal.onResize = null;
  }

  void _onTerminalOutput(String data) {
    _pty?.write(Uint8List.fromList(utf8.encode(data)));
  }

  void _onTerminalResize(int cols, int rows, int pixelWidth, int pixelHeight) {
    _pty?.resize(rows, cols);
  }

  List<String> _buildArguments() {
    // skillName が空文字 = エクスプローラから「このディレクトリで Claude
    // Code を開く」を選んだケース。引数なしで `claude` を起動して通常の
    // 対話モードに入る。
    if (skillName.isEmpty) {
      return const [];
    }
    // Claude Code Skills はスラッシュコマンド `/skill-name` として resolve
    // される（`claude --help` の `--bare` 説明: "Skills still resolve via
    // /skill-name"）。引数として `/<name>` を渡すと claude CLI が起動直後の
    // 最初のメッセージとして処理し、スラッシュコマンド経由で skill を発火
    // する。`/` を付けずに渡すと自然言語入力扱いになり、Claude が文脈推測で
    // 別の動作をする（例: cwd 内の似た名前のスクリプトを探して実行する等）。
    final normalized = skillName.startsWith('/') ? skillName : '/$skillName';
    return [normalized];
  }

  String _formatStartError(Object error) {
    final message = error.toString();
    if (message.contains('No such file or directory') ||
        message.contains('not found') ||
        message.contains('ENOENT')) {
      return '`$executable` コマンドが見つかりません。インストールと PATH を確認してください。';
    }
    return 'プロセスの起動に失敗しました: $message';
  }

  void _emit(SkillRunState next) {
    _currentState = next;
    if (!_stateController.isClosed) {
      _stateController.add(next);
    }
  }
}
