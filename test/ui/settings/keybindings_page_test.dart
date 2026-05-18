import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/keybindings/keybindings.dart';
import 'package:roola/data/keybindings/keybindings_repository.dart';
import 'package:roola/data/keybindings/keybindings_repository_impl.dart';
import 'package:roola/ui/settings/keybindings_page.dart';

class _FakeKeybindingsRepository implements KeybindingsRepository {
  @override
  Future<Keybindings> load() async => Keybindings.empty();

  @override
  Future<void> save(Keybindings keybindings) async {}
}

void main() {
  testWidgets('カテゴリ見出しとコマンド行が表示される', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keybindingsRepositoryProvider.overrideWithValue(
            _FakeKeybindingsRepository(),
          ),
        ],
        child: const MaterialApp(home: KeybindingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    // カテゴリ見出し。
    expect(find.text('ナビゲーション'), findsOneWidget);
    expect(find.text('エクスプローラ'), findsOneWidget);
    expect(find.text('Git'), findsOneWidget);

    // コマンド行のラベル。
    expect(find.text('パスをコピー'), findsOneWidget);
    expect(find.text('新規フォルダ'), findsOneWidget);

    // 既定のショートカット表示（copyPath = ⇧⌘C）。
    expect(find.text('⇧⌘C'), findsOneWidget);
  });
}
