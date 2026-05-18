// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_chord_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyChordDto _$KeyChordDtoFromJson(Map<String, dynamic> json) => KeyChordDto(
  key: (json['key'] as num).toInt(),
  meta: json['meta'] as bool? ?? false,
  control: json['control'] as bool? ?? false,
  shift: json['shift'] as bool? ?? false,
  alt: json['alt'] as bool? ?? false,
);

Map<String, dynamic> _$KeyChordDtoToJson(KeyChordDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'meta': instance.meta,
      'control': instance.control,
      'shift': instance.shift,
      'alt': instance.alt,
    };
