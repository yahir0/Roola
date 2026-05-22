import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/file_preview/file_preview_content.dart';
import 'package:roola/data/file_preview/file_preview_repository.dart';

void main() {
  const repo = FilePreviewRepository();
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_preview_test_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  File makeFile(String name, List<int> bytes) {
    final f = File('${tempDir.path}/$name');
    f.writeAsBytesSync(bytes);
    return f;
  }

  test('画像拡張子は内容を読まず FilePreviewImage を返す（ADR-0050）', () async {
    // 中身はテキストでも拡張子で画像と判定する（デコードは UI 層責務）。
    final f = makeFile('photo.PNG', 'not really a png'.codeUnits);

    final content = await repo.load(f.path);

    expect(content, isA<FilePreviewImage>());
    expect((content as FilePreviewImage).path, f.path);
  });

  test('jpg / jpeg / gif / webp / bmp も FilePreviewImage', () async {
    for (final name in ['a.jpg', 'b.jpeg', 'c.gif', 'd.webp', 'e.bmp']) {
      final f = makeFile(name, [0x00, 0x01]);
      expect(await repo.load(f.path), isA<FilePreviewImage>(), reason: name);
    }
  });

  test('pdf 拡張子は FilePreviewPdf を返す（ADR-0050）', () async {
    final f = makeFile('doc.pdf', 'not really a pdf'.codeUnits);

    final content = await repo.load(f.path);

    expect(content, isA<FilePreviewPdf>());
    expect((content as FilePreviewPdf).path, f.path);
  });

  test('テキストファイルは FilePreviewText を返し isTruncated:false', () async {
    final f = makeFile('hello.txt', 'hello world\nline 2\n'.codeUnits);

    final content = await repo.load(f.path);

    expect(content, isA<FilePreviewText>());
    final text = content as FilePreviewText;
    expect(text.content, 'hello world\nline 2\n');
    expect(text.isTruncated, isFalse);
    expect(text.language, isNull, reason: 'language 判定は呼び出し側責務');
  });

  test('先頭に NUL を含むファイルは FilePreviewBinary', () async {
    final f = makeFile('blob.bin', [0x48, 0x00, 0x65, 0x6C, 0x6C, 0x6F]);

    final content = await repo.load(f.path);

    expect(content, isA<FilePreviewBinary>());
  });

  test('UTF-8 decode に失敗するバイト列も FilePreviewBinary', () async {
    // 不正な UTF-8 列（先頭 NUL は含まない）
    final f = makeFile('garbage.bin', [0xC3, 0x28, 0xA0, 0xA1, 0xFF]);

    final content = await repo.load(f.path);

    expect(content, isA<FilePreviewBinary>());
  });

  test('1 MiB 超 16 MiB 以下は isTruncated:true', () async {
    // 1.5 MiB のテキスト（'a' の繰り返し）
    final bigText = List<int>.filled(1024 * 1024 + 100 * 1024, 0x61);
    final f = makeFile('big.txt', bigText);

    final content = await repo.load(f.path);

    expect(content, isA<FilePreviewText>());
    final text = content as FilePreviewText;
    expect(text.isTruncated, isTrue);
    expect(text.content.length, 1024 * 1024);
  });

  test('16 MiB 超は FilePreviewTooLarge', () async {
    // 真に 16 MiB 超のファイルを作る代わりに sparse 風に書く。
    // 単純に 17 MiB の 'a' を書く（テスト時間に問題ない程度）。
    final tooBig = Uint8List(17 * 1024 * 1024)
      ..fillRange(0, 17 * 1024 * 1024, 0x61);
    final f = makeFile('huge.txt', tooBig);

    final content = await repo.load(f.path);

    expect(content, isA<FilePreviewTooLarge>());
    final big = content as FilePreviewTooLarge;
    expect(big.sizeBytes, greaterThan(16 * 1024 * 1024));
  });

  test('存在しないパスは FilePreviewFailed', () async {
    final content = await repo.load('${tempDir.path}/does_not_exist.txt');

    expect(content, isA<FilePreviewFailed>());
  });
}
