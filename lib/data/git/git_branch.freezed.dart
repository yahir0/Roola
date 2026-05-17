// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_branch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitBranch {

/// short 名。ローカルは `main`、リモートは `origin/main`。
 String get name;/// リモート追跡ブランチか。
 bool get isRemote;/// 現在チェックアウト中のブランチか。
 bool get isCurrent;/// upstream の short 名。未設定なら `null`。
 String? get upstream;/// upstream に対して先行しているコミット数。
 int get ahead;/// upstream に対して遅れているコミット数。
 int get behind;
/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitBranchCopyWith<GitBranch> get copyWith => _$GitBranchCopyWithImpl<GitBranch>(this as GitBranch, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitBranch&&(identical(other.name, name) || other.name == name)&&(identical(other.isRemote, isRemote) || other.isRemote == isRemote)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.upstream, upstream) || other.upstream == upstream)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind));
}


@override
int get hashCode => Object.hash(runtimeType,name,isRemote,isCurrent,upstream,ahead,behind);

@override
String toString() {
  return 'GitBranch(name: $name, isRemote: $isRemote, isCurrent: $isCurrent, upstream: $upstream, ahead: $ahead, behind: $behind)';
}


}

/// @nodoc
abstract mixin class $GitBranchCopyWith<$Res>  {
  factory $GitBranchCopyWith(GitBranch value, $Res Function(GitBranch) _then) = _$GitBranchCopyWithImpl;
@useResult
$Res call({
 String name, bool isRemote, bool isCurrent, String? upstream, int ahead, int behind
});




}
/// @nodoc
class _$GitBranchCopyWithImpl<$Res>
    implements $GitBranchCopyWith<$Res> {
  _$GitBranchCopyWithImpl(this._self, this._then);

  final GitBranch _self;
  final $Res Function(GitBranch) _then;

/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? isRemote = null,Object? isCurrent = null,Object? upstream = freezed,Object? ahead = null,Object? behind = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isRemote: null == isRemote ? _self.isRemote : isRemote // ignore: cast_nullable_to_non_nullable
as bool,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,upstream: freezed == upstream ? _self.upstream : upstream // ignore: cast_nullable_to_non_nullable
as String?,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GitBranch].
extension GitBranchPatterns on GitBranch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitBranch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitBranch value)  $default,){
final _that = this;
switch (_that) {
case _GitBranch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitBranch value)?  $default,){
final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  bool isRemote,  bool isCurrent,  String? upstream,  int ahead,  int behind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
return $default(_that.name,_that.isRemote,_that.isCurrent,_that.upstream,_that.ahead,_that.behind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  bool isRemote,  bool isCurrent,  String? upstream,  int ahead,  int behind)  $default,) {final _that = this;
switch (_that) {
case _GitBranch():
return $default(_that.name,_that.isRemote,_that.isCurrent,_that.upstream,_that.ahead,_that.behind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  bool isRemote,  bool isCurrent,  String? upstream,  int ahead,  int behind)?  $default,) {final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
return $default(_that.name,_that.isRemote,_that.isCurrent,_that.upstream,_that.ahead,_that.behind);case _:
  return null;

}
}

}

/// @nodoc


class _GitBranch implements GitBranch {
  const _GitBranch({required this.name, required this.isRemote, required this.isCurrent, this.upstream, this.ahead = 0, this.behind = 0});
  

/// short 名。ローカルは `main`、リモートは `origin/main`。
@override final  String name;
/// リモート追跡ブランチか。
@override final  bool isRemote;
/// 現在チェックアウト中のブランチか。
@override final  bool isCurrent;
/// upstream の short 名。未設定なら `null`。
@override final  String? upstream;
/// upstream に対して先行しているコミット数。
@override@JsonKey() final  int ahead;
/// upstream に対して遅れているコミット数。
@override@JsonKey() final  int behind;

/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitBranchCopyWith<_GitBranch> get copyWith => __$GitBranchCopyWithImpl<_GitBranch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitBranch&&(identical(other.name, name) || other.name == name)&&(identical(other.isRemote, isRemote) || other.isRemote == isRemote)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.upstream, upstream) || other.upstream == upstream)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind));
}


@override
int get hashCode => Object.hash(runtimeType,name,isRemote,isCurrent,upstream,ahead,behind);

@override
String toString() {
  return 'GitBranch(name: $name, isRemote: $isRemote, isCurrent: $isCurrent, upstream: $upstream, ahead: $ahead, behind: $behind)';
}


}

/// @nodoc
abstract mixin class _$GitBranchCopyWith<$Res> implements $GitBranchCopyWith<$Res> {
  factory _$GitBranchCopyWith(_GitBranch value, $Res Function(_GitBranch) _then) = __$GitBranchCopyWithImpl;
@override @useResult
$Res call({
 String name, bool isRemote, bool isCurrent, String? upstream, int ahead, int behind
});




}
/// @nodoc
class __$GitBranchCopyWithImpl<$Res>
    implements _$GitBranchCopyWith<$Res> {
  __$GitBranchCopyWithImpl(this._self, this._then);

  final _GitBranch _self;
  final $Res Function(_GitBranch) _then;

/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? isRemote = null,Object? isCurrent = null,Object? upstream = freezed,Object? ahead = null,Object? behind = null,}) {
  return _then(_GitBranch(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isRemote: null == isRemote ? _self.isRemote : isRemote // ignore: cast_nullable_to_non_nullable
as bool,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,upstream: freezed == upstream ? _self.upstream : upstream // ignore: cast_nullable_to_non_nullable
as String?,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
