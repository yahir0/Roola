# ADR-0059: Windows 自動アップデートを WinSparkle で実装する

- **Status**: Accepted
- **Date**: 2026-06-02

## Context

ADR-0043 で macOS は Sparkle 2 による完全な自動アップデートを実現したが、
Windows 側は GitHub Releases API でバージョンを比較するだけの最小実装にとどまり、
ダウンロード・インストール・バックグラウンドチェックはいずれも行われていなかった。

また Windows は `TitleBarStyle.hidden` でネイティブタイトルバーを非表示にして
いるため `PlatformMenuBar` が視覚的に機能せず、「アップデートを確認…」の導線が
存在しなかった。

## Decision

### 1. WinSparkle を採用する

macOS の Sparkle 2 と対称の設計にするため **WinSparkle** を採用する。

- Sparkle と同じ appcast XML 形式。macOS 側の知識がそのまま流用できる
- C API（`win_sparkle_init` / `win_sparkle_check_update_with_ui` 等）で
  Win32 C++ から直接呼べる
- DLL 配布。既存の Inno Setup `recursesubdirs` で自動同梱される

Velopack は近代的だが Inno Setup 構成を大幅に変更する必要があるため却下。

### 2. MethodChannel `roola/updater` を Windows にも実装する

macOS と同じチャンネル名を使い、Dart 側の `UpdateCheckerWindows` を
`UpdateCheckerMacos` と同パターンの薄い MethodChannel ラッパーに変更する。
WinSparkle が存在しない場合（`ROOLA_WINSPARKLE` 未定義）はネイティブ側が
no-op で返す。

### 3. Windows インラインメニューバーを実装する

`TitleBarStyle.hidden` で `PlatformMenuBar` が機能しないため、Flutter の
`MenuBar` ウィジェットを `AppBar.title` スロットに配置してインラインメニューバー
を実現する。左端のロゴアイコンが「Roola」メニュー（About / アップデートを
確認 / 設定）を兼ね、以降にファイル / 編集 / 表示 / ターミナル / Git / ペインが
並ぶ。macOS の `PlatformMenuBar` と同じメニュー構成を持つ。

### 4. appcast を main ブランチの raw URL でホストする

WinSparkle は起動時に appcast URL を定期ポーリングする。URL を固定するため
`https://raw.githubusercontent.com/yahiro0/Roola/main/appcast-windows.xml`
を使い、リリース CI が更新して main へコミットする（`[skip ci]` タグで
ループ防止）。

### 5. Phase A / Phase B の段階的有効化

- **Phase A**（現在）: MethodChannel は no-op。WinSparkle ライブラリを
  まだ組み込まない。インラインメニューバーとチャンネル配線は完成済み
- **Phase B**: WinSparkle DLL を `windows/third_party/winsparkle/` に配置し、
  `runner/CMakeLists.txt` で `ROOLA_WINSPARKLE` を定義することで有効化する

### 6. Phase A では署名を省略する

WinSparkle は EdDSA 署名を強制しない。Phase A では署名なしで動作させ、
コード署名対応の change と合わせて Phase B で追加する。

## Why

- **macOS との対称性**: Sparkle と WinSparkle は同じ appcast 形式・同じ概念を
  共有するため、macOS で得た知識を再利用できる
- **段階的実装**: インラインメニューバーとチャンネル配線は WinSparkle DLL なしで
  完成できる。DLL を後から追加するだけで全機能が有効化される設計
- **UI の一貫性**: WinSparkle の標準ダイアログに任せることで独自 UI の実装・
  保守コストをゼロにする（macOS の Sparkle と同じ方針）

## References

- ADR-0001（Flutter Desktop macOS 採用 → ADR-0058 で Windows を追加）
- ADR-0043（手動アップデート確認の macOS 実装）
- ADR-0058（Windows 対応）
- WinSparkle: https://winsparkle.org/
