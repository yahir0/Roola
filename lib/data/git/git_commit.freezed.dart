// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_commit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitCommit {

/// 完全な commit SHA-1。
 String get sha;/// 親コミットの SHA 群。2 つ以上ならマージコミット。
 List<String> get parents;/// コミットメッセージの 1 行目。
 String get subject;/// 作者名。
 String get authorName;/// 作者メールアドレス。
 String get authorEmail;/// 作者日時。
 DateTime get date;/// このコミットを指す ref ラベル（ブランチ / タグ / `HEAD`）。
 List<String> get refs;
/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitCommitCopyWith<GitCommit> get copyWith => _$GitCommitCopyWithImpl<GitCommit>(this as GitCommit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitCommit&&(identical(other.sha, sha) || other.sha == sha)&&const DeepCollectionEquality().equals(other.parents, parents)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorEmail, authorEmail) || other.authorEmail == authorEmail)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.refs, refs));
}


@override
int get hashCode => Object.hash(runtimeType,sha,const DeepCollectionEquality().hash(parents),subject,authorName,authorEmail,date,const DeepCollectionEquality().hash(refs));

@override
String toString() {
  return 'GitCommit(sha: $sha, parents: $parents, subject: $subject, authorName: $authorName, authorEmail: $authorEmail, date: $date, refs: $refs)';
}


}

/// @nodoc
abstract mixin class $GitCommitCopyWith<$Res>  {
  factory $GitCommitCopyWith(GitCommit value, $Res Function(GitCommit) _then) = _$GitCommitCopyWithImpl;
@useResult
$Res call({
 String sha, List<String> parents, String subject, String authorName, String authorEmail, DateTime date, List<String> refs
});




}
/// @nodoc
class _$GitCommitCopyWithImpl<$Res>
    implements $GitCommitCopyWith<$Res> {
  _$GitCommitCopyWithImpl(this._self, this._then);

  final GitCommit _self;
  final $Res Function(GitCommit) _then;

/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sha = null,Object? parents = null,Object? subject = null,Object? authorName = null,Object? authorEmail = null,Object? date = null,Object? refs = null,}) {
  return _then(_self.copyWith(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,parents: null == parents ? _self.parents : parents // ignore: cast_nullable_to_non_nullable
as List<String>,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorEmail: null == authorEmail ? _self.authorEmail : authorEmail // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,refs: null == refs ? _self.refs : refs // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GitCommit].
extension GitCommitPatterns on GitCommit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitCommit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitCommit value)  $default,){
final _that = this;
switch (_that) {
case _GitCommit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitCommit value)?  $default,){
final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sha,  List<String> parents,  String subject,  String authorName,  String authorEmail,  DateTime date,  List<String> refs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
return $default(_that.sha,_that.parents,_that.subject,_that.authorName,_that.authorEmail,_that.date,_that.refs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sha,  List<String> parents,  String subject,  String authorName,  String authorEmail,  DateTime date,  List<String> refs)  $default,) {final _that = this;
switch (_that) {
case _GitCommit():
return $default(_that.sha,_that.parents,_that.subject,_that.authorName,_that.authorEmail,_that.date,_that.refs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sha,  List<String> parents,  String subject,  String authorName,  String authorEmail,  DateTime date,  List<String> refs)?  $default,) {final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
return $default(_that.sha,_that.parents,_that.subject,_that.authorName,_that.authorEmail,_that.date,_that.refs);case _:
  return null;

}
}

}

/// @nodoc


class _GitCommit extends GitCommit {
  const _GitCommit({required this.sha, required final  List<String> parents, required this.subject, required this.authorName, required this.authorEmail, required this.date, final  List<String> refs = const <String>[]}): _parents = parents,_refs = refs,super._();
  

/// 完全な commit SHA-1。
@override final  String sha;
/// 親コミットの SHA 群。2 つ以上ならマージコミット。
 final  List<String> _parents;
/// 親コミットの SHA 群。2 つ以上ならマージコミット。
@override List<String> get parents {
  if (_parents is EqualUnmodifiableListView) return _parents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parents);
}

/// コミットメッセージの 1 行目。
@override final  String subject;
/// 作者名。
@override final  String authorName;
/// 作者メールアドレス。
@override final  String authorEmail;
/// 作者日時。
@override final  DateTime date;
/// このコミットを指す ref ラベル（ブランチ / タグ / `HEAD`）。
 final  List<String> _refs;
/// このコミットを指す ref ラベル（ブランチ / タグ / `HEAD`）。
@override@JsonKey() List<String> get refs {
  if (_refs is EqualUnmodifiableListView) return _refs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_refs);
}


/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitCommitCopyWith<_GitCommit> get copyWith => __$GitCommitCopyWithImpl<_GitCommit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitCommit&&(identical(other.sha, sha) || other.sha == sha)&&const DeepCollectionEquality().equals(other._parents, _parents)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorEmail, authorEmail) || other.authorEmail == authorEmail)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._refs, _refs));
}


@override
int get hashCode => Object.hash(runtimeType,sha,const DeepCollectionEquality().hash(_parents),subject,authorName,authorEmail,date,const DeepCollectionEquality().hash(_refs));

@override
String toString() {
  return 'GitCommit(sha: $sha, parents: $parents, subject: $subject, authorName: $authorName, authorEmail: $authorEmail, date: $date, refs: $refs)';
}


}

/// @nodoc
abstract mixin class _$GitCommitCopyWith<$Res> implements $GitCommitCopyWith<$Res> {
  factory _$GitCommitCopyWith(_GitCommit value, $Res Function(_GitCommit) _then) = __$GitCommitCopyWithImpl;
@override @useResult
$Res call({
 String sha, List<String> parents, String subject, String authorName, String authorEmail, DateTime date, List<String> refs
});




}
/// @nodoc
class __$GitCommitCopyWithImpl<$Res>
    implements _$GitCommitCopyWith<$Res> {
  __$GitCommitCopyWithImpl(this._self, this._then);

  final _GitCommit _self;
  final $Res Function(_GitCommit) _then;

/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sha = null,Object? parents = null,Object? subject = null,Object? authorName = null,Object? authorEmail = null,Object? date = null,Object? refs = null,}) {
  return _then(_GitCommit(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,parents: null == parents ? _self._parents : parents // ignore: cast_nullable_to_non_nullable
as List<String>,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorEmail: null == authorEmail ? _self.authorEmail : authorEmail // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,refs: null == refs ? _self._refs : refs // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
