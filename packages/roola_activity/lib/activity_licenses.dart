import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 計器書体（Barlow Condensed / Chakra Petch・SIL OFL 1.1）のライセンスを
/// [LicenseRegistry] に登録する（ADR-0040 / ADR-0069）。
///
/// 書体は pub パッケージではないため Flutter の自動収集に乗らない。このパッケージを
/// 使うアプリは起動時に 1 回呼ぶ。
void registerActivityLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield await _load(
      packageName: 'Barlow Condensed (font)',
      fileName: 'BarlowCondensed-OFL.txt',
    );
    yield await _load(
      packageName: 'Chakra Petch (font)',
      fileName: 'ChakraPetch-OFL.txt',
    );
  });
}

Future<LicenseEntry> _load({
  required String packageName,
  required String fileName,
}) async {
  final text = await rootBundle.loadString(
    'packages/roola_activity/assets/licenses/$fileName',
  );
  return LicenseEntryWithLineBreaks([packageName], text);
}
