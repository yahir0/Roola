// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'process_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProcessMetrics {

/// プロセス ID。
 int get pid;/// プロセス名（実行ファイルの basename）。
 String get name;/// CPU 使用率（%）。マルチコアでは 100 を超えうる。
 double get cpuPercent;/// 常駐メモリ（RSS, bytes）。
 int get memoryBytes;/// I/O レート（B/s）。ディスク / ネットワーク ソート時のみ意味を持つ。
 int get ioBytesPerSec;
/// Create a copy of ProcessMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessMetricsCopyWith<ProcessMetrics> get copyWith => _$ProcessMetricsCopyWithImpl<ProcessMetrics>(this as ProcessMetrics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessMetrics&&(identical(other.pid, pid) || other.pid == pid)&&(identical(other.name, name) || other.name == name)&&(identical(other.cpuPercent, cpuPercent) || other.cpuPercent == cpuPercent)&&(identical(other.memoryBytes, memoryBytes) || other.memoryBytes == memoryBytes)&&(identical(other.ioBytesPerSec, ioBytesPerSec) || other.ioBytesPerSec == ioBytesPerSec));
}


@override
int get hashCode => Object.hash(runtimeType,pid,name,cpuPercent,memoryBytes,ioBytesPerSec);

@override
String toString() {
  return 'ProcessMetrics(pid: $pid, name: $name, cpuPercent: $cpuPercent, memoryBytes: $memoryBytes, ioBytesPerSec: $ioBytesPerSec)';
}


}

/// @nodoc
abstract mixin class $ProcessMetricsCopyWith<$Res>  {
  factory $ProcessMetricsCopyWith(ProcessMetrics value, $Res Function(ProcessMetrics) _then) = _$ProcessMetricsCopyWithImpl;
@useResult
$Res call({
 int pid, String name, double cpuPercent, int memoryBytes, int ioBytesPerSec
});




}
/// @nodoc
class _$ProcessMetricsCopyWithImpl<$Res>
    implements $ProcessMetricsCopyWith<$Res> {
  _$ProcessMetricsCopyWithImpl(this._self, this._then);

  final ProcessMetrics _self;
  final $Res Function(ProcessMetrics) _then;

/// Create a copy of ProcessMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pid = null,Object? name = null,Object? cpuPercent = null,Object? memoryBytes = null,Object? ioBytesPerSec = null,}) {
  return _then(_self.copyWith(
pid: null == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cpuPercent: null == cpuPercent ? _self.cpuPercent : cpuPercent // ignore: cast_nullable_to_non_nullable
as double,memoryBytes: null == memoryBytes ? _self.memoryBytes : memoryBytes // ignore: cast_nullable_to_non_nullable
as int,ioBytesPerSec: null == ioBytesPerSec ? _self.ioBytesPerSec : ioBytesPerSec // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProcessMetrics].
extension ProcessMetricsPatterns on ProcessMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProcessMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProcessMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProcessMetrics value)  $default,){
final _that = this;
switch (_that) {
case _ProcessMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProcessMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _ProcessMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pid,  String name,  double cpuPercent,  int memoryBytes,  int ioBytesPerSec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProcessMetrics() when $default != null:
return $default(_that.pid,_that.name,_that.cpuPercent,_that.memoryBytes,_that.ioBytesPerSec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pid,  String name,  double cpuPercent,  int memoryBytes,  int ioBytesPerSec)  $default,) {final _that = this;
switch (_that) {
case _ProcessMetrics():
return $default(_that.pid,_that.name,_that.cpuPercent,_that.memoryBytes,_that.ioBytesPerSec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pid,  String name,  double cpuPercent,  int memoryBytes,  int ioBytesPerSec)?  $default,) {final _that = this;
switch (_that) {
case _ProcessMetrics() when $default != null:
return $default(_that.pid,_that.name,_that.cpuPercent,_that.memoryBytes,_that.ioBytesPerSec);case _:
  return null;

}
}

}

/// @nodoc


class _ProcessMetrics implements ProcessMetrics {
  const _ProcessMetrics({required this.pid, required this.name, this.cpuPercent = 0, this.memoryBytes = 0, this.ioBytesPerSec = 0});
  

/// プロセス ID。
@override final  int pid;
/// プロセス名（実行ファイルの basename）。
@override final  String name;
/// CPU 使用率（%）。マルチコアでは 100 を超えうる。
@override@JsonKey() final  double cpuPercent;
/// 常駐メモリ（RSS, bytes）。
@override@JsonKey() final  int memoryBytes;
/// I/O レート（B/s）。ディスク / ネットワーク ソート時のみ意味を持つ。
@override@JsonKey() final  int ioBytesPerSec;

/// Create a copy of ProcessMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessMetricsCopyWith<_ProcessMetrics> get copyWith => __$ProcessMetricsCopyWithImpl<_ProcessMetrics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProcessMetrics&&(identical(other.pid, pid) || other.pid == pid)&&(identical(other.name, name) || other.name == name)&&(identical(other.cpuPercent, cpuPercent) || other.cpuPercent == cpuPercent)&&(identical(other.memoryBytes, memoryBytes) || other.memoryBytes == memoryBytes)&&(identical(other.ioBytesPerSec, ioBytesPerSec) || other.ioBytesPerSec == ioBytesPerSec));
}


@override
int get hashCode => Object.hash(runtimeType,pid,name,cpuPercent,memoryBytes,ioBytesPerSec);

@override
String toString() {
  return 'ProcessMetrics(pid: $pid, name: $name, cpuPercent: $cpuPercent, memoryBytes: $memoryBytes, ioBytesPerSec: $ioBytesPerSec)';
}


}

/// @nodoc
abstract mixin class _$ProcessMetricsCopyWith<$Res> implements $ProcessMetricsCopyWith<$Res> {
  factory _$ProcessMetricsCopyWith(_ProcessMetrics value, $Res Function(_ProcessMetrics) _then) = __$ProcessMetricsCopyWithImpl;
@override @useResult
$Res call({
 int pid, String name, double cpuPercent, int memoryBytes, int ioBytesPerSec
});




}
/// @nodoc
class __$ProcessMetricsCopyWithImpl<$Res>
    implements _$ProcessMetricsCopyWith<$Res> {
  __$ProcessMetricsCopyWithImpl(this._self, this._then);

  final _ProcessMetrics _self;
  final $Res Function(_ProcessMetrics) _then;

/// Create a copy of ProcessMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pid = null,Object? name = null,Object? cpuPercent = null,Object? memoryBytes = null,Object? ioBytesPerSec = null,}) {
  return _then(_ProcessMetrics(
pid: null == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cpuPercent: null == cpuPercent ? _self.cpuPercent : cpuPercent // ignore: cast_nullable_to_non_nullable
as double,memoryBytes: null == memoryBytes ? _self.memoryBytes : memoryBytes // ignore: cast_nullable_to_non_nullable
as int,ioBytesPerSec: null == ioBytesPerSec ? _self.ioBytesPerSec : ioBytesPerSec // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
