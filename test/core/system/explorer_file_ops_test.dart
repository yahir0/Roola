import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/system/explorer_file_ops.dart';

void main() {
  late Directory tempDir;
  const ops = ExplorerFileOps();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_fileops_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('createDirectory', () {
    test('creates a new directory under parentPath', () async {
      await ops.createDirectory(tempDir.path, 'newDir');
      expect(Directory('${tempDir.path}/newDir').existsSync(), isTrue);
    });

    test('throws when target already exists', () async {
      await Directory('${tempDir.path}/dup').create();
      expect(
        () => ops.createDirectory(tempDir.path, 'dup'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('createFile', () {
    test('creates an empty file under parentPath', () async {
      await ops.createFile(tempDir.path, 'note.txt');
      final f = File('${tempDir.path}/note.txt');
      expect(f.existsSync(), isTrue);
      expect(f.lengthSync(), 0);
    });

    test('throws when file path already exists as file', () async {
      await File('${tempDir.path}/a.txt').writeAsString('x');
      expect(
        () => ops.createFile(tempDir.path, 'a.txt'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws when path already exists as directory', () async {
      await Directory('${tempDir.path}/dir').create();
      expect(
        () => ops.createFile(tempDir.path, 'dir'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('rename', () {
    test('renames a file in the same parent', () async {
      final src = '${tempDir.path}/old.txt';
      await File(src).writeAsString('hello');
      await ops.rename(src, 'new.txt');
      expect(File(src).existsSync(), isFalse);
      expect(File('${tempDir.path}/new.txt').existsSync(), isTrue);
    });

    test('renames a directory', () async {
      final src = '${tempDir.path}/old';
      await Directory(src).create();
      await ops.rename(src, 'new');
      expect(Directory(src).existsSync(), isFalse);
      expect(Directory('${tempDir.path}/new').existsSync(), isTrue);
    });

    test('no-op when name does not change', () async {
      final src = '${tempDir.path}/same.txt';
      await File(src).writeAsString('x');
      await ops.rename(src, 'same.txt');
      expect(File(src).existsSync(), isTrue);
    });

    test('throws when target path already exists', () async {
      await File('${tempDir.path}/a.txt').writeAsString('a');
      await File('${tempDir.path}/b.txt').writeAsString('b');
      expect(
        () => ops.rename('${tempDir.path}/a.txt', 'b.txt'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws when source does not exist', () async {
      expect(
        () => ops.rename('${tempDir.path}/ghost', 'foo'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('moveInto', () {
    test('moves a file into a sibling directory', () async {
      await File('${tempDir.path}/note.txt').writeAsString('hi');
      await Directory('${tempDir.path}/dest').create();
      await ops.moveInto('${tempDir.path}/note.txt', '${tempDir.path}/dest');
      expect(File('${tempDir.path}/note.txt').existsSync(), isFalse);
      expect(File('${tempDir.path}/dest/note.txt').existsSync(), isTrue);
    });

    test('moves a directory into a sibling directory', () async {
      await Directory('${tempDir.path}/src').create();
      await File('${tempDir.path}/src/inside.txt').writeAsString('x');
      await Directory('${tempDir.path}/dest').create();
      await ops.moveInto('${tempDir.path}/src', '${tempDir.path}/dest');
      expect(Directory('${tempDir.path}/src').existsSync(), isFalse);
      expect(File('${tempDir.path}/dest/src/inside.txt').existsSync(), isTrue);
    });

    test('throws when target already has same-named entry', () async {
      await File('${tempDir.path}/a.txt').writeAsString('a');
      await Directory('${tempDir.path}/dest').create();
      await File('${tempDir.path}/dest/a.txt').writeAsString('existing');
      expect(
        () => ops.moveInto('${tempDir.path}/a.txt', '${tempDir.path}/dest'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws when moving directory into itself', () async {
      await Directory('${tempDir.path}/box').create();
      expect(
        () => ops.moveInto('${tempDir.path}/box', '${tempDir.path}/box'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws when moving directory into its descendant', () async {
      await Directory('${tempDir.path}/parent/child').create(recursive: true);
      expect(
        () => ops.moveInto(
          '${tempDir.path}/parent',
          '${tempDir.path}/parent/child',
        ),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('no-op when moving to current parent (same directory)', () async {
      final src = '${tempDir.path}/file.txt';
      await File(src).writeAsString('x');
      // 親に対する move なので何も起きない。
      await ops.moveInto(src, tempDir.path);
      expect(File(src).existsSync(), isTrue);
    });
  });

  group('copyInto', () {
    test('copies a file into a sibling directory', () async {
      await File('${tempDir.path}/note.txt').writeAsString('hi');
      await Directory('${tempDir.path}/dest').create();
      await ops.copyInto('${tempDir.path}/note.txt', '${tempDir.path}/dest');
      // ソースは残り、コピーが作られる。
      expect(File('${tempDir.path}/note.txt').existsSync(), isTrue);
      expect(File('${tempDir.path}/dest/note.txt').existsSync(), isTrue);
      expect(File('${tempDir.path}/dest/note.txt').readAsStringSync(), 'hi');
    });

    test('copies a directory recursively', () async {
      await Directory('${tempDir.path}/src/inner').create(recursive: true);
      await File('${tempDir.path}/src/a.txt').writeAsString('a');
      await File('${tempDir.path}/src/inner/b.txt').writeAsString('b');
      await Directory('${tempDir.path}/dest').create();
      await ops.copyInto('${tempDir.path}/src', '${tempDir.path}/dest');
      // 元は残り、再帰コピーされる。
      expect(File('${tempDir.path}/src/a.txt').existsSync(), isTrue);
      expect(File('${tempDir.path}/dest/src/a.txt').existsSync(), isTrue);
      expect(File('${tempDir.path}/dest/src/inner/b.txt').existsSync(), isTrue);
    });

    test('throws when target already has same-named entry', () async {
      await File('${tempDir.path}/a.txt').writeAsString('a');
      await Directory('${tempDir.path}/dest').create();
      await File('${tempDir.path}/dest/a.txt').writeAsString('existing');
      expect(
        () => ops.copyInto('${tempDir.path}/a.txt', '${tempDir.path}/dest'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws when copying directory into itself', () async {
      await Directory('${tempDir.path}/box').create();
      expect(
        () => ops.copyInto('${tempDir.path}/box', '${tempDir.path}/box'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws when copying directory into its descendant', () async {
      await Directory('${tempDir.path}/parent/child').create(recursive: true);
      expect(
        () => ops.copyInto(
          '${tempDir.path}/parent',
          '${tempDir.path}/parent/child',
        ),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws when source does not exist', () async {
      await Directory('${tempDir.path}/dest').create();
      expect(
        () => ops.copyInto('${tempDir.path}/ghost', '${tempDir.path}/dest'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
