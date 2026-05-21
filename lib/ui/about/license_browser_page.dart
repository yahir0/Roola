import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/about/package_license_detail_page.dart';
import 'package:roola/ui/common/instant_material_route.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';

/// 本アプリで利用している OSS のライセンス一覧画面（ADR-0040）。
///
/// Flutter 標準の [showLicensePage] / [LicensePage] は独自に `Scaffold` +
/// `AppBar` を組むため、`TitleBarStyle.hidden` + 信号灯ぶんの leading 余白を
/// 必要とする Roola のウィンドウ（[MacosWindowAppBar] 参照）と衝突し、back
/// ボタンが macOS の信号灯と重なる。これを避けるため、`LicenseRegistry` の
/// 内容を自前でグルーピングして、Roola の `MacosWindowAppBar` を使った
/// 2 画面（一覧 / 詳細）として描画する。
class LicenseBrowserPage extends HookWidget {
  const LicenseBrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = useFuture(useMemoized(_loadPackages, const []));
    return Scaffold(
      appBar: MacosWindowAppBar(title: Text(l10n.licensesPageTitle)),
      body: switch (snapshot.connectionState) {
        ConnectionState.done when snapshot.hasData => _PackageList(
          packages: snapshot.data!,
        ),
        ConnectionState.done => Center(
          child: Text(l10n.licensesLoadError('${snapshot.error}')),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// `LicenseRegistry.licenses` を全件畳んで、パッケージ名でグルーピングする。
/// 1 つの `LicenseEntry` が複数パッケージに属することもあるため、`packages`
/// を flat に展開する。1 つのパッケージに複数 entry が紐づく場合もまとめる。
Future<List<_PackageLicenses>> _loadPackages() async {
  final byPackage = <String, List<LicenseEntry>>{};
  await for (final entry in LicenseRegistry.licenses) {
    for (final pkg in entry.packages) {
      byPackage.putIfAbsent(pkg, () => <LicenseEntry>[]).add(entry);
    }
  }
  final packages =
      byPackage.entries
          .map((e) => _PackageLicenses(name: e.key, entries: e.value))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return packages;
}

class _PackageList extends StatelessWidget {
  const _PackageList({required this.packages});

  final List<_PackageLicenses> packages;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView.separated(
      itemCount: packages.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final pkg = packages[index];
        return ListTile(
          title: Text(pkg.name),
          subtitle: Text(l10n.licensesEntryCount(pkg.entries.length)),
          trailing: const Icon(
            Icons.chevron_right,
            size: PolarisIconSize.standard,
          ),
          onTap: () {
            Navigator.of(context).push(
              InstantMaterialRoute<void>(
                builder: (_) => PackageLicenseDetailPage(
                  packageName: pkg.name,
                  entries: pkg.entries,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 1 つのパッケージに対するライセンス情報の束。
@immutable
class _PackageLicenses {
  const _PackageLicenses({required this.name, required this.entries});

  final String name;
  final List<LicenseEntry> entries;
}
