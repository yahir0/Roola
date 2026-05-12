import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 設定画面 (`SettingsPage`) のためのエントリ一覧 ViewModel。
///
/// `loadAll` を起点に [AsyncValue] でエントリ一覧を公開する。
/// 追加・更新・削除はメソッドとして公開し、成功すると状態を再ロードする。
class SettingsViewModel extends AsyncNotifier<List<LauncherEntry>> {
  LauncherEntryRepository get _repository =>
      ref.read(launcherEntryRepositoryProvider);

  @override
  Future<List<LauncherEntry>> build() async {
    return _repository.loadAll();
  }

  Future<void> addEntry(LauncherEntry entry) async {
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

  Future<void> deleteEntry(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      return _repository.loadAll();
    });
  }
}

/// `SettingsViewModel` を購読する Provider。
final settingsViewModelProvider =
    AsyncNotifierProvider<SettingsViewModel, List<LauncherEntry>>(
  SettingsViewModel.new,
);
