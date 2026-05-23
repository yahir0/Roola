import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:roola/data/file_preview/file_preview_content.dart';
import 'package:roola/data/file_preview/file_preview_repository.dart';
import 'package:roola/ui/explorer/explorer_item_selection.dart';
import 'package:roola/ui/explorer/file_preview/language_detector.dart';

part 'file_preview_view_model.g.dart';

/// Explorer タブごとのファイルプレビュー ViewModel（ADR-0046 / ADR-0027）。
///
/// `explorerItemSelectionProvider(tabId)` の主選択（`primary`）を watch し、
/// ファイルなら [FilePreviewRepository.load] で内容を読み出して
/// [FilePreviewContent] を返す。ディレクトリ / 非選択は null を返す
/// （UI 側で空状態 placeholder を出す）。
///
/// keepAlive はしない。タブを閉じた瞬間に通常の autoDispose で破棄される。
/// 履歴等の状態を持たないため、再選択時に再読込されてもユーザー体感の
/// コストは小さい。
@riverpod
class FilePreviewViewModel extends _$FilePreviewViewModel {
  @override
  Future<FilePreviewContent?> build(String tabId) async {
    final selection = ref.watch(explorerItemSelectionProvider(tabId));
    final primary = selection.primary;
    if (primary == null) return null;

    // `ref` を介するアクセスは async gap 前に終わらせる（gap 中に provider が
    // 再 build されると ref が disposed になり [ref.read] が落ちるため）。
    final repo = ref.read(filePreviewRepositoryProvider);

    // ディレクトリは null（UI 側で空状態 placeholder を出す）。`FileStat` の
    // 結果が `FileSystemEntityType.directory` 以外（file / link / notFound）
    // ならファイル扱いで読み込みを試みる。
    final stat = await FileStat.stat(primary);
    if (stat.type == FileSystemEntityType.directory) return null;
    if (stat.type == FileSystemEntityType.notFound) {
      return FilePreviewContent.failed(
        path: primary,
        message: 'File not found',
      );
    }

    final content = await repo.load(primary);

    // 言語判定は UI 層の責務。Repository が language=null で返したテキストに
    // 対し、ここで `detectLanguage` を当てて更新する。
    if (content is FilePreviewText) {
      final head = content.content.length > 4096
          ? content.content.substring(0, 4096)
          : content.content;
      final language = detectLanguage(primary, head);
      return content.copyWith(language: language);
    }
    // 画像 / PDF は更新時刻を詰める。UI 層が key に織り込み、同じパスのまま
    // 中身が差し替わったファイルを再デコード / 再描画させる（ADR-0050）。
    if (content is FilePreviewImage) {
      return content.copyWith(modified: stat.modified);
    }
    if (content is FilePreviewPdf) {
      return content.copyWith(modified: stat.modified);
    }
    return content;
  }

  /// 現在の主選択を強制的に再読込する。パネル右上のリフレッシュアイコンが
  /// 呼ぶ（ADR-0046 / Decision 8）。
  ///
  /// 画像は Flutter の [ImageCache] がパス（と scale）単位でデコード結果を
  /// 保持するため、`invalidateSelf` だけでは同じパスのまま中身が差し替わった
  /// 画像が古いキャッシュのまま返り続ける（ADR-0050）。再 build の前に該当
  /// エントリをキャッシュから追い出す。
  ///
  /// さらに、`AsyncValue.when` の `skipLoadingOnRefresh` 既定値により再計算中も
  /// `Image` ウィジェットはマウントされ続け、同じパスの `FileImage` を等価と
  /// みなして再解決しない。そのため build() で詰めた更新時刻（`modified`）を
  /// UI 層が `Image` の key に織り込み、リフレッシュ後に key を変えてウィジェット
  /// ごと作り直させる（evict 済みなのでディスクから再デコードされる）。
  Future<void> reload() async {
    final current = state.asData?.value;
    if (current is FilePreviewImage) {
      await FileImage(File(current.path)).evict();
    }
    ref.invalidateSelf();
  }
}
