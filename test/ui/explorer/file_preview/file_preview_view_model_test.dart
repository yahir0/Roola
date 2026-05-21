import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/file_preview/file_preview_content.dart';
import 'package:roola/data/file_preview/file_preview_repository.dart';
import 'package:roola/ui/explorer/explorer_item_selection.dart';
import 'package:roola/ui/explorer/file_preview/file_preview_view_model.dart';

/// 呼び出された path を記録し、固定の内容を返す fake。
class _FakeRepository extends FilePreviewRepository {
  const _FakeRepository(this.responses);

  final Map<String, FilePreviewContent> responses;

  @override
  Future<FilePreviewContent> load(String path) async {
    return responses[path] ??
        FilePreviewContent.failed(path: path, message: 'not stubbed');
  }
}

void main() {
  late Directory tempDir;
  late File textFile;
  late Directory subDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_preview_vm_');
    textFile = File('${tempDir.path}/foo.dart')
      ..writeAsStringSync('void main() {}');
    subDir = Directory('${tempDir.path}/sub')..createSync();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  ProviderContainer makeContainer({
    Map<String, FilePreviewContent>? responses,
  }) {
    final stubbed = responses ??
        {
          textFile.path: FilePreviewContent.text(
            path: textFile.path,
            content: 'void main() {}',
            language: null,
            isTruncated: false,
          ),
        };
    final container = ProviderContainer(
      overrides: [
        filePreviewRepositoryProvider.overrideWithValue(
          _FakeRepository(stubbed),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('主選択が空のときは null を返す', () async {
    final container = makeContainer();
    final value = await container.read(
      filePreviewViewModelProvider('tab-1').future,
    );
    expect(value, isNull);
  });

  test('主選択がディレクトリのときは null を返す（読み込みは走らない）', () async {
    final container = makeContainer(
      responses: {
        subDir.path: FilePreviewContent.text(
          path: subDir.path,
          content: 'should not be returned',
          language: null,
          isTruncated: false,
        ),
      },
    );
    container.read(explorerItemSelectionProvider('tab-1').notifier).select(
      subDir.path,
    );

    final value = await container.read(
      filePreviewViewModelProvider('tab-1').future,
    );

    expect(value, isNull);
  });

  test('主選択がファイルのとき repository.load を呼んで結果を返す', () async {
    final container = makeContainer();
    container.read(explorerItemSelectionProvider('tab-1').notifier).select(
      textFile.path,
    );

    final value = await container.read(
      filePreviewViewModelProvider('tab-1').future,
    );

    expect(value, isA<FilePreviewText>());
    expect((value as FilePreviewText).path, textFile.path);
    // 言語判定が当たって `dart` が詰められている。
    expect(value.language, 'dart');
  });

  test('reload() で再取得される', () async {
    final container = makeContainer();
    container.read(explorerItemSelectionProvider('tab-1').notifier).select(
      textFile.path,
    );

    // `.future` を read だけしてしまうと subscription が即切れて autoDispose
    // が走り、reload 後の再 build と subscribe のタイミングがずれて null が
    // 返ってしまうため、listen を貼って provider を生存させたまま検証する。
    final sub = container.listen(
      filePreviewViewModelProvider('tab-1'),
      (_, _) {},
    );
    addTearDown(sub.close);

    await container.read(filePreviewViewModelProvider('tab-1').future);

    // reload は invalidateSelf を呼ぶ → 次の read で再 build される。
    await container
        .read(filePreviewViewModelProvider('tab-1').notifier)
        .reload();
    final next = await container.read(
      filePreviewViewModelProvider('tab-1').future,
    );

    expect(next, isA<FilePreviewText>());
  });

  test('別タブの主選択は独立している（family の分離）', () async {
    final container = makeContainer();
    container.read(explorerItemSelectionProvider('tab-A').notifier).select(
      textFile.path,
    );

    final a = await container.read(
      filePreviewViewModelProvider('tab-A').future,
    );
    final b = await container.read(
      filePreviewViewModelProvider('tab-B').future,
    );

    expect(a, isA<FilePreviewText>());
    expect(b, isNull, reason: 'tab-B の主選択は未設定なので null');
  });
}
