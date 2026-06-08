import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:roola/data/keybindings/command_category.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/key_chord.dart';

/// 1 つのコマンドの静的メタデータ（ADR-0033）。
///
/// 実体は `CommandRegistry` が `CommandId` ごとに 1 つ保持する。ユーザーの
/// カスタム割り当ては `Keybindings` 側が持ち、本クラスは既定値等の不変
/// メタデータに徹する。表示ラベルはロケール依存のため本クラスは持たず、
/// UI 層が `CommandId` を安定キーとして `AppLocalizations` から解決する
/// （ADR-0034）。
@immutable
class CommandMetadata {
  const CommandMetadata({
    required this.id,
    required this.category,
    required this.icon,
    required this.defaultChord,
    this.windowsDefaultChord,
    this.contextDependent = false,
  });

  /// 安定 ID。
  final CommandId id;

  /// 分類。
  final CommandCategory category;

  /// リーディングアイコン（コンテキストメニュー・設定画面）。
  final IconData icon;

  /// 既定キーコンビ（macOS 基準）。ユーザー未設定時に使う。
  final KeyChord defaultChord;

  /// Windows 専用の既定キーコンビ（ADR-0058 Case A）。
  /// 非 null のとき Windows では [defaultChord] の代わりにこれが使われる。
  final KeyChord? windowsDefaultChord;

  /// フォーカス中タブ / 選択アイテムに依存するか。
  /// true のコマンドは対象が解決できないとき no-op になる。
  final bool contextDependent;

  /// プラットフォームに応じた実効既定キーコンビ。
  KeyChord get platformDefaultChord =>
      Platform.isWindows && windowsDefaultChord != null
          ? windowsDefaultChord!
          : defaultChord;
}
