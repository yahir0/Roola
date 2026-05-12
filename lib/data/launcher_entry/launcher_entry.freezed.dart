// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'launcher_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LauncherEntry {

/// 一意 ID（uuid v4）。
 String get id;/// ユーザーが付けた表示名。
 String get displayName;/// 起動対象のローカルリポジトリ絶対パス。
 String get repositoryPath;/// 実行する Skill 名（`claude` プロセスに渡す）。
 String get skillName;/// アイコン画像のローカル絶対パス。未設定なら null（既定アイコンを使う）。
 String? get iconPath;/// エントリ作成日時。
 DateTime get createdAt;
/// Create a copy of LauncherEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LauncherEntryCopyWith<LauncherEntry> get copyWith => _$LauncherEntryCopyWithImpl<LauncherEntry>(this as LauncherEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LauncherEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.repositoryPath, repositoryPath) || other.repositoryPath == repositoryPath)&&(identical(other.skillName, skillName) || other.skillName == skillName)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayName,repositoryPath,skillName,iconPath,createdAt);

@override
String toString() {
  return 'LauncherEntry(id: $id, displayName: $displayName, repositoryPath: $repositoryPath, skillName: $skillName, iconPath: $iconPath, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LauncherEntryCopyWith<$Res>  {
  factory $LauncherEntryCopyWith(LauncherEntry value, $Res Function(LauncherEntry) _then) = _$LauncherEntryCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String repositoryPath, String skillName, String? iconPath, DateTime createdAt
});




}
/// @nodoc
class _$LauncherEntryCopyWithImpl<$Res>
    implements $LauncherEntryCopyWith<$Res> {
  _$LauncherEntryCopyWithImpl(this._self, this._then);

  final LauncherEntry _self;
  final $Res Function(LauncherEntry) _then;

/// Create a copy of LauncherEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? repositoryPath = null,Object? skillName = null,Object? iconPath = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,repositoryPath: null == repositoryPath ? _self.repositoryPath : repositoryPath // ignore: cast_nullable_to_non_nullable
as String,skillName: null == skillName ? _self.skillName : skillName // ignore: cast_nullable_to_non_nullable
as String,iconPath: freezed == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LauncherEntry].
extension LauncherEntryPatterns on LauncherEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LauncherEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LauncherEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LauncherEntry value)  $default,){
final _that = this;
switch (_that) {
case _LauncherEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LauncherEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LauncherEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String repositoryPath,  String skillName,  String? iconPath,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LauncherEntry() when $default != null:
return $default(_that.id,_that.displayName,_that.repositoryPath,_that.skillName,_that.iconPath,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String repositoryPath,  String skillName,  String? iconPath,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LauncherEntry():
return $default(_that.id,_that.displayName,_that.repositoryPath,_that.skillName,_that.iconPath,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String repositoryPath,  String skillName,  String? iconPath,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LauncherEntry() when $default != null:
return $default(_that.id,_that.displayName,_that.repositoryPath,_that.skillName,_that.iconPath,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _LauncherEntry implements LauncherEntry {
  const _LauncherEntry({required this.id, required this.displayName, required this.repositoryPath, required this.skillName, this.iconPath, required this.createdAt});
  

/// 一意 ID（uuid v4）。
@override final  String id;
/// ユーザーが付けた表示名。
@override final  String displayName;
/// 起動対象のローカルリポジトリ絶対パス。
@override final  String repositoryPath;
/// 実行する Skill 名（`claude` プロセスに渡す）。
@override final  String skillName;
/// アイコン画像のローカル絶対パス。未設定なら null（既定アイコンを使う）。
@override final  String? iconPath;
/// エントリ作成日時。
@override final  DateTime createdAt;

/// Create a copy of LauncherEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LauncherEntryCopyWith<_LauncherEntry> get copyWith => __$LauncherEntryCopyWithImpl<_LauncherEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LauncherEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.repositoryPath, repositoryPath) || other.repositoryPath == repositoryPath)&&(identical(other.skillName, skillName) || other.skillName == skillName)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayName,repositoryPath,skillName,iconPath,createdAt);

@override
String toString() {
  return 'LauncherEntry(id: $id, displayName: $displayName, repositoryPath: $repositoryPath, skillName: $skillName, iconPath: $iconPath, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LauncherEntryCopyWith<$Res> implements $LauncherEntryCopyWith<$Res> {
  factory _$LauncherEntryCopyWith(_LauncherEntry value, $Res Function(_LauncherEntry) _then) = __$LauncherEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String repositoryPath, String skillName, String? iconPath, DateTime createdAt
});




}
/// @nodoc
class __$LauncherEntryCopyWithImpl<$Res>
    implements _$LauncherEntryCopyWith<$Res> {
  __$LauncherEntryCopyWithImpl(this._self, this._then);

  final _LauncherEntry _self;
  final $Res Function(_LauncherEntry) _then;

/// Create a copy of LauncherEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? repositoryPath = null,Object? skillName = null,Object? iconPath = freezed,Object? createdAt = null,}) {
  return _then(_LauncherEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,repositoryPath: null == repositoryPath ? _self.repositoryPath : repositoryPath // ignore: cast_nullable_to_non_nullable
as String,skillName: null == skillName ? _self.skillName : skillName // ignore: cast_nullable_to_non_nullable
as String,iconPath: freezed == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
