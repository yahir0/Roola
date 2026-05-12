import 'package:claude_skills_launcher/app/theme.dart';
import 'package:claude_skills_launcher/ui/shell/app_shell_scope.dart';
import 'package:flutter/material.dart';

/// Home / Explorer タブを切り替えるバー。
///
/// `AppShellScope.maybeOf(context)` でシェルを取得し、SegmentedButton で
/// 操作する。シェル外の route（Run / Settings 等）から表示することは
/// 想定していないため、見つからなければ高さ 0 を返す。背景は完全透過にし、
/// 区切りはロゴアクセント色のグラデーションライン 1px で表現する。
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({super.key});

  static const _segmentRowHeight = 42.0;
  static const _accentLineHeight = 1.0;

  @override
  Size get preferredSize =>
      const Size.fromHeight(_segmentRowHeight + _accentLineHeight);

  @override
  Widget build(BuildContext context) {
    final shell = AppShellScope.maybeOf(context);
    if (shell == null) {
      return const SizedBox(height: _segmentRowHeight + _accentLineHeight);
    }
    final logo = Theme.of(context).extension<LogoTheme>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: _segmentRowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          alignment: Alignment.centerLeft,
          child: SegmentedButton<int>(
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
          ),
        ),
        _LogoAccentLine(color: logo.accentBlue),
      ],
    );
  }
}

/// ロゴアクセント色のグラデーションライン（左右フェード）。背景透過を
/// 損なわずにタブとコンテンツの区切りを示す。
class _LogoAccentLine extends StatelessWidget {
  const _LogoAccentLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
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
