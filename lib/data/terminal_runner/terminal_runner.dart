import 'dart:async';
import 'dart:typed_data';

import 'package:roola/data/terminal_runner/terminal_run_state.dart';

/// PTY 上で `LauncherAction` に応じたプロセス（素のシェル / 任意コマンド /
/// `claude /<skill>`）を起動するための抽象。
///
/// 描画・入力は SwiftTerm（ネイティブ macOS NSView）が担う（ADR-0031）。
/// `TerminalRunner` はレンダラ非依存で、PTY 出力をバイト列 Stream（[output]）
/// として配信し、ユーザー入力（[write]）と端末サイズ（[resize]）を受け取る。
/// View 層は [output] を SwiftTerm へ流し込み、SwiftTerm からの入力・リサイズ
/// を [write] / [resize] に渡すだけで描画が完結する（配線は `TerminalSurface`
/// と `TerminalChannel` が担う）。
///
/// `SkillRunState` などの内部クラス名は段階的リネーム方針の前半段階のため
/// 現行のまま維持する（ADR-0016 / tasks 3.3）。
abstract interface class TerminalRunner {
  /// PTY 上で対応するプロセスを起動する。複数回呼び出された場合の挙動は
  /// 実装依存（`PtyTerminalRunner` は二度目以降を no-op とする）。
  Future<void> start();

  /// プロセスの実行状態を時系列で配信する Stream。
  /// 現在値は `currentState` で取得できる。
  Stream<SkillRunState> get state;

  /// 現在の状態（同期取得）。
  SkillRunState get currentState;

  /// PTY 出力（標準出力＋標準エラーが混合された端末出力バイト列）。
  ///
  /// UTF-8 デコードは行わない。SwiftTerm の VT パーサがバイト列を直接解釈し、
  /// マルチバイト文字がチャンク境界をまたいでもパーサ側で正しく処理する。
  Stream<Uint8List> get output;

  /// PTY への入力（ユーザーのキー入力など）を書き込む。
  void write(Uint8List data);

  /// 端末サイズの変更を PTY に伝える。
  void resize({required int cols, required int rows});

  /// PTY 子プロセスに SIGTERM を送って終了させる。`output` Stream は保持し、
  /// セッションとしては参照可能なまま維持する。既に終了済みなら no-op。
  Future<void> cancel();

  /// セッションの明示破棄。PTY と内部 Stream を完全に解放する。
  /// 一度呼ぶと再起動できない（新しい `TerminalRunner` を生成する必要がある）。
  Future<void> dispose();
}
