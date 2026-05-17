// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_stash_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitStashEntry {

/// stash スタック上の位置（0 が最新）。
 int get index;/// `git` に渡す参照（例 `stash@{0}`）。
 String get ref;/// stash メッセージ（例 `WIP on main: ...`）。
 String get message;
/// Create a copy of GitStashEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitStashEntryCopyWith<GitStashEntry> get copyWith => _$GitStashEntryCopyWithImpl<GitStashEntry>(this as GitStashEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitStashEntry&&(identical(other.index, index) || other.index == index)&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,index,ref,message);

@override
String toString() {
  return 'GitStashEntry(index: $index, ref: $ref, message: $message)';
}


}

/// @nodoc
abstract mixin class $GitStashEntryCopyWith<$Res>  {
  factory $GitStashEntryCopyWith(GitStashEntry value, $Res Function(GitStashEntry) _then) = _$GitStashEntryCopyWithImpl;
@useResult
$Res call({
 int index, String ref, String message
});




}
/// @nodoc
class _$GitStashEntryCopyWithImpl<$Res>
    implements $GitStashEntryCopyWith<$Res> {
  _$GitStashEntryCopyWithImpl(this._self, this._then);

  final GitStashEntry _self;
  final $Res Function(GitStashEntry) _then;

/// Create a copy of GitStashEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? ref = null,Object? message = null,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GitStashEntry].
extension GitStashEntryPatterns on GitStashEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitStashEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitStashEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitStashEntry value)  $default,){
final _that = this;
switch (_that) {
case _GitStashEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitStashEntry value)?  $default,){
final _that = this;
switch (_that) {
case _GitStashEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  String ref,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitStashEntry() when $default != null:
return $default(_that.index,_that.ref,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  String ref,  String message)  $default,) {final _that = this;
switch (_that) {
case _GitStashEntry():
return $default(_that.index,_that.ref,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  String ref,  String message)?  $default,) {final _that = this;
switch (_that) {
case _GitStashEntry() when $default != null:
return $default(_that.index,_that.ref,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _GitStashEntry implements GitStashEntry {
  const _GitStashEntry({required this.index, required this.ref, required this.message});
  

/// stash スタック上の位置（0 が最新）。
@override final  int index;
/// `git` に渡す参照（例 `stash@{0}`）。
@override final  String ref;
/// stash メッセージ（例 `WIP on main: ...`）。
@override final  String message;

/// Create a copy of GitStashEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitStashEntryCopyWith<_GitStashEntry> get copyWith => __$GitStashEntryCopyWithImpl<_GitStashEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitStashEntry&&(identical(other.index, index) || other.index == index)&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,index,ref,message);

@override
String toString() {
  return 'GitStashEntry(index: $index, ref: $ref, message: $message)';
}


}

/// @nodoc
abstract mixin class _$GitStashEntryCopyWith<$Res> implements $GitStashEntryCopyWith<$Res> {
  factory _$GitStashEntryCopyWith(_GitStashEntry value, $Res Function(_GitStashEntry) _then) = __$GitStashEntryCopyWithImpl;
@override @useResult
$Res call({
 int index, String ref, String message
});




}
/// @nodoc
class __$GitStashEntryCopyWithImpl<$Res>
    implements _$GitStashEntryCopyWith<$Res> {
  __$GitStashEntryCopyWithImpl(this._self, this._then);

  final _GitStashEntry _self;
  final $Res Function(_GitStashEntry) _then;

/// Create a copy of GitStashEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? ref = null,Object? message = null,}) {
  return _then(_GitStashEntry(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
