import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';

/// 計器ディスプレイパネル（Polaris / ADR-0038 D3・D6）。
///
/// 筐体（`bg`）から僅かにインセットし、R=2px・1px ボーダーの矩形として
/// `well` トーンで嵌め込む「ベゼルに嵌った画面」のラッパ。ファイル一覧など
/// 「沈んだ計器ディスプレイ」として見せたい領域を包む。影は使わない。
class PolarisDisplayPanel extends StatelessWidget {
  const PolarisDisplayPanel({super.key, required this.child, this.inset = 8});

  /// パネルの中身。
  final Widget child;

  /// 筐体からのインセット（px）。4px グリッドに乗せる。
  final double inset;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Padding(
      padding: EdgeInsets.all(inset),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: tokens.well,
          borderRadius: BorderRadius.circular(tokens.radius),
          border: Border.all(color: tokens.line),
        ),
        child: child,
      ),
    );
  }
}
