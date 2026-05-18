import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'key_chord.freezed.dart';

/// 1 つのキーコンビ（修飾キー + トリガキー 1 つ）。
///
/// トリガキーは [LogicalKeyboardKey.keyId]（int）で保持する。`keyId` は
/// Flutter が割り当てる安定値で、JSON 永続化しても将来壊れにくい。
/// 表示文字列・[SingleActivator] への変換は `core/keybindings/chord_formatter.dart`
/// が担う（本モデルは純粋なデータに徹する）。
@freezed
abstract class KeyChord with _$KeyChord {
  const factory KeyChord({
    /// トリガキーの [LogicalKeyboardKey.keyId]。
    required int triggerKeyId,
    @Default(false) bool meta,
    @Default(false) bool control,
    @Default(false) bool shift,
    @Default(false) bool alt,
  }) = _KeyChord;

  const KeyChord._();

  /// トリガキーの [LogicalKeyboardKey]。
  LogicalKeyboardKey get triggerKey => LogicalKeyboardKey(triggerKeyId);

  /// 修飾キーを 1 つも含まないか。修飾なし単キーは割り当て不可（ADR-0033）。
  bool get hasNoModifier => !meta && !control && !shift && !alt;
}
