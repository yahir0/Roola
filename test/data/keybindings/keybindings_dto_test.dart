import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/data/keybindings/key_chord_dto.dart';
import 'package:roola/data/keybindings/keybindings.dart';
import 'package:roola/data/keybindings/keybindings_dto.dart';

void main() {
  group('KeyChordDto', () {
    test('round-trips through JSON', () {
      final chord = KeyChord(
        triggerKeyId: LogicalKeyboardKey.keyC.keyId,
        meta: true,
        shift: true,
      );
      final json = KeyChordDto.fromEntity(chord).toJson();
      final restored = KeyChordDto.fromJson(json).toEntity();
      expect(restored, chord);
    });
  });

  group('KeybindingsDto', () {
    test('round-trips overrides through JSON', () {
      final keybindings = Keybindings(
        overrides: {
          CommandId.copyPath: KeyChord(
            triggerKeyId: LogicalKeyboardKey.keyP.keyId,
            meta: true,
          ),
          CommandId.closeTab: KeyChord(
            triggerKeyId: LogicalKeyboardKey.keyW.keyId,
            meta: true,
            shift: true,
          ),
        },
      );
      final json = KeybindingsDto.fromEntity(keybindings).toJson();
      final restored = KeybindingsDto.fromJson(json).toEntity();
      expect(restored, keybindings);
    });

    test('未知の CommandId 名は読み飛ばす', () {
      final json = {
        'overrides': {
          'copyPath': {'key': LogicalKeyboardKey.keyP.keyId, 'meta': true},
          'someRemovedCommand': {'key': 999, 'meta': true},
        },
      };
      final restored = KeybindingsDto.fromJson(json).toEntity();
      expect(restored.overrides.keys, [CommandId.copyPath]);
    });

    test('空の overrides を round-trip できる', () {
      final json = KeybindingsDto.fromEntity(Keybindings.empty()).toJson();
      final restored = KeybindingsDto.fromJson(json).toEntity();
      expect(restored.overrides, isEmpty);
    });
  });
}
