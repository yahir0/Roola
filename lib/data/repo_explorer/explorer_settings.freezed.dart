// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explorer_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExplorerSettings {

/// 最後に開いていたルートディレクトリの絶対パス。`null` なら未設定
/// （ホームディレクトリで開く）。
 String? get rootPath;
/// Create a copy of ExplorerSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerSettingsCopyWith<ExplorerSettings> get copyWith => _$ExplorerSettingsCopyWithImpl<ExplorerSettings>(this as ExplorerSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerSettings&&(identical(other.rootPath, rootPath) || other.rootPath == rootPath));
}


@override
int get hashCode => Object.hash(runtimeType,rootPath);

@override
String toString() {
  return 'ExplorerSettings(rootPath: $rootPath)';
}


}

/// @nodoc
abstract mixin class $ExplorerSettingsCopyWith<$Res>  {
  factory $ExplorerSettingsCopyWith(ExplorerSettings value, $Res Function(ExplorerSettings) _then) = _$ExplorerSettingsCopyWithImpl;
@useResult
$Res call({
 String? rootPath
});




}
/// @nodoc
class _$ExplorerSettingsCopyWithImpl<$Res>
    implements $ExplorerSettingsCopyWith<$Res> {
  _$ExplorerSettingsCopyWithImpl(this._self, this._then);

  final ExplorerSettings _self;
  final $Res Function(ExplorerSettings) _then;

/// Create a copy of ExplorerSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rootPath = freezed,}) {
  return _then(_self.copyWith(
rootPath: freezed == rootPath ? _self.rootPath : rootPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExplorerSettings].
extension ExplorerSettingsPatterns on ExplorerSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExplorerSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExplorerSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExplorerSettings value)  $default,){
final _that = this;
switch (_that) {
case _ExplorerSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExplorerSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ExplorerSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? rootPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExplorerSettings() when $default != null:
return $default(_that.rootPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? rootPath)  $default,) {final _that = this;
switch (_that) {
case _ExplorerSettings():
return $default(_that.rootPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? rootPath)?  $default,) {final _that = this;
switch (_that) {
case _ExplorerSettings() when $default != null:
return $default(_that.rootPath);case _:
  return null;

}
}

}

/// @nodoc


class _ExplorerSettings implements ExplorerSettings {
  const _ExplorerSettings({this.rootPath});
  

/// 最後に開いていたルートディレクトリの絶対パス。`null` なら未設定
/// （ホームディレクトリで開く）。
@override final  String? rootPath;

/// Create a copy of ExplorerSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExplorerSettingsCopyWith<_ExplorerSettings> get copyWith => __$ExplorerSettingsCopyWithImpl<_ExplorerSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExplorerSettings&&(identical(other.rootPath, rootPath) || other.rootPath == rootPath));
}


@override
int get hashCode => Object.hash(runtimeType,rootPath);

@override
String toString() {
  return 'ExplorerSettings(rootPath: $rootPath)';
}


}

/// @nodoc
abstract mixin class _$ExplorerSettingsCopyWith<$Res> implements $ExplorerSettingsCopyWith<$Res> {
  factory _$ExplorerSettingsCopyWith(_ExplorerSettings value, $Res Function(_ExplorerSettings) _then) = __$ExplorerSettingsCopyWithImpl;
@override @useResult
$Res call({
 String? rootPath
});




}
/// @nodoc
class __$ExplorerSettingsCopyWithImpl<$Res>
    implements _$ExplorerSettingsCopyWith<$Res> {
  __$ExplorerSettingsCopyWithImpl(this._self, this._then);

  final _ExplorerSettings _self;
  final $Res Function(_ExplorerSettings) _then;

/// Create a copy of ExplorerSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rootPath = freezed,}) {
  return _then(_ExplorerSettings(
rootPath: freezed == rootPath ? _self.rootPath : rootPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
