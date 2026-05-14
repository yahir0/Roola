import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

/// `claude` CLI が PATH 上に存在し、起動可能かをチェックした結果。
class ClaudeHealth {
  const ClaudeHealth({required this.available, required this.versionOutput});

  /// `claude --version` がエラー無く実行できた場合 true。
  final bool available;

  /// stdout（または失敗時の説明）。
  final String versionOutput;
}

/// アプリ起動時に 1 度だけ `claude --version` を実行し、結果を Provider 化する。
final claudeHealthProvider = FutureProvider<ClaudeHealth>((ref) async {
  try {
    final result = await Process.run('claude', ['--version']);
    if (result.exitCode == 0) {
      return ClaudeHealth(
        available: true,
        versionOutput: (result.stdout as String).trim(),
      );
    }
    return ClaudeHealth(
      available: false,
      versionOutput: '終了コード ${result.exitCode}: ${result.stderr}',
    );
  } on ProcessException catch (e) {
    return ClaudeHealth(available: false, versionOutput: e.message);
  }
});

/// `claude` CLI が使えるかどうかの bool 派生 Provider（ADR-0022）。
///
/// 各 UI ウィジェットが `AsyncValue<ClaudeHealth>` を毎回 when() する手間を
/// 省き、`bool` 単発で reactive に切替えられるようにする。
/// - data: `available` 値そのまま
/// - loading: 楽観的に true（起動直後の数百 ms に Claude 関連 UI が点滅する
///   のを避ける。判定後に false なら描画から消える）
/// - error: false（最終的に false 寄りで保守する）
final claudeAvailableProvider = Provider<bool>((ref) {
  final health = ref.watch(claudeHealthProvider);
  return health.when(
    data: (h) => h.available,
    loading: () => true,
    error: (_, _) => false,
  );
});
