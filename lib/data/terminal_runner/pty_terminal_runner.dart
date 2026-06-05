import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';
import 'package:roola/data/terminal_runner/terminal_runner.dart';
import 'package:roola/data/terminal_runner/windows_shell.dart';

/// `flutter_pty` の `Pty.start` で任意プロセスを擬似端末上に起動する実装。
///
/// 動作タイプ別の起動コマンド組み立ては [PtyTerminalRunner.fromAction] が
/// 行う。本クラス自体は `executable` / `arguments` を引数として受け取る
/// 汎用 PTY runner。
///
/// 描画は SwiftTerm（ネイティブ NSView / macOS）または xterm.js WebView2
/// （Windows）が担い、本クラスは PTY 出力をバイト列のまま [output] Stream で
/// 配信する（ADR-0031 / ADR-0058）。UTF-8 デコードは行わない。
class PtyTerminalRunner implements TerminalRunner {
  PtyTerminalRunner({
    required this.workingDirectory,
    required this.executable,
    this.arguments = const [],
    this.environment,
    this.idleThreshold = const Duration(seconds: 2),
    this.unsupportedError,
  });

  /// `LauncherAction` を解釈して runner を組み立てる factory。
  ///
  /// `skillArgument` は `ClaudeSkillAction` のとき `claude /<skill> <引数>` の
  /// 単一引数として渡される（ADR-0062）。null / 空なら従来どおり引数なしで
  /// `claude /<skill>` を起動する。
  factory PtyTerminalRunner.fromAction({
    required String workingDirectory,
    required LauncherAction action,
    Map<String, String>? environment,
    Duration idleThreshold = const Duration(seconds: 2),
    WindowsShell windowsShell = WindowsShell.powershell,
    String? skillArgument,
  }) {
    final (executable, arguments) = _resolveExecutable(
      action,
      windowsShell: windowsShell,
      skillArgument: skillArgument,
    );
    return PtyTerminalRunner(
      workingDirectory: workingDirectory,
      executable: executable,
      arguments: arguments,
      environment: Platform.isWindows ? _windowsEnvironment(environment) : environment,
      idleThreshold: idleThreshold,
    );
  }

  /// Windows では flutter_pty が HOME / PATH 等しか PTY に引き継がないため、
  /// SYSTEMROOT / USERPROFILE 等のシステム変数を明示的に補完する。
  /// （flutter_pty は environment パラメータを effectiveEnv に追記するため
  /// ここで渡した変数はホワイトリスト外でも PTY プロセスに届く。）
  static Map<String, String> _windowsEnvironment(
    Map<String, String>? extra,
  ) {
    const keys = [
      'SYSTEMROOT', 'SystemRoot',
      'WINDIR', 'windir',
      'ComSpec', 'COMSPEC',
      'USERPROFILE',
      'USERNAME', 'USERDOMAIN',
      'APPDATA', 'LOCALAPPDATA',
      'TEMP', 'TMP',
      'SystemDrive',
      'PATHEXT',
      'OS',
      'PROCESSOR_ARCHITECTURE',
    ];
    final env = <String, String>{};
    for (final key in keys) {
      final value = Platform.environment[key];
      if (value != null) env[key] = value;
    }
    if (extra != null) env.addAll(extra);
    return env;
  }

  /// null 以外の場合、[start] は PTY を起動せずこのメッセージで即 failed 遷移する。
  final String? unsupportedError;

  /// 子プロセスの作業ディレクトリ。
  final String workingDirectory;

  /// 起動するコマンド名。
  final String executable;

  /// `executable` に渡す引数列。
  final List<String> arguments;

  /// PTY プロセスに追加注入する環境変数。
  final Map<String, String>? environment;

  /// PTY 出力が止まってから `waitingInput` 状態へ遷移するまでの時間（既定 2 秒）。
  final Duration idleThreshold;

  Pty? _pty;
  Timer? _idleTimer;
  final _stateController = StreamController<SkillRunState>.broadcast();
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
    if (_started) return;
    _started = true;
    _emit(const SkillRunState.starting());

    // Windows で未サポートアクション（ClaudeSkillAction 等）の場合は即 failed。
    if (unsupportedError != null) {
      _emit(SkillRunState.failed(unsupportedError!));
      return;
    }

    if (!Directory(workingDirectory).existsSync()) {
      _emit(SkillRunState.failed('作業ディレクトリが見つかりません: $workingDirectory'));
      return;
    }

    try {
      _pty = Pty.start(
        executable,
        arguments: arguments,
        workingDirectory: workingDirectory,
        environment: environment,
      );
    } on Object catch (e) {
      _emit(SkillRunState.failed(_formatStartError(e)));
      return;
    }

    _ptyOutputSub = _pty!.output.listen((bytes) {
      if (!_outputController.isClosed) {
        _outputController.add(bytes);
      }
      if (_currentState is SkillRunWaitingInput) {
        _emit(const SkillRunState.running());
      }
      _scheduleIdleCheck();
    });

    _emit(const SkillRunState.running());
    _scheduleIdleCheck();

