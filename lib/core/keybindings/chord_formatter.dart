import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:roola/data/keybindings/key_chord.dart';

/// [KeyChord] の表示文字列化と [SingleActivator] への変換（ADR-0033）。
///
/// macOS: 修飾キーを Control → Option → Shift → Command の順（⌃⌥⇧⌘）で並べる。
/// Windows: ⌘(meta) → Ctrl、⌃(control) → Ctrl、⌘+⌃ → Ctrl+Alt にマップする。

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

/// [KeyChord] を表示文字列にする。
///
/// macOS: 「⌘⇧C」形式。
/// Windows: macOS の ⌘(meta) を Ctrl に、⌘+⌃(meta+control) を Ctrl+Alt に
/// マップし「Ctrl+Shift+C」形式で返す。
String formatChord(KeyChord chord) {
  if (Platform.isWindows) {
    return _formatChordWindows(chord);
  }
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

String _formatChordWindows(KeyChord chord) {
  final parts = <String>[];
  // ⌘(meta) → Ctrl、⌃(control) だけでも → Ctrl、⌘+⌃ → Ctrl+Alt
  if (chord.meta || chord.control) parts.add('Ctrl');
  if (chord.alt || (chord.meta && chord.control)) parts.add('Alt');
  if (chord.shift) parts.add('Shift');
  parts.add(formatTriggerKey(chord.triggerKey));
  return parts.join('+');
}

/// [KeyChord] を Flutter の [SingleActivator]（`MenuSerializableShortcut`）に
/// 変換する。`PlatformMenuItem.shortcut` に渡せる。
///
/// Windows では macOS の ⌘(meta) を control に、⌘+⌃ を control+alt にマップする。
SingleActivator toSingleActivator(KeyChord chord) {
  if (Platform.isWindows) {
    return SingleActivator(
      chord.triggerKey,
      control: chord.meta || chord.control,
      shift: chord.shift,
      alt: chord.alt || (chord.meta && chord.control),
    );
  }
  return SingleActivator(
    chord.triggerKey,
    control: chord.control,
    shift: chord.shift,
    alt: chord.alt,
    meta: chord.meta,
  );
}
