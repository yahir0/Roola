import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/appearance/appearance_settings.dart';
import 'package:roola/data/appearance/appearance_settings_repository_impl.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';

/// 設定画面に組み込む「外観」セクション。
///
/// `appearanceSettingsProvider` を購読し、モード切替・色設定・画像選択を
/// ユーザーに提供する。
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  // ロゴ（AppIcon）の配色に揃えたプリセット。
  static const _presetColors = <Color>[
    Color(0xFF1E232A), // ロゴ背景（deep gunmetal）
    Color(0xFF2F353D), // ロゴ surface
    Color(0xFF0A0A14), // pure midnight
    Color(0xFF5080C0), // ロゴ primary blue
    Color(0xFF90C0F0), // ロゴ accent light blue
    Color(0xFFFFFFFF), // 白
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appearanceSettingsProvider);
    return state.when(
      data: (settings) => _Body(settings: settings),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('外観設定の読み込みに失敗しました: $e'),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.settings});

  final AppearanceSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(appearanceSettingsProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('外観', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<AppearanceMode>(
            segments: const [
              ButtonSegment(
                value: AppearanceMode.transparent,
                label: Text('透過'),
                icon: Icon(Icons.blur_on),
              ),
              ButtonSegment(
                value: AppearanceMode.gradient,
                label: Text('ロゴ'),
                icon: Icon(Icons.gradient),
              ),
              ButtonSegment(
                value: AppearanceMode.solid,
                label: Text('単色'),
                icon: Icon(Icons.format_color_fill),
              ),
              ButtonSegment(
                value: AppearanceMode.image,
                label: Text('画像'),
                icon: Icon(Icons.image),
              ),
            ],
            selected: {settings.mode},
            onSelectionChanged: (modes) async {
              if (modes.isNotEmpty) {
                await notifier.setMode(modes.first);
              }
            },
          ),
          const SizedBox(height: 16),
          if (settings.mode == AppearanceMode.transparent) ...[
            _OpacitySlider(
              value: settings.transparencyOpacity,
              onChanged: notifier.setTransparencyOpacity,
            ),
            const SizedBox(height: 16),
            _CenterImagePicker(
              imagePath: settings.transparentCenterImagePath,
              onPick: () =>
                  _pickAndSaveCenterImage(context, ref, notifier),
              onClear: () => notifier.setTransparentCenterImagePath(null),
            ),
          ],
          if (settings.mode == AppearanceMode.solid)
            _ColorPicker(
              selectedColor: settings.solidColor,
              onPick: notifier.setSolidColor,
            ),
          if (settings.mode == AppearanceMode.image)
            _ImagePicker(
              imagePath: settings.imagePath,
              onPick: () => _pickAndSaveImage(context, ref, notifier),
            ),
        ],
      ),
    );
  }

  Future<void> _pickAndSaveImage(
    BuildContext context,
    WidgetRef ref,
    AppearanceSettingsNotifier notifier,
  ) async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    final src = result?.files.single.path;
    if (src == null) {
      return;
    }
    final paths = ref.read(appPathsProvider);
    final dest = paths.backgroundImageFile;
    await File(src).copy(dest.path);
    // 同じパスに上書き保存しただけでは Flutter の ImageCache が
    // 古いバイト列を返し続け、再起動するまで描画が更新されない。
    // 該当パスの FileImage を cache から落として強制再読み込みする。
    await FileImage(dest).evict();
    await notifier.setImagePath(dest.path);
  }

  Future<void> _pickAndSaveCenterImage(
    BuildContext context,
    WidgetRef ref,
    AppearanceSettingsNotifier notifier,
  ) async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    final src = result?.files.single.path;
    if (src == null) {
      return;
    }
    final paths = ref.read(appPathsProvider);
    final dest = paths.transparentCenterImageFile;
    await File(src).copy(dest.path);
    // 上書き保存後のキャッシュ立て直し。背景画像と同じ理由（詳細は
    // `_pickAndSaveImage` のコメント参照）。
    await FileImage(dest).evict();
    await notifier.setTransparentCenterImagePath(dest.path);
  }
}

/// 透過モード時の暗幕の不透明度スライダー。値は 0.0〜1.0。
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
            const Text('不透明度'),
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

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selectedColor, required this.onPick});

  final int? selectedColor;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppearanceSection._presetColors.map((color) {
        final isSelected = color.toARGB32() == selectedColor;
        return GestureDetector(
          onTap: () => onPick(color.toARGB32()),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({required this.imagePath, required this.onPick});

  final String? imagePath;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final file = imagePath != null ? File(imagePath!) : null;
    final hasImage = file != null && file.existsSync();
    return Row(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Image.file(
                  file,
                  // 同パス上書きで Image が再リゾルブされない問題対策
                  key: ValueKey(file.lastModifiedSync()),
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.image_outlined, size: 32),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('画像を選択'),
          onPressed: onPick,
        ),
      ],
    );
  }
}

/// 透過モード時に中央へ重ねる画像のピッカー。`_ImagePicker` と似た形だが、
/// 「クリア」操作を持つ点と、見出しテキストを追加する点が異なる。
class _CenterImagePicker extends StatelessWidget {
  const _CenterImagePicker({
    required this.imagePath,
    required this.onPick,
    required this.onClear,
  });

  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final file = imagePath != null ? File(imagePath!) : null;
    final hasImage = file != null && file.existsSync();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('中央画像', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          'ウィンドウの中央に重ねて表示します（短辺の 60% 程度のサイズ）。',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Image.file(
                      file,
                      // 同パス上書きで Image が再リゾルブされない問題対策
                      key: ValueKey(file.lastModifiedSync()),
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_outlined, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('画像を選択'),
                  onPressed: onPick,
                ),
                if (hasImage) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('クリア'),
                    onPressed: onClear,
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
