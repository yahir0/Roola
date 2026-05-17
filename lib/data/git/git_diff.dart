import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_diff.freezed.dart';

/// diff 1 行の種別。
enum GitDiffLineKind {
  /// 文脈行（変更なし）。
  context,

  /// 追加行（`+`）。
  addition,

  /// 削除行（`-`）。
  deletion,

  /// ハンクヘッダ（`@@ ... @@`）。
  hunkHeader,

  /// ファイルヘッダ（`diff --git` / `index` / `+++` / `---`）。
  fileHeader,
}

/// diff の 1 行。
@freezed
abstract class GitDiffLine with _$GitDiffLine {
  const factory GitDiffLine({
    required GitDiffLineKind kind,

    /// 行頭の `+` / `-` / 空白を除いた本文。
    required String text,

    /// 旧ファイル側の行番号。追加行・ヘッダでは `null`。
    int? oldLineNo,

    /// 新ファイル側の行番号。削除行・ヘッダでは `null`。
    int? newLineNo,
  }) = _GitDiffLine;
}

/// ファイル 1 つ分の diff。
@freezed
abstract class GitDiff with _$GitDiff {
  const factory GitDiff({
    /// 対象ファイルのリポジトリルート相対パス。
    required String path,

    /// unified diff をパースした行列。
    required List<GitDiffLine> lines,

    /// バイナリファイルで差分行が出せない場合 `true`。
    @Default(false) bool isBinary,
  }) = _GitDiff;

  const GitDiff._();

  /// 差分が空（変更なし）か。
  bool get hasNoChanges => lines.isEmpty && !isBinary;
}
