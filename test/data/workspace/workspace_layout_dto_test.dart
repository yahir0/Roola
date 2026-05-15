import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/skill_session/adhoc_run_args.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_layout_dto.dart';
import 'package:roola/data/workspace/workspace_tab.dart';

void main() {
  group('WorkspaceLayoutDto roundtrip', () {
    test('エクスプローラ / ターミナルタブを JSON 経由で復元できる', () {
      const layout = WorkspaceLayout(
        topLeft: PaneSlot(
          tabs: [
            WorkspaceTab.explorer(id: 'e1', currentPath: '/Users/me/repo'),
          ],
        ),
        topRight: PaneSlot(
          tabs: [
            WorkspaceTab.explorer(id: 'e2', currentPath: '/tmp'),
            WorkspaceTab.explorer(id: 'e3', currentPath: '/var'),
          ],
          activeIndex: 1,
        ),
        bottom: PaneSlot(
          tabs: [
            WorkspaceTab.terminal(
              id: 't1',
              args: AdhocRunArgs(
                adhocId: 'adhoc-original',
                workingDirectory: '/Users/me',
                displayName: 'シェル',
                action: LauncherAction.openHere(),
              ),
            ),
          ],
        ),
        topRatio: 0.7,
        leftRatio: 0.4,
      );

      final json = jsonEncode(WorkspaceLayoutDto.fromEntity(layout).toJson());
      final restored = WorkspaceLayoutDto.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      ).toEntity();

      // スプリッタ比率。
      expect(restored.topRatio, 0.7);
      expect(restored.leftRatio, 0.4);

      // エクスプローラタブはパスを復元する。
      final e1 = restored.topLeft.tabs.single as ExplorerTab;
      expect(e1.id, 'e1');
      expect(e1.currentPath, '/Users/me/repo');
      expect(restored.topRight.activeIndex, 1);
      expect((restored.topRight.tabs[1] as ExplorerTab).currentPath, '/var');

      // ターミナルタブは作業ディレクトリ / 表示名 / action を復元する。
      final t1 = restored.bottom.tabs.single as TerminalTab;
      expect(t1.id, 't1');
      expect(t1.args.workingDirectory, '/Users/me');
      expect(t1.args.displayName, 'シェル');
      expect(t1.args.action, const LauncherAction.openHere());
    });

    test('ターミナルタブの adhocId は永続化されず再採番される', () {
      const layout = WorkspaceLayout(
        topLeft: PaneSlot(
          tabs: [
            WorkspaceTab.terminal(
              id: 't1',
              args: AdhocRunArgs(
                adhocId: 'adhoc-original',
                workingDirectory: '/tmp',
                displayName: 'x',
                action: LauncherAction.openHere(),
              ),
            ),
          ],
        ),
        topRight: PaneSlot.empty,
        bottom: PaneSlot.empty,
      );

      final restored = WorkspaceLayoutDto.fromJson(
        jsonDecode(jsonEncode(WorkspaceLayoutDto.fromEntity(layout).toJson()))
            as Map<String, dynamic>,
      ).toEntity();

      final t1 = restored.topLeft.tabs.single as TerminalTab;
      // 復元時は新規 adhocId（ADR-0028: ターミナルは再 spawn）。
      expect(t1.args.adhocId, isNot('adhoc-original'));
      expect(t1.args.adhocId, startsWith('adhoc-'));
    });

    test('runCommand action も復元できる', () {
      const layout = WorkspaceLayout(
        topLeft: PaneSlot(
          tabs: [
            WorkspaceTab.terminal(
              id: 't1',
              args: AdhocRunArgs(
                adhocId: 'a',
                workingDirectory: '/tmp',
                displayName: 'cmd',
                action: LauncherAction.runCommand(command: 'ls -la'),
              ),
            ),
          ],
        ),
        topRight: PaneSlot.empty,
        bottom: PaneSlot.empty,
      );

      final restored = WorkspaceLayoutDto.fromJson(
        jsonDecode(jsonEncode(WorkspaceLayoutDto.fromEntity(layout).toJson()))
            as Map<String, dynamic>,
      ).toEntity();

      final action = (restored.topLeft.tabs.single as TerminalTab).args.action;
      expect(action, isA<RunCommandAction>());
      expect((action as RunCommandAction).command, 'ls -la');
    });
  });
}
