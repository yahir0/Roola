import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:roola/data/analytics/analytics_service.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(Options());
  });

  late _MockDio dio;

  setUp(() {
    dio = _MockDio();
    PackageInfo.setMockInitialValues(
      appName: 'Roola',
      packageName: 'tech.yahiro.Roola',
      version: '0.0.43',
      buildNumber: '43',
      buildSignature: '',
    );
  });

  AnalyticsService buildService({
    String appKey = 'A-US-0000000000',
    bool Function()? isAllowed,
  }) {
    return AnalyticsService(
      appKey: appKey,
      isAllowed: isAllowed ?? () => true,
      dio: dio,
    );
  }

  void stubPost() {
    when(
      () => dio.postUri<void>(
        any(),
        data: any<Object?>(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<void>(requestOptions: RequestOptions()),
    );
  }

  test('App Key が空なら送信しない（開発 / fork ビルド）', () async {
    final service = buildService(appKey: '');
    await service.trackEvent('app_launched');
    verifyZeroInteractions(dio);
  });

  test('App Key の形式が不正なら送信しない', () async {
    final service = buildService(appKey: 'not-a-valid-key-shape-x');
    await service.trackEvent('app_launched');
    verifyZeroInteractions(dio);
  });

  test('未許可（同意前・オプトアウト中）なら送信しない', () async {
    final service = buildService(isAllowed: () => false);
    await service.trackEvent('app_launched');
    verifyZeroInteractions(dio);
  });

  test('許可済みなら US リージョンへイベント 1 件の配列を送信する', () async {
    stubPost();
    final service = buildService();
    await service.trackEvent('launcher_executed', {'kind': 'openHere'});

    final captured = verify(
      () => dio.postUri<void>(
        captureAny(),
        data: captureAny<Object?>(named: 'data'),
        options: any(named: 'options'),
      ),
    ).captured;

    final uri = captured[0] as Uri;
    expect(uri.toString(), 'https://us.aptabase.com/api/v0/events');

    final data = captured[1] as List<Object?>;
    expect(data, hasLength(1));
    final event = data.single! as Map<String, Object?>;
    expect(event['eventName'], 'launcher_executed');
    expect(event['props'], {'kind': 'openHere'});
    expect(event['sessionId'], isNotEmpty);
    final systemProps = event['systemProps']! as Map<String, Object?>;
    expect(systemProps['appVersion'], '0.0.43');
    expect(systemProps['appBuildNumber'], '43');
  });

  test('送信失敗は握り潰す（ベストエフォート）', () async {
    when(
      () => dio.postUri<void>(
        any(),
        data: any<Object?>(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenThrow(DioException(requestOptions: RequestOptions()));
    final service = buildService();
    await expectLater(service.trackEvent('app_launched'), completes);
  });

  test('trackAppLaunchedOnce は 1 起動 1 回だけ送信する', () async {
    stubPost();
    final service = buildService();
    await service.trackAppLaunchedOnce();
    await service.trackAppLaunchedOnce();
    verify(
      () => dio.postUri<void>(
        any(),
        data: any<Object?>(named: 'data'),
        options: any(named: 'options'),
      ),
    ).called(1);
  });

  test('trackAppLaunchedOnce は未許可の間は送信済みにしない（同意後に送信される）',
      () async {
    stubPost();
    var allowed = false;
    final service = buildService(isAllowed: () => allowed);

    // 同意モーダル表示中（未許可）の呼び出し。
    await service.trackAppLaunchedOnce();
    verifyZeroInteractions(dio);

    // 「同意して開始」後の呼び出しで改めて送信される。
    allowed = true;
    await service.trackAppLaunchedOnce();
    verify(
      () => dio.postUri<void>(
        any(),
        data: any<Object?>(named: 'data'),
        options: any(named: 'options'),
      ),
    ).called(1);
  });
}
