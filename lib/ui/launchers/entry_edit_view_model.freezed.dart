// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_edit_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EntryEditState {

 String get displayName; String get workingDirectory; LauncherAction get action;/// 「⚡ コマンド実行」セグメント用の編集中コマンド文字列。
 String get editedCommand;/// 「⚡ コマンド実行」セグメント用の「終了後シェル残留」フラグ。
 bool get editedKeepShellAfterExit;/// 「🤖 Claude Skill」セグメント用の編集中 Skill 名。
 String get editedSkillName;/// 現在の作業ディレクトリ配下で検出された Skill 名候補。
/// `<dir>/.claude/skills/<name>/SKILL.md` の `<name>` を集めたもの。
 List<String> get availableSkills;/// 所属させるフォルダ ID。null なら root（フォルダなし、ADR-0019）。
 String? get folderId; Map<String, String> get errors; bool get isSubmitting;
/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryEditStateCopyWith<EntryEditState> get copyWith => _$EntryEditStateCopyWithImpl<EntryEditState>(this as EntryEditState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryEditState&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.workingDirectory, workingDirectory) || other.workingDirectory == workingDirectory)&&(identical(other.action, action) || other.action == action)&&(identical(other.editedCommand, editedCommand) || other.editedCommand == editedCommand)&&(identical(other.editedKeepShellAfterExit, editedKeepShellAfterExit) || other.editedKeepShellAfterExit == editedKeepShellAfterExit)&&(identical(other.editedSkillName, editedSkillName) || other.editedSkillName == editedSkillName)&&const DeepCollectionEquality().equals(other.availableSkills, availableSkills)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,workingDirectory,action,editedCommand,editedKeepShellAfterExit,editedSkillName,const DeepCollectionEquality().hash(availableSkills),folderId,const DeepCollectionEquality().hash(errors),isSubmitting);

@override
String toString() {
  return 'EntryEditState(displayName: $displayName, workingDirectory: $workingDirectory, action: $action, editedCommand: $editedCommand, editedKeepShellAfterExit: $editedKeepShellAfterExit, editedSkillName: $editedSkillName, availableSkills: $availableSkills, folderId: $folderId, errors: $errors, isSubmitting: $isSubmitting)';
}


}

/// @nodoc
abstract mixin class $EntryEditStateCopyWith<$Res>  {
  factory $EntryEditStateCopyWith(EntryEditState value, $Res Function(EntryEditState) _then) = _$EntryEditStateCopyWithImpl;
@useResult
$Res call({
 String displayName, String workingDirectory, LauncherAction action, String editedCommand, bool editedKeepShellAfterExit, String editedSkillName, List<String> availableSkills, String? folderId, Map<String, String> errors, bool isSubmitting
});


$LauncherActionCopyWith<$Res> get action;

}
/// @nodoc
class _$EntryEditStateCopyWithImpl<$Res>
    implements $EntryEditStateCopyWith<$Res> {
  _$EntryEditStateCopyWithImpl(this._self, this._then);

  final EntryEditState _self;
  final $Res Function(EntryEditState) _then;

/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? workingDirectory = null,Object? action = null,Object? editedCommand = null,Object? editedKeepShellAfterExit = null,Object? editedSkillName = null,Object? availableSkills = null,Object? folderId = freezed,Object? errors = null,Object? isSubmitting = null,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,workingDirectory: null == workingDirectory ? _self.workingDirectory : workingDirectory // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as LauncherAction,editedCommand: null == editedCommand ? _self.editedCommand : editedCommand // ignore: cast_nullable_to_non_nullable
as String,editedKeepShellAfterExit: null == editedKeepShellAfterExit ? _self.editedKeepShellAfterExit : editedKeepShellAfterExit // ignore: cast_nullable_to_non_nullable
as bool,editedSkillName: null == editedSkillName ? _self.editedSkillName : editedSkillName // ignore: cast_nullable_to_non_nullable
as String,availableSkills: null == availableSkills ? _self.availableSkills : availableSkills // ignore: cast_nullable_to_non_nullable
as List<String>,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LauncherActionCopyWith<$Res> get action {
  
  return $LauncherActionCopyWith<$Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}


/// Adds pattern-matching-related methods to [EntryEditState].
extension EntryEditStatePatterns on EntryEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryEditState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryEditState value)  $default,){
final _that = this;
switch (_that) {
case _EntryEditState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryEditState value)?  $default,){
final _that = this;
switch (_that) {
case _EntryEditState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName,  String workingDirectory,  LauncherAction action,  String editedCommand,  bool editedKeepShellAfterExit,  String editedSkillName,  List<String> availableSkills,  String? folderId,  Map<String, String> errors,  bool isSubmitting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryEditState() when $default != null:
return $default(_that.displayName,_that.workingDirectory,_that.action,_that.editedCommand,_that.editedKeepShellAfterExit,_that.editedSkillName,_that.availableSkills,_that.folderId,_that.errors,_that.isSubmitting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName,  String workingDirectory,  LauncherAction action,  String editedCommand,  bool editedKeepShellAfterExit,  String editedSkillName,  List<String> availableSkills,  String? folderId,  Map<String, String> errors,  bool isSubmitting)  $default,) {final _that = this;
switch (_that) {
case _EntryEditState():
return $default(_that.displayName,_that.workingDirectory,_that.action,_that.editedCommand,_that.editedKeepShellAfterExit,_that.editedSkillName,_that.availableSkills,_that.folderId,_that.errors,_that.isSubmitting);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName,  String workingDirectory,  LauncherAction action,  String editedCommand,  bool editedKeepShellAfterExit,  String editedSkillName,  List<String> availableSkills,  String? folderId,  Map<String, String> errors,  bool isSubmitting)?  $default,) {final _that = this;
switch (_that) {
case _EntryEditState() when $default != null:
return $default(_that.displayName,_that.workingDirectory,_that.action,_that.editedCommand,_that.editedKeepShellAfterExit,_that.editedSkillName,_that.availableSkills,_that.folderId,_that.errors,_that.isSubmitting);case _:
  return null;

}
}

}

