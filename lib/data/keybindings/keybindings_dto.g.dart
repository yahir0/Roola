// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keybindings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeybindingsDto _$KeybindingsDtoFromJson(Map<String, dynamic> json) =>
    KeybindingsDto(
      overrides: (json['overrides'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, KeyChordDto.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$KeybindingsDtoToJson(KeybindingsDto instance) =>
    <String, dynamic>{
      'overrides': instance.overrides.map((k, e) => MapEntry(k, e.toJson())),
    };
