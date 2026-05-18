import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:roola/data/keybindings/key_chord.dart';

/// [KeyChord] の表示文字列化と [SingleActivator] への変換（ADR-0033）。
///
/// 表示は macOS の慣習に合わせ、修飾キーを Control → Option → Shift →
/// Command の順（⌃⌥⇧⌘）で並べ、最後にトリガキーのラベルを置く。

/// 特殊キーの表示シンボル。printable なキー（英数字・記号）は
/// [LogicalKeyboardKey.keyLabel] にフォールバックする。
/// [LogicalKeyboardKey] は `==` を override するため const map に入れられない。
final Map<LogicalKeyboardKey, String> _specialKeyLabels = {
  LogicalKeyboardKey.enter: '↩',
  LogicalKeyboardKey.escape: '⎋',
  LogicalKeyboardKey.backspace: '⌫',
  LogicalKeyboardKey.tab: '⇥',
  LogicalKeyboardKey.space: 'Space',
  LogicalKeyboardKey.delete: '⌦',
  LogicalKeyboardKey.arrowUp: '↑',
  LogicalKeyboardKey.arrowDown: '↓',
  LogicalKeyboardKey.arrowLeft: '←',
  LogicalKeyboardKey.arrowRight: '→',
  LogicalKeyboardKey.pageUp: '⇞',
  LogicalKeyboardKey.pageDown: '⇟',
  LogicalKeyboardKey.home: '↖',
  LogicalKeyboardKey.end: '↘',
};

/// トリガキー 1 つの表示ラベル。
String formatTriggerKey(LogicalKeyboardKey key) {
  final special = _specialKeyLabels[key];
  if (special != null) {
    return special;
  }
  final label = key.keyLabel;
  if (label.isNotEmpty) {
    return label.toUpperCase();
  }
  // 想定外のキー。デバッグ名から雑に整える。
  return key.debugName ?? 'Key';
}

/// [KeyChord] を「⌘⇧C」のような表示文字列にする。
String formatChord(KeyChord chord) {
  final buffer = StringBuffer();
  if (chord.control) {
    buffer.write('⌃');
  }
  if (chord.alt) {
    buffer.write('⌥');
  }
  if (chord.shift) {
    buffer.write('⇧');
  }
  if (chord.meta) {
    buffer.write('⌘');
  }
  buffer.write(formatTriggerKey(chord.triggerKey));
  return buffer.toString();
}

/// [KeyChord] を Flutter の [SingleActivator]（`MenuSerializableShortcut`）に
/// 変換する。`PlatformMenuItem.shortcut` に渡せる。
SingleActivator toSingleActivator(KeyChord chord) {
  return SingleActivator(
    chord.triggerKey,
    control: chord.control,
    shift: chord.shift,
    alt: chord.alt,
    meta: chord.meta,
  );
}
