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
/// - macOS: 修飾キーを 1 つ以上含む。テキスト編集（⌘C/⌘V/⌘X/⌘A/⌘Z）は使わない
/// - Windows: ターミナル Ctrl シーケンスとの衝突を避けるため Ctrl+Shift ベース
///   （ADR-0058 Case A）。F2 / Delete は修飾キーなしで許可（Windows Explorer 慣習）
/// - 既定どうしは各プラットフォーム内で衝突しない
abstract final class CommandRegistry {
  /// `CommandId` → メタデータ。全コマンドを定義する。
  static final Map<CommandId, CommandMetadata> _all = {
    // ナビゲーション
    CommandId.navigateBack: _meta(
      CommandId.navigateBack,
      CommandCategory.navigation,
      Icons.arrow_back,
      _chord(LogicalKeyboardKey.bracketLeft, meta: true),
      windows: _wchord(LogicalKeyboardKey.arrowLeft, alt: true),
      contextDependent: true,
    ),
    CommandId.navigateForward: _meta(
      CommandId.navigateForward,
      CommandCategory.navigation,
      Icons.arrow_forward,
      _chord(LogicalKeyboardKey.bracketRight, meta: true),
      windows: _wchord(LogicalKeyboardKey.arrowRight, alt: true),
      contextDependent: true,
    ),
    CommandId.navigateUp: _meta(
      CommandId.navigateUp,
      CommandCategory.navigation,
      Icons.arrow_upward,
      _chord(LogicalKeyboardKey.arrowUp, meta: true),
      windows: _wchord(LogicalKeyboardKey.arrowUp, alt: true),
      contextDependent: true,
    ),

    // エクスプローラ
    CommandId.copyPath: _meta(
      CommandId.copyPath,
      CommandCategory.explorer,
      Icons.link,
      _chord(LogicalKeyboardKey.keyC, meta: true, shift: true),
      windows: _wchord(LogicalKeyboardKey.keyC, control: true, shift: true),
      contextDependent: true,
    ),
    CommandId.copyItem: _meta(
      CommandId.copyItem,
      CommandCategory.explorer,
      Icons.content_copy,
      _chord(LogicalKeyboardKey.keyC, meta: true, alt: true),
      windows: _wchord(LogicalKeyboardKey.keyC, control: true, alt: true),
      contextDependent: true,
    ),
    CommandId.pasteItem: _meta(
      CommandId.pasteItem,
      CommandCategory.explorer,
      Icons.content_paste,
      _chord(LogicalKeyboardKey.keyV, meta: true, alt: true),
      windows: _wchord(LogicalKeyboardKey.keyV, control: true, alt: true),
      contextDependent: true,
    ),
    CommandId.renameItem: _meta(
      CommandId.renameItem,
      CommandCategory.explorer,
      Icons.drive_file_rename_outline,
      _chord(LogicalKeyboardKey.keyR, meta: true),
      windows: _wchord(LogicalKeyboardKey.f2),
      contextDependent: true,
    ),
    CommandId.moveToTrash: _meta(
      CommandId.moveToTrash,
      CommandCategory.explorer,
      Icons.delete_outline,
      _chord(LogicalKeyboardKey.backspace, meta: true),
      windows: _wchord(LogicalKeyboardKey.delete),
      contextDependent: true,
    ),
    CommandId.newFolder: _meta(
      CommandId.newFolder,
      CommandCategory.explorer,
      Icons.create_new_folder_outlined,
      _chord(LogicalKeyboardKey.keyN, meta: true, shift: true),
      windows: _wchord(LogicalKeyboardKey.keyN, control: true, shift: true),
      contextDependent: true,
    ),
    CommandId.newFile: _meta(
      CommandId.newFile,
      CommandCategory.explorer,
      Icons.note_add_outlined,
      _chord(LogicalKeyboardKey.keyN, meta: true, alt: true),
      windows: _wchord(LogicalKeyboardKey.keyN, control: true, alt: true),
      contextDependent: true,
    ),
    CommandId.revealInFinder: _meta(
      CommandId.revealInFinder,
      CommandCategory.explorer,
      Icons.folder_open,
      _chord(LogicalKeyboardKey.keyR, meta: true, alt: true),
      windows: _wchord(LogicalKeyboardKey.keyR, control: true, alt: true),
      contextDependent: true,
    ),
    CommandId.openItem: _meta(
      CommandId.openItem,
      CommandCategory.explorer,
      Icons.open_in_new,
      _chord(LogicalKeyboardKey.keyO, meta: true),
      windows: _wchord(LogicalKeyboardKey.keyO, control: true, shift: true),
      contextDependent: true,
    ),
    CommandId.showProperties: _meta(
      CommandId.showProperties,
      CommandCategory.explorer,
      Icons.info_outline,
      _chord(LogicalKeyboardKey.keyI, meta: true),
      windows: _wchord(LogicalKeyboardKey.enter, alt: true),
      contextDependent: true,
    ),
    CommandId.openTerminalHere: _meta(
      CommandId.openTerminalHere,
      CommandCategory.explorer,
      Icons.developer_mode,
      _chord(LogicalKeyboardKey.keyT, meta: true, control: true),
      windows: _wchord(LogicalKeyboardKey.keyT, control: true, alt: true),
      contextDependent: true,
    ),
    CommandId.openClaudeHere: _meta(
      CommandId.openClaudeHere,
      CommandCategory.explorer,
      Icons.terminal,
      _chord(LogicalKeyboardKey.keyC, meta: true, control: true),
      windows: _wchord(LogicalKeyboardKey.keyG, control: true, alt: true),
      contextDependent: true,
    ),

    // タブ / ペイン
    CommandId.newExplorerTab: _meta(
      CommandId.newExplorerTab,
      CommandCategory.tab,
      Icons.folder_outlined,
      _chord(LogicalKeyboardKey.keyT, meta: true),
      windows: _wchord(LogicalKeyboardKey.keyT, control: true, shift: true),
    ),
    CommandId.newTerminalTab: _meta(
      CommandId.newTerminalTab,
      CommandCategory.tab,
      Icons.add_box_outlined,
      _chord(LogicalKeyboardKey.keyT, meta: true, shift: true),
      windows: _wchord(
        LogicalKeyboardKey.keyT,
        control: true,
        shift: true,
        alt: true,
      ),
    ),
    CommandId.closeTab: _meta(
      CommandId.closeTab,
      CommandCategory.tab,
      Icons.close,
      _chord(LogicalKeyboardKey.keyW, meta: true),
      windows: _wchord(LogicalKeyboardKey.keyW, control: true, shift: true),
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
      windows: _wchord(LogicalKeyboardKey.digit1, control: true, alt: true),
      contextDependent: true,
    ),
    CommandId.moveTabTopRight: _meta(
      CommandId.moveTabTopRight,
      CommandCategory.tab,
      Icons.north_east,
      _chord(LogicalKeyboardKey.digit2, meta: true, control: true),
      windows: _wchord(LogicalKeyboardKey.digit2, control: true, alt: true),
      contextDependent: true,
    ),
    CommandId.moveTabBottom: _meta(
      CommandId.moveTabBottom,
      CommandCategory.tab,
      Icons.south,
      _chord(LogicalKeyboardKey.digit3, meta: true, control: true),
      windows: _wchord(LogicalKeyboardKey.digit3, control: true, alt: true),
      contextDependent: true,
    ),

    // ランチャー / アプリ
    CommandId.openLauncherManagement: _meta(
      CommandId.openLauncherManagement,
      CommandCategory.app,
      Icons.apps,
      _chord(LogicalKeyboardKey.keyL, meta: true),
      windows: _wchord(LogicalKeyboardKey.keyL, control: true, shift: true),
    ),
    CommandId.openSettings: _meta(
      CommandId.openSettings,
      CommandCategory.app,
      Icons.settings,
      _chord(LogicalKeyboardKey.comma, meta: true),
      windows: _wchord(LogicalKeyboardKey.comma, control: true),
    ),
    CommandId.openKeybindings: _meta(
      CommandId.openKeybindings,
      CommandCategory.app,
      Icons.keyboard,
      _chord(LogicalKeyboardKey.comma, meta: true, alt: true),
      windows: _wchord(LogicalKeyboardKey.comma, control: true, shift: true),
    ),

    // Git
    CommandId.gitRefresh: _meta(
      CommandId.gitRefresh,
      CommandCategory.git,
      Icons.refresh,
      _chord(LogicalKeyboardKey.keyR, meta: true, shift: true),
      windows: _wchord(LogicalKeyboardKey.keyR, control: true, shift: true),
      contextDependent: true,
    ),
    CommandId.gitFetch: _meta(
      CommandId.gitFetch,
      CommandCategory.git,
      Icons.sync,
      _chord(LogicalKeyboardKey.keyF, meta: true, shift: true),
      windows: _wchord(LogicalKeyboardKey.keyF, control: true, shift: true),
      contextDependent: true,
    ),
    CommandId.gitPull: _meta(
      CommandId.gitPull,
      CommandCategory.git,
      Icons.download,
      _chord(LogicalKeyboardKey.keyL, meta: true, shift: true),
      windows: _wchord(LogicalKeyboardKey.keyP, control: true, shift: true),
      contextDependent: true,
    ),
    CommandId.gitPush: _meta(
      CommandId.gitPush,
      CommandCategory.git,
      Icons.publish,
      _chord(LogicalKeyboardKey.keyU, meta: true, shift: true),
      windows: _wchord(LogicalKeyboardKey.keyU, control: true, shift: true),
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

  /// 全コマンドのプラットフォーム別既定キーコンビ。
  static Map<CommandId, KeyChord> get defaults => {
    for (final m in all) m.id: m.platformDefaultChord,
  };
}

CommandMetadata _meta(
  CommandId id,
  CommandCategory category,
  IconData icon,
  KeyChord defaultChord, {
  KeyChord? windows,
  bool contextDependent = false,
}) {
  return CommandMetadata(
    id: id,
    category: category,
    icon: icon,
    defaultChord: defaultChord,
    windowsDefaultChord: windows,
    contextDependent: contextDependent,
  );
}

/// macOS 基準のキーコンビ（meta = ⌘）。
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

/// Windows 専用のキーコンビ（meta を使わない）。
KeyChord _wchord(
  LogicalKeyboardKey key, {
  bool control = false,
  bool shift = false,
  bool alt = false,
}) {
  return KeyChord(
    triggerKeyId: key.keyId,
    control: control,
    shift: shift,
    alt: alt,
  );
}
