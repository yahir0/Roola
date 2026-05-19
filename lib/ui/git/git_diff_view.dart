import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/data/git/git_diff.dart';

/// ファイル単位の diff をダイアログで表示する（ADR-0030 / design D6）。
///
/// [load] は diff を取得する非同期処理。unified / split の表示切替に対応する。
Future<void> showGitDiffDialog(
  BuildContext context, {
  required String title,
  required Future<GitDiff> Function() load,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _GitDiffDialog(title: title, load: load),
  );
}

enum _DiffMode { unified, split }

class _GitDiffDialog extends HookWidget {
  const _GitDiffDialog({required this.title, required this.load});

  final String title;
  final Future<GitDiff> Function() load;

  @override
  Widget build(BuildContext context) {
    final mode = useState(_DiffMode.unified);
    final future = useMemoized(load);
    final snapshot = useFuture(future);
    final colors = Theme.of(context).colorScheme;
    final tokens = PolarisTokens.of(context);
    final media = MediaQuery.of(context).size;

    return Dialog(
      child: SizedBox(
        width: media.width * 0.78,
        height: media.height * 0.82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダ帯。
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PolarisTokens.space4,
                PolarisTokens.space2,
                PolarisTokens.space2,
                PolarisTokens.space2,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.difference_outlined,
                    size: PolarisIconSize.standard,
                    color: tokens.textDim,
                  ),
                  const SizedBox(width: PolarisTokens.space2),
                  Expanded(
                    child: Text(
                      title,
                      style: tokens.body.copyWith(color: tokens.text),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SegmentedButton<_DiffMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: _DiffMode.unified,
                        label: Text('Unified'),
                      ),
                      ButtonSegment(
                        value: _DiffMode.split,
                        label: Text('Split'),
                      ),
                    ],
                    selected: {mode.value},
                    onSelectionChanged: (s) => mode.value = s.first,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: PolarisIconSize.standard,
                    ),
                    tooltip: '閉じる',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: tokens.line),
            Expanded(
              child: switch (snapshot.connectionState) {
                ConnectionState.done =>
                  snapshot.hasError
                      ? _DiffMessage(
                          message: _errorText(snapshot.error),
                          color: colors.error,
                        )
                      : _DiffContent(diff: snapshot.data!, mode: mode.value),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _errorText(Object? error) {
    if (error is GitCommandFailure) {
      return error.message;
    }
    return 'diff の取得に失敗しました: $error';
  }
}

class _DiffMessage extends StatelessWidget {
  const _DiffMessage({required this.message, this.color});

  final String message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PolarisTokens.space6),
        child: Text(message, style: TextStyle(color: color)),
      ),
    );
  }
}

class _DiffContent extends StatelessWidget {
  const _DiffContent({required this.diff, required this.mode});

  final GitDiff diff;
  final _DiffMode mode;

  @override
  Widget build(BuildContext context) {
    if (diff.isBinary) {
      return const _DiffMessage(message: 'バイナリファイルのため差分を表示できません');
    }
    if (diff.hasNoChanges) {
      return const _DiffMessage(message: '差分はありません');
    }
    return Scrollbar(
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: mode == _DiffMode.unified
              ? _UnifiedDiff(lines: diff.lines)
              : _SplitDiff(lines: diff.lines),
        ),
      ),
    );
  }
}

/// diff の行配色（Polaris / ADR-0038 D5）。追加行は新規の信号色、削除行は
/// コンフリクトの信号色を淡く敷く。
class _DiffPalette {
  _DiffPalette(BuildContext context)
    : this._(PolarisTokens.of(context), Theme.of(context).colorScheme);

  _DiffPalette._(PolarisTokens tokens, ColorScheme colors)
    : addBg = tokens.signalNew.withValues(alpha: 0.18),
      delBg = tokens.signalConflict.withValues(alpha: 0.18),
      headerBg = colors.surfaceContainerHighest.withValues(alpha: 0.6),
      gutter = colors.onSurfaceVariant;

  final Color addBg;
  final Color delBg;
  final Color headerBg;
  final Color gutter;
}

