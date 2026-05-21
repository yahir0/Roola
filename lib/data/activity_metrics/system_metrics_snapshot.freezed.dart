// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_metrics_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SystemMetricsSnapshot {

/// この snapshot 時点の素データ（累積カウンタ含む）。
 SystemMetrics get metrics;/// ディスク I/O レート（read + write の合計、B/s）。初回 snapshot は 0。
 double get diskBytesPerSec;/// ネットワーク I/O レート（in + out の合計、B/s）。初回 snapshot は 0。
 double get networkBytesPerSec;
/// Create a copy of SystemMetricsSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemMetricsSnapshotCopyWith<SystemMetricsSnapshot> get copyWith => _$SystemMetricsSnapshotCopyWithImpl<SystemMetricsSnapshot>(this as SystemMetricsSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemMetricsSnapshot&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.diskBytesPerSec, diskBytesPerSec) || other.diskBytesPerSec == diskBytesPerSec)&&(identical(other.networkBytesPerSec, networkBytesPerSec) || other.networkBytesPerSec == networkBytesPerSec));
}


@override
int get hashCode => Object.hash(runtimeType,metrics,diskBytesPerSec,networkBytesPerSec);

@override
String toString() {
  return 'SystemMetricsSnapshot(metrics: $metrics, diskBytesPerSec: $diskBytesPerSec, networkBytesPerSec: $networkBytesPerSec)';
}


}

/// @nodoc
abstract mixin class $SystemMetricsSnapshotCopyWith<$Res>  {
  factory $SystemMetricsSnapshotCopyWith(SystemMetricsSnapshot value, $Res Function(SystemMetricsSnapshot) _then) = _$SystemMetricsSnapshotCopyWithImpl;
@useResult
$Res call({
 SystemMetrics metrics, double diskBytesPerSec, double networkBytesPerSec
});


$SystemMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class _$SystemMetricsSnapshotCopyWithImpl<$Res>
    implements $SystemMetricsSnapshotCopyWith<$Res> {
  _$SystemMetricsSnapshotCopyWithImpl(this._self, this._then);

  final SystemMetricsSnapshot _self;
  final $Res Function(SystemMetricsSnapshot) _then;

/// Create a copy of SystemMetricsSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metrics = null,Object? diskBytesPerSec = null,Object? networkBytesPerSec = null,}) {
  return _then(_self.copyWith(
metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as SystemMetrics,diskBytesPerSec: null == diskBytesPerSec ? _self.diskBytesPerSec : diskBytesPerSec // ignore: cast_nullable_to_non_nullable
as double,networkBytesPerSec: null == networkBytesPerSec ? _self.networkBytesPerSec : networkBytesPerSec // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of SystemMetricsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SystemMetricsCopyWith<$Res> get metrics {
  
  return $SystemMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}


/// Adds pattern-matching-related methods to [SystemMetricsSnapshot].
extension SystemMetricsSnapshotPatterns on SystemMetricsSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SystemMetricsSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemMetricsSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SystemMetricsSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _SystemMetricsSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SystemMetricsSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _SystemMetricsSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SystemMetrics metrics,  double diskBytesPerSec,  double networkBytesPerSec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemMetricsSnapshot() when $default != null:
return $default(_that.metrics,_that.diskBytesPerSec,_that.networkBytesPerSec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SystemMetrics metrics,  double diskBytesPerSec,  double networkBytesPerSec)  $default,) {final _that = this;
switch (_that) {
case _SystemMetricsSnapshot():
return $default(_that.metrics,_that.diskBytesPerSec,_that.networkBytesPerSec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SystemMetrics metrics,  double diskBytesPerSec,  double networkBytesPerSec)?  $default,) {final _that = this;
switch (_that) {
case _SystemMetricsSnapshot() when $default != null:
return $default(_that.metrics,_that.diskBytesPerSec,_that.networkBytesPerSec);case _:
  return null;

}
}

}

/// @nodoc


class _SystemMetricsSnapshot extends SystemMetricsSnapshot {
  const _SystemMetricsSnapshot({required this.metrics, required this.diskBytesPerSec, required this.networkBytesPerSec}): super._();
  

/// この snapshot 時点の素データ（累積カウンタ含む）。
@override final  SystemMetrics metrics;
/// ディスク I/O レート（read + write の合計、B/s）。初回 snapshot は 0。
@override final  double diskBytesPerSec;
/// ネットワーク I/O レート（in + out の合計、B/s）。初回 snapshot は 0。
@override final  double networkBytesPerSec;

/// Create a copy of SystemMetricsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemMetricsSnapshotCopyWith<_SystemMetricsSnapshot> get copyWith => __$SystemMetricsSnapshotCopyWithImpl<_SystemMetricsSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemMetricsSnapshot&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.diskBytesPerSec, diskBytesPerSec) || other.diskBytesPerSec == diskBytesPerSec)&&(identical(other.networkBytesPerSec, networkBytesPerSec) || other.networkBytesPerSec == networkBytesPerSec));
}


@override
int get hashCode => Object.hash(runtimeType,metrics,diskBytesPerSec,networkBytesPerSec);

@override
String toString() {
  return 'SystemMetricsSnapshot(metrics: $metrics, diskBytesPerSec: $diskBytesPerSec, networkBytesPerSec: $networkBytesPerSec)';
}


}

/// @nodoc
abstract mixin class _$SystemMetricsSnapshotCopyWith<$Res> implements $SystemMetricsSnapshotCopyWith<$Res> {
  factory _$SystemMetricsSnapshotCopyWith(_SystemMetricsSnapshot value, $Res Function(_SystemMetricsSnapshot) _then) = __$SystemMetricsSnapshotCopyWithImpl;
@override @useResult
$Res call({
 SystemMetrics metrics, double diskBytesPerSec, double networkBytesPerSec
});


@override $SystemMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class __$SystemMetricsSnapshotCopyWithImpl<$Res>
    implements _$SystemMetricsSnapshotCopyWith<$Res> {
  __$SystemMetricsSnapshotCopyWithImpl(this._self, this._then);

  final _SystemMetricsSnapshot _self;
  final $Res Function(_SystemMetricsSnapshot) _then;

/// Create a copy of SystemMetricsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metrics = null,Object? diskBytesPerSec = null,Object? networkBytesPerSec = null,}) {
  return _then(_SystemMetricsSnapshot(
metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as SystemMetrics,diskBytesPerSec: null == diskBytesPerSec ? _self.diskBytesPerSec : diskBytesPerSec // ignore: cast_nullable_to_non_nullable
as double,networkBytesPerSec: null == networkBytesPerSec ? _self.networkBytesPerSec : networkBytesPerSec // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of SystemMetricsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SystemMetricsCopyWith<$Res> get metrics {
  
  return $SystemMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}

// dart format on
