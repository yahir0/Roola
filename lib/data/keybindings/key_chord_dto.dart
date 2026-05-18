import 'package:json_annotation/json_annotation.dart';
import 'package:roola/data/keybindings/key_chord.dart';

part 'key_chord_dto.g.dart';

/// [KeyChord] の JSON 永続化 DTO。
@JsonSerializable()
class KeyChordDto {
  KeyChordDto({
    required this.key,
    this.meta = false,
    this.control = false,
    this.shift = false,
    this.alt = false,
  });

  factory KeyChordDto.fromJson(Map<String, dynamic> json) =>
      _$KeyChordDtoFromJson(json);

  factory KeyChordDto.fromEntity(KeyChord entity) => KeyChordDto(
    key: entity.triggerKeyId,
    meta: entity.meta,
    control: entity.control,
    shift: entity.shift,
    alt: entity.alt,
  );

  /// トリガキーの [LogicalKeyboardKey.keyId]。
  final int key;
  final bool meta;
  final bool control;
  final bool shift;
  final bool alt;

  Map<String, dynamic> toJson() => _$KeyChordDtoToJson(this);

  KeyChord toEntity() => KeyChord(
    triggerKeyId: key,
    meta: meta,
    control: control,
    shift: shift,
    alt: alt,
  );
}
