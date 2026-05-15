// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pane_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaneSlot {

 List<WorkspaceTab> get tabs; int get activeIndex;
/// Create a copy of PaneSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaneSlotCopyWith<PaneSlot> get copyWith => _$PaneSlotCopyWithImpl<PaneSlot>(this as PaneSlot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaneSlot&&const DeepCollectionEquality().equals(other.tabs, tabs)&&(identical(other.activeIndex, activeIndex) || other.activeIndex == activeIndex));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tabs),activeIndex);

@override
String toString() {
  return 'PaneSlot(tabs: $tabs, activeIndex: $activeIndex)';
}


}

/// @nodoc
abstract mixin class $PaneSlotCopyWith<$Res>  {
  factory $PaneSlotCopyWith(PaneSlot value, $Res Function(PaneSlot) _then) = _$PaneSlotCopyWithImpl;
@useResult
$Res call({
 List<WorkspaceTab> tabs, int activeIndex
});




}
/// @nodoc
class _$PaneSlotCopyWithImpl<$Res>
    implements $PaneSlotCopyWith<$Res> {
  _$PaneSlotCopyWithImpl(this._self, this._then);

  final PaneSlot _self;
  final $Res Function(PaneSlot) _then;

/// Create a copy of PaneSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tabs = null,Object? activeIndex = null,}) {
  return _then(_self.copyWith(
tabs: null == tabs ? _self.tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<WorkspaceTab>,activeIndex: null == activeIndex ? _self.activeIndex : activeIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaneSlot].
extension PaneSlotPatterns on PaneSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaneSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaneSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaneSlot value)  $default,){
final _that = this;
switch (_that) {
case _PaneSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaneSlot value)?  $default,){
final _that = this;
switch (_that) {
case _PaneSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WorkspaceTab> tabs,  int activeIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaneSlot() when $default != null:
return $default(_that.tabs,_that.activeIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WorkspaceTab> tabs,  int activeIndex)  $default,) {final _that = this;
switch (_that) {
case _PaneSlot():
return $default(_that.tabs,_that.activeIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WorkspaceTab> tabs,  int activeIndex)?  $default,) {final _that = this;
switch (_that) {
case _PaneSlot() when $default != null:
return $default(_that.tabs,_that.activeIndex);case _:
  return null;

}
}

}

/// @nodoc


class _PaneSlot extends PaneSlot {
  const _PaneSlot({final  List<WorkspaceTab> tabs = const <WorkspaceTab>[], this.activeIndex = 0}): _tabs = tabs,super._();
  

 final  List<WorkspaceTab> _tabs;
@override@JsonKey() List<WorkspaceTab> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}

@override@JsonKey() final  int activeIndex;

/// Create a copy of PaneSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaneSlotCopyWith<_PaneSlot> get copyWith => __$PaneSlotCopyWithImpl<_PaneSlot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaneSlot&&const DeepCollectionEquality().equals(other._tabs, _tabs)&&(identical(other.activeIndex, activeIndex) || other.activeIndex == activeIndex));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tabs),activeIndex);

@override
String toString() {
  return 'PaneSlot(tabs: $tabs, activeIndex: $activeIndex)';
}


}

/// @nodoc
abstract mixin class _$PaneSlotCopyWith<$Res> implements $PaneSlotCopyWith<$Res> {
  factory _$PaneSlotCopyWith(_PaneSlot value, $Res Function(_PaneSlot) _then) = __$PaneSlotCopyWithImpl;
@override @useResult
$Res call({
 List<WorkspaceTab> tabs, int activeIndex
});




}
/// @nodoc
class __$PaneSlotCopyWithImpl<$Res>
    implements _$PaneSlotCopyWith<$Res> {
  __$PaneSlotCopyWithImpl(this._self, this._then);

  final _PaneSlot _self;
  final $Res Function(_PaneSlot) _then;

/// Create a copy of PaneSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tabs = null,Object? activeIndex = null,}) {
  return _then(_PaneSlot(
tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<WorkspaceTab>,activeIndex: null == activeIndex ? _self.activeIndex : activeIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
