// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'launcher_folder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LauncherFolder {

/// 一意 ID（uuid v4）。
 String get id;/// ユーザーが付けたフォルダ名。
 String get name;/// フォルダ作成日時。同セクション内での並び順に使う。
 DateTime get createdAt;
/// Create a copy of LauncherFolder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LauncherFolderCopyWith<LauncherFolder> get copyWith => _$LauncherFolderCopyWithImpl<LauncherFolder>(this as LauncherFolder, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LauncherFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt);

@override
String toString() {
  return 'LauncherFolder(id: $id, name: $name, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LauncherFolderCopyWith<$Res>  {
  factory $LauncherFolderCopyWith(LauncherFolder value, $Res Function(LauncherFolder) _then) = _$LauncherFolderCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime createdAt
});




}
/// @nodoc
class _$LauncherFolderCopyWithImpl<$Res>
    implements $LauncherFolderCopyWith<$Res> {
  _$LauncherFolderCopyWithImpl(this._self, this._then);

  final LauncherFolder _self;
  final $Res Function(LauncherFolder) _then;

/// Create a copy of LauncherFolder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LauncherFolder].
extension LauncherFolderPatterns on LauncherFolder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LauncherFolder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LauncherFolder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LauncherFolder value)  $default,){
final _that = this;
switch (_that) {
case _LauncherFolder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LauncherFolder value)?  $default,){
final _that = this;
switch (_that) {
case _LauncherFolder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LauncherFolder() when $default != null:
return $default(_that.id,_that.name,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LauncherFolder():
return $default(_that.id,_that.name,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LauncherFolder() when $default != null:
return $default(_that.id,_that.name,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _LauncherFolder implements LauncherFolder {
  const _LauncherFolder({required this.id, required this.name, required this.createdAt});
  

/// 一意 ID（uuid v4）。
@override final  String id;
/// ユーザーが付けたフォルダ名。
@override final  String name;
/// フォルダ作成日時。同セクション内での並び順に使う。
@override final  DateTime createdAt;

/// Create a copy of LauncherFolder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LauncherFolderCopyWith<_LauncherFolder> get copyWith => __$LauncherFolderCopyWithImpl<_LauncherFolder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LauncherFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt);

@override
String toString() {
  return 'LauncherFolder(id: $id, name: $name, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LauncherFolderCopyWith<$Res> implements $LauncherFolderCopyWith<$Res> {
  factory _$LauncherFolderCopyWith(_LauncherFolder value, $Res Function(_LauncherFolder) _then) = __$LauncherFolderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime createdAt
});




}
/// @nodoc
class __$LauncherFolderCopyWithImpl<$Res>
    implements _$LauncherFolderCopyWith<$Res> {
  __$LauncherFolderCopyWithImpl(this._self, this._then);

  final _LauncherFolder _self;
  final $Res Function(_LauncherFolder) _then;

/// Create a copy of LauncherFolder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,}) {
  return _then(_LauncherFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
