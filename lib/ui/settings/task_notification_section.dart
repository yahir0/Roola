import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/task_notification/task_notification_repository.dart';
import 'package:roola/data/task_notification/task_notification_server.dart';
import 'package:roola/data/task_notification/task_notification_settings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
import 'package:roola/ui/common/polaris_settings_panel.dart';
import 'package:roola/ui/common/polaris_toggle.dart';

/// Claude Code タスク完了通知（ADR-0057）の設定セクション。
///
/// 機能の ON/OFF、通知許可状態と導線、待受ポート、`~/.claude/settings.json`
/// へ貼るフック設定スニペットを表示する。
class TaskNotificationSection extends ConsumerWidget {
  const TaskNotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(taskNotificationSettingsProvider);
    final enabled = settings.value?.enabled ?? false;

    return PolarisSettingsSection(
      label: l10n.settingsTaskNotificationTitle,
      description: l10n.settingsTaskNotificationDescription,
      children: [
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
              : (value) => _setEnabled(ref, value),
        ),
        if (enabled) ...[
          const SizedBox(height: PolarisTokens.space4),
          const _AuthorizationRow(),
          const SizedBox(height: PolarisTokens.space4),
          const _HookSetup(),
        ],
      ],
    );
  }

  Future<void> _setEnabled(WidgetRef ref, bool value) async {
    await ref.read(taskNotificationSettingsProvider.notifier).setEnabled(value);
    // 有効化時のみ初回の通知許可を要求する（ADR-0057）。
    if (value) {
      await ref.read(taskNotificationRepositoryProvider).requestAuthorization();
      ref.invalidate(notificationAuthorizationProvider);
    }
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

/// 待受ポートと、`~/.claude/settings.json` へ貼るフック設定スニペット。
class _HookSetup extends ConsumerWidget {
  const _HookSetup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final tokens = PolarisTokens.of(context);
    final portAsync = ref.watch(taskNotificationServerProvider);
    final port = portAsync.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PolarisFieldLabel(l10n.settingsTaskNotificationSetupTitle),
        const SizedBox(height: PolarisTokens.space2),
        Text(
          l10n.settingsTaskNotificationSetupInstructions,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: PolarisTokens.space2),
        if (port == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(PolarisTokens.space3),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else ...[
          Text(
            l10n.settingsTaskNotificationPortLabel(port),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    buildHookSnippet(port),
                    style: const TextStyle(
                      fontFamily: 'SarasaTermJ',
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: PolarisGlyph.copy(color: colors.onSurfaceVariant),
                  tooltip: l10n.settingsTaskNotificationCopyTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _copy(context, buildHookSnippet(port)),
                ),
              ],
            ),
          ),
          const SizedBox(height: PolarisTokens.space2),
          Text(
            l10n.settingsTaskNotificationJqNote,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: PolarisTokens.space2),
          Text(
            Platform.isWindows
                ? 'Node.js（Claude Code に同梱）で動作します。追加のインストールは不要です。'
                : '`jq` と `curl` が必要です（macOS: `brew install jq`）。',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Future<void> _copy(BuildContext context, String snippet) async {
    final messenger = ScaffoldMessenger.of(context);
    final copiedMessage = AppLocalizations.of(
      context,
    ).settingsTaskNotificationCopied;
    await Clipboard.setData(ClipboardData(text: snippet));
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

/// `~/.claude/settings.json` に貼る Stop フック設定スニペットを組み立てる。
///
/// macOS: `jq` + `curl` で stdin の JSON を整形して POST する。
/// Windows: `jq` が標準搭載されないため Node.js（Claude Code の実行要件）で代替。
/// 末尾 `|| true` でフック失敗が claude 側の処理に影響しない。
/// JSON エスケープは [JsonEncoder] に任せる。
String buildHookSnippet(int port) {
  final command = Platform.isWindows
      ? _buildWindowsCommand(port)
      : _buildMacosCommand(port);
  return const JsonEncoder.withIndent('  ').convert({
    'hooks': {
      'Stop': [
        {
          'hooks': [
            {'type': 'command', 'command': command},
          ],
        },
      ],
    },
  });
}

String _buildMacosCommand(int port) =>
    'jq -nc --arg id "\$ROOLA_TAB_ID" --arg token "\$ROOLA_NOTIFY_TOKEN" '
    '--argjson in "\$(cat)" '
    "'{tab_id:\$id, token:\$token, session_id:\$in.session_id, cwd:\$in.cwd}' "
    '| curl -s -X POST http://127.0.0.1:$port/hook/stop '
    "-H 'Content-Type: application/json' -d @- || true";

// Windows は Git Bash (sh -c) でフックが実行される。jq が標準搭載されない
// ため、Claude Code の実行要件である Node.js の http モジュールで代替する。
// process.env.* を使うことで $ 記号を避けられ、bash の変数展開に干渉しない。
String _buildWindowsCommand(int port) {
  final script =
      "let d='';"
      "process.stdin.setEncoding('utf8');"
      "process.stdin.on('data',c=>d+=c);"
      "process.stdin.on('end',()=>{"
      'const p=JSON.parse(d),'
      'b=JSON.stringify({tab_id:process.env.ROOLA_TAB_ID,'
      'token:process.env.ROOLA_NOTIFY_TOKEN,'
      'session_id:p.session_id,cwd:p.cwd}),'
      "r=require('http').request({"
      "hostname:'127.0.0.1',port:$port,"
      "path:'/hook/stop',method:'POST',"
      "headers:{'Content-Type':'application/json',"
      "'Content-Length':Buffer.byteLength(b)}});"
      'r.on(\'error\',()=>{});r.end(b)})';
  return 'node -e "$script" 2>/dev/null || true';
}
