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
 String? get rootPath;/// サイドバーに並べるお気に入り。先頭から順に表示する。
 List<ExplorerFavorite> get favorites;
/// Create a copy of ExplorerSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerSettingsCopyWith<ExplorerSettings> get copyWith => _$ExplorerSettingsCopyWithImpl<ExplorerSettings>(this as ExplorerSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerSettings&&(identical(other.rootPath, rootPath) || other.rootPath == rootPath)&&const DeepCollectionEquality().equals(other.favorites, favorites));
}


@override
int get hashCode => Object.hash(runtimeType,rootPath,const DeepCollectionEquality().hash(favorites));

@override
String toString() {
  return 'ExplorerSettings(rootPath: $rootPath, favorites: $favorites)';
}


}

/// @nodoc
abstract mixin class $ExplorerSettingsCopyWith<$Res>  {
  factory $ExplorerSettingsCopyWith(ExplorerSettings value, $Res Function(ExplorerSettings) _then) = _$ExplorerSettingsCopyWithImpl;
@useResult
$Res call({
 String? rootPath, List<ExplorerFavorite> favorites
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
@pragma('vm:prefer-inline') @override $Res call({Object? rootPath = freezed,Object? favorites = null,}) {
  return _then(_self.copyWith(
rootPath: freezed == rootPath ? _self.rootPath : rootPath // ignore: cast_nullable_to_non_nullable
as String?,favorites: null == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<ExplorerFavorite>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? rootPath,  List<ExplorerFavorite> favorites)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExplorerSettings() when $default != null:
return $default(_that.rootPath,_that.favorites);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? rootPath,  List<ExplorerFavorite> favorites)  $default,) {final _that = this;
switch (_that) {
case _ExplorerSettings():
return $default(_that.rootPath,_that.favorites);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? rootPath,  List<ExplorerFavorite> favorites)?  $default,) {final _that = this;
switch (_that) {
case _ExplorerSettings() when $default != null:
return $default(_that.rootPath,_that.favorites);case _:
  return null;

}
}

}

/// @nodoc


class _ExplorerSettings implements ExplorerSettings {
  const _ExplorerSettings({this.rootPath, final  List<ExplorerFavorite> favorites = const <ExplorerFavorite>[]}): _favorites = favorites;
  

/// 最後に開いていたルートディレクトリの絶対パス。`null` なら未設定
/// （ホームディレクトリで開く）。
@override final  String? rootPath;
/// サイドバーに並べるお気に入り。先頭から順に表示する。
 final  List<ExplorerFavorite> _favorites;
/// サイドバーに並べるお気に入り。先頭から順に表示する。
@override@JsonKey() List<ExplorerFavorite> get favorites {
  if (_favorites is EqualUnmodifiableListView) return _favorites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favorites);
}


/// Create a copy of ExplorerSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExplorerSettingsCopyWith<_ExplorerSettings> get copyWith => __$ExplorerSettingsCopyWithImpl<_ExplorerSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExplorerSettings&&(identical(other.rootPath, rootPath) || other.rootPath == rootPath)&&const DeepCollectionEquality().equals(other._favorites, _favorites));
}


@override
int get hashCode => Object.hash(runtimeType,rootPath,const DeepCollectionEquality().hash(_favorites));

@override
String toString() {
  return 'ExplorerSettings(rootPath: $rootPath, favorites: $favorites)';
}


}

/// @nodoc
abstract mixin class _$ExplorerSettingsCopyWith<$Res> implements $ExplorerSettingsCopyWith<$Res> {
  factory _$ExplorerSettingsCopyWith(_ExplorerSettings value, $Res Function(_ExplorerSettings) _then) = __$ExplorerSettingsCopyWithImpl;
@override @useResult
$Res call({
 String? rootPath, List<ExplorerFavorite> favorites
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
@override @pragma('vm:prefer-inline') $Res call({Object? rootPath = freezed,Object? favorites = null,}) {
  return _then(_ExplorerSettings(
rootPath: freezed == rootPath ? _self.rootPath : rootPath // ignore: cast_nullable_to_non_nullable
as String?,favorites: null == favorites ? _self._favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<ExplorerFavorite>,
  ));
}


}

/// @nodoc
mixin _$ExplorerFavorite {

 String get id; String get path; String get name;
/// Create a copy of ExplorerFavorite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerFavoriteCopyWith<ExplorerFavorite> get copyWith => _$ExplorerFavoriteCopyWithImpl<ExplorerFavorite>(this as ExplorerFavorite, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerFavorite&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,path,name);

@override
String toString() {
  return 'ExplorerFavorite(id: $id, path: $path, name: $name)';
}


}

/// @nodoc
abstract mixin class $ExplorerFavoriteCopyWith<$Res>  {
  factory $ExplorerFavoriteCopyWith(ExplorerFavorite value, $Res Function(ExplorerFavorite) _then) = _$ExplorerFavoriteCopyWithImpl;
@useResult
$Res call({
 String id, String path, String name
});




}
/// @nodoc
class _$ExplorerFavoriteCopyWithImpl<$Res>
    implements $ExplorerFavoriteCopyWith<$Res> {
  _$ExplorerFavoriteCopyWithImpl(this._self, this._then);

  final ExplorerFavorite _self;
  final $Res Function(ExplorerFavorite) _then;

/// Create a copy of ExplorerFavorite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? path = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExplorerFavorite].
extension ExplorerFavoritePatterns on ExplorerFavorite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExplorerFavorite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExplorerFavorite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExplorerFavorite value)  $default,){
final _that = this;
switch (_that) {
case _ExplorerFavorite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExplorerFavorite value)?  $default,){
final _that = this;
switch (_that) {
case _ExplorerFavorite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String path,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExplorerFavorite() when $default != null:
return $default(_that.id,_that.path,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String path,  String name)  $default,) {final _that = this;
switch (_that) {
case _ExplorerFavorite():
return $default(_that.id,_that.path,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String path,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ExplorerFavorite() when $default != null:
return $default(_that.id,_that.path,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _ExplorerFavorite implements ExplorerFavorite {
  const _ExplorerFavorite({required this.id, required this.path, required this.name});
  

@override final  String id;
@override final  String path;
@override final  String name;

/// Create a copy of ExplorerFavorite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExplorerFavoriteCopyWith<_ExplorerFavorite> get copyWith => __$ExplorerFavoriteCopyWithImpl<_ExplorerFavorite>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExplorerFavorite&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,path,name);

@override
String toString() {
  return 'ExplorerFavorite(id: $id, path: $path, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ExplorerFavoriteCopyWith<$Res> implements $ExplorerFavoriteCopyWith<$Res> {
  factory _$ExplorerFavoriteCopyWith(_ExplorerFavorite value, $Res Function(_ExplorerFavorite) _then) = __$ExplorerFavoriteCopyWithImpl;
@override @useResult
$Res call({
 String id, String path, String name
});




}
/// @nodoc
class __$ExplorerFavoriteCopyWithImpl<$Res>
    implements _$ExplorerFavoriteCopyWith<$Res> {
  __$ExplorerFavoriteCopyWithImpl(this._self, this._then);

  final _ExplorerFavorite _self;
  final $Res Function(_ExplorerFavorite) _then;

/// Create a copy of ExplorerFavorite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? name = null,}) {
  return _then(_ExplorerFavorite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
