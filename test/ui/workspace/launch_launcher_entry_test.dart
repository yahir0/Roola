import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/explorer/launcher_actions.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

final _entry = LauncherEntry(
  id: 'entry-1',
  displayName: 'dev サーバ',
  workingDirectory: '/tmp',
  action: const LauncherAction.openHere(),
  createdAt: DateTime(2026),
);

class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => launchLauncherEntry(ref, _entry),
      child: const Text('launch'),
    );
  }
}

void main() {
  testWidgets('launchLauncherEntry は bottom ペインにターミナルタブを追加する', (tester) async {
    final container = ProviderContainer(
      overrides: [
        // bottom が空の状態から始める。
        workspaceInitialLayoutProvider.overrideWithValue(
          const WorkspaceLayout(
            topLeft: PaneSlot(
              tabs: [WorkspaceTab.explorer(id: 'e', currentPath: '/')],
            ),
            topRight: PaneSlot.empty,
            bottom: PaneSlot.empty,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: _Harness())),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    final bottom = container.read(workspaceProvider).bottom;
    expect(bottom.tabs.length, 1);
    final tab = bottom.tabs.single;
    expect(tab, isA<TerminalTab>());
    expect((tab as TerminalTab).args.displayName, 'dev サーバ');
    expect(tab.args.workingDirectory, '/tmp');
  });
}
