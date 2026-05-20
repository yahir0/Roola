import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// ネイティブ依存（pub 経由でない OSS）のライセンスを [LicenseRegistry] に
/// 流し込むブートストラップ（ADR-0040）。
///
/// `LicenseRegistry` は pub パッケージのライセンスを自動収集するが、
/// CocoaPods 経由の Sparkle や Swift Package Manager 経由の SwiftTerm は
/// その経路に乗らない。本アプリは macOS にネイティブリンクしている以上
/// 配布物の MIT 表記義務はこれらにも掛かるため、`assets/licenses/` に
/// ライセンス全文をバンドルし、起動時にここで明示登録する。
///
/// 既存の Flutter / Dart / pub パッケージのライセンスはここでは触らず、
/// Flutter の自動収集に任せる。
Future<void> registerNativeLicenses() async {
  LicenseRegistry.addLicense(() async* {
    yield await _loadLicense(
      packageName: 'Sparkle',
      assetPath: 'assets/licenses/sparkle.txt',
    );
    yield await _loadLicense(
      packageName: 'SwiftTerm',
      assetPath: 'assets/licenses/swiftterm.txt',
    );
  });
}

Future<LicenseEntry> _loadLicense({
  required String packageName,
  required String assetPath,
}) async {
  final text = await rootBundle.loadString(assetPath);
  return LicenseEntryWithLineBreaks([packageName], text);
}
