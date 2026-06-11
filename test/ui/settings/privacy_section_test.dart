import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/privacy/privacy_settings.dart';
import 'package:roola/data/privacy/privacy_settings_repository.dart';
import 'package:roola/data/privacy/privacy_settings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/settings/privacy_section.dart';

/// 実ファイル IO は widget test の fake async で完結しないため、in-memory の
/// Fake で差し替える（実 IO 込みの挙動は repository のユニットテストで担保）。
class _FakePrivacySettingsRepository implements PrivacySettingsRepository {
  _FakePrivacySettingsRepository(this.settings);

  PrivacySettings settings;

  @override
  Future<PrivacySettings> load() async => settings;

  @override
  Future<void> save(PrivacySettings value) async {
    settings = value;
  }
}

void main() {
  late _FakePrivacySettingsRepository repository;

  setUp(() {
    // 同意済み・アナリティクス ON の状態から始める。
    repository = _FakePrivacySettingsRepository(
      const PrivacySettings(acceptedTermsVersion: 2),
    );
  });

  Future<void> pumpSection(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          privacySettingsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ja'),
          home: Scaffold(body: SingleChildScrollView(child: PrivacySection())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('トグルと規約表示の導線が表示される', (tester) async {
    await pumpSection(tester);
    expect(find.text('オン'), findsOneWidget);
    expect(find.text('オフ'), findsOneWidget);
    expect(find.text('利用規約を表示'), findsOneWidget);
  });

  testWidgets('OFF にすると永続化され、以後の送信が止まる状態になる', (tester) async {
    await pumpSection(tester);
    await tester.tap(find.text('オフ'));
    await tester.pumpAndSettle();

    // `analyticsEnabled: false` の間は AnalyticsService の isAllowed 判定が
    // false になり一切送信されない（analytics_service_test の「未許可なら
    // 送信しない」でカバー）。
    expect(repository.settings.analyticsEnabled, isFalse);
    expect(repository.settings.acceptedTermsVersion, 2);
  });
}
