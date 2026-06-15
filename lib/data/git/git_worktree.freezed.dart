// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_worktree.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitWorktree {

/// worktree のルート絶対パス。
 String get path;/// チェックアウト中のブランチ short 名。detached HEAD なら `null`。
 String? get branch;/// HEAD のコミット SHA。
 String get head;/// 本体（main worktree）か。
 bool get isMain;/// フォルダが直接削除される等で管理情報だけ残った孤児か
/// （`git worktree prune` の対象）。
 bool get isPrunable;/// ロック済みか（`git worktree lock`）。
 bool get isLocked;
/// Create a copy of GitWorktree
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitWorktreeCopyWith<GitWorktree> get copyWith => _$GitWorktreeCopyWithImpl<GitWorktree>(this as GitWorktree, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitWorktree&&(identical(other.path, path) || other.path == path)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.head, head) || other.head == head)&&(identical(other.isMain, isMain) || other.isMain == isMain)&&(identical(other.isPrunable, isPrunable) || other.isPrunable == isPrunable)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked));
}


@override
int get hashCode => Object.hash(runtimeType,path,branch,head,isMain,isPrunable,isLocked);

@override
String toString() {
  return 'GitWorktree(path: $path, branch: $branch, head: $head, isMain: $isMain, isPrunable: $isPrunable, isLocked: $isLocked)';
}


}

/// @nodoc
abstract mixin class $GitWorktreeCopyWith<$Res>  {
  factory $GitWorktreeCopyWith(GitWorktree value, $Res Function(GitWorktree) _then) = _$GitWorktreeCopyWithImpl;
@useResult
$Res call({
 String path, String? branch, String head, bool isMain, bool isPrunable, bool isLocked
});




}
/// @nodoc
class _$GitWorktreeCopyWithImpl<$Res>
    implements $GitWorktreeCopyWith<$Res> {
  _$GitWorktreeCopyWithImpl(this._self, this._then);

  final GitWorktree _self;
  final $Res Function(GitWorktree) _then;

/// Create a copy of GitWorktree
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? branch = freezed,Object? head = null,Object? isMain = null,Object? isPrunable = null,Object? isLocked = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,head: null == head ? _self.head : head // ignore: cast_nullable_to_non_nullable
as String,isMain: null == isMain ? _self.isMain : isMain // ignore: cast_nullable_to_non_nullable
as bool,isPrunable: null == isPrunable ? _self.isPrunable : isPrunable // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GitWorktree].
extension GitWorktreePatterns on GitWorktree {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitWorktree value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitWorktree() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitWorktree value)  $default,){
final _that = this;
switch (_that) {
case _GitWorktree():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitWorktree value)?  $default,){
final _that = this;
switch (_that) {
case _GitWorktree() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String? branch,  String head,  bool isMain,  bool isPrunable,  bool isLocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitWorktree() when $default != null:
return $default(_that.path,_that.branch,_that.head,_that.isMain,_that.isPrunable,_that.isLocked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String? branch,  String head,  bool isMain,  bool isPrunable,  bool isLocked)  $default,) {final _that = this;
switch (_that) {
case _GitWorktree():
return $default(_that.path,_that.branch,_that.head,_that.isMain,_that.isPrunable,_that.isLocked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String? branch,  String head,  bool isMain,  bool isPrunable,  bool isLocked)?  $default,) {final _that = this;
switch (_that) {
case _GitWorktree() when $default != null:
return $default(_that.path,_that.branch,_that.head,_that.isMain,_that.isPrunable,_that.isLocked);case _:
  return null;

}
}

}

/// @nodoc


class _GitWorktree implements GitWorktree {
  const _GitWorktree({required this.path, this.branch, required this.head, required this.isMain, this.isPrunable = false, this.isLocked = false});
  

/// worktree のルート絶対パス。
@override final  String path;
/// チェックアウト中のブランチ short 名。detached HEAD なら `null`。
@override final  String? branch;
/// HEAD のコミット SHA。
@override final  String head;
/// 本体（main worktree）か。
@override final  bool isMain;
/// フォルダが直接削除される等で管理情報だけ残った孤児か
/// （`git worktree prune` の対象）。
@override@JsonKey() final  bool isPrunable;
/// ロック済みか（`git worktree lock`）。
@override@JsonKey() final  bool isLocked;

/// Create a copy of GitWorktree
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitWorktreeCopyWith<_GitWorktree> get copyWith => __$GitWorktreeCopyWithImpl<_GitWorktree>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitWorktree&&(identical(other.path, path) || other.path == path)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.head, head) || other.head == head)&&(identical(other.isMain, isMain) || other.isMain == isMain)&&(identical(other.isPrunable, isPrunable) || other.isPrunable == isPrunable)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked));
}


@override
int get hashCode => Object.hash(runtimeType,path,branch,head,isMain,isPrunable,isLocked);

@override
String toString() {
  return 'GitWorktree(path: $path, branch: $branch, head: $head, isMain: $isMain, isPrunable: $isPrunable, isLocked: $isLocked)';
}


}

