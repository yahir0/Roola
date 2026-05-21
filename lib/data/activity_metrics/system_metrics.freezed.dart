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
 int get memoryTotalBytes;/// ディスクからの累積読み込みバイト数（IOBlockStorageDriver 合計）。
 int get diskReadBytes;/// ディスクへの累積書き込みバイト数（IOBlockStorageDriver 合計）。
 int get diskWrittenBytes;/// ネットワーク受信の累積バイト数（loopback 除く全インターフェイス）。
 int get networkInBytes;/// ネットワーク送信の累積バイト数（loopback 除く全インターフェイス）。
 int get networkOutBytes;
/// Create a copy of SystemMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemMetricsCopyWith<SystemMetrics> get copyWith => _$SystemMetricsCopyWithImpl<SystemMetrics>(this as SystemMetrics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemMetrics&&(identical(other.cpuPercent, cpuPercent) || other.cpuPercent == cpuPercent)&&(identical(other.memoryUsedBytes, memoryUsedBytes) || other.memoryUsedBytes == memoryUsedBytes)&&(identical(other.memoryTotalBytes, memoryTotalBytes) || other.memoryTotalBytes == memoryTotalBytes)&&(identical(other.diskReadBytes, diskReadBytes) || other.diskReadBytes == diskReadBytes)&&(identical(other.diskWrittenBytes, diskWrittenBytes) || other.diskWrittenBytes == diskWrittenBytes)&&(identical(other.networkInBytes, networkInBytes) || other.networkInBytes == networkInBytes)&&(identical(other.networkOutBytes, networkOutBytes) || other.networkOutBytes == networkOutBytes));
}


@override
int get hashCode => Object.hash(runtimeType,cpuPercent,memoryUsedBytes,memoryTotalBytes,diskReadBytes,diskWrittenBytes,networkInBytes,networkOutBytes);

@override
String toString() {
  return 'SystemMetrics(cpuPercent: $cpuPercent, memoryUsedBytes: $memoryUsedBytes, memoryTotalBytes: $memoryTotalBytes, diskReadBytes: $diskReadBytes, diskWrittenBytes: $diskWrittenBytes, networkInBytes: $networkInBytes, networkOutBytes: $networkOutBytes)';
}


}

