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

 String get adhocId; String get repositoryPath;/// chip 列でのラベル。「ディレクトリ名 / Skill 名」または
/// 「ディレクトリ名 (Claude)」など、呼び出し側が組み立てて渡す。
 String get displayName;/// 空文字なら Skill 指定なし（`claude` 単独起動）。
 String get skillName;/// 実行種別。既定は `claudeCode`（既存呼び出しの互換）。
 AdhocRunKind get kind;
/// Create a copy of AdhocRunArgs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdhocRunArgsCopyWith<AdhocRunArgs> get copyWith => _$AdhocRunArgsCopyWithImpl<AdhocRunArgs>(this as AdhocRunArgs, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdhocRunArgs&&(identical(other.adhocId, adhocId) || other.adhocId == adhocId)&&(identical(other.repositoryPath, repositoryPath) || other.repositoryPath == repositoryPath)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.skillName, skillName) || other.skillName == skillName)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,adhocId,repositoryPath,displayName,skillName,kind);

@override
String toString() {
  return 'AdhocRunArgs(adhocId: $adhocId, repositoryPath: $repositoryPath, displayName: $displayName, skillName: $skillName, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $AdhocRunArgsCopyWith<$Res>  {
  factory $AdhocRunArgsCopyWith(AdhocRunArgs value, $Res Function(AdhocRunArgs) _then) = _$AdhocRunArgsCopyWithImpl;
@useResult
$Res call({
 String adhocId, String repositoryPath, String displayName, String skillName, AdhocRunKind kind
});




}
/// @nodoc
class _$AdhocRunArgsCopyWithImpl<$Res>
    implements $AdhocRunArgsCopyWith<$Res> {
  _$AdhocRunArgsCopyWithImpl(this._self, this._then);

  final AdhocRunArgs _self;
  final $Res Function(AdhocRunArgs) _then;

/// Create a copy of AdhocRunArgs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adhocId = null,Object? repositoryPath = null,Object? displayName = null,Object? skillName = null,Object? kind = null,}) {
  return _then(_self.copyWith(
adhocId: null == adhocId ? _self.adhocId : adhocId // ignore: cast_nullable_to_non_nullable
as String,repositoryPath: null == repositoryPath ? _self.repositoryPath : repositoryPath // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,skillName: null == skillName ? _self.skillName : skillName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AdhocRunKind,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String adhocId,  String repositoryPath,  String displayName,  String skillName,  AdhocRunKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdhocRunArgs() when $default != null:
return $default(_that.adhocId,_that.repositoryPath,_that.displayName,_that.skillName,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String adhocId,  String repositoryPath,  String displayName,  String skillName,  AdhocRunKind kind)  $default,) {final _that = this;
switch (_that) {
case _AdhocRunArgs():
return $default(_that.adhocId,_that.repositoryPath,_that.displayName,_that.skillName,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String adhocId,  String repositoryPath,  String displayName,  String skillName,  AdhocRunKind kind)?  $default,) {final _that = this;
switch (_that) {
case _AdhocRunArgs() when $default != null:
return $default(_that.adhocId,_that.repositoryPath,_that.displayName,_that.skillName,_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _AdhocRunArgs implements AdhocRunArgs {
  const _AdhocRunArgs({required this.adhocId, required this.repositoryPath, required this.displayName, this.skillName = '', this.kind = AdhocRunKind.claudeCode});
  

@override final  String adhocId;
@override final  String repositoryPath;
/// chip 列でのラベル。「ディレクトリ名 / Skill 名」または
/// 「ディレクトリ名 (Claude)」など、呼び出し側が組み立てて渡す。
@override final  String displayName;
/// 空文字なら Skill 指定なし（`claude` 単独起動）。
@override@JsonKey() final  String skillName;
/// 実行種別。既定は `claudeCode`（既存呼び出しの互換）。
@override@JsonKey() final  AdhocRunKind kind;

/// Create a copy of AdhocRunArgs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdhocRunArgsCopyWith<_AdhocRunArgs> get copyWith => __$AdhocRunArgsCopyWithImpl<_AdhocRunArgs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdhocRunArgs&&(identical(other.adhocId, adhocId) || other.adhocId == adhocId)&&(identical(other.repositoryPath, repositoryPath) || other.repositoryPath == repositoryPath)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.skillName, skillName) || other.skillName == skillName)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,adhocId,repositoryPath,displayName,skillName,kind);

@override
String toString() {
  return 'AdhocRunArgs(adhocId: $adhocId, repositoryPath: $repositoryPath, displayName: $displayName, skillName: $skillName, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$AdhocRunArgsCopyWith<$Res> implements $AdhocRunArgsCopyWith<$Res> {
  factory _$AdhocRunArgsCopyWith(_AdhocRunArgs value, $Res Function(_AdhocRunArgs) _then) = __$AdhocRunArgsCopyWithImpl;
@override @useResult
$Res call({
 String adhocId, String repositoryPath, String displayName, String skillName, AdhocRunKind kind
});




}
/// @nodoc
class __$AdhocRunArgsCopyWithImpl<$Res>
    implements _$AdhocRunArgsCopyWith<$Res> {
  __$AdhocRunArgsCopyWithImpl(this._self, this._then);

  final _AdhocRunArgs _self;
  final $Res Function(_AdhocRunArgs) _then;

/// Create a copy of AdhocRunArgs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? adhocId = null,Object? repositoryPath = null,Object? displayName = null,Object? skillName = null,Object? kind = null,}) {
  return _then(_AdhocRunArgs(
adhocId: null == adhocId ? _self.adhocId : adhocId // ignore: cast_nullable_to_non_nullable
as String,repositoryPath: null == repositoryPath ? _self.repositoryPath : repositoryPath // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,skillName: null == skillName ? _self.skillName : skillName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AdhocRunKind,
  ));
}


}

// dart format on
