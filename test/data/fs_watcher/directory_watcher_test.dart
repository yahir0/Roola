import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/fs_watcher/directory_watcher.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_dirwatch_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('購読中にファイル追加するとデバウンス後に 1 回イベントが流れる', () async {
    const watcher = DirectoryWatcher();
    final events = <void>[];
    final sub = watcher
        .watch(tempDir.path, debounce: const Duration(milliseconds: 100))
        .listen(events.add);
    addTearDown(sub.cancel);

    // 監視開始直後は FSEvents 配信前なので少しだけ待つ。
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final file = File('${tempDir.path}/a.txt');
    await file.writeAsString('hello');

    // 連続変更を 1 回にまとめる。
    await file.writeAsString('hello world');
    await file.writeAsString('hello world 2');

    // debounce + 余裕を取って待つ。
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(events, hasLength(1));
  });

  test('exclude にマッチするパス変更だけならイベントは流れない', () async {
    // 監視ルート自身の MODIFY イベント（FSEvents は ルート に対しても
    // 変更通知を出す）も exclude の対象にして、ignored/ 配下の純粋な動作を
    // 検証する。
    await Directory('${tempDir.path}/ignored').create();

    const watcher = DirectoryWatcher();
    final relativePaths = <String>[];
    final events = <void>[];
    final sub = watcher
        .watch(
          tempDir.path,
          debounce: const Duration(milliseconds: 100),
          recursive: true,
          exclude: (rel) {
            relativePaths.add(rel);
            return rel.isEmpty ||
                rel == 'ignored' ||
                rel.startsWith('ignored/');
          },
        )
        .listen(events.add);
    addTearDown(sub.cancel);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await File('${tempDir.path}/ignored/a.txt').writeAsString('x');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // exclude callback は ignored 配下の相対パスを受け取っている。
    expect(
      relativePaths.any((p) => p.startsWith('ignored/') || p == 'ignored'),
      isTrue,
    );
    // FSEvents の挙動が CI / マシンによって揺れるため、ノイズを debug 出力。
    expect(events, isEmpty, reason: 'paths seen: $relativePaths');

    // exclude にマッチしないパス（b.txt）を変更するとイベントが流れる。
    await File('${tempDir.path}/b.txt').writeAsString('x');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(events, hasLength(1));
  });

  test('存在しないパスを watch すると Stream は即座に閉じる', () async {
    const watcher = DirectoryWatcher();
    final completer = Completer<void>();
    final sub = watcher
        .watch('${tempDir.path}/does_not_exist')
        .listen((_) {}, onDone: completer.complete);
    addTearDown(sub.cancel);
    await completer.future.timeout(const Duration(seconds: 1));
  });
}