/// @nodoc
abstract mixin class $SystemMetricsCopyWith<$Res>  {
  factory $SystemMetricsCopyWith(SystemMetrics value, $Res Function(SystemMetrics) _then) = _$SystemMetricsCopyWithImpl;
@useResult
$Res call({
 double cpuPercent, int memoryUsedBytes, int memoryTotalBytes, int diskReadBytes, int diskWrittenBytes, int networkInBytes, int networkOutBytes
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
@pragma('vm:prefer-inline') @override $Res call({Object? cpuPercent = null,Object? memoryUsedBytes = null,Object? memoryTotalBytes = null,Object? diskReadBytes = null,Object? diskWrittenBytes = null,Object? networkInBytes = null,Object? networkOutBytes = null,}) {
  return _then(_self.copyWith(
cpuPercent: null == cpuPercent ? _self.cpuPercent : cpuPercent // ignore: cast_nullable_to_non_nullable
as double,memoryUsedBytes: null == memoryUsedBytes ? _self.memoryUsedBytes : memoryUsedBytes // ignore: cast_nullable_to_non_nullable
as int,memoryTotalBytes: null == memoryTotalBytes ? _self.memoryTotalBytes : memoryTotalBytes // ignore: cast_nullable_to_non_nullable
as int,diskReadBytes: null == diskReadBytes ? _self.diskReadBytes : diskReadBytes // ignore: cast_nullable_to_non_nullable
as int,diskWrittenBytes: null == diskWrittenBytes ? _self.diskWrittenBytes : diskWrittenBytes // ignore: cast_nullable_to_non_nullable
as int,networkInBytes: null == networkInBytes ? _self.networkInBytes : networkInBytes // ignore: cast_nullable_to_non_nullable
as int,networkOutBytes: null == networkOutBytes ? _self.networkOutBytes : networkOutBytes // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double cpuPercent,  int memoryUsedBytes,  int memoryTotalBytes,  int diskReadBytes,  int diskWrittenBytes,  int networkInBytes,  int networkOutBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemMetrics() when $default != null:
return $default(_that.cpuPercent,_that.memoryUsedBytes,_that.memoryTotalBytes,_that.diskReadBytes,_that.diskWrittenBytes,_that.networkInBytes,_that.networkOutBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double cpuPercent,  int memoryUsedBytes,  int memoryTotalBytes,  int diskReadBytes,  int diskWrittenBytes,  int networkInBytes,  int networkOutBytes)  $default,) {final _that = this;
switch (_that) {
case _SystemMetrics():
return $default(_that.cpuPercent,_that.memoryUsedBytes,_that.memoryTotalBytes,_that.diskReadBytes,_that.diskWrittenBytes,_that.networkInBytes,_that.networkOutBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double cpuPercent,  int memoryUsedBytes,  int memoryTotalBytes,  int diskReadBytes,  int diskWrittenBytes,  int networkInBytes,  int networkOutBytes)?  $default,) {final _that = this;
switch (_that) {
case _SystemMetrics() when $default != null:
return $default(_that.cpuPercent,_that.memoryUsedBytes,_that.memoryTotalBytes,_that.diskReadBytes,_that.diskWrittenBytes,_that.networkInBytes,_that.networkOutBytes);case _:
  return null;

}
}

}

/// @nodoc


class _SystemMetrics extends SystemMetrics {
  const _SystemMetrics({required this.cpuPercent, required this.memoryUsedBytes, required this.memoryTotalBytes, required this.diskReadBytes, required this.diskWrittenBytes, required this.networkInBytes, required this.networkOutBytes}): super._();
  

/// システム全体の CPU 使用率（0–100）。
@override final  double cpuPercent;
/// 使用中メモリ（bytes）。
@override final  int memoryUsedBytes;
/// 物理メモリ総容量（bytes）。
@override final  int memoryTotalBytes;
/// ディスクからの累積読み込みバイト数（IOBlockStorageDriver 合計）。
@override final  int diskReadBytes;
/// ディスクへの累積書き込みバイト数（IOBlockStorageDriver 合計）。
@override final  int diskWrittenBytes;
/// ネットワーク受信の累積バイト数（loopback 除く全インターフェイス）。
@override final  int networkInBytes;
/// ネットワーク送信の累積バイト数（loopback 除く全インターフェイス）。
@override final  int networkOutBytes;

/// Create a copy of SystemMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemMetricsCopyWith<_SystemMetrics> get copyWith => __$SystemMetricsCopyWithImpl<_SystemMetrics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemMetrics&&(identical(other.cpuPercent, cpuPercent) || other.cpuPercent == cpuPercent)&&(identical(other.memoryUsedBytes, memoryUsedBytes) || other.memoryUsedBytes == memoryUsedBytes)&&(identical(other.memoryTotalBytes, memoryTotalBytes) || other.memoryTotalBytes == memoryTotalBytes)&&(identical(other.diskReadBytes, diskReadBytes) || other.diskReadBytes == diskReadBytes)&&(identical(other.diskWrittenBytes, diskWrittenBytes) || other.diskWrittenBytes == diskWrittenBytes)&&(identical(other.networkInBytes, networkInBytes) || other.networkInBytes == networkInBytes)&&(identical(other.networkOutBytes, networkOutBytes) || other.networkOutBytes == networkOutBytes));
}


@override
int get hashCode => Object.hash(runtimeType,cpuPercent,memoryUsedBytes,memoryTotalBytes,diskReadBytes,diskWrittenBytes,networkInBytes,networkOutBytes);

@override
String toString() {
  return 'SystemMetrics(cpuPercent: $cpuPercent, memoryUsedBytes: $memoryUsedBytes, memoryTotalBytes: $memoryTotalBytes, diskReadBytes: $diskReadBytes, diskWrittenBytes: $diskWrittenBytes, networkInBytes: $networkInBytes, networkOutBytes: $networkOutBytes)';
}


}

/// @nodoc
abstract mixin class _$SystemMetricsCopyWith<$Res> implements $SystemMetricsCopyWith<$Res> {
  factory _$SystemMetricsCopyWith(_SystemMetrics value, $Res Function(_SystemMetrics) _then) = __$SystemMetricsCopyWithImpl;
@override @useResult
$Res call({
 double cpuPercent, int memoryUsedBytes, int memoryTotalBytes, int diskReadBytes, int diskWrittenBytes, int networkInBytes, int networkOutBytes
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
@override @pragma('vm:prefer-inline') $Res call({Object? cpuPercent = null,Object? memoryUsedBytes = null,Object? memoryTotalBytes = null,Object? diskReadBytes = null,Object? diskWrittenBytes = null,Object? networkInBytes = null,Object? networkOutBytes = null,}) {
  return _then(_SystemMetrics(
cpuPercent: null == cpuPercent ? _self.cpuPercent : cpuPercent // ignore: cast_nullable_to_non_nullable
as double,memoryUsedBytes: null == memoryUsedBytes ? _self.memoryUsedBytes : memoryUsedBytes // ignore: cast_nullable_to_non_nullable
as int,memoryTotalBytes: null == memoryTotalBytes ? _self.memoryTotalBytes : memoryTotalBytes // ignore: cast_nullable_to_non_nullable
as int,diskReadBytes: null == diskReadBytes ? _self.diskReadBytes : diskReadBytes // ignore: cast_nullable_to_non_nullable
as int,diskWrittenBytes: null == diskWrittenBytes ? _self.diskWrittenBytes : diskWrittenBytes // ignore: cast_nullable_to_non_nullable
as int,networkInBytes: null == networkInBytes ? _self.networkInBytes : networkInBytes // ignore: cast_nullable_to_non_nullable
as int,networkOutBytes: null == networkOutBytes ? _self.networkOutBytes : networkOutBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
