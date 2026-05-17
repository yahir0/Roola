// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitNotice {

 GitNoticeKind get kind; String get message;/// `true` のとき「ターミナルで開く」導線を併記する（同期失敗時など）。
 bool get offerTerminal;
/// Create a copy of GitNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitNoticeCopyWith<GitNotice> get copyWith => _$GitNoticeCopyWithImpl<GitNotice>(this as GitNotice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitNotice&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.message, message) || other.message == message)&&(identical(other.offerTerminal, offerTerminal) || other.offerTerminal == offerTerminal));
}


@override
int get hashCode => Object.hash(runtimeType,kind,message,offerTerminal);

@override
String toString() {
  return 'GitNotice(kind: $kind, message: $message, offerTerminal: $offerTerminal)';
}


}

/// @nodoc
abstract mixin class $GitNoticeCopyWith<$Res>  {
  factory $GitNoticeCopyWith(GitNotice value, $Res Function(GitNotice) _then) = _$GitNoticeCopyWithImpl;
@useResult
$Res call({
 GitNoticeKind kind, String message, bool offerTerminal
});




}
/// @nodoc
class _$GitNoticeCopyWithImpl<$Res>
    implements $GitNoticeCopyWith<$Res> {
  _$GitNoticeCopyWithImpl(this._self, this._then);

  final GitNotice _self;
  final $Res Function(GitNotice) _then;

/// Create a copy of GitNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? message = null,Object? offerTerminal = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as GitNoticeKind,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,offerTerminal: null == offerTerminal ? _self.offerTerminal : offerTerminal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GitNotice].
extension GitNoticePatterns on GitNotice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitNotice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitNotice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitNotice value)  $default,){
final _that = this;
switch (_that) {
case _GitNotice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitNotice value)?  $default,){
final _that = this;
switch (_that) {
case _GitNotice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GitNoticeKind kind,  String message,  bool offerTerminal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitNotice() when $default != null:
return $default(_that.kind,_that.message,_that.offerTerminal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GitNoticeKind kind,  String message,  bool offerTerminal)  $default,) {final _that = this;
switch (_that) {
case _GitNotice():
return $default(_that.kind,_that.message,_that.offerTerminal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GitNoticeKind kind,  String message,  bool offerTerminal)?  $default,) {final _that = this;
switch (_that) {
case _GitNotice() when $default != null:
return $default(_that.kind,_that.message,_that.offerTerminal);case _:
  return null;

}
}

}

/// @nodoc


class _GitNotice implements GitNotice {
  const _GitNotice({required this.kind, required this.message, this.offerTerminal = false});
  

@override final  GitNoticeKind kind;
@override final  String message;
/// `true` のとき「ターミナルで開く」導線を併記する（同期失敗時など）。
@override@JsonKey() final  bool offerTerminal;

/// Create a copy of GitNotice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitNoticeCopyWith<_GitNotice> get copyWith => __$GitNoticeCopyWithImpl<_GitNotice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitNotice&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.message, message) || other.message == message)&&(identical(other.offerTerminal, offerTerminal) || other.offerTerminal == offerTerminal));
}


@override
int get hashCode => Object.hash(runtimeType,kind,message,offerTerminal);

@override
String toString() {
  return 'GitNotice(kind: $kind, message: $message, offerTerminal: $offerTerminal)';
}


}

