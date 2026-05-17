import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/data/terminal_runner/terminal_runner.dart';

/// `flutter_pty` の `Pty.start` で任意プロセスを擬似端末上に起動する実装。
///
/// 動作タイプ別の起動コマンド組み立ては [PtyTerminalRunner.fromAction] が
/// 行う。本クラス自体は `executable` / `arguments` を引数として受け取る
/// 汎用 PTY runner。
///
/// 描画は SwiftTerm（ネイティブ NSView）が担い、本クラスは PTY 出力を
/// バイト列のまま [output] Stream で配信する（ADR-0031）。UTF-8 デコードは
/// 行わない。
class PtyTerminalRunner implements TerminalRunner {
  PtyTerminalRunner({
    required this.workingDirectory,
    required this.executable,
    this.arguments = const [],
    this.idleThreshold = const Duration(seconds: 2),
  });

  /// `LauncherAction` を解釈して runner を組み立てる factory。
  ///
  /// - [OpenHereAction] → `$SHELL`（無ければ `/bin/zsh`）を引数なしで起動
  /// - [RunCommandAction] → `$SHELL -lc "<built-command>"`。`keepShellAfterExit`
  ///   が true のときは末尾に `; exec $SHELL -i` を後置し、コマンド完了後に
  ///   ログインシェルが立ち上がる
  /// - [ClaudeSkillAction] → `claude /<skillName>`（旧 `PtySkillRunner` の
  ///   `_buildArguments` と同等の挙動。先頭の `/` 自動付与もここで行う）
  factory PtyTerminalRunner.fromAction({
    required String workingDirectory,
    required LauncherAction action,
    Duration idleThreshold = const Duration(seconds: 2),
  }) {
    final (executable, arguments) = _resolveExecutable(action);
    return PtyTerminalRunner(
      workingDirectory: workingDirectory,
      executable: executable,
      arguments: arguments,
      idleThreshold: idleThreshold,
    );
  }

  /// 子プロセスの作業ディレクトリ。
  final String workingDirectory;

  /// 起動するコマンド名。テストでは `bash` など差し替え可。
  final String executable;

  /// `executable` に渡す引数列。
  final List<String> arguments;

  /// PTY 出力が止まってから `waitingInput` 状態へ遷移するまでの時間。
  /// 短すぎると claude の通常思考中も「入力待ち」と表示されてしまうため、
  /// 既定 2 秒。出力が再開すれば即 `running` に戻る。
  final Duration idleThreshold;

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

    if (!Directory(workingDirectory).existsSync()) {
      _emit(SkillRunState.failed('作業ディレクトリが見つかりません: $workingDirectory'));
      return;
    }

    try {
      _pty = Pty.start(
        executable,
        arguments: arguments,
        workingDirectory: workingDirectory,
      );
    } on Object catch (e) {
      _emit(SkillRunState.failed(_formatStartError(e)));
      return;
    }

    _ptyOutputSub = _pty!.output.listen((bytes) {
      if (!_outputController.isClosed) {
        _outputController.add(bytes);
      }
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

  static (String, List<String>) _resolveExecutable(LauncherAction action) {
    return switch (action) {
      OpenHereAction() => (_userShell(), const <String>[]),
      // `$SHELL -ilc '<command>'` で起動。`-i -l` の両方が必要なのは
      // ClaudeSkillAction と同じ理由（`.zshrc` に PATH を書いているユーザー
      // 環境で `-l` だけだと PATH が伸びず claude / node 等が `command not
      // found` になる）。エクスプローラ右クリックの「Claude Code を開く」も
      // この経路で `claude` を起動するため、`-lc` だと GUI 起動経路で落ちる。
      RunCommandAction(:final command, :final keepShellAfterExit) => (
        _userShell(),
        ['-ilc', _buildShellCommand(command, keepShellAfterExit)],
      ),
      // Claude Code Skills はスラッシュコマンド `/skill-name` として resolve
      // される（`claude --help` の `--bare` 説明: "Skills still resolve via
      // /skill-name"）。引数として `/<name>` を渡すと claude CLI が起動直後の
      // 最初のメッセージとして処理し、スラッシュコマンド経由で skill を発火
      // する。`/` を付けずに渡すと自然言語入力扱いになり、Claude が文脈推測で
      // 別の動作をする（例: cwd 内の似た名前のスクリプトを探して実行する等）。
      //
      // 直接 `claude` を `Pty.start` するとプロセスの PATH が launchd 由来の
      // 最小 PATH (`/usr/bin:/bin:...`) になり、pnpm / nvm / Homebrew 配下の
      // `claude` も、claude の shebang が呼ぶ `node` も解決できず
      // `execvp: No such file or directory` で即落ちする（DMG / Dock 起動）。
      // ターミナル直起動だと再現しないため気付きにくい。
      //
      // login + interactive shell (`$SHELL -i -l`) 経由で起動して
      // `.zprofile` / `.zshrc` の両方を読み込ませて PATH を継承させ、
      // `exec "$@"` でシェル自身を claude に置き換えることでプロセスツリー
      // を増やさずに済ます。`-c` の `"$@"` quote により skill 名に空白等が
      // 含まれても safe。
      //
      // `-l` だけだと `.zshrc` が読まれず、`.zshrc` に PATH 拡張を書いて
      // いるユーザー（pnpm / Homebrew 等の一般的構成）で `command not
      // found` になる。`-i` を追加して `.zshrc` も読ませる。
      ClaudeSkillAction(:final skillName) => (
        _userShell(),
        <String>[
          '-i',
          '-l',
          '-c',
          r'exec "$@"',
          '_',
          'claude',
          skillName.startsWith('/') ? skillName : '/$skillName',
        ],
      ),
    };
  }

  static String _userShell() {
    final shell = Platform.environment['SHELL'];
    return (shell != null && shell.isNotEmpty) ? shell : '/bin/zsh';
  }

  /// `keepShellAfterExit=true` のときは末尾に `; exec $SHELL -i` を後置する。
  ///
  /// `;` で繋ぐのはコマンド失敗時にもシェルが残る挙動のため（`&&` だと失敗時
  /// に PTY が即終了して結果が見えない）。`exec` でプロセスを置換するので、
  /// ユーザーから見るとコマンド完了後にプロンプトが現れる体験になる。
  static String _buildShellCommand(String command, bool keepShellAfterExit) {
    if (!keepShellAfterExit) {
      return command;
    }
    return '$command; exec \$SHELL -i';
  }
}
