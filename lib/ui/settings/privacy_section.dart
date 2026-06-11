import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/privacy/privacy_settings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
import 'package:roola/ui/common/polaris_settings_panel.dart';
import 'package:roola/ui/common/polaris_toggle.dart';

/// プライバシー設定セクション（ADR-0065）。
///
/// 匿名利用統計（Aptabase）送信のオプトアウトトグルと、利用規約全文への
/// 導線を置く。トグルは即時反映・永続化で、OFF の間は `AnalyticsService` が
/// 一切送信しない。
class PrivacySection extends ConsumerWidget {
  const PrivacySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);
    final colors = Theme.of(context).colorScheme;
    final settings = ref.watch(privacySettingsProvider);
    final enabled = settings.value?.analyticsEnabled ?? true;

    return PolarisSettingsSection(
      label: l10n.settingsPrivacyTitle,
      description: l10n.settingsPrivacyDescription,
      children: [
        PolarisFieldLabel(l10n.consentAnalyticsToggleLabel),
        const SizedBox(height: PolarisTokens.space2),
        Text(
          l10n.consentAnalyticsDescription,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.textDim),
        ),
        const SizedBox(height: PolarisTokens.space3),
        PolarisToggle<bool>(
          segments: [
            PolarisToggleSegment(
              value: false,
              label: l10n.settingsTaskNotificationOff,
            ),
            PolarisToggleSegment(
              value: true,
              label: l10n.settingsTaskNotificationOn,
            ),
          ],
          selected: enabled,
          onChanged: settings.isLoading
              ? null
              : (value) => ref
                    .read(privacySettingsProvider.notifier)
                    .setAnalyticsEnabled(value),
        ),
        const SizedBox(height: PolarisTokens.space4),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: PolarisGlyph.info(color: colors.onSurfaceVariant),
            label: Text(l10n.settingsPrivacyViewTermsButton),
            onPressed: () => const TermsRoute().push<void>(context),
          ),
        ),
      ],
    );
  }
}
