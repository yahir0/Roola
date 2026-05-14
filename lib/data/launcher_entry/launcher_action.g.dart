// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenHereAction _$OpenHereActionFromJson(Map<String, dynamic> json) =>
    OpenHereAction($type: json['type'] as String?);

Map<String, dynamic> _$OpenHereActionToJson(OpenHereAction instance) =>
    <String, dynamic>{'type': instance.$type};

RunCommandAction _$RunCommandActionFromJson(Map<String, dynamic> json) =>
    RunCommandAction(
      command: json['command'] as String,
      keepShellAfterExit: json['keepShellAfterExit'] as bool? ?? true,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$RunCommandActionToJson(RunCommandAction instance) =>
    <String, dynamic>{
      'command': instance.command,
      'keepShellAfterExit': instance.keepShellAfterExit,
      'type': instance.$type,
    };

ClaudeSkillAction _$ClaudeSkillActionFromJson(Map<String, dynamic> json) =>
    ClaudeSkillAction(
      skillName: json['skillName'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$ClaudeSkillActionToJson(ClaudeSkillAction instance) =>
    <String, dynamic>{'skillName': instance.skillName, 'type': instance.$type};
