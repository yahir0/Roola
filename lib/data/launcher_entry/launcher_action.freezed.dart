// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'launcher_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
LauncherAction _$LauncherActionFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'openHere':
          return OpenHereAction.fromJson(
            json
          );
                case 'runCommand':
          return RunCommandAction.fromJson(
            json
          );
                case 'claudeSkill':
          return ClaudeSkillAction.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'LauncherAction',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$LauncherAction {



  /// Serializes this LauncherAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LauncherAction);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LauncherAction()';
}


}

/// @nodoc
class $LauncherActionCopyWith<$Res>  {
$LauncherActionCopyWith(LauncherAction _, $Res Function(LauncherAction) __);
}


/// Adds pattern-matching-related methods to [LauncherAction].
extension LauncherActionPatterns on LauncherAction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OpenHereAction value)?  openHere,TResult Function( RunCommandAction value)?  runCommand,TResult Function( ClaudeSkillAction value)?  claudeSkill,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OpenHereAction() when openHere != null:
return openHere(_that);case RunCommandAction() when runCommand != null:
return runCommand(_that);case ClaudeSkillAction() when claudeSkill != null:
return claudeSkill(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OpenHereAction value)  openHere,required TResult Function( RunCommandAction value)  runCommand,required TResult Function( ClaudeSkillAction value)  claudeSkill,}){
final _that = this;
switch (_that) {
case OpenHereAction():
return openHere(_that);case RunCommandAction():
return runCommand(_that);case ClaudeSkillAction():
return claudeSkill(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OpenHereAction value)?  openHere,TResult? Function( RunCommandAction value)?  runCommand,TResult? Function( ClaudeSkillAction value)?  claudeSkill,}){
final _that = this;
switch (_that) {
case OpenHereAction() when openHere != null:
return openHere(_that);case RunCommandAction() when runCommand != null:
return runCommand(_that);case ClaudeSkillAction() when claudeSkill != null:
return claudeSkill(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  openHere,TResult Function( String command,  bool keepShellAfterExit)?  runCommand,TResult Function( String skillName,  bool requiresArgument)?  claudeSkill,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OpenHereAction() when openHere != null:
return openHere();case RunCommandAction() when runCommand != null:
return runCommand(_that.command,_that.keepShellAfterExit);case ClaudeSkillAction() when claudeSkill != null:
return claudeSkill(_that.skillName,_that.requiresArgument);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  openHere,required TResult Function( String command,  bool keepShellAfterExit)  runCommand,required TResult Function( String skillName,  bool requiresArgument)  claudeSkill,}) {final _that = this;
switch (_that) {
case OpenHereAction():
return openHere();case RunCommandAction():
return runCommand(_that.command,_that.keepShellAfterExit);case ClaudeSkillAction():
return claudeSkill(_that.skillName,_that.requiresArgument);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  openHere,TResult? Function( String command,  bool keepShellAfterExit)?  runCommand,TResult? Function( String skillName,  bool requiresArgument)?  claudeSkill,}) {final _that = this;
switch (_that) {
case OpenHereAction() when openHere != null:
return openHere();case RunCommandAction() when runCommand != null:
return runCommand(_that.command,_that.keepShellAfterExit);case ClaudeSkillAction() when claudeSkill != null:
return claudeSkill(_that.skillName,_that.requiresArgument);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class OpenHereAction implements LauncherAction {
  const OpenHereAction({final  String? $type}): $type = $type ?? 'openHere';
  factory OpenHereAction.fromJson(Map<String, dynamic> json) => _$OpenHereActionFromJson(json);



@JsonKey(name: 'type')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$OpenHereActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenHereAction);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LauncherAction.openHere()';
}


}




/// @nodoc
@JsonSerializable()

class RunCommandAction implements LauncherAction {
  const RunCommandAction({required this.command, this.keepShellAfterExit = true, final  String? $type}): $type = $type ?? 'runCommand';
  factory RunCommandAction.fromJson(Map<String, dynamic> json) => _$RunCommandActionFromJson(json);

 final  String command;
@JsonKey() final  bool keepShellAfterExit;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of LauncherAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunCommandActionCopyWith<RunCommandAction> get copyWith => _$RunCommandActionCopyWithImpl<RunCommandAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunCommandActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunCommandAction&&(identical(other.command, command) || other.command == command)&&(identical(other.keepShellAfterExit, keepShellAfterExit) || other.keepShellAfterExit == keepShellAfterExit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,command,keepShellAfterExit);

@override
String toString() {
  return 'LauncherAction.runCommand(command: $command, keepShellAfterExit: $keepShellAfterExit)';
}


}

/// @nodoc
abstract mixin class $RunCommandActionCopyWith<$Res> implements $LauncherActionCopyWith<$Res> {
  factory $RunCommandActionCopyWith(RunCommandAction value, $Res Function(RunCommandAction) _then) = _$RunCommandActionCopyWithImpl;
@useResult
$Res call({
 String command, bool keepShellAfterExit
});




}
/// @nodoc
class _$RunCommandActionCopyWithImpl<$Res>
    implements $RunCommandActionCopyWith<$Res> {
  _$RunCommandActionCopyWithImpl(this._self, this._then);

  final RunCommandAction _self;
  final $Res Function(RunCommandAction) _then;

/// Create a copy of LauncherAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? command = null,Object? keepShellAfterExit = null,}) {
  return _then(RunCommandAction(
command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,keepShellAfterExit: null == keepShellAfterExit ? _self.keepShellAfterExit : keepShellAfterExit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ClaudeSkillAction implements LauncherAction {
  const ClaudeSkillAction({required this.skillName, this.requiresArgument = false, final  String? $type}): $type = $type ?? 'claudeSkill';
  factory ClaudeSkillAction.fromJson(Map<String, dynamic> json) => _$ClaudeSkillActionFromJson(json);

 final  String skillName;
@JsonKey() final  bool requiresArgument;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of LauncherAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeSkillActionCopyWith<ClaudeSkillAction> get copyWith => _$ClaudeSkillActionCopyWithImpl<ClaudeSkillAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClaudeSkillActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeSkillAction&&(identical(other.skillName, skillName) || other.skillName == skillName)&&(identical(other.requiresArgument, requiresArgument) || other.requiresArgument == requiresArgument));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,skillName,requiresArgument);

@override
String toString() {
  return 'LauncherAction.claudeSkill(skillName: $skillName, requiresArgument: $requiresArgument)';
}


}

/// @nodoc
abstract mixin class $ClaudeSkillActionCopyWith<$Res> implements $LauncherActionCopyWith<$Res> {
  factory $ClaudeSkillActionCopyWith(ClaudeSkillAction value, $Res Function(ClaudeSkillAction) _then) = _$ClaudeSkillActionCopyWithImpl;
@useResult
$Res call({
 String skillName, bool requiresArgument
});




}
/// @nodoc
class _$ClaudeSkillActionCopyWithImpl<$Res>
    implements $ClaudeSkillActionCopyWith<$Res> {
  _$ClaudeSkillActionCopyWithImpl(this._self, this._then);

  final ClaudeSkillAction _self;
  final $Res Function(ClaudeSkillAction) _then;

/// Create a copy of LauncherAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? skillName = null,Object? requiresArgument = null,}) {
  return _then(ClaudeSkillAction(
skillName: null == skillName ? _self.skillName : skillName // ignore: cast_nullable_to_non_nullable
as String,requiresArgument: null == requiresArgument ? _self.requiresArgument : requiresArgument // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