    unawaited(
      _pty!.exitCode.then((code) {
        if (_currentState is SkillRunCancelled) return;
        _idleTimer?.cancel();
        _emit(SkillRunState.completed(code));
      }),
    );
  }

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
    if (pty == null) return;
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
    if (_disposed) return;
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

  static (String, List<String>) _resolveExecutable(
    LauncherAction action, {
    WindowsShell windowsShell = WindowsShell.powershell,
    String? skillArgument,
  }) {
    if (Platform.isWindows) {
      return _resolveExecutableWindows(action, windowsShell, skillArgument);
    }
    return _resolveExecutableMacos(action, skillArgument);
  }

  static (String, List<String>) _resolveExecutableMacos(
    LauncherAction action,
    String? skillArgument,
  ) {
    return switch (action) {
      OpenHereAction() => (_userShell(), const <String>[]),
      RunCommandAction(:final command, :final keepShellAfterExit) => (
          _userShell(),
          ['-ilc', _buildShellCommand(command, keepShellAfterExit)],
        ),
      // `exec "$@"` でログインシェルを claude プロセスに置き換える。引数は
      // argv 要素としてそのまま渡るため、シェルのエスケープや文字コードの
      // 変質を受けない（ADR-0062）。skillArgument は `/skill <本文>` の単一
      // 引数に連結する（本文に空白 / 改行があっても 1 引数のまま claude に
      // 届く）。
      ClaudeSkillAction(:final skillName) => (
          _userShell(),
          <String>[
            '-i',
            '-l',
            '-c',
            r'exec "$@"',
            '_',
            'claude',
            _claudeSkillPrompt(skillName, skillArgument),
          ],
        ),
    };
  }

  static (String, List<String>) _resolveExecutableWindows(
    LauncherAction action,
    WindowsShell shell,
    String? skillArgument,
  ) {
    final exe = _windowsShellExe(shell);
    return switch (action) {
      OpenHereAction() => _windowsOpenHere(exe, shell),
      RunCommandAction(:final command, :final keepShellAfterExit) =>
        _windowsRunCommand(exe, shell, command, keepShellAfterExit),
      ClaudeSkillAction(:final skillName) =>
        _windowsClaudeSkill(exe, shell, skillName, skillArgument),
    };
  }

  /// `claude` に渡す単一の positional 引数（`/skill` または `/skill <本文>`）を
  /// 組み立てる。`skillName` が `/` 始まりでなければ補う。`argument` が
  /// 非空のときだけ半角空白で連結する。
  static String _claudeSkillPrompt(String skillName, String? argument) {
    final skill = skillName.startsWith('/') ? skillName : '/$skillName';
    if (argument == null || argument.isEmpty) {
      return skill;
    }
    return '$skill $argument';
  }

  static String _windowsShellExe(WindowsShell shell) => switch (shell) {
        WindowsShell.cmd => 'cmd.exe',
        WindowsShell.powershell => 'powershell.exe',
        WindowsShell.pwsh => 'pwsh.exe',
      };

  static (String, List<String>) _windowsOpenHere(
      String exe, WindowsShell shell) {
    return switch (shell) {
      WindowsShell.cmd => (exe, const <String>[]),
      WindowsShell.powershell => (exe, const ['-NoExit']),
      WindowsShell.pwsh => (exe, const ['-NoExit']),
    };
  }

  static (String, List<String>) _windowsRunCommand(
    String exe,
    WindowsShell shell,
    String command,
    bool keepShellAfterExit,
  ) {
    return switch (shell) {
      WindowsShell.cmd => (
          exe,
          [keepShellAfterExit ? '/K' : '/C', command],
        ),
      WindowsShell.powershell => (
          exe,
          [if (keepShellAfterExit) '-NoExit', '-Command', command],
        ),
      WindowsShell.pwsh => (
          exe,
          [if (keepShellAfterExit) '-NoExit', '-Command', command],
        ),
    };
  }

  static (String, List<String>) _windowsClaudeSkill(
    String exe,
    WindowsShell shell,
    String skillName,
    String? skillArgument,
  ) {
    final skill = skillName.startsWith('/') ? skillName : '/$skillName';
    final hasArg = skillArgument != null && skillArgument.isNotEmpty;
    // claude は npm の .cmd シム経由でしかないため、シェル（cmd / PowerShell）の
    // コマンド文字列に埋め込まざるを得ない。引数なしは従来どおり素の
    // `claude /skill`。引数ありは `prompt`（= `/skill <本文>`）を claude への
    // 1 引数としてシェルごとにクォートする（ADR-0062）。PowerShell / pwsh は
    // シングルクォート囲み（`'` → `''`）で `$` / バッククォート / `%` / `!` /
    // 改行をリテラル化でき最も安全。cmd は仕様上アーバイトラリなテキストを
    // 安全に渡しきれないため best-effort。
    final String command;
    if (!hasArg) {
      command = 'claude $skill';
    } else {
      final prompt = '$skill $skillArgument';
      command = switch (shell) {
        WindowsShell.cmd => 'claude ${_cmdQuote(prompt)}',
        WindowsShell.powershell ||
        WindowsShell.pwsh => 'claude ${_powerShellQuote(prompt)}',
      };
    }
    return switch (shell) {
      WindowsShell.cmd => (exe, ['/C', command]),
      WindowsShell.powershell => (exe, ['-Command', command]),
      WindowsShell.pwsh => (exe, ['-Command', command]),
    };
  }

  /// PowerShell のシングルクォート文字列リテラルとして安全に囲む。
  /// シングルクォートのみ `''` にエスケープすればよく、`$` / バッククォート /
  /// `%` / `!` / 改行はすべてリテラルとして扱われる。
  static String _powerShellQuote(String s) => "'${s.replaceAll("'", "''")}'";

  /// cmd.exe 向けの best-effort クォート。ダブルクォートで囲み、内側の `"` を
  /// `""` にする。cmd の `%`（変数展開）等は完全には無害化できないため、長文 /
  /// 特殊文字を確実に渡したい場合は PowerShell を推奨（ADR-0062）。
  static String _cmdQuote(String s) => '"${s.replaceAll('"', '""')}"';

  static String _userShell() {
    final shell = Platform.environment['SHELL'];
    return (shell != null && shell.isNotEmpty) ? shell : '/bin/zsh';
  }

  static String _buildShellCommand(String command, bool keepShellAfterExit) {
    if (!keepShellAfterExit) return command;
    return '$command; exec \$SHELL -i';
  }
}
