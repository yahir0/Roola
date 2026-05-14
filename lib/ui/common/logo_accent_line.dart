import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';

/// ロゴアクセント色のグラデーションライン（左右フェード）。AppBar の
/// 下端に置いて、ヘッダと本体コンテンツの区切りを 1px で示す。背景透過を
/// 損なわずにアクセントだけ残す目的。
///
/// `LogoTheme` 拡張が刺さっていない（テスト等の素の `ThemeData`）場合は
/// `colorScheme.primary` にフォールバックする。
class LogoAccentLine extends StatelessWidget implements PreferredSizeWidget {
  const LogoAccentLine({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(1);

  @override
  Widget build(BuildContext context) {
    final logoTheme = Theme.of(context).extension<LogoTheme>();
    final color = logoTheme?.accentBlue ?? Theme.of(context).colorScheme.primary;
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: 0.6),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
