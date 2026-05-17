// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_graph_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitGraphRoute {

 int get fromLane; int get toLane;
/// Create a copy of GitGraphRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitGraphRouteCopyWith<GitGraphRoute> get copyWith => _$GitGraphRouteCopyWithImpl<GitGraphRoute>(this as GitGraphRoute, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitGraphRoute&&(identical(other.fromLane, fromLane) || other.fromLane == fromLane)&&(identical(other.toLane, toLane) || other.toLane == toLane));
}


@override
int get hashCode => Object.hash(runtimeType,fromLane,toLane);

@override
String toString() {
  return 'GitGraphRoute(fromLane: $fromLane, toLane: $toLane)';
}


}

/// @nodoc
abstract mixin class $GitGraphRouteCopyWith<$Res>  {
  factory $GitGraphRouteCopyWith(GitGraphRoute value, $Res Function(GitGraphRoute) _then) = _$GitGraphRouteCopyWithImpl;
@useResult
$Res call({
 int fromLane, int toLane
});




}
/// @nodoc
class _$GitGraphRouteCopyWithImpl<$Res>
    implements $GitGraphRouteCopyWith<$Res> {
  _$GitGraphRouteCopyWithImpl(this._self, this._then);

  final GitGraphRoute _self;
  final $Res Function(GitGraphRoute) _then;

/// Create a copy of GitGraphRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromLane = null,Object? toLane = null,}) {
  return _then(_self.copyWith(
fromLane: null == fromLane ? _self.fromLane : fromLane // ignore: cast_nullable_to_non_nullable
as int,toLane: null == toLane ? _self.toLane : toLane // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GitGraphRoute].
extension GitGraphRoutePatterns on GitGraphRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitGraphRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitGraphRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitGraphRoute value)  $default,){
final _that = this;
switch (_that) {
case _GitGraphRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitGraphRoute value)?  $default,){
final _that = this;
switch (_that) {
case _GitGraphRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int fromLane,  int toLane)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitGraphRoute() when $default != null:
return $default(_that.fromLane,_that.toLane);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int fromLane,  int toLane)  $default,) {final _that = this;
switch (_that) {
case _GitGraphRoute():
return $default(_that.fromLane,_that.toLane);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int fromLane,  int toLane)?  $default,) {final _that = this;
switch (_that) {
case _GitGraphRoute() when $default != null:
return $default(_that.fromLane,_that.toLane);case _:
  return null;

}
}

}

/// @nodoc


class _GitGraphRoute implements GitGraphRoute {
  const _GitGraphRoute({required this.fromLane, required this.toLane});
  

@override final  int fromLane;
@override final  int toLane;

/// Create a copy of GitGraphRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitGraphRouteCopyWith<_GitGraphRoute> get copyWith => __$GitGraphRouteCopyWithImpl<_GitGraphRoute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitGraphRoute&&(identical(other.fromLane, fromLane) || other.fromLane == fromLane)&&(identical(other.toLane, toLane) || other.toLane == toLane));
}


@override
int get hashCode => Object.hash(runtimeType,fromLane,toLane);

@override
String toString() {
  return 'GitGraphRoute(fromLane: $fromLane, toLane: $toLane)';
}


}

