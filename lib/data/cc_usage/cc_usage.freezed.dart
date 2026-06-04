// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cc_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CcUsage {

/// 通常入力トークンの合計。
 int get inputTokens;/// 出力トークンの合計。
 int get outputTokens;/// キャッシュ読み取りトークンの合計。
 int get cacheReadTokens;/// キャッシュ生成（書き込み）トークンの合計。
 int get cacheCreationTokens;/// モデル別単価で算定した推定コスト（USD）。未知モデル分は 0 とする。
 double get estimatedCostUsd;
/// Create a copy of CcUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CcUsageCopyWith<CcUsage> get copyWith => _$CcUsageCopyWithImpl<CcUsage>(this as CcUsage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CcUsage&&(identical(other.inputTokens, inputTokens) || other.inputTokens == inputTokens)&&(identical(other.outputTokens, outputTokens) || other.outputTokens == outputTokens)&&(identical(other.cacheReadTokens, cacheReadTokens) || other.cacheReadTokens == cacheReadTokens)&&(identical(other.cacheCreationTokens, cacheCreationTokens) || other.cacheCreationTokens == cacheCreationTokens)&&(identical(other.estimatedCostUsd, estimatedCostUsd) || other.estimatedCostUsd == estimatedCostUsd));
}


@override
int get hashCode => Object.hash(runtimeType,inputTokens,outputTokens,cacheReadTokens,cacheCreationTokens,estimatedCostUsd);

@override
String toString() {
  return 'CcUsage(inputTokens: $inputTokens, outputTokens: $outputTokens, cacheReadTokens: $cacheReadTokens, cacheCreationTokens: $cacheCreationTokens, estimatedCostUsd: $estimatedCostUsd)';
}


}

