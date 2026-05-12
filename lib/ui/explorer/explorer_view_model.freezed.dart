// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explorer_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExplorerState {

 String get root; String get currentPath; List<ExplorerNode> get children;
/// Create a copy of ExplorerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerStateCopyWith<ExplorerState> get copyWith => _$ExplorerStateCopyWithImpl<ExplorerState>(this as ExplorerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerState&&(identical(other.root, root) || other.root == root)&&(identical(other.currentPath, currentPath) || other.currentPath == currentPath)&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,root,currentPath,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'ExplorerState(root: $root, currentPath: $currentPath, children: $children)';
}


}

/// @nodoc
abstract mixin class $ExplorerStateCopyWith<$Res>  {
  factory $ExplorerStateCopyWith(ExplorerState value, $Res Function(ExplorerState) _then) = _$ExplorerStateCopyWithImpl;
@useResult
$Res call({
 String root, String currentPath, List<ExplorerNode> children
});




}
/// @nodoc
class _$ExplorerStateCopyWithImpl<$Res>
    implements $ExplorerStateCopyWith<$Res> {
  _$ExplorerStateCopyWithImpl(this._self, this._then);

  final ExplorerState _self;
  final $Res Function(ExplorerState) _then;

/// Create a copy of ExplorerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? root = null,Object? currentPath = null,Object? children = null,}) {
  return _then(_self.copyWith(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as String,currentPath: null == currentPath ? _self.currentPath : currentPath // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<ExplorerNode>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExplorerState].
extension ExplorerStatePatterns on ExplorerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExplorerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExplorerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExplorerState value)  $default,){
final _that = this;
switch (_that) {
case _ExplorerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExplorerState value)?  $default,){
final _that = this;
switch (_that) {
case _ExplorerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String root,  String currentPath,  List<ExplorerNode> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExplorerState() when $default != null:
return $default(_that.root,_that.currentPath,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String root,  String currentPath,  List<ExplorerNode> children)  $default,) {final _that = this;
switch (_that) {
case _ExplorerState():
return $default(_that.root,_that.currentPath,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String root,  String currentPath,  List<ExplorerNode> children)?  $default,) {final _that = this;
switch (_that) {
case _ExplorerState() when $default != null:
return $default(_that.root,_that.currentPath,_that.children);case _:
  return null;

}
}

}

/// @nodoc


class _ExplorerState implements ExplorerState {
  const _ExplorerState({required this.root, required this.currentPath, required final  List<ExplorerNode> children}): _children = children;
  

@override final  String root;
@override final  String currentPath;
 final  List<ExplorerNode> _children;
@override List<ExplorerNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of ExplorerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExplorerStateCopyWith<_ExplorerState> get copyWith => __$ExplorerStateCopyWithImpl<_ExplorerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExplorerState&&(identical(other.root, root) || other.root == root)&&(identical(other.currentPath, currentPath) || other.currentPath == currentPath)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,root,currentPath,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'ExplorerState(root: $root, currentPath: $currentPath, children: $children)';
}


}

/// @nodoc
abstract mixin class _$ExplorerStateCopyWith<$Res> implements $ExplorerStateCopyWith<$Res> {
  factory _$ExplorerStateCopyWith(_ExplorerState value, $Res Function(_ExplorerState) _then) = __$ExplorerStateCopyWithImpl;
@override @useResult
$Res call({
 String root, String currentPath, List<ExplorerNode> children
});




}
/// @nodoc
class __$ExplorerStateCopyWithImpl<$Res>
    implements _$ExplorerStateCopyWith<$Res> {
  __$ExplorerStateCopyWithImpl(this._self, this._then);

  final _ExplorerState _self;
  final $Res Function(_ExplorerState) _then;

/// Create a copy of ExplorerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? root = null,Object? currentPath = null,Object? children = null,}) {
  return _then(_ExplorerState(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as String,currentPath: null == currentPath ? _self.currentPath : currentPath // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<ExplorerNode>,
  ));
}


}

// dart format on
