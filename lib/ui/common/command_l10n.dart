import 'package:roola/data/keybindings/command_category.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/l10n/app_localizations.dart';

/// `CommandId` / `CommandCategory` を安定キーとして表示ラベルを解決する
/// `AppLocalizations` の拡張（ADR-0034）。
///
/// コマンドのメタデータ（`CommandRegistry` / data 層）はロケール非依存の
/// 識別子のみを持ち、表示文字列はこの拡張経由で UI 層が解決する。
extension CommandL10n on AppLocalizations {
  /// コマンドの表示ラベル（メニュー項目・設定画面の行ラベル）。
  String commandLabel(CommandId id) => switch (id) {
    CommandId.navigateBack => navBack,
    CommandId.navigateForward => navForward,
    CommandId.navigateUp => navUp,
    CommandId.copyPath => commandCopyPath,
    CommandId.copyItem => commandCopyItem,
    CommandId.pasteItem => commandPasteItem,
    CommandId.renameItem => commandRenameItem,
    CommandId.moveToTrash => commandMoveToTrash,
    CommandId.newFolder => commandNewFolder,
    CommandId.newFile => commandNewFile,
    CommandId.revealInFinder => commandRevealInFinder,
    CommandId.openItem => commandOpenItem,
    CommandId.showProperties => commandShowProperties,
    CommandId.openTerminalHere => commandOpenTerminalHere,
    CommandId.openClaudeHere => commandOpenClaudeHere,
    CommandId.newExplorerTab => commandNewExplorerTab,
    CommandId.newTerminalTab => commandNewTerminalTab,
    CommandId.closeTab => commandCloseTab,
    CommandId.nextTab => commandNextTab,
    CommandId.previousTab => commandPreviousTab,
    CommandId.moveTabTopLeft => commandMoveTabTopLeft,
    CommandId.moveTabTopRight => commandMoveTabTopRight,
    CommandId.moveTabBottom => commandMoveTabBottom,
    CommandId.openLauncherManagement => commandOpenLauncherManagement,
    CommandId.openSettings => commandOpenSettings,
    CommandId.openKeybindings => commandOpenKeybindings,
    CommandId.gitRefresh => commandGitRefresh,
    CommandId.gitFetch => commandGitFetch,
    CommandId.gitPull => commandGitPull,
    CommandId.gitPush => commandGitPush,
  };

  /// コマンドカテゴリの表示ラベル（設定画面の見出し・メニュー分け）。
  String commandCategoryLabel(CommandCategory category) => switch (category) {
    CommandCategory.navigation => commandCategoryNavigation,
    CommandCategory.explorer => commandCategoryExplorer,
    CommandCategory.tab => commandCategoryTab,
    CommandCategory.app => commandCategoryApp,
    CommandCategory.git => commandCategoryGit,
  };
}
