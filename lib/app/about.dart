import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:roola/l10n/app_localizations.dart';

/// About ダイアログを開く（ADR-0040）。
///
/// アプリ名・バージョン・著作権表記を表示する Flutter 標準の [AboutDialog]
/// を使う。「ライセンスを表示」ボタンから [showLicensePage] に遷移し、
/// pub の OSS パッケージ群と、起動時に明示登録したネイティブ依存
/// （Sparkle / SwiftTerm）のライセンスをまとめて閲覧できる。
///
/// macOS のメニュー「Roola → About Roola」と、設定画面の About セクションの
/// 双方から呼ぶ単一の経路にする。
Future<void> showRoolaAboutDialog(BuildContext context) async {
  final info = await PackageInfo.fromPlatform();
  // PackageInfo の取得待ちの間にウィジェットツリーが破棄される可能性がある
  // ため、`mounted` を確認してから dialog を出す。
  if (!context.mounted) {
    return;
  }
  final l10n = AppLocalizations.of(context);
  showAboutDialog(
    context: context,
    applicationName: 'Roola',
    // 例: "0.0.14 (14)"。CFBundleShortVersionString と CFBundleVersion を
    // 並べて、リリース版と内部ビルド番号の両方を確認できるようにする。
    applicationVersion: '${info.version} (${info.buildNumber})',
    applicationLegalese: l10n.aboutLegalese,
    applicationIcon: const _AboutIcon(),
  );
}

/// About ダイアログ左上に表示するアプリアイコン。
/// `pubspec.yaml` の assets に置かず、Flutter の `Image.asset` でも参照
/// しないのは、現状アイコン PNG が `docs/images/icon.png` にしか無く、
/// アプリバンドルにバンドルされていないため。アイコン自体は macOS 側の
/// .icns で表示される（メニュー / Dock）ので、ダイアログでは Material の
/// アイコンを 1 枚置く程度に留める。後でバンドル化したら差し替える。
class _AboutIcon extends StatelessWidget {
  const _AboutIcon();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Icon(Icons.terminal, size: 48, color: colors.primary);
  }
}
