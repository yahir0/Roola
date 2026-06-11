// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'privacy_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrivacySettings {

/// ユーザーが同意した利用規約の版数。未同意なら null。
/// `currentTermsVersion` より古い場合も再同意が必要（規約改定時）。
 int? get acceptedTermsVersion;/// 匿名利用統計（Aptabase）の送信可否。既定 ON。
/// 同意モーダルと設定画面のトグルで変更できる。
 bool get analyticsEnabled;
/// Create a copy of PrivacySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivacySettingsCopyWith<PrivacySettings> get copyWith => _$PrivacySettingsCopyWithImpl<PrivacySettings>(this as PrivacySettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivacySettings&&(identical(other.acceptedTermsVersion, acceptedTermsVersion) || other.acceptedTermsVersion == acceptedTermsVersion)&&(identical(other.analyticsEnabled, analyticsEnabled) || other.analyticsEnabled == analyticsEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,acceptedTermsVersion,analyticsEnabled);

@override
String toString() {
  return 'PrivacySettings(acceptedTermsVersion: $acceptedTermsVersion, analyticsEnabled: $analyticsEnabled)';
}


}

/// @nodoc
abstract mixin class $PrivacySettingsCopyWith<$Res>  {
  factory $PrivacySettingsCopyWith(PrivacySettings value, $Res Function(PrivacySettings) _then) = _$PrivacySettingsCopyWithImpl;
@useResult
$Res call({
 int? acceptedTermsVersion, bool analyticsEnabled
});




}
/// @nodoc
class _$PrivacySettingsCopyWithImpl<$Res>
    implements $PrivacySettingsCopyWith<$Res> {
  _$PrivacySettingsCopyWithImpl(this._self, this._then);

  final PrivacySettings _self;
  final $Res Function(PrivacySettings) _then;

/// Create a copy of PrivacySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? acceptedTermsVersion = freezed,Object? analyticsEnabled = null,}) {
  return _then(_self.copyWith(
acceptedTermsVersion: freezed == acceptedTermsVersion ? _self.acceptedTermsVersion : acceptedTermsVersion // ignore: cast_nullable_to_non_nullable
as int?,analyticsEnabled: null == analyticsEnabled ? _self.analyticsEnabled : analyticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivacySettings].
extension PrivacySettingsPatterns on PrivacySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivacySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivacySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivacySettings value)  $default,){
final _that = this;
switch (_that) {
case _PrivacySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivacySettings value)?  $default,){
final _that = this;
switch (_that) {
case _PrivacySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? acceptedTermsVersion,  bool analyticsEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivacySettings() when $default != null:
return $default(_that.acceptedTermsVersion,_that.analyticsEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? acceptedTermsVersion,  bool analyticsEnabled)  $default,) {final _that = this;
switch (_that) {
case _PrivacySettings():
return $default(_that.acceptedTermsVersion,_that.analyticsEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? acceptedTermsVersion,  bool analyticsEnabled)?  $default,) {final _that = this;
switch (_that) {
case _PrivacySettings() when $default != null:
return $default(_that.acceptedTermsVersion,_that.analyticsEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _PrivacySettings implements PrivacySettings {
  const _PrivacySettings({this.acceptedTermsVersion, this.analyticsEnabled = true});
  

/// ユーザーが同意した利用規約の版数。未同意なら null。
/// `currentTermsVersion` より古い場合も再同意が必要（規約改定時）。
@override final  int? acceptedTermsVersion;
/// 匿名利用統計（Aptabase）の送信可否。既定 ON。
/// 同意モーダルと設定画面のトグルで変更できる。
@override@JsonKey() final  bool analyticsEnabled;

/// Create a copy of PrivacySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivacySettingsCopyWith<_PrivacySettings> get copyWith => __$PrivacySettingsCopyWithImpl<_PrivacySettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivacySettings&&(identical(other.acceptedTermsVersion, acceptedTermsVersion) || other.acceptedTermsVersion == acceptedTermsVersion)&&(identical(other.analyticsEnabled, analyticsEnabled) || other.analyticsEnabled == analyticsEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,acceptedTermsVersion,analyticsEnabled);

@override
String toString() {
  return 'PrivacySettings(acceptedTermsVersion: $acceptedTermsVersion, analyticsEnabled: $analyticsEnabled)';
}


}

/// @nodoc
abstract mixin class _$PrivacySettingsCopyWith<$Res> implements $PrivacySettingsCopyWith<$Res> {
  factory _$PrivacySettingsCopyWith(_PrivacySettings value, $Res Function(_PrivacySettings) _then) = __$PrivacySettingsCopyWithImpl;
@override @useResult
$Res call({
 int? acceptedTermsVersion, bool analyticsEnabled
});




}
/// @nodoc
class __$PrivacySettingsCopyWithImpl<$Res>
    implements _$PrivacySettingsCopyWith<$Res> {
  __$PrivacySettingsCopyWithImpl(this._self, this._then);

  final _PrivacySettings _self;
  final $Res Function(_PrivacySettings) _then;

/// Create a copy of PrivacySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? acceptedTermsVersion = freezed,Object? analyticsEnabled = null,}) {
  return _then(_PrivacySettings(
acceptedTermsVersion: freezed == acceptedTermsVersion ? _self.acceptedTermsVersion : acceptedTermsVersion // ignore: cast_nullable_to_non_nullable
as int?,analyticsEnabled: null == analyticsEnabled ? _self.analyticsEnabled : analyticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
