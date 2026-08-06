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

 PaneSlot get topLeft; PaneSlot get topRight; PaneSlot get bottomLeft;/// 右下スロット。既定 seed では空で、ユーザーがタブを移動して初めて
/// 4 分割になる（ADR-0068）。
 PaneSlot get bottomRight;/// 上段の高さ比率（0..1）。上下スプリッタで変化する。
 double get topRatio;/// **上段**における `topLeft` の幅比率（0..1）。上段の左右スプリッタで
/// 変化する。下段の分割位置とは独立（ADR-0068）。
 double get leftRatio;/// **下段**における `bottomLeft` の幅比率（0..1）。下段の左右スプリッタで
/// 変化する。上段の分割位置とは独立（ADR-0068）。
 double get bottomLeftRatio;
/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceLayoutCopyWith<WorkspaceLayout> get copyWith => _$WorkspaceLayoutCopyWithImpl<WorkspaceLayout>(this as WorkspaceLayout, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceLayout&&(identical(other.topLeft, topLeft) || other.topLeft == topLeft)&&(identical(other.topRight, topRight) || other.topRight == topRight)&&(identical(other.bottomLeft, bottomLeft) || other.bottomLeft == bottomLeft)&&(identical(other.bottomRight, bottomRight) || other.bottomRight == bottomRight)&&(identical(other.topRatio, topRatio) || other.topRatio == topRatio)&&(identical(other.leftRatio, leftRatio) || other.leftRatio == leftRatio)&&(identical(other.bottomLeftRatio, bottomLeftRatio) || other.bottomLeftRatio == bottomLeftRatio));
}


@override
int get hashCode => Object.hash(runtimeType,topLeft,topRight,bottomLeft,bottomRight,topRatio,leftRatio,bottomLeftRatio);

@override
String toString() {
  return 'WorkspaceLayout(topLeft: $topLeft, topRight: $topRight, bottomLeft: $bottomLeft, bottomRight: $bottomRight, topRatio: $topRatio, leftRatio: $leftRatio, bottomLeftRatio: $bottomLeftRatio)';
}


}

