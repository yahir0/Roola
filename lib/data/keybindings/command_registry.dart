import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roola/data/keybindings/command_category.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_metadata.dart';
import 'package:roola/data/keybindings/key_chord.dart';

/// 全コマンドの静的メタデータ（既定キーコンビ・ラベル・アイコン）の単一の
/// 真実（ADR-0033）。メニューバー・コンテキストメニュー・設定画面はここを
/// 参照する。ユーザーのカスタム割り当ては `Keybindings` 側が保持する。
///
/// 既定キーコンビの方針（ADR-0033 / design D5）:
/// - すべて修飾キーを 1 つ以上含む
/// - macOS のテキスト編集（⌘C/⌘V/⌘X/⌘A/⌘Z）は使わない
/// - 既定どうしは衝突しない（衝突検出に引っかからないこと）
abstract final class CommandRegistry {
  /// `CommandId` → メタデータ。全コマンドを定義する。
  static final Map<CommandId, CommandMetadata> _all = {
    // ナビゲーション
    CommandId.navigateBack: _meta(
      CommandId.navigateBack,
      CommandCategory.navigation,
      Icons.arrow_back,
      _chord(LogicalKeyboardKey.bracketLeft, meta: true),
      contextDependent: true,
    ),
    CommandId.navigateForward: _meta(
      CommandId.navigateForward,
      CommandCategory.navigation,
      Icons.arrow_forward,
      _chord(LogicalKeyboardKey.bracketRight, meta: true),
      contextDependent: true,
    ),
    CommandId.navigateUp: _meta(
      CommandId.navigateUp,
      CommandCategory.navigation,
      Icons.arrow_upward,
      _chord(LogicalKeyboardKey.arrowUp, meta: true),
      contextDependent: true,
    ),

    // エクスプローラ
    CommandId.copyPath: _meta(
      CommandId.copyPath,
      CommandCategory.explorer,
      Icons.link,
      _chord(LogicalKeyboardKey.keyC, meta: true, shift: true),
      contextDependent: true,
    ),
    CommandId.copyItem: _meta(
      CommandId.copyItem,
      CommandCategory.explorer,
      Icons.content_copy,
      _chord(LogicalKeyboardKey.keyC, meta: true, alt: true),
      contextDependent: true,
    ),
    CommandId.pasteItem: _meta(
      CommandId.pasteItem,
      CommandCategory.explorer,
      Icons.content_paste,
      _chord(LogicalKeyboardKey.keyV, meta: true, alt: true),
      contextDependent: true,
    ),
    CommandId.renameItem: _meta(
      CommandId.renameItem,
      CommandCategory.explorer,
      Icons.drive_file_rename_outline,
      _chord(LogicalKeyboardKey.keyR, meta: true),
      contextDependent: true,
    ),
    CommandId.moveToTrash: _meta(
      CommandId.moveToTrash,
      CommandCategory.explorer,
      Icons.delete_outline,
      _chord(LogicalKeyboardKey.backspace, meta: true),
      contextDependent: true,
    ),
    CommandId.newFolder: _meta(
      CommandId.newFolder,
      CommandCategory.explorer,
      Icons.create_new_folder_outlined,
      _chord(LogicalKeyboardKey.keyN, meta: true, shift: true),
      contextDependent: true,
    ),
    CommandId.newFile: _meta(
      CommandId.newFile,
      CommandCategory.explorer,
      Icons.note_add_outlined,
      _chord(LogicalKeyboardKey.keyN, meta: true, alt: true),
      contextDependent: true,
    ),
    CommandId.revealInFinder: _meta(
      CommandId.revealInFinder,
      CommandCategory.explorer,
      Icons.folder_open,
      _chord(LogicalKeyboardKey.keyR, meta: true, alt: true),
      contextDependent: true,
    ),
    CommandId.openItem: _meta(
      CommandId.openItem,
      CommandCategory.explorer,
      Icons.open_in_new,
      _chord(LogicalKeyboardKey.keyO, meta: true),
      contextDependent: true,
    ),
    CommandId.showProperties: _meta(
      CommandId.showProperties,
      CommandCategory.explorer,
      Icons.info_outline,
      _chord(LogicalKeyboardKey.keyI, meta: true),
      contextDependent: true,
    ),
    CommandId.openTerminalHere: _meta(
      CommandId.openTerminalHere,
      CommandCategory.explorer,
      Icons.developer_mode,
      _chord(LogicalKeyboardKey.keyT, meta: true, control: true),
      contextDependent: true,
    ),
    CommandId.openClaudeHere: _meta(
      CommandId.openClaudeHere,
      CommandCategory.explorer,
      Icons.terminal,
      _chord(LogicalKeyboardKey.keyC, meta: true, control: true),
      contextDependent: true,
    ),

    // タブ / ペイン
    CommandId.newExplorerTab: _meta(
      CommandId.newExplorerTab,
      CommandCategory.tab,
      Icons.folder_outlined,
      _chord(LogicalKeyboardKey.keyT, meta: true),
    ),
    CommandId.newTerminalTab: _meta(
      CommandId.newTerminalTab,
      CommandCategory.tab,
      Icons.add_box_outlined,
      _chord(LogicalKeyboardKey.keyT, meta: true, shift: true),
    ),
    CommandId.closeTab: _meta(
      CommandId.closeTab,
      CommandCategory.tab,
      Icons.close,
      _chord(LogicalKeyboardKey.keyW, meta: true),
      contextDependent: true,
    ),
    CommandId.nextTab: _meta(
      CommandId.nextTab,
      CommandCategory.tab,
      Icons.chevron_right,
      _chord(LogicalKeyboardKey.tab, control: true),
      contextDependent: true,
    ),
    CommandId.previousTab: _meta(
      CommandId.previousTab,
      CommandCategory.tab,
      Icons.chevron_left,
      _chord(LogicalKeyboardKey.tab, control: true, shift: true),
      contextDependent: true,
    ),
    CommandId.moveTabTopLeft: _meta(
      CommandId.moveTabTopLeft,
      CommandCategory.tab,
      Icons.north_west,
      _chord(LogicalKeyboardKey.digit1, meta: true, control: true),
      contextDependent: true,
    ),
    CommandId.moveTabTopRight: _meta(
      CommandId.moveTabTopRight,
      CommandCategory.tab,
      Icons.north_east,
      _chord(LogicalKeyboardKey.digit2, meta: true, control: true),
      contextDependent: true,
    ),
    CommandId.moveTabBottom: _meta(
      CommandId.moveTabBottom,
      CommandCategory.tab,
      Icons.south,
      _chord(LogicalKeyboardKey.digit3, meta: true, control: true),
      contextDependent: true,
    ),

    // ランチャー / アプリ
    CommandId.openLauncherManagement: _meta(
      CommandId.openLauncherManagement,
      CommandCategory.app,
      Icons.apps,
      _chord(LogicalKeyboardKey.keyL, meta: true),
    ),
    CommandId.openSettings: _meta(
      CommandId.openSettings,
      CommandCategory.app,
      Icons.settings,
      _chord(LogicalKeyboardKey.comma, meta: true),
    ),
    CommandId.openKeybindings: _meta(
      CommandId.openKeybindings,
      CommandCategory.app,
      Icons.keyboard,
      _chord(LogicalKeyboardKey.comma, meta: true, alt: true),
    ),

    // Git
    CommandId.gitRefresh: _meta(
      CommandId.gitRefresh,
      CommandCategory.git,
      Icons.refresh,
      _chord(LogicalKeyboardKey.keyR, meta: true, shift: true),
      contextDependent: true,
    ),
    CommandId.gitFetch: _meta(
      CommandId.gitFetch,
      CommandCategory.git,
      Icons.sync,
      _chord(LogicalKeyboardKey.keyF, meta: true, shift: true),
      contextDependent: true,
    ),
    CommandId.gitPull: _meta(
      CommandId.gitPull,
      CommandCategory.git,
      Icons.download,
      _chord(LogicalKeyboardKey.keyL, meta: true, shift: true),
      contextDependent: true,
    ),
    CommandId.gitPush: _meta(
      CommandId.gitPush,
      CommandCategory.git,
      Icons.publish,
      _chord(LogicalKeyboardKey.keyU, meta: true, shift: true),
      contextDependent: true,
    ),
  };

