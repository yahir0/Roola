// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keybindings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Keybindings {

 Map<CommandId, KeyChord> get overrides;
/// Create a copy of Keybindings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeybindingsCopyWith<Keybindings> get copyWith => _$KeybindingsCopyWithImpl<Keybindings>(this as Keybindings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Keybindings&&const DeepCollectionEquality().equals(other.overrides, overrides));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(overrides));

@override
String toString() {
  return 'Keybindings(overrides: $overrides)';
}


}

/// @nodoc
abstract mixin class $KeybindingsCopyWith<$Res>  {
  factory $KeybindingsCopyWith(Keybindings value, $Res Function(Keybindings) _then) = _$KeybindingsCopyWithImpl;
@useResult
$Res call({
 Map<CommandId, KeyChord> overrides
});




}
/// @nodoc
class _$KeybindingsCopyWithImpl<$Res>
    implements $KeybindingsCopyWith<$Res> {
  _$KeybindingsCopyWithImpl(this._self, this._then);

  final Keybindings _self;
  final $Res Function(Keybindings) _then;

/// Create a copy of Keybindings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overrides = null,}) {
  return _then(_self.copyWith(
overrides: null == overrides ? _self.overrides : overrides // ignore: cast_nullable_to_non_nullable
as Map<CommandId, KeyChord>,
  ));
}

}


/// Adds pattern-matching-related methods to [Keybindings].
extension KeybindingsPatterns on Keybindings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Keybindings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Keybindings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Keybindings value)  $default,){
final _that = this;
switch (_that) {
case _Keybindings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Keybindings value)?  $default,){
final _that = this;
switch (_that) {
case _Keybindings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<CommandId, KeyChord> overrides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Keybindings() when $default != null:
return $default(_that.overrides);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<CommandId, KeyChord> overrides)  $default,) {final _that = this;
switch (_that) {
case _Keybindings():
return $default(_that.overrides);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<CommandId, KeyChord> overrides)?  $default,) {final _that = this;
switch (_that) {
case _Keybindings() when $default != null:
return $default(_that.overrides);case _:
  return null;

}
}

}

/// @nodoc


class _Keybindings implements Keybindings {
  const _Keybindings({final  Map<CommandId, KeyChord> overrides = const <CommandId, KeyChord>{}}): _overrides = overrides;
  

 final  Map<CommandId, KeyChord> _overrides;
@override@JsonKey() Map<CommandId, KeyChord> get overrides {
  if (_overrides is EqualUnmodifiableMapView) return _overrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_overrides);
}


/// Create a copy of Keybindings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeybindingsCopyWith<_Keybindings> get copyWith => __$KeybindingsCopyWithImpl<_Keybindings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Keybindings&&const DeepCollectionEquality().equals(other._overrides, _overrides));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_overrides));

@override
String toString() {
  return 'Keybindings(overrides: $overrides)';
}


}

/// @nodoc
abstract mixin class _$KeybindingsCopyWith<$Res> implements $KeybindingsCopyWith<$Res> {
  factory _$KeybindingsCopyWith(_Keybindings value, $Res Function(_Keybindings) _then) = __$KeybindingsCopyWithImpl;
@override @useResult
$Res call({
 Map<CommandId, KeyChord> overrides
});




}
/// @nodoc
class __$KeybindingsCopyWithImpl<$Res>
    implements _$KeybindingsCopyWith<$Res> {
  __$KeybindingsCopyWithImpl(this._self, this._then);

  final _Keybindings _self;
  final $Res Function(_Keybindings) _then;

/// Create a copy of Keybindings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overrides = null,}) {
  return _then(_Keybindings(
overrides: null == overrides ? _self._overrides : overrides // ignore: cast_nullable_to_non_nullable
as Map<CommandId, KeyChord>,
  ));
}


}

// dart format on
