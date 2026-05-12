import 'dart:io';

import 'package:claude_skills_launcher/data/appearance/appearance_settings.dart';
import 'package:claude_skills_launcher/data/appearance/appearance_settings_repository_impl.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 設定画面に組み込む「外観」セクション。
///
/// `appearanceSettingsProvider` を購読し、モード切替・色設定・画像選択を
/// ユーザーに提供する。
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  static const _presetColors = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFF1E1E1E),
    Color(0xFF6750A4),
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFFD32F2F),
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
    final paths = await ref.read(appPathsProvider.future);
    final dest = paths.backgroundImageFile;
    await File(src).copy(dest.path);
    await notifier.setImagePath(dest.path);
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
    final hasImage = imagePath != null && File(imagePath!).existsSync();
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
              ? Image.file(File(imagePath!), fit: BoxFit.cover)
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
