# ADR-0064: macOS のトップバーからワードマークを廃止し、信号灯を上下中央へ寄せる

- **Status**: Accepted
- **Date**: 2026-06-08

## Context

macOS のウィンドウ左上（信号灯の直後）に、ブランドのワードマーク「ROOLA」を
テキストで表示していた（`workspace_page.dart` の `_AppWordmark` / トークンは
`PolarisTokens.wordmark`）。これは ADR-0038 D9（タイポグラフィで OS 標準を尊重）
の流れで「トップバー中央の空白を埋め、右端のアクションと釣り合わせる」目的で
置かれていた。

一方 Windows 版は左上にブランドアイコン（`roola_icon.png`）を置いているが、これは
**ネイティブメニューバーを持たない Windows でアプリメニューの入口を兼ねる**機能を
持つ（`WindowsTopMenuBar` の `SubmenuButton`、ADR-0058）。「macOS も Windows に
合わせてアイコンにすべきか」を検討した結果、次の整理に至った。

- macOS は**ネイティブメニューバー（ADR-0033）にアプリ名 "Roola" が常時表示**されて
  おり、ウィンドウ内にワードマークを出すのはアプリ名の二重表示。
- ネイティブな macOS アプリ（Finder / Terminal / VS Code 等）は**自分のウィンドウ内に
  自社名・ロゴを貼らない**。タイトルバーに出すのは「今開いている対象」であって
  ブランドではない。自社名を自窓に貼るのは Windows / Web アプリの作法。
- Polaris は機能主義（ADR-0038）。「このワードマークは何の機能を持つか」を問うと、
  macOS では起動中に自明なアプリ名を再掲しているだけで**機能を持たない**。Windows の
  アイコンが「メニュー入口」という機能を持つのとは前提が違う。

あわせて、信号灯（close / minimize / zoom）の縦位置の問題も判明した。Roola は
`window_manager` の `titleBarStyle: hidden` + `titlebarAppearsTransparent` で
ネイティブタイトルバーを隠している。この構成では信号灯が macOS 標準タイトルバー
（約 28px）基準で配置されるため、Roola の 40px トップバー
（`MacosWindowAppBar._toolbarHeight`、ADR-0038 D6）の中では**上端に詰まって**見え、
他の Mac アプリのような上下の余白バランスにならない。`window_manager` 0.5.1 には
信号灯の縦位置オフセットを制御する API が無いため、Dart 側だけでは解決できない。

## Decision

1. **macOS のトップバーからワードマークを廃止する。** `MacosWindowAppBar` の
   `title` は macOS では `null`、Windows では従来どおり `WindowsTopMenuBar` を置く。
   `_AppWordmark` ウィジェットと `PolarisTokens.wordmark` トークンも削除する。
   空いた領域は `flexibleSpace` の `DragToMoveArea` がそのままドラッグ移動領域として
   活かす（むしろドラッグ可能域が広がる）。

   ```dart
   title: Platform.isWindows ? const WindowsTopMenuBar() : null,
   ```

2. **信号灯を 40px トップバー内で上下中央へ寄せる。** ネイティブ側
   （`MainFlutterWindow.swift`）で標準ウィンドウボタンの `frame.origin.y` を、中心が
   トップバー上端から `topBarHeight / 2` の位置に来るよう再計算する。リサイズで
   AppKit が既定位置へ戻すため、`NSWindow.didResizeNotification` /
   `didExitFullScreenNotification` と初回 run loop で再適用する。フルスクリーン中は
   OS がボタンを管理するため何もしない。

## Why

- **macOS では純飾アイコンよりワードマーク廃止が筋が通る。** 「アイコン単体に置換」
  すると macOS では何の機能も持たない絵が左上に座るだけで、アプリ名の情報量すら失う。
  メニューバーにアプリ名がある以上、ウィンドウ内のブランド再掲は不要と判断した。
- **OS ごとに役割が違うのは正当。** Windows のアイコンはメニュー入口という機能を
  持つので据え置き、macOS は機能を持てないので廃止、と非対称にするのが機能主義に沿う。
- **信号灯の位置は手元の Mac アプリと同じ「いい感じの上下余白」に揃える。** これは
  ターミナルランチャーとしてネイティブな所作に寄せる方針（ADR-0063 と同じ思想）。

## Trade-offs

- **ブランド表示が macOS のウィンドウ内から消える。** ただしアプリアイコン（Dock /
  メニューバー / About）で十分に担保され、ウィンドウ内の常時表示はノイズと判断。
- **信号灯の縦位置調整はプライベートなビュー階層（標準ボタンの superview）に依存する。**
  将来の macOS で配置が変わると破綻しうるが、`compactMap` + `guard` で nil 安全にし、
  失敗時は単に既定位置（上端寄り）へフォールバックするだけで機能は壊れない。
  `topBarHeight` の 40 は `MacosWindowAppBar._toolbarHeight` と一致させる必要があり、
  両者を変える際は揃える（コード側にコメントで明記）。
- **代替案（採用せず）**:
  - *macOS もアイコンに置換*: 機能を持てず情報量も減るため不採用。
  - *アイコン＋ワードマーク併置*: ブランド一貫性は上がるが、二重表示・ノイズの解消には
    ならず、macOS の作法からも外れるため不採用。
  - *NSToolbar を追加して信号灯を自動センタリング*: よりネイティブだが Flutter の
    `fullSizeContentView` 構成との整合調整が増え、40px へぴったり合わせにくい。確実に
    高さを合わせられるボタン frame 再配置を採った。

## References

- ADR-0038: Polaris デザインシステム（D6 トップバー高 40px / D8 タイトルバー隠蔽 /
  D9 タイポグラフィで OS 標準を尊重）。本 ADR は D9 のワードマーク採用を一部 Supersede。
- ADR-0033: コマンドレジストリとネイティブメニューバー（macOS はアプリ名がメニュー
  バーに常時表示される前提）
- ADR-0053: ブランドシンボルを「翼＋フォルダ」へ刷新
- ADR-0058: Windows 対応（`WindowsTopMenuBar` のアイコン＝メニュー入口）
- `lib/ui/workspace/workspace_page.dart`（`MacosWindowAppBar` の `title`）
- `lib/ui/common/macos_window_app_bar.dart`（`_toolbarHeight = 40`）
- `lib/app/theme.dart`（`PolarisTokens` から `wordmark` を削除）
- `macos/Runner/MainFlutterWindow.swift`（`centerWindowButtons`）
