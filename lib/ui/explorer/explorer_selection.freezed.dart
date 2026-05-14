// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explorer_selection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExplorerSelection {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ExplorerSelection()';
}


}

/// @nodoc
class $ExplorerSelectionCopyWith<$Res>  {
$ExplorerSelectionCopyWith(ExplorerSelection _, $Res Function(ExplorerSelection) __);
}


/// Adds pattern-matching-related methods to [ExplorerSelection].
extension ExplorerSelectionPatterns on ExplorerSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ExplorerSelectionDirectory value)?  directory,TResult Function( ExplorerSelectionEntrySession value)?  entrySession,TResult Function( ExplorerSelectionAdhocSession value)?  adhocSession,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ExplorerSelectionDirectory() when directory != null:
return directory(_that);case ExplorerSelectionEntrySession() when entrySession != null:
return entrySession(_that);case ExplorerSelectionAdhocSession() when adhocSession != null:
return adhocSession(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ExplorerSelectionDirectory value)  directory,required TResult Function( ExplorerSelectionEntrySession value)  entrySession,required TResult Function( ExplorerSelectionAdhocSession value)  adhocSession,}){
final _that = this;
switch (_that) {
case ExplorerSelectionDirectory():
return directory(_that);case ExplorerSelectionEntrySession():
return entrySession(_that);case ExplorerSelectionAdhocSession():
return adhocSession(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ExplorerSelectionDirectory value)?  directory,TResult? Function( ExplorerSelectionEntrySession value)?  entrySession,TResult? Function( ExplorerSelectionAdhocSession value)?  adhocSession,}){
final _that = this;
switch (_that) {
case ExplorerSelectionDirectory() when directory != null:
return directory(_that);case ExplorerSelectionEntrySession() when entrySession != null:
return entrySession(_that);case ExplorerSelectionAdhocSession() when adhocSession != null:
return adhocSession(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String path)?  directory,TResult Function( String entryId)?  entrySession,TResult Function( AdhocRunArgs args)?  adhocSession,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ExplorerSelectionDirectory() when directory != null:
return directory(_that.path);case ExplorerSelectionEntrySession() when entrySession != null:
return entrySession(_that.entryId);case ExplorerSelectionAdhocSession() when adhocSession != null:
return adhocSession(_that.args);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String path)  directory,required TResult Function( String entryId)  entrySession,required TResult Function( AdhocRunArgs args)  adhocSession,}) {final _that = this;
switch (_that) {
case ExplorerSelectionDirectory():
return directory(_that.path);case ExplorerSelectionEntrySession():
return entrySession(_that.entryId);case ExplorerSelectionAdhocSession():
return adhocSession(_that.args);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String path)?  directory,TResult? Function( String entryId)?  entrySession,TResult? Function( AdhocRunArgs args)?  adhocSession,}) {final _that = this;
switch (_that) {
case ExplorerSelectionDirectory() when directory != null:
return directory(_that.path);case ExplorerSelectionEntrySession() when entrySession != null:
return entrySession(_that.entryId);case ExplorerSelectionAdhocSession() when adhocSession != null:
return adhocSession(_that.args);case _:
  return null;

}
}

}

/// @nodoc


class ExplorerSelectionDirectory implements ExplorerSelection {
  const ExplorerSelectionDirectory(this.path);
  

 final  String path;

/// Create a copy of ExplorerSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerSelectionDirectoryCopyWith<ExplorerSelectionDirectory> get copyWith => _$ExplorerSelectionDirectoryCopyWithImpl<ExplorerSelectionDirectory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerSelectionDirectory&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'ExplorerSelection.directory(path: $path)';
}


}

