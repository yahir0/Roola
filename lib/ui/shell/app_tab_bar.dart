import 'package:claude_skills_launcher/app/theme.dart';
import 'package:claude_skills_launcher/ui/shell/app_shell_scope.dart';
import 'package:flutter/material.dart';

/// Home / Explorer をシェルレベルで切り替える SegmentedButton。
///
/// 旧 `AppTabBar` は独立した行として AppBar の下に配置していたが、
/// タブの文字 / 行が縦方向に冗長だったため AppBar のタイトル枠に
/// 直接埋め込む形に変更した。シェル外の route（Run / Settings 等）から
/// 表示することは想定していないため、`AppShellScope` が見つからなければ
/// 何も描画しない。
class AppTabSegments extends StatelessWidget {
  const AppTabSegments({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = AppShellScope.maybeOf(context);
    if (shell == null) {
      return const SizedBox.shrink();
    }
    return SegmentedButton<int>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: 0,
          icon: Icon(Icons.home_outlined),
          label: Text('ホーム'),
        ),
        ButtonSegment(
          value: 1,
          icon: Icon(Icons.folder_outlined),
          label: Text('エクスプローラ'),
        ),
      ],
      selected: {shell.currentIndex},
      onSelectionChanged: (selection) {
        final index = selection.first;
        shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        );
      },
    );
  }
}

/// ロゴアクセント色のグラデーションライン（左右フェード）。AppBar の
/// 下端に置いて、タブと本体コンテンツの区切りを 1px で示す。背景透過を
/// 損なわずにアクセントだけ残す目的。
class LogoAccentLine extends StatelessWidget implements PreferredSizeWidget {
  const LogoAccentLine({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(1);

  @override
  Widget build(BuildContext context) {
    // 通常は AppTheme から LogoTheme 拡張が刺さっているが、テスト等で
    // 拡張無しの ThemeData が使われている場合の保険として
    // `colorScheme.primary` にフォールバックする。
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
