// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_layout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceLayout {

 PaneSlot get topLeft; PaneSlot get topRight; PaneSlot get bottom;/// 上段の高さ比率（0..1）。上下スプリッタで変化する。
 double get topRatio;/// 上段における `topLeft` の幅比率（0..1）。左右スプリッタで変化する。
 double get leftRatio;
/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceLayoutCopyWith<WorkspaceLayout> get copyWith => _$WorkspaceLayoutCopyWithImpl<WorkspaceLayout>(this as WorkspaceLayout, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceLayout&&(identical(other.topLeft, topLeft) || other.topLeft == topLeft)&&(identical(other.topRight, topRight) || other.topRight == topRight)&&(identical(other.bottom, bottom) || other.bottom == bottom)&&(identical(other.topRatio, topRatio) || other.topRatio == topRatio)&&(identical(other.leftRatio, leftRatio) || other.leftRatio == leftRatio));
}


@override
int get hashCode => Object.hash(runtimeType,topLeft,topRight,bottom,topRatio,leftRatio);

@override
String toString() {
  return 'WorkspaceLayout(topLeft: $topLeft, topRight: $topRight, bottom: $bottom, topRatio: $topRatio, leftRatio: $leftRatio)';
}


}

/// @nodoc
abstract mixin class $WorkspaceLayoutCopyWith<$Res>  {
  factory $WorkspaceLayoutCopyWith(WorkspaceLayout value, $Res Function(WorkspaceLayout) _then) = _$WorkspaceLayoutCopyWithImpl;
@useResult
$Res call({
 PaneSlot topLeft, PaneSlot topRight, PaneSlot bottom, double topRatio, double leftRatio
});


$PaneSlotCopyWith<$Res> get topLeft;$PaneSlotCopyWith<$Res> get topRight;$PaneSlotCopyWith<$Res> get bottom;

}
/// @nodoc
class _$WorkspaceLayoutCopyWithImpl<$Res>
    implements $WorkspaceLayoutCopyWith<$Res> {
  _$WorkspaceLayoutCopyWithImpl(this._self, this._then);

  final WorkspaceLayout _self;
  final $Res Function(WorkspaceLayout) _then;

/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topLeft = null,Object? topRight = null,Object? bottom = null,Object? topRatio = null,Object? leftRatio = null,}) {
  return _then(_self.copyWith(
topLeft: null == topLeft ? _self.topLeft : topLeft // ignore: cast_nullable_to_non_nullable
as PaneSlot,topRight: null == topRight ? _self.topRight : topRight // ignore: cast_nullable_to_non_nullable
as PaneSlot,bottom: null == bottom ? _self.bottom : bottom // ignore: cast_nullable_to_non_nullable
as PaneSlot,topRatio: null == topRatio ? _self.topRatio : topRatio // ignore: cast_nullable_to_non_nullable
as double,leftRatio: null == leftRatio ? _self.leftRatio : leftRatio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaneSlotCopyWith<$Res> get topLeft {
  
  return $PaneSlotCopyWith<$Res>(_self.topLeft, (value) {
    return _then(_self.copyWith(topLeft: value));
  });
}/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaneSlotCopyWith<$Res> get topRight {
  
  return $PaneSlotCopyWith<$Res>(_self.topRight, (value) {
    return _then(_self.copyWith(topRight: value));
  });
}/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaneSlotCopyWith<$Res> get bottom {
  
  return $PaneSlotCopyWith<$Res>(_self.bottom, (value) {
    return _then(_self.copyWith(bottom: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkspaceLayout].
extension WorkspaceLayoutPatterns on WorkspaceLayout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceLayout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceLayout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceLayout value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceLayout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceLayout value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceLayout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaneSlot topLeft,  PaneSlot topRight,  PaneSlot bottom,  double topRatio,  double leftRatio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceLayout() when $default != null:
return $default(_that.topLeft,_that.topRight,_that.bottom,_that.topRatio,_that.leftRatio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaneSlot topLeft,  PaneSlot topRight,  PaneSlot bottom,  double topRatio,  double leftRatio)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceLayout():
return $default(_that.topLeft,_that.topRight,_that.bottom,_that.topRatio,_that.leftRatio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaneSlot topLeft,  PaneSlot topRight,  PaneSlot bottom,  double topRatio,  double leftRatio)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceLayout() when $default != null:
return $default(_that.topLeft,_that.topRight,_that.bottom,_that.topRatio,_that.leftRatio);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceLayout extends WorkspaceLayout {
  const _WorkspaceLayout({required this.topLeft, required this.topRight, required this.bottom, this.topRatio = 0.62, this.leftRatio = 0.5}): super._();
  

@override final  PaneSlot topLeft;
@override final  PaneSlot topRight;
@override final  PaneSlot bottom;
/// 上段の高さ比率（0..1）。上下スプリッタで変化する。
@override@JsonKey() final  double topRatio;
/// 上段における `topLeft` の幅比率（0..1）。左右スプリッタで変化する。
@override@JsonKey() final  double leftRatio;

/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceLayoutCopyWith<_WorkspaceLayout> get copyWith => __$WorkspaceLayoutCopyWithImpl<_WorkspaceLayout>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceLayout&&(identical(other.topLeft, topLeft) || other.topLeft == topLeft)&&(identical(other.topRight, topRight) || other.topRight == topRight)&&(identical(other.bottom, bottom) || other.bottom == bottom)&&(identical(other.topRatio, topRatio) || other.topRatio == topRatio)&&(identical(other.leftRatio, leftRatio) || other.leftRatio == leftRatio));
}


@override
int get hashCode => Object.hash(runtimeType,topLeft,topRight,bottom,topRatio,leftRatio);

@override
String toString() {
  return 'WorkspaceLayout(topLeft: $topLeft, topRight: $topRight, bottom: $bottom, topRatio: $topRatio, leftRatio: $leftRatio)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceLayoutCopyWith<$Res> implements $WorkspaceLayoutCopyWith<$Res> {
  factory _$WorkspaceLayoutCopyWith(_WorkspaceLayout value, $Res Function(_WorkspaceLayout) _then) = __$WorkspaceLayoutCopyWithImpl;
@override @useResult
$Res call({
 PaneSlot topLeft, PaneSlot topRight, PaneSlot bottom, double topRatio, double leftRatio
});


@override $PaneSlotCopyWith<$Res> get topLeft;@override $PaneSlotCopyWith<$Res> get topRight;@override $PaneSlotCopyWith<$Res> get bottom;

}
/// @nodoc
class __$WorkspaceLayoutCopyWithImpl<$Res>
    implements _$WorkspaceLayoutCopyWith<$Res> {
  __$WorkspaceLayoutCopyWithImpl(this._self, this._then);

  final _WorkspaceLayout _self;
  final $Res Function(_WorkspaceLayout) _then;

/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topLeft = null,Object? topRight = null,Object? bottom = null,Object? topRatio = null,Object? leftRatio = null,}) {
  return _then(_WorkspaceLayout(
topLeft: null == topLeft ? _self.topLeft : topLeft // ignore: cast_nullable_to_non_nullable
as PaneSlot,topRight: null == topRight ? _self.topRight : topRight // ignore: cast_nullable_to_non_nullable
as PaneSlot,bottom: null == bottom ? _self.bottom : bottom // ignore: cast_nullable_to_non_nullable
as PaneSlot,topRatio: null == topRatio ? _self.topRatio : topRatio // ignore: cast_nullable_to_non_nullable
as double,leftRatio: null == leftRatio ? _self.leftRatio : leftRatio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaneSlotCopyWith<$Res> get topLeft {
  
  return $PaneSlotCopyWith<$Res>(_self.topLeft, (value) {
    return _then(_self.copyWith(topLeft: value));
  });
}/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaneSlotCopyWith<$Res> get topRight {
  
  return $PaneSlotCopyWith<$Res>(_self.topRight, (value) {
    return _then(_self.copyWith(topRight: value));
  });
}/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaneSlotCopyWith<$Res> get bottom {
  
  return $PaneSlotCopyWith<$Res>(_self.bottom, (value) {
    return _then(_self.copyWith(bottom: value));
  });
}
}

// dart format on
