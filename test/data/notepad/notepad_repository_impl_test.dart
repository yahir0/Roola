import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/notepad/notepad_repository_impl.dart';

void main() {
  late Directory tempDir;
  late NotepadRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_notepad_');
    repo = NotepadRepositoryImpl(paths: AppPaths(root: tempDir));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('load returns empty string when file does not exist', () async {
    expect(await repo.load(), '');
  });

  test('save then load round-trips multi-line content', () async {
    await repo.save('hello\nworld\n123');
    expect(await repo.load(), 'hello\nworld\n123');
  });

  test('save then load round-trips empty content', () async {
    await repo.save('');
    expect(await repo.load(), '');
  });

  test('load returns empty string for malformed JSON', () async {
    await AppPaths(root: tempDir).ensureDirectories();
    await File('${tempDir.path}/notepad.json').writeAsString('not json');
    expect(await repo.load(), '');
  });

  test('load returns empty string when content key is missing', () async {
    await AppPaths(root: tempDir).ensureDirectories();
    await File('${tempDir.path}/notepad.json').writeAsString('{"other": 1}');
    expect(await repo.load(), '');
  });

  test('load returns empty string when content is not a string', () async {
    await AppPaths(root: tempDir).ensureDirectories();
    await File('${tempDir.path}/notepad.json').writeAsString('{"content": 42}');
    expect(await repo.load(), '');
  });
}