/// @nodoc
abstract mixin class $CcUsageCopyWith<$Res>  {
  factory $CcUsageCopyWith(CcUsage value, $Res Function(CcUsage) _then) = _$CcUsageCopyWithImpl;
@useResult
$Res call({
 int inputTokens, int outputTokens, int cacheReadTokens, int cacheCreationTokens, double estimatedCostUsd
});




}
/// @nodoc
class _$CcUsageCopyWithImpl<$Res>
    implements $CcUsageCopyWith<$Res> {
  _$CcUsageCopyWithImpl(this._self, this._then);

  final CcUsage _self;
  final $Res Function(CcUsage) _then;

/// Create a copy of CcUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inputTokens = null,Object? outputTokens = null,Object? cacheReadTokens = null,Object? cacheCreationTokens = null,Object? estimatedCostUsd = null,}) {
  return _then(_self.copyWith(
inputTokens: null == inputTokens ? _self.inputTokens : inputTokens // ignore: cast_nullable_to_non_nullable
as int,outputTokens: null == outputTokens ? _self.outputTokens : outputTokens // ignore: cast_nullable_to_non_nullable
as int,cacheReadTokens: null == cacheReadTokens ? _self.cacheReadTokens : cacheReadTokens // ignore: cast_nullable_to_non_nullable
as int,cacheCreationTokens: null == cacheCreationTokens ? _self.cacheCreationTokens : cacheCreationTokens // ignore: cast_nullable_to_non_nullable
as int,estimatedCostUsd: null == estimatedCostUsd ? _self.estimatedCostUsd : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CcUsage].
extension CcUsagePatterns on CcUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CcUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CcUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CcUsage value)  $default,){
final _that = this;
switch (_that) {
case _CcUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CcUsage value)?  $default,){
final _that = this;
switch (_that) {
case _CcUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int inputTokens,  int outputTokens,  int cacheReadTokens,  int cacheCreationTokens,  double estimatedCostUsd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CcUsage() when $default != null:
return $default(_that.inputTokens,_that.outputTokens,_that.cacheReadTokens,_that.cacheCreationTokens,_that.estimatedCostUsd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int inputTokens,  int outputTokens,  int cacheReadTokens,  int cacheCreationTokens,  double estimatedCostUsd)  $default,) {final _that = this;
switch (_that) {
case _CcUsage():
return $default(_that.inputTokens,_that.outputTokens,_that.cacheReadTokens,_that.cacheCreationTokens,_that.estimatedCostUsd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int inputTokens,  int outputTokens,  int cacheReadTokens,  int cacheCreationTokens,  double estimatedCostUsd)?  $default,) {final _that = this;
switch (_that) {
case _CcUsage() when $default != null:
return $default(_that.inputTokens,_that.outputTokens,_that.cacheReadTokens,_that.cacheCreationTokens,_that.estimatedCostUsd);case _:
  return null;

}
}

}

/// @nodoc


class _CcUsage extends CcUsage {
  const _CcUsage({required this.inputTokens, required this.outputTokens, required this.cacheReadTokens, required this.cacheCreationTokens, required this.estimatedCostUsd}): super._();
  

/// 通常入力トークンの合計。
@override final  int inputTokens;
/// 出力トークンの合計。
@override final  int outputTokens;
/// キャッシュ読み取りトークンの合計。
@override final  int cacheReadTokens;
/// キャッシュ生成（書き込み）トークンの合計。
@override final  int cacheCreationTokens;
/// モデル別単価で算定した推定コスト（USD）。未知モデル分は 0 とする。
@override final  double estimatedCostUsd;

/// Create a copy of CcUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CcUsageCopyWith<_CcUsage> get copyWith => __$CcUsageCopyWithImpl<_CcUsage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CcUsage&&(identical(other.inputTokens, inputTokens) || other.inputTokens == inputTokens)&&(identical(other.outputTokens, outputTokens) || other.outputTokens == outputTokens)&&(identical(other.cacheReadTokens, cacheReadTokens) || other.cacheReadTokens == cacheReadTokens)&&(identical(other.cacheCreationTokens, cacheCreationTokens) || other.cacheCreationTokens == cacheCreationTokens)&&(identical(other.estimatedCostUsd, estimatedCostUsd) || other.estimatedCostUsd == estimatedCostUsd));
}


@override
int get hashCode => Object.hash(runtimeType,inputTokens,outputTokens,cacheReadTokens,cacheCreationTokens,estimatedCostUsd);

@override
String toString() {
  return 'CcUsage(inputTokens: $inputTokens, outputTokens: $outputTokens, cacheReadTokens: $cacheReadTokens, cacheCreationTokens: $cacheCreationTokens, estimatedCostUsd: $estimatedCostUsd)';
}


}

/// @nodoc
abstract mixin class _$CcUsageCopyWith<$Res> implements $CcUsageCopyWith<$Res> {
  factory _$CcUsageCopyWith(_CcUsage value, $Res Function(_CcUsage) _then) = __$CcUsageCopyWithImpl;
@override @useResult
$Res call({
 int inputTokens, int outputTokens, int cacheReadTokens, int cacheCreationTokens, double estimatedCostUsd
});




}
/// @nodoc
class __$CcUsageCopyWithImpl<$Res>
    implements _$CcUsageCopyWith<$Res> {
  __$CcUsageCopyWithImpl(this._self, this._then);

  final _CcUsage _self;
  final $Res Function(_CcUsage) _then;

/// Create a copy of CcUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inputTokens = null,Object? outputTokens = null,Object? cacheReadTokens = null,Object? cacheCreationTokens = null,Object? estimatedCostUsd = null,}) {
  return _then(_CcUsage(
inputTokens: null == inputTokens ? _self.inputTokens : inputTokens // ignore: cast_nullable_to_non_nullable
as int,outputTokens: null == outputTokens ? _self.outputTokens : outputTokens // ignore: cast_nullable_to_non_nullable
as int,cacheReadTokens: null == cacheReadTokens ? _self.cacheReadTokens : cacheReadTokens // ignore: cast_nullable_to_non_nullable
as int,cacheCreationTokens: null == cacheCreationTokens ? _self.cacheCreationTokens : cacheCreationTokens // ignore: cast_nullable_to_non_nullable
as int,estimatedCostUsd: null == estimatedCostUsd ? _self.estimatedCostUsd : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