const TextStyle _monoStyle = TextStyle(
  fontFamily: 'SarasaTermJ',
  fontSize: 13,
  height: 1.35,
);

class _UnifiedDiff extends StatelessWidget {
  const _UnifiedDiff({required this.lines});

  final List<GitDiffLine> lines;

  @override
  Widget build(BuildContext context) {
    final palette = _DiffPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) _UnifiedRow(line: line, palette: palette),
      ],
    );
  }
}

class _UnifiedRow extends StatelessWidget {
  const _UnifiedRow({required this.line, required this.palette});

  final GitDiffLine line;
  final _DiffPalette palette;

  @override
  Widget build(BuildContext context) {
    final (bg, prefix) = switch (line.kind) {
      GitDiffLineKind.addition => (palette.addBg, '+'),
      GitDiffLineKind.deletion => (palette.delBg, '-'),
      GitDiffLineKind.hunkHeader => (palette.headerBg, ''),
      GitDiffLineKind.fileHeader => (palette.headerBg, ''),
      GitDiffLineKind.context => (null as Color?, ' '),
    };
    final isHeader =
        line.kind == GitDiffLineKind.hunkHeader ||
        line.kind == GitDiffLineKind.fileHeader;
    return Container(
      color: bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Gutter(text: _no(line.oldLineNo), color: palette.gutter),
          _Gutter(text: _no(line.newLineNo), color: palette.gutter),
          const SizedBox(width: PolarisTokens.space2),
          Text(
            isHeader ? line.text : '$prefix${line.text}',
            style: _monoStyle.copyWith(
              color: isHeader
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
          const SizedBox(width: PolarisTokens.space4),
        ],
      ),
    );
  }

  static String _no(int? value) => value == null ? '' : '$value';
}

class _Gutter extends StatelessWidget {
  const _Gutter({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      padding: const EdgeInsets.only(right: PolarisTokens.space2, top: 1),
      alignment: Alignment.topRight,
      child: Text(text, style: _monoStyle.copyWith(color: color)),
    );
  }
}

/// 左に旧、右に新を並べる簡易 split。文脈行は両側、追加 / 削除は片側のみ。
class _SplitDiff extends StatelessWidget {
  const _SplitDiff({required this.lines});

  final List<GitDiffLine> lines;

  @override
  Widget build(BuildContext context) {
    final palette = _DiffPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) _SplitRow(line: line, palette: palette),
      ],
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.line, required this.palette});

  final GitDiffLine line;
  final _DiffPalette palette;

  @override
  Widget build(BuildContext context) {
    if (line.kind == GitDiffLineKind.hunkHeader ||
        line.kind == GitDiffLineKind.fileHeader) {
      return Container(
        color: palette.headerBg,
        padding: const EdgeInsets.symmetric(
          horizontal: PolarisTokens.space2,
          vertical: 1,
        ),
        child: Text(
          line.text,
          style: _monoStyle.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    final showLeft =
        line.kind == GitDiffLineKind.context ||
        line.kind == GitDiffLineKind.deletion;
    final showRight =
        line.kind == GitDiffLineKind.context ||
        line.kind == GitDiffLineKind.addition;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SplitCell(
          lineNo: line.oldLineNo,
          text: showLeft ? line.text : null,
          bg: line.kind == GitDiffLineKind.deletion ? palette.delBg : null,
          palette: palette,
        ),
        Container(width: 1, height: 18, color: palette.gutter),
        _SplitCell(
          lineNo: line.newLineNo,
          text: showRight ? line.text : null,
          bg: line.kind == GitDiffLineKind.addition ? palette.addBg : null,
          palette: palette,
        ),
      ],
    );
  }
}

class _SplitCell extends StatelessWidget {
  const _SplitCell({
    required this.lineNo,
    required this.text,
    required this.bg,
    required this.palette,
  });

  final int? lineNo;
  final String? text;
  final Color? bg;
  final _DiffPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 460,
      color: bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Gutter(text: lineNo == null ? '' : '$lineNo', color: palette.gutter),
          const SizedBox(width: PolarisTokens.space1),
          Expanded(child: Text(text ?? '', style: _monoStyle)),
        ],
      ),
    );
  }
}
