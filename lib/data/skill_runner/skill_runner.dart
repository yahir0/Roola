import 'dart:async';
import 'dart:typed_data';

import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';

/// PTY 上で `claude` プロセスを起動し、Skill を実行するための抽象。
///
/// View 層は `state` を購読し、`output` を `xterm.Terminal` に流し込み、
/// `xterm` の `onOutput` から取得したキー入力を `write` に書き戻す。
/// `resize` は端末表示サイズの変化をプロセスへ伝えるために呼ぶ。
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

  /// PTY への入力（ユーザーのキー入力など）を書き込む。
  void write(Uint8List data);

  /// 端末サイズの変更を PTY に伝える。
  void resize({required int cols, required int rows});

  /// プロセスを SIGTERM で終了させ、リソースを解放する。
  /// 既に終了済みの場合は no-op。
  Future<void> cancel();
}
