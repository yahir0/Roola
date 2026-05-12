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
    await runner.cancel();
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
    await runner.cancel();
  });
}
