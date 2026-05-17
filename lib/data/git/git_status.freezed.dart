// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitFileChange {

/// リポジトリルートからの相対パス。
 String get path;/// 変更種別。
 GitChangeType get type;/// index に載っている（staged）か、作業ツリー上の変更（unstaged）か。
 bool get staged;/// リネーム / コピー元のパス。それ以外では `null`。
 String? get originalPath;
/// Create a copy of GitFileChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitFileChangeCopyWith<GitFileChange> get copyWith => _$GitFileChangeCopyWithImpl<GitFileChange>(this as GitFileChange, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitFileChange&&(identical(other.path, path) || other.path == path)&&(identical(other.type, type) || other.type == type)&&(identical(other.staged, staged) || other.staged == staged)&&(identical(other.originalPath, originalPath) || other.originalPath == originalPath));
}


@override
int get hashCode => Object.hash(runtimeType,path,type,staged,originalPath);

@override
String toString() {
  return 'GitFileChange(path: $path, type: $type, staged: $staged, originalPath: $originalPath)';
}


}

/// @nodoc
abstract mixin class $GitFileChangeCopyWith<$Res>  {
  factory $GitFileChangeCopyWith(GitFileChange value, $Res Function(GitFileChange) _then) = _$GitFileChangeCopyWithImpl;
@useResult
$Res call({
 String path, GitChangeType type, bool staged, String? originalPath
});




}
/// @nodoc
class _$GitFileChangeCopyWithImpl<$Res>
    implements $GitFileChangeCopyWith<$Res> {
  _$GitFileChangeCopyWithImpl(this._self, this._then);

  final GitFileChange _self;
  final $Res Function(GitFileChange) _then;

/// Create a copy of GitFileChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? type = null,Object? staged = null,Object? originalPath = freezed,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GitChangeType,staged: null == staged ? _self.staged : staged // ignore: cast_nullable_to_non_nullable
as bool,originalPath: freezed == originalPath ? _self.originalPath : originalPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GitFileChange].
extension GitFileChangePatterns on GitFileChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitFileChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitFileChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitFileChange value)  $default,){
final _that = this;
switch (_that) {
case _GitFileChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitFileChange value)?  $default,){
final _that = this;
switch (_that) {
case _GitFileChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  GitChangeType type,  bool staged,  String? originalPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitFileChange() when $default != null:
return $default(_that.path,_that.type,_that.staged,_that.originalPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  GitChangeType type,  bool staged,  String? originalPath)  $default,) {final _that = this;
switch (_that) {
case _GitFileChange():
return $default(_that.path,_that.type,_that.staged,_that.originalPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  GitChangeType type,  bool staged,  String? originalPath)?  $default,) {final _that = this;
switch (_that) {
case _GitFileChange() when $default != null:
return $default(_that.path,_that.type,_that.staged,_that.originalPath);case _:
  return null;

}
}

}

/// @nodoc


class _GitFileChange extends GitFileChange {
  const _GitFileChange({required this.path, required this.type, required this.staged, this.originalPath}): super._();
  

/// リポジトリルートからの相対パス。
@override final  String path;
/// 変更種別。
@override final  GitChangeType type;
/// index に載っている（staged）か、作業ツリー上の変更（unstaged）か。
@override final  bool staged;
/// リネーム / コピー元のパス。それ以外では `null`。
@override final  String? originalPath;

/// Create a copy of GitFileChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitFileChangeCopyWith<_GitFileChange> get copyWith => __$GitFileChangeCopyWithImpl<_GitFileChange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitFileChange&&(identical(other.path, path) || other.path == path)&&(identical(other.type, type) || other.type == type)&&(identical(other.staged, staged) || other.staged == staged)&&(identical(other.originalPath, originalPath) || other.originalPath == originalPath));
}


@override
int get hashCode => Object.hash(runtimeType,path,type,staged,originalPath);

@override
String toString() {
  return 'GitFileChange(path: $path, type: $type, staged: $staged, originalPath: $originalPath)';
}


}

