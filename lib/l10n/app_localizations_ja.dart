// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get buttonCancel => 'キャンセル';

  @override
  String get buttonClose => '閉じる';

  @override
  String get buttonConfirm => '決定';

  @override
  String get buttonReset => '戻す';

  @override
  String get buttonDelete => '削除';

  @override
  String get buttonCreate => '作成';

  @override
  String get buttonChange => '変更';

  @override
  String get buttonSave => '保存';

  @override
  String get buttonSaving => '保存中...';

  @override
  String get buttonRetry => '再試行';

  @override
  String get navBack => '戻る';

  @override
  String get navForward => '進む';

  @override
  String get navUp => '上の階層へ';

  @override
  String get commandCategoryNavigation => 'ナビゲーション';

  @override
  String get commandCategoryExplorer => 'エクスプローラ';

  @override
  String get commandCategoryTab => 'タブ / ペイン';

  @override
  String get commandCategoryApp => 'ランチャー / アプリ';

  @override
  String get commandCategoryGit => 'Git';

  @override
  String get commandCopyPath => 'パスをコピー';

  @override
  String get commandCopyItem => 'コピー';

  @override
  String get commandPasteItem => 'ペースト';

  @override
  String get commandRenameItem => '名前を変更';

  @override
  String get commandMoveToTrash => '削除';

  @override
  String get commandNewFolder => '新規フォルダ';

  @override
  String get commandNewFile => '新規テキストファイル';

  @override
  String get commandRevealInFinder => 'Finder で表示';

  @override
  String get commandOpenItem => '開く';

  @override
  String get commandShowProperties => 'プロパティ';

  @override
  String get commandOpenTerminalHere => 'ここでターミナルを開く';

  @override
  String get commandOpenClaudeHere => 'ここで Claude Code を開く';

  @override
  String get commandNewExplorerTab => '新規エクスプローラタブ';

  @override
  String get commandNewTerminalTab => '新規ターミナルタブ';

  @override
  String get commandCloseTab => 'タブを閉じる';

  @override
  String get commandNextTab => '次のタブ';

  @override
  String get commandPreviousTab => '前のタブ';

  @override
  String get commandMoveTabTopLeft => 'タブを左上ペインへ移動';

  @override
  String get commandMoveTabTopRight => 'タブを右上ペインへ移動';

  @override
  String get commandMoveTabBottom => 'タブを下ペインへ移動';

  @override
  String get commandOpenLauncherManagement => 'ランチャー管理を開く';

  @override
  String get commandOpenSettings => '設定を開く';

  @override
  String get commandOpenKeybindings => 'キーボードショートカットを開く';

  @override
  String get commandGitRefresh => 'Git ビューを更新';

  @override
  String get commandGitFetch => 'フェッチ';

  @override
  String get commandGitPull => 'プル';

  @override
  String get commandGitPush => 'プッシュ';

  @override
  String get appMenuRoola => 'Roola';

  @override
  String get appMenuFile => 'ファイル';

  @override
  String get appMenuEdit => '編集';

  @override
  String get appMenuView => '表示';

  @override
  String get appMenuTerminal => 'ターミナル';

  @override
  String get appMenuGit => 'Git';

  @override
  String get appMenuPane => 'ペイン';

  @override
  String get windowCloseConfirmTitle => '終了の確認';

  @override
  String windowCloseConfirmMessage(int count) {
    return '$count 件のセッションが残っています。\n終了するとすべての PTY が終了され、出力履歴も失われます。';
  }

  @override
  String get windowCloseConfirmButton => '終了する';

  @override
  String get settingsPageTitle => '設定';

  @override
  String get settingsLanguageTitle => '言語';

  @override
  String get settingsLanguageDescription => 'アプリの表示言語を選択します。';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsExplorerTitle => 'エクスプローラ';

  @override
  String get settingsExplorerDescription => 'ファイル / フォルダタイルの縦幅と情報量を切替えます。';

  @override
  String get explorerDensityCompact => 'コンパクト';

  @override
  String get explorerDensityComfortable => 'ゆったり';

  @override
  String get explorerDensityCompactDescription =>
      'コンパクト: サイドバーと同じ縦幅。Skill サブタイトル / チップは省略。';

  @override
  String get explorerDensityComfortableDescription =>
      'ゆったり: 縦幅にゆとりを持たせ、Skill サブタイトルとチップも表示。';

  @override
  String get settingsClaudeIntegrationTitle => 'Claude Code 連携';

  @override
  String get settingsClaudeIntegrationDescription =>
      'Anthropic の Claude Code CLI が PATH 上で見つかると、関連機能が自動で有効化されます。';

  @override
  String get claudeHealthChecking => '検出中…';

  @override
  String get claudeHealthCheckingDetail => '`claude --version` の実行を待っています。';

  @override
  String get claudeHealthCheckError => 'ヘルスチェックに失敗';

  @override
  String get claudeHealthCheckSuccess => '検出済み';

  @override
  String get claudeHealthCheckSuccessDetail => '`claude` コマンドが利用可能です。';

  @override
  String claudeHealthVersion(String version) {
    return 'Version: $version';
  }

  @override
  String get claudeHealthCheckNotFound => '未検出';

  @override
  String get claudeHealthCheckNotFoundDetail =>
      '`claude` コマンドが PATH 上で見つかりませんでした。';

  @override
  String claudeHealthCheckNotFoundDetailWith(String detail) {
    return '詳細: $detail';
  }

  @override
  String get settingsClaudeFeatures => '有効化される機能';

  @override
  String get settingsClaudeFeature1 =>
      'エクスプローラのフォルダで `.claude/skills/` を自動検知し、特別アイコンと Skill チップを表示';

  @override
  String get settingsClaudeFeature2 =>
      '右クリックメニューに「Claude Code を開く」「Skill を即実行」「Skill をランチャーに登録」を追加';

  @override
  String get settingsClaudeFeature3 =>
      'ランチャー登録時に「Claude Skill」動作タイプを選べる（Skill 名を指定して `claude /skillname` を起動）';

  @override
  String get settingsClaudeInstallTitle => 'インストール手順';

  @override
  String get settingsClaudeInstallInstructions =>
      'Node.js 18+ がある状態で次のコマンドを実行してください:';

  @override
  String get settingsClaudeInstallCopyTooltip => 'コマンドをコピー';

  @override
  String get settingsClaudeInstallCopied => 'インストールコマンドをコピーしました';

  @override
  String get settingsClaudeInstallAfter => 'インストール後、Roola を再起動すると検出されます。';

  @override
  String get settingsKeyboardShortcutsTitle => 'キーボードショートカット';

  @override
  String get settingsKeyboardShortcutsDescription =>
      'すべてのコマンドのショートカットは専用画面で確認・変更できます。';

  @override
  String get settingsKeyboardShortcutsButton => 'キーボードショートカットを編集…';

  @override
  String get settingsMouseOperationsTitle => 'マウス操作';

  @override
  String get settingsMouseClick => 'ファイル / フォルダを選択（ハイライト表示）';

  @override
  String get settingsMouseDoubleClick => 'フォルダに遷移 / ファイルを既定のアプリで開く';

  @override
  String get settingsMouseRightClick => 'コンテキストメニュー（フォルダ / ファイル別の操作一覧）';

  @override
  String get settingsMouseNavigation =>
      'ディレクトリ履歴を 1 つ戻る / 進む（AppBar の ← → と同等）';

  @override
  String get appearanceTitle => '外観';

  @override
  String appearanceLoadError(String error) {
    return '外観設定の読み込みに失敗しました: $error';
  }

  @override
  String get appearanceModeTransparent => '透過';

  @override
  String get appearanceModeSolid => '単色';

  @override
  String get appearanceModeImage => '画像';

  @override
  String get appearanceModeGradient => 'ロゴ';

  @override
  String get appearanceOpacityLabel => '不透明度';

  @override
  String get appearanceImageSelectButton => '画像を選択';

  @override
  String get appearanceCenterImageLabel => '中央画像';

  @override
  String get appearanceCenterImageDescription =>
      'ウィンドウの中央に重ねて表示します（短辺の 60% 程度のサイズ）。';

  @override
  String get appearanceCenterImageClear => 'クリア';

  @override
  String get keybindingsPageTitle => 'キーボードショートカット';

  @override
  String get keybindingsIntro =>
      '行をクリックしてショートカットを変更できます。修飾キー（⌘ ⌥ ⌃ ⇧）を 1 つ以上含める必要があり、他のコマンドと重複するキーは保存できません。';

  @override
  String get keybindingsResetAllButton => 'すべてデフォルトに戻す';

  @override
  String get keybindingsResetAllConfirmTitle => 'すべてデフォルトに戻しますか？';

  @override
  String get keybindingsResetAllConfirmMessage => 'すべてのショートカットを既定のキーコンビに戻します。';

  @override
  String get keybindingsResetOneTooltip => 'デフォルトに戻す';

  @override
  String get keyChordErrorMissingModifier => '修飾キー（⌘ ⌥ ⌃ ⇧）を 1 つ以上含めてください。';

  @override
  String get keyChordErrorReserved =>
      '⌘C / ⌘V / ⌘X / ⌘A / ⌘Z はコピー & ペースト等のテキスト編集用に予約されています。';

  @override
  String keyChordErrorAlreadyAssigned(String label) {
    return '「$label」に割り当て済みです。';
  }

  @override
  String keyChordRecorderTitle(String command) {
    return '$command のショートカット';
  }

  @override
  String get keyChordRecorderInstructions => '割り当てたいキーを押してください。';

  @override
  String get keyChordPlaceholderUnselected => '（未入力）';

  @override
  String get explorerNoItems => '表示できる項目がありません';

  @override
  String get explorerOpenGitViewTooltip => 'Git ビューを開く';

  @override
  String get explorerNotGitRepository => 'Git 管理下ではありません';

  @override
  String explorerPathNotFound(String input) {
    return 'パスが存在しません: $input';
  }

  @override
  String get explorerPropertyTitle => 'プロパティ';

  @override
  String explorerPropertyPathNotFound(String path) {
    return '対象が存在しません: $path';
  }

  @override
  String get explorerPropertyName => '名前';

  @override
  String get explorerPropertyPath => 'パス';

  @override
  String get explorerPropertyType => '種類';

  @override
  String get explorerPropertyTypeDirectory => 'ディレクトリ';

  @override
  String get explorerPropertyTypeFile => 'ファイル';

  @override
  String get explorerPropertySize => 'サイズ';

  @override
  String get explorerPropertyModified => '更新日時';

  @override
  String get explorerPropertyAccessed => 'アクセス日時';

  @override
  String get explorerPropertyChanged => 'status 変更日時';

  @override
  String get explorerPropertyPermission => 'パーミッション';

  @override
  String get explorerSidebarPlaces => '場所';

  @override
  String get explorerPlaceHome => 'ホーム';

  @override
  String get explorerPlaceDownloads => 'ダウンロード';

  @override
  String get explorerPlaceDesktop => 'デスクトップ';

  @override
  String get explorerPlaceDocuments => 'ドキュメント';

  @override
  String get explorerPlaceApplications => 'アプリケーション';

  @override
  String get explorerOpenOtherFolder => '別のフォルダを開く…';

  @override
  String get explorerSidebarFavorites => 'お気に入り';

  @override
  String get explorerFavoritesAddTooltip => 'お気に入りを追加 / フォルダを作成';

  @override
  String get explorerRegisterCurrentDirectory => 'フォーカス中のディレクトリを登録';

  @override
  String get explorerNewFavoriteFolder => '新しいフォルダ';

  @override
  String get explorerFavoriteFolderHint => '例: work / personal';

  @override
  String get explorerFavoriteDisplayNameHint => 'お気に入りの表示名';

  @override
  String get explorerFavoritesEmptyHint => '上の + でフォーカス中のディレクトリを登録';

  @override
  String get explorerRemoveFromFavorites => 'お気に入りから削除';

  @override
  String get explorerSidebarLaunchers => 'ランチャー';

  @override
  String get explorerLaunchersAddTooltip => 'エントリを追加 / フォルダを作成';

  @override
  String get explorerNewLauncherEntry => '新しいエントリ';

  @override
  String get explorerNewLauncherFolder => '新しいフォルダ';

  @override
  String get explorerLauncherFolderHint => '例: dev / ops';

  @override
  String get explorerLaunchersEmptyHint => 'ランチャーエントリを追加…（または、コンテキストメニューから登録）';

  @override
  String get explorerSidebarRunning => '実行中';

  @override
  String get explorerSessionDiscardTooltip => 'セッションを完全に破棄';

  @override
  String get explorerNavigateToPathTooltip => 'このパスに移動';

  @override
  String get explorerLaunchersRegisterHint => '上の + でエントリを登録';

  @override
  String get explorerManageLaunchers => 'ランチャーを管理…';

  @override
  String get explorerRunningEmpty => 'なし';

  @override
  String get explorerContextMenuAddFavorite => 'お気に入りに追加';

  @override
  String explorerContextMenuRunSkill(String skill) {
    return '「$skill」を即実行';
  }

  @override
  String explorerContextMenuRegisterSkill(String skill) {
    return '「$skill」をランチャーに登録';
  }

  @override
  String get explorerContextMenuOpenWith => '別のアプリケーションで開く…';

  @override
  String get explorerContextMenuOpenInVim => 'vim で開く';

  @override
  String get explorerPickAppTitle => '開くアプリを選択';

  @override
  String get explorerParentDirectoryLabel => '上の階層へ';

  @override
  String explorerSnackbarCopied(String name) {
    return 'コピーしました: $name';
  }

  @override
  String explorerSnackbarAddedFavorite(String name) {
    return 'お気に入りに追加しました: $name';
  }

  @override
  String explorerSnackbarOpenFailed(String error) {
    return '開けませんでした: $error';
  }

  @override
  String explorerSnackbarCopyFailed(String error) {
    return 'コピーに失敗しました: $error';
  }

  @override
  String explorerSnackbarMoveFailed(String error) {
    return '移動に失敗しました: $error';
  }

  @override
  String get explorerDefaultFolderName => '新規フォルダ';

  @override
  String get explorerDefaultFileName => '新規テキストファイル.txt';

  @override
  String get explorerNewFolderTitle => '新規フォルダ名';

  @override
  String get explorerNewFileTitle => '新規ファイル名';

  @override
  String get explorerRenameTitle => '名前を変更';

  @override
  String explorerSnackbarCreateFailed(String error) {
    return '作成に失敗しました: $error';
  }

  @override
  String explorerSnackbarRenameFailed(String error) {
    return 'リネームに失敗しました: $error';
  }

  @override
  String explorerSnackbarPasteFailed(String error) {
    return 'ペーストに失敗しました: $error';
  }

  @override
  String explorerSnackbarSourceNotFound(String sources) {
    return 'コピー元が見つかりません: $sources';
  }

  @override
  String get explorerDeleteConfirmTitle => '削除しますか？';

  @override
  String explorerDeleteConfirmMessage(String name) {
    return '「$name」をゴミ箱に移動します。';
  }

  @override
  String explorerSnackbarMovedToTrash(String name) {
    return 'ゴミ箱に移動しました: $name';
  }

  @override
  String explorerSnackbarMoveToTrashFailed(String error) {
    return 'ゴミ箱に移動できませんでした: $error';
  }

  @override
  String explorerSnackbarPathCopied(String path) {
    return 'パスをコピーしました: $path';
  }

  @override
  String explorerSnackbarItemCopied(String name) {
    return 'コピーしました: $name';
  }

  @override
  String explorerTerminalDisplayName(String name) {
    return '$name (Terminal)';
  }

  @override
  String explorerClaudeDisplayName(String name) {
    return '$name (Claude)';
  }

  @override
  String get folderDeleteConfirmTitle => 'フォルダを削除しますか？';

  @override
  String folderDeleteConfirmMessage(String name) {
    return '「$name」を削除します。中身のエントリは未分類に戻ります。';
  }

  @override
  String get folderDeleteWithContentsMenuItem => '削除（中身は未分類に戻る）';

  @override
  String get unclassified => '未分類';

  @override
  String get entryEditTitleNew => 'エントリ追加';

  @override
  String get entryEditTitleEdit => 'エントリ編集';

  @override
  String get entryEditDisplayNameLabel => '表示名';

  @override
  String get entryEditWorkingDirectoryLabel => '作業ディレクトリ';

  @override
  String get entryEditWorkingDirectoryHint => '/Users/you/path/to/dir';

  @override
  String get entryEditDirectorySelectTooltip => 'ディレクトリを選択';

  @override
  String get entryEditFolderLabel => 'フォルダ';

  @override
  String get entryEditFolderNone => 'フォルダなし（未分類）';

  @override
  String get entryEditActionTypeLabel => '動作';

  @override
  String get entryEditActionOpenHere => '開くだけ';

  @override
  String get entryEditActionRunCommand => 'コマンド実行';

  @override
  String get entryEditActionClaudeSkill => 'Claude Skill';

  @override
  String get entryEditClaudeUnavailableNoticeCurrent =>
      'Claude Code が未導入です。このエントリは Skill タイプですが、保存しても起動できません。「設定」画面のインストール手順を参照してください。';

  @override
  String get entryEditClaudeUnavailableNoticeGeneral =>
      'Claude Code が未導入のため「Claude Skill」タイプは無効化されています。「設定」画面のインストール手順を参照してください。';

  @override
  String get entryEditOpenHereDescription =>
      '指定した作業ディレクトリでログインシェル (\$SHELL) を起動し、プロンプトで停止します。';

  @override
  String get entryEditCommandLabel => '実行コマンド';

  @override
  String get entryEditCommandHint => 'npm run dev';

  @override
  String get entryEditCommandHelper => '\$SHELL -lc 経由で実行されます。&& や環境変数も使えます。';

  @override
  String get entryEditKeepShellAfterExitTitle => 'コマンド終了後もターミナルを残す';

  @override
  String get entryEditKeepShellAfterExitSubtitle =>
      '一発完結コマンド（make build 等）の結果を確認できます。常駐コマンド (npm run dev 等) では結果に影響しません。';

  @override
  String get entryEditSkillNameLabel => 'Skill 名';

  @override
  String get entryEditSkillNameHint => 'my-skill';

  @override
  String get entryEditSkillNameHelperNoSkills =>
      '作業ディレクトリ内の `.claude/skills/` から候補を取得します';

  @override
  String entryEditSkillNameHelperWithSkills(int count) {
    return '候補: $count 件';
  }

  @override
  String get entryEditSkillNameSelectTooltip => '候補から選択';

  @override
  String get launcherManagementTitle => 'ランチャー管理';

  @override
  String get launcherAddFolderTooltip => 'フォルダ追加';

  @override
  String get launcherAddEntryTooltip => 'エントリ追加';

  @override
  String launcherLoadError(String error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get launcherEmptyPlaceholder => '登録されたランチャーがまだありません';

  @override
  String get launcherAddEntryButton => 'エントリを追加';

  @override
  String get launcherFolderNameTitle => 'フォルダ名';

  @override
  String get launcherFolderNameHint => '例: dev / ops';

  @override
  String get launcherEmptyFolderHint => '（このフォルダは空です。エントリをここにドラッグして追加できます）';

  @override
  String get launcherEmptyRootHint =>
      '（未分類のエントリはありません。フォルダから「未分類」ヘッダにドラッグすると戻せます）';

  @override
  String get launcherDeleteEntryTooltip => '削除';

  @override
  String get launcherDeleteEntryConfirm => 'エントリを削除しますか？';

  @override
  String launcherDeleteEntryMessage(String name) {
    return '「$name」を削除します。この操作は取り消せません。';
  }

  @override
  String get launcherActionLabelOpenHere => '動作: 開くだけ';

  @override
  String launcherActionLabelRunCommand(String command) {
    return '動作: コマンド実行 — $command';
  }

  @override
  String launcherActionLabelClaudeSkill(String skillName) {
    return '動作: Claude Skill — $skillName';
  }

  @override
  String get gitMenuRefresh => '再読込';

  @override
  String get gitMenuStashSave => '変更を stash に退避';

  @override
  String gitMenuStashList(int count) {
    return 'stash 一覧 ($count)';
  }

  @override
  String get gitMenuForcePush => 'Push (--force-with-lease)';

  @override
  String get gitToolbarOverflowTooltip => 'その他の操作';

  @override
  String get gitStashSaveTitle => '変更を stash に退避';

  @override
  String get gitStashMessageLabel => 'メッセージ（任意）';

  @override
  String get gitStashSaveButton => '退避';

  @override
  String get gitForcePushMessage => 'リモートブランチを --force-with-lease で上書きします。';

  @override
  String get gitForcePushButton => 'Push';

  @override
  String get gitStashListTitle => 'stash 一覧';

  @override
  String get gitStashEmpty => 'stash はありません';

  @override
  String get gitStashApplyButton => '適用';

  @override
  String get gitStashPopButton => 'pop';

  @override
  String get gitStashDiscardTooltip => '破棄';

  @override
  String get gitStashDropTitle => 'stash を破棄';

  @override
  String gitStashDropMessage(String ref) {
    return '$ref を破棄します。';
  }

  @override
  String get gitStashDropButton => '破棄';

  @override
  String get gitBranchDialogTitle => 'ブランチ';

  @override
  String get gitBranchNewButton => '新規作成';

  @override
  String get gitBranchCreateTitle => 'ブランチを作成';

  @override
  String get gitBranchNameLabel => 'ブランチ名';

  @override
  String get gitBranchFilterHint => 'ブランチを絞り込み';

  @override
  String get gitBranchLocalLabel => 'ローカル';

  @override
  String get gitBranchRemoteLabel => 'リモート';

  @override
  String get gitBranchOperationsTooltip => 'ブランチ操作';

  @override
  String get gitBranchMergeMenuItem => '現在ブランチへマージ';

  @override
  String get gitBranchDeleteMenuItem => '削除';

  @override
  String get gitBranchDeleteConfirmTitle => 'ブランチを削除';

  @override
  String gitBranchDeleteConfirmMessage(String name) {
    return 'ブランチ「$name」を削除します。';
  }

  @override
  String get gitWorkingTreeClean => '作業ツリーはクリーンです';

  @override
  String get gitDiscardAllTooltip => 'すべて破棄';

  @override
  String get gitDiscardChangeTooltip => '変更を破棄';

  @override
  String get gitAmendPreviousCommit => '直前のコミットを修正（amend）';

  @override
  String get gitLoadMoreButton => 'さらに読み込む';

  @override
  String get gitCloseDetailsTooltip => '詳細を閉じる';

  @override
  String gitLoadError(String error) {
    return 'Git 情報の取得に失敗しました\n$error';
  }

  @override
  String get gitOpenInTerminal => 'ターミナルで開く';

  @override
  String get sessionRerunTooltip => '再実行';

  @override
  String get settingsButtonTooltip => '設定';

  @override
  String get paneTabCloseTooltip => 'タブを閉じる';

  @override
  String get paneTabAddTooltip => 'タブを追加';

  @override
  String get buttonDiscard => '破棄';

  @override
  String get buttonRename => 'リネーム';

  @override
  String get gitTabChanges => '変更';

  @override
  String get gitTabHistory => '履歴';

  @override
  String get gitStaged => 'ステージ済み';

  @override
  String get gitConflicts => 'コンフリクト';

  @override
  String gitTabChangesWithCount(int count) {
    return '変更 ($count)';
  }

  @override
  String gitTabHistoryWithCount(int count) {
    return '履歴 ($count)';
  }

  @override
  String get gitStageAll => 'すべて stage';

  @override
  String get gitUnstageAll => 'すべて unstage';

  @override
  String get gitStage => 'stage';

  @override
  String get gitUnstage => 'unstage';

  @override
  String gitDiscardAllConfirmMessage(int count) {
    return '$count 件のファイルの変更を破棄します。この操作は取り消せません。';
  }

  @override
  String gitDiscardFileConfirmMessage(String path) {
    return '$path の変更を破棄します。';
  }

  @override
  String get gitCommitMessageHint => 'コミットメッセージ';

  @override
  String get gitCommitButton => 'コミット';

  @override
  String get gitCommitOptionsTooltip => 'コミットオプション';

  @override
  String get gitCommitAndPush => 'コミット & プッシュ';

  @override
  String get gitNoCommits => 'コミットがありません';

  @override
  String get gitLoadingChangedFiles => '変更ファイルを読み込み中…';

  @override
  String get gitNotFoundTitle => 'git コマンドが見つかりません';

  @override
  String get gitNotFoundMessage => 'Git ビューを使うには git をインストールし、PATH を通してください。';

  @override
  String get gitForcePushTitle => 'force push';

  @override
  String gitTerminalDisplayName(String name) {
    return '$name (git)';
  }

  @override
  String get sessionStateIdle => '待機中';

  @override
  String get sessionStateStarting => '起動中…';

  @override
  String get sessionStateRunning => '実行中';

  @override
  String get sessionStateWaitingInput => '入力待ち';

  @override
  String sessionStateCompleted(int code) {
    return '完了 ($code)';
  }

  @override
  String sessionStateExited(int code) {
    return '終了 ($code)';
  }

  @override
  String get sessionStateFailed => '失敗';

  @override
  String get sessionStateCancelled => 'キャンセル';

  @override
  String get launcherFolderOperationsTooltip => 'フォルダ操作';
}
