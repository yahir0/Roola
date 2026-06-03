// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonConfirm => 'OK';

  @override
  String get buttonReset => 'Reset';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonCreate => 'Create';

  @override
  String get buttonChange => 'Change';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonSaving => 'Saving...';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get navBack => 'Back';

  @override
  String get navForward => 'Forward';

  @override
  String get navUp => 'Up one level';

  @override
  String get commandCategoryNavigation => 'Navigation';

  @override
  String get commandCategoryExplorer => 'Explorer';

  @override
  String get commandCategoryTab => 'Tabs / Panes';

  @override
  String get commandCategoryApp => 'Launcher / App';

  @override
  String get commandCategoryGit => 'Git';

  @override
  String get commandCopyPath => 'Copy path';

  @override
  String get commandCopyItem => 'Copy';

  @override
  String get commandPasteItem => 'Paste';

  @override
  String get commandRenameItem => 'Rename';

  @override
  String get commandMoveToTrash => 'Delete';

  @override
  String get commandNewFolder => 'New folder';

  @override
  String get commandNewFile => 'New text file';

  @override
  String get commandRevealInFinder => 'Reveal in Finder';

  @override
  String get commandOpenItem => 'Open';

  @override
  String get commandShowProperties => 'Properties';

  @override
  String get commandOpenTerminalHere => 'Open terminal here';

  @override
  String get explorerOpenTerminalCmdPrompt => 'Open Command Prompt';

  @override
  String get explorerOpenTerminalPowerShell => 'Open PowerShell';

  @override
  String get commandOpenClaudeHere => 'Open Claude Code here';

  @override
  String get commandNewExplorerTab => 'New explorer tab';

  @override
  String get commandNewTerminalTab => 'New terminal tab';

  @override
  String get commandCloseTab => 'Close tab';

  @override
  String get commandNextTab => 'Next tab';

  @override
  String get commandPreviousTab => 'Previous tab';

  @override
  String get commandMoveTabTopLeft => 'Move tab to top-left pane';

  @override
  String get commandMoveTabTopRight => 'Move tab to top-right pane';

  @override
  String get commandMoveTabBottom => 'Move tab to bottom pane';

  @override
  String get commandOpenLauncherManagement => 'Open launcher management';

  @override
  String get commandOpenSettings => 'Open settings';

  @override
  String get commandOpenKeybindings => 'Open keyboard shortcuts';

  @override
  String get commandGitRefresh => 'Refresh Git view';

  @override
  String get commandGitFetch => 'Fetch';

  @override
  String get commandGitPull => 'Pull';

  @override
  String get commandGitPush => 'Push';

  @override
  String get appMenuRoola => 'Roola';

  @override
  String get appMenuFile => 'File';

  @override
  String get appMenuEdit => 'Edit';

  @override
  String get appMenuView => 'View';

  @override
  String get appMenuTerminal => 'Terminal';

  @override
  String get appMenuGit => 'Git';

  @override
  String get appMenuPane => 'Pane';

  @override
  String get windowCloseConfirmTitle => 'Confirm quit';

  @override
  String windowCloseConfirmMessage(int count) {
    return '$count session(s) are still running.\nQuitting will terminate all PTYs and discard their output history.';
  }

  @override
  String get windowCloseConfirmButton => 'Quit';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageDescription =>
      'Choose the display language of the app.';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsExplorerTitle => 'Explorer';

  @override
  String get settingsExplorerDescription =>
      'Switch the row height and amount of detail of file / folder tiles.';

  @override
  String get explorerDensityCompact => 'Compact';

  @override
  String get explorerDensityComfortable => 'Comfortable';

  @override
  String get explorerDensityCompactDescription =>
      'Compact: same row height as the sidebar. Skill subtitle / chips are omitted.';

  @override
  String get explorerDensityComfortableDescription =>
      'Comfortable: roomier rows that also show the Skill subtitle and chips.';

  @override
  String get settingsClaudeIntegrationTitle => 'Claude Code integration';

  @override
  String get settingsClaudeIntegrationDescription =>
      'When Anthropic\'s Claude Code CLI is found on PATH, related features are enabled automatically.';

  @override
  String get claudeHealthChecking => 'Detecting…';

  @override
  String get claudeHealthCheckingDetail =>
      'Waiting for `claude --version` to run.';

  @override
  String get claudeHealthCheckError => 'Health check failed';

  @override
  String get claudeHealthCheckSuccess => 'Detected';

  @override
  String get claudeHealthCheckSuccessDetail =>
      'The `claude` command is available.';

  @override
  String claudeHealthVersion(String version) {
    return 'Version: $version';
  }

  @override
  String get claudeHealthCheckNotFound => 'Not detected';

  @override
  String get claudeHealthCheckNotFoundDetail =>
      'The `claude` command was not found on PATH.';

  @override
  String claudeHealthCheckNotFoundDetailWith(String detail) {
    return 'Details: $detail';
  }

  @override
  String get settingsClaudeFeatures => 'Features that get enabled';

  @override
  String get settingsClaudeFeature1 =>
      'Auto-detects `.claude/skills/` in explorer folders and shows a special icon and Skill chips';

  @override
  String get settingsClaudeFeature2 =>
      'Adds \"Open Claude Code\", \"Run Skill now\", and \"Register Skill to launcher\" to the right-click menu';

  @override
  String get settingsClaudeFeature3 =>
      'Lets you pick the \"Claude Code Skill\" action type when registering a launcher entry (runs `claude /skillname` with the given Skill name)';

  @override
  String get settingsClaudeInstallTitle => 'Installation steps';

  @override
  String get settingsClaudeInstallInstructions =>
      'With Node.js 18+ installed, run the following command:';

  @override
  String get settingsClaudeInstallCopyTooltip => 'Copy command';

  @override
  String get settingsClaudeInstallCopied => 'Copied the install command';

  @override
  String get settingsClaudeInstallAfter =>
      'After installing, restart Roola for it to be detected.';

  @override
  String get settingsTaskNotificationTitle => 'Task completion notifications';

  @override
  String get settingsTaskNotificationDescription =>
      'Get a system notification when Claude Code launched from Roola finishes a task and returns to the input prompt.';

  @override
  String get settingsTaskNotificationEnableLabel => 'Notifications';

  @override
  String get settingsTaskNotificationOn => 'On';

  @override
  String get settingsTaskNotificationOff => 'Off';

  @override
  String get settingsTaskNotificationAuthAuthorized =>
      'Notifications are allowed.';

  @override
  String get settingsTaskNotificationAuthDenied =>
      'Notifications are denied. Allow Roola notifications in System Settings.';

  @override
  String get settingsTaskNotificationAuthNotDetermined =>
      'Notification permission hasn\'t been requested yet. Tap \"Allow notifications\".';

  @override
  String get settingsTaskNotificationGrantButton => 'Allow notifications';

  @override
  String get settingsTaskNotificationOpenSettingsButton =>
      'Open System Settings';

  @override
  String get settingsTaskNotificationSetupTitle => 'Hook setup';

  @override
  String get settingsTaskNotificationSetupInstructions =>
      'Add the snippet below to the `hooks` section of `~/.claude/settings.json` (merge it into the `Stop` array if one already exists). The port is the one this Roola instance is listening on.';

  @override
  String settingsTaskNotificationPortLabel(int port) {
    return 'Listening port: $port';
  }

  @override
  String get settingsTaskNotificationCopyTooltip => 'Copy snippet';

  @override
  String get settingsTaskNotificationCopied => 'Copied hook configuration';

  @override
  String get settingsTaskNotificationJqNote =>
      'The token references the `\$ROOLA_NOTIFY_TOKEN` environment variable, so you don\'t need to re-paste after restarting Roola (only update it if the port number changes).';

  @override
  String get settingsTaskNotificationAutoSetupTitle => 'Auto setup';

  @override
  String get settingsTaskNotificationHookInstalled => 'Installed';

  @override
  String get settingsTaskNotificationHookNotInstalled => 'Not installed';

  @override
  String get settingsTaskNotificationInstallButton => 'Install automatically';

  @override
  String get settingsTaskNotificationUninstallButton => 'Remove';

  @override
  String get settingsTaskNotificationManualSetupTitle =>
      'Manual setup (reference)';

  @override
  String get settingsTaskNotificationBackupDialogTitle =>
      'Modifying settings.json';

  @override
  String get settingsTaskNotificationBackupDialogContent =>
      'This will modify your Claude Code settings file (settings.json).\n\nWe recommend creating a backup before proceeding.';

  @override
  String get settingsTaskNotificationBackupAndProceed => 'Back up and continue';

  @override
  String get settingsTaskNotificationProceedWithoutBackup =>
      'Continue without backup';

  @override
  String get settingsTaskNotificationBackupCreated => 'Backup created';

  @override
  String get settingsTaskNotificationInstallSuccess =>
      'Hook configuration installed';

  @override
  String get settingsTaskNotificationUninstallSuccess =>
      'Hook configuration removed';

  @override
  String get settingsTaskNotificationInstallError => 'An error occurred';

  @override
  String get settingsTaskNotificationStalePortNote =>
      'If the port number has changed, remove and reinstall.';

  @override
  String get settingsTaskNotificationPortFieldLabel => 'Listening port';

  @override
  String get settingsTaskNotificationPortHint => 'e.g. 51763';

  @override
  String get settingsTaskNotificationPortInvalid =>
      'Enter an integer between 1024 and 65535.';

  @override
  String get settingsTaskNotificationPortReinstallNote =>
      'Reinstall the hook after changing the port.';

  @override
  String get settingsKeyboardShortcutsTitle => 'Keyboard shortcuts';

  @override
  String get settingsKeyboardShortcutsDescription =>
      'All command shortcuts can be reviewed and changed on a dedicated screen.';

  @override
  String get settingsKeyboardShortcutsButton => 'Edit keyboard shortcuts…';

  @override
  String get settingsMouseOperationsTitle => 'Mouse operations';

  @override
  String get settingsMouseClick => 'Select a file / folder (highlighted)';

  @override
  String get settingsMouseDoubleClick =>
      'Enter a folder / open a file with the default app';

  @override
  String get settingsMouseRightClick =>
      'Context menu (operations specific to folders / files)';

  @override
  String get settingsMouseNavigation =>
      'Go back / forward one step in directory history (same as ← → in the AppBar)';

  @override
  String get settingsAboutTitle => 'About Roola';

  @override
  String get settingsAboutDescription =>
      'View the app version and licenses of the open-source software used by this app.';

  @override
  String get settingsAboutOpenButton => 'About Roola…';

  @override
  String get aboutMenuItem => 'About Roola…';

  @override
  String get checkForUpdatesMenuItem => 'Check for Updates…';

  @override
  String get aboutLegalese =>
      'Copyright © 2026 Yahiro\nDistributed under the MIT License.';

  @override
  String get aboutViewLicensesButton => 'View licenses';

  @override
  String get licensesPageTitle => 'Open source licenses';

  @override
  String licensesEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count licenses',
      one: '$count license',
    );
    return '$_temp0';
  }

  @override
  String licensesLoadError(String error) {
    return 'Failed to load licenses: $error';
  }

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String appearanceLoadError(String error) {
    return 'Failed to load appearance settings: $error';
  }

  @override
  String get appearanceBackgroundLabel => 'Background';

  @override
  String get appearanceModeOpaque => 'Opaque';

  @override
  String get appearanceModeTransparent => 'Transparent';

  @override
  String get appearanceAccentLabel => 'Accent color';

  @override
  String get appearanceOpacityLabel => 'Opacity';

  @override
  String get keybindingsPageTitle => 'Keyboard shortcuts';

  @override
  String get keybindingsIntro =>
      'Click a row to change its shortcut. It must include at least one modifier key (⌘ ⌥ ⌃ ⇧), and a key combination that conflicts with another command cannot be saved.';

  @override
  String get keybindingsResetAllButton => 'Reset all to defaults';

  @override
  String get keybindingsResetAllConfirmTitle => 'Reset all to defaults?';

  @override
  String get keybindingsResetAllConfirmMessage =>
      'Resets every shortcut to its default key combination.';

  @override
  String get keybindingsResetOneTooltip => 'Reset to default';

  @override
  String get keyChordErrorMissingModifier =>
      'Include at least one modifier key (⌘ ⌥ ⌃ ⇧).';

  @override
  String get keyChordErrorReserved =>
      '⌘C / ⌘V / ⌘X / ⌘A / ⌘Z are reserved for text editing (copy & paste, etc.).';

  @override
  String keyChordErrorAlreadyAssigned(String label) {
    return 'Already assigned to \"$label\".';
  }

  @override
  String keyChordRecorderTitle(String command) {
    return 'Shortcut for $command';
  }

  @override
  String get keyChordRecorderInstructions =>
      'Press the key you want to assign.';

  @override
  String get keyChordPlaceholderUnselected => '(none)';

  @override
  String get explorerNoItems => 'There are no items to show';

  @override
  String get explorerOpenGitViewTooltip => 'Open Git view';

  @override
  String get explorerNotGitRepository => 'Not under Git management';

  @override
  String explorerPathNotFound(String input) {
    return 'Path does not exist: $input';
  }

  @override
  String get filePreviewTitle => 'Preview';

  @override
  String get filePreviewEmpty => 'Select a file to preview';

  @override
  String get filePreviewBinary => 'Preview unavailable (binary file)';

  @override
  String filePreviewTooLarge(String size) {
    return 'File too large to preview ($size)';
  }

  @override
  String filePreviewFailed(String message) {
    return 'Cannot show preview: $message';
  }

  @override
  String get filePreviewTruncated => 'Showing the beginning of the file only';

  @override
  String get filePreviewRefreshTooltip => 'Reload';

  @override
  String get filePreviewImageError => 'Cannot display this image';

  @override
  String get filePreviewPdfError => 'Cannot display this PDF';

  @override
  String get explorerPropertyTitle => 'Properties';

  @override
  String explorerPropertyPathNotFound(String path) {
    return 'Target does not exist: $path';
  }

  @override
  String get explorerPropertyName => 'Name';

  @override
  String get explorerPropertyPath => 'Path';

  @override
  String get explorerPropertyType => 'Type';

  @override
  String get explorerPropertyTypeDirectory => 'Directory';

  @override
  String get explorerPropertyTypeFile => 'File';

  @override
  String get explorerPropertySize => 'Size';

  @override
  String get explorerPropertyModified => 'Modified';

  @override
  String get explorerPropertyAccessed => 'Accessed';

  @override
  String get explorerPropertyChanged => 'Status changed';

  @override
  String get explorerPropertyPermission => 'Permissions';

  @override
  String get explorerSidebarPlaces => 'Places';

  @override
  String get explorerPlaceHome => 'Home';

  @override
  String get explorerPlaceDownloads => 'Downloads';

  @override
  String get explorerPlaceDesktop => 'Desktop';

  @override
  String get explorerPlaceDocuments => 'Documents';

  @override
  String get explorerPlaceApplications => 'Applications';

  @override
  String get explorerOpenOtherFolder => 'Open another folder…';

  @override
  String get explorerSidebarFavorites => 'Favorites';

  @override
  String get explorerFavoritesAddTooltip => 'Add favorite / create folder';

  @override
  String get explorerRegisterCurrentDirectory =>
      'Register the focused directory';

  @override
  String get explorerNewFavoriteFolder => 'New folder';

  @override
  String get explorerFavoriteFolderHint => 'e.g. work / personal';

  @override
  String get explorerFavoriteDisplayNameHint => 'Favorite display name';

  @override
  String get explorerFavoritesEmptyHint =>
      'Use + above to register the focused directory';

  @override
  String get explorerRemoveFromFavorites => 'Remove from favorites';

  @override
  String get explorerSidebarLaunchers => 'Launcher';

  @override
  String get explorerLaunchersAddTooltip => 'Add entry / create folder';

  @override
  String get explorerNewLauncherEntry => 'New entry';

  @override
  String get explorerNewLauncherFolder => 'New folder';

  @override
  String get explorerLauncherFolderHint => 'e.g. dev / ops';

  @override
  String get explorerLaunchersEmptyHint =>
      'Add a launcher entry… (or register from the context menu)';

  @override
  String get explorerSidebarRunning => 'Running';

  @override
  String get explorerSessionDiscardTooltip => 'Discard the session entirely';

  @override
  String get explorerNavigateToPathTooltip => 'Go to this path';

  @override
  String get explorerLaunchersRegisterHint =>
      'Use + above to register an entry';

  @override
  String get explorerManageLaunchers => 'Manage launchers…';

  @override
  String get explorerRunningEmpty => 'None';

  @override
  String get explorerContextMenuAddFavorite => 'Add to favorites';

  @override
  String explorerContextMenuRunSkill(String skill) {
    return 'Run \"$skill\" now';
  }

  @override
  String explorerContextMenuRegisterSkill(String skill) {
    return 'Register \"$skill\" to launcher';
  }

  @override
  String get explorerContextMenuOpenWith => 'Open with another application…';

  @override
  String get explorerContextMenuOpenInVim => 'Open in vim';

  @override
  String explorerContextMenuCurrentFolder(String name) {
    return 'Actions for $name';
  }

  @override
  String get explorerPickAppTitle => 'Choose an app to open with';

  @override
  String get explorerParentDirectoryLabel => 'Up one level';

  @override
  String explorerSnackbarCopied(String name) {
    return 'Copied: $name';
  }

  @override
  String explorerSnackbarAddedFavorite(String name) {
    return 'Added to favorites: $name';
  }

  @override
  String explorerSnackbarOpenFailed(String error) {
    return 'Could not open: $error';
  }

  @override
  String explorerSnackbarCopyFailed(String error) {
    return 'Copy failed: $error';
  }

  @override
  String explorerSnackbarMoveFailed(String error) {
    return 'Move failed: $error';
  }

  @override
  String get explorerDefaultFolderName => 'New folder';

  @override
  String get explorerDefaultFileName => 'New text file.txt';

  @override
  String get explorerNewFolderTitle => 'New folder name';

  @override
  String get explorerNewFileTitle => 'New file name';

  @override
  String get explorerRenameTitle => 'Rename';

  @override
  String explorerSnackbarCreateFailed(String error) {
    return 'Failed to create: $error';
  }

  @override
  String explorerSnackbarRenameFailed(String error) {
    return 'Failed to rename: $error';
  }

  @override
  String explorerSnackbarPasteFailed(String error) {
    return 'Failed to paste: $error';
  }

  @override
  String explorerSnackbarSourceNotFound(String sources) {
    return 'Copy source not found: $sources';
  }

  @override
  String get explorerDeleteConfirmTitle => 'Delete?';

  @override
  String explorerDeleteConfirmMessage(String name) {
    return '\"$name\" will be moved to the Trash.';
  }

  @override
  String explorerSnackbarMovedToTrash(String name) {
    return 'Moved to Trash: $name';
  }

  @override
  String explorerSnackbarMoveToTrashFailed(String error) {
    return 'Could not move to Trash: $error';
  }

  @override
  String explorerSnackbarPathCopied(String path) {
    return 'Copied path: $path';
  }

  @override
  String explorerSnackbarItemCopied(String name) {
    return 'Copied: $name';
  }

  @override
  String explorerTerminalDisplayName(String name) {
    return '$name (Terminal)';
  }

  @override
  String explorerClaudeDisplayName(String name) {
    return '$name (Claude Code)';
  }

  @override
  String get folderDeleteConfirmTitle => 'Delete folder?';

  @override
  String folderDeleteConfirmMessage(String name) {
    return '\"$name\" will be deleted. Its entries return to Unclassified.';
  }

  @override
  String get folderDeleteWithContentsMenuItem =>
      'Delete (contents return to Unclassified)';

  @override
  String get unclassified => 'Unclassified';

  @override
  String get entryEditTitleNew => 'Add entry';

  @override
  String get entryEditTitleEdit => 'Edit entry';

  @override
  String get entryEditDisplayNameLabel => 'Display name';

  @override
  String get entryEditWorkingDirectoryLabel => 'Working directory';

  @override
  String get entryEditWorkingDirectoryHint => '/Users/you/path/to/dir';

  @override
  String get entryEditDirectorySelectTooltip => 'Select directory';

  @override
  String get entryEditFolderLabel => 'Folder';

  @override
  String get entryEditFolderNone => 'No folder (Unclassified)';

  @override
  String get entryEditActionTypeLabel => 'Action';

  @override
  String get entryEditActionOpenHere => 'Open only';

  @override
  String get entryEditActionRunCommand => 'Run command';

  @override
  String get entryEditActionClaudeSkill => 'Claude Code Skill';

  @override
  String get entryEditClaudeUnavailableNoticeCurrent =>
      'Claude Code is not installed. This entry is a Skill type, so it cannot be launched even if saved. See the installation steps on the \"Settings\" screen.';

  @override
  String get entryEditClaudeUnavailableNoticeGeneral =>
      'The \"Claude Code Skill\" type is disabled because Claude Code is not installed. See the installation steps on the \"Settings\" screen.';

  @override
  String get entryEditOpenHereDescription =>
      'Starts a login shell (\$SHELL) in the specified working directory and stops at the prompt.';

  @override
  String get entryEditCommandLabel => 'Command to run';

  @override
  String get entryEditCommandHint => 'npm run dev';

  @override
  String get entryEditCommandHelper =>
      'Runs via \$SHELL -lc. You can use && and environment variables.';

  @override
  String get entryEditKeepShellAfterExitTitle =>
      'Keep the terminal after the command exits';

  @override
  String get entryEditKeepShellAfterExitSubtitle =>
      'Lets you review the result of one-shot commands (e.g. make build). Has no effect on long-running commands (e.g. npm run dev).';

  @override
  String get entryEditSkillNameLabel => 'Skill name';

  @override
  String get entryEditSkillNameHint => 'my-skill';

  @override
  String get entryEditSkillNameHelperNoSkills =>
      'Suggestions are taken from `.claude/skills/` in the working directory';

  @override
  String entryEditSkillNameHelperWithSkills(int count) {
    return '$count suggestion(s)';
  }

  @override
  String get entryEditSkillNameSelectTooltip => 'Select from suggestions';

  @override
  String get launcherManagementTitle => 'Launcher management';

  @override
  String get launcherAddFolderTooltip => 'Add folder';

  @override
  String get launcherAddEntryTooltip => 'Add entry';

  @override
  String launcherLoadError(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get launcherEmptyPlaceholder => 'No launchers registered yet';

  @override
  String get launcherAddEntryButton => 'Add entry';

  @override
  String get launcherFolderNameTitle => 'Folder name';

  @override
  String get launcherFolderNameHint => 'e.g. dev / ops';

  @override
  String get launcherEmptyFolderHint =>
      '(This folder is empty. Drag entries here to add them.)';

  @override
  String get launcherEmptyRootHint =>
      '(There are no unclassified entries. Drag from a folder to the \"Unclassified\" header to return them.)';

  @override
  String get launcherDeleteEntryTooltip => 'Delete';

  @override
  String get launcherDeleteEntryConfirm => 'Delete entry?';

  @override
  String launcherDeleteEntryMessage(String name) {
    return '\"$name\" will be deleted. This action cannot be undone.';
  }

  @override
  String get launcherActionLabelOpenHere => 'Action: Open only';

  @override
  String launcherActionLabelRunCommand(String command) {
    return 'Action: Run command — $command';
  }

  @override
  String launcherActionLabelClaudeSkill(String skillName) {
    return 'Action: Claude Code Skill — $skillName';
  }

  @override
  String get gitMenuRefresh => 'Reload';

  @override
  String get gitMenuStashSave => 'Stash changes';

  @override
  String gitMenuStashList(int count) {
    return 'Stash list ($count)';
  }

  @override
  String get gitMenuForcePush => 'Push (--force-with-lease)';

  @override
  String get gitToolbarOverflowTooltip => 'More actions';

  @override
  String get gitStashSaveTitle => 'Stash changes';

  @override
  String get gitStashMessageLabel => 'Message (optional)';

  @override
  String get gitStashSaveButton => 'Stash';

  @override
  String get gitForcePushMessage =>
      'Overwrites the remote branch with --force-with-lease.';

  @override
  String get gitForcePushButton => 'Push';

  @override
  String get gitStashListTitle => 'Stash list';

  @override
  String get gitStashEmpty => 'No stashes';

  @override
  String get gitStashApplyButton => 'Apply';

  @override
  String get gitStashPopButton => 'Pop';

  @override
  String get gitStashDiscardTooltip => 'Discard';

  @override
  String get gitStashDropTitle => 'Discard stash';

  @override
  String gitStashDropMessage(String ref) {
    return '$ref will be discarded.';
  }

  @override
  String get gitStashDropButton => 'Discard';

  @override
  String get gitBranchDialogTitle => 'Branches';

  @override
  String get gitBranchNewButton => 'Create new';

  @override
  String get gitBranchCreateTitle => 'Create branch';

  @override
  String get gitBranchNameLabel => 'Branch name';

  @override
  String get gitBranchFilterHint => 'Filter branches';

  @override
  String get gitBranchLocalLabel => 'Local';

  @override
  String get gitBranchRemoteLabel => 'Remote';

  @override
  String get gitBranchOperationsTooltip => 'Branch operations';

  @override
  String get gitBranchMergeMenuItem => 'Merge into current branch';

  @override
  String get gitBranchDeleteMenuItem => 'Delete';

  @override
  String get gitBranchDeleteConfirmTitle => 'Delete branch';

  @override
  String gitBranchDeleteConfirmMessage(String name) {
    return 'Branch \"$name\" will be deleted.';
  }

  @override
  String get gitWorkingTreeClean => 'Working tree is clean';

  @override
  String get gitDiscardAllTooltip => 'Discard all';

  @override
  String get gitDiscardChangeTooltip => 'Discard change';

  @override
  String get gitAmendPreviousCommit => 'Amend the previous commit';

  @override
  String get gitLoadMoreButton => 'Load more';

  @override
  String get gitCloseDetailsTooltip => 'Close details';

  @override
  String gitLoadError(String error) {
    return 'Failed to get Git information\n$error';
  }

  @override
  String get gitOpenInTerminal => 'Open in terminal';

  @override
  String get sessionRerunTooltip => 'Re-run';

  @override
  String get settingsButtonTooltip => 'Settings';

  @override
  String get paneTabCloseTooltip => 'Close tab';

  @override
  String get paneTabAddTooltip => 'Add tab';

  @override
  String get notepadButtonTooltip => 'Notepad';

  @override
  String get notepadTitle => 'Notepad';

  @override
  String get notepadHint => 'Jot a note…';

  @override
  String activityMonitorCpuTooltip(String percent) {
    return 'CPU $percent%';
  }

  @override
  String activityMonitorMemoryTooltip(String percent) {
    return 'Memory $percent%';
  }

  @override
  String get activityMonitorCpuPopoverTitle => 'Top processes — CPU';

  @override
  String get activityMonitorMemoryPopoverTitle => 'Top processes — Memory';

  @override
  String get activityMonitorColumnCpu => 'CPU';

  @override
  String get activityMonitorColumnMemory => 'MEM';

  @override
  String get activityMonitorEmpty => 'No process data available';

  @override
  String get buttonDiscard => 'Discard';

  @override
  String get buttonRename => 'Rename';

  @override
  String get gitTabChanges => 'Changes';

  @override
  String get gitTabHistory => 'History';

  @override
  String get gitStaged => 'Staged';

  @override
  String get gitConflicts => 'Conflicts';

  @override
  String gitTabChangesWithCount(int count) {
    return 'Changes ($count)';
  }

  @override
  String gitTabHistoryWithCount(int count) {
    return 'History ($count)';
  }

  @override
  String get gitStageAll => 'Stage all';

  @override
  String get gitUnstageAll => 'Unstage all';

  @override
  String get gitStage => 'Stage';

  @override
  String get gitUnstage => 'Unstage';

  @override
  String gitDiscardAllConfirmMessage(int count) {
    return 'Discards changes to $count file(s). This action cannot be undone.';
  }

  @override
  String gitDiscardFileConfirmMessage(String path) {
    return 'Discards changes to $path.';
  }

  @override
  String get gitCommitMessageHint => 'Commit message';

  @override
  String get gitCommitButton => 'Commit';

  @override
  String get gitCommitOptionsTooltip => 'Commit options';

  @override
  String get gitCommitAndPush => 'Commit & Push';

  @override
  String get gitNoCommits => 'No commits';

  @override
  String get gitLoadingChangedFiles => 'Loading changed files…';

  @override
  String get gitNotFoundTitle => 'git command not found';

  @override
  String get gitNotFoundMessage =>
      'Install git and add it to PATH to use the Git view.';

  @override
  String get gitForcePushTitle => 'Force push';

  @override
  String gitTerminalDisplayName(String name) {
    return '$name (git)';
  }

  @override
  String get sessionStateIdle => 'Idle';

  @override
  String get sessionStateStarting => 'Starting…';

  @override
  String get sessionStateRunning => 'Running';

  @override
  String get sessionStateWaitingInput => 'Waiting for input';

  @override
  String sessionStateCompleted(int code) {
    return 'Completed ($code)';
  }

  @override
  String sessionStateExited(int code) {
    return 'Exited ($code)';
  }

  @override
  String get sessionStateFailed => 'Failed';

  @override
  String get sessionStateCancelled => 'Cancelled';

  @override
  String get launcherFolderOperationsTooltip => 'Folder operations';
}
