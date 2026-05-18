import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/notepad/notepad_repository.dart';
import 'package:roola/data/notepad/notepad_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/notepad/notepad_panel.dart';
import 'package:roola/ui/notepad/notepad_view_model.dart';

class _FakeNotepadRepository implements NotepadRepository {
  String saved = '';

  @override
  Future<String> load() async => saved;

  @override
  Future<void> save(String content) async => saved = content;
}

void main() {
  Widget app({required VoidCallback onClose, String initial = ''}) {
    return ProviderScope(
      overrides: [
        notepadRepositoryProvider.overrideWithValue(_FakeNotepadRepository()),
        notepadInitialContentProvider.overrideWithValue(initial),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ja'),
        home: Scaffold(body: NotepadPanel(onClose: onClose)),
      ),
    );
  }

  testWidgets('typing shows one line number per logical line', (tester) async {
    await tester.pumpWidget(app(onClose: () {}));
    await tester.enterText(find.byType(TextField), 'first\nsecond\nthird');
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // 保留中の debounce タイマーを消化してから終わる。
    await tester.pump(
      NotepadViewModel.saveDebounce + const Duration(milliseconds: 50),
    );
  });

  testWidgets('does not overflow when content exceeds the viewport', (
    tester,
  ) async {
    final manyLines = List.generate(60, (i) => 'line ${i + 1}').join('\n');
    await tester.pumpWidget(app(onClose: () {}, initial: manyLines));
    await tester.pump();

    // 行番号 Column がビューポートより高くてもレイアウト例外を出さない。
    expect(tester.takeException(), isNull);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('renders the injected initial content', (tester) async {
    await tester.pumpWidget(app(onClose: () {}, initial: 'restored note'));
    expect(find.text('restored note'), findsOneWidget);
  });

  testWidgets('the close button invokes onClose', (tester) async {
    var closed = false;
    await tester.pumpWidget(app(onClose: () => closed = true));

    await tester.tap(find.byIcon(Icons.close));
    expect(closed, isTrue);
  });
}
