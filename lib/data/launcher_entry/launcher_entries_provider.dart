import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// アプリ全体で共有する「ランチャーエントリ一覧」の AsyncNotifier。
///
/// HomePage と SettingsPage の両方がこの Notifier の状態を購読することで、
/// どちらかの画面で発生した追加・更新・削除が反対側へ即時反映される。
/// 永続化は `LauncherEntryRepository` に委譲する。
class LauncherEntriesNotifier extends AsyncNotifier<List<LauncherEntry>> {
  LauncherEntryRepository get _repository =>
      ref.read(launcherEntryRepositoryProvider);

  @override
  Future<List<LauncherEntry>> build() => _repository.loadAll();

  Future<void> add(LauncherEntry entry) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.add(entry);
      return _repository.loadAll();
    });
  }

  Future<void> updateEntry(LauncherEntry entry) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.update(entry);
      return _repository.loadAll();
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      return _repository.loadAll();
    });
  }
}

/// `LauncherEntriesNotifier` の Provider。
final launcherEntriesProvider =
    AsyncNotifierProvider<LauncherEntriesNotifier, List<LauncherEntry>>(
      LauncherEntriesNotifier.new,
    );
