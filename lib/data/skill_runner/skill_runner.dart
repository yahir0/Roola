import 'dart:async';
import 'dart:typed_data';

import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:xterm/xterm.dart';

/// PTY 上で `claude` プロセスを起動し、Skill を実行するための抽象。
///
/// View 層は `state` を購読し、保有する `terminal` を `TerminalView` に渡す
/// だけで描画が完結する。PTY との双方向配線（出力 → terminal.write、
/// terminal.onOutput → PTY.write、terminal.onResize → PTY.resize）は
/// 実装側に閉じる。
abstract interface class SkillRunner {
  /// PTY 上で `claude <skill>` を起動する。複数回呼び出された場合の
  /// 挙動は実装依存（`PtySkillRunner` は二度目以降を no-op とする）。
  Future<void> start();

  /// プロセスの実行状態を時系列で配信する Stream。
  /// 現在値は `currentState` で取得できる。
  Stream<SkillRunState> get state;

  /// 現在の状態（同期取得）。
  SkillRunState get currentState;

  /// PTY 出力（標準出力＋標準エラーが混合された端末出力）。
  Stream<Uint8List> get output;

  /// `TerminalView` で描画するためのターミナルバッファ。実装側でスクロール
  /// バックを保持するため、`SkillRunner` の生存期間 = `Terminal` の生存期間。
  Terminal get terminal;

  /// PTY への入力（ユーザーのキー入力など）を書き込む。
  void write(Uint8List data);

  /// 端末サイズの変更を PTY に伝える。
  void resize({required int cols, required int rows});

  /// PTY 子プロセスに SIGTERM を送って終了させる。`Terminal` インスタンスと
  /// `output` Stream は保持し、スクロールバックを参照可能に維持する。
  /// 既に終了済みの場合は no-op。
  Future<void> cancel();

  /// セッションの明示破棄。`Terminal` と内部 Stream を完全に解放する。
  /// 一度呼ぶと再起動できない（新しい `SkillRunner` を生成する必要がある）。
  Future<void> dispose();
}
