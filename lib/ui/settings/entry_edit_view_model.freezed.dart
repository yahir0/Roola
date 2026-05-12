// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_edit_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EntryEditState {

 String get displayName; String get repositoryPath; String get skillName;/// 表示中のアイコンパス。新規選択中はソース画像の絶対パス、
/// 保存済みエントリ編集時は永続化先のパス。
 String? get iconPath;/// 「保存ボタンを押したらこのソース画像をリサイズして保存する」用の
/// 一時的なソースパス。null なら既存 iconPath を維持する。
 String? get pendingIconSource; Map<String, String> get errors; bool get isSubmitting;
/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryEditStateCopyWith<EntryEditState> get copyWith => _$EntryEditStateCopyWithImpl<EntryEditState>(this as EntryEditState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryEditState&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.repositoryPath, repositoryPath) || other.repositoryPath == repositoryPath)&&(identical(other.skillName, skillName) || other.skillName == skillName)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.pendingIconSource, pendingIconSource) || other.pendingIconSource == pendingIconSource)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,repositoryPath,skillName,iconPath,pendingIconSource,const DeepCollectionEquality().hash(errors),isSubmitting);

@override
String toString() {
  return 'EntryEditState(displayName: $displayName, repositoryPath: $repositoryPath, skillName: $skillName, iconPath: $iconPath, pendingIconSource: $pendingIconSource, errors: $errors, isSubmitting: $isSubmitting)';
}


}

/// @nodoc
abstract mixin class $EntryEditStateCopyWith<$Res>  {
  factory $EntryEditStateCopyWith(EntryEditState value, $Res Function(EntryEditState) _then) = _$EntryEditStateCopyWithImpl;
@useResult
$Res call({
 String displayName, String repositoryPath, String skillName, String? iconPath, String? pendingIconSource, Map<String, String> errors, bool isSubmitting
});




}
/// @nodoc
class _$EntryEditStateCopyWithImpl<$Res>
    implements $EntryEditStateCopyWith<$Res> {
  _$EntryEditStateCopyWithImpl(this._self, this._then);

  final EntryEditState _self;
  final $Res Function(EntryEditState) _then;

/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? repositoryPath = null,Object? skillName = null,Object? iconPath = freezed,Object? pendingIconSource = freezed,Object? errors = null,Object? isSubmitting = null,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,repositoryPath: null == repositoryPath ? _self.repositoryPath : repositoryPath // ignore: cast_nullable_to_non_nullable
as String,skillName: null == skillName ? _self.skillName : skillName // ignore: cast_nullable_to_non_nullable
as String,iconPath: freezed == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String?,pendingIconSource: freezed == pendingIconSource ? _self.pendingIconSource : pendingIconSource // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EntryEditState].
extension EntryEditStatePatterns on EntryEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryEditState value)  $default,){
final _that = this;
switch (_that) {
case _EntryEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryEditState value)?  $default,){
final _that = this;
switch (_that) {
case _EntryEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName,  String repositoryPath,  String skillName,  String? iconPath,  String? pendingIconSource,  Map<String, String> errors,  bool isSubmitting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryEditState() when $default != null:
return $default(_that.displayName,_that.repositoryPath,_that.skillName,_that.iconPath,_that.pendingIconSource,_that.errors,_that.isSubmitting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName,  String repositoryPath,  String skillName,  String? iconPath,  String? pendingIconSource,  Map<String, String> errors,  bool isSubmitting)  $default,) {final _that = this;
switch (_that) {
case _EntryEditState():
return $default(_that.displayName,_that.repositoryPath,_that.skillName,_that.iconPath,_that.pendingIconSource,_that.errors,_that.isSubmitting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName,  String repositoryPath,  String skillName,  String? iconPath,  String? pendingIconSource,  Map<String, String> errors,  bool isSubmitting)?  $default,) {final _that = this;
switch (_that) {
case _EntryEditState() when $default != null:
return $default(_that.displayName,_that.repositoryPath,_that.skillName,_that.iconPath,_that.pendingIconSource,_that.errors,_that.isSubmitting);case _:
  return null;

}
}

}

/// @nodoc


class _EntryEditState implements EntryEditState {
  const _EntryEditState({required this.displayName, required this.repositoryPath, required this.skillName, this.iconPath, this.pendingIconSource, final  Map<String, String> errors = const <String, String>{}, this.isSubmitting = false}): _errors = errors;
  

@override final  String displayName;
@override final  String repositoryPath;
@override final  String skillName;
/// 表示中のアイコンパス。新規選択中はソース画像の絶対パス、
/// 保存済みエントリ編集時は永続化先のパス。
@override final  String? iconPath;
/// 「保存ボタンを押したらこのソース画像をリサイズして保存する」用の
/// 一時的なソースパス。null なら既存 iconPath を維持する。
@override final  String? pendingIconSource;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override@JsonKey() final  bool isSubmitting;

/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryEditStateCopyWith<_EntryEditState> get copyWith => __$EntryEditStateCopyWithImpl<_EntryEditState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryEditState&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.repositoryPath, repositoryPath) || other.repositoryPath == repositoryPath)&&(identical(other.skillName, skillName) || other.skillName == skillName)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.pendingIconSource, pendingIconSource) || other.pendingIconSource == pendingIconSource)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,repositoryPath,skillName,iconPath,pendingIconSource,const DeepCollectionEquality().hash(_errors),isSubmitting);

@override
String toString() {
  return 'EntryEditState(displayName: $displayName, repositoryPath: $repositoryPath, skillName: $skillName, iconPath: $iconPath, pendingIconSource: $pendingIconSource, errors: $errors, isSubmitting: $isSubmitting)';
}


}

/// @nodoc
abstract mixin class _$EntryEditStateCopyWith<$Res> implements $EntryEditStateCopyWith<$Res> {
  factory _$EntryEditStateCopyWith(_EntryEditState value, $Res Function(_EntryEditState) _then) = __$EntryEditStateCopyWithImpl;
@override @useResult
$Res call({
 String displayName, String repositoryPath, String skillName, String? iconPath, String? pendingIconSource, Map<String, String> errors, bool isSubmitting
});




}
/// @nodoc
class __$EntryEditStateCopyWithImpl<$Res>
    implements _$EntryEditStateCopyWith<$Res> {
  __$EntryEditStateCopyWithImpl(this._self, this._then);

  final _EntryEditState _self;
  final $Res Function(_EntryEditState) _then;

/// Create a copy of EntryEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? repositoryPath = null,Object? skillName = null,Object? iconPath = freezed,Object? pendingIconSource = freezed,Object? errors = null,Object? isSubmitting = null,}) {
  return _then(_EntryEditState(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,repositoryPath: null == repositoryPath ? _self.repositoryPath : repositoryPath // ignore: cast_nullable_to_non_nullable
as String,skillName: null == skillName ? _self.skillName : skillName // ignore: cast_nullable_to_non_nullable
as String,iconPath: freezed == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String?,pendingIconSource: freezed == pendingIconSource ? _self.pendingIconSource : pendingIconSource // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
