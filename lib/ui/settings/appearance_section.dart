import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/appearance/appearance_settings.dart';
import 'package:roola/data/appearance/appearance_settings_repository_impl.dart';
import 'package:roola/data/appearance/polaris_accent.dart';
import 'package:roola/l10n/app_localizations.dart';

/// 設定画面に組み込む「外観」セクション。
///
/// `appearanceSettingsProvider` を購読し、アクセント色・透過モードの切替を
/// ユーザーに提供する。Polaris（ADR-0038）はダーク専用・グラファイト筐体の
/// 視覚システムのため、外観は「不透明な筐体」と「筐体を透かす」の 2 択に
/// 絞る（旧 単色 / 画像 / グラデーションは廃止）。
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appearanceSettingsProvider);
    return state.when(
      data: (settings) => _Body(settings: settings),
      loading: () => const Padding(
        padding: EdgeInsets.all(PolarisTokens.space4),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(PolarisTokens.space4),
        child: Text(AppLocalizations.of(context).appearanceLoadError('$e')),
      ),
    );
  }
}

/// 設定項目のフィールド見出し（全大文字トラッキング / ADR-0038 D9）。
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Text(
      text.toUpperCase(),
      style: tokens.label.copyWith(color: tokens.textFaint),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.settings});

  final AppearanceSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(appearanceSettingsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(PolarisTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appearanceTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: PolarisTokens.space4),
          // アクセント色（ADR-0038 D4）。常に 1 色だが選択できる。
          _FieldLabel(l10n.appearanceAccentLabel),
          const SizedBox(height: PolarisTokens.space2),
          SegmentedButton<PolarisAccent>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: PolarisAccent.gold, label: Text('GOLD')),
              ButtonSegment(value: PolarisAccent.iceBlue, label: Text('ICE')),
            ],
            selected: {settings.accent},
            onSelectionChanged: (accents) async {
              if (accents.isNotEmpty) {
                await notifier.setAccent(accents.first);
              }
            },
          ),
          const SizedBox(height: PolarisTokens.space4),
          // 背景モード。不透明 = Polaris グラファイト筐体、透過 = 筐体を
          // 半透明にして背後のデスクトップを透かす（ADR-0038）。
          _FieldLabel(l10n.appearanceBackgroundLabel),
          const SizedBox(height: PolarisTokens.space2),
          SegmentedButton<AppearanceMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: AppearanceMode.opaque,
                label: Text(l10n.appearanceModeOpaque),
              ),
              ButtonSegment(
                value: AppearanceMode.transparent,
                label: Text(l10n.appearanceModeTransparent),
              ),
            ],
            selected: {settings.mode},
            onSelectionChanged: (modes) async {
              if (modes.isNotEmpty) {
                await notifier.setMode(modes.first);
              }
            },
          ),
          const SizedBox(height: PolarisTokens.space4),
          if (settings.mode == AppearanceMode.transparent)
            _OpacitySlider(
              value: settings.transparencyOpacity,
              onChanged: notifier.setTransparencyOpacity,
            ),
        ],
      ),
    );
  }
}

/// 透過モードの不透明度スライダー。値は 0.0〜1.0。
class _OpacitySlider extends StatelessWidget {
  const _OpacitySlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context).appearanceOpacityLabel),
            const Spacer(),
            Text('$percent%', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Slider(
          value: value.clamp(0.0, 1.0),
          divisions: 20,
          label: '$percent%',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
