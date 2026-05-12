import 'dart:io';

import 'package:image/image.dart' as img;

/// アイコン画像を保存可能な PNG に整える処理。
///
/// 入力画像（PNG / JPEG など）を最大 512px の正方形にリサイズし、
/// 指定の出力ファイルに PNG として書き出す。
class IconImageProcessor {
  const IconImageProcessor({this.maxSize = 512});

  /// 出力する正方形の最大辺長（ピクセル）。
  final int maxSize;

  /// [sourceFile] を読み、[destination] に PNG として保存する。
  ///
  /// アスペクト比は保ち、長辺が [maxSize] を超える場合のみ縮小する。
  /// デコードできなければ [FormatException] を投げる。
  Future<void> resizeAndSave(File sourceFile, File destination) async {
    final bytes = await sourceFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Unsupported image format');
    }
    final longest = decoded.width > decoded.height ? decoded.width : decoded.height;
    final resized = longest > maxSize
        ? img.copyResize(
            decoded,
            width: decoded.width > decoded.height ? maxSize : null,
            height: decoded.height >= decoded.width ? maxSize : null,
          )
        : decoded;
    final destinationDir = destination.parent;
    if (!destinationDir.existsSync()) {
      await destinationDir.create(recursive: true);
    }
    await destination.writeAsBytes(img.encodePng(resized), flush: true);
  }
}
