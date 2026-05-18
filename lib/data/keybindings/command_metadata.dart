import 'package:flutter/widgets.dart';
import 'package:roola/data/keybindings/command_category.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/key_chord.dart';

/// 1 つのコマンドの静的メタデータ（ADR-0033）。
///
/// 実体は `CommandRegistry` が `CommandId` ごとに 1 つ保持する。ユーザーの
/// カスタム割り当ては `Keybindings` 側が持ち、本クラスは既定値とラベル等の
/// 不変メタデータに徹する。
@immutable
class CommandMetadata {
  const CommandMetadata({
    required this.id,
    required this.category,
    required this.label,
    required this.icon,
    required this.defaultChord,
    this.contextDependent = false,
  });

  /// 安定 ID。
  final CommandId id;

  /// 分類。
  final CommandCategory category;

  /// 日本語表示名（メニュー項目・設定画面の行ラベル）。
  final String label;

  /// リーディングアイコン（コンテキストメニュー・設定画面）。
  final IconData icon;

  /// 既定キーコンビ。ユーザー未設定時に使う。
  final KeyChord defaultChord;

  /// フォーカス中タブ / 選択アイテムに依存するか。
  /// true のコマンドは対象が解決できないとき no-op になる。
  final bool contextDependent;
}
