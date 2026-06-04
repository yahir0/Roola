import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:roola/data/keybindings/key_chord.dart';

/// [KeyChord] の表示文字列化と [SingleActivator] への変換（ADR-0033）。
///
/// macOS: 修飾キーを Control → Option → Shift → Command の順（⌃⌥⇧⌘）で並べる。
/// Windows: Ctrl / Alt / Shift / Win の順で並べ、「+」で繋ぐ。
/// Windows 既定キーコンビは [CommandRegistry] が platform-specific に定義済みのため、
/// ここでの modifier 変換は不要。

/// 特殊キーの表示シンボル（macOS / 共通）。printable なキー（英数字・記号）は
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

/// Windows 専用の特殊キー表示（英語ラベル優先）。
final Map<LogicalKeyboardKey, String> _windowsSpecialKeyLabels = {
  LogicalKeyboardKey.enter: 'Enter',
  LogicalKeyboardKey.delete: 'Del',
};

/// トリガキー 1 つの表示ラベル。
String formatTriggerKey(LogicalKeyboardKey key) {
  if (Platform.isWindows) {
    final w = _windowsSpecialKeyLabels[key];
    if (w != null) return w;
  }
  final special = _specialKeyLabels[key];
  if (special != null) return special;
  final label = key.keyLabel;
  if (label.isNotEmpty) return label.toUpperCase();
  return key.debugName ?? 'Key';
}

/// [KeyChord] を表示文字列にする。
///
/// macOS: 「⌘⇧C」形式。
/// Windows: 「Ctrl+Shift+C」形式。
String formatChord(KeyChord chord) {
  if (Platform.isWindows) {
    return _formatChordWindows(chord);
  }
  final buffer = StringBuffer();
  if (chord.control) buffer.write('⌃');
  if (chord.alt) buffer.write('⌥');
  if (chord.shift) buffer.write('⇧');
  if (chord.meta) buffer.write('⌘');
  buffer.write(formatTriggerKey(chord.triggerKey));
  return buffer.toString();
}

String _formatChordWindows(KeyChord chord) {
  final parts = <String>[];
  if (chord.control) parts.add('Ctrl');
  if (chord.alt) parts.add('Alt');
  if (chord.shift) parts.add('Shift');
  if (chord.meta) parts.add('Win');
  parts.add(formatTriggerKey(chord.triggerKey));
  return parts.join('+');
}

/// [KeyChord] を Flutter の [SingleActivator]（`MenuSerializableShortcut`）に
/// 変換する。`PlatformMenuItem.shortcut` に渡せる。
///
/// Windows では [CommandRegistry] が platform-specific な既定値を持つため、
/// ここでは modifier の変換を行わずそのまま渡す。
SingleActivator toSingleActivator(KeyChord chord) {
  return SingleActivator(
    chord.triggerKey,
    control: chord.control,
    shift: chord.shift,
    alt: chord.alt,
    meta: chord.meta,
  );
}
