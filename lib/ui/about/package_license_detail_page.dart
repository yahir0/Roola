import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';

/// 1 パッケージのライセンス詳細画面（ADR-0040）。
///
/// 該当 [LicenseEntry] の `paragraphs` を順に描画する。`indent` の値は
/// `LicenseParagraph.centeredIndent` で中央寄せ、それ以外は左 indent を
/// EM 倍で適用する（Flutter 標準 `LicensePage` の挙動に合わせる）。
class PackageLicenseDetailPage extends StatelessWidget {
  const PackageLicenseDetailPage({
    required this.packageName,
    required this.entries,
    super.key,
  });

  final String packageName;
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
    return Scaffold(
      appBar: MacosWindowAppBar(title: Text(packageName)),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: PolarisTokens.space6,
          vertical: PolarisTokens.space4,
        ),
        itemCount: paragraphs.length,
        itemBuilder: (context, index) {
          final paragraph = paragraphs[index];
          return _Paragraph(paragraph: paragraph);
        },
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.paragraph});

  final LicenseParagraph paragraph;

  @override
  Widget build(BuildContext context) {
    final text = paragraph.text;
    if (text.isEmpty) {
      return const SizedBox(height: PolarisTokens.space2);
    }
    final isCentered = paragraph.indent == LicenseParagraph.centeredIndent;
    return Padding(
      padding: EdgeInsets.only(
        left: isCentered
            ? 0
            : paragraph.indent * PackageLicenseDetailPage._indentEm,
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
