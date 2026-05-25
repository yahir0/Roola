import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/about.dart';
import 'package:roola/app/router.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/health/claude_health_check.dart';
import 'package:roola/data/locale/app_locale.dart';
import 'package:roola/data/locale/locale_settings_repository_impl.dart';
import 'package:roola/data/repo_explorer/explorer_settings.dart';
import 'package:roola/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
import 'package:roola/ui/common/polaris_modal_shell.dart';
import 'package:roola/ui/common/polaris_settings_panel.dart';
import 'package:roola/ui/common/polaris_toggle.dart';
import 'package:roola/ui/settings/appearance_section.dart';
import 'package:roola/ui/settings/task_notification_section.dart';

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
    // ワークスペースに重ねる計器ディスプレイ（[PolarisModalShell]）として出す。
    // ベゼル(シェル) の内側は箱で囲わず、極薄ヘアライン
    // （[PolarisSectionDivider]）と余白だけのフラット構成（ADR-0054）。
    return PolarisModalShell(
      title: AppLocalizations.of(context).settingsPageTitle,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: PolarisTokens.space4),
        children: const [
          _LanguageSection(),
          PolarisSectionDivider(),
          AppearanceSection(),
          PolarisSectionDivider(),
          _ExplorerSection(),
          PolarisSectionDivider(),
          _ClaudeIntegrationSection(),
          PolarisSectionDivider(),
          TaskNotificationSection(),
          PolarisSectionDivider(),
          _ShortcutsSection(),
          PolarisSectionDivider(),
          _AboutSection(),
        ],
      ),
    );
  }
}

/// アプリ情報セクション（ADR-0040）。
///
/// アプリ名・バージョン・著作権と、OSS ライセンス一覧への導線を表示する。
/// 「Roola について…」ボタンを押すと [showRoolaAboutDialog] が開き、その
/// 「ライセンスを表示」ボタンから OSS ライセンス一覧モーダルへ遷移できる
/// （ADR-0056）。
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return PolarisSettingsSection(
      label: l10n.settingsAboutTitle,
      description: l10n.settingsAboutDescription,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: PolarisGlyph.info(color: colors.onSurfaceVariant),
            label: Text(l10n.settingsAboutOpenButton),
            onPressed: () => showRoolaAboutDialog(context),
          ),
        ),
      ],
    );
  }
}

