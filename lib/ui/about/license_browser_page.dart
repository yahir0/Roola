import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_modal_shell.dart';

/// 本アプリで利用している OSS のライセンス一覧画面（ADR-0040）。
///
/// Flutter 標準の [showLicensePage] / [LicensePage] は独自に `Scaffold` +
/// `AppBar` を組むため、`TitleBarStyle.hidden` + 信号灯ぶんの leading 余白を
/// 必要とする Roola のウィンドウと衝突し、back ボタンが macOS の信号灯と
/// 重なる。これを避けるため、`LicenseRegistry` の内容を自前でグルーピングし、
/// 設定 / ランチャー管理と同じ [PolarisModalShell] のモーダルとして出す
/// （ADR-0054 / ADR-0056）。
///
/// 一覧 → 詳細はモーダル 1 枚の中で内部 state（[useState]）で切替える。詳細
/// 表示中はシェルの戻る山括弧 + Esc で一覧へ戻り、✕ / スクリムでモーダル
/// 全体を閉じる。これにより `MacosWindowAppBar` の戻るボタンを使わずに済む。
class LicenseBrowserPage extends HookWidget {
  const LicenseBrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = useFuture(useMemoized(_loadPackages, const []));
    final selected = useState<_PackageLicenses?>(null);

    final package = selected.value;
    return PolarisModalShell(
      title: package?.name ?? l10n.licensesPageTitle,
      onBack: package == null ? null : () => selected.value = null,
      child: package != null
          ? _PackageDetail(entries: package.entries)
          : switch (snapshot.connectionState) {
              ConnectionState.done when snapshot.hasData => _PackageList(
                packages: snapshot.data!,
                onSelect: (pkg) => selected.value = pkg,
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
  const _PackageList({required this.packages, required this.onSelect});

  final List<_PackageLicenses> packages;
  final ValueChanged<_PackageLicenses> onSelect;

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
          onTap: () => onSelect(pkg),
        );
      },
    );
  }
}

/// 1 パッケージのライセンス詳細（ADR-0040）。該当 [LicenseEntry] の
/// `paragraphs` を順に描画する。`indent` の値は `LicenseParagraph.centeredIndent`
/// で中央寄せ、それ以外は左 indent を EM 倍で適用する（Flutter 標準
/// `LicensePage` の挙動に合わせる）。
class _PackageDetail extends StatelessWidget {
  const _PackageDetail({required this.entries});

  final List<LicenseEntry> entries;

  /// `LicenseParagraph.indent` に対する EM 換算の左パディング。
  /// Flutter 標準と同じ「1 indent = 1 EM」。
  static const double _indentEm = 12;

  @override
  Widget build(BuildContext context) {
    final paragraphs = <LicenseParagraph>[];
    for (final entry in entries) {
      paragraphs.addAll(entry.paragraphs);
      // entry 同士の区切り（同じパッケージに複数 entry がある場合）。
      paragraphs.add(const LicenseParagraph('', 0));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: PolarisTokens.space6,
        vertical: PolarisTokens.space4,
      ),
      itemCount: paragraphs.length,
      itemBuilder: (context, index) =>
          _Paragraph(paragraph: paragraphs[index], indentEm: _indentEm),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.paragraph, required this.indentEm});

  final LicenseParagraph paragraph;
  final double indentEm;

  @override
  Widget build(BuildContext context) {
    final text = paragraph.text;
    if (text.isEmpty) {
      return const SizedBox(height: PolarisTokens.space2);
    }
    final isCentered = paragraph.indent == LicenseParagraph.centeredIndent;
    return Padding(
      padding: EdgeInsets.only(
        left: isCentered ? 0 : paragraph.indent * indentEm,
        bottom: PolarisTokens.space2,
      ),
      child: SelectableText(
        text,
        textAlign: isCentered ? TextAlign.center : TextAlign.start,
        style: Theme.of(context).textTheme.bodySmall,
      ),
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
