/// アプリの全アクションを識別する安定 ID（ADR-0033）。
///
/// メニューバー・コンテキストメニュー・設定画面の 3 UI と、永続化された
/// ユーザーのキー割り当てが、この enum 値（の `name`）を介して対応づく。
/// 値の追加・削除に対しては、永続化 DTO が未知の `name` を読み飛ばすことで
/// 前方・後方互換を保つ。
enum CommandId {
  // ナビゲーション
  navigateBack,
  navigateForward,
  navigateUp,

  // エクスプローラ（選択中アイテム / カレントディレクトリ対象）
  copyPath,
  copyItem,
  pasteItem,
  renameItem,
  moveToTrash,
  newFolder,
  newFile,
  revealInFinder,
  openItem,
  showProperties,
  openTerminalHere,
  openClaudeHere,

  // タブ / ペイン
  newExplorerTab,
  newTerminalTab,
  closeTab,
  nextTab,
  previousTab,
  moveTabTopLeft,
  moveTabTopRight,
  moveTabBottom,

  // ランチャー / アプリ
  openLauncherManagement,
  openSettings,
  openKeybindings,

  // Git（フォーカス中 Git タブ対象）
  gitRefresh,
  gitCommit,
  gitFetch,
  gitPull,
  gitPush,
}
