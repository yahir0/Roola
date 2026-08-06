import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_tab.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/workspace/pane_tab_strip.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:roola/ui/workspace/workspace_seed.dart';

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
    overrides: [workspaceInitialLayoutProvider.overrideWithValue(initial)],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('ja'),
      home: Scaffold(body: _Harness()),
    ),
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
          bottomLeft: PaneSlot.empty,
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
          bottomLeft: PaneSlot.empty,
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

  testWidgets('右クリックメニューから右下ペインへ移動して 4 分割になる（ADR-0068）', (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workspaceInitialLayoutProvider.overrideWithValue(
            const WorkspaceLayout(
              topLeft: PaneSlot(
                tabs: [
                  WorkspaceTab.explorer(id: 'a', currentPath: '/tmp'),
                  WorkspaceTab.explorer(id: 'b', currentPath: '/var'),
                ],
              ),
              topRight: PaneSlot(
                tabs: [WorkspaceTab.explorer(id: 'c', currentPath: '/usr')],
              ),
              bottomLeft: PaneSlot(
                tabs: [WorkspaceTab.explorer(id: 'd', currentPath: '/etc')],
              ),
            ),
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ja'),
              home: Scaffold(body: _Harness()),
            );
          },
        ),
      ),
    );

    // タブ chip を右クリックしてメニューを開く。
    await tester.tap(find.text('tmp'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();

    // 現在のペイン（左上）以外の 3 つが並ぶ。
    expect(find.text('タブを右上ペインへ移動'), findsOneWidget);
    expect(find.text('タブを左下ペインへ移動'), findsOneWidget);
    expect(find.text('タブを右下ペインへ移動'), findsOneWidget);
    expect(find.text('タブを左上ペインへ移動'), findsNothing);

    await tester.tap(find.text('タブを右下ペインへ移動'));
    await tester.pumpAndSettle();

    final layout = container.read(workspaceProvider);
    expect(layout.bottomRight.tabs.single.id, 'a');
    expect(layout.topLeft.tabs.map((t) => t.id), ['b']);
    // 4 スロットすべてが埋まる = 4 分割。
    expect(layout.nonEmptySlots.length, 4);
  });
}
