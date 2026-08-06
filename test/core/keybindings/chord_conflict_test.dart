import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/core/keybindings/chord_conflict.dart';
import 'package:roola/core/keybindings/key_chord_recorder.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/key_chord.dart';

KeyChord _chord(
  LogicalKeyboardKey key, {
  bool meta = false,
  bool shift = false,
}) {
  return KeyChord(triggerKeyId: key.keyId, meta: meta, shift: shift);
}

void main() {
  group('conflictingCommand', () {
    test('別コマンドが同じキーコンビを持つと衝突相手を返す', () {
      final chord = _chord(LogicalKeyboardKey.keyC, meta: true, shift: true);
      final effective = {
        CommandId.copyPath: chord,
        CommandId.copyItem: _chord(LogicalKeyboardKey.keyV, meta: true),
      };
      final result = conflictingCommand(
        effective: effective,
        target: CommandId.copyItem,
        candidate: chord,
      );
      expect(result, CommandId.copyPath);
    });

    test('自分自身の現在のキーコンビは衝突扱いしない', () {
      final chord = _chord(LogicalKeyboardKey.keyC, meta: true);
      final effective = {CommandId.copyPath: chord};
      final result = conflictingCommand(
        effective: effective,
        target: CommandId.copyPath,
        candidate: chord,
      );
      expect(result, isNull);
    });

    test('未使用のキーコンビは衝突しない', () {
      final effective = {
        CommandId.copyPath: _chord(LogicalKeyboardKey.keyC, meta: true),
      };
      final result = conflictingCommand(
        effective: effective,
        target: CommandId.copyItem,
        candidate: _chord(LogicalKeyboardKey.keyZ, meta: true),
      );
      expect(result, isNull);
    });
  });

  group('findConflicts', () {
    test('重複しているキーコンビの組だけを返す', () {
      final dup = _chord(LogicalKeyboardKey.keyC, meta: true);
      final effective = {
        CommandId.copyPath: dup,
        CommandId.copyItem: dup,
        CommandId.pasteItem: _chord(LogicalKeyboardKey.keyV, meta: true),
      };
      final conflicts = findConflicts(effective);
      expect(conflicts.length, 1);
      expect(
        conflicts[dup],
        containsAll([CommandId.copyPath, CommandId.copyItem]),
      );
    });

    test('重複が無ければ空', () {
      expect(findConflicts(CommandRegistry.defaults), isEmpty);
    });
  });

  group('CommandRegistry の既定値', () {
    test('全コマンドに既定キーコンビが定義されている', () {
      for (final id in CommandId.values) {
        expect(CommandRegistry.defaults[id], isNotNull, reason: '$id');
      }
    });

    test('既定キーコンビどうしは衝突しない', () {
      expect(findConflicts(CommandRegistry.defaults), isEmpty);
    });

    // 「修飾キーを含むこと」は macOS の規則で、Windows は F1〜F12 / Delete を
    // 修飾キー無しでも許可する（Windows Explorer 慣習 / ADR-0033・ADR-0058。
    // 実際 renameItem = F2 / moveToTrash = Delete が該当する）。両方を貫く
    // 不変条件は「割り当て可能なコンビであること」なので、それを検証する。
    test('既定キーコンビはすべて割り当て可能', () {
      for (final entry in CommandRegistry.defaults.entries) {
        expect(
          isAssignableChord(entry.value),
          isTrue,
          reason: '${entry.key} は割り当て不可なコンビ',
        );
      }
    });

    test('修飾キー無しの既定はプラットフォームの許可キーに限られる', () {
      final modifierFree = CommandRegistry.defaults.entries
          .where((e) => e.value.hasNoModifier)
          .toList();
      if (!Platform.isWindows) {
        // macOS は修飾キー無しの既定を一切持たない。
        expect(modifierFree, isEmpty);
        return;
      }
      // Windows は F1〜F12 / Delete のみ許可。
      for (final entry in modifierFree) {
        expect(
          isAssignableChord(entry.value),
          isTrue,
          reason: '${entry.key} は修飾なしだが許可対象外',
        );
      }
    });
  });
}
