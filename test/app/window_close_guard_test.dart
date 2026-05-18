import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/app/window_close_guard.dart';
import 'package:roola/l10n/app_localizations.dart';

void main() {
  Future<void> pumpHarness(
    WidgetTester tester, {
    required ValueChanged<bool?> onResult,
    required int sessionCount,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ja'),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await showSessionCloseConfirmation(
                  context,
                  sessionCount,
                );
                onResult(result);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows dialog with session count and resolves true on confirm', (
    tester,
  ) async {
    bool? captured;
    await pumpHarness(tester, sessionCount: 3, onResult: (r) => captured = r);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('終了の確認'), findsOneWidget);
    expect(find.textContaining('3 件のセッション'), findsOneWidget);

    await tester.tap(find.text('終了する'));
    await tester.pumpAndSettle();
    expect(captured, isTrue);
  });

  testWidgets('cancel resolves with false', (tester) async {
    bool? captured;
    await pumpHarness(tester, sessionCount: 1, onResult: (r) => captured = r);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    expect(captured, isFalse);
  });
}
