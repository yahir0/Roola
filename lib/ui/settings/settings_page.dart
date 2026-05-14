import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/settings/appearance_section.dart';

/// 設定画面。アプリ全体の preference のみを扱う（外観 / `claude` ヘルス /
/// キーボードショートカット解説）。
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
        children: const [
          _ClaudeHealthBanner(),
          AppearanceSection(),
          Divider(height: 32),
          _ShortcutsSection(),
        ],
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

/// エクスプローラのキーボードショートカット / 操作モデルの解説。
///
/// ADR-0021 で操作モデルがダブルクリック式に変わったので、ユーザーが
/// 「クリックしても何も起きない」と迷わないように、明示的に書いておく。
class _ShortcutsSection extends StatelessWidget {
  const _ShortcutsSection();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'キーボードショートカット',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'エクスプローラの操作モデルと、選択中アイテムに対するショートカット。',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const _ShortcutRow(
            keys: ['Click'],
            description: 'ファイル / フォルダを選択（ハイライト表示）',
          ),
          const _ShortcutRow(
            keys: ['Double Click'],
            description: 'フォルダに遷移 / ファイルを既定のアプリで開く',
          ),
          const _ShortcutRow(
            keys: ['C', 'C'],
            description: '選択中アイテムのパスをクリップボードへコピー（500ms 以内に 2 連打）',
          ),
          const _ShortcutRow(
            keys: ['Right Click'],
            description: 'コンテキストメニュー（フォルダ / ファイル別の操作一覧）',
          ),
          const _ShortcutRow(
            keys: ['Mouse Back / Forward'],
            description: 'ディレクトリ履歴を 1 つ戻る / 進む（AppBar の ← → と同等）',
          ),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.keys, required this.description});

  final List<String> keys;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [for (final k in keys) _KeyChip(label: k)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(description),
            ),
          ),
        ],
      ),
    );
  }
}

/// キー名を「キーキャップ風」に表示するチップ。フラット UI に合わせて
/// 角丸 2px・薄い 1px ボーダーのみ。
class _KeyChip extends StatelessWidget {
  const _KeyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          color: colors.onSurface,
        ),
      ),
    );
  }
}
