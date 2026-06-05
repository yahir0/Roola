import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/file_preview/file_preview_content.dart';
import 'package:roola/data/file_preview/file_preview_repository.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/explorer/explorer_item_selection.dart';
import 'package:roola/ui/explorer/file_preview/file_preview_pane.dart';
import 'package:roola/ui/explorer/file_preview/file_preview_view_model.dart';

/// 固定の内容を返す fake repository。
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

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('roola_preview_pane_');
    textFile = File('${tempDir.path}/foo.dart')
      ..writeAsStringSync('void main() {}');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget app() {
    return ProviderScope(
      overrides: [
        filePreviewRepositoryProvider.overrideWithValue(
          _FakeRepository({
            textFile.path: FilePreviewContent.text(
              path: textFile.path,
              content: 'void main() {}',
              language: null,
              isTruncated: false,
            ),
          }),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ja'),
        home: Scaffold(body: FilePreviewPane(tabId: 'tab-1')),
      ),
    );
  }

  testWidgets('テキストプレビューは SelectionArea 配下の Text.rich で描画され選択できる', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    // 主選択をテキストファイルに設定して再 build させる。
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FilePreviewPane)),
    );
    container
        .read(explorerItemSelectionProvider('tab-1').notifier)
        .select(textFile.path);
    // 実 I/O（FileStat.stat → repository.load）を runAsync 内で完了させてから
    // pump で data 状態へ再 build する。ローディング中の CircularProgressIndicator
    // が無限アニメのため pumpAndSettle は使えない。
    await tester.runAsync(
      () => container.read(filePreviewViewModelProvider('tab-1').future),
    );
    await tester.pump();

    // SelectionArea は SelectableRegion を 1 つ挿入する（選択インフラ有効化）。
    expect(find.byType(SelectableRegion), findsOneWidget);

    // 本文は textSpan を持つ Text（Text.rich）として描画される。
    // flutter_highlight の HighlightView は生の RichText を使い選択できなかった
    // ため、Text.rich へ置き換えたことの回帰ガード。
    final body = tester.widgetList<Text>(find.byType(Text)).firstWhere(
      (t) => t.textSpan?.toPlainText().contains('void main() {}') ?? false,
      orElse: () => throw TestFailure('本文の Text.rich が見つからない'),
    );

    // 本文の Text.rich が SelectableRegion の子孫にある（＝選択対象）。
    expect(
      find.ancestor(
        of: find.byWidget(body),
        matching: find.byType(SelectableRegion),
      ),
      findsOneWidget,
    );
  });
}