/// @nodoc
abstract mixin class $ExplorerSelectionDirectoryCopyWith<$Res> implements $ExplorerSelectionCopyWith<$Res> {
  factory $ExplorerSelectionDirectoryCopyWith(ExplorerSelectionDirectory value, $Res Function(ExplorerSelectionDirectory) _then) = _$ExplorerSelectionDirectoryCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$ExplorerSelectionDirectoryCopyWithImpl<$Res>
    implements $ExplorerSelectionDirectoryCopyWith<$Res> {
  _$ExplorerSelectionDirectoryCopyWithImpl(this._self, this._then);

  final ExplorerSelectionDirectory _self;
  final $Res Function(ExplorerSelectionDirectory) _then;

/// Create a copy of ExplorerSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(ExplorerSelectionDirectory(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ExplorerSelectionEntrySession implements ExplorerSelection {
  const ExplorerSelectionEntrySession(this.entryId);
  

 final  String entryId;

/// Create a copy of ExplorerSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerSelectionEntrySessionCopyWith<ExplorerSelectionEntrySession> get copyWith => _$ExplorerSelectionEntrySessionCopyWithImpl<ExplorerSelectionEntrySession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerSelectionEntrySession&&(identical(other.entryId, entryId) || other.entryId == entryId));
}


@override
int get hashCode => Object.hash(runtimeType,entryId);

@override
String toString() {
  return 'ExplorerSelection.entrySession(entryId: $entryId)';
}


}

/// @nodoc
abstract mixin class $ExplorerSelectionEntrySessionCopyWith<$Res> implements $ExplorerSelectionCopyWith<$Res> {
  factory $ExplorerSelectionEntrySessionCopyWith(ExplorerSelectionEntrySession value, $Res Function(ExplorerSelectionEntrySession) _then) = _$ExplorerSelectionEntrySessionCopyWithImpl;
@useResult
$Res call({
 String entryId
});




}
/// @nodoc
class _$ExplorerSelectionEntrySessionCopyWithImpl<$Res>
    implements $ExplorerSelectionEntrySessionCopyWith<$Res> {
  _$ExplorerSelectionEntrySessionCopyWithImpl(this._self, this._then);

  final ExplorerSelectionEntrySession _self;
  final $Res Function(ExplorerSelectionEntrySession) _then;

/// Create a copy of ExplorerSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entryId = null,}) {
  return _then(ExplorerSelectionEntrySession(
null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ExplorerSelectionAdhocSession implements ExplorerSelection {
  const ExplorerSelectionAdhocSession(this.args);
  

 final  AdhocRunArgs args;

/// Create a copy of ExplorerSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerSelectionAdhocSessionCopyWith<ExplorerSelectionAdhocSession> get copyWith => _$ExplorerSelectionAdhocSessionCopyWithImpl<ExplorerSelectionAdhocSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerSelectionAdhocSession&&(identical(other.args, args) || other.args == args));
}


@override
int get hashCode => Object.hash(runtimeType,args);

@override
String toString() {
  return 'ExplorerSelection.adhocSession(args: $args)';
}


}

/// @nodoc
abstract mixin class $ExplorerSelectionAdhocSessionCopyWith<$Res> implements $ExplorerSelectionCopyWith<$Res> {
  factory $ExplorerSelectionAdhocSessionCopyWith(ExplorerSelectionAdhocSession value, $Res Function(ExplorerSelectionAdhocSession) _then) = _$ExplorerSelectionAdhocSessionCopyWithImpl;
@useResult
$Res call({
 AdhocRunArgs args
});


$AdhocRunArgsCopyWith<$Res> get args;

}
/// @nodoc
class _$ExplorerSelectionAdhocSessionCopyWithImpl<$Res>
    implements $ExplorerSelectionAdhocSessionCopyWith<$Res> {
  _$ExplorerSelectionAdhocSessionCopyWithImpl(this._self, this._then);

  final ExplorerSelectionAdhocSession _self;
  final $Res Function(ExplorerSelectionAdhocSession) _then;

/// Create a copy of ExplorerSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? args = null,}) {
  return _then(ExplorerSelectionAdhocSession(
null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as AdhocRunArgs,
  ));
}

/// Create a copy of ExplorerSelection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdhocRunArgsCopyWith<$Res> get args {
  
  return $AdhocRunArgsCopyWith<$Res>(_self.args, (value) {
    return _then(_self.copyWith(args: value));
  });
}
}

// dart format on