/// @nodoc
abstract mixin class _$GitNoticeCopyWith<$Res> implements $GitNoticeCopyWith<$Res> {
  factory _$GitNoticeCopyWith(_GitNotice value, $Res Function(_GitNotice) _then) = __$GitNoticeCopyWithImpl;
@override @useResult
$Res call({
 GitNoticeKind kind, String message, bool offerTerminal
});




}
/// @nodoc
class __$GitNoticeCopyWithImpl<$Res>
    implements _$GitNoticeCopyWith<$Res> {
  __$GitNoticeCopyWithImpl(this._self, this._then);

  final _GitNotice _self;
  final $Res Function(_GitNotice) _then;

/// Create a copy of GitNotice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? message = null,Object? offerTerminal = null,}) {
  return _then(_GitNotice(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as GitNoticeKind,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,offerTerminal: null == offerTerminal ? _self.offerTerminal : offerTerminal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$GitViewState {

/// 対象リポジトリのルート絶対パス。
 String get repoRoot;/// `git` コマンドが利用できない、または GitTab が解決できない。
 bool get gitMissing;/// 作業ツリーの状態。初回ロード前は `null`。
 GitStatus? get status;/// ローカル・リモート追跡ブランチ一覧。
 List<GitBranch> get branches;/// 履歴グラフの行。
 List<GitGraphRow> get graph;/// さらに古い履歴を取得できる可能性があるか。
 bool get hasMoreHistory;/// stash 一覧。
 List<GitStashEntry> get stashes;/// 履歴で選択中のコミット SHA。
 String? get selectedSha;/// 選択中コミットの変更ファイル一覧。
 List<GitFileChange> get selectedCommitFiles;/// 進行中の Git 操作。`null` なら操作可能。
 GitOperation? get runningOperation;/// 通知バーに出すメッセージ。
 GitNotice? get notice;
/// Create a copy of GitViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitViewStateCopyWith<GitViewState> get copyWith => _$GitViewStateCopyWithImpl<GitViewState>(this as GitViewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitViewState&&(identical(other.repoRoot, repoRoot) || other.repoRoot == repoRoot)&&(identical(other.gitMissing, gitMissing) || other.gitMissing == gitMissing)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.branches, branches)&&const DeepCollectionEquality().equals(other.graph, graph)&&(identical(other.hasMoreHistory, hasMoreHistory) || other.hasMoreHistory == hasMoreHistory)&&const DeepCollectionEquality().equals(other.stashes, stashes)&&(identical(other.selectedSha, selectedSha) || other.selectedSha == selectedSha)&&const DeepCollectionEquality().equals(other.selectedCommitFiles, selectedCommitFiles)&&(identical(other.runningOperation, runningOperation) || other.runningOperation == runningOperation)&&(identical(other.notice, notice) || other.notice == notice));
}


@override
int get hashCode => Object.hash(runtimeType,repoRoot,gitMissing,status,const DeepCollectionEquality().hash(branches),const DeepCollectionEquality().hash(graph),hasMoreHistory,const DeepCollectionEquality().hash(stashes),selectedSha,const DeepCollectionEquality().hash(selectedCommitFiles),runningOperation,notice);

@override
String toString() {
  return 'GitViewState(repoRoot: $repoRoot, gitMissing: $gitMissing, status: $status, branches: $branches, graph: $graph, hasMoreHistory: $hasMoreHistory, stashes: $stashes, selectedSha: $selectedSha, selectedCommitFiles: $selectedCommitFiles, runningOperation: $runningOperation, notice: $notice)';
}


}

/// @nodoc
abstract mixin class $GitViewStateCopyWith<$Res>  {
  factory $GitViewStateCopyWith(GitViewState value, $Res Function(GitViewState) _then) = _$GitViewStateCopyWithImpl;
@useResult
$Res call({
 String repoRoot, bool gitMissing, GitStatus? status, List<GitBranch> branches, List<GitGraphRow> graph, bool hasMoreHistory, List<GitStashEntry> stashes, String? selectedSha, List<GitFileChange> selectedCommitFiles, GitOperation? runningOperation, GitNotice? notice
});


$GitStatusCopyWith<$Res>? get status;$GitNoticeCopyWith<$Res>? get notice;

}
/// @nodoc
class _$GitViewStateCopyWithImpl<$Res>
    implements $GitViewStateCopyWith<$Res> {
  _$GitViewStateCopyWithImpl(this._self, this._then);

  final GitViewState _self;
  final $Res Function(GitViewState) _then;

/// Create a copy of GitViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repoRoot = null,Object? gitMissing = null,Object? status = freezed,Object? branches = null,Object? graph = null,Object? hasMoreHistory = null,Object? stashes = null,Object? selectedSha = freezed,Object? selectedCommitFiles = null,Object? runningOperation = freezed,Object? notice = freezed,}) {
  return _then(_self.copyWith(
repoRoot: null == repoRoot ? _self.repoRoot : repoRoot // ignore: cast_nullable_to_non_nullable
as String,gitMissing: null == gitMissing ? _self.gitMissing : gitMissing // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GitStatus?,branches: null == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<GitBranch>,graph: null == graph ? _self.graph : graph // ignore: cast_nullable_to_non_nullable
as List<GitGraphRow>,hasMoreHistory: null == hasMoreHistory ? _self.hasMoreHistory : hasMoreHistory // ignore: cast_nullable_to_non_nullable
as bool,stashes: null == stashes ? _self.stashes : stashes // ignore: cast_nullable_to_non_nullable
as List<GitStashEntry>,selectedSha: freezed == selectedSha ? _self.selectedSha : selectedSha // ignore: cast_nullable_to_non_nullable
as String?,selectedCommitFiles: null == selectedCommitFiles ? _self.selectedCommitFiles : selectedCommitFiles // ignore: cast_nullable_to_non_nullable
as List<GitFileChange>,runningOperation: freezed == runningOperation ? _self.runningOperation : runningOperation // ignore: cast_nullable_to_non_nullable
as GitOperation?,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as GitNotice?,
  ));
}
/// Create a copy of GitViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $GitStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of GitViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitNoticeCopyWith<$Res>? get notice {
    if (_self.notice == null) {
    return null;
  }

  return $GitNoticeCopyWith<$Res>(_self.notice!, (value) {
    return _then(_self.copyWith(notice: value));
  });
}
}


