import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_runner.dart';
import 'package:flutter_pty/flutter_pty.dart';

/// `flutter_pty` の `Pty.start` で `claude` を擬似端末上に起動する実装。
class PtySkillRunner implements SkillRunner {
  PtySkillRunner({
    required this.repositoryPath,
    required this.skillName,
    this.executable = 'claude',
  });

  /// 子プロセスの作業ディレクトリ。
  final String repositoryPath;

  /// 実行する Skill 名（`claude` への引数として渡す）。
  final String skillName;

  /// 起動するコマンド名。テストでは `bash` など差し替え可。
  final String executable;

  Pty? _pty;
  final _stateController = StreamController<SkillRunState>.broadcast();
  SkillRunState _currentState = const SkillRunState.idle();
  bool _started = false;

  @override
  SkillRunState get currentState => _currentState;

  @override
  Stream<SkillRunState> get state => _stateController.stream;

  @override
  Stream<Uint8List> get output =>
      _pty?.output ?? const Stream<Uint8List>.empty();

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

    _emit(const SkillRunState.running());

    unawaited(
      _pty!.exitCode.then((code) {
        if (_currentState is SkillRunCancelled) {
          return;
        }
        _emit(SkillRunState.completed(code));
      }),
    );
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
    pty.kill();
    _emit(const SkillRunState.cancelled());
    await _stateController.close();
  }

  List<String> _buildArguments() {
    // claude CLI に Skill 名を引数として渡す前提。実際の Skills 実行方式が
    // 異なる場合（例: スラッシュコマンド経由）はここで変える。
    return [skillName];
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
