# ADR-0002: ターミナル統合を最初から PTY ベースで実装

- **Status**: Accepted
- **Date**: 2026-05-11

## Context

本アプリの主要機能は「アイコンクリックで対象ディレクトリで Skill を実行し、対話を続ける」こと。`claude` CLI は対話的な UI を多用する:

- 承認プロンプト（y/n）
- 矢印キーで操作する選択 UI
- ANSI エスケープによる画面更新（カラー・カーソル移動・画面クリア）
- 場合によっては pager（less 等）の起動

これを「アプリ内ターミナル」で扱うには、子プロセスを単なる stdio パイプではなく **擬似端末（PTY）** で起動する必要がある。

## Decision

最初から PTY ベースで実装する。`flutter_pty` パッケージで `PseudoTerminal.start(executable, arguments, workingDirectory, environment)` を用いて `claude` を擬似端末上で起動し、入出力をバイト列ストリームで橋渡しする。

MVP の段階で「`Process.start` で簡易実装し、後から PTY に差し替える」という段階的アプローチは取らない。

## Why

### 代替案: `dart:io Process.start` で開始

却下。理由:

1. `Process.start` は擬似端末を提供しないため、`isatty` が false になり、`claude` 側がインタラクティブモードを無効化する可能性がある
2. 矢印キー・Ctrl-C 等の制御シーケンス送出が壊れる
3. ANSI エスケープが想定通り解釈されないケースが出る
4. 後から PTY に差し替えるには、状態管理境界・テスト・UI 統合の再設計が伴う。MVP で `Process.start` を採用するコスト削減効果より、後の再構築コストが上回る

### 採用理由（PTY 最初から）

- 現状の Skills は TTY 前提の対話を多用するため、PTY 無しでは「半分しか動かない」状態になる
- `flutter_pty` + `xterm` の組み合わせは Mac / Linux / Windows で動き、公式パッケージとして公開されている
- 抽象化（`SkillRunner` interface）を入れておけば、将来 PTY ライブラリを差し替えるコストも限定的

## Trade-offs

- `flutter_pty` への依存。OS ごとの挙動差（特にウィンドウサイズ変更時の文字化け等）は実装後に検出する必要がある
- PTY 経由のため、子プロセスの stdout / stderr が混合された出力になる（パイプベースなら分離できる）。本アプリの用途では分離は不要
- macOS App Sandbox 下では PTY 起動に制限がかかる可能性がある。本プロジェクトは Sandbox を無効化する方針（後続 ADR / `app-bootstrap` 仕様で扱う）

## References

- flutter_pty: https://pub.dev/packages/flutter_pty
- xterm: https://pub.dev/packages/xterm
- POSIX pty 概念: https://man7.org/linux/man-pages/man7/pty.7.html
