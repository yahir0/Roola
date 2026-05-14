import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/settings/appearance_section.dart';

/// 設定画面。アプリ全体の preference のみを扱う（外観 / `claude` ヘルス）。
///
/// 登録済みランチャーエントリの一覧と管理 UI は `LauncherManagementPage` に
/// 移してある（コンテンツ管理 ≠ 設定）。サイドバーのランチャーセクション末尾の
/// 「管理…」から開く。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const MacosWindowAppBar(title: Text('設定')),
      body: ListView(
        children: const [_ClaudeHealthBanner(), AppearanceSection()],
      ),
    );
  }
}

class _ClaudeHealthBanner extends ConsumerWidget {
  const _ClaudeHealthBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(claudeHealthProvider);
    return health.when(
      data: (h) => h.available
          ? const SizedBox.shrink()
          : MaterialBanner(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              leading: const Icon(Icons.warning_amber),
              content: Text(
                '`claude` コマンドが見つかりません。インストールと PATH を確認してください。\n'
                '詳細: ${h.versionOutput}',
              ),
              actions: const [SizedBox.shrink()],
            ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => MaterialBanner(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        leading: const Icon(Icons.warning_amber),
        content: Text('ヘルスチェックに失敗: $e'),
        actions: const [SizedBox.shrink()],
      ),
    );
  }
}
