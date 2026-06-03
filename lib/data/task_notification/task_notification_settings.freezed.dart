// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_notification_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskNotificationSettings {

 bool get enabled; int? get preferredPort;
/// Create a copy of TaskNotificationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskNotificationSettingsCopyWith<TaskNotificationSettings> get copyWith => _$TaskNotificationSettingsCopyWithImpl<TaskNotificationSettings>(this as TaskNotificationSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskNotificationSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.preferredPort, preferredPort) || other.preferredPort == preferredPort));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,preferredPort);

@override
String toString() {
  return 'TaskNotificationSettings(enabled: $enabled, preferredPort: $preferredPort)';
}


}

/// @nodoc
abstract mixin class $TaskNotificationSettingsCopyWith<$Res>  {
  factory $TaskNotificationSettingsCopyWith(TaskNotificationSettings value, $Res Function(TaskNotificationSettings) _then) = _$TaskNotificationSettingsCopyWithImpl;
@useResult
$Res call({
 bool enabled, int? preferredPort
});




}
/// @nodoc
class _$TaskNotificationSettingsCopyWithImpl<$Res>
    implements $TaskNotificationSettingsCopyWith<$Res> {
  _$TaskNotificationSettingsCopyWithImpl(this._self, this._then);

  final TaskNotificationSettings _self;
  final $Res Function(TaskNotificationSettings) _then;

/// Create a copy of TaskNotificationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? preferredPort = freezed,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,preferredPort: freezed == preferredPort ? _self.preferredPort : preferredPort // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskNotificationSettings].
extension TaskNotificationSettingsPatterns on TaskNotificationSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskNotificationSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskNotificationSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskNotificationSettings value)  $default,){
final _that = this;
switch (_that) {
case _TaskNotificationSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskNotificationSettings value)?  $default,){
final _that = this;
switch (_that) {
case _TaskNotificationSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int? preferredPort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskNotificationSettings() when $default != null:
return $default(_that.enabled,_that.preferredPort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int? preferredPort)  $default,) {final _that = this;
switch (_that) {
case _TaskNotificationSettings():
return $default(_that.enabled,_that.preferredPort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int? preferredPort)?  $default,) {final _that = this;
switch (_that) {
case _TaskNotificationSettings() when $default != null:
return $default(_that.enabled,_that.preferredPort);case _:
  return null;

}
}

}

/// @nodoc


class _TaskNotificationSettings implements TaskNotificationSettings {
  const _TaskNotificationSettings({this.enabled = false, this.preferredPort});
  

@override@JsonKey() final  bool enabled;
@override final  int? preferredPort;

/// Create a copy of TaskNotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskNotificationSettingsCopyWith<_TaskNotificationSettings> get copyWith => __$TaskNotificationSettingsCopyWithImpl<_TaskNotificationSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskNotificationSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.preferredPort, preferredPort) || other.preferredPort == preferredPort));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,preferredPort);

@override
String toString() {
  return 'TaskNotificationSettings(enabled: $enabled, preferredPort: $preferredPort)';
}


}

/// @nodoc
abstract mixin class _$TaskNotificationSettingsCopyWith<$Res> implements $TaskNotificationSettingsCopyWith<$Res> {
  factory _$TaskNotificationSettingsCopyWith(_TaskNotificationSettings value, $Res Function(_TaskNotificationSettings) _then) = __$TaskNotificationSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int? preferredPort
});




}
/// @nodoc
class __$TaskNotificationSettingsCopyWithImpl<$Res>
    implements _$TaskNotificationSettingsCopyWith<$Res> {
  __$TaskNotificationSettingsCopyWithImpl(this._self, this._then);

  final _TaskNotificationSettings _self;
  final $Res Function(_TaskNotificationSettings) _then;

/// Create a copy of TaskNotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? preferredPort = freezed,}) {
  return _then(_TaskNotificationSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,preferredPort: freezed == preferredPort ? _self.preferredPort : preferredPort // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