/// @nodoc
abstract mixin class _$GitGraphRouteCopyWith<$Res> implements $GitGraphRouteCopyWith<$Res> {
  factory _$GitGraphRouteCopyWith(_GitGraphRoute value, $Res Function(_GitGraphRoute) _then) = __$GitGraphRouteCopyWithImpl;
@override @useResult
$Res call({
 int fromLane, int toLane
});




}
/// @nodoc
class __$GitGraphRouteCopyWithImpl<$Res>
    implements _$GitGraphRouteCopyWith<$Res> {
  __$GitGraphRouteCopyWithImpl(this._self, this._then);

  final _GitGraphRoute _self;
  final $Res Function(_GitGraphRoute) _then;

/// Create a copy of GitGraphRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromLane = null,Object? toLane = null,}) {
  return _then(_GitGraphRoute(
fromLane: null == fromLane ? _self.fromLane : fromLane // ignore: cast_nullable_to_non_nullable
as int,toLane: null == toLane ? _self.toLane : toLane // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GitGraphRow {

/// この行のコミット。
 GitCommit get commit;/// コミットの丸印を打つレーン番号（0 始まり）。
 int get dotLane;/// この行を貫く線分群。
 List<GitGraphRoute> get routes;/// この行で使われるレーン数（描画幅の算出に使う）。
 int get laneCount;
/// Create a copy of GitGraphRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitGraphRowCopyWith<GitGraphRow> get copyWith => _$GitGraphRowCopyWithImpl<GitGraphRow>(this as GitGraphRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitGraphRow&&(identical(other.commit, commit) || other.commit == commit)&&(identical(other.dotLane, dotLane) || other.dotLane == dotLane)&&const DeepCollectionEquality().equals(other.routes, routes)&&(identical(other.laneCount, laneCount) || other.laneCount == laneCount));
}


@override
int get hashCode => Object.hash(runtimeType,commit,dotLane,const DeepCollectionEquality().hash(routes),laneCount);

@override
String toString() {
  return 'GitGraphRow(commit: $commit, dotLane: $dotLane, routes: $routes, laneCount: $laneCount)';
}


}

/// @nodoc
abstract mixin class $GitGraphRowCopyWith<$Res>  {
  factory $GitGraphRowCopyWith(GitGraphRow value, $Res Function(GitGraphRow) _then) = _$GitGraphRowCopyWithImpl;
@useResult
$Res call({
 GitCommit commit, int dotLane, List<GitGraphRoute> routes, int laneCount
});


$GitCommitCopyWith<$Res> get commit;

}
/// @nodoc
class _$GitGraphRowCopyWithImpl<$Res>
    implements $GitGraphRowCopyWith<$Res> {
  _$GitGraphRowCopyWithImpl(this._self, this._then);

  final GitGraphRow _self;
  final $Res Function(GitGraphRow) _then;

/// Create a copy of GitGraphRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commit = null,Object? dotLane = null,Object? routes = null,Object? laneCount = null,}) {
  return _then(_self.copyWith(
commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as GitCommit,dotLane: null == dotLane ? _self.dotLane : dotLane // ignore: cast_nullable_to_non_nullable
as int,routes: null == routes ? _self.routes : routes // ignore: cast_nullable_to_non_nullable
as List<GitGraphRoute>,laneCount: null == laneCount ? _self.laneCount : laneCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of GitGraphRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitCommitCopyWith<$Res> get commit {
  
  return $GitCommitCopyWith<$Res>(_self.commit, (value) {
    return _then(_self.copyWith(commit: value));
  });
}
}


/// Adds pattern-matching-related methods to [GitGraphRow].
extension GitGraphRowPatterns on GitGraphRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitGraphRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitGraphRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitGraphRow value)  $default,){
final _that = this;
switch (_that) {
case _GitGraphRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitGraphRow value)?  $default,){
final _that = this;
switch (_that) {
case _GitGraphRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GitCommit commit,  int dotLane,  List<GitGraphRoute> routes,  int laneCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitGraphRow() when $default != null:
return $default(_that.commit,_that.dotLane,_that.routes,_that.laneCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GitCommit commit,  int dotLane,  List<GitGraphRoute> routes,  int laneCount)  $default,) {final _that = this;
switch (_that) {
case _GitGraphRow():
return $default(_that.commit,_that.dotLane,_that.routes,_that.laneCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GitCommit commit,  int dotLane,  List<GitGraphRoute> routes,  int laneCount)?  $default,) {final _that = this;
switch (_that) {
case _GitGraphRow() when $default != null:
return $default(_that.commit,_that.dotLane,_that.routes,_that.laneCount);case _:
  return null;

}
}

}

/// @nodoc


class _GitGraphRow implements GitGraphRow {
  const _GitGraphRow({required this.commit, required this.dotLane, required final  List<GitGraphRoute> routes, required this.laneCount}): _routes = routes;
  

/// この行のコミット。
@override final  GitCommit commit;
/// コミットの丸印を打つレーン番号（0 始まり）。
@override final  int dotLane;
/// この行を貫く線分群。
 final  List<GitGraphRoute> _routes;
/// この行を貫く線分群。
@override List<GitGraphRoute> get routes {
  if (_routes is EqualUnmodifiableListView) return _routes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routes);
}

/// この行で使われるレーン数（描画幅の算出に使う）。
@override final  int laneCount;

/// Create a copy of GitGraphRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitGraphRowCopyWith<_GitGraphRow> get copyWith => __$GitGraphRowCopyWithImpl<_GitGraphRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitGraphRow&&(identical(other.commit, commit) || other.commit == commit)&&(identical(other.dotLane, dotLane) || other.dotLane == dotLane)&&const DeepCollectionEquality().equals(other._routes, _routes)&&(identical(other.laneCount, laneCount) || other.laneCount == laneCount));
}


@override
int get hashCode => Object.hash(runtimeType,commit,dotLane,const DeepCollectionEquality().hash(_routes),laneCount);

@override
String toString() {
  return 'GitGraphRow(commit: $commit, dotLane: $dotLane, routes: $routes, laneCount: $laneCount)';
}


}

/// @nodoc
abstract mixin class _$GitGraphRowCopyWith<$Res> implements $GitGraphRowCopyWith<$Res> {
  factory _$GitGraphRowCopyWith(_GitGraphRow value, $Res Function(_GitGraphRow) _then) = __$GitGraphRowCopyWithImpl;
@override @useResult
$Res call({
 GitCommit commit, int dotLane, List<GitGraphRoute> routes, int laneCount
});


@override $GitCommitCopyWith<$Res> get commit;

}
/// @nodoc
class __$GitGraphRowCopyWithImpl<$Res>
    implements _$GitGraphRowCopyWith<$Res> {
  __$GitGraphRowCopyWithImpl(this._self, this._then);

  final _GitGraphRow _self;
  final $Res Function(_GitGraphRow) _then;

/// Create a copy of GitGraphRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commit = null,Object? dotLane = null,Object? routes = null,Object? laneCount = null,}) {
  return _then(_GitGraphRow(
commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as GitCommit,dotLane: null == dotLane ? _self.dotLane : dotLane // ignore: cast_nullable_to_non_nullable
as int,routes: null == routes ? _self._routes : routes // ignore: cast_nullable_to_non_nullable
as List<GitGraphRoute>,laneCount: null == laneCount ? _self.laneCount : laneCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GitGraphRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitCommitCopyWith<$Res> get commit {
  
  return $GitCommitCopyWith<$Res>(_self.commit, (value) {
    return _then(_self.copyWith(commit: value));
  });
}
}

// dart format on
