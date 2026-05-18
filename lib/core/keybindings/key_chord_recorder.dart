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

/// 割り当て可能なキーコンビか。修飾キーを 1 つ以上含む必要がある（ADR-0033）。
bool isAssignableChord(KeyChord chord) => !chord.hasNoModifier;

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
/// `⌘`（meta）単独 + {C, V, X, A, Z} の組だけを予約対象とする。⌘⇧C のように
/// 修飾キーが増えたコンビは別物として割り当て可能（既定の copyPath 等）。
/// 予約コンビはコマンドへ割り当てできず、コピー & ペースト等の標準動作に残す。
bool isReservedChord(KeyChord chord) =>
    chord.meta &&
    !chord.control &&
    !chord.shift &&
    !chord.alt &&
    _reservedTriggerKeyIds.contains(chord.triggerKeyId);
