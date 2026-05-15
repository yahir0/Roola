import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_repository.dart';
import 'package:roola/data/workspace/workspace_repository_impl.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/ui/workspace/pane_tab_strip.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

class _FakeWorkspaceRepository implements WorkspaceRepository {
  @override
  Future<WorkspaceLayout?> load() async => null;
  @override
  Future<void> save(WorkspaceLayout layout) async {}
}

/// `topLeft` スロットのタブストリップを `workspaceProvider` 連動で描画する。
class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slot = ref.watch(
      workspaceProvider.select((l) => l.slot(PaneSlotId.topLeft)),
    );
    return PaneTabStrip(slotId: PaneSlotId.topLeft, slot: slot);
  }
}

void main() {
  Widget app(WorkspaceLayout initial) => ProviderScope(
    overrides: [
      workspaceInitialLayoutProvider.overrideWithValue(initial),
      workspaceRepositoryProvider.overrideWithValue(_FakeWorkspaceRepository()),
    ],
    child: const MaterialApp(home: Scaffold(body: _Harness())),
  );

  testWidgets('タブのラベル（パス basename）が描画される', (tester) async {
    await tester.pumpWidget(
      app(
        const WorkspaceLayout(
          topLeft: PaneSlot(
            tabs: [
              WorkspaceTab.explorer(id: 'a', currentPath: '/tmp'),
              WorkspaceTab.explorer(id: 'b', currentPath: '/var'),
            ],
          ),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      ),
    );
    expect(find.text('tmp'), findsOneWidget);
    expect(find.text('var'), findsOneWidget);
  });

  testWidgets('タブの × でタブが閉じる', (tester) async {
    await tester.pumpWidget(
      app(
        const WorkspaceLayout(
          topLeft: PaneSlot(
            tabs: [
              WorkspaceTab.explorer(id: 'a', currentPath: '/tmp'),
              WorkspaceTab.explorer(id: 'b', currentPath: '/var'),
            ],
          ),
          topRight: PaneSlot.empty,
          bottom: PaneSlot.empty,
        ),
      ),
    );
    expect(find.byIcon(Icons.close), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    // 1 タブだけ残る。
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('tmp'), findsNothing);
    expect(find.text('var'), findsOneWidget);
  });
}
