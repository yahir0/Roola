import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/file_preview/file_preview_content.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/explorer/file_preview/file_preview_view_model.dart';
import 'package:roola/ui/explorer/file_preview/polaris_highlight_theme.dart';

/// Explorer タブ右ペインのファイルプレビュー（ADR-0046）。
///
/// 主選択ファイルを `flutter_highlight` でシンタックスハイライト表示する
/// 読み取り専用ビュー。バイナリ / 大きすぎ / 失敗のケースはそれぞれ専用の
/// placeholder を出す。`PolarisDisplayPanel` の中に置く前提で、地色は
/// 親（`well`）に任せ、本 Widget では塗らない。
class FilePreviewPane extends ConsumerWidget {
  const FilePreviewPane({super.key, required this.tabId});

  /// 自タブ id（ADR-0027 / family）。
  final String tabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    final asyncContent = ref.watch(filePreviewViewModelProvider(tabId));
    return Column(
      children: [
        _PreviewHeader(tabId: tabId),
        Container(height: 1, color: tokens.line),
        Expanded(
          child: asyncContent.when(
            data: (content) => _PreviewBody(content: content),
            loading: () => const _LoadingPlaceholder(),
            error: (e, _) => _MessagePlaceholder(
              icon: Icons.error_outline_rounded,
              message: e.toString(),
            ),
          ),
        ),
      ],
    );
  }
}

/// プレビューパネル内側ヘッダ。タイトルとリフレッシュアイコンを並べる。
class _PreviewHeader extends ConsumerWidget {
  const _PreviewHeader({required this.tabId});

  final String tabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space3,
        PolarisTokens.space1,
        PolarisTokens.space2,
        PolarisTokens.space1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.filePreviewTitle,
              style: tokens.label.copyWith(color: tokens.textFaint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              size: PolarisIconSize.small,
            ),
            tooltip: l10n.filePreviewRefreshTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 24, height: 24),
            onPressed: () =>
                ref.read(filePreviewViewModelProvider(tabId).notifier).reload(),
          ),
        ],
      ),
    );
  }
}

/// プレビュー本体。`FilePreviewContent` の sealed 分岐で描画を切替える。
class _PreviewBody extends StatelessWidget {
  const _PreviewBody({required this.content});

  final FilePreviewContent? content;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = content;
    if (c == null) {
      return _MessagePlaceholder(
        icon: Icons.description_outlined,
        message: l10n.filePreviewEmpty,
      );
    }
    return switch (c) {
      FilePreviewText() => _TextBody(content: c),
      FilePreviewBinary() => _MessagePlaceholder(
        icon: Icons.data_object_rounded,
        message: l10n.filePreviewBinary,
      ),
      FilePreviewTooLarge() => _MessagePlaceholder(
        icon: Icons.warning_amber_rounded,
        message: l10n.filePreviewTooLarge(_formatBytes(c.sizeBytes)),
      ),
      FilePreviewFailed() => _MessagePlaceholder(
        icon: Icons.error_outline_rounded,
        message: l10n.filePreviewFailed(c.message),
      ),
    };
  }
}

/// テキスト本体。`flutter_highlight` の [HighlightView] に Polaris テーマを
/// 渡して描画する。truncate された場合は上部にバナーを表示する。
class _TextBody extends StatelessWidget {
  const _TextBody({required this.content});

  final FilePreviewText content;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = polarisHighlightTheme(tokens);
    final highlight = HighlightView(
      content.content,
      // 言語未判定（プレーンテキスト）は HighlightView がそのまま素通しで
      // 描画するよう空文字を渡す（`'plaintext'` でも同じ挙動だが、明示的
      // にスタイルなしを意図して空にする）。
      language: content.language ?? '',
      theme: theme,
      padding: const EdgeInsets.all(PolarisTokens.space3),
      textStyle: tokens.mono,
    );
    return Column(
      children: [
        if (content.isTruncated)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: PolarisTokens.space3,
              vertical: PolarisTokens.space1,
            ),
            color: tokens.surface,
            child: Text(
              l10n.filePreviewTruncated,
              style: tokens.meta.copyWith(color: tokens.textDim),
            ),
          ),
        if (content.isTruncated) Container(height: 1, color: tokens.line),
        Expanded(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectionArea(child: highlight),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// アイコン + 1 行メッセージのプレースホルダ。
class _MessagePlaceholder extends StatelessWidget {
  const _MessagePlaceholder({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PolarisTokens.space4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: PolarisIconSize.hero, color: tokens.textFaint),
            const SizedBox(height: PolarisTokens.space3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tokens.meta.copyWith(color: tokens.textDim),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// バイト数を簡潔に整形（KB / MB の整数 + 単位 1 文字）。プレビューパネルの
/// メッセージ表示用なので厳密でなくてよい。
String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).round()} MB';
}
