import 'dart:io';

import 'package:flutter/services.dart';
import 'package:roola/data/keybindings/key_chord.dart';

/// 設定画面のキー入力キャプチャ用ロジック（ADR-0033）。

/// 修飾キー（それ自体ではトリガにならないキー）の集合。
/// [LogicalKeyboardKey] は `==` を override するため const set に入れられない。
final Set<LogicalKeyboardKey> _modifierKeys = {
  LogicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlRight,
  LogicalKeyboardKey.control,
  LogicalKeyboardKey.shiftLeft,
  LogicalKeyboardKey.shiftRight,
  LogicalKeyboardKey.shift,
  LogicalKeyboardKey.altLeft,
  LogicalKeyboardKey.altRight,
  LogicalKeyboardKey.alt,
  LogicalKeyboardKey.metaLeft,
  LogicalKeyboardKey.metaRight,
  LogicalKeyboardKey.meta,
  LogicalKeyboardKey.capsLock,
  LogicalKeyboardKey.fn,
  LogicalKeyboardKey.fnLock,
};

/// [key] が修飾キーか。
bool isModifierKey(LogicalKeyboardKey key) => _modifierKeys.contains(key);

/// トリガキーと修飾キーの押下状態から [KeyChord] を組み立てる純粋関数。
KeyChord buildChord({
  required LogicalKeyboardKey trigger,
  required bool meta,
  required bool control,
  required bool shift,
  required bool alt,
}) {
  return KeyChord(
    triggerKeyId: trigger.keyId,
    meta: meta,
    control: control,
    shift: shift,
    alt: alt,
  );
}

/// キー押下イベントから [KeyChord] を組み立てる。トリガキーが修飾キー自身、
/// または `KeyDownEvent` でないときは null を返す（まだ確定しない）。
///
/// 修飾キーの押下状態は [HardwareKeyboard]（既定はグローバル instance）から
/// 読む。テストでは [keyboard] を差し替えられる。
KeyChord? recordChord(KeyEvent event, {HardwareKeyboard? keyboard}) {
  if (event is! KeyDownEvent) {
    return null;
  }
  if (isModifierKey(event.logicalKey)) {
    return null;
  }
  final kb = keyboard ?? HardwareKeyboard.instance;
  return buildChord(
    trigger: event.logicalKey,
    meta: kb.isMetaPressed,
    control: kb.isControlPressed,
    shift: kb.isShiftPressed,
    alt: kb.isAltPressed,
  );
}

/// Windows で修飾キーなしでも割り当て可能な特殊キーの keyId 集合。
/// F1〜F12 と Delete は Windows Explorer 慣習に合わせて許可する。
final Set<int> _windowsModifierFreeAllowed = {
  LogicalKeyboardKey.f1.keyId,
  LogicalKeyboardKey.f2.keyId,
  LogicalKeyboardKey.f3.keyId,
  LogicalKeyboardKey.f4.keyId,
  LogicalKeyboardKey.f5.keyId,
  LogicalKeyboardKey.f6.keyId,
  LogicalKeyboardKey.f7.keyId,
  LogicalKeyboardKey.f8.keyId,
  LogicalKeyboardKey.f9.keyId,
  LogicalKeyboardKey.f10.keyId,
  LogicalKeyboardKey.f11.keyId,
  LogicalKeyboardKey.f12.keyId,
  LogicalKeyboardKey.delete.keyId,
};

/// 割り当て可能なキーコンビか（ADR-0033）。
///
/// macOS: 修飾キーを 1 つ以上含む必要がある。
/// Windows: F1〜F12 / Delete は修飾キーなしでも許可（Windows Explorer 慣習）。
bool isAssignableChord(KeyChord chord) {
  if (!chord.hasNoModifier) return true;
  if (Platform.isWindows) {
    return _windowsModifierFreeAllowed.contains(chord.triggerKeyId);
  }
  return false;
}

/// テキスト編集の標準ショートカットとして予約されたトリガキー（ADR-0035）。
/// コピー / ペースト / カット / 全選択 / 取り消しに対応する C / V / X / A / Z。
final Set<int> _reservedTriggerKeyIds = {
  LogicalKeyboardKey.keyC.keyId,
  LogicalKeyboardKey.keyV.keyId,
  LogicalKeyboardKey.keyX.keyId,
  LogicalKeyboardKey.keyA.keyId,
  LogicalKeyboardKey.keyZ.keyId,
};

/// [chord] がテキスト編集用に予約されたコンビか（ADR-0035）。
///
/// macOS: ⌘単独 + {C, V, X, A, Z} を予約。
/// Windows: Ctrl単独 + {C, V, X, A, Z} を予約。
/// 修飾キーが増えたコンビ（⌘⇧C 等）は別物として割り当て可能（既定の copyPath 等）。
bool isReservedChord(KeyChord chord) {
  if (Platform.isWindows) {
    return chord.control &&
        !chord.meta &&
        !chord.shift &&
        !chord.alt &&
        _reservedTriggerKeyIds.contains(chord.triggerKeyId);
  }
  return chord.meta &&
      !chord.control &&
      !chord.shift &&
      !chord.alt &&
      _reservedTriggerKeyIds.contains(chord.triggerKeyId);
}
