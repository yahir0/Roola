import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/file_preview/file_preview_content.dart';

/// ファイルパスを読み取り [FilePreviewContent] に変換するリポジトリ
/// （ADR-0046）。
///
/// 差し替え可能性は不要（永続化なし・ネイティブ依存なし・OS の `dart:io`
/// だけで完結する）ため interface は作らない（ADR-0006）。テストでは
/// `filePreviewRepositoryProvider` を `overrideWithValue` で差し替える。
///
/// バイナリ判定はファイル先頭 [_sniffBytes] バイトに NUL（`0x00`）を
/// 含むか、または UTF-8 decode に失敗するかで行う。サイズ制限は
/// [_truncateThresholdBytes] / [_rejectThresholdBytes] の 2 段階。
class FilePreviewRepository {
  const FilePreviewRepository();

  /// 先頭 NUL 判定に読むバイト数（4 KiB）。
  static const int _sniffBytes = 4 * 1024;

  /// 読み込み拒否のしきい値（16 MiB）。これを超えるファイルは内容を読まず
  /// `tooLarge` を返す。
  static const int _rejectThresholdBytes = 16 * 1024 * 1024;

  /// 「先頭のみ読む」しきい値（1 MiB）。これを超え、かつ [_rejectThresholdBytes]
  /// 以下のファイルは先頭 1 MiB だけ読み `isTruncated:true` で返す。
  static const int _truncateThresholdBytes = 1 * 1024 * 1024;

  /// [path] のファイルを読み [FilePreviewContent] として返す。
  ///
  /// 言語判定は呼び出し側の責務（UI 層 `language_detector.dart`）。本メソッド
  /// はテキスト判定とサイズ制限のみを担当し、`language` には null を入れて
  /// 返す（呼び出し側で詰める）。
  Future<FilePreviewContent> load(String path) async {
    final file = File(path);
    final int sizeBytes;
    try {
      sizeBytes = await file.length();
    } on FileSystemException catch (e) {
      return FilePreviewContent.failed(path: path, message: e.message);
    }

    if (sizeBytes > _rejectThresholdBytes) {
      return FilePreviewContent.tooLarge(path: path, sizeBytes: sizeBytes);
    }

    // 先頭スニッフ用バイト列。バイナリ判定にも、可能なら本文 decode の
    // ベースにも使う（小さいファイルなら丸ごとここに入る）。
    final List<int> headBytes;
    try {
      final raf = await file.open();
      try {
        final readCount = sizeBytes < _sniffBytes ? sizeBytes : _sniffBytes;
        headBytes = await raf.read(readCount);
      } finally {
        await raf.close();
      }
    } on FileSystemException catch (e) {
      return FilePreviewContent.failed(path: path, message: e.message);
    }

    if (_containsNullByte(headBytes)) {
      return FilePreviewContent.binary(path: path);
    }

    final bool isTruncated;
    final List<int> bodyBytes;
    if (sizeBytes <= _sniffBytes) {
      // 全文がすでに headBytes に入っている。
      isTruncated = false;
      bodyBytes = headBytes;
    } else if (sizeBytes <= _truncateThresholdBytes) {
      // 1 MiB 以下はそのまま全文読む。
      try {
        bodyBytes = await file.readAsBytes();
      } on FileSystemException catch (e) {
        return FilePreviewContent.failed(path: path, message: e.message);
      }
      isTruncated = false;
    } else {
      // 1 MiB 超 16 MiB 以下は先頭 1 MiB だけ読む。
      try {
        final raf = await file.open();
        try {
          bodyBytes = await raf.read(_truncateThresholdBytes);
        } finally {
          await raf.close();
        }
      } on FileSystemException catch (e) {
        return FilePreviewContent.failed(path: path, message: e.message);
      }
      isTruncated = true;
    }

    final String content;
    try {
      // allowMalformed は false。マルチバイト境界の途中で truncate すると
      // 末尾が壊れる可能性はあるが、その場合は decode が失敗するので
      // 安全側に「バイナリ扱い」へ落とす（実用上 1 MiB 内に必ず境界はある）。
      content = utf8.decode(bodyBytes);
    } on FormatException {
      return FilePreviewContent.binary(path: path);
    }

    return FilePreviewContent.text(
      path: path,
      content: content,
      language: null,
      isTruncated: isTruncated,
    );
  }

  /// バイナリ判定: 先頭バイト列に NUL（`0x00`）を含むか。
  static bool _containsNullByte(List<int> bytes) {
    for (final b in bytes) {
      if (b == 0) return true;
    }
    return false;
  }
}

/// リポジトリの DI 用 Provider。`overrideWithValue` でテスト時に差し替える。
final filePreviewRepositoryProvider = Provider<FilePreviewRepository>(
  (ref) => const FilePreviewRepository(),
);
