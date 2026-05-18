import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/data/keybindings/key_chord_dto.dart';
import 'package:roola/data/keybindings/keybindings.dart';

part 'keybindings_dto.g.dart';

/// [Keybindings] の JSON 永続化 DTO。
///
/// `overrides` の キーは [CommandId.name]（文字列）。読み込み時にアプリが
/// 知らない `name` は読み飛ばすことで、`CommandId` の増減に対する前方・
/// 後方互換を保つ（ADR-0033）。
@JsonSerializable(explicitToJson: true)
class KeybindingsDto {
  KeybindingsDto({required this.overrides});

  factory KeybindingsDto.fromJson(Map<String, dynamic> json) =>
      _$KeybindingsDtoFromJson(json);

  factory KeybindingsDto.fromEntity(Keybindings entity) => KeybindingsDto(
    overrides: {
      for (final entry in entity.overrides.entries)
        entry.key.name: KeyChordDto.fromEntity(entry.value),
    },
  );

  /// `CommandId.name` → キーコンビ。
  final Map<String, KeyChordDto> overrides;

  Map<String, dynamic> toJson() => _$KeybindingsDtoToJson(this);

  Keybindings toEntity() {
    final result = <CommandId, KeyChord>{};
    for (final entry in overrides.entries) {
      final id = _commandIdByName(entry.key);
      if (id == null) {
        // 未知の CommandId は読み飛ばす。
        continue;
      }
      result[id] = entry.value.toEntity();
    }
    return Keybindings(overrides: result);
  }
}

CommandId? _commandIdByName(String name) {
  for (final id in CommandId.values) {
    if (id.name == name) {
      return id;
    }
  }
  return null;
}