/// Adds pattern-matching-related methods to [GitViewState].
extension GitViewStatePatterns on GitViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitViewState value)  $default,){
final _that = this;
switch (_that) {
case _GitViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitViewState value)?  $default,){
final _that = this;
switch (_that) {
case _GitViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String repoRoot,  bool gitMissing,  GitStatus? status,  List<GitBranch> branches,  List<GitGraphRow> graph,  bool hasMoreHistory,  List<GitStashEntry> stashes,  String? selectedSha,  List<GitFileChange> selectedCommitFiles,  GitOperation? runningOperation,  GitNotice? notice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitViewState() when $default != null:
return $default(_that.repoRoot,_that.gitMissing,_that.status,_that.branches,_that.graph,_that.hasMoreHistory,_that.stashes,_that.selectedSha,_that.selectedCommitFiles,_that.runningOperation,_that.notice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String repoRoot,  bool gitMissing,  GitStatus? status,  List<GitBranch> branches,  List<GitGraphRow> graph,  bool hasMoreHistory,  List<GitStashEntry> stashes,  String? selectedSha,  List<GitFileChange> selectedCommitFiles,  GitOperation? runningOperation,  GitNotice? notice)  $default,) {final _that = this;
switch (_that) {
case _GitViewState():
return $default(_that.repoRoot,_that.gitMissing,_that.status,_that.branches,_that.graph,_that.hasMoreHistory,_that.stashes,_that.selectedSha,_that.selectedCommitFiles,_that.runningOperation,_that.notice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String repoRoot,  bool gitMissing,  GitStatus? status,  List<GitBranch> branches,  List<GitGraphRow> graph,  bool hasMoreHistory,  List<GitStashEntry> stashes,  String? selectedSha,  List<GitFileChange> selectedCommitFiles,  GitOperation? runningOperation,  GitNotice? notice)?  $default,) {final _that = this;
switch (_that) {
case _GitViewState() when $default != null:
return $default(_that.repoRoot,_that.gitMissing,_that.status,_that.branches,_that.graph,_that.hasMoreHistory,_that.stashes,_that.selectedSha,_that.selectedCommitFiles,_that.runningOperation,_that.notice);case _:
  return null;

}
}

}

/// @nodoc


class _GitViewState extends GitViewState {
  const _GitViewState({required this.repoRoot, this.gitMissing = false, this.status, final  List<GitBranch> branches = const <GitBranch>[], final  List<GitGraphRow> graph = const <GitGraphRow>[], this.hasMoreHistory = true, final  List<GitStashEntry> stashes = const <GitStashEntry>[], this.selectedSha, final  List<GitFileChange> selectedCommitFiles = const <GitFileChange>[], this.runningOperation, this.notice}): _branches = branches,_graph = graph,_stashes = stashes,_selectedCommitFiles = selectedCommitFiles,super._();
  

/// 対象リポジトリのルート絶対パス。
@override final  String repoRoot;
/// `git` コマンドが利用できない、または GitTab が解決できない。
@override@JsonKey() final  bool gitMissing;
/// 作業ツリーの状態。初回ロード前は `null`。
@override final  GitStatus? status;
/// ローカル・リモート追跡ブランチ一覧。
 final  List<GitBranch> _branches;
/// ローカル・リモート追跡ブランチ一覧。
@override@JsonKey() List<GitBranch> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}

/// 履歴グラフの行。
 final  List<GitGraphRow> _graph;
/// 履歴グラフの行。
@override@JsonKey() List<GitGraphRow> get graph {
  if (_graph is EqualUnmodifiableListView) return _graph;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_graph);
}

/// さらに古い履歴を取得できる可能性があるか。
@override@JsonKey() final  bool hasMoreHistory;
/// stash 一覧。
 final  List<GitStashEntry> _stashes;
/// stash 一覧。
@override@JsonKey() List<GitStashEntry> get stashes {
  if (_stashes is EqualUnmodifiableListView) return _stashes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stashes);
}

/// 履歴で選択中のコミット SHA。
@override final  String? selectedSha;
/// 選択中コミットの変更ファイル一覧。
 final  List<GitFileChange> _selectedCommitFiles;
/// 選択中コミットの変更ファイル一覧。
@override@JsonKey() List<GitFileChange> get selectedCommitFiles {
  if (_selectedCommitFiles is EqualUnmodifiableListView) return _selectedCommitFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedCommitFiles);
}

