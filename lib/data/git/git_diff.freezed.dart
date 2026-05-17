// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_diff.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitDiffLine {

 GitDiffLineKind get kind;/// 行頭の `+` / `-` / 空白を除いた本文。
 String get text;/// 旧ファイル側の行番号。追加行・ヘッダでは `null`。
 int? get oldLineNo;/// 新ファイル側の行番号。削除行・ヘッダでは `null`。
 int? get newLineNo;
/// Create a copy of GitDiffLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitDiffLineCopyWith<GitDiffLine> get copyWith => _$GitDiffLineCopyWithImpl<GitDiffLine>(this as GitDiffLine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitDiffLine&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.text, text) || other.text == text)&&(identical(other.oldLineNo, oldLineNo) || other.oldLineNo == oldLineNo)&&(identical(other.newLineNo, newLineNo) || other.newLineNo == newLineNo));
}


@override
int get hashCode => Object.hash(runtimeType,kind,text,oldLineNo,newLineNo);

@override
String toString() {
  return 'GitDiffLine(kind: $kind, text: $text, oldLineNo: $oldLineNo, newLineNo: $newLineNo)';
}


}

/// @nodoc
abstract mixin class $GitDiffLineCopyWith<$Res>  {
  factory $GitDiffLineCopyWith(GitDiffLine value, $Res Function(GitDiffLine) _then) = _$GitDiffLineCopyWithImpl;
@useResult
$Res call({
 GitDiffLineKind kind, String text, int? oldLineNo, int? newLineNo
});




}
/// @nodoc
class _$GitDiffLineCopyWithImpl<$Res>
    implements $GitDiffLineCopyWith<$Res> {
  _$GitDiffLineCopyWithImpl(this._self, this._then);

  final GitDiffLine _self;
  final $Res Function(GitDiffLine) _then;

/// Create a copy of GitDiffLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? text = null,Object? oldLineNo = freezed,Object? newLineNo = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as GitDiffLineKind,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,oldLineNo: freezed == oldLineNo ? _self.oldLineNo : oldLineNo // ignore: cast_nullable_to_non_nullable
as int?,newLineNo: freezed == newLineNo ? _self.newLineNo : newLineNo // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [GitDiffLine].
extension GitDiffLinePatterns on GitDiffLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitDiffLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitDiffLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitDiffLine value)  $default,){
final _that = this;
switch (_that) {
case _GitDiffLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitDiffLine value)?  $default,){
final _that = this;
switch (_that) {
case _GitDiffLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GitDiffLineKind kind,  String text,  int? oldLineNo,  int? newLineNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitDiffLine() when $default != null:
return $default(_that.kind,_that.text,_that.oldLineNo,_that.newLineNo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GitDiffLineKind kind,  String text,  int? oldLineNo,  int? newLineNo)  $default,) {final _that = this;
switch (_that) {
case _GitDiffLine():
return $default(_that.kind,_that.text,_that.oldLineNo,_that.newLineNo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GitDiffLineKind kind,  String text,  int? oldLineNo,  int? newLineNo)?  $default,) {final _that = this;
switch (_that) {
case _GitDiffLine() when $default != null:
return $default(_that.kind,_that.text,_that.oldLineNo,_that.newLineNo);case _:
  return null;

}
}

}

/// @nodoc


class _GitDiffLine implements GitDiffLine {
  const _GitDiffLine({required this.kind, required this.text, this.oldLineNo, this.newLineNo});
  

@override final  GitDiffLineKind kind;
/// 行頭の `+` / `-` / 空白を除いた本文。
@override final  String text;
/// 旧ファイル側の行番号。追加行・ヘッダでは `null`。
@override final  int? oldLineNo;
/// 新ファイル側の行番号。削除行・ヘッダでは `null`。
@override final  int? newLineNo;

/// Create a copy of GitDiffLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitDiffLineCopyWith<_GitDiffLine> get copyWith => __$GitDiffLineCopyWithImpl<_GitDiffLine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitDiffLine&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.text, text) || other.text == text)&&(identical(other.oldLineNo, oldLineNo) || other.oldLineNo == oldLineNo)&&(identical(other.newLineNo, newLineNo) || other.newLineNo == newLineNo));
}


@override
int get hashCode => Object.hash(runtimeType,kind,text,oldLineNo,newLineNo);

@override
String toString() {
  return 'GitDiffLine(kind: $kind, text: $text, oldLineNo: $oldLineNo, newLineNo: $newLineNo)';
}


}

