// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_dashboard_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivityDashboardSettings {

 ActivityDisplayMode get mode; TachoStyle get tachoStyle;/// CPU をコア別にも表示するか。既定は全体 1 本のみ。
 bool get showAllCores;
/// Create a copy of ActivityDashboardSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityDashboardSettingsCopyWith<ActivityDashboardSettings> get copyWith => _$ActivityDashboardSettingsCopyWithImpl<ActivityDashboardSettings>(this as ActivityDashboardSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityDashboardSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.tachoStyle, tachoStyle) || other.tachoStyle == tachoStyle)&&(identical(other.showAllCores, showAllCores) || other.showAllCores == showAllCores));
}


@override
int get hashCode => Object.hash(runtimeType,mode,tachoStyle,showAllCores);

@override
String toString() {
  return 'ActivityDashboardSettings(mode: $mode, tachoStyle: $tachoStyle, showAllCores: $showAllCores)';
}


}

/// @nodoc
abstract mixin class $ActivityDashboardSettingsCopyWith<$Res>  {
  factory $ActivityDashboardSettingsCopyWith(ActivityDashboardSettings value, $Res Function(ActivityDashboardSettings) _then) = _$ActivityDashboardSettingsCopyWithImpl;
@useResult
$Res call({
 ActivityDisplayMode mode, TachoStyle tachoStyle, bool showAllCores
});




}
/// @nodoc
class _$ActivityDashboardSettingsCopyWithImpl<$Res>
    implements $ActivityDashboardSettingsCopyWith<$Res> {
  _$ActivityDashboardSettingsCopyWithImpl(this._self, this._then);

  final ActivityDashboardSettings _self;
  final $Res Function(ActivityDashboardSettings) _then;

/// Create a copy of ActivityDashboardSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? tachoStyle = null,Object? showAllCores = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ActivityDisplayMode,tachoStyle: null == tachoStyle ? _self.tachoStyle : tachoStyle // ignore: cast_nullable_to_non_nullable
as TachoStyle,showAllCores: null == showAllCores ? _self.showAllCores : showAllCores // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityDashboardSettings].
extension ActivityDashboardSettingsPatterns on ActivityDashboardSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityDashboardSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityDashboardSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityDashboardSettings value)  $default,){
final _that = this;
switch (_that) {
case _ActivityDashboardSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityDashboardSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityDashboardSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ActivityDisplayMode mode,  TachoStyle tachoStyle,  bool showAllCores)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityDashboardSettings() when $default != null:
return $default(_that.mode,_that.tachoStyle,_that.showAllCores);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ActivityDisplayMode mode,  TachoStyle tachoStyle,  bool showAllCores)  $default,) {final _that = this;
switch (_that) {
case _ActivityDashboardSettings():
return $default(_that.mode,_that.tachoStyle,_that.showAllCores);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ActivityDisplayMode mode,  TachoStyle tachoStyle,  bool showAllCores)?  $default,) {final _that = this;
switch (_that) {
case _ActivityDashboardSettings() when $default != null:
return $default(_that.mode,_that.tachoStyle,_that.showAllCores);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityDashboardSettings implements ActivityDashboardSettings {
  const _ActivityDashboardSettings({this.mode = ActivityDisplayMode.level, this.tachoStyle = TachoStyle.classic, this.showAllCores = false});
  

@override@JsonKey() final  ActivityDisplayMode mode;
@override@JsonKey() final  TachoStyle tachoStyle;
/// CPU をコア別にも表示するか。既定は全体 1 本のみ。
@override@JsonKey() final  bool showAllCores;

/// Create a copy of ActivityDashboardSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityDashboardSettingsCopyWith<_ActivityDashboardSettings> get copyWith => __$ActivityDashboardSettingsCopyWithImpl<_ActivityDashboardSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityDashboardSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.tachoStyle, tachoStyle) || other.tachoStyle == tachoStyle)&&(identical(other.showAllCores, showAllCores) || other.showAllCores == showAllCores));
}


@override
int get hashCode => Object.hash(runtimeType,mode,tachoStyle,showAllCores);

@override
String toString() {
  return 'ActivityDashboardSettings(mode: $mode, tachoStyle: $tachoStyle, showAllCores: $showAllCores)';
}


}

/// @nodoc
abstract mixin class _$ActivityDashboardSettingsCopyWith<$Res> implements $ActivityDashboardSettingsCopyWith<$Res> {
  factory _$ActivityDashboardSettingsCopyWith(_ActivityDashboardSettings value, $Res Function(_ActivityDashboardSettings) _then) = __$ActivityDashboardSettingsCopyWithImpl;
@override @useResult
$Res call({
 ActivityDisplayMode mode, TachoStyle tachoStyle, bool showAllCores
});




}
/// @nodoc
class __$ActivityDashboardSettingsCopyWithImpl<$Res>
    implements _$ActivityDashboardSettingsCopyWith<$Res> {
  __$ActivityDashboardSettingsCopyWithImpl(this._self, this._then);

  final _ActivityDashboardSettings _self;
  final $Res Function(_ActivityDashboardSettings) _then;

/// Create a copy of ActivityDashboardSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? tachoStyle = null,Object? showAllCores = null,}) {
  return _then(_ActivityDashboardSettings(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ActivityDisplayMode,tachoStyle: null == tachoStyle ? _self.tachoStyle : tachoStyle // ignore: cast_nullable_to_non_nullable
as TachoStyle,showAllCores: null == showAllCores ? _self.showAllCores : showAllCores // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
