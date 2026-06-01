// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'terminal_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TerminalSettings {

/// Windows でターミナルタブを開くときに使うシェル。
/// デフォルトは PowerShell 5 (powershell.exe)。
 WindowsShell get windowsShell;
/// Create a copy of TerminalSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerminalSettingsCopyWith<TerminalSettings> get copyWith => _$TerminalSettingsCopyWithImpl<TerminalSettings>(this as TerminalSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalSettings&&(identical(other.windowsShell, windowsShell) || other.windowsShell == windowsShell));
}


@override
int get hashCode => Object.hash(runtimeType,windowsShell);

@override
String toString() {
  return 'TerminalSettings(windowsShell: $windowsShell)';
}


}

/// @nodoc
abstract mixin class $TerminalSettingsCopyWith<$Res>  {
  factory $TerminalSettingsCopyWith(TerminalSettings value, $Res Function(TerminalSettings) _then) = _$TerminalSettingsCopyWithImpl;
@useResult
$Res call({
 WindowsShell windowsShell
});




}
/// @nodoc
class _$TerminalSettingsCopyWithImpl<$Res>
    implements $TerminalSettingsCopyWith<$Res> {
  _$TerminalSettingsCopyWithImpl(this._self, this._then);

  final TerminalSettings _self;
  final $Res Function(TerminalSettings) _then;

/// Create a copy of TerminalSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? windowsShell = null,}) {
  return _then(_self.copyWith(
windowsShell: null == windowsShell ? _self.windowsShell : windowsShell // ignore: cast_nullable_to_non_nullable
as WindowsShell,
  ));
}

}


/// Adds pattern-matching-related methods to [TerminalSettings].
extension TerminalSettingsPatterns on TerminalSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TerminalSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TerminalSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TerminalSettings value)  $default,){
final _that = this;
switch (_that) {
case _TerminalSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TerminalSettings value)?  $default,){
final _that = this;
switch (_that) {
case _TerminalSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WindowsShell windowsShell)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TerminalSettings() when $default != null:
return $default(_that.windowsShell);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WindowsShell windowsShell)  $default,) {final _that = this;
switch (_that) {
case _TerminalSettings():
return $default(_that.windowsShell);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WindowsShell windowsShell)?  $default,) {final _that = this;
switch (_that) {
case _TerminalSettings() when $default != null:
return $default(_that.windowsShell);case _:
  return null;

}
}

}

/// @nodoc


class _TerminalSettings implements TerminalSettings {
  const _TerminalSettings({this.windowsShell = WindowsShell.powershell});
  

/// Windows でターミナルタブを開くときに使うシェル。
/// デフォルトは PowerShell 5 (powershell.exe)。
@override@JsonKey() final  WindowsShell windowsShell;

/// Create a copy of TerminalSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TerminalSettingsCopyWith<_TerminalSettings> get copyWith => __$TerminalSettingsCopyWithImpl<_TerminalSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TerminalSettings&&(identical(other.windowsShell, windowsShell) || other.windowsShell == windowsShell));
}


@override
int get hashCode => Object.hash(runtimeType,windowsShell);

@override
String toString() {
  return 'TerminalSettings(windowsShell: $windowsShell)';
}


}

/// @nodoc
abstract mixin class _$TerminalSettingsCopyWith<$Res> implements $TerminalSettingsCopyWith<$Res> {
  factory _$TerminalSettingsCopyWith(_TerminalSettings value, $Res Function(_TerminalSettings) _then) = __$TerminalSettingsCopyWithImpl;
@override @useResult
$Res call({
 WindowsShell windowsShell
});




}
/// @nodoc
class __$TerminalSettingsCopyWithImpl<$Res>
    implements _$TerminalSettingsCopyWith<$Res> {
  __$TerminalSettingsCopyWithImpl(this._self, this._then);

  final _TerminalSettings _self;
  final $Res Function(_TerminalSettings) _then;

/// Create a copy of TerminalSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? windowsShell = null,}) {
  return _then(_TerminalSettings(
windowsShell: null == windowsShell ? _self.windowsShell : windowsShell // ignore: cast_nullable_to_non_nullable
as WindowsShell,
  ));
}


}

// dart format on
