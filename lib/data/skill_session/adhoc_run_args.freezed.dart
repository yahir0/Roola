// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adhoc_run_args.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdhocRunArgs {

 String get adhocId; String get workingDirectory;/// chip 列でのラベル。「ディレクトリ名 / Skill 名」または
/// 「ディレクトリ名 (Claude)」など、呼び出し側が組み立てて渡す。
 String get displayName;/// 起動時にやること（[LauncherAction] の sealed union を再利用）。
 LauncherAction get action;/// Windows でシェルを明示指定する場合に使用。null の場合は設定値を使う。
 WindowsShell? get windowsShell;
/// Create a copy of AdhocRunArgs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdhocRunArgsCopyWith<AdhocRunArgs> get copyWith => _$AdhocRunArgsCopyWithImpl<AdhocRunArgs>(this as AdhocRunArgs, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdhocRunArgs&&(identical(other.adhocId, adhocId) || other.adhocId == adhocId)&&(identical(other.workingDirectory, workingDirectory) || other.workingDirectory == workingDirectory)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.action, action) || other.action == action)&&(identical(other.windowsShell, windowsShell) || other.windowsShell == windowsShell));
}


@override
int get hashCode => Object.hash(runtimeType,adhocId,workingDirectory,displayName,action,windowsShell);

@override
String toString() {
  return 'AdhocRunArgs(adhocId: $adhocId, workingDirectory: $workingDirectory, displayName: $displayName, action: $action, windowsShell: $windowsShell)';
}


}

/// @nodoc
abstract mixin class $AdhocRunArgsCopyWith<$Res>  {
  factory $AdhocRunArgsCopyWith(AdhocRunArgs value, $Res Function(AdhocRunArgs) _then) = _$AdhocRunArgsCopyWithImpl;
@useResult
$Res call({
 String adhocId, String workingDirectory, String displayName, LauncherAction action, WindowsShell? windowsShell
});


$LauncherActionCopyWith<$Res> get action;

}
/// @nodoc
class _$AdhocRunArgsCopyWithImpl<$Res>
    implements $AdhocRunArgsCopyWith<$Res> {
  _$AdhocRunArgsCopyWithImpl(this._self, this._then);

  final AdhocRunArgs _self;
  final $Res Function(AdhocRunArgs) _then;

/// Create a copy of AdhocRunArgs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adhocId = null,Object? workingDirectory = null,Object? displayName = null,Object? action = null,Object? windowsShell = freezed,}) {
  return _then(_self.copyWith(
adhocId: null == adhocId ? _self.adhocId : adhocId // ignore: cast_nullable_to_non_nullable
as String,workingDirectory: null == workingDirectory ? _self.workingDirectory : workingDirectory // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as LauncherAction,windowsShell: freezed == windowsShell ? _self.windowsShell : windowsShell // ignore: cast_nullable_to_non_nullable
as WindowsShell?,
  ));
}
/// Create a copy of AdhocRunArgs
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LauncherActionCopyWith<$Res> get action {
  
  return $LauncherActionCopyWith<$Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdhocRunArgs].
extension AdhocRunArgsPatterns on AdhocRunArgs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdhocRunArgs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdhocRunArgs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdhocRunArgs value)  $default,){
final _that = this;
switch (_that) {
case _AdhocRunArgs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdhocRunArgs value)?  $default,){
final _that = this;
switch (_that) {
case _AdhocRunArgs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String adhocId,  String workingDirectory,  String displayName,  LauncherAction action,  WindowsShell? windowsShell)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdhocRunArgs() when $default != null:
return $default(_that.adhocId,_that.workingDirectory,_that.displayName,_that.action,_that.windowsShell);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String adhocId,  String workingDirectory,  String displayName,  LauncherAction action,  WindowsShell? windowsShell)  $default,) {final _that = this;
switch (_that) {
case _AdhocRunArgs():
return $default(_that.adhocId,_that.workingDirectory,_that.displayName,_that.action,_that.windowsShell);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String adhocId,  String workingDirectory,  String displayName,  LauncherAction action,  WindowsShell? windowsShell)?  $default,) {final _that = this;
switch (_that) {
case _AdhocRunArgs() when $default != null:
return $default(_that.adhocId,_that.workingDirectory,_that.displayName,_that.action,_that.windowsShell);case _:
  return null;

}
}

}

/// @nodoc


class _AdhocRunArgs implements AdhocRunArgs {
  const _AdhocRunArgs({required this.adhocId, required this.workingDirectory, required this.displayName, required this.action, this.windowsShell});


@override final  String adhocId;
@override final  String workingDirectory;
/// chip 列でのラベル。「ディレクトリ名 / Skill 名」または
/// 「ディレクトリ名 (Claude)」など、呼び出し側が組み立てて渡す。
@override final  String displayName;
/// 起動時にやること（[LauncherAction] の sealed union を再利用）。
@override final  LauncherAction action;
/// Windows でシェルを明示指定する場合に使用。null の場合は設定値を使う。
@override final  WindowsShell? windowsShell;

/// Create a copy of AdhocRunArgs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdhocRunArgsCopyWith<_AdhocRunArgs> get copyWith => __$AdhocRunArgsCopyWithImpl<_AdhocRunArgs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdhocRunArgs&&(identical(other.adhocId, adhocId) || other.adhocId == adhocId)&&(identical(other.workingDirectory, workingDirectory) || other.workingDirectory == workingDirectory)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.action, action) || other.action == action)&&(identical(other.windowsShell, windowsShell) || other.windowsShell == windowsShell));
}


@override
int get hashCode => Object.hash(runtimeType,adhocId,workingDirectory,displayName,action,windowsShell);

@override
String toString() {
  return 'AdhocRunArgs(adhocId: $adhocId, workingDirectory: $workingDirectory, displayName: $displayName, action: $action, windowsShell: $windowsShell)';
}


}

/// @nodoc
abstract mixin class _$AdhocRunArgsCopyWith<$Res> implements $AdhocRunArgsCopyWith<$Res> {
  factory _$AdhocRunArgsCopyWith(_AdhocRunArgs value, $Res Function(_AdhocRunArgs) _then) = __$AdhocRunArgsCopyWithImpl;
@override @useResult
$Res call({
 String adhocId, String workingDirectory, String displayName, LauncherAction action, WindowsShell? windowsShell
});


@override $LauncherActionCopyWith<$Res> get action;

}
/// @nodoc
class __$AdhocRunArgsCopyWithImpl<$Res>
    implements _$AdhocRunArgsCopyWith<$Res> {
  __$AdhocRunArgsCopyWithImpl(this._self, this._then);

  final _AdhocRunArgs _self;
  final $Res Function(_AdhocRunArgs) _then;

/// Create a copy of AdhocRunArgs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? adhocId = null,Object? workingDirectory = null,Object? displayName = null,Object? action = null,Object? windowsShell = freezed,}) {
  return _then(_AdhocRunArgs(
adhocId: null == adhocId ? _self.adhocId : adhocId // ignore: cast_nullable_to_non_nullable
as String,workingDirectory: null == workingDirectory ? _self.workingDirectory : workingDirectory // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as LauncherAction,windowsShell: freezed == windowsShell ? _self.windowsShell : windowsShell // ignore: cast_nullable_to_non_nullable
as WindowsShell?,
  ));
}

/// Create a copy of AdhocRunArgs
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