  /// 指定コマンドのメタデータ。
  static CommandMetadata metadataFor(CommandId id) => _all[id]!;

  /// 全コマンドのメタデータ（`CommandId` の宣言順）。
  static List<CommandMetadata> get all =>
      CommandId.values.map(metadataFor).toList(growable: false);

  /// 指定カテゴリのコマンド（`CommandId` の宣言順）。
  static List<CommandMetadata> byCategory(CommandCategory category) =>
      all.where((m) => m.category == category).toList(growable: false);

  /// 全コマンドの既定キーコンビ。
  static Map<CommandId, KeyChord> get defaults => {
    for (final m in all) m.id: m.defaultChord,
  };
}

CommandMetadata _meta(
  CommandId id,
  CommandCategory category,
  IconData icon,
  KeyChord defaultChord, {
  bool contextDependent = false,
}) {
  return CommandMetadata(
    id: id,
    category: category,
    icon: icon,
    defaultChord: defaultChord,
    contextDependent: contextDependent,
  );
}

KeyChord _chord(
  LogicalKeyboardKey key, {
  bool meta = false,
  bool control = false,
  bool shift = false,
  bool alt = false,
}) {
  return KeyChord(
    triggerKeyId: key.keyId,
    meta: meta,
    control: control,
    shift: shift,
    alt: alt,
  );
}
