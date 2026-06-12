import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/task_notification/task_notification_repository.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
import 'package:roola/ui/common/polaris_settings_panel.dart';

/// タスク通知（ADR-0066）の設定セクション。
///
/// 通知は OSC（in-band）方式で設定ゼロで動くため、ここで提供するのは
/// OS の通知許可状態の表示と導線（許可リクエスト / システム設定を開く）のみ。
/// 許可が未決定でも初回の通知発射時に lazy に要求されるので、この導線は
/// 「通知が出ない原因の自己診断と事前許可」のためにある。
class NotificationSection extends ConsumerWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PolarisSettingsSection(
      label: l10n.settingsTaskNotificationTitle,
      description: l10n.settingsTaskNotificationDescription,
      children: const [_AuthorizationRow()],
    );
  }
}

/// 通知許可状態の表示と、未許可 / 拒否時の導線。
class _AuthorizationRow extends ConsumerWidget {
  const _AuthorizationRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final auth = ref.watch(notificationAuthorizationProvider);
    final status = auth.value ?? NotificationAuthorizationStatus.notDetermined;

    final (text, glyph) = switch (status) {
      NotificationAuthorizationStatus.authorized => (
        l10n.settingsTaskNotificationAuthAuthorized,
        PolarisGlyph.check(color: colors.primary),
      ),
      NotificationAuthorizationStatus.denied => (
        l10n.settingsTaskNotificationAuthDenied,
        PolarisGlyph.warn(color: colors.error),
      ),
      NotificationAuthorizationStatus.notDetermined => (
        l10n.settingsTaskNotificationAuthNotDetermined,
        PolarisGlyph.info(color: colors.onSurfaceVariant),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: PolarisTokens.space1),
              child: glyph,
            ),
            const SizedBox(width: PolarisTokens.space2),
            Expanded(child: Text(text)),
          ],
        ),
        const SizedBox(height: PolarisTokens.space2),
        if (status == NotificationAuthorizationStatus.notDetermined)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => _grant(ref),
              child: Text(l10n.settingsTaskNotificationGrantButton),
            ),
          )
        else if (status == NotificationAuthorizationStatus.denied)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => ref
                  .read(taskNotificationRepositoryProvider)
                  .openSystemSettings(),
              child: Text(l10n.settingsTaskNotificationOpenSettingsButton),
            ),
          ),
      ],
    );
  }

  Future<void> _grant(WidgetRef ref) async {
    await ref.read(taskNotificationRepositoryProvider).requestAuthorization();
    ref.invalidate(notificationAuthorizationProvider);
  }
}
