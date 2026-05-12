// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explorer_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExplorerNode {

 String get path; String get name;
/// Create a copy of ExplorerNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerNodeCopyWith<ExplorerNode> get copyWith => _$ExplorerNodeCopyWithImpl<ExplorerNode>(this as ExplorerNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerNode&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,path,name);

@override
String toString() {
  return 'ExplorerNode(path: $path, name: $name)';
}


}

/// @nodoc
abstract mixin class $ExplorerNodeCopyWith<$Res>  {
  factory $ExplorerNodeCopyWith(ExplorerNode value, $Res Function(ExplorerNode) _then) = _$ExplorerNodeCopyWithImpl;
@useResult
$Res call({
 String path, String name
});




}
/// @nodoc
class _$ExplorerNodeCopyWithImpl<$Res>
    implements $ExplorerNodeCopyWith<$Res> {
  _$ExplorerNodeCopyWithImpl(this._self, this._then);

  final ExplorerNode _self;
  final $Res Function(ExplorerNode) _then;

/// Create a copy of ExplorerNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? name = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExplorerNode].
extension ExplorerNodePatterns on ExplorerNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ExplorerDirectoryNode value)?  directory,TResult Function( ExplorerFileNode value)?  file,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ExplorerDirectoryNode() when directory != null:
return directory(_that);case ExplorerFileNode() when file != null:
return file(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ExplorerDirectoryNode value)  directory,required TResult Function( ExplorerFileNode value)  file,}){
final _that = this;
switch (_that) {
case ExplorerDirectoryNode():
return directory(_that);case ExplorerFileNode():
return file(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ExplorerDirectoryNode value)?  directory,TResult? Function( ExplorerFileNode value)?  file,}){
final _that = this;
switch (_that) {
case ExplorerDirectoryNode() when directory != null:
return directory(_that);case ExplorerFileNode() when file != null:
return file(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String path,  String name,  List<String> skillNames)?  directory,TResult Function( String path,  String name)?  file,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ExplorerDirectoryNode() when directory != null:
return directory(_that.path,_that.name,_that.skillNames);case ExplorerFileNode() when file != null:
return file(_that.path,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String path,  String name,  List<String> skillNames)  directory,required TResult Function( String path,  String name)  file,}) {final _that = this;
switch (_that) {
case ExplorerDirectoryNode():
return directory(_that.path,_that.name,_that.skillNames);case ExplorerFileNode():
return file(_that.path,_that.name);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String path,  String name,  List<String> skillNames)?  directory,TResult? Function( String path,  String name)?  file,}) {final _that = this;
switch (_that) {
case ExplorerDirectoryNode() when directory != null:
return directory(_that.path,_that.name,_that.skillNames);case ExplorerFileNode() when file != null:
return file(_that.path,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class ExplorerDirectoryNode implements ExplorerNode {
  const ExplorerDirectoryNode({required this.path, required this.name, final  List<String> skillNames = const <String>[]}): _skillNames = skillNames;
  

@override final  String path;
@override final  String name;
 final  List<String> _skillNames;
@JsonKey() List<String> get skillNames {
  if (_skillNames is EqualUnmodifiableListView) return _skillNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skillNames);
}


/// Create a copy of ExplorerNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerDirectoryNodeCopyWith<ExplorerDirectoryNode> get copyWith => _$ExplorerDirectoryNodeCopyWithImpl<ExplorerDirectoryNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerDirectoryNode&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._skillNames, _skillNames));
}


@override
int get hashCode => Object.hash(runtimeType,path,name,const DeepCollectionEquality().hash(_skillNames));

@override
String toString() {
  return 'ExplorerNode.directory(path: $path, name: $name, skillNames: $skillNames)';
}


}

/// @nodoc
abstract mixin class $ExplorerDirectoryNodeCopyWith<$Res> implements $ExplorerNodeCopyWith<$Res> {
  factory $ExplorerDirectoryNodeCopyWith(ExplorerDirectoryNode value, $Res Function(ExplorerDirectoryNode) _then) = _$ExplorerDirectoryNodeCopyWithImpl;
@override @useResult
$Res call({
 String path, String name, List<String> skillNames
});




}
/// @nodoc
class _$ExplorerDirectoryNodeCopyWithImpl<$Res>
    implements $ExplorerDirectoryNodeCopyWith<$Res> {
  _$ExplorerDirectoryNodeCopyWithImpl(this._self, this._then);

  final ExplorerDirectoryNode _self;
  final $Res Function(ExplorerDirectoryNode) _then;

/// Create a copy of ExplorerNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? name = null,Object? skillNames = null,}) {
  return _then(ExplorerDirectoryNode(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,skillNames: null == skillNames ? _self._skillNames : skillNames // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ExplorerFileNode implements ExplorerNode {
  const ExplorerFileNode({required this.path, required this.name});
  

@override final  String path;
@override final  String name;

/// Create a copy of ExplorerNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerFileNodeCopyWith<ExplorerFileNode> get copyWith => _$ExplorerFileNodeCopyWithImpl<ExplorerFileNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerFileNode&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,path,name);

@override
String toString() {
  return 'ExplorerNode.file(path: $path, name: $name)';
}


}

/// @nodoc
abstract mixin class $ExplorerFileNodeCopyWith<$Res> implements $ExplorerNodeCopyWith<$Res> {
  factory $ExplorerFileNodeCopyWith(ExplorerFileNode value, $Res Function(ExplorerFileNode) _then) = _$ExplorerFileNodeCopyWithImpl;
@override @useResult
$Res call({
 String path, String name
});




}
/// @nodoc
class _$ExplorerFileNodeCopyWithImpl<$Res>
    implements $ExplorerFileNodeCopyWith<$Res> {
  _$ExplorerFileNodeCopyWithImpl(this._self, this._then);

  final ExplorerFileNode _self;
  final $Res Function(ExplorerFileNode) _then;

/// Create a copy of ExplorerNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? name = null,}) {
  return _then(ExplorerFileNode(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
