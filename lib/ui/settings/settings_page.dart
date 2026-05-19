import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/data/locale/app_locale.dart';
import 'package:roola/data/locale/locale_settings_repository_impl.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/settings/appearance_section.dart';

/// 設定画面。アプリ全体の preference のみを扱う（言語 / 外観 / `claude`
/// 連携 / キーボードショートカット解説）。
///
/// 登録済みランチャーエントリの一覧と管理 UI は `LauncherManagementPage` に
/// 移してある（コンテンツ管理 ≠ 設定）。サイドバーのランチャーセクション末尾の
/// 「管理…」から開く。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: MacosWindowAppBar(
        title: Text(AppLocalizations.of(context).settingsPageTitle),
      ),
      body: ListView(
        children: const [
          _LanguageSection(),
          Divider(height: 32),
          AppearanceSection(),
          Divider(height: 32),
          _ExplorerSection(),
          Divider(height: 32),
          _ClaudeIntegrationSection(),
          Divider(height: 32),
          _ShortcutsSection(),
        ],
      ),
    );
  }
}

/// 表示言語の切替セクション（ADR-0034）。日本語 / 英語の 2 択。
class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = ref.watch(appLocaleProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsLanguageTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsLanguageDescription,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          SegmentedButton<AppLocale>(
            segments: [
              ButtonSegment(
                value: AppLocale.ja,
                label: Text(l10n.languageJapanese),
              ),
              ButtonSegment(
                value: AppLocale.en,
                label: Text(l10n.languageEnglish),
              ),
            ],
            selected: {locale},
            onSelectionChanged: (set) {
              if (set.isNotEmpty) {
                ref.read(appLocaleProvider.notifier).setLocale(set.first);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// エクスプローラ表示設定セクション（ADR-0024）。
/// ファイル / フォルダタイルの縦幅を「サイドバーと同等の単行 (compact)」と
/// 「Skill subtitle を含む従来 3 行 (comfortable)」で切替える。
class _ExplorerSection extends ConsumerWidget {
  const _ExplorerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(explorerSettingsProvider);
    final colors = Theme.of(context).colorScheme;
    final density = state.value?.listDensity ?? ExplorerListDensity.comfortable;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsExplorerTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsExplorerDescription,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ExplorerListDensity>(
            segments: [
              ButtonSegment(
                value: ExplorerListDensity.compact,
                label: Text(l10n.explorerDensityCompact),
                icon: const Icon(Icons.density_small),
              ),
              ButtonSegment(
                value: ExplorerListDensity.comfortable,
                label: Text(l10n.explorerDensityComfortable),
                icon: const Icon(Icons.density_medium),
              ),
            ],
            selected: {density},
            onSelectionChanged: state.isLoading
                ? null
                : (set) {
                    if (set.isNotEmpty) {
                      ref
                          .read(explorerSettingsProvider.notifier)
                          .setListDensity(set.first);
                    }
                  },
          ),
          const SizedBox(height: 8),
          Text(
            density == ExplorerListDensity.compact
                ? l10n.explorerDensityCompactDescription
                : l10n.explorerDensityComfortableDescription,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
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
    final l10n = AppLocalizations.of(context);
    final health = ref.watch(claudeHealthProvider);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsClaudeIntegrationTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsClaudeIntegrationDescription,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          health.when(
            loading: () => _StatusCard(
              icon: Icons.hourglass_top,
              tone: _StatusTone.neutral,
              title: l10n.claudeHealthChecking,
              detail: l10n.claudeHealthCheckingDetail,
            ),
            error: (e, _) => _StatusCard(
              icon: Icons.error_outline,
              tone: _StatusTone.error,
              title: l10n.claudeHealthCheckError,
              detail: '$e',
            ),
            data: (h) => h.available
                ? _StatusCard(
                    icon: Icons.check_circle_outline,
                    tone: _StatusTone.ok,
                    title: l10n.claudeHealthCheckSuccess,
                    detail: h.versionOutput.isEmpty
                        ? l10n.claudeHealthCheckSuccessDetail
                        : l10n.claudeHealthVersion(h.versionOutput),
                  )
                : _StatusCard(
                    icon: Icons.error_outline,
                    tone: _StatusTone.error,
                    title: l10n.claudeHealthCheckNotFound,
                    detail: h.versionOutput.isEmpty
                        ? l10n.claudeHealthCheckNotFoundDetail
                        : l10n.claudeHealthCheckNotFoundDetailWith(
                            h.versionOutput,
                          ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.settingsClaudeFeatures,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _FeatureRow(description: l10n.settingsClaudeFeature1),
          _FeatureRow(description: l10n.settingsClaudeFeature2),
          _FeatureRow(description: l10n.settingsClaudeFeature3),
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
    final tokens = PolarisTokens.of(context);
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
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: PolarisIconSize.standard, color: toneColor),
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
            child: Icon(
              Icons.check,
              size: PolarisIconSize.small,
              color: colors.onSurfaceVariant,
            ),
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
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final tokens = PolarisTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsClaudeInstallTitle,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsClaudeInstallInstructions,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(tokens.radius),
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
                icon: const Icon(
                  Icons.content_copy,
                  size: PolarisIconSize.standard,
                ),
                tooltip: l10n.settingsClaudeInstallCopyTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: () => _copy(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsClaudeInstallAfter,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final copiedMessage = AppLocalizations.of(
      context,
    ).settingsClaudeInstallCopied;
    await Clipboard.setData(const ClipboardData(text: _command));
    if (!context.mounted) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(copiedMessage),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// キーボードショートカットの導線と、エクスプローラのマウス操作モデルの解説。
///
/// キー割り当ての一覧・編集は専用画面 [KeybindingsPage] に分離した（ADR-0033）。
/// マウス操作（ADR-0021 のダブルクリック式）は割り当て対象外なので、ここに
/// 解説として残す。
class _ShortcutsSection extends StatelessWidget {
  const _ShortcutsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsKeyboardShortcutsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsKeyboardShortcutsDescription,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.keyboard),
              label: Text(l10n.settingsKeyboardShortcutsButton),
              onPressed: () => const KeybindingsRoute().push<void>(context),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.settingsMouseOperationsTitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _ShortcutRow(
            keys: const ['Click'],
            description: l10n.settingsMouseClick,
          ),
          _ShortcutRow(
            keys: const ['Double Click'],
            description: l10n.settingsMouseDoubleClick,
          ),
          _ShortcutRow(
            keys: const ['Right Click'],
            description: l10n.settingsMouseRightClick,
          ),
          _ShortcutRow(
            keys: const ['Mouse Back / Forward'],
            description: l10n.settingsMouseNavigation,
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
    final tokens = PolarisTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.radius),
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
