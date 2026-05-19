import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/l10n/app_localizations.dart';

import 'notepad_line_gutter.dart';
import 'notepad_view_model.dart';

/// ターミナル横（ワークスペース右下）に重ねて表示するノートパッド
/// パネル（ADR-0036）。
///
/// ちょっとしたメモ書き用途に割り切った最小構成。本文入力・標準の編集系
/// ショートカット（`TextField` 既定）・左端の行番号ルーラのみを持ち、
/// txt 書き出し等の機能は持たない。本文は [notepadProvider] が保持し、
/// 入力のたびに永続化される。
class NotepadPanel extends HookConsumerWidget {
  const NotepadPanel({required this.onClose, super.key});

  /// ヘッダの閉じるボタンが押されたときの動作。
  final VoidCallback onClose;

  /// 本文と行番号で共有するテキストメトリクス。
  static const double _fontSize = 14;
  static const double _lineHeightFactor = 1.5;
  static const double _lineHeight = _fontSize * _lineHeightFactor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);

    final controller = useTextEditingController(
      text: ref.read(notepadProvider),
    );
    final scrollController = useScrollController();

    useEffect(() {
      void listener() {
        ref.read(notepadProvider.notifier).updateContent(controller.text);
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

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

    return Material(
      // フローティングパネル（ADR-0036）。Polaris は影を抑えるため
      // elevation は最小限にとどめ、分離は 1px ボーダーで示す（ADR-0038 D3）。
      elevation: 4,
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      child: SizedBox(
        width: 380,
        height: 320,
        child: Column(
          children: [
            _NotepadHeader(title: l10n.notepadTitle, onClose: onClose),
            Divider(height: 1, thickness: 1, color: theme.dividerColor),
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
        ),
      ),
    );
  }
}

/// パネル上部のタイトルバー（タイトル + 閉じるボタン）。
class _NotepadHeader extends StatelessWidget {
  const _NotepadHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 36,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.only(
        left: PolarisTokens.space3,
        right: PolarisTokens.space1,
      ),
      child: Row(
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: PolarisIconSize.standard,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: PolarisTokens.space2),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.labelLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: PolarisIconSize.standard),
            tooltip: AppLocalizations.of(context).buttonClose,
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// 行番号ルーラと本文入力欄を横並びにした編集領域。
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

  /// `RenderEditable` は本文の折り返し可能幅からキャレット余白
  /// （`_kCaretGap` 1px + `cursorWidth` 2px）を差し引く。ルーラ側の
  /// 折り返し計算をこれに合わせて番号位置のずれを防ぐ。
  static const double _caretMargin = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final textFieldWidth = constraints.maxWidth - _gutterWidth;
        final wrapWidth = (textFieldWidth - _editorPadH * 2 - _caretMargin)
            .clamp(1.0, double.infinity);
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
