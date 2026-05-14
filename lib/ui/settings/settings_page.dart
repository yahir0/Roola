import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/settings/appearance_section.dart';

/// 設定画面。アプリ全体の preference のみを扱う（外観 / `claude` 連携 /
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
          AppearanceSection(),
          Divider(height: 32),
          _ClaudeIntegrationSection(),
          Divider(height: 32),
          _ShortcutsSection(),
        ],
      ),
    );
  }
}

/// Claude Code 連携セクション。CLI の検出状態と、有効化される機能の一覧を
/// 常時表示する（ADR-0022）。未導入時はインストール手順を案内、導入済み時は
/// 検出済み旨と version を表示。
class _ClaudeIntegrationSection extends ConsumerWidget {
  const _ClaudeIntegrationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(claudeHealthProvider);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Claude Code 連携',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anthropic の Claude Code CLI が PATH 上で見つかると、'
            '関連機能が自動で有効化されます。',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          health.when(
            loading: () => const _StatusCard(
              icon: Icons.hourglass_top,
              tone: _StatusTone.neutral,
              title: '検出中…',
              detail: '`claude --version` の実行を待っています。',
            ),
            error: (e, _) => _StatusCard(
              icon: Icons.error_outline,
              tone: _StatusTone.error,
              title: 'ヘルスチェックに失敗',
              detail: '$e',
            ),
            data: (h) => h.available
                ? _StatusCard(
                    icon: Icons.check_circle_outline,
                    tone: _StatusTone.ok,
                    title: '検出済み',
                    detail: h.versionOutput.isEmpty
                        ? '`claude` コマンドが利用可能です。'
                        : 'Version: ${h.versionOutput}',
                  )
                : _StatusCard(
                    icon: Icons.error_outline,
                    tone: _StatusTone.error,
                    title: '未検出',
                    detail: h.versionOutput.isEmpty
                        ? '`claude` コマンドが PATH 上で見つかりませんでした。'
                        : '詳細: ${h.versionOutput}',
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            '有効化される機能',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const _FeatureRow(
            description:
                'エクスプローラのフォルダで `.claude/skills/` を自動検知し、特別アイコンと Skill チップを表示',
          ),
          const _FeatureRow(
            description:
                '右クリックメニューに「Claude Code を開く」「Skill を即実行」「Skill をホームに登録」を追加',
          ),
          const _FeatureRow(
            description:
                'ランチャー登録時に「Claude Skill」動作タイプを選べる（Skill 名を指定して `claude /skillname` を起動）',
          ),
          if (health.value?.available != true) ...[
            const SizedBox(height: 16),
            const _InstallGuide(),
          ],
        ],
      ),
    );
  }
}

enum _StatusTone { ok, neutral, error }

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final _StatusTone tone;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final toneColor = switch (tone) {
      _StatusTone.ok => colors.primary,
      _StatusTone.neutral => colors.onSurfaceVariant,
      _StatusTone.error => colors.error,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: toneColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: toneColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.check, size: 14, color: colors.onSurfaceVariant),
          ),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}

/// Claude Code の標準的なインストール手順をコードブロックで案内する。
/// 公式は npm 経由。
class _InstallGuide extends StatelessWidget {
  const _InstallGuide();

  static const _command = 'npm install -g @anthropic-ai/claude-code';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'インストール手順',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Node.js 18+ がある状態で次のコマンドを実行してください:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              const Expanded(
                child: SelectableText(
                  _command,
                  style: TextStyle(fontFamily: 'SarasaTermJ'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy, size: 16),
                tooltip: 'コマンドをコピー',
                visualDensity: VisualDensity.compact,
                onPressed: () => _copy(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'インストール後、Roola を再起動すると検出されます。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _command));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('インストールコマンドをコピーしました'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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
