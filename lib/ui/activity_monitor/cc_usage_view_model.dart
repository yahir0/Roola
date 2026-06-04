import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/cc_usage/cc_usage.dart';
import 'package:roola/data/cc_usage/cc_usage_repository.dart';
import 'package:roola/data/fs_watcher/directory_watcher.dart';

/// トップバーのアクティビティモニタが参照する Claude Code 使用量
/// （ADR-0060）。
///
/// CPU / メモリ（[ActivityMonitorViewModel]）と異なり、使用量は JSONL の
/// 追記時にしか変化しないため、ポーリングではなく [DirectoryWatcher]
/// （ADR-0041）でイベント駆動更新する。加えて、ファイル変更が無くても
/// ローカルタイムの日付が変われば当日集計はリセットされるべきなので、
/// 低頻度の定期タイマで再集計して日跨ぎを検知する。
///
/// 監視・集計は `~/.claude/projects` を対象にするだけで、ネットワークや
/// Claude Code 本体には依存しない（自己完結方針 ADR-0005）。`NotifierProvider`
/// は autoDispose ではないため、トップバーが存在する限り常駐する。
class CcUsageViewModel extends Notifier<CcUsage> {
  /// 連続する JSONL 追記を 1 回の再集計にまとめるデバウンス。
  static const Duration watchDebounce = Duration(milliseconds: 400);

  /// 日跨ぎ検知用の再集計間隔。ファイル変更が無くても当日集計を最新に保つ。
  static const Duration dateCheckInterval = Duration(minutes: 1);

  static const DirectoryWatcher _watcher = DirectoryWatcher();

  StreamSubscription<void>? _watchSub;
  Timer? _dateTimer;

  @override
  CcUsage build() {
    ref.onDispose(() {
      _watchSub?.cancel();
      _watchSub = null;
      _dateTimer?.cancel();
      _dateTimer = null;
    });
    _start();
    return CcUsage.zero;
  }

  void _start() {
    unawaited(_refresh());

    final dir = ref.read(ccUsageRepositoryProvider).projectsDirectory();
    if (dir != null && dir.existsSync()) {
      _watchSub = _watcher
          .watch(dir.path, recursive: true, debounce: watchDebounce)
          .listen((_) => unawaited(_refresh()));
    }

    // aggregateToday() は呼び出しごとに「現在の当日」を計算するため、定期
    // 再集計だけで日付変更時のリセットも兼ねる。対象は当日分ファイルのみで
    // 軽量なため、1 分間隔の常駐ポーリングでも負荷は小さい。
    _dateTimer = Timer.periodic(
      dateCheckInterval,
      (_) => unawaited(_refresh()),
    );
  }

  Future<void> _refresh() async {
    try {
      state = await ref.read(ccUsageRepositoryProvider).aggregateToday();
    } on Object {
      // 集計失敗時は直近値を維持。aggregateToday 自体はデータ不在で
      // CcUsage.zero を返すため、ここに来るのは想定外の I/O 例外のみ。
    }
  }
}

/// Claude Code 使用量の Provider。トップバーの使用量メーターが参照する。
final ccUsageProvider = NotifierProvider<CcUsageViewModel, CcUsage>(
  CcUsageViewModel.new,
);
