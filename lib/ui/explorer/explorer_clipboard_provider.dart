import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// OS のクリップボード（macOS は NSPasteboard）に対してファイル URI の
/// 読み書きを行うサービス。
///
/// super_clipboard 経由で `public.file-url` を扱うため、Finder の「コピー」を
/// アプリ側で「ペースト」したり、その逆も成立する。アプリ内専用の状態は
/// 持たない（OS クリップボードが唯一の真実）。
class OsClipboardService {
  const OsClipboardService();

  /// 単一のファイル / フォルダパスを OS クリップボードに書き込む。
  /// super_clipboard が利用不能なプラットフォームでは何もしない。
  Future<void> writeFile(String path) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return;
    }
    final item = DataWriterItem()
      ..add(Formats.fileUri(Uri.file(path)));
    await clipboard.write([item]);
  }

  /// OS クリップボードに乗っているすべてのファイル URI を絶対パス文字列
  /// として返す。ファイル系の値が無い場合は空リスト。
  Future<List<String>> readFilePaths() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return const [];
    }
    final reader = await clipboard.read();
    final paths = <String>[];
    for (final item in reader.items) {
      if (!item.canProvide(Formats.fileUri)) {
        continue;
      }
      final uri = await item.readValue(Formats.fileUri);
      if (uri != null) {
        paths.add(uri.toFilePath());
      }
    }
    return paths;
  }

  /// OS クリップボードにペースト可能なファイル URI が乗っているか。
  /// 右クリックメニューの「ペースト」項目の表示判定に使う。
  Future<bool> hasFile() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return false;
    }
    final reader = await clipboard.read();
    return reader.canProvide(Formats.fileUri);
  }
}

final osClipboardServiceProvider = Provider<OsClipboardService>(
  (ref) => const OsClipboardService(),
);
