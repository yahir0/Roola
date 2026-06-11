import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/terms_consent_gate.dart';
import 'package:roola/data/privacy/privacy_settings.dart';
import 'package:roola/data/privacy/privacy_settings_repository.dart';
import 'package:roola/data/privacy/privacy_settings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/consent/terms_text_view.dart';

/// 実ファイル IO は widget test の fake async で完結しないため、in-memory の
/// Fake で差し替える（実 IO 込みの挙動は repository のユニットテストで担保）。
class _FakePrivacySettingsRepository implements PrivacySettingsRepository {
  _FakePrivacySettingsRepository([PrivacySettings? initial])
      : settings = initial ?? PrivacySettings.defaults();

  PrivacySettings settings;

  @override
  Future<PrivacySettings> load() async => settings;

  @override
  Future<void> save(PrivacySettings value) async {
    settings = value;
  }
}

void main() {
  Future<void> pumpGate(
    WidgetTester tester,
    _FakePrivacySettingsRepository repository,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          privacySettingsRepositoryProvider.overrideWithValue(repository),
          // 規約アセットの実ファイル IO は widget test で解決タイミングが
          // 不安定（pumpAndSettle がスピナーで timeout する）ため固定する。
          termsTextProvider.overrideWith((ref) async => 'Roola 利用規約（テスト）'),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ja'),
          home: TermsConsentGate(child: Text('MAIN')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('未同意なら同意モーダルが表示される', (tester) async {
    await pumpGate(tester, _FakePrivacySettingsRepository());
    expect(find.text('同意して開始'), findsOneWidget);
    expect(find.text('終了'), findsOneWidget);
  });

  testWidgets('同意で現行バージョンが保存され、モーダルが消える', (tester) async {
    final repository = _FakePrivacySettingsRepository();
    await pumpGate(tester, repository);
    await tester.tap(find.text('同意して開始'));
    await tester.pumpAndSettle();

    expect(find.text('同意して開始'), findsNothing);
    expect(repository.settings.acceptedTermsVersion, 2);
    expect(repository.settings.analyticsEnabled, isTrue);
  });

  testWidgets('トグル OFF で同意するとアナリティクス無効で保存される', (tester) async {
    final repository = _FakePrivacySettingsRepository();
    await pumpGate(tester, repository);
    await tester.tap(find.text('オフ'));
    await tester.pump();
    await tester.tap(find.text('同意して開始'));
    await tester.pumpAndSettle();

    expect(repository.settings.acceptedTermsVersion, 2);
    expect(repository.settings.analyticsEnabled, isFalse);
  });

  testWidgets('旧バージョンに同意済みなら再同意モーダルが表示される', (tester) async {
    final repository = _FakePrivacySettingsRepository(
      const PrivacySettings(acceptedTermsVersion: 1),
    );
    await pumpGate(tester, repository);
    expect(find.text('同意して開始'), findsOneWidget);
  });

  testWidgets('現行バージョンに同意済みならモーダルは表示されない', (tester) async {
    final repository = _FakePrivacySettingsRepository(
      const PrivacySettings(acceptedTermsVersion: 2),
    );
    await pumpGate(tester, repository);
    expect(find.text('同意して開始'), findsNothing);
    expect(find.text('MAIN'), findsOneWidget);
  });
}
