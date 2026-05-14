import 'package:flutter/material.dart';

/// AppBar 下端に置く 1px の区切り線。
///
/// サイドバーの右端ボーダーと同じ `Theme.of(context).dividerColor` を使い、
/// AppBar と本体コンテンツの境界が縦線と統一されたトーンで描かれる
/// （ADR-0020 のフラット路線）。
///
/// 旧 `LogoAccentLine` を置換。ブランドアクセント色のグラデーション線は
/// 「柔らかさを残さない」UI 方針と合わなくなったため、汎用の divider に
/// 揃えた。
class AppBarDivider extends StatelessWidget implements PreferredSizeWidget {
  const AppBarDivider({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(1);

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Theme.of(context).dividerColor);
  }
}
