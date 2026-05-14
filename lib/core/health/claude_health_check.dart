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
///
/// DMG / Dock 起動だと launchd 経由になり PATH が `/usr/bin:/bin:...` まで
/// 切り詰められる。pnpm / nvm / volta / Homebrew 等にインストールされた
/// `claude` がそのままだと見えないだけでなく、claude が Node スクリプト
/// （shebang `#!/usr/bin/env -S node ...`）の場合は claude のフルパスが
/// 解決できても `node` が PATH に無くて失敗する。
///
/// このため、まず素の PATH で試し、失敗したらユーザーの login shell 経由で
/// `exec "$@"` テクニックで claude を起動して再試行する。これで claude /
/// node とも login shell の PATH 上で解決される。
final claudeHealthProvider = FutureProvider<ClaudeHealth>((ref) async {
  // 1) PATH 経由（ターミナル直起動 / dev 起動はここで通る）。
  final direct = await _runVersion(executable: 'claude', arguments: const []);
  if (direct != null) return direct;

  // 2) login + interactive shell 経由（DMG / Dock 起動）。
  //    - `-l` で .zprofile / .profile を読み込み
  //    - `-i` で .zshrc / .bashrc も読み込む（多くのユーザーは PATH 拡張を
  //      .zshrc に書くため、-l だけだと `.zshrc` が読まれず PATH が伸びず
  //      `command not found` になる）
  //    - `exec "$@"` でシェルを claude に置き換えて起動する
  final shell = Platform.environment['SHELL'] ?? '/bin/zsh';
  final viaShell = await _runVersion(
    executable: shell,
    arguments: const ['-i', '-l', '-c', r'exec "$@"', '_', 'claude'],
  );
  return viaShell ??
      const ClaudeHealth(
        available: false,
        versionOutput: '`claude` CLI が見つかりませんでした',
      );
});

/// 与えられた `executable` + `arguments` の末尾に `--version` を付けて起動し、
/// stdout を読む。成功なら ClaudeHealth、失敗・例外なら null。
///
/// stdout には `.zshrc` 等の echo が混ざる可能性があるため、最終非空行を
/// version 表示として採用する。
Future<ClaudeHealth?> _runVersion({
  required String executable,
  required List<String> arguments,
}) async {
  try {
    final result = await Process.run(executable, [...arguments, '--version']);
    if (result.exitCode != 0) return null;
    final lines = (result.stdout as String)
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;
    return ClaudeHealth(available: true, versionOutput: lines.last);
  } on ProcessException {
    return null;
  }
}

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
