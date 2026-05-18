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
    KeyChord cmd(LogicalKeyboardKey key) => buildChord(
      trigger: key,
      meta: true,
      control: false,
      shift: false,
      alt: false,
    );

    test('⌘ のみ + C/V/X/A/Z は予約コンビ', () {
      for (final key in [
        LogicalKeyboardKey.keyC,
        LogicalKeyboardKey.keyV,
        LogicalKeyboardKey.keyX,
        LogicalKeyboardKey.keyA,
        LogicalKeyboardKey.keyZ,
      ]) {
        expect(isReservedChord(cmd(key)), isTrue, reason: key.debugName);
      }
    });

    test('修飾キーが増えたコンビ（⌘⇧C / ⌘⌥C）は予約対象外', () {
      final cmdShiftC = buildChord(
        trigger: LogicalKeyboardKey.keyC,
        meta: true,
        control: false,
        shift: true,
        alt: false,
      );
      final cmdAltC = buildChord(
        trigger: LogicalKeyboardKey.keyC,
        meta: true,
        control: false,
        shift: false,
        alt: true,
      );
      expect(isReservedChord(cmdShiftC), isFalse);
      expect(isReservedChord(cmdAltC), isFalse);
    });

    test('⌘ 以外の予約対象外キーは予約コンビではない', () {
      expect(isReservedChord(cmd(LogicalKeyboardKey.keyB)), isFalse);
      final ctrlC = buildChord(
        trigger: LogicalKeyboardKey.keyC,
        meta: false,
        control: true,
        shift: false,
        alt: false,
      );
      expect(isReservedChord(ctrlC), isFalse);
    });
  });
}
