import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/keybindings/chord_formatter.dart';
import 'package:roola/data/keybindings/key_chord.dart';

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

void main() {
  // `formatChord` は macOS がシンボル連結（⌘⇧C）、Windows が「+」区切りの英語
  // 表記（Ctrl+Shift+C）と、プラットフォームで出力形式そのものが違う
  // （`chord_formatter.dart` / ADR-0058）。期待値を共有できないため group を
  // 分け、実行中のプラットフォーム側だけを走らせる。
  group('formatChord（macOS）', skip: Platform.isWindows, () {
    test('修飾キーは ⌃⌥⇧⌘ の順で並ぶ', () {
      final chord = _chord(
        LogicalKeyboardKey.keyC,
        meta: true,
        control: true,
        shift: true,
        alt: true,
      );
      expect(formatChord(chord), '⌃⌥⇧⌘C');
    });

    test('⌘ は常に末尾の修飾キー（⇧ の後ろ）', () {
      final chord = _chord(LogicalKeyboardKey.keyN, meta: true, shift: true);
      expect(formatChord(chord), '⇧⌘N');
    });

    test('単一修飾 + 英字は大文字化される', () {
      expect(formatChord(_chord(LogicalKeyboardKey.keyL, meta: true)), '⌘L');
    });

    test('特殊キーはシンボル表示になる', () {
      expect(
        formatChord(_chord(LogicalKeyboardKey.backspace, meta: true)),
        '⌘⌫',
      );
      expect(formatChord(_chord(LogicalKeyboardKey.arrowUp, meta: true)), '⌘↑');
      expect(formatChord(_chord(LogicalKeyboardKey.enter, meta: true)), '⌘↩');
      expect(formatChord(_chord(LogicalKeyboardKey.tab, control: true)), '⌃⇥');
    });
  });

  group('formatChord（Windows）', skip: !Platform.isWindows, () {
    test('修飾キーは Ctrl+Alt+Shift+Win の順で「+」区切りに並ぶ', () {
      final chord = _chord(
        LogicalKeyboardKey.keyC,
        meta: true,
        control: true,
        shift: true,
        alt: true,
      );
      expect(formatChord(chord), 'Ctrl+Alt+Shift+Win+C');
    });

    test('Win は常に末尾の修飾キー（Shift の後ろ）', () {
      final chord = _chord(LogicalKeyboardKey.keyN, meta: true, shift: true);
      expect(formatChord(chord), 'Shift+Win+N');
    });

    test('単一修飾 + 英字は大文字化される', () {
      expect(
        formatChord(_chord(LogicalKeyboardKey.keyL, control: true)),
        'Ctrl+L',
      );
    });

    test('Enter / Delete は英語ラベル、その他の特殊キーはシンボル表示', () {
      // Windows 専用ラベルを持つキー。
      expect(
        formatChord(_chord(LogicalKeyboardKey.enter, control: true)),
        'Ctrl+Enter',
      );
      expect(
        formatChord(_chord(LogicalKeyboardKey.delete, control: true)),
        'Ctrl+Del',
      );
      // 専用ラベルを持たないキーは共通のシンボル表にフォールバックする。
      expect(
        formatChord(_chord(LogicalKeyboardKey.backspace, control: true)),
        'Ctrl+⌫',
      );
      expect(
        formatChord(_chord(LogicalKeyboardKey.arrowUp, control: true)),
        'Ctrl+↑',
      );
    });
  });

  group('toSingleActivator', () {
    test('修飾キーとトリガキーが伝わる', () {
      final chord = _chord(LogicalKeyboardKey.keyC, meta: true, shift: true);
      final activator = toSingleActivator(chord);
      expect(activator.trigger, LogicalKeyboardKey.keyC);
      expect(activator.meta, isTrue);
      expect(activator.shift, isTrue);
      expect(activator.control, isFalse);
      expect(activator.alt, isFalse);
    });
  });
}