/// @nodoc
abstract mixin class $WorkspaceLayoutCopyWith<$Res>  {
  factory $WorkspaceLayoutCopyWith(WorkspaceLayout value, $Res Function(WorkspaceLayout) _then) = _$WorkspaceLayoutCopyWithImpl;
@useResult
$Res call({
 PaneSlot topLeft, PaneSlot topRight, PaneSlot bottomLeft, PaneSlot bottomRight, double topRatio, double leftRatio, double bottomLeftRatio
});


$PaneSlotCopyWith<$Res> get topLeft;$PaneSlotCopyWith<$Res> get topRight;$PaneSlotCopyWith<$Res> get bottomLeft;$PaneSlotCopyWith<$Res> get bottomRight;

}
/// @nodoc
class _$WorkspaceLayoutCopyWithImpl<$Res>
    implements $WorkspaceLayoutCopyWith<$Res> {
  _$WorkspaceLayoutCopyWithImpl(this._self, this._then);

  final WorkspaceLayout _self;
  final $Res Function(WorkspaceLayout) _then;

/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topLeft = null,Object? topRight = null,Object? bottomLeft = null,Object? bottomRight = null,Object? topRatio = null,Object? leftRatio = null,Object? bottomLeftRatio = null,}) {
  return _then(_self.copyWith(
topLeft: null == topLeft ? _self.topLeft : topLeft // ignore: cast_nullable_to_non_nullable
as PaneSlot,topRight: null == topRight ? _self.topRight : topRight // ignore: cast_nullable_to_non_nullable
as PaneSlot,bottomLeft: null == bottomLeft ? _self.bottomLeft : bottomLeft // ignore: cast_nullable_to_non_nullable
as PaneSlot,bottomRight: null == bottomRight ? _self.bottomRight : bottomRight // ignore: cast_nullable_to_non_nullable
as PaneSlot,topRatio: null == topRatio ? _self.topRatio : topRatio // ignore: cast_nullable_to_non_nullable
as double,leftRatio: null == leftRatio ? _self.leftRatio : leftRatio // ignore: cast_nullable_to_non_nullable
as double,bottomLeftRatio: null == bottomLeftRatio ? _self.bottomLeftRatio : bottomLeftRatio // ignore: cast_nullable_to_non_nullable
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
$PaneSlotCopyWith<$Res> get bottomLeft {
  
  return $PaneSlotCopyWith<$Res>(_self.bottomLeft, (value) {
    return _then(_self.copyWith(bottomLeft: value));
  });
}/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaneSlotCopyWith<$Res> get bottomRight {
  
  return $PaneSlotCopyWith<$Res>(_self.bottomRight, (value) {
    return _then(_self.copyWith(bottomRight: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaneSlot topLeft,  PaneSlot topRight,  PaneSlot bottomLeft,  PaneSlot bottomRight,  double topRatio,  double leftRatio,  double bottomLeftRatio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceLayout() when $default != null:
return $default(_that.topLeft,_that.topRight,_that.bottomLeft,_that.bottomRight,_that.topRatio,_that.leftRatio,_that.bottomLeftRatio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaneSlot topLeft,  PaneSlot topRight,  PaneSlot bottomLeft,  PaneSlot bottomRight,  double topRatio,  double leftRatio,  double bottomLeftRatio)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceLayout():
return $default(_that.topLeft,_that.topRight,_that.bottomLeft,_that.bottomRight,_that.topRatio,_that.leftRatio,_that.bottomLeftRatio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaneSlot topLeft,  PaneSlot topRight,  PaneSlot bottomLeft,  PaneSlot bottomRight,  double topRatio,  double leftRatio,  double bottomLeftRatio)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceLayout() when $default != null:
return $default(_that.topLeft,_that.topRight,_that.bottomLeft,_that.bottomRight,_that.topRatio,_that.leftRatio,_that.bottomLeftRatio);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceLayout extends WorkspaceLayout {
  const _WorkspaceLayout({required this.topLeft, required this.topRight, required this.bottomLeft, this.bottomRight = PaneSlot.empty, this.topRatio = 0.62, this.leftRatio = 0.5, this.bottomLeftRatio = 0.5}): super._();
  

@override final  PaneSlot topLeft;
@override final  PaneSlot topRight;
@override final  PaneSlot bottomLeft;
/// 右下スロット。既定 seed では空で、ユーザーがタブを移動して初めて
/// 4 分割になる（ADR-0068）。
@override@JsonKey() final  PaneSlot bottomRight;
/// 上段の高さ比率（0..1）。上下スプリッタで変化する。
@override@JsonKey() final  double topRatio;
/// **上段**における `topLeft` の幅比率（0..1）。上段の左右スプリッタで
/// 変化する。下段の分割位置とは独立（ADR-0068）。
@override@JsonKey() final  double leftRatio;
/// **下段**における `bottomLeft` の幅比率（0..1）。下段の左右スプリッタで
/// 変化する。上段の分割位置とは独立（ADR-0068）。
@override@JsonKey() final  double bottomLeftRatio;

/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceLayoutCopyWith<_WorkspaceLayout> get copyWith => __$WorkspaceLayoutCopyWithImpl<_WorkspaceLayout>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceLayout&&(identical(other.topLeft, topLeft) || other.topLeft == topLeft)&&(identical(other.topRight, topRight) || other.topRight == topRight)&&(identical(other.bottomLeft, bottomLeft) || other.bottomLeft == bottomLeft)&&(identical(other.bottomRight, bottomRight) || other.bottomRight == bottomRight)&&(identical(other.topRatio, topRatio) || other.topRatio == topRatio)&&(identical(other.leftRatio, leftRatio) || other.leftRatio == leftRatio)&&(identical(other.bottomLeftRatio, bottomLeftRatio) || other.bottomLeftRatio == bottomLeftRatio));
}


@override
int get hashCode => Object.hash(runtimeType,topLeft,topRight,bottomLeft,bottomRight,topRatio,leftRatio,bottomLeftRatio);

@override
String toString() {
  return 'WorkspaceLayout(topLeft: $topLeft, topRight: $topRight, bottomLeft: $bottomLeft, bottomRight: $bottomRight, topRatio: $topRatio, leftRatio: $leftRatio, bottomLeftRatio: $bottomLeftRatio)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceLayoutCopyWith<$Res> implements $WorkspaceLayoutCopyWith<$Res> {
  factory _$WorkspaceLayoutCopyWith(_WorkspaceLayout value, $Res Function(_WorkspaceLayout) _then) = __$WorkspaceLayoutCopyWithImpl;
@override @useResult
$Res call({
 PaneSlot topLeft, PaneSlot topRight, PaneSlot bottomLeft, PaneSlot bottomRight, double topRatio, double leftRatio, double bottomLeftRatio
});


@override $PaneSlotCopyWith<$Res> get topLeft;@override $PaneSlotCopyWith<$Res> get topRight;@override $PaneSlotCopyWith<$Res> get bottomLeft;@override $PaneSlotCopyWith<$Res> get bottomRight;

}
/// @nodoc
class __$WorkspaceLayoutCopyWithImpl<$Res>
    implements _$WorkspaceLayoutCopyWith<$Res> {
  __$WorkspaceLayoutCopyWithImpl(this._self, this._then);

  final _WorkspaceLayout _self;
  final $Res Function(_WorkspaceLayout) _then;

/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topLeft = null,Object? topRight = null,Object? bottomLeft = null,Object? bottomRight = null,Object? topRatio = null,Object? leftRatio = null,Object? bottomLeftRatio = null,}) {
  return _then(_WorkspaceLayout(
topLeft: null == topLeft ? _self.topLeft : topLeft // ignore: cast_nullable_to_non_nullable
as PaneSlot,topRight: null == topRight ? _self.topRight : topRight // ignore: cast_nullable_to_non_nullable
as PaneSlot,bottomLeft: null == bottomLeft ? _self.bottomLeft : bottomLeft // ignore: cast_nullable_to_non_nullable
as PaneSlot,bottomRight: null == bottomRight ? _self.bottomRight : bottomRight // ignore: cast_nullable_to_non_nullable
as PaneSlot,topRatio: null == topRatio ? _self.topRatio : topRatio // ignore: cast_nullable_to_non_nullable
as double,leftRatio: null == leftRatio ? _self.leftRatio : leftRatio // ignore: cast_nullable_to_non_nullable
as double,bottomLeftRatio: null == bottomLeftRatio ? _self.bottomLeftRatio : bottomLeftRatio // ignore: cast_nullable_to_non_nullable
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
$PaneSlotCopyWith<$Res> get bottomLeft {
  
  return $PaneSlotCopyWith<$Res>(_self.bottomLeft, (value) {
    return _then(_self.copyWith(bottomLeft: value));
  });
}/// Create a copy of WorkspaceLayout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaneSlotCopyWith<$Res> get bottomRight {
  
  return $PaneSlotCopyWith<$Res>(_self.bottomRight, (value) {
    return _then(_self.copyWith(bottomRight: value));
  });
}
}

// dart format on
