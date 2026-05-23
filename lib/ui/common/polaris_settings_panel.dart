import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';

/// 設定画面の 1 セクション（Polaris / ADR-0038）。
///
/// 箱で囲わず、筐体（`bg`）の上に全大文字トラッキングのラックラベルと内容を
/// 余白だけで積む（フラット）。セクション間の区切りは呼び出し側
/// （[PolarisSectionDivider]）の極薄ラインに任せ、面の塗りや枠は持たない。
class PolarisSettingsSection extends StatelessWidget {
  const PolarisSettingsSection({
    super.key,
    required this.label,
    this.description,
    required this.children,
  });

  /// セクション見出し（ラックラベル）。内部で全大文字化する。
  final String label;

  /// 見出し直下に置く補足説明。無ければ省略。
  final String? description;

  /// セクションに縦積みする内容。
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PolarisFieldLabel(label),
          if (description != null) ...[
            const SizedBox(height: PolarisTokens.space2),
            Text(
              description!,
              style: tokens.meta.copyWith(color: tokens.textDim),
            ),
          ],
          const SizedBox(height: PolarisTokens.space3),
          ...children,
        ],
      ),
    );
  }
}

/// セクション間の極薄ライン区切り（Polaris / ADR-0038）。
///
/// 面や枠でなく 1px のヘアライン 1 本だけで区切り、上下にたっぷり余白を取って
/// リズムをオープンにする。フラット指向の静かな区切り。
class PolarisSectionDivider extends StatelessWidget {
  const PolarisSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PolarisTokens.space6,
        vertical: PolarisTokens.space3,
      ),
      child: SizedBox(height: 1, child: ColoredBox(color: tokens.line)),
    );
  }
}

/// フィールド／サブ見出しの全大文字トラッキングラベル（ADR-0038 D9）。
/// セクション見出しにもパネル内のサブ見出しにも使い、見出しの語彙を統一する。
class PolarisFieldLabel extends StatelessWidget {
  const PolarisFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Text(
      text.toUpperCase(),
      style: tokens.label.copyWith(color: tokens.textFaint),
    );
  }
}
