import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/terminal_runner/pty_terminal_runner.dart';
import 'package:roola/data/terminal_runner/terminal_run_state.dart';

/// `PtyTerminalRunner` の状態遷移と `fromAction` factory を検証する。
///
/// PTY 上で実プロセスを起動する代わりに「存在しないバイナリ」を `executable`
/// に指定して `failed` 遷移を確認する。`fromAction` で組み立てた
/// `(executable, arguments)` の妥当性は、生成後の `runner.executable` /
/// `runner.arguments` を直接見て担保する（実プロセス起動は integration_test
/// の責務）。
void main() {
  test('failed when working directory does not exist', () async {
    final runner = PtyTerminalRunner(
      workingDirectory: '/path/does/not/exist',
      executable: 'true',
    );
    await runner.start();
    expect(runner.currentState, isA<SkillRunFailed>());
    await runner.dispose();
  });

  // NOTE: 実際の PTY 上で起動したプロセスの exitCode 検証は、flutter_pty が
  // ネイティブ ReceivePort 経由で結果を返す構造のため `flutter test` の
  // テストバインディング下では動かない（ネイティブ側が初期化されない）。
  // 当該検証は integration_test で扱う想定。本ファイルでは事前検証
  // （存在しないディレクトリ・存在しない実行ファイル）の状態遷移のみ確認する。

  test('failed when executable is missing', () async {
    final dir = await Directory.systemTemp.createTemp('roola_pty_');
    addTearDown(() => dir.delete(recursive: true));

    final runner = PtyTerminalRunner(
      workingDirectory: dir.path,
      executable: '/no/such/binary',
    );
    await runner.start();
    expect(runner.currentState, isA<SkillRunFailed>());
    await runner.dispose();
  });

  test('output stream survives cancel (closed only on dispose)', () async {
    final dir = await Directory.systemTemp.createTemp('roola_pty_term_');
    addTearDown(() => dir.delete(recursive: true));

    final runner = PtyTerminalRunner(
      workingDirectory: dir.path,
      executable: 'true',
    );

    // SwiftTerm へ流す output Stream は描画の唯一の供給源（ADR-0031）。
    // cancel（PTY を SIGTERM 終了）してもセッション参照は残るため、
    // output Stream は閉じない。
    var done = false;
    final sub = runner.output.listen((_) {}, onDone: () => done = true);

    await runner.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(done, isFalse);

    // dispose で初めて output Stream が閉じる。
    await sub.cancel();
    await runner.dispose();
  });

  test(
    'output stream is subscribable before start (does not complete immediately)',
    () async {
      // 回帰: 以前は `output` getter が `_pty?.output ?? Stream.empty()` を
      // 返していたため、構築直後に subscribe するとすぐに完了済みの空 Stream に
      // 紐づいてしまい、PTY 生成後の出力がターミナルに流れなかった。
      // `TerminalSurface` は build 時点で subscribe するため、この順序を
      // ロックするテスト。
      final dir = await Directory.systemTemp.createTemp('roola_pty_out_');
      addTearDown(() => dir.delete(recursive: true));

      final runner = PtyTerminalRunner(
        workingDirectory: dir.path,
        executable: 'true',
      );
      var done = false;
      final sub = runner.output.listen((_) {}, onDone: () => done = true);

      // 短時間待っても Stream は完了状態にならない（subscribe を保持する）。
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(done, isFalse);

      await sub.cancel();
      await runner.dispose();
    },
  );

  group('PtyTerminalRunner.fromAction', () {
    late Directory dir;
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('roola_pty_factory_');
    });
    tearDown(() async {
      await dir.delete(recursive: true);
    });

    test(
      r'OpenHereAction → executable は $SHELL（無ければ /bin/zsh）, arguments は空',
      () {
        final runner = PtyTerminalRunner.fromAction(
          workingDirectory: dir.path,
          action: const LauncherAction.openHere(),
        );
        addTearDown(runner.dispose);
        final expectedShell = Platform.environment['SHELL'] ?? '/bin/zsh';
        expect(runner.executable, expectedShell);
        expect(runner.arguments, isEmpty);
      },
    );

    test(
      'RunCommandAction(keepShellAfterExit: true) → \$SHELL -ilc "<cmd>; exec \$SHELL -i"',
      () {
        final runner = PtyTerminalRunner.fromAction(
          workingDirectory: dir.path,
          action: const LauncherAction.runCommand(command: 'echo hi'),
        );
        addTearDown(runner.dispose);
        final expectedShell = Platform.environment['SHELL'] ?? '/bin/zsh';
        expect(runner.executable, expectedShell);
        expect(runner.arguments.length, 2);
        expect(runner.arguments[0], '-ilc');
        expect(runner.arguments[1], r'echo hi; exec $SHELL -i');
      },
    );

    test(
      'RunCommandAction(keepShellAfterExit: false) → \$SHELL -lc "<cmd>" のみ',
      () {
        final runner = PtyTerminalRunner.fromAction(
          workingDirectory: dir.path,
          action: const LauncherAction.runCommand(
            command: 'make build',
            keepShellAfterExit: false,
          ),
        );
        addTearDown(runner.dispose);
        expect(runner.arguments[1], 'make build');
      },
    );

    test('ClaudeSkillAction → login shell 経由で claude /<skillName> を起動', () {
      final runner = PtyTerminalRunner.fromAction(
        workingDirectory: dir.path,
        action: const LauncherAction.claudeSkill(skillName: 'my-skill'),
      );
      addTearDown(runner.dispose);
      // GUI 起動経路の PATH 継承のため login + interactive shell 経由
      // （`$SHELL -i -l -c 'exec "$@"' _ claude /<skill>`）。
      final expectedShell = Platform.environment['SHELL'] ?? '/bin/zsh';
      expect(runner.executable, expectedShell);
      expect(runner.arguments, [
        '-i',
        '-l',
        '-c',
        r'exec "$@"',
        '_',
        'claude',
        '/my-skill',
      ]);
    });

    test('ClaudeSkillAction で既に `/` 始まりの skillName はそのまま使う', () {
      final runner = PtyTerminalRunner.fromAction(
        workingDirectory: dir.path,
        action: const LauncherAction.claudeSkill(skillName: '/already-slashed'),
      );
      addTearDown(runner.dispose);
      expect(runner.arguments.last, '/already-slashed');
    });
  });
}
