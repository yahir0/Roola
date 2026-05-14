import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_folder.dart';
import 'package:roola/data/launcher_entry/launcher_folder_repository.dart';
import 'package:roola/data/launcher_entry/launcher_folder_repository_impl.dart';

/// アプリ全体で共有する「ランチャーフォルダ一覧」の AsyncNotifier。
///
/// 永続化は `LauncherFolderRepository` に委譲する。フォルダ削除時には
/// 配下エントリの folderId が repository 側で null に戻されるため、
/// 連動して [launcherEntriesProvider] も再フェッチして反映する。
class LauncherFoldersNotifier extends AsyncNotifier<List<LauncherFolder>> {
  LauncherFolderRepository get _repository =>
      ref.read(launcherFolderRepositoryProvider);

  @override
  Future<List<LauncherFolder>> build() => _repository.loadAll();

  Future<void> add(LauncherFolder folder) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.add(folder);
      return _repository.loadAll();
    });
  }

  Future<void> updateFolder(LauncherFolder folder) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.update(folder);
      return _repository.loadAll();
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      return _repository.loadAll();
    });
    // フォルダ削除は配下エントリの folderId を変更するので、entries 側も
    // refetch して UI に反映させる。
    ref.invalidate(launcherEntriesProvider);
  }
}

/// `LauncherFoldersNotifier` の Provider。
final launcherFoldersProvider =
    AsyncNotifierProvider<LauncherFoldersNotifier, List<LauncherFolder>>(
      LauncherFoldersNotifier.new,
    );
