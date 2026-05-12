import 'package:claude_skills_launcher/data/launcher_entry/launcher_entries_provider.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ホーム画面 (`HomePage`) 用 ViewModel。
///
/// `launcherEntriesProvider` を購読することで、設定画面側の追加・編集・削除が
/// 即座にホームのアイコングリッドへ反映される。
class HomeViewModel extends AsyncNotifier<List<LauncherEntry>> {
  @override
  Future<List<LauncherEntry>> build() async {
    final asyncEntries = ref.watch(launcherEntriesProvider);
    return asyncEntries.when(
      data: (entries) => entries,
      loading: () => Future<List<LauncherEntry>>.value(const []),
      error: Future<List<LauncherEntry>>.error,
    );
  }
}

final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, List<LauncherEntry>>(
      HomeViewModel.new,
    );
