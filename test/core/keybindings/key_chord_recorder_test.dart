import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/keybindings/key_chord_recorder.dart';
import 'package:roola/data/keybindings/key_chord.dart';

void main() {
  group('isModifierKey', () {
    test('修飾キーを判定する', () {
      expect(isModifierKey(LogicalKeyboardKey.metaLeft), isTrue);
      expect(isModifierKey(LogicalKeyboardKey.shiftRight), isTrue);
      expect(isModifierKey(LogicalKeyboardKey.controlLeft), isTrue);
      expect(isModifierKey(LogicalKeyboardKey.altLeft), isTrue);
    });

    test('通常キーは修飾キーではない', () {
      expect(isModifierKey(LogicalKeyboardKey.keyC), isFalse);
      expect(isModifierKey(LogicalKeyboardKey.enter), isFalse);
      expect(isModifierKey(LogicalKeyboardKey.digit1), isFalse);
    });
  });

  group('buildChord', () {
    test('トリガキーと修飾キーの状態が反映される', () {
      final chord = buildChord(
        trigger: LogicalKeyboardKey.keyC,
        meta: true,
        control: false,
        shift: true,
        alt: false,
      );
      expect(chord.triggerKeyId, LogicalKeyboardKey.keyC.keyId);
      expect(chord.meta, isTrue);
      expect(chord.shift, isTrue);
      expect(chord.control, isFalse);
      expect(chord.alt, isFalse);
    });
  });

  group('isAssignableChord', () {
    test('修飾キーを含むキーコンビは割り当て可能', () {
      final chord = buildChord(
        trigger: LogicalKeyboardKey.keyC,
        meta: true,
        control: false,
        shift: false,
        alt: false,
      );
      expect(isAssignableChord(chord), isTrue);
    });

    test('修飾キーなしの単キーは割り当て不可', () {
      final chord = buildChord(
        trigger: LogicalKeyboardKey.keyC,
        meta: false,
        control: false,
        shift: false,
        alt: false,
      );
      expect(isAssignableChord(chord), isFalse);
    });
  });

  group('isReservedChord', () {
    // テキスト編集用に予約される修飾キーは macOS が ⌘、Windows が Ctrl
    // （ADR-0035 / ADR-0058）。予約側 / 非予約側の修飾キーをプラットフォームで
    // 入れ替え、規則そのものは両方で同じように検証する。
    final usesControl = Platform.isWindows;

    /// 予約対象の修飾キー単独のコンビ（macOS: ⌘ / Windows: Ctrl）。
    KeyChord primary(LogicalKeyboardKey key) => buildChord(
      trigger: key,
      meta: !usesControl,
      control: usesControl,
      shift: false,
      alt: false,
    );

    /// 予約対象**外**の修飾キー単独のコンビ（macOS: ⌃ / Windows: Win）。
    KeyChord secondary(LogicalKeyboardKey key) => buildChord(
      trigger: key,
      meta: usesControl,
      control: !usesControl,
      shift: false,
      alt: false,
    );

    test('予約修飾キー単独 + C/V/X/A/Z は予約コンビ', () {
      for (final key in [
        LogicalKeyboardKey.keyC,
        LogicalKeyboardKey.keyV,
        LogicalKeyboardKey.keyX,
        LogicalKeyboardKey.keyA,
        LogicalKeyboardKey.keyZ,
      ]) {
        expect(isReservedChord(primary(key)), isTrue, reason: key.debugName);
      }
    });

    test('修飾キーが増えたコンビ（⌘⇧C / ⌘⌥C 相当）は予約対象外', () {
      final withShift = buildChord(
        trigger: LogicalKeyboardKey.keyC,
        meta: !usesControl,
        control: usesControl,
        shift: true,
        alt: false,
      );
      final withAlt = buildChord(
        trigger: LogicalKeyboardKey.keyC,
        meta: !usesControl,
        control: usesControl,
        shift: false,
        alt: true,
      );
      expect(isReservedChord(withShift), isFalse);
      expect(isReservedChord(withAlt), isFalse);
    });

    test('予約対象外のキー / 修飾キーは予約コンビではない', () {
      // 予約修飾キーでも、トリガキーが C/V/X/A/Z 以外なら予約されない。
      expect(isReservedChord(primary(LogicalKeyboardKey.keyB)), isFalse);
      // トリガキーが C でも、修飾キーが予約対象外なら予約されない。
      expect(isReservedChord(secondary(LogicalKeyboardKey.keyC)), isFalse);
    });
  });
}
