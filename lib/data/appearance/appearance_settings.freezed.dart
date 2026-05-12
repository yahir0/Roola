// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appearance_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppearanceSettings {

 AppearanceMode get mode;/// RGBA を 32bit int で保持（`Color.toARGB32()` 相当）。
 int? get solidColor; String? get imagePath;/// `transparent` モードで背景にうっすら載せる暗幕の不透明度（0.0〜1.0）。
/// 1.0 で完全不透明、0.0 で完全透過。色はロゴの deep background 固定。
/// 既定値はウィンドウ枠が視認できる程度の 0.8。
 double get transparencyOpacity;
/// Create a copy of AppearanceSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppearanceSettingsCopyWith<AppearanceSettings> get copyWith => _$AppearanceSettingsCopyWithImpl<AppearanceSettings>(this as AppearanceSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppearanceSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.solidColor, solidColor) || other.solidColor == solidColor)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.transparencyOpacity, transparencyOpacity) || other.transparencyOpacity == transparencyOpacity));
}


@override
int get hashCode => Object.hash(runtimeType,mode,solidColor,imagePath,transparencyOpacity);

@override
String toString() {
  return 'AppearanceSettings(mode: $mode, solidColor: $solidColor, imagePath: $imagePath, transparencyOpacity: $transparencyOpacity)';
}


}

/// @nodoc
abstract mixin class $AppearanceSettingsCopyWith<$Res>  {
  factory $AppearanceSettingsCopyWith(AppearanceSettings value, $Res Function(AppearanceSettings) _then) = _$AppearanceSettingsCopyWithImpl;
@useResult
$Res call({
 AppearanceMode mode, int? solidColor, String? imagePath, double transparencyOpacity
});




}
/// @nodoc
class _$AppearanceSettingsCopyWithImpl<$Res>
    implements $AppearanceSettingsCopyWith<$Res> {
  _$AppearanceSettingsCopyWithImpl(this._self, this._then);

  final AppearanceSettings _self;
  final $Res Function(AppearanceSettings) _then;

/// Create a copy of AppearanceSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? solidColor = freezed,Object? imagePath = freezed,Object? transparencyOpacity = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AppearanceMode,solidColor: freezed == solidColor ? _self.solidColor : solidColor // ignore: cast_nullable_to_non_nullable
as int?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,transparencyOpacity: null == transparencyOpacity ? _self.transparencyOpacity : transparencyOpacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AppearanceSettings].
extension AppearanceSettingsPatterns on AppearanceSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppearanceSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppearanceSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppearanceSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppearanceSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppearanceSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppearanceSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppearanceMode mode,  int? solidColor,  String? imagePath,  double transparencyOpacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppearanceSettings() when $default != null:
return $default(_that.mode,_that.solidColor,_that.imagePath,_that.transparencyOpacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppearanceMode mode,  int? solidColor,  String? imagePath,  double transparencyOpacity)  $default,) {final _that = this;
switch (_that) {
case _AppearanceSettings():
return $default(_that.mode,_that.solidColor,_that.imagePath,_that.transparencyOpacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppearanceMode mode,  int? solidColor,  String? imagePath,  double transparencyOpacity)?  $default,) {final _that = this;
switch (_that) {
case _AppearanceSettings() when $default != null:
return $default(_that.mode,_that.solidColor,_that.imagePath,_that.transparencyOpacity);case _:
  return null;

}
}

}

/// @nodoc


class _AppearanceSettings implements AppearanceSettings {
  const _AppearanceSettings({this.mode = AppearanceMode.transparent, this.solidColor, this.imagePath, this.transparencyOpacity = 0.8});
  

@override@JsonKey() final  AppearanceMode mode;
/// RGBA を 32bit int で保持（`Color.toARGB32()` 相当）。
@override final  int? solidColor;
@override final  String? imagePath;
/// `transparent` モードで背景にうっすら載せる暗幕の不透明度（0.0〜1.0）。
/// 1.0 で完全不透明、0.0 で完全透過。色はロゴの deep background 固定。
/// 既定値はウィンドウ枠が視認できる程度の 0.8。
@override@JsonKey() final  double transparencyOpacity;

/// Create a copy of AppearanceSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppearanceSettingsCopyWith<_AppearanceSettings> get copyWith => __$AppearanceSettingsCopyWithImpl<_AppearanceSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppearanceSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.solidColor, solidColor) || other.solidColor == solidColor)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.transparencyOpacity, transparencyOpacity) || other.transparencyOpacity == transparencyOpacity));
}


@override
int get hashCode => Object.hash(runtimeType,mode,solidColor,imagePath,transparencyOpacity);

@override
String toString() {
  return 'AppearanceSettings(mode: $mode, solidColor: $solidColor, imagePath: $imagePath, transparencyOpacity: $transparencyOpacity)';
}


}

/// @nodoc
abstract mixin class _$AppearanceSettingsCopyWith<$Res> implements $AppearanceSettingsCopyWith<$Res> {
  factory _$AppearanceSettingsCopyWith(_AppearanceSettings value, $Res Function(_AppearanceSettings) _then) = __$AppearanceSettingsCopyWithImpl;
@override @useResult
$Res call({
 AppearanceMode mode, int? solidColor, String? imagePath, double transparencyOpacity
});




}
/// @nodoc
class __$AppearanceSettingsCopyWithImpl<$Res>
    implements _$AppearanceSettingsCopyWith<$Res> {
  __$AppearanceSettingsCopyWithImpl(this._self, this._then);

  final _AppearanceSettings _self;
  final $Res Function(_AppearanceSettings) _then;

/// Create a copy of AppearanceSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? solidColor = freezed,Object? imagePath = freezed,Object? transparencyOpacity = null,}) {
  return _then(_AppearanceSettings(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AppearanceMode,solidColor: freezed == solidColor ? _self.solidColor : solidColor // ignore: cast_nullable_to_non_nullable
as int?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,transparencyOpacity: null == transparencyOpacity ? _self.transparencyOpacity : transparencyOpacity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
