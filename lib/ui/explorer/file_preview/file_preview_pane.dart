import 'dart:io';

import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/file_preview/file_preview_content.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/explorer/file_preview/file_preview_view_model.dart';
import 'package:roola/ui/explorer/file_preview/polaris_highlight_theme.dart';

/// Explorer タブ右ペインのファイルプレビュー（ADR-0046）。
///
/// 主選択ファイルを `highlight` パッケージでシンタックスハイライト表示する
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
      FilePreviewImage() => _ImageBody(path: c.path, modified: c.modified),
      FilePreviewPdf() => _PdfBody(path: c.path, modified: c.modified),
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

/// テキスト本体。`highlight` パッケージで構文解析した結果を Polaris テーマで
/// [Text.rich] として描画する。truncate された場合は上部にバナーを表示する。
///
/// flutter_highlight の `HighlightView` は内部で生の [RichText] を使うため
/// 祖先の [SelectionArea] に選択対象として登録されず、テキスト選択 / コピーが
/// できない。ここでは同じハイライト結果を [Text.rich] で描画することで
/// [SelectionArea] 経由のドラッグ選択・⌘C コピーを有効にする。
class _TextBody extends StatelessWidget {
  const _TextBody({required this.content});

  final FilePreviewText content;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = polarisHighlightTheme(tokens);
    // ベース（root）の色は theme['root'] から、フォントは mono を使う。地色は
    // 親の計器ディスプレイ（well）に任せるため塗らない。
    final baseStyle = tokens.mono.copyWith(color: theme['root']?.color);
    final spans = _highlightSpans(
      content.content,
      // 言語未判定（プレーンテキスト）は空文字を渡す。`highlight.parse` は
      // 未登録言語を plaintext にフォールバックするため素通しで描画される。
      content.language ?? '',
      theme,
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
          child: SelectionArea(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(PolarisTokens.space3),
                    child: Text.rich(
                      TextSpan(style: baseStyle, children: spans),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// `highlight` パッケージの構文木（[Node]）を Polaris テーマ付きの [TextSpan]
/// 列へ変換する。flutter_highlight の `HighlightView._convert` と同じ走査だが、
/// 描画先を [Text.rich]（選択可能）にするために自前で持つ。
List<TextSpan> _highlightSpans(
  String source,
  String language,
  Map<String, TextStyle> theme,
) {
  final nodes = highlight.parse(source, language: language).nodes ?? const [];
  final spans = <TextSpan>[];
  var currentSpans = spans;
  final stack = <List<TextSpan>>[];

  void traverse(Node node) {
    if (node.value != null) {
      currentSpans.add(
        node.className == null
            ? TextSpan(text: node.value)
            : TextSpan(text: node.value, style: theme[node.className!]),
      );
    } else if (node.children != null) {
      final children = <TextSpan>[];
      currentSpans.add(
        TextSpan(children: children, style: theme[node.className!]),
      );
      stack.add(currentSpans);
      currentSpans = children;
      for (final child in node.children!) {
        traverse(child);
        if (child == node.children!.last) {
          currentSpans = stack.isEmpty ? spans : stack.removeLast();
        }
      }
    }
  }

  for (final node in nodes) {
    traverse(node);
  }
  return spans;
}

/// 画像本体（ADR-0050）。`Image.file` をピンチ / ドラッグでパン・ズーム
/// できる [InteractiveViewer] に載せ、地（`well`）の中央に contain で置く。
/// デコードに失敗したら（破損 / 未対応エンコード）エラー placeholder を出す。
class _ImageBody extends StatelessWidget {
  const _ImageBody({required this.path, this.modified});

  final String path;

  /// ファイルの最終更新時刻（ADR-0050）。`Image` の key に織り込み、同じパス
  /// のまま中身が差し替わった画像をリフレッシュ後に再デコードさせる。
  final DateTime? modified;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(PolarisTokens.space2),
      child: InteractiveViewer(
        maxScale: 8,
        child: Center(
          // filterQuality は Image 既定（medium）のまま。拡大時の補間で
          // 輪郭が過度に滲まない品質。
          child: Image.file(
            File(path),
            // パス + 更新時刻を key にし、内容差し替え時にウィジェットごと
            // 作り直して（evict 済みキャッシュを介さず）再デコードさせる。
            key: ValueKey('$path|${modified?.microsecondsSinceEpoch ?? 0}'),
            errorBuilder: (context, error, stackTrace) => _MessagePlaceholder(
              icon: Icons.broken_image_outlined,
              message: l10n.filePreviewImageError,
            ),
          ),
        ),
      ),
    );
  }
}

/// PDF 本体（ADR-0050）。pdfrx の [PdfViewer] で読み取り専用表示する
/// （スクロール / ズーム / テキスト選択は pdfrx 既定の挙動）。地色は
/// Polaris の `well` に合わせる。読み込み失敗時はエラー placeholder を出す。
class _PdfBody extends StatelessWidget {
  const _PdfBody({required this.path, this.modified});

  final String path;

  /// ファイルの最終更新時刻（ADR-0050）。key に織り込み、同じパスのまま
  /// 中身が差し替わった PDF をリフレッシュ後に再描画させる。
  final DateTime? modified;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    return PdfViewer.file(
      path,
      // パス + 更新時刻を key にする。同じパスの再選択ではビューアを作り直さず、
      // 内容が差し替わった（更新時刻が変わった）ときだけ作り直す。
      key: ValueKey('$path|${modified?.microsecondsSinceEpoch ?? 0}'),
      params: PdfViewerParams(
        backgroundColor: tokens.well,
        loadingBannerBuilder: (context, bytesDownloaded, totalBytes) =>
            const _LoadingPlaceholder(),
        errorBannerBuilder: (context, error, stackTrace, documentRef) =>
            _MessagePlaceholder(
              icon: Icons.picture_as_pdf_outlined,
              message: l10n.filePreviewPdfError,
            ),
      ),
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
