import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/analytics/analytics_service.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_dialog.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 登録済み [LauncherEntry] をクリックしたときの「起動」アクション。
///
/// ワークスペースのターミナルタブはすべて ad-hoc セッションに正規化されて
/// いるため（ADR-0026 design Decision 5）、毎回新しい ad-hoc セッションを
/// `bottom` ペインのターミナルタブとして開く。
///
/// 表示名はすでに同名で実行中のセッションがあれば連番（" 2", " 3", ...）を
/// 付ける。Finder で同名の新規ファイルが「foo 2」「foo 3」と増えるのと同じ
/// 感覚で、同じエントリを複数並行できるようにする。連番は「現在 active な
/// 表示名のみ」を見て決めるので、閉じた跡は空き番号として埋まる。
/// `ClaudeSkillAction(requiresArgument: true)` のときは、起動前に複数行入力
/// ダイアログで引数（プロンプト本文）を受け取り、`skillArgument` として渡す
/// （ADR-0062）。ダイアログを取消した場合は起動しない。引数入力には
/// [BuildContext] が要るため、引数要求ありのエントリではこの非同期パスを使う。
Future<void> launchLauncherEntry(
  BuildContext context,
  WidgetRef ref,
  LauncherEntry entry,
) async {
  final action = entry.action;
  String? skillArgument;
  if (action is ClaudeSkillAction && action.requiresArgument) {
    final l10n = AppLocalizations.of(context);
    final input = await showPolarisMultilinePrompt(
      context,
      title: l10n.launcherSkillArgumentPromptTitle(entry.displayName),
      hintText: l10n.launcherSkillArgumentPromptHint,
      confirmLabel: l10n.launcherSkillArgumentPromptConfirm,
      cancelLabel: l10n.buttonCancel,
    );
    // 取消（null）なら起動しない。空文字での確定は許可（引数なしで実行）。
    if (input == null) {
      return;
    }
    skillArgument = input;
  }

  final sessions = ref.read(activeSessionsProvider);
  final used = _collectActiveDisplayNames(ref, sessions.keys);
  final displayName = generateUniqueDisplayName(entry.displayName, used);
  final args = AdhocRunArgs(
    adhocId: 'adhoc-${_uuid.v4()}',
    workingDirectory: entry.workingDirectory,
    displayName: displayName,
    action: entry.action,
    skillArgument: skillArgument,
  );
  ref
      .read(workspaceProvider.notifier)
      .addTerminalTab(PaneSlotId.bottom, args: args);

  // 匿名利用統計（ADR-0065）。実行種別のみを送り、パス・コマンド・エントリ名
  // は送らない。
  unawaited(
    ref.read(analyticsServiceProvider).trackEvent('launcher_executed', {
      'kind': launcherActionTypeOf(action).name,
    }),
  );
}

/// 現在 active なセッション全件の表示名を集める。すべて ad-hoc 由来なので
/// 登録時の `adhocArgs.displayName` を採用する。
Set<String> _collectActiveDisplayNames(
  WidgetRef ref,
  Iterable<String> sessionIds,
) {
  final active = ref.read(activeSessionsProvider.notifier);
  final names = <String>{};
  for (final id in sessionIds) {
    final adhoc = active.adhocArgsFor(id);
    if (adhoc != null) {
      names.add(adhoc.displayName);
    }
  }
  return names;
}

/// `base` と `existing` から重複しない表示名を作る。
///
/// アルゴリズム:
/// - `base` 自体が `existing` に無ければそのまま返す
/// - そうでなければ `base 2`, `base 3`, ... と連番を試し、`existing` に
///   入っていない最初の候補を返す（空き番号は埋める）
///
/// 例:
/// - `("foo", {})` → `"foo"`
/// - `("foo", {"foo"})` → `"foo 2"`
/// - `("foo", {"foo", "foo 2"})` → `"foo 3"`
/// - `("foo", {"foo", "foo 3"})` → `"foo 2"` （gap fill）
@visibleForTesting
String generateUniqueDisplayName(String base, Set<String> existing) {
  if (!existing.contains(base)) {
    return base;
  }
  for (var i = 2; ; i++) {
    final candidate = '$base $i';
    if (!existing.contains(candidate)) {
      return candidate;
    }
  }
}
