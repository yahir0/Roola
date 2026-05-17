import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/workspace/pane_slot.dart';
import 'package:roola/data/workspace/workspace_layout.dart';
import 'package:roola/data/workspace/workspace_layout_dto.dart';
import 'package:roola/data/workspace/workspace_tab.dart';

/// `WorkspaceLayoutDto` の GitTab 対応（ADR-0030 / tasks 8.4）を検証する。
void main() {
  late Directory repo;

  setUp(() async {
    repo = await Directory.systemTemp.createTemp('roola_dto_git_');
    // `.git` の存在で「Git リポジトリ」と判定される。
    await Directory('${repo.path}/.git').create();
  });

  tearDown(() async {
    if (repo.existsSync()) {
      await repo.delete(recursive: true);
    }
  });

  WorkspaceLayout roundtrip(WorkspaceLayout layout) {
    final json = jsonEncode(WorkspaceLayoutDto.fromEntity(layout).toJson());
    return WorkspaceLayoutDto.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    ).toEntity();
  }

  test('GitTab は JSON 経由で復元できる', () {
    final layout = WorkspaceLayout(
      topLeft: PaneSlot(
        tabs: [WorkspaceTab.git(id: 'g1', repoRoot: repo.path)],
      ),
      topRight: PaneSlot.empty,
      bottom: PaneSlot.empty,
    );

    final restored = roundtrip(layout);
    final tab = restored.topLeft.tabs.single;
    expect(tab, isA<GitTab>());
    expect((tab as GitTab).id, 'g1');
    expect(tab.repoRoot, repo.path);
  });

  test('repoRoot が現存しない GitTab は復元時にスキップされる', () {
    final layout = WorkspaceLayout(
      topLeft: PaneSlot(
        tabs: [
          const WorkspaceTab.git(id: 'gone', repoRoot: '/no/such/repo'),
          WorkspaceTab.explorer(id: 'e1', currentPath: repo.path),
        ],
      ),
      topRight: PaneSlot.empty,
      bottom: PaneSlot.empty,
    );

    final restored = roundtrip(layout);
    // 復元不能な GitTab は除外され、エクスプローラタブだけが残る。
    expect(restored.topLeft.tabs.length, 1);
    expect(restored.topLeft.tabs.single, isA<ExplorerTab>());
  });

  test('Git 管理下でない repoRoot の GitTab もスキップされる', () async {
    final notRepo = await Directory.systemTemp.createTemp('roola_not_repo_');
    addTearDown(() => notRepo.delete(recursive: true));
    final layout = WorkspaceLayout(
      topLeft: PaneSlot(
        tabs: [WorkspaceTab.git(id: 'g', repoRoot: notRepo.path)],
      ),
      topRight: PaneSlot.empty,
      bottom: PaneSlot.empty,
    );

    expect(roundtrip(layout).topLeft.tabs, isEmpty);
  });

  test('git 種別を含まない旧スキーマ JSON は従来どおり読める', () {
    // 旧バージョンが書いた workspace.json 相当（git タブなし）。
    final oldJson = {
      'topLeft': {
        'tabs': [
          {'kind': 'explorer', 'id': 'e1', 'currentPath': '/tmp'},
        ],
        'activeIndex': 0,
      },
      'topRight': {'tabs': <dynamic>[], 'activeIndex': 0},
      'bottom': {'tabs': <dynamic>[], 'activeIndex': 0},
      'topRatio': 0.62,
      'leftRatio': 0.5,
    };

    final restored = WorkspaceLayoutDto.fromJson(oldJson).toEntity();
    expect(restored.topLeft.tabs.single, isA<ExplorerTab>());
    expect(
      (restored.topLeft.tabs.single as ExplorerTab).currentPath,
      '/tmp',
    );
  });
}