/// @nodoc
abstract mixin class _$GitWorktreeCopyWith<$Res> implements $GitWorktreeCopyWith<$Res> {
  factory _$GitWorktreeCopyWith(_GitWorktree value, $Res Function(_GitWorktree) _then) = __$GitWorktreeCopyWithImpl;
@override @useResult
$Res call({
 String path, String? branch, String head, bool isMain, bool isPrunable, bool isLocked
});




}
/// @nodoc
class __$GitWorktreeCopyWithImpl<$Res>
    implements _$GitWorktreeCopyWith<$Res> {
  __$GitWorktreeCopyWithImpl(this._self, this._then);

  final _GitWorktree _self;
  final $Res Function(_GitWorktree) _then;

/// Create a copy of GitWorktree
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? branch = freezed,Object? head = null,Object? isMain = null,Object? isPrunable = null,Object? isLocked = null,}) {
  return _then(_GitWorktree(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,head: null == head ? _self.head : head // ignore: cast_nullable_to_non_nullable
as String,isMain: null == isMain ? _self.isMain : isMain // ignore: cast_nullable_to_non_nullable
as bool,isPrunable: null == isPrunable ? _self.isPrunable : isPrunable // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$WorktreeStatusSummary {

/// 未コミットの変更（staged / unstaged / 未追跡）があるか。
 bool get isDirty;/// upstream に対して先行しているコミット数。upstream 未設定なら 0。
 int get ahead;/// upstream に対して遅れているコミット数。upstream 未設定なら 0。
 int get behind;
/// Create a copy of WorktreeStatusSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorktreeStatusSummaryCopyWith<WorktreeStatusSummary> get copyWith => _$WorktreeStatusSummaryCopyWithImpl<WorktreeStatusSummary>(this as WorktreeStatusSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorktreeStatusSummary&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind));
}


@override
int get hashCode => Object.hash(runtimeType,isDirty,ahead,behind);

@override
String toString() {
  return 'WorktreeStatusSummary(isDirty: $isDirty, ahead: $ahead, behind: $behind)';
}


}

/// @nodoc
abstract mixin class $WorktreeStatusSummaryCopyWith<$Res>  {
  factory $WorktreeStatusSummaryCopyWith(WorktreeStatusSummary value, $Res Function(WorktreeStatusSummary) _then) = _$WorktreeStatusSummaryCopyWithImpl;
@useResult
$Res call({
 bool isDirty, int ahead, int behind
});




}
/// @nodoc
class _$WorktreeStatusSummaryCopyWithImpl<$Res>
    implements $WorktreeStatusSummaryCopyWith<$Res> {
  _$WorktreeStatusSummaryCopyWithImpl(this._self, this._then);

  final WorktreeStatusSummary _self;
  final $Res Function(WorktreeStatusSummary) _then;

/// Create a copy of WorktreeStatusSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isDirty = null,Object? ahead = null,Object? behind = null,}) {
  return _then(_self.copyWith(
isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WorktreeStatusSummary].
extension WorktreeStatusSummaryPatterns on WorktreeStatusSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorktreeStatusSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorktreeStatusSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorktreeStatusSummary value)  $default,){
final _that = this;
switch (_that) {
case _WorktreeStatusSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorktreeStatusSummary value)?  $default,){
final _that = this;
switch (_that) {
case _WorktreeStatusSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isDirty,  int ahead,  int behind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorktreeStatusSummary() when $default != null:
return $default(_that.isDirty,_that.ahead,_that.behind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isDirty,  int ahead,  int behind)  $default,) {final _that = this;
switch (_that) {
case _WorktreeStatusSummary():
return $default(_that.isDirty,_that.ahead,_that.behind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isDirty,  int ahead,  int behind)?  $default,) {final _that = this;
switch (_that) {
case _WorktreeStatusSummary() when $default != null:
return $default(_that.isDirty,_that.ahead,_that.behind);case _:
  return null;

}
}

}

/// @nodoc


class _WorktreeStatusSummary implements WorktreeStatusSummary {
  const _WorktreeStatusSummary({required this.isDirty, this.ahead = 0, this.behind = 0});
  

/// 未コミットの変更（staged / unstaged / 未追跡）があるか。
@override final  bool isDirty;
/// upstream に対して先行しているコミット数。upstream 未設定なら 0。
@override@JsonKey() final  int ahead;
/// upstream に対して遅れているコミット数。upstream 未設定なら 0。
@override@JsonKey() final  int behind;

/// Create a copy of WorktreeStatusSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorktreeStatusSummaryCopyWith<_WorktreeStatusSummary> get copyWith => __$WorktreeStatusSummaryCopyWithImpl<_WorktreeStatusSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorktreeStatusSummary&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind));
}


@override
int get hashCode => Object.hash(runtimeType,isDirty,ahead,behind);

@override
String toString() {
  return 'WorktreeStatusSummary(isDirty: $isDirty, ahead: $ahead, behind: $behind)';
}


}

/// @nodoc
abstract mixin class _$WorktreeStatusSummaryCopyWith<$Res> implements $WorktreeStatusSummaryCopyWith<$Res> {
  factory _$WorktreeStatusSummaryCopyWith(_WorktreeStatusSummary value, $Res Function(_WorktreeStatusSummary) _then) = __$WorktreeStatusSummaryCopyWithImpl;
@override @useResult
$Res call({
 bool isDirty, int ahead, int behind
});




}
/// @nodoc
class __$WorktreeStatusSummaryCopyWithImpl<$Res>
    implements _$WorktreeStatusSummaryCopyWith<$Res> {
  __$WorktreeStatusSummaryCopyWithImpl(this._self, this._then);

  final _WorktreeStatusSummary _self;
  final $Res Function(_WorktreeStatusSummary) _then;

/// Create a copy of WorktreeStatusSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isDirty = null,Object? ahead = null,Object? behind = null,}) {
  return _then(_WorktreeStatusSummary(
isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
