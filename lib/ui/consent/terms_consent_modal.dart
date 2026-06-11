import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/constants/terms.dart';
import 'package:roola/data/privacy/privacy_settings_repository_impl.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_settings_panel.dart';
import 'package:roola/ui/common/polaris_toggle.dart';
import 'package:roola/ui/consent/terms_text_view.dart';

/// 利用規約への同意モーダル（ADR-0065）。
///
/// `TermsConsentGate` がメイン UI の上に被せる。[PolarisModalShell] と同じ
/// 「スクリム + ベゼルパネル」の見た目だが、こちらは同意するまで閉じられない
/// （✕ なし・スクリムタップ無効・Esc 無効）ため別実装にしている。
///
/// 構成: 規約全文（スクロール）→ アナリティクス説明 + 送信トグル（既定 ON）
/// → 「終了」「同意して開始」ボタン。トグルを同意画面に明示することで、
/// 既定 ON でも初回に必ずオプトアウトの選択機会を保証する。
class TermsConsentModal extends HookConsumerWidget {
  const TermsConsentModal({super.key, required this.onQuit});

  /// 「終了」が押されたときの処理（アプリ終了）。テストで差し替えるため注入。
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final analyticsEnabled = useState(true);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // スクリム。PolarisModalShell と違いタップしても閉じない。
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: ColoredBox(color: tokens.well.withValues(alpha: 0.72)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(PolarisTokens.space8),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.well,
                    borderRadius: BorderRadius.circular(tokens.radius),
                    border: Border.all(color: tokens.line),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radius),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 筐体上端が光を受ける 1px ハイライト（ADR-0038 D3）。
                        SizedBox(
                          height: 1,
                          child: ColoredBox(color: tokens.topEdge),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(PolarisTokens.space3),
                          child: PolarisFieldLabel(l10n.consentModalTitle),
                        ),
                        SizedBox(
                          height: 1,
                          child: ColoredBox(color: tokens.line),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            PolarisTokens.space6,
                            PolarisTokens.space4,
                            PolarisTokens.space6,
                            0,
                          ),
                          child: Text(
                            l10n.consentModalIntro,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: PolarisTokens.space3),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PolarisTokens.space6,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: tokens.bg,
                                borderRadius: BorderRadius.circular(
                                  tokens.radius,
                                ),
                                border: Border.all(color: tokens.line),
                              ),
                              child: const _TermsOverlay(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            PolarisTokens.space6,
                            PolarisTokens.space4,
                            PolarisTokens.space6,
                            PolarisTokens.space4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PolarisFieldLabel(
                                l10n.consentAnalyticsToggleLabel,
                              ),
                              const SizedBox(height: PolarisTokens.space2),
                              Text(
                                l10n.consentAnalyticsDescription,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: tokens.textDim),
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
                                selected: analyticsEnabled.value,
                                onChanged: (value) =>
                                    analyticsEnabled.value = value,
                              ),
                              const SizedBox(height: PolarisTokens.space4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: onQuit,
                                    child: Text(l10n.consentQuitButton),
                                  ),
                                  const SizedBox(width: PolarisTokens.space3),
                                  FilledButton(
                                    autofocus: true,
                                    onPressed: () => _accept(
                                      ref,
                                      analyticsEnabled.value,
                                    ),
                                    child: Text(l10n.consentAcceptButton),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _accept(WidgetRef ref, bool analyticsEnabled) {
    // 同意の記録で `privacySettingsProvider` が同意済みに変わり、
    // `TermsConsentGate` がモーダルを外して `app_launched` を送信する。
    return ref
        .read(privacySettingsProvider.notifier)
        .acceptTerms(
          version: currentTermsVersion,
          analyticsEnabled: analyticsEnabled,
        );
  }
}

/// 規約表示（`TermsTextView`）専用の [Overlay]。
///
/// このモーダルは MaterialApp の builder チェーン（Navigator の外側）に
/// 重なるため、ツリー上に [Overlay] が存在しない。`TermsTextView` 内の
/// `SelectionArea` は選択ハンドル・コンテキストメニューの描画先として
/// Overlay を要求するので、ここで 1 枚はさむ。
class _TermsOverlay extends StatelessWidget {
  const _TermsOverlay();

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(builder: (_) => const TermsTextView()),
      ],
    );
  }
}
