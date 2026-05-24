import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:roola/app/router.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/l10n/app_localizations.dart';

/// About ダイアログを開く（ADR-0040）。
///
/// アプリ名・バージョン・著作権を表示する自前のダイアログ。Flutter 標準の
/// [showAboutDialog] / [AboutDialog] を使わない理由は、内蔵されている
/// 「ライセンスを表示」ボタンが [showLicensePage] を経由し、Material 標準
/// の [LicensePage] を開いてしまうため。`LicensePage` の back ボタンは
/// macOS の信号灯と重なる位置に描かれ、Roola の `TitleBarStyle.hidden` の
/// 前提と合わない。
///
/// 代わりに、ダイアログの「ライセンスを表示」ボタンから自前のライセンス
/// 一覧（[LicensesRoute] → `LicenseBrowserPage`）を、設定 / ランチャー管理と
/// 同じモーダルとして開く（ADR-0056）。これにより信号灯衝突を避けつつ、
/// Polaris の見た目とも揃う。
Future<void> showRoolaAboutDialog(BuildContext context) async {
  final info = await PackageInfo.fromPlatform();
  if (!context.mounted) {
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (context) => _AboutDialog(packageInfo: info),
  );
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog({required this.packageInfo});

  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final version = '${packageInfo.version} (${packageInfo.buildNumber})';
    return AlertDialog(
      icon: Image.asset(
        'assets/branding/roola_icon.png',
        width: 64,
        height: 64,
      ),
      title: const Text('Roola'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(version, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: PolarisTokens.space3),
          Text(
            l10n.aboutLegalese,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // ダイアログを閉じてから、root Navigator 上にライセンスモーダルを
            // 重ねる。pop 直後の defunct な context を避けるため、go_router の
            // push には root Navigator の context を使う（`app_menu_bar` と同様）。
            Navigator.of(context).pop();
            final rootContext = rootNavigatorKey.currentContext;
            if (rootContext != null) {
              const LicensesRoute().push<void>(rootContext);
            }
          },
          child: Text(l10n.aboutViewLicensesButton),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonClose),
        ),
      ],
    );
  }
}
