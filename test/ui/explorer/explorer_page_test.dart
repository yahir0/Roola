import 'dart:io';

import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings.dart';
import 'package:claude_skills_launcher/data/repo_explorer/explorer_settings_repository_impl.dart';
import 'package:claude_skills_launcher/ui/explorer/explorer_page.dart';
import 'package:claude_skills_launcher/ui/explorer/explorer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// テスト用に「最初から rootPath を持つ ExplorerSettings」を返す Notifier。
/// build() の非同期 I/O を回避し、テストの永久ループを防ぐ。
class _SeededExplorerSettings extends ExplorerSettingsNotifier {
  _SeededExplorerSettings(this._seed);
  final ExplorerSettings _seed;

  @override
  Future<ExplorerSettings> build() async => _seed;
}

void main() {
  late Directory tempDir;
  late Directory repoA;
  late Directory plain;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cskl_explorer_page_');
    repoA = Directory('${tempDir.path}/repo-a');
    await Directory(
      '${repoA.path}/.claude/skills/alpha',
    ).create(recursive: true);
    await File(
      '${repoA.path}/.claude/skills/alpha/SKILL.md',
    ).writeAsString('# alpha');
    plain = Directory('${tempDir.path}/plain');
    await plain.create();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  ProviderContainer makeContainerForRoot(String rootPath) {
    return ProviderContainer(
      overrides: [
        explorerSettingsProvider.overrideWith(
          () => _SeededExplorerSettings(ExplorerSettings(rootPath: rootPath)),
        ),
      ],
    );
  }

  Widget harness(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ExplorerPage()),
    );
  }

  testWidgets('lists child folders with skill badge for repo-a', (
    tester,
  ) async {
    final container = makeContainerForRoot(tempDir.path);
    addTearDown(container.dispose);
    // Settings の AsyncNotifier を解決させる
    await container.read(explorerSettingsProvider.future);

    await tester.pumpWidget(harness(container));
    await tester.pump();

    expect(find.text('repo-a'), findsOneWidget);
    expect(find.text('plain'), findsOneWidget);
    expect(find.text('Skill: alpha'), findsOneWidget);
  });

  testWidgets('tapping a child enters it', (tester) async {
    final container = makeContainerForRoot(tempDir.path);
    addTearDown(container.dispose);
    await container.read(explorerSettingsProvider.future);

    await tester.pumpWidget(harness(container));
    await tester.pump();

    await tester.tap(find.text('repo-a'));
    await tester.pump();

    final vm = container.read(explorerViewModelProvider);
    expect(vm.currentPath, repoA.path);
  });
}