/// @nodoc


class _EntryEditState implements EntryEditState {
  const _EntryEditState({required this.displayName, required this.workingDirectory, required this.action, this.editedCommand = '', this.editedKeepShellAfterExit = true, this.editedSkillName = '', final  List<String> availableSkills = const <String>[], this.folderId, final  Map<String, String> errors = const <String, String>{}, this.isSubmitting = false}): _availableSkills = availableSkills,_errors = errors;
  

@override final  String displayName;
@override final  String workingDirectory;
@override final  LauncherAction action;
/// 「⚡ コマンド実行」セグメント用の編集中コマンド文字列。
@override@JsonKey() final  String editedCommand;
/// 「⚡ コマンド実行」セグメント用の「終了後シェル残留」フラグ。
@override@JsonKey() final  bool editedKeepShellAfterExit;
/// 「🤖 Claude Skill」セグメント用の編集中 Skill 名。
@override@JsonKey() final  String editedSkillName;
/// 現在の作業ディレクトリ配下で検出された Skill 名候補。
/// `<dir>/.claude/skills/<name>/SKILL.md` の `<name>` を集めたもの。
 final  List<String> _availableSkills;
/// 現在の作業ディレクトリ配下で検出された Skill 名候補。
/// `<dir>/.claude/skills/<name>/SKILL.md` の `<name>` を集めたもの。
@override@JsonKey() List<String> get availableSkills {
  if (_availableSkills is EqualUnmodifiableListView) return _availableSkills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableSkills);
}

/// 所属させるフォルダ ID。null なら root（フォルダなし、ADR-0019）。
@override final  String? folderId;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override@JsonKey() final  bool isSubmitting;

/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryEditStateCopyWith<_EntryEditState> get copyWith => __$EntryEditStateCopyWithImpl<_EntryEditState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryEditState&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.workingDirectory, workingDirectory) || other.workingDirectory == workingDirectory)&&(identical(other.action, action) || other.action == action)&&(identical(other.editedCommand, editedCommand) || other.editedCommand == editedCommand)&&(identical(other.editedKeepShellAfterExit, editedKeepShellAfterExit) || other.editedKeepShellAfterExit == editedKeepShellAfterExit)&&(identical(other.editedSkillName, editedSkillName) || other.editedSkillName == editedSkillName)&&const DeepCollectionEquality().equals(other._availableSkills, _availableSkills)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,workingDirectory,action,editedCommand,editedKeepShellAfterExit,editedSkillName,const DeepCollectionEquality().hash(_availableSkills),folderId,const DeepCollectionEquality().hash(_errors),isSubmitting);

@override
String toString() {
  return 'EntryEditState(displayName: $displayName, workingDirectory: $workingDirectory, action: $action, editedCommand: $editedCommand, editedKeepShellAfterExit: $editedKeepShellAfterExit, editedSkillName: $editedSkillName, availableSkills: $availableSkills, folderId: $folderId, errors: $errors, isSubmitting: $isSubmitting)';
}


}

/// @nodoc
abstract mixin class _$EntryEditStateCopyWith<$Res> implements $EntryEditStateCopyWith<$Res> {
  factory _$EntryEditStateCopyWith(_EntryEditState value, $Res Function(_EntryEditState) _then) = __$EntryEditStateCopyWithImpl;
@override @useResult
$Res call({
 String displayName, String workingDirectory, LauncherAction action, String editedCommand, bool editedKeepShellAfterExit, String editedSkillName, List<String> availableSkills, String? folderId, Map<String, String> errors, bool isSubmitting
});


@override $LauncherActionCopyWith<$Res> get action;

}
/// @nodoc
class __$EntryEditStateCopyWithImpl<$Res>
    implements _$EntryEditStateCopyWith<$Res> {
  __$EntryEditStateCopyWithImpl(this._self, this._then);

  final _EntryEditState _self;
  final $Res Function(_EntryEditState) _then;

/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? workingDirectory = null,Object? action = null,Object? editedCommand = null,Object? editedKeepShellAfterExit = null,Object? editedSkillName = null,Object? availableSkills = null,Object? folderId = freezed,Object? errors = null,Object? isSubmitting = null,}) {
  return _then(_EntryEditState(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,workingDirectory: null == workingDirectory ? _self.workingDirectory : workingDirectory // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as LauncherAction,editedCommand: null == editedCommand ? _self.editedCommand : editedCommand // ignore: cast_nullable_to_non_nullable
as String,editedKeepShellAfterExit: null == editedKeepShellAfterExit ? _self.editedKeepShellAfterExit : editedKeepShellAfterExit // ignore: cast_nullable_to_non_nullable
as bool,editedSkillName: null == editedSkillName ? _self.editedSkillName : editedSkillName // ignore: cast_nullable_to_non_nullable
as String,availableSkills: null == availableSkills ? _self._availableSkills : availableSkills // ignore: cast_nullable_to_non_nullable
as List<String>,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LauncherActionCopyWith<$Res> get action {
  
  return $LauncherActionCopyWith<$Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}

// dart format on
