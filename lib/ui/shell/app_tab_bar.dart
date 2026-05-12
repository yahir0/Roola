import 'package:claude_skills_launcher/ui/shell/app_shell_scope.dart';
import 'package:flutter/material.dart';

/// Home / Explorer タブを切り替えるバー。
///
/// `AppShellScope.maybeOf(context)` でシェルを取得し、SegmentedButton で
/// 操作する。シェル外の route（Run / Settings 等）から表示することは
/// 想定していないため、見つからなければ高さ 0 を返す。
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({super.key});

  static const _height = 42.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final shell = AppShellScope.maybeOf(context);
    if (shell == null) {
      return const SizedBox(height: _height);
    }
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
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
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
      ),
    );
  }
}
