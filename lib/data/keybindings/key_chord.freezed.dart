// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'key_chord.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KeyChord {

/// トリガキーの [LogicalKeyboardKey.keyId]。
 int get triggerKeyId; bool get meta; bool get control; bool get shift; bool get alt;
/// Create a copy of KeyChord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeyChordCopyWith<KeyChord> get copyWith => _$KeyChordCopyWithImpl<KeyChord>(this as KeyChord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeyChord&&(identical(other.triggerKeyId, triggerKeyId) || other.triggerKeyId == triggerKeyId)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.control, control) || other.control == control)&&(identical(other.shift, shift) || other.shift == shift)&&(identical(other.alt, alt) || other.alt == alt));
}


@override
int get hashCode => Object.hash(runtimeType,triggerKeyId,meta,control,shift,alt);

@override
String toString() {
  return 'KeyChord(triggerKeyId: $triggerKeyId, meta: $meta, control: $control, shift: $shift, alt: $alt)';
}


}

/// @nodoc
abstract mixin class $KeyChordCopyWith<$Res>  {
  factory $KeyChordCopyWith(KeyChord value, $Res Function(KeyChord) _then) = _$KeyChordCopyWithImpl;
@useResult
$Res call({
 int triggerKeyId, bool meta, bool control, bool shift, bool alt
});




}
/// @nodoc
class _$KeyChordCopyWithImpl<$Res>
    implements $KeyChordCopyWith<$Res> {
  _$KeyChordCopyWithImpl(this._self, this._then);

  final KeyChord _self;
  final $Res Function(KeyChord) _then;

/// Create a copy of KeyChord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? triggerKeyId = null,Object? meta = null,Object? control = null,Object? shift = null,Object? alt = null,}) {
  return _then(_self.copyWith(
triggerKeyId: null == triggerKeyId ? _self.triggerKeyId : triggerKeyId // ignore: cast_nullable_to_non_nullable
as int,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as bool,control: null == control ? _self.control : control // ignore: cast_nullable_to_non_nullable
as bool,shift: null == shift ? _self.shift : shift // ignore: cast_nullable_to_non_nullable
as bool,alt: null == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [KeyChord].
extension KeyChordPatterns on KeyChord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeyChord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeyChord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeyChord value)  $default,){
final _that = this;
switch (_that) {
case _KeyChord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeyChord value)?  $default,){
final _that = this;
switch (_that) {
case _KeyChord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int triggerKeyId,  bool meta,  bool control,  bool shift,  bool alt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeyChord() when $default != null:
return $default(_that.triggerKeyId,_that.meta,_that.control,_that.shift,_that.alt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int triggerKeyId,  bool meta,  bool control,  bool shift,  bool alt)  $default,) {final _that = this;
switch (_that) {
case _KeyChord():
return $default(_that.triggerKeyId,_that.meta,_that.control,_that.shift,_that.alt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int triggerKeyId,  bool meta,  bool control,  bool shift,  bool alt)?  $default,) {final _that = this;
switch (_that) {
case _KeyChord() when $default != null:
return $default(_that.triggerKeyId,_that.meta,_that.control,_that.shift,_that.alt);case _:
  return null;

}
}

}

/// @nodoc


class _KeyChord extends KeyChord {
  const _KeyChord({required this.triggerKeyId, this.meta = false, this.control = false, this.shift = false, this.alt = false}): super._();
  

/// トリガキーの [LogicalKeyboardKey.keyId]。
@override final  int triggerKeyId;
@override@JsonKey() final  bool meta;
@override@JsonKey() final  bool control;
@override@JsonKey() final  bool shift;
@override@JsonKey() final  bool alt;

/// Create a copy of KeyChord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeyChordCopyWith<_KeyChord> get copyWith => __$KeyChordCopyWithImpl<_KeyChord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeyChord&&(identical(other.triggerKeyId, triggerKeyId) || other.triggerKeyId == triggerKeyId)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.control, control) || other.control == control)&&(identical(other.shift, shift) || other.shift == shift)&&(identical(other.alt, alt) || other.alt == alt));
}


@override
int get hashCode => Object.hash(runtimeType,triggerKeyId,meta,control,shift,alt);

@override
String toString() {
  return 'KeyChord(triggerKeyId: $triggerKeyId, meta: $meta, control: $control, shift: $shift, alt: $alt)';
}


}

/// @nodoc
abstract mixin class _$KeyChordCopyWith<$Res> implements $KeyChordCopyWith<$Res> {
  factory _$KeyChordCopyWith(_KeyChord value, $Res Function(_KeyChord) _then) = __$KeyChordCopyWithImpl;
@override @useResult
$Res call({
 int triggerKeyId, bool meta, bool control, bool shift, bool alt
});




}
/// @nodoc
class __$KeyChordCopyWithImpl<$Res>
    implements _$KeyChordCopyWith<$Res> {
  __$KeyChordCopyWithImpl(this._self, this._then);

  final _KeyChord _self;
  final $Res Function(_KeyChord) _then;

/// Create a copy of KeyChord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? triggerKeyId = null,Object? meta = null,Object? control = null,Object? shift = null,Object? alt = null,}) {
  return _then(_KeyChord(
triggerKeyId: null == triggerKeyId ? _self.triggerKeyId : triggerKeyId // ignore: cast_nullable_to_non_nullable
as int,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as bool,control: null == control ? _self.control : control // ignore: cast_nullable_to_non_nullable
as bool,shift: null == shift ? _self.shift : shift // ignore: cast_nullable_to_non_nullable
as bool,alt: null == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