/// @nodoc
abstract mixin class _$GitFileChangeCopyWith<$Res> implements $GitFileChangeCopyWith<$Res> {
  factory _$GitFileChangeCopyWith(_GitFileChange value, $Res Function(_GitFileChange) _then) = __$GitFileChangeCopyWithImpl;
@override @useResult
$Res call({
 String path, GitChangeType type, bool staged, String? originalPath
});




}
/// @nodoc
class __$GitFileChangeCopyWithImpl<$Res>
    implements _$GitFileChangeCopyWith<$Res> {
  __$GitFileChangeCopyWithImpl(this._self, this._then);

  final _GitFileChange _self;
  final $Res Function(_GitFileChange) _then;

/// Create a copy of GitFileChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? type = null,Object? staged = null,Object? originalPath = freezed,}) {
  return _then(_GitFileChange(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GitChangeType,staged: null == staged ? _self.staged : staged // ignore: cast_nullable_to_non_nullable
as bool,originalPath: freezed == originalPath ? _self.originalPath : originalPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$GitStatus {

/// 現在のブランチ名。detached HEAD では `null`。
 String? get branch;/// upstream の short 名（例 `origin/main`）。未設定なら `null`。
 String? get upstream;/// upstream に対して先行しているコミット数。
 int get ahead;/// upstream に対して遅れているコミット数。
 int get behind;/// index に載っている変更（staged）。
 List<GitFileChange> get staged;/// 作業ツリー上の変更（unstaged、未追跡を含む）。
 List<GitFileChange> get unstaged;
/// Create a copy of GitStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitStatusCopyWith<GitStatus> get copyWith => _$GitStatusCopyWithImpl<GitStatus>(this as GitStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitStatus&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.upstream, upstream) || other.upstream == upstream)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind)&&const DeepCollectionEquality().equals(other.staged, staged)&&const DeepCollectionEquality().equals(other.unstaged, unstaged));
}


@override
int get hashCode => Object.hash(runtimeType,branch,upstream,ahead,behind,const DeepCollectionEquality().hash(staged),const DeepCollectionEquality().hash(unstaged));

@override
String toString() {
  return 'GitStatus(branch: $branch, upstream: $upstream, ahead: $ahead, behind: $behind, staged: $staged, unstaged: $unstaged)';
}


}

/// @nodoc
abstract mixin class $GitStatusCopyWith<$Res>  {
  factory $GitStatusCopyWith(GitStatus value, $Res Function(GitStatus) _then) = _$GitStatusCopyWithImpl;
@useResult
$Res call({
 String? branch, String? upstream, int ahead, int behind, List<GitFileChange> staged, List<GitFileChange> unstaged
});




}
/// @nodoc
class _$GitStatusCopyWithImpl<$Res>
    implements $GitStatusCopyWith<$Res> {
  _$GitStatusCopyWithImpl(this._self, this._then);

  final GitStatus _self;
  final $Res Function(GitStatus) _then;

/// Create a copy of GitStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branch = freezed,Object? upstream = freezed,Object? ahead = null,Object? behind = null,Object? staged = null,Object? unstaged = null,}) {
  return _then(_self.copyWith(
branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,upstream: freezed == upstream ? _self.upstream : upstream // ignore: cast_nullable_to_non_nullable
as String?,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,staged: null == staged ? _self.staged : staged // ignore: cast_nullable_to_non_nullable
as List<GitFileChange>,unstaged: null == unstaged ? _self.unstaged : unstaged // ignore: cast_nullable_to_non_nullable
as List<GitFileChange>,
  ));
}

}


/// Adds pattern-matching-related methods to [GitStatus].
extension GitStatusPatterns on GitStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitStatus value)  $default,){
final _that = this;
switch (_that) {
case _GitStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitStatus value)?  $default,){
final _that = this;
switch (_that) {
case _GitStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? branch,  String? upstream,  int ahead,  int behind,  List<GitFileChange> staged,  List<GitFileChange> unstaged)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitStatus() when $default != null:
return $default(_that.branch,_that.upstream,_that.ahead,_that.behind,_that.staged,_that.unstaged);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? branch,  String? upstream,  int ahead,  int behind,  List<GitFileChange> staged,  List<GitFileChange> unstaged)  $default,) {final _that = this;
switch (_that) {
case _GitStatus():
return $default(_that.branch,_that.upstream,_that.ahead,_that.behind,_that.staged,_that.unstaged);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? branch,  String? upstream,  int ahead,  int behind,  List<GitFileChange> staged,  List<GitFileChange> unstaged)?  $default,) {final _that = this;
switch (_that) {
case _GitStatus() when $default != null:
return $default(_that.branch,_that.upstream,_that.ahead,_that.behind,_that.staged,_that.unstaged);case _:
  return null;

}
}

}

