// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_tab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceTab {

 String get id;
/// Create a copy of WorkspaceTab
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceTabCopyWith<WorkspaceTab> get copyWith => _$WorkspaceTabCopyWithImpl<WorkspaceTab>(this as WorkspaceTab, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceTab&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'WorkspaceTab(id: $id)';
}


}

/// @nodoc
abstract mixin class $WorkspaceTabCopyWith<$Res>  {
  factory $WorkspaceTabCopyWith(WorkspaceTab value, $Res Function(WorkspaceTab) _then) = _$WorkspaceTabCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$WorkspaceTabCopyWithImpl<$Res>
    implements $WorkspaceTabCopyWith<$Res> {
  _$WorkspaceTabCopyWithImpl(this._self, this._then);

  final WorkspaceTab _self;
  final $Res Function(WorkspaceTab) _then;

/// Create a copy of WorkspaceTab
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceTab].
extension WorkspaceTabPatterns on WorkspaceTab {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ExplorerTab value)?  explorer,TResult Function( TerminalTab value)?  terminal,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ExplorerTab() when explorer != null:
return explorer(_that);case TerminalTab() when terminal != null:
return terminal(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ExplorerTab value)  explorer,required TResult Function( TerminalTab value)  terminal,}){
final _that = this;
switch (_that) {
case ExplorerTab():
return explorer(_that);case TerminalTab():
return terminal(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ExplorerTab value)?  explorer,TResult? Function( TerminalTab value)?  terminal,}){
final _that = this;
switch (_that) {
case ExplorerTab() when explorer != null:
return explorer(_that);case TerminalTab() when terminal != null:
return terminal(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String currentPath)?  explorer,TResult Function( String id,  AdhocRunArgs args)?  terminal,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ExplorerTab() when explorer != null:
return explorer(_that.id,_that.currentPath);case TerminalTab() when terminal != null:
return terminal(_that.id,_that.args);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String currentPath)  explorer,required TResult Function( String id,  AdhocRunArgs args)  terminal,}) {final _that = this;
switch (_that) {
case ExplorerTab():
return explorer(_that.id,_that.currentPath);case TerminalTab():
return terminal(_that.id,_that.args);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String currentPath)?  explorer,TResult? Function( String id,  AdhocRunArgs args)?  terminal,}) {final _that = this;
switch (_that) {
case ExplorerTab() when explorer != null:
return explorer(_that.id,_that.currentPath);case TerminalTab() when terminal != null:
return terminal(_that.id,_that.args);case _:
  return null;

}
}

}

/// @nodoc


class ExplorerTab implements WorkspaceTab {
  const ExplorerTab({required this.id, required this.currentPath});
  

@override final  String id;
 final  String currentPath;

/// Create a copy of WorkspaceTab
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerTabCopyWith<ExplorerTab> get copyWith => _$ExplorerTabCopyWithImpl<ExplorerTab>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerTab&&(identical(other.id, id) || other.id == id)&&(identical(other.currentPath, currentPath) || other.currentPath == currentPath));
}


@override
int get hashCode => Object.hash(runtimeType,id,currentPath);

@override
String toString() {
  return 'WorkspaceTab.explorer(id: $id, currentPath: $currentPath)';
}


}

/// @nodoc
abstract mixin class $ExplorerTabCopyWith<$Res> implements $WorkspaceTabCopyWith<$Res> {
  factory $ExplorerTabCopyWith(ExplorerTab value, $Res Function(ExplorerTab) _then) = _$ExplorerTabCopyWithImpl;
@override @useResult
$Res call({
 String id, String currentPath
});




}
/// @nodoc
class _$ExplorerTabCopyWithImpl<$Res>
    implements $ExplorerTabCopyWith<$Res> {
  _$ExplorerTabCopyWithImpl(this._self, this._then);

  final ExplorerTab _self;
  final $Res Function(ExplorerTab) _then;

/// Create a copy of WorkspaceTab
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? currentPath = null,}) {
  return _then(ExplorerTab(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,currentPath: null == currentPath ? _self.currentPath : currentPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TerminalTab implements WorkspaceTab {
  const TerminalTab({required this.id, required this.args});
  

@override final  String id;
 final  AdhocRunArgs args;

/// Create a copy of WorkspaceTab
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerminalTabCopyWith<TerminalTab> get copyWith => _$TerminalTabCopyWithImpl<TerminalTab>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalTab&&(identical(other.id, id) || other.id == id)&&(identical(other.args, args) || other.args == args));
}


@override
int get hashCode => Object.hash(runtimeType,id,args);

@override
String toString() {
  return 'WorkspaceTab.terminal(id: $id, args: $args)';
}


}

/// @nodoc
abstract mixin class $TerminalTabCopyWith<$Res> implements $WorkspaceTabCopyWith<$Res> {
  factory $TerminalTabCopyWith(TerminalTab value, $Res Function(TerminalTab) _then) = _$TerminalTabCopyWithImpl;
@override @useResult
$Res call({
 String id, AdhocRunArgs args
});


$AdhocRunArgsCopyWith<$Res> get args;

}
/// @nodoc
class _$TerminalTabCopyWithImpl<$Res>
    implements $TerminalTabCopyWith<$Res> {
  _$TerminalTabCopyWithImpl(this._self, this._then);

  final TerminalTab _self;
  final $Res Function(TerminalTab) _then;

/// Create a copy of WorkspaceTab
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? args = null,}) {
  return _then(TerminalTab(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as AdhocRunArgs,
  ));
}

/// Create a copy of WorkspaceTab
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
