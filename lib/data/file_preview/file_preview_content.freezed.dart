// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_preview_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FilePreviewContent {

 String get path;
/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilePreviewContentCopyWith<FilePreviewContent> get copyWith => _$FilePreviewContentCopyWithImpl<FilePreviewContent>(this as FilePreviewContent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilePreviewContent&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'FilePreviewContent(path: $path)';
}


}

/// @nodoc
abstract mixin class $FilePreviewContentCopyWith<$Res>  {
  factory $FilePreviewContentCopyWith(FilePreviewContent value, $Res Function(FilePreviewContent) _then) = _$FilePreviewContentCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$FilePreviewContentCopyWithImpl<$Res>
    implements $FilePreviewContentCopyWith<$Res> {
  _$FilePreviewContentCopyWithImpl(this._self, this._then);

  final FilePreviewContent _self;
  final $Res Function(FilePreviewContent) _then;

/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FilePreviewContent].
extension FilePreviewContentPatterns on FilePreviewContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FilePreviewText value)?  text,TResult Function( FilePreviewBinary value)?  binary,TResult Function( FilePreviewTooLarge value)?  tooLarge,TResult Function( FilePreviewFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FilePreviewText() when text != null:
return text(_that);case FilePreviewBinary() when binary != null:
return binary(_that);case FilePreviewTooLarge() when tooLarge != null:
return tooLarge(_that);case FilePreviewFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FilePreviewText value)  text,required TResult Function( FilePreviewBinary value)  binary,required TResult Function( FilePreviewTooLarge value)  tooLarge,required TResult Function( FilePreviewFailed value)  failed,}){
final _that = this;
switch (_that) {
case FilePreviewText():
return text(_that);case FilePreviewBinary():
return binary(_that);case FilePreviewTooLarge():
return tooLarge(_that);case FilePreviewFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FilePreviewText value)?  text,TResult? Function( FilePreviewBinary value)?  binary,TResult? Function( FilePreviewTooLarge value)?  tooLarge,TResult? Function( FilePreviewFailed value)?  failed,}){
final _that = this;
switch (_that) {
case FilePreviewText() when text != null:
return text(_that);case FilePreviewBinary() when binary != null:
return binary(_that);case FilePreviewTooLarge() when tooLarge != null:
return tooLarge(_that);case FilePreviewFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String path,  String content,  String? language,  bool isTruncated)?  text,TResult Function( String path)?  binary,TResult Function( String path,  int sizeBytes)?  tooLarge,TResult Function( String path,  String message)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FilePreviewText() when text != null:
return text(_that.path,_that.content,_that.language,_that.isTruncated);case FilePreviewBinary() when binary != null:
return binary(_that.path);case FilePreviewTooLarge() when tooLarge != null:
return tooLarge(_that.path,_that.sizeBytes);case FilePreviewFailed() when failed != null:
return failed(_that.path,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String path,  String content,  String? language,  bool isTruncated)  text,required TResult Function( String path)  binary,required TResult Function( String path,  int sizeBytes)  tooLarge,required TResult Function( String path,  String message)  failed,}) {final _that = this;
switch (_that) {
case FilePreviewText():
return text(_that.path,_that.content,_that.language,_that.isTruncated);case FilePreviewBinary():
return binary(_that.path);case FilePreviewTooLarge():
return tooLarge(_that.path,_that.sizeBytes);case FilePreviewFailed():
return failed(_that.path,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String path,  String content,  String? language,  bool isTruncated)?  text,TResult? Function( String path)?  binary,TResult? Function( String path,  int sizeBytes)?  tooLarge,TResult? Function( String path,  String message)?  failed,}) {final _that = this;
switch (_that) {
case FilePreviewText() when text != null:
return text(_that.path,_that.content,_that.language,_that.isTruncated);case FilePreviewBinary() when binary != null:
return binary(_that.path);case FilePreviewTooLarge() when tooLarge != null:
return tooLarge(_that.path,_that.sizeBytes);case FilePreviewFailed() when failed != null:
return failed(_that.path,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class FilePreviewText implements FilePreviewContent {
  const FilePreviewText({required this.path, required this.content, required this.language, required this.isTruncated});
  

@override final  String path;
 final  String content;
 final  String? language;
 final  bool isTruncated;

/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilePreviewTextCopyWith<FilePreviewText> get copyWith => _$FilePreviewTextCopyWithImpl<FilePreviewText>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilePreviewText&&(identical(other.path, path) || other.path == path)&&(identical(other.content, content) || other.content == content)&&(identical(other.language, language) || other.language == language)&&(identical(other.isTruncated, isTruncated) || other.isTruncated == isTruncated));
}


@override
int get hashCode => Object.hash(runtimeType,path,content,language,isTruncated);

@override
String toString() {
  return 'FilePreviewContent.text(path: $path, content: $content, language: $language, isTruncated: $isTruncated)';
}


}

/// @nodoc
abstract mixin class $FilePreviewTextCopyWith<$Res> implements $FilePreviewContentCopyWith<$Res> {
  factory $FilePreviewTextCopyWith(FilePreviewText value, $Res Function(FilePreviewText) _then) = _$FilePreviewTextCopyWithImpl;
@override @useResult
$Res call({
 String path, String content, String? language, bool isTruncated
});




}
/// @nodoc
class _$FilePreviewTextCopyWithImpl<$Res>
    implements $FilePreviewTextCopyWith<$Res> {
  _$FilePreviewTextCopyWithImpl(this._self, this._then);

  final FilePreviewText _self;
  final $Res Function(FilePreviewText) _then;

/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? content = null,Object? language = freezed,Object? isTruncated = null,}) {
  return _then(FilePreviewText(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,isTruncated: null == isTruncated ? _self.isTruncated : isTruncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class FilePreviewBinary implements FilePreviewContent {
  const FilePreviewBinary({required this.path});
  

@override final  String path;

/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilePreviewBinaryCopyWith<FilePreviewBinary> get copyWith => _$FilePreviewBinaryCopyWithImpl<FilePreviewBinary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilePreviewBinary&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'FilePreviewContent.binary(path: $path)';
}


}

/// @nodoc
abstract mixin class $FilePreviewBinaryCopyWith<$Res> implements $FilePreviewContentCopyWith<$Res> {
  factory $FilePreviewBinaryCopyWith(FilePreviewBinary value, $Res Function(FilePreviewBinary) _then) = _$FilePreviewBinaryCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$FilePreviewBinaryCopyWithImpl<$Res>
    implements $FilePreviewBinaryCopyWith<$Res> {
  _$FilePreviewBinaryCopyWithImpl(this._self, this._then);

  final FilePreviewBinary _self;
  final $Res Function(FilePreviewBinary) _then;

/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(FilePreviewBinary(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FilePreviewTooLarge implements FilePreviewContent {
  const FilePreviewTooLarge({required this.path, required this.sizeBytes});
  

@override final  String path;
 final  int sizeBytes;

/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilePreviewTooLargeCopyWith<FilePreviewTooLarge> get copyWith => _$FilePreviewTooLargeCopyWithImpl<FilePreviewTooLarge>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilePreviewTooLarge&&(identical(other.path, path) || other.path == path)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}


@override
int get hashCode => Object.hash(runtimeType,path,sizeBytes);

@override
String toString() {
  return 'FilePreviewContent.tooLarge(path: $path, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class $FilePreviewTooLargeCopyWith<$Res> implements $FilePreviewContentCopyWith<$Res> {
  factory $FilePreviewTooLargeCopyWith(FilePreviewTooLarge value, $Res Function(FilePreviewTooLarge) _then) = _$FilePreviewTooLargeCopyWithImpl;
@override @useResult
$Res call({
 String path, int sizeBytes
});




}
/// @nodoc
class _$FilePreviewTooLargeCopyWithImpl<$Res>
    implements $FilePreviewTooLargeCopyWith<$Res> {
  _$FilePreviewTooLargeCopyWithImpl(this._self, this._then);

  final FilePreviewTooLarge _self;
  final $Res Function(FilePreviewTooLarge) _then;

/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? sizeBytes = null,}) {
  return _then(FilePreviewTooLarge(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class FilePreviewFailed implements FilePreviewContent {
  const FilePreviewFailed({required this.path, required this.message});
  

@override final  String path;
 final  String message;

/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilePreviewFailedCopyWith<FilePreviewFailed> get copyWith => _$FilePreviewFailedCopyWithImpl<FilePreviewFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilePreviewFailed&&(identical(other.path, path) || other.path == path)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,path,message);

@override
String toString() {
  return 'FilePreviewContent.failed(path: $path, message: $message)';
}


}

/// @nodoc
abstract mixin class $FilePreviewFailedCopyWith<$Res> implements $FilePreviewContentCopyWith<$Res> {
  factory $FilePreviewFailedCopyWith(FilePreviewFailed value, $Res Function(FilePreviewFailed) _then) = _$FilePreviewFailedCopyWithImpl;
@override @useResult
$Res call({
 String path, String message
});




}
/// @nodoc
class _$FilePreviewFailedCopyWithImpl<$Res>
    implements $FilePreviewFailedCopyWith<$Res> {
  _$FilePreviewFailedCopyWithImpl(this._self, this._then);

  final FilePreviewFailed _self;
  final $Res Function(FilePreviewFailed) _then;

/// Create a copy of FilePreviewContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? message = null,}) {
  return _then(FilePreviewFailed(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
