import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 新しいタブ id を払い出す。
String newTabId() => 'tab-${_uuid.v4()}';

/// ワークスペースの既定ホームディレクトリ。
/// macOS / Linux は `$HOME`、Windows は `%USERPROFILE%` を使う。
String defaultWorkspaceHome() {
  final home = Platform.environment['HOME']
      ?? Platform.environment['USERPROFILE'];
  if (home != null && home.isNotEmpty) return home;
  return Platform.isWindows ? 'C:\\' : '/';
}

/// 既定の素のシェル ad-hoc 起動引数（$HOME / `OpenHereAction`）。
///
/// ターミナルタブを「+」から追加するときと、初回 seed の `bottom` ペインで
/// 使う。`adhocId` は毎回新規払い出し（ADR-0028: ターミナルは再 spawn）。
AdhocRunArgs defaultTerminalArgs() => AdhocRunArgs(
  adhocId: 'adhoc-${_uuid.v4()}',
  workingDirectory: defaultWorkspaceHome(),
  displayName: 'ターミナル',
  action: const LauncherAction.openHere(),
);

/// 初回起動 / 永続データ無し時の既定 3 ペインレイアウト（ADR-0026）。
///
/// `topLeft` / `topRight` はエクスプローラ（$HOME）、`bottom` は素のシェル
/// のターミナル（$HOME）。
WorkspaceLayout seedDefaultWorkspace() {
  final home = defaultWorkspaceHome();
  return WorkspaceLayout(
    topLeft: PaneSlot(
      tabs: [WorkspaceTab.explorer(id: newTabId(), currentPath: home)],
    ),
    topRight: PaneSlot(
      tabs: [WorkspaceTab.explorer(id: newTabId(), currentPath: home)],
    ),
    bottom: PaneSlot(
      tabs: [
        WorkspaceTab.terminal(id: newTabId(), args: defaultTerminalArgs()),
      ],
    ),
  );
}

/// `workspaceProvider` の初期レイアウト。
///
/// 既定は [seedDefaultWorkspace] で、本体（`main`）はこれを override しない
/// （ADR-0042）。テストでは固定レイアウトを注入するために override する。
final workspaceInitialLayoutProvider = Provider<WorkspaceLayout>(
  (ref) => seedDefaultWorkspace(),
);