/// 表示言語の切替セクション（ADR-0034）。日本語 / 英語の 2 択。
class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider);
    return PolarisSettingsSection(
      label: l10n.settingsLanguageTitle,
      description: l10n.settingsLanguageDescription,
      children: [
        PolarisToggle<AppLocale>(
          segments: [
            PolarisToggleSegment(
              value: AppLocale.ja,
              label: l10n.languageJapanese,
            ),
            PolarisToggleSegment(
              value: AppLocale.en,
              label: l10n.languageEnglish,
            ),
          ],
          selected: locale,
          onChanged: (value) =>
              ref.read(appLocaleProvider.notifier).setLocale(value),
        ),
      ],
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
    return PolarisSettingsSection(
      label: l10n.settingsExplorerTitle,
      description: l10n.settingsExplorerDescription,
      children: [
        PolarisToggle<ExplorerListDensity>(
          segments: [
            PolarisToggleSegment(
              value: ExplorerListDensity.compact,
              label: l10n.explorerDensityCompact,
              iconBuilder: (color) => PolarisGlyph.rows(
                color: color,
                rows: 3,
                size: PolarisIconSize.small,
              ),
            ),
            PolarisToggleSegment(
              value: ExplorerListDensity.comfortable,
              label: l10n.explorerDensityComfortable,
              iconBuilder: (color) => PolarisGlyph.rows(
                color: color,
                rows: 2,
                size: PolarisIconSize.small,
              ),
            ),
          ],
          selected: density,
          onChanged: state.isLoading
              ? null
              : (value) => ref
                    .read(explorerSettingsProvider.notifier)
                    .setListDensity(value),
        ),
        const SizedBox(height: PolarisTokens.space2),
        Text(
          density == ExplorerListDensity.compact
              ? l10n.explorerDensityCompactDescription
              : l10n.explorerDensityComfortableDescription,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
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
    return PolarisSettingsSection(
      label: l10n.settingsClaudeIntegrationTitle,
      description: l10n.settingsClaudeIntegrationDescription,
      children: [
        health.when(
          loading: () => _StatusCard(
            tone: _StatusTone.neutral,
            title: l10n.claudeHealthChecking,
            detail: l10n.claudeHealthCheckingDetail,
          ),
          error: (e, _) => _StatusCard(
            tone: _StatusTone.error,
            title: l10n.claudeHealthCheckError,
            detail: '$e',
          ),
          data: (h) => h.available
              ? _StatusCard(
                  tone: _StatusTone.ok,
                  title: l10n.claudeHealthCheckSuccess,
                  detail: h.versionOutput.isEmpty
                      ? l10n.claudeHealthCheckSuccessDetail
                      : l10n.claudeHealthVersion(h.versionOutput),
                )
              : _StatusCard(
                  tone: _StatusTone.error,
                  title: l10n.claudeHealthCheckNotFound,
                  detail: h.versionOutput.isEmpty
                      ? l10n.claudeHealthCheckNotFoundDetail
                      : l10n.claudeHealthCheckNotFoundDetailWith(
                          h.versionOutput,
                        ),
                ),
        ),
        const SizedBox(height: PolarisTokens.space4),
        PolarisFieldLabel(l10n.settingsClaudeFeatures),
        const SizedBox(height: PolarisTokens.space2),
        _FeatureRow(description: l10n.settingsClaudeFeature1),
        _FeatureRow(description: l10n.settingsClaudeFeature2),
        _FeatureRow(description: l10n.settingsClaudeFeature3),
        if (health.value?.available != true) ...[
          const SizedBox(height: PolarisTokens.space4),
          const _InstallGuide(),
        ],
      ],
    );
  }
}

enum _StatusTone { ok, neutral, error }

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.tone,
    required this.title,
    required this.detail,
  });

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
    final glyph = switch (tone) {
      _StatusTone.ok => PolarisGlyph.check(color: toneColor),
      _StatusTone.neutral => PolarisGlyph.info(color: toneColor),
      _StatusTone.error => PolarisGlyph.warn(color: toneColor),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space3,
        PolarisTokens.space3,
        PolarisTokens.space3,
        PolarisTokens.space3,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          glyph,
          const SizedBox(width: PolarisTokens.space3),
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
            padding: const EdgeInsets.only(
              top: PolarisTokens.space1,
              right: PolarisTokens.space2,
            ),
            child: PolarisGlyph.check(
              color: colors.onSurfaceVariant,
              size: PolarisIconSize.small,
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
        PolarisFieldLabel(l10n.settingsClaudeInstallTitle),
        const SizedBox(height: PolarisTokens.space2),
        Text(
          l10n.settingsClaudeInstallInstructions,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: PolarisTokens.space2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            PolarisTokens.space3,
            PolarisTokens.space3,
            PolarisTokens.space2,
            PolarisTokens.space3,
          ),
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
                icon: PolarisGlyph.copy(color: colors.onSurfaceVariant),
                tooltip: l10n.settingsClaudeInstallCopyTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: () => _copy(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: PolarisTokens.space2),
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
    return PolarisSettingsSection(
      label: l10n.settingsKeyboardShortcutsTitle,
      description: l10n.settingsKeyboardShortcutsDescription,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: PolarisGlyph.keyboard(color: colors.onSurfaceVariant),
            label: Text(l10n.settingsKeyboardShortcutsButton),
            onPressed: () => const KeybindingsRoute().push<void>(context),
          ),
        ),
        const SizedBox(height: PolarisTokens.space4),
        PolarisFieldLabel(l10n.settingsMouseOperationsTitle),
        const SizedBox(height: PolarisTokens.space2),
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
      padding: const EdgeInsets.symmetric(vertical: PolarisTokens.space1),
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
          const SizedBox(width: PolarisTokens.space3),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: PolarisTokens.space1),
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
      padding: const EdgeInsets.symmetric(
        horizontal: PolarisTokens.space2,
        vertical: PolarisTokens.space1,
      ),
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