/// @nodoc


class _GitStatus extends GitStatus {
  const _GitStatus({this.branch, this.upstream, this.ahead = 0, this.behind = 0, final  List<GitFileChange> staged = const <GitFileChange>[], final  List<GitFileChange> unstaged = const <GitFileChange>[]}): _staged = staged,_unstaged = unstaged,super._();
  

/// 現在のブランチ名。detached HEAD では `null`。
@override final  String? branch;
/// upstream の short 名（例 `origin/main`）。未設定なら `null`。
@override final  String? upstream;
/// upstream に対して先行しているコミット数。
@override@JsonKey() final  int ahead;
/// upstream に対して遅れているコミット数。
@override@JsonKey() final  int behind;
/// index に載っている変更（staged）。
 final  List<GitFileChange> _staged;
/// index に載っている変更（staged）。
@override@JsonKey() List<GitFileChange> get staged {
  if (_staged is EqualUnmodifiableListView) return _staged;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_staged);
}

/// 作業ツリー上の変更（unstaged、未追跡を含む）。
 final  List<GitFileChange> _unstaged;
/// 作業ツリー上の変更（unstaged、未追跡を含む）。
@override@JsonKey() List<GitFileChange> get unstaged {
  if (_unstaged is EqualUnmodifiableListView) return _unstaged;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unstaged);
}


/// Create a copy of GitStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitStatusCopyWith<_GitStatus> get copyWith => __$GitStatusCopyWithImpl<_GitStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitStatus&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.upstream, upstream) || other.upstream == upstream)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind)&&const DeepCollectionEquality().equals(other._staged, _staged)&&const DeepCollectionEquality().equals(other._unstaged, _unstaged));
}


@override
int get hashCode => Object.hash(runtimeType,branch,upstream,ahead,behind,const DeepCollectionEquality().hash(_staged),const DeepCollectionEquality().hash(_unstaged));

@override
String toString() {
  return 'GitStatus(branch: $branch, upstream: $upstream, ahead: $ahead, behind: $behind, staged: $staged, unstaged: $unstaged)';
}


}

/// @nodoc
abstract mixin class _$GitStatusCopyWith<$Res> implements $GitStatusCopyWith<$Res> {
  factory _$GitStatusCopyWith(_GitStatus value, $Res Function(_GitStatus) _then) = __$GitStatusCopyWithImpl;
@override @useResult
$Res call({
 String? branch, String? upstream, int ahead, int behind, List<GitFileChange> staged, List<GitFileChange> unstaged
});




}
/// @nodoc
class __$GitStatusCopyWithImpl<$Res>
    implements _$GitStatusCopyWith<$Res> {
  __$GitStatusCopyWithImpl(this._self, this._then);

  final _GitStatus _self;
  final $Res Function(_GitStatus) _then;

/// Create a copy of GitStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branch = freezed,Object? upstream = freezed,Object? ahead = null,Object? behind = null,Object? staged = null,Object? unstaged = null,}) {
  return _then(_GitStatus(
branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,upstream: freezed == upstream ? _self.upstream : upstream // ignore: cast_nullable_to_non_nullable
as String?,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,staged: null == staged ? _self._staged : staged // ignore: cast_nullable_to_non_nullable
as List<GitFileChange>,unstaged: null == unstaged ? _self._unstaged : unstaged // ignore: cast_nullable_to_non_nullable
as List<GitFileChange>,
  ));
}


}

// dart format on
