// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SystemMetrics {

/// システム全体の CPU 使用率（0–100）。
 double get cpuPercent;/// 使用中メモリ（bytes）。
 int get memoryUsedBytes;/// 物理メモリ総容量（bytes）。
 int get memoryTotalBytes;
/// Create a copy of SystemMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemMetricsCopyWith<SystemMetrics> get copyWith => _$SystemMetricsCopyWithImpl<SystemMetrics>(this as SystemMetrics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemMetrics&&(identical(other.cpuPercent, cpuPercent) || other.cpuPercent == cpuPercent)&&(identical(other.memoryUsedBytes, memoryUsedBytes) || other.memoryUsedBytes == memoryUsedBytes)&&(identical(other.memoryTotalBytes, memoryTotalBytes) || other.memoryTotalBytes == memoryTotalBytes));
}


@override
int get hashCode => Object.hash(runtimeType,cpuPercent,memoryUsedBytes,memoryTotalBytes);

@override
String toString() {
  return 'SystemMetrics(cpuPercent: $cpuPercent, memoryUsedBytes: $memoryUsedBytes, memoryTotalBytes: $memoryTotalBytes)';
}


}

/// @nodoc
abstract mixin class $SystemMetricsCopyWith<$Res>  {
  factory $SystemMetricsCopyWith(SystemMetrics value, $Res Function(SystemMetrics) _then) = _$SystemMetricsCopyWithImpl;
@useResult
$Res call({
 double cpuPercent, int memoryUsedBytes, int memoryTotalBytes
});




}
/// @nodoc
class _$SystemMetricsCopyWithImpl<$Res>
    implements $SystemMetricsCopyWith<$Res> {
  _$SystemMetricsCopyWithImpl(this._self, this._then);

  final SystemMetrics _self;
  final $Res Function(SystemMetrics) _then;

/// Create a copy of SystemMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cpuPercent = null,Object? memoryUsedBytes = null,Object? memoryTotalBytes = null,}) {
  return _then(_self.copyWith(
cpuPercent: null == cpuPercent ? _self.cpuPercent : cpuPercent // ignore: cast_nullable_to_non_nullable
as double,memoryUsedBytes: null == memoryUsedBytes ? _self.memoryUsedBytes : memoryUsedBytes // ignore: cast_nullable_to_non_nullable
as int,memoryTotalBytes: null == memoryTotalBytes ? _self.memoryTotalBytes : memoryTotalBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SystemMetrics].
extension SystemMetricsPatterns on SystemMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SystemMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SystemMetrics value)  $default,){
final _that = this;
switch (_that) {
case _SystemMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SystemMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _SystemMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double cpuPercent,  int memoryUsedBytes,  int memoryTotalBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemMetrics() when $default != null:
return $default(_that.cpuPercent,_that.memoryUsedBytes,_that.memoryTotalBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double cpuPercent,  int memoryUsedBytes,  int memoryTotalBytes)  $default,) {final _that = this;
switch (_that) {
case _SystemMetrics():
return $default(_that.cpuPercent,_that.memoryUsedBytes,_that.memoryTotalBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double cpuPercent,  int memoryUsedBytes,  int memoryTotalBytes)?  $default,) {final _that = this;
switch (_that) {
case _SystemMetrics() when $default != null:
return $default(_that.cpuPercent,_that.memoryUsedBytes,_that.memoryTotalBytes);case _:
  return null;

}
}

}

/// @nodoc


class _SystemMetrics extends SystemMetrics {
  const _SystemMetrics({required this.cpuPercent, required this.memoryUsedBytes, required this.memoryTotalBytes}): super._();
  

/// システム全体の CPU 使用率（0–100）。
@override final  double cpuPercent;
/// 使用中メモリ（bytes）。
@override final  int memoryUsedBytes;
/// 物理メモリ総容量（bytes）。
@override final  int memoryTotalBytes;

/// Create a copy of SystemMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemMetricsCopyWith<_SystemMetrics> get copyWith => __$SystemMetricsCopyWithImpl<_SystemMetrics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemMetrics&&(identical(other.cpuPercent, cpuPercent) || other.cpuPercent == cpuPercent)&&(identical(other.memoryUsedBytes, memoryUsedBytes) || other.memoryUsedBytes == memoryUsedBytes)&&(identical(other.memoryTotalBytes, memoryTotalBytes) || other.memoryTotalBytes == memoryTotalBytes));
}


@override
int get hashCode => Object.hash(runtimeType,cpuPercent,memoryUsedBytes,memoryTotalBytes);

@override
String toString() {
  return 'SystemMetrics(cpuPercent: $cpuPercent, memoryUsedBytes: $memoryUsedBytes, memoryTotalBytes: $memoryTotalBytes)';
}


}

/// @nodoc
abstract mixin class _$SystemMetricsCopyWith<$Res> implements $SystemMetricsCopyWith<$Res> {
  factory _$SystemMetricsCopyWith(_SystemMetrics value, $Res Function(_SystemMetrics) _then) = __$SystemMetricsCopyWithImpl;
@override @useResult
$Res call({
 double cpuPercent, int memoryUsedBytes, int memoryTotalBytes
});




}
/// @nodoc
class __$SystemMetricsCopyWithImpl<$Res>
    implements _$SystemMetricsCopyWith<$Res> {
  __$SystemMetricsCopyWithImpl(this._self, this._then);

  final _SystemMetrics _self;
  final $Res Function(_SystemMetrics) _then;

/// Create a copy of SystemMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cpuPercent = null,Object? memoryUsedBytes = null,Object? memoryTotalBytes = null,}) {
  return _then(_SystemMetrics(
cpuPercent: null == cpuPercent ? _self.cpuPercent : cpuPercent // ignore: cast_nullable_to_non_nullable
as double,memoryUsedBytes: null == memoryUsedBytes ? _self.memoryUsedBytes : memoryUsedBytes // ignore: cast_nullable_to_non_nullable
as int,memoryTotalBytes: null == memoryTotalBytes ? _self.memoryTotalBytes : memoryTotalBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
