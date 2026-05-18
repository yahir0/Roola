import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/data/keybindings/keybindings.dart';
import 'package:roola/data/keybindings/keybindings_repository_impl.dart';

void main() {
  late Directory tempDir;
  late KeybindingsRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_kb_');
    repo = KeybindingsRepositoryImpl(paths: AppPaths(root: tempDir));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ファイルが無いときは空を返す', () async {
    final loaded = await repo.load();
    expect(loaded.overrides, isEmpty);
  });

  test('save した上書きを load で復元できる', () async {
    final keybindings = Keybindings(
      overrides: {
        CommandId.copyPath: KeyChord(
          triggerKeyId: LogicalKeyboardKey.keyP.keyId,
          meta: true,
          alt: true,
        ),
      },
    );
    await repo.save(keybindings);
    final loaded = await repo.load();
    expect(loaded, keybindings);
  });

  test('壊れた JSON のときは空を返す', () async {
    await AppPaths(root: tempDir).ensureDirectories();
    await File('${tempDir.path}/keybindings.json').writeAsString('not json');
    final loaded = await repo.load();
    expect(loaded.overrides, isEmpty);
  });

  test('空ファイルのときは空を返す', () async {
    await AppPaths(root: tempDir).ensureDirectories();
    await File('${tempDir.path}/keybindings.json').writeAsString('   ');
    final loaded = await repo.load();
    expect(loaded.overrides, isEmpty);
  });
}
