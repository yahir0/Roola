import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/notepad/notepad_note.dart';
import 'package:roola/data/notepad/notepad_notes_provider.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/prompt_name_dialog.dart';
import 'package:roola/ui/notepad/notepad_line_gutter.dart';
import 'package:roola/ui/workspace/current_tab_id_provider.dart';
import 'package:roola/ui/workspace/workspace_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// ワークスペースのペインに埋め込まれるノートパッドタブ。
///
/// 上部ツールバーに「保存」「TXTで保存」ボタンを配置し、保存するとサイドバー
/// の NOTEPAD セクションに未分類として登録される。
class NotepadTabBody extends HookConsumerWidget {
  const NotepadTabBody({required this.noteId, super.key});

  /// 保存済みメモの ID。null の場合は新規未保存メモ。
  final String? noteId;

  static const double _fontSize = 14;
  static const double _lineHeightFactor = 1.5;
  static const double _lineHeight = _fontSize * _lineHeightFactor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);
    final theme = Theme.of(context);

    final notes = ref.watch(notepadNotesProvider).value ?? const [];
    final savedNote = noteId != null
        ? notes.where((n) => n.id == noteId).firstOrNull
        : null;

    final controller = useTextEditingController(
      text: savedNote?.content ?? '',
    );
    final scrollController = useScrollController();
    final isSaving = useState(false);

    // 保存済みメモのコンテンツが更新されたら反映する（別タブで同じメモを
    // 開いて保存した場合など）。
    useEffect(() {
      if (savedNote != null && controller.text != savedNote.content) {
        controller.text = savedNote.content;
      }
      return null;
    }, [savedNote?.updatedAt]);

    final baseStyle = theme.textTheme.bodyMedium ?? const TextStyle();
    final textStyle = baseStyle.copyWith(
      fontSize: _fontSize,
      height: _lineHeightFactor,
      color: theme.colorScheme.onSurface,
    );
    const strutStyle = StrutStyle(
      fontSize: _fontSize,
      height: _lineHeightFactor,
      forceStrutHeight: true,
    );
    final numberStyle = baseStyle.copyWith(
      fontSize: 13,
      color: theme.colorScheme.onSurfaceVariant,
    );

    Future<void> handleSave() async {
      if (isSaving.value) return;
      isSaving.value = true;
      try {
        final content = controller.text;
        final notesNotifier = ref.read(notepadNotesProvider.notifier);
        final tabId = ref.read(currentTabIdProvider);
        if (noteId == null) {
          // 初回保存：名前入力ダイアログを表示する。
          final suggested = _titleFromContent(content);
          if (!context.mounted) return;
          final inputName = await promptName(
            context,
            title: l10n.notepadNameDialogTitle,
            initialValue: suggested,
            confirmLabel: l10n.buttonSave,
          );
          if (inputName == null || inputName.isEmpty) return;
          final now = DateTime.now();
          final saved = await notesNotifier.addNote(
            NotepadNote(
              id: _uuid.v4(),
              title: inputName,
              content: content,
              createdAt: now,
              updatedAt: now,
            ),
          );
          // タブの noteId とタイトルを更新して「既存メモ」として扱えるようにする。
          ref
              .read(workspaceProvider.notifier)
              .updateNotepadTabAfterSave(tabId, saved.id, saved.title);
        } else {
          final existing = ref
              .read(notepadNotesProvider)
              .value
              ?.where((n) => n.id == noteId)
              .firstOrNull;
          if (existing != null) {
            await notesNotifier.updateNote(
              existing.copyWith(
                content: content,
                updatedAt: DateTime.now(),
              ),
            );
          }
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.notepadSavedToNotepad),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> handleSaveAsTxt() async {
      final content = controller.text;
      final title = _titleFromContent(content);
      final savePath = await FilePicker.saveFile(
        dialogTitle: l10n.notepadSaveAsTxt,
        fileName: '$title.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      if (savePath == null) return;
      await File(savePath).writeAsString(content);
    }

    return Column(
      children: [
        _NotepadToolbar(
          onSave: isSaving.value ? null : handleSave,
          onSaveAsTxt: handleSaveAsTxt,
          isSaving: isSaving.value,
          tokens: tokens,
          l10n: l10n,
        ),
        Divider(height: 1, thickness: 1, color: tokens.line),
        Expanded(
          child: _NotepadEditor(
            controller: controller,
            scrollController: scrollController,
            textStyle: textStyle,
            strutStyle: strutStyle,
            lineHeight: _lineHeight,
            numberStyle: numberStyle,
            hintText: l10n.notepadHint,
          ),
        ),
      ],
    );
  }

  /// コンテンツの最初の非空行をタイトルとして使う（最大 40 文字）。
  static String _titleFromContent(String content) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        return trimmed.length > 40 ? '${trimmed.substring(0, 40)}…' : trimmed;
      }
    }
    return '無題';
  }
}

class _NotepadToolbar extends StatelessWidget {
  const _NotepadToolbar({
    required this.onSave,
    required this.onSaveAsTxt,
    required this.isSaving,
    required this.tokens,
    required this.l10n,
  });

  final VoidCallback? onSave;
  final VoidCallback onSaveAsTxt;
  final bool isSaving;
  final PolarisTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: tokens.bg,
      padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space2),
      child: Row(
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: PolarisIconSize.standard,
            color: tokens.textFaint,
          ),
          const SizedBox(width: PolarisTokens.space2),
          Text(l10n.notepadTitle, style: tokens.body.copyWith(color: tokens.textDim)),
          const Spacer(),
          TextButton(
            onPressed: onSave,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space3),
              minimumSize: const Size(0, 32),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              isSaving ? l10n.buttonSaving : l10n.buttonSave,
              style: tokens.body.copyWith(color: tokens.accent),
            ),
          ),
          const SizedBox(width: PolarisTokens.space1),
          TextButton(
            onPressed: onSaveAsTxt,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space3),
              minimumSize: const Size(0, 32),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              l10n.notepadSaveAsTxt,
              style: tokens.body.copyWith(color: tokens.textDim),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotepadEditor extends StatelessWidget {
  const _NotepadEditor({
    required this.controller,
    required this.scrollController,
    required this.textStyle,
    required this.strutStyle,
    required this.lineHeight,
    required this.numberStyle,
    required this.hintText,
  });

  final TextEditingController controller;
  final ScrollController scrollController;
  final TextStyle textStyle;
  final StrutStyle strutStyle;
  final double lineHeight;
  final TextStyle numberStyle;
  final String hintText;

  static const double _gutterWidth = 40;
  static const double _editorPadH = 10;
  static const double _editorPadV = 8;
  static const double _caretMargin = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final textFieldWidth = constraints.maxWidth - _gutterWidth;
        final wrapWidth =
            (textFieldWidth - _editorPadH * 2 - _caretMargin).clamp(
              1.0,
              double.infinity,
            );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(right: BorderSide(color: theme.dividerColor)),
              ),
              child: SizedBox(
                width: _gutterWidth,
                child: NotepadLineGutter(
                  controller: controller,
                  scrollController: scrollController,
                  wrapWidth: wrapWidth,
                  textStyle: textStyle,
                  strutStyle: strutStyle,
                  lineHeight: lineHeight,
                  topPadding: _editorPadV,
                  numberStyle: numberStyle,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                scrollController: scrollController,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: textStyle,
                strutStyle: strutStyle,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: textStyle.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: _editorPadH,
                    vertical: _editorPadV,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
