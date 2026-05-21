import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_preview_content.freezed.dart';

/// Explorer タブ内の読み取り専用プレビューパネルが扱うファイル内容の状態
/// （ADR-0046）。
///
/// 「テキストとして表示できる / バイナリ / 大きすぎ / 失敗」の 4 ケースを
/// sealed union で表す。プレビューパネルはこれらをそれぞれ専用の
/// placeholder に分岐して描画する。
@freezed
sealed class FilePreviewContent with _$FilePreviewContent {
  /// テキストとして読み出せたファイル。[language] は `flutter_highlight` の
  /// 言語 ID（拡張子 / shebang から判定、未知なら null でプレーンテキスト）。
  /// [isTruncated] が true のとき [content] はファイル先頭の一部だけを含む。
  const factory FilePreviewContent.text({
    required String path,
    required String content,
    required String? language,
    required bool isTruncated,
  }) = FilePreviewText;

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
}
