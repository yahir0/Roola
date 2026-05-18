import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/key_chord.dart';

part 'keybindings.freezed.dart';

/// ユーザーによるキー割り当ての「上書き」を保持するモデル（ADR-0033）。
///
/// 既定キーコンビは `CommandRegistry` 側が持つ。本モデルは既定から変更された
/// 分だけを `overrides` に持ち、`effectiveKeybindingsProvider` が両者を
/// マージする。これにより「デフォルトに戻す」は当該エントリの削除で表現できる。
@freezed
abstract class Keybindings with _$Keybindings {
  const factory Keybindings({
    @Default(<CommandId, KeyChord>{}) Map<CommandId, KeyChord> overrides,
  }) = _Keybindings;

  /// 上書きなしの初期状態。
  factory Keybindings.empty() => const Keybindings();
}
