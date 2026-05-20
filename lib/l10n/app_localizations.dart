import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @buttonCancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get buttonCancel;

  /// No description provided for @buttonClose.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get buttonClose;

  /// No description provided for @buttonConfirm.
  ///
  /// In ja, this message translates to:
  /// **'決定'**
  String get buttonConfirm;

  /// No description provided for @buttonReset.
  ///
  /// In ja, this message translates to:
  /// **'戻す'**
  String get buttonReset;

  /// No description provided for @buttonDelete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get buttonDelete;

  /// No description provided for @buttonCreate.
  ///
  /// In ja, this message translates to:
  /// **'作成'**
  String get buttonCreate;

  /// No description provided for @buttonChange.
  ///
  /// In ja, this message translates to:
  /// **'変更'**
  String get buttonChange;

  /// No description provided for @buttonSave.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get buttonSave;

  /// No description provided for @buttonSaving.
  ///
  /// In ja, this message translates to:
  /// **'保存中...'**
  String get buttonSaving;

  /// No description provided for @buttonRetry.
  ///
  /// In ja, this message translates to:
  /// **'再試行'**
  String get buttonRetry;

  /// No description provided for @navBack.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get navBack;

  /// No description provided for @navForward.
  ///
  /// In ja, this message translates to:
  /// **'進む'**
  String get navForward;

  /// No description provided for @navUp.
  ///
  /// In ja, this message translates to:
  /// **'上の階層へ'**
  String get navUp;

  /// No description provided for @commandCategoryNavigation.
  ///
  /// In ja, this message translates to:
  /// **'ナビゲーション'**
  String get commandCategoryNavigation;

  /// No description provided for @commandCategoryExplorer.
  ///
  /// In ja, this message translates to:
  /// **'エクスプローラ'**
  String get commandCategoryExplorer;

  /// No description provided for @commandCategoryTab.
  ///
  /// In ja, this message translates to:
  /// **'タブ / ペイン'**
  String get commandCategoryTab;

  /// No description provided for @commandCategoryApp.
  ///
  /// In ja, this message translates to:
  /// **'ランチャー / アプリ'**
  String get commandCategoryApp;

  /// No description provided for @commandCategoryGit.
  ///
  /// In ja, this message translates to:
  /// **'Git'**
  String get commandCategoryGit;

  /// No description provided for @commandCopyPath.
  ///
  /// In ja, this message translates to:
  /// **'パスをコピー'**
  String get commandCopyPath;

  /// No description provided for @commandCopyItem.
  ///
  /// In ja, this message translates to:
  /// **'コピー'**
  String get commandCopyItem;

  /// No description provided for @commandPasteItem.
  ///
  /// In ja, this message translates to:
  /// **'ペースト'**
  String get commandPasteItem;

  /// No description provided for @commandRenameItem.
  ///
  /// In ja, this message translates to:
  /// **'名前を変更'**
  String get commandRenameItem;

  /// No description provided for @commandMoveToTrash.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get commandMoveToTrash;

  /// No description provided for @commandNewFolder.
  ///
  /// In ja, this message translates to:
  /// **'新規フォルダ'**
  String get commandNewFolder;

  /// No description provided for @commandNewFile.
  ///
  /// In ja, this message translates to:
  /// **'新規テキストファイル'**
  String get commandNewFile;

  /// No description provided for @commandRevealInFinder.
  ///
  /// In ja, this message translates to:
  /// **'Finder で表示'**
  String get commandRevealInFinder;

  /// No description provided for @commandOpenItem.
  ///
  /// In ja, this message translates to:
  /// **'開く'**
  String get commandOpenItem;

  /// No description provided for @commandShowProperties.
  ///
  /// In ja, this message translates to:
  /// **'プロパティ'**
  String get commandShowProperties;

  /// No description provided for @commandOpenTerminalHere.
  ///
  /// In ja, this message translates to:
  /// **'ここでターミナルを開く'**
  String get commandOpenTerminalHere;

  /// No description provided for @commandOpenClaudeHere.
  ///
  /// In ja, this message translates to:
  /// **'ここで Claude Code を開く'**
  String get commandOpenClaudeHere;

  /// No description provided for @commandNewExplorerTab.
  ///
  /// In ja, this message translates to:
  /// **'新規エクスプローラタブ'**
  String get commandNewExplorerTab;

  /// No description provided for @commandNewTerminalTab.
  ///
  /// In ja, this message translates to:
  /// **'新規ターミナルタブ'**
  String get commandNewTerminalTab;

  /// No description provided for @commandCloseTab.
  ///
  /// In ja, this message translates to:
  /// **'タブを閉じる'**
  String get commandCloseTab;

  /// No description provided for @commandNextTab.
  ///
  /// In ja, this message translates to:
  /// **'次のタブ'**
  String get commandNextTab;

  /// No description provided for @commandPreviousTab.
  ///
  /// In ja, this message translates to:
  /// **'前のタブ'**
  String get commandPreviousTab;

  /// No description provided for @commandMoveTabTopLeft.
  ///
  /// In ja, this message translates to:
  /// **'タブを左上ペインへ移動'**
  String get commandMoveTabTopLeft;

  /// No description provided for @commandMoveTabTopRight.
  ///
  /// In ja, this message translates to:
  /// **'タブを右上ペインへ移動'**
  String get commandMoveTabTopRight;

  /// No description provided for @commandMoveTabBottom.
  ///
  /// In ja, this message translates to:
  /// **'タブを下ペインへ移動'**
  String get commandMoveTabBottom;

  /// No description provided for @commandOpenLauncherManagement.
  ///
  /// In ja, this message translates to:
  /// **'ランチャー管理を開く'**
  String get commandOpenLauncherManagement;

  /// No description provided for @commandOpenSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定を開く'**
  String get commandOpenSettings;

  /// No description provided for @commandOpenKeybindings.
  ///
  /// In ja, this message translates to:
  /// **'キーボードショートカットを開く'**
  String get commandOpenKeybindings;

  /// No description provided for @commandGitRefresh.
  ///
  /// In ja, this message translates to:
  /// **'Git ビューを更新'**
  String get commandGitRefresh;

  /// No description provided for @commandGitFetch.
  ///
  /// In ja, this message translates to:
  /// **'フェッチ'**
  String get commandGitFetch;

  /// No description provided for @commandGitPull.
  ///
  /// In ja, this message translates to:
  /// **'プル'**
  String get commandGitPull;

  /// No description provided for @commandGitPush.
  ///
  /// In ja, this message translates to:
  /// **'プッシュ'**
  String get commandGitPush;

  /// No description provided for @appMenuRoola.
  ///
  /// In ja, this message translates to:
  /// **'Roola'**
  String get appMenuRoola;

  /// No description provided for @appMenuFile.
  ///
  /// In ja, this message translates to:
  /// **'ファイル'**
  String get appMenuFile;

  /// No description provided for @appMenuEdit.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get appMenuEdit;

  /// No description provided for @appMenuView.
  ///
  /// In ja, this message translates to:
  /// **'表示'**
  String get appMenuView;

  /// No description provided for @appMenuTerminal.
  ///
  /// In ja, this message translates to:
  /// **'ターミナル'**
  String get appMenuTerminal;

  /// No description provided for @appMenuGit.
  ///
  /// In ja, this message translates to:
  /// **'Git'**
  String get appMenuGit;

  /// No description provided for @appMenuPane.
  ///
  /// In ja, this message translates to:
  /// **'ペイン'**
  String get appMenuPane;

  /// No description provided for @windowCloseConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'終了の確認'**
  String get windowCloseConfirmTitle;

  /// No description provided for @windowCloseConfirmMessage.
  ///
  /// In ja, this message translates to:
  /// **'{count} 件のセッションが残っています。\n終了するとすべての PTY が終了され、出力履歴も失われます。'**
  String windowCloseConfirmMessage(int count);

  /// No description provided for @windowCloseConfirmButton.
  ///
  /// In ja, this message translates to:
  /// **'終了する'**
  String get windowCloseConfirmButton;

  /// No description provided for @settingsPageTitle.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingsPageTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In ja, this message translates to:
  /// **'アプリの表示言語を選択します。'**
  String get settingsLanguageDescription;

  /// No description provided for @languageJapanese.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageEnglish.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsExplorerTitle.
  ///
  /// In ja, this message translates to:
  /// **'エクスプローラ'**
  String get settingsExplorerTitle;

  /// No description provided for @settingsExplorerDescription.
  ///
  /// In ja, this message translates to:
  /// **'ファイル / フォルダタイルの縦幅と情報量を切替えます。'**
  String get settingsExplorerDescription;

  /// No description provided for @explorerDensityCompact.
  ///
  /// In ja, this message translates to:
  /// **'コンパクト'**
  String get explorerDensityCompact;

  /// No description provided for @explorerDensityComfortable.
  ///
  /// In ja, this message translates to:
  /// **'ゆったり'**
  String get explorerDensityComfortable;

  /// No description provided for @explorerDensityCompactDescription.
  ///
  /// In ja, this message translates to:
  /// **'コンパクト: サイドバーと同じ縦幅。Skill サブタイトル / チップは省略。'**
  String get explorerDensityCompactDescription;

  /// No description provided for @explorerDensityComfortableDescription.
  ///
  /// In ja, this message translates to:
  /// **'ゆったり: 縦幅にゆとりを持たせ、Skill サブタイトルとチップも表示。'**
  String get explorerDensityComfortableDescription;

  /// No description provided for @settingsClaudeIntegrationTitle.
  ///
  /// In ja, this message translates to:
  /// **'Claude Code 連携'**
  String get settingsClaudeIntegrationTitle;

  /// No description provided for @settingsClaudeIntegrationDescription.
  ///
  /// In ja, this message translates to:
  /// **'Anthropic の Claude Code CLI が PATH 上で見つかると、関連機能が自動で有効化されます。'**
  String get settingsClaudeIntegrationDescription;

  /// No description provided for @claudeHealthChecking.
  ///
  /// In ja, this message translates to:
  /// **'検出中…'**
  String get claudeHealthChecking;

  /// No description provided for @claudeHealthCheckingDetail.
  ///
  /// In ja, this message translates to:
  /// **'`claude --version` の実行を待っています。'**
  String get claudeHealthCheckingDetail;

  /// No description provided for @claudeHealthCheckError.
  ///
  /// In ja, this message translates to:
  /// **'ヘルスチェックに失敗'**
  String get claudeHealthCheckError;

  /// No description provided for @claudeHealthCheckSuccess.
  ///
  /// In ja, this message translates to:
  /// **'検出済み'**
  String get claudeHealthCheckSuccess;

  /// No description provided for @claudeHealthCheckSuccessDetail.
  ///
  /// In ja, this message translates to:
  /// **'`claude` コマンドが利用可能です。'**
  String get claudeHealthCheckSuccessDetail;

  /// No description provided for @claudeHealthVersion.
  ///
  /// In ja, this message translates to:
  /// **'Version: {version}'**
  String claudeHealthVersion(String version);

  /// No description provided for @claudeHealthCheckNotFound.
  ///
  /// In ja, this message translates to:
  /// **'未検出'**
  String get claudeHealthCheckNotFound;

  /// No description provided for @claudeHealthCheckNotFoundDetail.
  ///
  /// In ja, this message translates to:
  /// **'`claude` コマンドが PATH 上で見つかりませんでした。'**
  String get claudeHealthCheckNotFoundDetail;

  /// No description provided for @claudeHealthCheckNotFoundDetailWith.
  ///
  /// In ja, this message translates to:
  /// **'詳細: {detail}'**
  String claudeHealthCheckNotFoundDetailWith(String detail);

  /// No description provided for @settingsClaudeFeatures.
  ///
  /// In ja, this message translates to:
  /// **'有効化される機能'**
  String get settingsClaudeFeatures;

  /// No description provided for @settingsClaudeFeature1.
  ///
  /// In ja, this message translates to:
  /// **'エクスプローラのフォルダで `.claude/skills/` を自動検知し、特別アイコンと Skill チップを表示'**
  String get settingsClaudeFeature1;

  /// No description provided for @settingsClaudeFeature2.
  ///
  /// In ja, this message translates to:
  /// **'右クリックメニューに「Claude Code を開く」「Skill を即実行」「Skill をランチャーに登録」を追加'**
  String get settingsClaudeFeature2;

  /// No description provided for @settingsClaudeFeature3.
  ///
  /// In ja, this message translates to:
  /// **'ランチャー登録時に「Claude Code Skill」動作タイプを選べる（Skill 名を指定して `claude /skillname` を起動）'**
  String get settingsClaudeFeature3;

  /// No description provided for @settingsClaudeInstallTitle.
  ///
  /// In ja, this message translates to:
  /// **'インストール手順'**
  String get settingsClaudeInstallTitle;

  /// No description provided for @settingsClaudeInstallInstructions.
  ///
  /// In ja, this message translates to:
  /// **'Node.js 18+ がある状態で次のコマンドを実行してください:'**
  String get settingsClaudeInstallInstructions;

  /// No description provided for @settingsClaudeInstallCopyTooltip.
  ///
  /// In ja, this message translates to:
  /// **'コマンドをコピー'**
  String get settingsClaudeInstallCopyTooltip;

  /// No description provided for @settingsClaudeInstallCopied.
  ///
  /// In ja, this message translates to:
  /// **'インストールコマンドをコピーしました'**
  String get settingsClaudeInstallCopied;

  /// No description provided for @settingsClaudeInstallAfter.
  ///
  /// In ja, this message translates to:
  /// **'インストール後、Roola を再起動すると検出されます。'**
  String get settingsClaudeInstallAfter;

  /// No description provided for @settingsKeyboardShortcutsTitle.
  ///
  /// In ja, this message translates to:
  /// **'キーボードショートカット'**
  String get settingsKeyboardShortcutsTitle;

  /// No description provided for @settingsKeyboardShortcutsDescription.
  ///
  /// In ja, this message translates to:
  /// **'すべてのコマンドのショートカットは専用画面で確認・変更できます。'**
  String get settingsKeyboardShortcutsDescription;

  /// No description provided for @settingsKeyboardShortcutsButton.
  ///
  /// In ja, this message translates to:
  /// **'キーボードショートカットを編集…'**
  String get settingsKeyboardShortcutsButton;

  /// No description provided for @settingsMouseOperationsTitle.
  ///
  /// In ja, this message translates to:
  /// **'マウス操作'**
  String get settingsMouseOperationsTitle;

  /// No description provided for @settingsMouseClick.
  ///
  /// In ja, this message translates to:
  /// **'ファイル / フォルダを選択（ハイライト表示）'**
  String get settingsMouseClick;

  /// No description provided for @settingsMouseDoubleClick.
  ///
  /// In ja, this message translates to:
  /// **'フォルダに遷移 / ファイルを既定のアプリで開く'**
  String get settingsMouseDoubleClick;

  /// No description provided for @settingsMouseRightClick.
  ///
  /// In ja, this message translates to:
  /// **'コンテキストメニュー（フォルダ / ファイル別の操作一覧）'**
  String get settingsMouseRightClick;

  /// No description provided for @settingsMouseNavigation.
  ///
  /// In ja, this message translates to:
  /// **'ディレクトリ履歴を 1 つ戻る / 進む（AppBar の ← → と同等）'**
  String get settingsMouseNavigation;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In ja, this message translates to:
  /// **'Roola について'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In ja, this message translates to:
  /// **'アプリのバージョンと、本アプリで利用しているオープンソースソフトウェアのライセンスを確認できます。'**
  String get settingsAboutDescription;

  /// No description provided for @settingsAboutOpenButton.
  ///
  /// In ja, this message translates to:
  /// **'Roola について…'**
  String get settingsAboutOpenButton;

  /// No description provided for @aboutMenuItem.
  ///
  /// In ja, this message translates to:
  /// **'Roola について…'**
  String get aboutMenuItem;

  /// No description provided for @aboutLegalese.
  ///
  /// In ja, this message translates to:
  /// **'Copyright © 2026 Yahiro\nMIT License で配布しています。'**
  String get aboutLegalese;

  /// No description provided for @appearanceTitle.
  ///
  /// In ja, this message translates to:
  /// **'外観'**
  String get appearanceTitle;

  /// No description provided for @appearanceLoadError.
  ///
  /// In ja, this message translates to:
  /// **'外観設定の読み込みに失敗しました: {error}'**
  String appearanceLoadError(String error);

  /// No description provided for @appearanceBackgroundLabel.
  ///
  /// In ja, this message translates to:
  /// **'背景'**
  String get appearanceBackgroundLabel;

  /// No description provided for @appearanceModeOpaque.
  ///
  /// In ja, this message translates to:
  /// **'不透明'**
  String get appearanceModeOpaque;

  /// No description provided for @appearanceModeTransparent.
  ///
  /// In ja, this message translates to:
  /// **'透過'**
  String get appearanceModeTransparent;

  /// No description provided for @appearanceAccentLabel.
  ///
  /// In ja, this message translates to:
  /// **'アクセントカラー'**
  String get appearanceAccentLabel;

  /// No description provided for @appearanceOpacityLabel.
  ///
  /// In ja, this message translates to:
  /// **'不透明度'**
  String get appearanceOpacityLabel;

  /// No description provided for @appearanceImageSelectButton.
  ///
  /// In ja, this message translates to:
  /// **'画像を選択'**
  String get appearanceImageSelectButton;

  /// No description provided for @appearanceCenterImageLabel.
  ///
  /// In ja, this message translates to:
  /// **'中央画像'**
  String get appearanceCenterImageLabel;

  /// No description provided for @appearanceCenterImageDescription.
  ///
  /// In ja, this message translates to:
  /// **'ウィンドウの中央に重ねて表示します（短辺の 60% 程度のサイズ）。'**
  String get appearanceCenterImageDescription;

  /// No description provided for @appearanceCenterImageClear.
  ///
  /// In ja, this message translates to:
  /// **'クリア'**
  String get appearanceCenterImageClear;

  /// No description provided for @keybindingsPageTitle.
  ///
  /// In ja, this message translates to:
  /// **'キーボードショートカット'**
  String get keybindingsPageTitle;

  /// No description provided for @keybindingsIntro.
  ///
  /// In ja, this message translates to:
  /// **'行をクリックしてショートカットを変更できます。修飾キー（⌘ ⌥ ⌃ ⇧）を 1 つ以上含める必要があり、他のコマンドと重複するキーは保存できません。'**
  String get keybindingsIntro;

  /// No description provided for @keybindingsResetAllButton.
  ///
  /// In ja, this message translates to:
  /// **'すべてデフォルトに戻す'**
  String get keybindingsResetAllButton;

  /// No description provided for @keybindingsResetAllConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'すべてデフォルトに戻しますか？'**
  String get keybindingsResetAllConfirmTitle;

  /// No description provided for @keybindingsResetAllConfirmMessage.
  ///
  /// In ja, this message translates to:
  /// **'すべてのショートカットを既定のキーコンビに戻します。'**
  String get keybindingsResetAllConfirmMessage;

  /// No description provided for @keybindingsResetOneTooltip.
  ///
  /// In ja, this message translates to:
  /// **'デフォルトに戻す'**
  String get keybindingsResetOneTooltip;

  /// No description provided for @keyChordErrorMissingModifier.
  ///
  /// In ja, this message translates to:
  /// **'修飾キー（⌘ ⌥ ⌃ ⇧）を 1 つ以上含めてください。'**
  String get keyChordErrorMissingModifier;

  /// No description provided for @keyChordErrorReserved.
  ///
  /// In ja, this message translates to:
  /// **'⌘C / ⌘V / ⌘X / ⌘A / ⌘Z はコピー & ペースト等のテキスト編集用に予約されています。'**
  String get keyChordErrorReserved;

  /// No description provided for @keyChordErrorAlreadyAssigned.
  ///
  /// In ja, this message translates to:
  /// **'「{label}」に割り当て済みです。'**
  String keyChordErrorAlreadyAssigned(String label);

  /// No description provided for @keyChordRecorderTitle.
  ///
  /// In ja, this message translates to:
  /// **'{command} のショートカット'**
  String keyChordRecorderTitle(String command);

  /// No description provided for @keyChordRecorderInstructions.
  ///
  /// In ja, this message translates to:
  /// **'割り当てたいキーを押してください。'**
  String get keyChordRecorderInstructions;

  /// No description provided for @keyChordPlaceholderUnselected.
  ///
  /// In ja, this message translates to:
  /// **'（未入力）'**
  String get keyChordPlaceholderUnselected;

  /// No description provided for @explorerNoItems.
  ///
  /// In ja, this message translates to:
  /// **'表示できる項目がありません'**
  String get explorerNoItems;

  /// No description provided for @explorerOpenGitViewTooltip.
  ///
  /// In ja, this message translates to:
  /// **'Git ビューを開く'**
  String get explorerOpenGitViewTooltip;

  /// No description provided for @explorerNotGitRepository.
  ///
  /// In ja, this message translates to:
  /// **'Git 管理下ではありません'**
  String get explorerNotGitRepository;

  /// No description provided for @explorerPathNotFound.
  ///
  /// In ja, this message translates to:
  /// **'パスが存在しません: {input}'**
  String explorerPathNotFound(String input);

  /// No description provided for @explorerPropertyTitle.
  ///
  /// In ja, this message translates to:
  /// **'プロパティ'**
  String get explorerPropertyTitle;

  /// No description provided for @explorerPropertyPathNotFound.
  ///
  /// In ja, this message translates to:
  /// **'対象が存在しません: {path}'**
  String explorerPropertyPathNotFound(String path);

  /// No description provided for @explorerPropertyName.
  ///
  /// In ja, this message translates to:
  /// **'名前'**
  String get explorerPropertyName;

  /// No description provided for @explorerPropertyPath.
  ///
  /// In ja, this message translates to:
  /// **'パス'**
  String get explorerPropertyPath;

  /// No description provided for @explorerPropertyType.
  ///
  /// In ja, this message translates to:
  /// **'種類'**
  String get explorerPropertyType;

  /// No description provided for @explorerPropertyTypeDirectory.
  ///
  /// In ja, this message translates to:
  /// **'ディレクトリ'**
  String get explorerPropertyTypeDirectory;

  /// No description provided for @explorerPropertyTypeFile.
  ///
  /// In ja, this message translates to:
  /// **'ファイル'**
  String get explorerPropertyTypeFile;

  /// No description provided for @explorerPropertySize.
  ///
  /// In ja, this message translates to:
  /// **'サイズ'**
  String get explorerPropertySize;

  /// No description provided for @explorerPropertyModified.
  ///
  /// In ja, this message translates to:
  /// **'更新日時'**
  String get explorerPropertyModified;

  /// No description provided for @explorerPropertyAccessed.
  ///
  /// In ja, this message translates to:
  /// **'アクセス日時'**
  String get explorerPropertyAccessed;

  /// No description provided for @explorerPropertyChanged.
  ///
  /// In ja, this message translates to:
  /// **'status 変更日時'**
  String get explorerPropertyChanged;

  /// No description provided for @explorerPropertyPermission.
  ///
  /// In ja, this message translates to:
  /// **'パーミッション'**
  String get explorerPropertyPermission;

  /// 【未使用】サイドバーのセクション見出しは explorer_sidebar.dart で英語固定リテラル化したため未参照。再ローカライズしたくなったときの復帰用に残置。
  ///
  /// In ja, this message translates to:
  /// **'場所'**
  String get explorerSidebarPlaces;

  /// 【未使用】PLACES の初期項目は explorer_sidebar.dart で英語固定リテラル化したため未参照。再ローカライズ時の復帰用に残置。
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get explorerPlaceHome;

  /// 【未使用】PLACES の初期項目は explorer_sidebar.dart で英語固定リテラル化したため未参照。再ローカライズ時の復帰用に残置。
  ///
  /// In ja, this message translates to:
  /// **'ダウンロード'**
  String get explorerPlaceDownloads;

  /// 【未使用】PLACES の初期項目は explorer_sidebar.dart で英語固定リテラル化したため未参照。再ローカライズ時の復帰用に残置。
  ///
  /// In ja, this message translates to:
  /// **'デスクトップ'**
  String get explorerPlaceDesktop;

  /// 【未使用】PLACES の初期項目は explorer_sidebar.dart で英語固定リテラル化したため未参照。再ローカライズ時の復帰用に残置。
  ///
  /// In ja, this message translates to:
  /// **'ドキュメント'**
  String get explorerPlaceDocuments;

  /// 【未使用】PLACES の初期項目は explorer_sidebar.dart で英語固定リテラル化したため未参照。再ローカライズ時の復帰用に残置。
  ///
  /// In ja, this message translates to:
  /// **'アプリケーション'**
  String get explorerPlaceApplications;

  /// No description provided for @explorerOpenOtherFolder.
  ///
  /// In ja, this message translates to:
  /// **'別のフォルダを開く…'**
  String get explorerOpenOtherFolder;

  /// 【未使用】サイドバーのセクション見出しは explorer_sidebar.dart で英語固定リテラル化したため未参照。再ローカライズしたくなったときの復帰用に残置。
  ///
  /// In ja, this message translates to:
  /// **'お気に入り'**
  String get explorerSidebarFavorites;

  /// No description provided for @explorerFavoritesAddTooltip.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りを追加 / フォルダを作成'**
  String get explorerFavoritesAddTooltip;

  /// No description provided for @explorerRegisterCurrentDirectory.
  ///
  /// In ja, this message translates to:
  /// **'フォーカス中のディレクトリを登録'**
  String get explorerRegisterCurrentDirectory;

  /// No description provided for @explorerNewFavoriteFolder.
  ///
  /// In ja, this message translates to:
  /// **'新しいフォルダ'**
  String get explorerNewFavoriteFolder;

  /// No description provided for @explorerFavoriteFolderHint.
  ///
  /// In ja, this message translates to:
  /// **'例: work / personal'**
  String get explorerFavoriteFolderHint;

  /// No description provided for @explorerFavoriteDisplayNameHint.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りの表示名'**
  String get explorerFavoriteDisplayNameHint;

  /// No description provided for @explorerFavoritesEmptyHint.
  ///
  /// In ja, this message translates to:
  /// **'上の + でフォーカス中のディレクトリを登録'**
  String get explorerFavoritesEmptyHint;

  /// No description provided for @explorerRemoveFromFavorites.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りから削除'**
  String get explorerRemoveFromFavorites;

  /// 【未使用】サイドバーのセクション見出しは explorer_sidebar.dart で英語固定リテラル化したため未参照。再ローカライズしたくなったときの復帰用に残置。
  ///
  /// In ja, this message translates to:
  /// **'ランチャー'**
  String get explorerSidebarLaunchers;

  /// No description provided for @explorerLaunchersAddTooltip.
  ///
  /// In ja, this message translates to:
  /// **'エントリを追加 / フォルダを作成'**
  String get explorerLaunchersAddTooltip;

  /// No description provided for @explorerNewLauncherEntry.
  ///
  /// In ja, this message translates to:
  /// **'新しいエントリ'**
  String get explorerNewLauncherEntry;

  /// No description provided for @explorerNewLauncherFolder.
  ///
  /// In ja, this message translates to:
  /// **'新しいフォルダ'**
  String get explorerNewLauncherFolder;

  /// No description provided for @explorerLauncherFolderHint.
  ///
  /// In ja, this message translates to:
  /// **'例: dev / ops'**
  String get explorerLauncherFolderHint;

  /// No description provided for @explorerLaunchersEmptyHint.
  ///
  /// In ja, this message translates to:
  /// **'ランチャーエントリを追加…（または、コンテキストメニューから登録）'**
  String get explorerLaunchersEmptyHint;

  /// 【未使用】サイドバーのセクション見出しは explorer_sidebar.dart で英語固定リテラル化したため未参照。再ローカライズしたくなったときの復帰用に残置。
  ///
  /// In ja, this message translates to:
  /// **'実行中'**
  String get explorerSidebarRunning;

  /// No description provided for @explorerSessionDiscardTooltip.
  ///
  /// In ja, this message translates to:
  /// **'セッションを完全に破棄'**
  String get explorerSessionDiscardTooltip;

  /// No description provided for @explorerNavigateToPathTooltip.
  ///
  /// In ja, this message translates to:
  /// **'このパスに移動'**
  String get explorerNavigateToPathTooltip;

  /// No description provided for @explorerLaunchersRegisterHint.
  ///
  /// In ja, this message translates to:
  /// **'上の + でエントリを登録'**
  String get explorerLaunchersRegisterHint;

  /// No description provided for @explorerManageLaunchers.
  ///
  /// In ja, this message translates to:
  /// **'ランチャーを管理…'**
  String get explorerManageLaunchers;

  /// No description provided for @explorerRunningEmpty.
  ///
  /// In ja, this message translates to:
  /// **'なし'**
  String get explorerRunningEmpty;

  /// No description provided for @explorerContextMenuAddFavorite.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りに追加'**
  String get explorerContextMenuAddFavorite;

  /// No description provided for @explorerContextMenuRunSkill.
  ///
  /// In ja, this message translates to:
  /// **'「{skill}」を即実行'**
  String explorerContextMenuRunSkill(String skill);

  /// No description provided for @explorerContextMenuRegisterSkill.
  ///
  /// In ja, this message translates to:
  /// **'「{skill}」をランチャーに登録'**
  String explorerContextMenuRegisterSkill(String skill);

  /// No description provided for @explorerContextMenuOpenWith.
  ///
  /// In ja, this message translates to:
  /// **'別のアプリケーションで開く…'**
  String get explorerContextMenuOpenWith;

  /// No description provided for @explorerContextMenuOpenInVim.
  ///
  /// In ja, this message translates to:
  /// **'vim で開く'**
  String get explorerContextMenuOpenInVim;

  /// No description provided for @explorerPickAppTitle.
  ///
  /// In ja, this message translates to:
  /// **'開くアプリを選択'**
  String get explorerPickAppTitle;

  /// No description provided for @explorerParentDirectoryLabel.
  ///
  /// In ja, this message translates to:
  /// **'上の階層へ'**
  String get explorerParentDirectoryLabel;

  /// No description provided for @explorerSnackbarCopied.
  ///
  /// In ja, this message translates to:
  /// **'コピーしました: {name}'**
  String explorerSnackbarCopied(String name);

  /// No description provided for @explorerSnackbarAddedFavorite.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りに追加しました: {name}'**
  String explorerSnackbarAddedFavorite(String name);

  /// No description provided for @explorerSnackbarOpenFailed.
  ///
  /// In ja, this message translates to:
  /// **'開けませんでした: {error}'**
  String explorerSnackbarOpenFailed(String error);

  /// No description provided for @explorerSnackbarCopyFailed.
  ///
  /// In ja, this message translates to:
  /// **'コピーに失敗しました: {error}'**
  String explorerSnackbarCopyFailed(String error);

  /// No description provided for @explorerSnackbarMoveFailed.
  ///
  /// In ja, this message translates to:
  /// **'移動に失敗しました: {error}'**
  String explorerSnackbarMoveFailed(String error);

  /// No description provided for @explorerDefaultFolderName.
  ///
  /// In ja, this message translates to:
  /// **'新規フォルダ'**
  String get explorerDefaultFolderName;

  /// No description provided for @explorerDefaultFileName.
  ///
  /// In ja, this message translates to:
  /// **'新規テキストファイル.txt'**
  String get explorerDefaultFileName;

  /// No description provided for @explorerNewFolderTitle.
  ///
  /// In ja, this message translates to:
  /// **'新規フォルダ名'**
  String get explorerNewFolderTitle;

  /// No description provided for @explorerNewFileTitle.
  ///
  /// In ja, this message translates to:
  /// **'新規ファイル名'**
  String get explorerNewFileTitle;

  /// No description provided for @explorerRenameTitle.
  ///
  /// In ja, this message translates to:
  /// **'名前を変更'**
  String get explorerRenameTitle;

  /// No description provided for @explorerSnackbarCreateFailed.
  ///
  /// In ja, this message translates to:
  /// **'作成に失敗しました: {error}'**
  String explorerSnackbarCreateFailed(String error);

  /// No description provided for @explorerSnackbarRenameFailed.
  ///
  /// In ja, this message translates to:
  /// **'リネームに失敗しました: {error}'**
  String explorerSnackbarRenameFailed(String error);

  /// No description provided for @explorerSnackbarPasteFailed.
  ///
  /// In ja, this message translates to:
  /// **'ペーストに失敗しました: {error}'**
  String explorerSnackbarPasteFailed(String error);

  /// No description provided for @explorerSnackbarSourceNotFound.
  ///
  /// In ja, this message translates to:
  /// **'コピー元が見つかりません: {sources}'**
  String explorerSnackbarSourceNotFound(String sources);

  /// No description provided for @explorerDeleteConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'削除しますか？'**
  String get explorerDeleteConfirmTitle;

  /// No description provided for @explorerDeleteConfirmMessage.
  ///
  /// In ja, this message translates to:
  /// **'「{name}」をゴミ箱に移動します。'**
  String explorerDeleteConfirmMessage(String name);

  /// No description provided for @explorerSnackbarMovedToTrash.
  ///
  /// In ja, this message translates to:
  /// **'ゴミ箱に移動しました: {name}'**
  String explorerSnackbarMovedToTrash(String name);

  /// No description provided for @explorerSnackbarMoveToTrashFailed.
  ///
  /// In ja, this message translates to:
  /// **'ゴミ箱に移動できませんでした: {error}'**
  String explorerSnackbarMoveToTrashFailed(String error);

  /// No description provided for @explorerSnackbarPathCopied.
  ///
  /// In ja, this message translates to:
  /// **'パスをコピーしました: {path}'**
  String explorerSnackbarPathCopied(String path);

  /// No description provided for @explorerSnackbarItemCopied.
  ///
  /// In ja, this message translates to:
  /// **'コピーしました: {name}'**
  String explorerSnackbarItemCopied(String name);

  /// No description provided for @explorerTerminalDisplayName.
  ///
  /// In ja, this message translates to:
  /// **'{name} (Terminal)'**
  String explorerTerminalDisplayName(String name);

  /// No description provided for @explorerClaudeDisplayName.
  ///
  /// In ja, this message translates to:
  /// **'{name} (Claude Code)'**
  String explorerClaudeDisplayName(String name);

  /// No description provided for @folderDeleteConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'フォルダを削除しますか？'**
  String get folderDeleteConfirmTitle;

  /// No description provided for @folderDeleteConfirmMessage.
  ///
  /// In ja, this message translates to:
  /// **'「{name}」を削除します。中身のエントリは未分類に戻ります。'**
  String folderDeleteConfirmMessage(String name);

  /// No description provided for @folderDeleteWithContentsMenuItem.
  ///
  /// In ja, this message translates to:
  /// **'削除（中身は未分類に戻る）'**
  String get folderDeleteWithContentsMenuItem;

  /// No description provided for @unclassified.
  ///
  /// In ja, this message translates to:
  /// **'未分類'**
  String get unclassified;

  /// No description provided for @entryEditTitleNew.
  ///
  /// In ja, this message translates to:
  /// **'エントリ追加'**
  String get entryEditTitleNew;

  /// No description provided for @entryEditTitleEdit.
  ///
  /// In ja, this message translates to:
  /// **'エントリ編集'**
  String get entryEditTitleEdit;

  /// No description provided for @entryEditDisplayNameLabel.
  ///
  /// In ja, this message translates to:
  /// **'表示名'**
  String get entryEditDisplayNameLabel;

  /// No description provided for @entryEditWorkingDirectoryLabel.
  ///
  /// In ja, this message translates to:
  /// **'作業ディレクトリ'**
  String get entryEditWorkingDirectoryLabel;

  /// No description provided for @entryEditWorkingDirectoryHint.
  ///
  /// In ja, this message translates to:
  /// **'/Users/you/path/to/dir'**
  String get entryEditWorkingDirectoryHint;

  /// No description provided for @entryEditDirectorySelectTooltip.
  ///
  /// In ja, this message translates to:
  /// **'ディレクトリを選択'**
  String get entryEditDirectorySelectTooltip;

  /// No description provided for @entryEditFolderLabel.
  ///
  /// In ja, this message translates to:
  /// **'フォルダ'**
  String get entryEditFolderLabel;

  /// No description provided for @entryEditFolderNone.
  ///
  /// In ja, this message translates to:
  /// **'フォルダなし（未分類）'**
  String get entryEditFolderNone;

  /// No description provided for @entryEditActionTypeLabel.
  ///
  /// In ja, this message translates to:
  /// **'動作'**
  String get entryEditActionTypeLabel;

  /// No description provided for @entryEditActionOpenHere.
  ///
  /// In ja, this message translates to:
  /// **'開くだけ'**
  String get entryEditActionOpenHere;

  /// No description provided for @entryEditActionRunCommand.
  ///
  /// In ja, this message translates to:
  /// **'コマンド実行'**
  String get entryEditActionRunCommand;

  /// No description provided for @entryEditActionClaudeSkill.
  ///
  /// In ja, this message translates to:
  /// **'Claude Code Skill'**
  String get entryEditActionClaudeSkill;

  /// No description provided for @entryEditClaudeUnavailableNoticeCurrent.
  ///
  /// In ja, this message translates to:
  /// **'Claude Code が未導入です。このエントリは Skill タイプですが、保存しても起動できません。「設定」画面のインストール手順を参照してください。'**
  String get entryEditClaudeUnavailableNoticeCurrent;

  /// No description provided for @entryEditClaudeUnavailableNoticeGeneral.
  ///
  /// In ja, this message translates to:
  /// **'Claude Code が未導入のため「Claude Code Skill」タイプは無効化されています。「設定」画面のインストール手順を参照してください。'**
  String get entryEditClaudeUnavailableNoticeGeneral;

  /// No description provided for @entryEditOpenHereDescription.
  ///
  /// In ja, this message translates to:
  /// **'指定した作業ディレクトリでログインシェル (\$SHELL) を起動し、プロンプトで停止します。'**
  String get entryEditOpenHereDescription;

  /// No description provided for @entryEditCommandLabel.
  ///
  /// In ja, this message translates to:
  /// **'実行コマンド'**
  String get entryEditCommandLabel;

  /// No description provided for @entryEditCommandHint.
  ///
  /// In ja, this message translates to:
  /// **'npm run dev'**
  String get entryEditCommandHint;

  /// No description provided for @entryEditCommandHelper.
  ///
  /// In ja, this message translates to:
  /// **'\$SHELL -lc 経由で実行されます。&& や環境変数も使えます。'**
  String get entryEditCommandHelper;

  /// No description provided for @entryEditKeepShellAfterExitTitle.
  ///
  /// In ja, this message translates to:
  /// **'コマンド終了後もターミナルを残す'**
  String get entryEditKeepShellAfterExitTitle;

  /// No description provided for @entryEditKeepShellAfterExitSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'一発完結コマンド（make build 等）の結果を確認できます。常駐コマンド (npm run dev 等) では結果に影響しません。'**
  String get entryEditKeepShellAfterExitSubtitle;

  /// No description provided for @entryEditSkillNameLabel.
  ///
  /// In ja, this message translates to:
  /// **'Skill 名'**
  String get entryEditSkillNameLabel;

  /// No description provided for @entryEditSkillNameHint.
  ///
  /// In ja, this message translates to:
  /// **'my-skill'**
  String get entryEditSkillNameHint;

  /// No description provided for @entryEditSkillNameHelperNoSkills.
  ///
  /// In ja, this message translates to:
  /// **'作業ディレクトリ内の `.claude/skills/` から候補を取得します'**
  String get entryEditSkillNameHelperNoSkills;

  /// No description provided for @entryEditSkillNameHelperWithSkills.
  ///
  /// In ja, this message translates to:
  /// **'候補: {count} 件'**
  String entryEditSkillNameHelperWithSkills(int count);

  /// No description provided for @entryEditSkillNameSelectTooltip.
  ///
  /// In ja, this message translates to:
  /// **'候補から選択'**
  String get entryEditSkillNameSelectTooltip;

  /// No description provided for @launcherManagementTitle.
  ///
  /// In ja, this message translates to:
  /// **'ランチャー管理'**
  String get launcherManagementTitle;

  /// No description provided for @launcherAddFolderTooltip.
  ///
  /// In ja, this message translates to:
  /// **'フォルダ追加'**
  String get launcherAddFolderTooltip;

  /// No description provided for @launcherAddEntryTooltip.
  ///
  /// In ja, this message translates to:
  /// **'エントリ追加'**
  String get launcherAddEntryTooltip;

  /// No description provided for @launcherLoadError.
  ///
  /// In ja, this message translates to:
  /// **'読み込みに失敗しました: {error}'**
  String launcherLoadError(String error);

  /// No description provided for @launcherEmptyPlaceholder.
  ///
  /// In ja, this message translates to:
  /// **'登録されたランチャーがまだありません'**
  String get launcherEmptyPlaceholder;

  /// No description provided for @launcherAddEntryButton.
  ///
  /// In ja, this message translates to:
  /// **'エントリを追加'**
  String get launcherAddEntryButton;

  /// No description provided for @launcherFolderNameTitle.
  ///
  /// In ja, this message translates to:
  /// **'フォルダ名'**
  String get launcherFolderNameTitle;

  /// No description provided for @launcherFolderNameHint.
  ///
  /// In ja, this message translates to:
  /// **'例: dev / ops'**
  String get launcherFolderNameHint;

  /// No description provided for @launcherEmptyFolderHint.
  ///
  /// In ja, this message translates to:
  /// **'（このフォルダは空です。エントリをここにドラッグして追加できます）'**
  String get launcherEmptyFolderHint;

  /// No description provided for @launcherEmptyRootHint.
  ///
  /// In ja, this message translates to:
  /// **'（未分類のエントリはありません。フォルダから「未分類」ヘッダにドラッグすると戻せます）'**
  String get launcherEmptyRootHint;

  /// No description provided for @launcherDeleteEntryTooltip.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get launcherDeleteEntryTooltip;

  /// No description provided for @launcherDeleteEntryConfirm.
  ///
  /// In ja, this message translates to:
  /// **'エントリを削除しますか？'**
  String get launcherDeleteEntryConfirm;

  /// No description provided for @launcherDeleteEntryMessage.
  ///
  /// In ja, this message translates to:
  /// **'「{name}」を削除します。この操作は取り消せません。'**
  String launcherDeleteEntryMessage(String name);

  /// No description provided for @launcherActionLabelOpenHere.
  ///
  /// In ja, this message translates to:
  /// **'動作: 開くだけ'**
  String get launcherActionLabelOpenHere;

  /// No description provided for @launcherActionLabelRunCommand.
  ///
  /// In ja, this message translates to:
  /// **'動作: コマンド実行 — {command}'**
  String launcherActionLabelRunCommand(String command);

  /// No description provided for @launcherActionLabelClaudeSkill.
  ///
  /// In ja, this message translates to:
  /// **'動作: Claude Code Skill — {skillName}'**
  String launcherActionLabelClaudeSkill(String skillName);

  /// No description provided for @gitMenuRefresh.
  ///
  /// In ja, this message translates to:
  /// **'再読込'**
  String get gitMenuRefresh;

  /// No description provided for @gitMenuStashSave.
  ///
  /// In ja, this message translates to:
  /// **'変更を stash に退避'**
  String get gitMenuStashSave;

  /// No description provided for @gitMenuStashList.
  ///
  /// In ja, this message translates to:
  /// **'stash 一覧 ({count})'**
  String gitMenuStashList(int count);

  /// No description provided for @gitMenuForcePush.
  ///
  /// In ja, this message translates to:
  /// **'Push (--force-with-lease)'**
  String get gitMenuForcePush;

  /// No description provided for @gitToolbarOverflowTooltip.
  ///
  /// In ja, this message translates to:
  /// **'その他の操作'**
  String get gitToolbarOverflowTooltip;

  /// No description provided for @gitStashSaveTitle.
  ///
  /// In ja, this message translates to:
  /// **'変更を stash に退避'**
  String get gitStashSaveTitle;

  /// No description provided for @gitStashMessageLabel.
  ///
  /// In ja, this message translates to:
  /// **'メッセージ（任意）'**
  String get gitStashMessageLabel;

  /// No description provided for @gitStashSaveButton.
  ///
  /// In ja, this message translates to:
  /// **'退避'**
  String get gitStashSaveButton;

  /// No description provided for @gitForcePushMessage.
  ///
  /// In ja, this message translates to:
  /// **'リモートブランチを --force-with-lease で上書きします。'**
  String get gitForcePushMessage;

  /// No description provided for @gitForcePushButton.
  ///
  /// In ja, this message translates to:
  /// **'Push'**
  String get gitForcePushButton;

  /// No description provided for @gitStashListTitle.
  ///
  /// In ja, this message translates to:
  /// **'stash 一覧'**
  String get gitStashListTitle;

  /// No description provided for @gitStashEmpty.
  ///
  /// In ja, this message translates to:
  /// **'stash はありません'**
  String get gitStashEmpty;

  /// No description provided for @gitStashApplyButton.
  ///
  /// In ja, this message translates to:
  /// **'適用'**
  String get gitStashApplyButton;

  /// No description provided for @gitStashPopButton.
  ///
  /// In ja, this message translates to:
  /// **'pop'**
  String get gitStashPopButton;

  /// No description provided for @gitStashDiscardTooltip.
  ///
  /// In ja, this message translates to:
  /// **'破棄'**
  String get gitStashDiscardTooltip;

  /// No description provided for @gitStashDropTitle.
  ///
  /// In ja, this message translates to:
  /// **'stash を破棄'**
  String get gitStashDropTitle;

  /// No description provided for @gitStashDropMessage.
  ///
  /// In ja, this message translates to:
  /// **'{ref} を破棄します。'**
  String gitStashDropMessage(String ref);

  /// No description provided for @gitStashDropButton.
  ///
  /// In ja, this message translates to:
  /// **'破棄'**
  String get gitStashDropButton;

  /// No description provided for @gitBranchDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'ブランチ'**
  String get gitBranchDialogTitle;

  /// No description provided for @gitBranchNewButton.
  ///
  /// In ja, this message translates to:
  /// **'新規作成'**
  String get gitBranchNewButton;

  /// No description provided for @gitBranchCreateTitle.
  ///
  /// In ja, this message translates to:
  /// **'ブランチを作成'**
  String get gitBranchCreateTitle;

  /// No description provided for @gitBranchNameLabel.
  ///
  /// In ja, this message translates to:
  /// **'ブランチ名'**
  String get gitBranchNameLabel;

  /// No description provided for @gitBranchFilterHint.
  ///
  /// In ja, this message translates to:
  /// **'ブランチを絞り込み'**
  String get gitBranchFilterHint;

  /// No description provided for @gitBranchLocalLabel.
  ///
  /// In ja, this message translates to:
  /// **'ローカル'**
  String get gitBranchLocalLabel;

  /// No description provided for @gitBranchRemoteLabel.
  ///
  /// In ja, this message translates to:
  /// **'リモート'**
  String get gitBranchRemoteLabel;

  /// No description provided for @gitBranchOperationsTooltip.
  ///
  /// In ja, this message translates to:
  /// **'ブランチ操作'**
  String get gitBranchOperationsTooltip;

  /// No description provided for @gitBranchMergeMenuItem.
  ///
  /// In ja, this message translates to:
  /// **'現在ブランチへマージ'**
  String get gitBranchMergeMenuItem;

  /// No description provided for @gitBranchDeleteMenuItem.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get gitBranchDeleteMenuItem;

  /// No description provided for @gitBranchDeleteConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'ブランチを削除'**
  String get gitBranchDeleteConfirmTitle;

  /// No description provided for @gitBranchDeleteConfirmMessage.
  ///
  /// In ja, this message translates to:
  /// **'ブランチ「{name}」を削除します。'**
  String gitBranchDeleteConfirmMessage(String name);

  /// No description provided for @gitWorkingTreeClean.
  ///
  /// In ja, this message translates to:
  /// **'作業ツリーはクリーンです'**
  String get gitWorkingTreeClean;

  /// No description provided for @gitDiscardAllTooltip.
  ///
  /// In ja, this message translates to:
  /// **'すべて破棄'**
  String get gitDiscardAllTooltip;

  /// No description provided for @gitDiscardChangeTooltip.
  ///
  /// In ja, this message translates to:
  /// **'変更を破棄'**
  String get gitDiscardChangeTooltip;

  /// No description provided for @gitAmendPreviousCommit.
  ///
  /// In ja, this message translates to:
  /// **'直前のコミットを修正（amend）'**
  String get gitAmendPreviousCommit;

  /// No description provided for @gitLoadMoreButton.
  ///
  /// In ja, this message translates to:
  /// **'さらに読み込む'**
  String get gitLoadMoreButton;

  /// No description provided for @gitCloseDetailsTooltip.
  ///
  /// In ja, this message translates to:
  /// **'詳細を閉じる'**
  String get gitCloseDetailsTooltip;

  /// No description provided for @gitLoadError.
  ///
  /// In ja, this message translates to:
  /// **'Git 情報の取得に失敗しました\n{error}'**
  String gitLoadError(String error);

  /// No description provided for @gitOpenInTerminal.
  ///
  /// In ja, this message translates to:
  /// **'ターミナルで開く'**
  String get gitOpenInTerminal;

  /// No description provided for @sessionRerunTooltip.
  ///
  /// In ja, this message translates to:
  /// **'再実行'**
  String get sessionRerunTooltip;

  /// No description provided for @settingsButtonTooltip.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingsButtonTooltip;

  /// No description provided for @paneTabCloseTooltip.
  ///
  /// In ja, this message translates to:
  /// **'タブを閉じる'**
  String get paneTabCloseTooltip;

  /// No description provided for @paneTabAddTooltip.
  ///
  /// In ja, this message translates to:
  /// **'タブを追加'**
  String get paneTabAddTooltip;

  /// No description provided for @notepadButtonTooltip.
  ///
  /// In ja, this message translates to:
  /// **'ノートパッド'**
  String get notepadButtonTooltip;

  /// No description provided for @notepadTitle.
  ///
  /// In ja, this message translates to:
  /// **'ノートパッド'**
  String get notepadTitle;

  /// No description provided for @notepadHint.
  ///
  /// In ja, this message translates to:
  /// **'メモを入力…'**
  String get notepadHint;

  /// No description provided for @activityMonitorCpuTooltip.
  ///
  /// In ja, this message translates to:
  /// **'CPU {percent}%'**
  String activityMonitorCpuTooltip(String percent);

  /// No description provided for @activityMonitorMemoryTooltip.
  ///
  /// In ja, this message translates to:
  /// **'メモリ {percent}%'**
  String activityMonitorMemoryTooltip(String percent);

  /// No description provided for @activityMonitorCpuPopoverTitle.
  ///
  /// In ja, this message translates to:
  /// **'CPU 上位プロセス'**
  String get activityMonitorCpuPopoverTitle;

  /// No description provided for @activityMonitorMemoryPopoverTitle.
  ///
  /// In ja, this message translates to:
  /// **'メモリ上位プロセス'**
  String get activityMonitorMemoryPopoverTitle;

  /// No description provided for @activityMonitorColumnCpu.
  ///
  /// In ja, this message translates to:
  /// **'CPU'**
  String get activityMonitorColumnCpu;

  /// No description provided for @activityMonitorColumnMemory.
  ///
  /// In ja, this message translates to:
  /// **'メモリ'**
  String get activityMonitorColumnMemory;

  /// No description provided for @activityMonitorEmpty.
  ///
  /// In ja, this message translates to:
  /// **'プロセス情報を取得できません'**
  String get activityMonitorEmpty;

  /// No description provided for @buttonDiscard.
  ///
  /// In ja, this message translates to:
  /// **'破棄'**
  String get buttonDiscard;

  /// No description provided for @buttonRename.
  ///
  /// In ja, this message translates to:
  /// **'リネーム'**
  String get buttonRename;

  /// No description provided for @gitTabChanges.
  ///
  /// In ja, this message translates to:
  /// **'変更'**
  String get gitTabChanges;

  /// No description provided for @gitTabHistory.
  ///
  /// In ja, this message translates to:
  /// **'履歴'**
  String get gitTabHistory;

  /// No description provided for @gitStaged.
  ///
  /// In ja, this message translates to:
  /// **'ステージ済み'**
  String get gitStaged;

  /// No description provided for @gitConflicts.
  ///
  /// In ja, this message translates to:
  /// **'コンフリクト'**
  String get gitConflicts;

  /// No description provided for @gitTabChangesWithCount.
  ///
  /// In ja, this message translates to:
  /// **'変更 ({count})'**
  String gitTabChangesWithCount(int count);

  /// No description provided for @gitTabHistoryWithCount.
  ///
  /// In ja, this message translates to:
  /// **'履歴 ({count})'**
  String gitTabHistoryWithCount(int count);

  /// No description provided for @gitStageAll.
  ///
  /// In ja, this message translates to:
  /// **'すべて stage'**
  String get gitStageAll;

  /// No description provided for @gitUnstageAll.
  ///
  /// In ja, this message translates to:
  /// **'すべて unstage'**
  String get gitUnstageAll;

  /// No description provided for @gitStage.
  ///
  /// In ja, this message translates to:
  /// **'stage'**
  String get gitStage;

  /// No description provided for @gitUnstage.
  ///
  /// In ja, this message translates to:
  /// **'unstage'**
  String get gitUnstage;

  /// No description provided for @gitDiscardAllConfirmMessage.
  ///
  /// In ja, this message translates to:
  /// **'{count} 件のファイルの変更を破棄します。この操作は取り消せません。'**
  String gitDiscardAllConfirmMessage(int count);

  /// No description provided for @gitDiscardFileConfirmMessage.
  ///
  /// In ja, this message translates to:
  /// **'{path} の変更を破棄します。'**
  String gitDiscardFileConfirmMessage(String path);

  /// No description provided for @gitCommitMessageHint.
  ///
  /// In ja, this message translates to:
  /// **'コミットメッセージ'**
  String get gitCommitMessageHint;

  /// No description provided for @gitCommitButton.
  ///
  /// In ja, this message translates to:
  /// **'コミット'**
  String get gitCommitButton;

  /// No description provided for @gitCommitOptionsTooltip.
  ///
  /// In ja, this message translates to:
  /// **'コミットオプション'**
  String get gitCommitOptionsTooltip;

  /// No description provided for @gitCommitAndPush.
  ///
  /// In ja, this message translates to:
  /// **'コミット & プッシュ'**
  String get gitCommitAndPush;

  /// No description provided for @gitNoCommits.
  ///
  /// In ja, this message translates to:
  /// **'コミットがありません'**
  String get gitNoCommits;

  /// No description provided for @gitLoadingChangedFiles.
  ///
  /// In ja, this message translates to:
  /// **'変更ファイルを読み込み中…'**
  String get gitLoadingChangedFiles;

  /// No description provided for @gitNotFoundTitle.
  ///
  /// In ja, this message translates to:
  /// **'git コマンドが見つかりません'**
  String get gitNotFoundTitle;

  /// No description provided for @gitNotFoundMessage.
  ///
  /// In ja, this message translates to:
  /// **'Git ビューを使うには git をインストールし、PATH を通してください。'**
  String get gitNotFoundMessage;

  /// No description provided for @gitForcePushTitle.
  ///
  /// In ja, this message translates to:
  /// **'force push'**
  String get gitForcePushTitle;

  /// No description provided for @gitTerminalDisplayName.
  ///
  /// In ja, this message translates to:
  /// **'{name} (git)'**
  String gitTerminalDisplayName(String name);

  /// No description provided for @sessionStateIdle.
  ///
  /// In ja, this message translates to:
  /// **'待機中'**
  String get sessionStateIdle;

  /// No description provided for @sessionStateStarting.
  ///
  /// In ja, this message translates to:
  /// **'起動中…'**
  String get sessionStateStarting;

  /// No description provided for @sessionStateRunning.
  ///
  /// In ja, this message translates to:
  /// **'実行中'**
  String get sessionStateRunning;

  /// No description provided for @sessionStateWaitingInput.
  ///
  /// In ja, this message translates to:
  /// **'入力待ち'**
  String get sessionStateWaitingInput;

  /// No description provided for @sessionStateCompleted.
  ///
  /// In ja, this message translates to:
  /// **'完了 ({code})'**
  String sessionStateCompleted(int code);

  /// No description provided for @sessionStateExited.
  ///
  /// In ja, this message translates to:
  /// **'終了 ({code})'**
  String sessionStateExited(int code);

  /// No description provided for @sessionStateFailed.
  ///
  /// In ja, this message translates to:
  /// **'失敗'**
  String get sessionStateFailed;

  /// No description provided for @sessionStateCancelled.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get sessionStateCancelled;

  /// No description provided for @launcherFolderOperationsTooltip.
  ///
  /// In ja, this message translates to:
  /// **'フォルダ操作'**
  String get launcherFolderOperationsTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