/// @nodoc
abstract mixin class _$GitDiffLineCopyWith<$Res> implements $GitDiffLineCopyWith<$Res> {
  factory _$GitDiffLineCopyWith(_GitDiffLine value, $Res Function(_GitDiffLine) _then) = __$GitDiffLineCopyWithImpl;
@override @useResult
$Res call({
 GitDiffLineKind kind, String text, int? oldLineNo, int? newLineNo
});




}
/// @nodoc
class __$GitDiffLineCopyWithImpl<$Res>
    implements _$GitDiffLineCopyWith<$Res> {
  __$GitDiffLineCopyWithImpl(this._self, this._then);

  final _GitDiffLine _self;
  final $Res Function(_GitDiffLine) _then;

/// Create a copy of GitDiffLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? text = null,Object? oldLineNo = freezed,Object? newLineNo = freezed,}) {
  return _then(_GitDiffLine(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as GitDiffLineKind,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,oldLineNo: freezed == oldLineNo ? _self.oldLineNo : oldLineNo // ignore: cast_nullable_to_non_nullable
as int?,newLineNo: freezed == newLineNo ? _self.newLineNo : newLineNo // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$GitDiff {

/// 対象ファイルのリポジトリルート相対パス。
 String get path;/// unified diff をパースした行列。
 List<GitDiffLine> get lines;/// バイナリファイルで差分行が出せない場合 `true`。
 bool get isBinary;
/// Create a copy of GitDiff
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitDiffCopyWith<GitDiff> get copyWith => _$GitDiffCopyWithImpl<GitDiff>(this as GitDiff, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitDiff&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other.lines, lines)&&(identical(other.isBinary, isBinary) || other.isBinary == isBinary));
}


@override
int get hashCode => Object.hash(runtimeType,path,const DeepCollectionEquality().hash(lines),isBinary);

@override
String toString() {
  return 'GitDiff(path: $path, lines: $lines, isBinary: $isBinary)';
}


}

/// @nodoc
abstract mixin class $GitDiffCopyWith<$Res>  {
  factory $GitDiffCopyWith(GitDiff value, $Res Function(GitDiff) _then) = _$GitDiffCopyWithImpl;
@useResult
$Res call({
 String path, List<GitDiffLine> lines, bool isBinary
});




}
/// @nodoc
class _$GitDiffCopyWithImpl<$Res>
    implements $GitDiffCopyWith<$Res> {
  _$GitDiffCopyWithImpl(this._self, this._then);

  final GitDiff _self;
  final $Res Function(GitDiff) _then;

/// Create a copy of GitDiff
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? lines = null,Object? isBinary = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<GitDiffLine>,isBinary: null == isBinary ? _self.isBinary : isBinary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GitDiff].
extension GitDiffPatterns on GitDiff {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitDiff value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitDiff() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitDiff value)  $default,){
final _that = this;
switch (_that) {
case _GitDiff():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitDiff value)?  $default,){
final _that = this;
switch (_that) {
case _GitDiff() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  List<GitDiffLine> lines,  bool isBinary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitDiff() when $default != null:
return $default(_that.path,_that.lines,_that.isBinary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  List<GitDiffLine> lines,  bool isBinary)  $default,) {final _that = this;
switch (_that) {
case _GitDiff():
return $default(_that.path,_that.lines,_that.isBinary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  List<GitDiffLine> lines,  bool isBinary)?  $default,) {final _that = this;
switch (_that) {
case _GitDiff() when $default != null:
return $default(_that.path,_that.lines,_that.isBinary);case _:
  return null;

}
}

}

/// @nodoc


class _GitDiff extends GitDiff {
  const _GitDiff({required this.path, required final  List<GitDiffLine> lines, this.isBinary = false}): _lines = lines,super._();
  

/// 対象ファイルのリポジトリルート相対パス。
@override final  String path;
/// unified diff をパースした行列。
 final  List<GitDiffLine> _lines;
/// unified diff をパースした行列。
@override List<GitDiffLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

/// バイナリファイルで差分行が出せない場合 `true`。
@override@JsonKey() final  bool isBinary;

/// Create a copy of GitDiff
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitDiffCopyWith<_GitDiff> get copyWith => __$GitDiffCopyWithImpl<_GitDiff>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitDiff&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other._lines, _lines)&&(identical(other.isBinary, isBinary) || other.isBinary == isBinary));
}


@override
int get hashCode => Object.hash(runtimeType,path,const DeepCollectionEquality().hash(_lines),isBinary);

@override
String toString() {
  return 'GitDiff(path: $path, lines: $lines, isBinary: $isBinary)';
}


}

/// @nodoc
abstract mixin class _$GitDiffCopyWith<$Res> implements $GitDiffCopyWith<$Res> {
  factory _$GitDiffCopyWith(_GitDiff value, $Res Function(_GitDiff) _then) = __$GitDiffCopyWithImpl;
@override @useResult
$Res call({
 String path, List<GitDiffLine> lines, bool isBinary
});




}
/// @nodoc
class __$GitDiffCopyWithImpl<$Res>
    implements _$GitDiffCopyWith<$Res> {
  __$GitDiffCopyWithImpl(this._self, this._then);

  final _GitDiff _self;
  final $Res Function(_GitDiff) _then;

/// Create a copy of GitDiff
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? lines = null,Object? isBinary = null,}) {
  return _then(_GitDiff(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<GitDiffLine>,isBinary: null == isBinary ? _self.isBinary : isBinary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