/// 進行中の Git 操作。`null` なら操作可能。
@override final  GitOperation? runningOperation;
/// 通知バーに出すメッセージ。
@override final  GitNotice? notice;

/// Create a copy of GitViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitViewStateCopyWith<_GitViewState> get copyWith => __$GitViewStateCopyWithImpl<_GitViewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitViewState&&(identical(other.repoRoot, repoRoot) || other.repoRoot == repoRoot)&&(identical(other.gitMissing, gitMissing) || other.gitMissing == gitMissing)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._branches, _branches)&&const DeepCollectionEquality().equals(other._graph, _graph)&&(identical(other.hasMoreHistory, hasMoreHistory) || other.hasMoreHistory == hasMoreHistory)&&const DeepCollectionEquality().equals(other._stashes, _stashes)&&(identical(other.selectedSha, selectedSha) || other.selectedSha == selectedSha)&&const DeepCollectionEquality().equals(other._selectedCommitFiles, _selectedCommitFiles)&&(identical(other.runningOperation, runningOperation) || other.runningOperation == runningOperation)&&(identical(other.notice, notice) || other.notice == notice));
}


@override
int get hashCode => Object.hash(runtimeType,repoRoot,gitMissing,status,const DeepCollectionEquality().hash(_branches),const DeepCollectionEquality().hash(_graph),hasMoreHistory,const DeepCollectionEquality().hash(_stashes),selectedSha,const DeepCollectionEquality().hash(_selectedCommitFiles),runningOperation,notice);

@override
String toString() {
  return 'GitViewState(repoRoot: $repoRoot, gitMissing: $gitMissing, status: $status, branches: $branches, graph: $graph, hasMoreHistory: $hasMoreHistory, stashes: $stashes, selectedSha: $selectedSha, selectedCommitFiles: $selectedCommitFiles, runningOperation: $runningOperation, notice: $notice)';
}


}

/// @nodoc
abstract mixin class _$GitViewStateCopyWith<$Res> implements $GitViewStateCopyWith<$Res> {
  factory _$GitViewStateCopyWith(_GitViewState value, $Res Function(_GitViewState) _then) = __$GitViewStateCopyWithImpl;
@override @useResult
$Res call({
 String repoRoot, bool gitMissing, GitStatus? status, List<GitBranch> branches, List<GitGraphRow> graph, bool hasMoreHistory, List<GitStashEntry> stashes, String? selectedSha, List<GitFileChange> selectedCommitFiles, GitOperation? runningOperation, GitNotice? notice
});


@override $GitStatusCopyWith<$Res>? get status;@override $GitNoticeCopyWith<$Res>? get notice;

}
/// @nodoc
class __$GitViewStateCopyWithImpl<$Res>
    implements _$GitViewStateCopyWith<$Res> {
  __$GitViewStateCopyWithImpl(this._self, this._then);

  final _GitViewState _self;
  final $Res Function(_GitViewState) _then;

/// Create a copy of GitViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repoRoot = null,Object? gitMissing = null,Object? status = freezed,Object? branches = null,Object? graph = null,Object? hasMoreHistory = null,Object? stashes = null,Object? selectedSha = freezed,Object? selectedCommitFiles = null,Object? runningOperation = freezed,Object? notice = freezed,}) {
  return _then(_GitViewState(
repoRoot: null == repoRoot ? _self.repoRoot : repoRoot // ignore: cast_nullable_to_non_nullable
as String,gitMissing: null == gitMissing ? _self.gitMissing : gitMissing // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GitStatus?,branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<GitBranch>,graph: null == graph ? _self._graph : graph // ignore: cast_nullable_to_non_nullable
as List<GitGraphRow>,hasMoreHistory: null == hasMoreHistory ? _self.hasMoreHistory : hasMoreHistory // ignore: cast_nullable_to_non_nullable
as bool,stashes: null == stashes ? _self._stashes : stashes // ignore: cast_nullable_to_non_nullable
as List<GitStashEntry>,selectedSha: freezed == selectedSha ? _self.selectedSha : selectedSha // ignore: cast_nullable_to_non_nullable
as String?,selectedCommitFiles: null == selectedCommitFiles ? _self._selectedCommitFiles : selectedCommitFiles // ignore: cast_nullable_to_non_nullable
as List<GitFileChange>,runningOperation: freezed == runningOperation ? _self.runningOperation : runningOperation // ignore: cast_nullable_to_non_nullable
as GitOperation?,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as GitNotice?,
  ));
}

/// Create a copy of GitViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $GitStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of GitViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitNoticeCopyWith<$Res>? get notice {
    if (_self.notice == null) {
    return null;
  }

  return $GitNoticeCopyWith<$Res>(_self.notice!, (value) {
    return _then(_self.copyWith(notice: value));
  });
}
}

// dart format on
