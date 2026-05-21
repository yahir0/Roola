# ADR-0043: メニューから手動でアップデート確認を呼べるようにする

- **Status**: Accepted
- **Date**: 2026-05-21

## Context

Roola は Sparkle 2 で自動更新を実装している（CocoaPods 経由 / `Sparkle ~> 2.6`）。
`SPUStandardUpdaterController(startingUpdater: true, ...)` を `AppDelegate.init()`
で初期化し、バックグラウンドで appcast を定期チェックする構成。

これだとユーザーは「アップデートを今すぐ確認」する手段を持たない。新しいリリース
を急いで取り込みたい場面（不具合修正版の確認、CI のリリース完了を見届けたあと
など）で「アプリ側から能動的に確認したい」要望が出てきた。

## Decision

メニューバーの **Roola メニュー** に「アップデートを確認…」を追加し、Flutter →
ネイティブ → Sparkle の経路で `SPUStandardUpdater.checkForUpdates(_:)` を呼ぶ。

### 配線

```
PlatformMenuBar (Dart)
  └─ "アップデートを確認…" onSelected
       └─ ref.read(sparkleUpdaterProvider).checkForUpdates()
            └─ MethodChannel("roola/updater").invokeMethod("checkForUpdates")
                 └─ MainFlutterWindow setMethodCallHandler
                      └─ (NSApp.delegate as? AppDelegate).checkForUpdates(nil)
                           └─ updaterController?.checkForUpdates(nil)
```

### 配置

- メニュー位置: macOS の慣例に従い **アプリメニュー（Roola）の About 直下** の
  グループ。`PlatformMenuItemGroup` で About と分けて区切る
- ショートカット: 付けない（誤押下を避ける。ユーザーが必要なら後で
  `CommandRegistry`（ADR-0033）に乗せて割り当て可能）
- Sparkle UI: チェック結果ダイアログ・ダウンロード進捗・再起動確認はすべて
  Sparkle が描画する。Dart 側にステータスを返さない

### ネイティブ側の責務分離

- **AppDelegate**: `SPUStandardUpdaterController` の所有者。`@objc func
  checkForUpdates(_ sender: Any?)` を生やしてエントリポイントを公開する
- **MainFlutterWindow**: MethodChannel の登録だけ。Sparkle のインスタンスは
  持たず、`NSApp.delegate as? AppDelegate` 経由で AppDelegate に転送する

### SUFeedURL / SUPublicEDKey 未設定時

ローカル debug ビルド等で Info.plist の設定が無い場合、AppDelegate の
`updaterController` は nil。`checkForUpdates(_:)` は **no-op** で何も起きない。
Dart 側にエラーは返さない（ユーザーに「設定不備」を見せる意味が無い）。

## Why

- **Sparkle 標準のフロー**: `checkForUpdates(_:)` は Sparkle 公式が menu item /
  ボタンから呼ぶことを想定した API（`SPUStandardUserDriver` が自動でダイアログ
  を出す）。独自 UI を書く必要がない
- **MethodChannel を AppDelegate に直結させない**: `AppDelegate` に Flutter Engine
  参照を持たせると依存が逆転する。`MainFlutterWindow` は既に `engine.binaryMessenger`
  を握っているので、ここで channel を立てて AppDelegate に薄く転送する方が、
  既存パターン（`roola/trash` / `roola/system/metrics`）と一貫する
- **メニューバーへの追加が最も摩擦が少ない**: 既存の `AppMenuBar` に 1 行足す
  だけで macOS ネイティブのメニューに反映される。設定画面に潜らせるより発見性
  が高い
- **ショートカットを最初から割り当てない**: アップデート確認は意図して押す操作。
  誤発火させたくない。必要になれば `CommandRegistry` 経由で後付け可能

## 代替案

### 代替案 1: 設定画面に「アップデートを確認」ボタンを置く

`SettingsPage` の About セクションあたりにボタンを出す。

- 発見性が低い。「メニューから 1 アクションで叩ける」体験から後退する
- macOS の慣例（Sparkle 採用アプリのほとんどがアプリメニューに置く）と外れる
- 却下。

### 代替案 2: `CommandRegistry`（ADR-0033）に `CommandId.checkForUpdates` を追加

他のメニュー項目と同じく `CommandId` に乗せ、ユーザーがショートカットを割り当て
られるようにする。

- 仕組み的には可能だが、ショートカット割り当ての需要が見えていない
- 「アップデート確認」は CommandRegistry に流す副作用（コマンド履歴・キーバインド
  上書き）に乗せるほどの粒度ではない
- 必要になれば後追いで上に被せられる
- 当面は却下。

### 代替案 3: AppDelegate に直接 MethodChannel を持たせる

`MainFlutterWindow` を介さず AppDelegate 自身が `roola/updater` を listen する。

- AppDelegate に Flutter Engine 参照（contentViewController から辿る）を持たせる
  ことになる。既存パターン（plugin channel は MainFlutterWindow で登録）と外れる
- 却下。

## Trade-offs

- **Sparkle の UI に依存**: メニューから叩いてもアプリ内のダイアログには
  ならず、Sparkle の標準ダイアログが出る（タイトルや配色は Polaris と
  揃わない）。とはいえ macOS ユーザーには Sparkle UI のほうが見慣れている
- **CocoaPods 依存の維持**: Sparkle を CocoaPods で入れている前提に依存する
  （SPM ではなく）。配布構成を見直すときは合わせて再検討
- **テストしにくい**: MethodChannel 越しの Sparkle 呼び出しは Widget テストに
  乗らない。実機での手動確認（PR の test plan）で担保する

## References

- ADR-0033（コマンドレジストリとネイティブメニューバー）
- ADR-0040（About ダイアログと OSS ライセンス画面：同じく `MainFlutterWindow`
  + アプリメニューのパターン）
- Sparkle docs: `SPUStandardUpdater` / `SPUStandardUpdaterController`
  - https://sparkle-project.org/documentation/api-reference/
