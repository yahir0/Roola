import 'dart:io';

import 'package:claude_skills_launcher/data/skill_runner/pty_skill_runner.dart';
import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// `PtySkillRunner` の状態遷移を、軽量コマンド（`true`/`false`）で検証する。
///
/// PTY 上で `claude` を起動する代わりに、`/usr/bin/true`（即座に exit 0）と
/// `/usr/bin/false`（exit 1）を使うことで CI 外でも実行可能なテストにする。
void main() {
  test('failed when repository directory does not exist', () async {
    final runner = PtySkillRunner(
      repositoryPath: '/path/does/not/exist',
      skillName: 'demo',
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
    final dir = await Directory.systemTemp.createTemp('cskl_pty_');
    addTearDown(() => dir.delete(recursive: true));

    final runner = PtySkillRunner(
      repositoryPath: dir.path,
      skillName: 'unused',
      executable: '/no/such/binary',
    );
    await runner.start();
    expect(runner.currentState, isA<SkillRunFailed>());
    await runner.dispose();
  });

  test('terminal is available before start and survives cancel', () async {
    final dir = await Directory.systemTemp.createTemp('cskl_pty_term_');
    addTearDown(() => dir.delete(recursive: true));

    final runner = PtySkillRunner(
      repositoryPath: dir.path,
      skillName: 'unused',
    );

    // 構築直後に terminal が存在する（View が即購読できる）
    final terminalBefore = runner.terminal;
    expect(terminalBefore, isNotNull);

    // cancel しても terminal インスタンスは保持される
    await runner.cancel();
    expect(identical(runner.terminal, terminalBefore), isTrue);

    // dispose 後も terminal 参照自体は残るが onOutput / onResize は外れる
    await runner.dispose();
    expect(runner.terminal.onOutput, isNull);
    expect(runner.terminal.onResize, isNull);
  });

  test(
    'output stream is subscribable before start (does not complete immediately)',
    () async {
      // 回帰: 以前は `output` getter が `_pty?.output ?? Stream.empty()` を
      // 返していたため、構築直後に subscribe するとすぐに完了済みの空 Stream に
      // 紐づいてしまい、PTY 生成後の出力が xterm に流れなかった。
      // RunPage の useEffect は build 時点で subscribe するため、この順序を
      // ロックするテスト。
      final dir = await Directory.systemTemp.createTemp('cskl_pty_out_');
      addTearDown(() => dir.delete(recursive: true));

      final runner = PtySkillRunner(
        repositoryPath: dir.path,
        skillName: 'unused',
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
}
