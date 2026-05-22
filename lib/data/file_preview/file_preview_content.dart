import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_preview_content.freezed.dart';

/// Explorer タブ内の読み取り専用プレビューパネルが扱うファイル内容の状態
/// （ADR-0046 / 画像・PDF は ADR-0050 で追加）。
///
/// 「テキスト / 画像 / PDF / バイナリ / 大きすぎ / 失敗」のケースを sealed
/// union で表す。プレビューパネルはこれらをそれぞれ専用の描画 / placeholder
/// に分岐する。画像・PDF はパスのみを保持し、デコード / レンダリングは
/// UI 層（`Image.file` / pdfrx）に委ねる。
@freezed
sealed class FilePreviewContent with _$FilePreviewContent {
  const FilePreviewContent._();

  /// テキストとして読み出せたファイル。[language] は `flutter_highlight` の
  /// 言語 ID（拡張子 / shebang から判定、未知なら null でプレーンテキスト）。
  /// [isTruncated] が true のとき [content] はファイル先頭の一部だけを含む。
  const factory FilePreviewContent.text({
    required String path,
    required String content,
    required String? language,
    required bool isTruncated,
  }) = FilePreviewText;

  /// 画像ファイル（拡張子で判定）。デコードは UI 層の `Image.file` が行う。
  const factory FilePreviewContent.image({required String path}) =
      FilePreviewImage;

  /// PDF ファイル（拡張子で判定）。レンダリングは UI 層の pdfrx が行う。
  const factory FilePreviewContent.pdf({required String path}) = FilePreviewPdf;

  /// バイナリと判定したファイル（先頭 4 KiB に NUL バイトを含む、または
  /// UTF-8 decode に失敗）。
  const factory FilePreviewContent.binary({required String path}) =
      FilePreviewBinary;

  /// 16 MiB 超で読み込み拒否したファイル。[sizeBytes] は実サイズ。
  const factory FilePreviewContent.tooLarge({
    required String path,
    required int sizeBytes,
  }) = FilePreviewTooLarge;

  /// 読み込みに失敗（権限不足 / 削除済み 等）。[message] はユーザー表示用の
  /// 簡潔なエラーメッセージ。
  const factory FilePreviewContent.failed({
    required String path,
    required String message,
  }) = FilePreviewFailed;

  /// プレビュー領域に実際の内容を描画できる種別か（text / image / pdf）。
  /// バイナリ / 大きすぎ / 失敗は false。選択追従でパネルを自動開閉する
  /// 判定に使う（ADR-0050）。
  bool get isPreviewable =>
      this is FilePreviewText ||
      this is FilePreviewImage ||
      this is FilePreviewPdf;
}
