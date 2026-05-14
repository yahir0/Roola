import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/skill_session/active_sessions.dart';
import 'package:roola/ui/explorer/explorer_selection.dart';
import 'package:roola/ui/run/adhoc_run_view_model.dart';
import 'package:roola/ui/run/run_view_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 登録済み LauncherEntry をクリックしたときの「起動」アクション。
///
/// 既に同 entry の永続セッション（entry.id を ID とするセッション）が
/// 走っていなければ、それを起動して selection をそのセッションに切替える
/// 単発起動。
///
/// すでに走っていれば、`entry.displayName` を base に連番（" 2", " 3", ...）
/// で空きを探し、ad-hoc セッションとして同時起動する。Finder で同名の
/// 新規ファイルが「foo 2」「foo 3」と増えていくのと同じ感覚で、同じ Skill
/// を複数並行できるようにする。
///
/// 連番は「現在 active な表示名のみ」を見て決める。閉じた跡は空き番号に
/// なるので、`base`, `base 3` が動いていて `base 2` が閉じられた状態で
/// 次に起動すると `base 2` が割り当てられる。
void launchLauncherEntry(WidgetRef ref, LauncherEntry entry) {
  final sessions = ref.read(activeSessionsProvider);
  final selection = ref.read(explorerSelectionProvider.notifier);

  // ケース 1: まだ 1 つも動いていない → 永続セッションとして起動。
  if (!sessions.containsKey(entry.id)) {
    ref.read(runViewModelProvider(entry.id));
    selection.selectEntrySession(entry.id);
    return;
  }

  // ケース 2: すでに動いている → ad-hoc で連番起動。entry の動作タイプを
  // そのまま継承する（ADR-0016: 動作タイプは AdhocRunArgs.action に統合）。
  final used = _collectActiveDisplayNames(ref, sessions.keys);
  final displayName = generateUniqueDisplayName(entry.displayName, used);
  final args = AdhocRunArgs(
    adhocId: 'adhoc-${_uuid.v4()}',
    workingDirectory: entry.workingDirectory,
    displayName: displayName,
    action: entry.action,
  );
  ref.read(adhocRunViewModelProvider(args));
  selection.selectAdhocSession(args);
}

/// 現在 active なセッション全件の表示名を集める。
///
/// 永続エントリ由来は `entry.displayName`、ad-hoc 由来は登録時の
/// `adhocArgs.displayName` を採用する。整合性が崩れて両方とも引けない
/// セッション（理論上ありえない）はスキップ。
Set<String> _collectActiveDisplayNames(
  WidgetRef ref,
  Iterable<String> sessionIds,
) {
  final entries = ref.read(launcherEntriesProvider).value ?? const [];
  final active = ref.read(activeSessionsProvider.notifier);
  final names = <String>{};
  for (final id in sessionIds) {
    final entry = entries.where((e) => e.id == id).firstOrNull;
    if (entry != null) {
      names.add(entry.displayName);
      continue;
    }
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
  for (var i = 2;; i++) {
    final candidate = '$base $i';
    if (!existing.contains(candidate)) {
      return candidate;
    }
  }
}
