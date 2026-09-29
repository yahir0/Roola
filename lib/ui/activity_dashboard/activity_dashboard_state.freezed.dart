// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivityDashboardState {

/// CPU 使用率（0–1）。差分が取れるまでは null。
 double? get cpu;/// コア別 CPU 使用率（0–1）。取得できない環境では空。
 List<double> get cores;/// 論理コア数（ロードアベレージの満点に使う）。不明なら 0。
 int get coreCount; int get memoryUsedBytes; int get memoryTotalBytes; int? get swapUsedBytes; int? get swapTotalBytes;/// ディスク読み込み / 書き込み（B/s）。
 double? get diskReadRate; double? get diskWriteRate;/// ネットワーク受信 / 送信（B/s）。
 double? get netRxRate; double? get netTxRate;/// ロードアベレージ `[1 分, 5 分, 15 分]`。macOS のみ。
 List<double>? get loadAverage; int? get uptimeSeconds;
/// Create a copy of ActivityDashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityDashboardStateCopyWith<ActivityDashboardState> get copyWith => _$ActivityDashboardStateCopyWithImpl<ActivityDashboardState>(this as ActivityDashboardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityDashboardState&&(identical(other.cpu, cpu) || other.cpu == cpu)&&const DeepCollectionEquality().equals(other.cores, cores)&&(identical(other.coreCount, coreCount) || other.coreCount == coreCount)&&(identical(other.memoryUsedBytes, memoryUsedBytes) || other.memoryUsedBytes == memoryUsedBytes)&&(identical(other.memoryTotalBytes, memoryTotalBytes) || other.memoryTotalBytes == memoryTotalBytes)&&(identical(other.swapUsedBytes, swapUsedBytes) || other.swapUsedBytes == swapUsedBytes)&&(identical(other.swapTotalBytes, swapTotalBytes) || other.swapTotalBytes == swapTotalBytes)&&(identical(other.diskReadRate, diskReadRate) || other.diskReadRate == diskReadRate)&&(identical(other.diskWriteRate, diskWriteRate) || other.diskWriteRate == diskWriteRate)&&(identical(other.netRxRate, netRxRate) || other.netRxRate == netRxRate)&&(identical(other.netTxRate, netTxRate) || other.netTxRate == netTxRate)&&const DeepCollectionEquality().equals(other.loadAverage, loadAverage)&&(identical(other.uptimeSeconds, uptimeSeconds) || other.uptimeSeconds == uptimeSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,cpu,const DeepCollectionEquality().hash(cores),coreCount,memoryUsedBytes,memoryTotalBytes,swapUsedBytes,swapTotalBytes,diskReadRate,diskWriteRate,netRxRate,netTxRate,const DeepCollectionEquality().hash(loadAverage),uptimeSeconds);

@override
String toString() {
  return 'ActivityDashboardState(cpu: $cpu, cores: $cores, coreCount: $coreCount, memoryUsedBytes: $memoryUsedBytes, memoryTotalBytes: $memoryTotalBytes, swapUsedBytes: $swapUsedBytes, swapTotalBytes: $swapTotalBytes, diskReadRate: $diskReadRate, diskWriteRate: $diskWriteRate, netRxRate: $netRxRate, netTxRate: $netTxRate, loadAverage: $loadAverage, uptimeSeconds: $uptimeSeconds)';
}


}

/// @nodoc
abstract mixin class $ActivityDashboardStateCopyWith<$Res>  {
  factory $ActivityDashboardStateCopyWith(ActivityDashboardState value, $Res Function(ActivityDashboardState) _then) = _$ActivityDashboardStateCopyWithImpl;
@useResult
$Res call({
 double? cpu, List<double> cores, int coreCount, int memoryUsedBytes, int memoryTotalBytes, int? swapUsedBytes, int? swapTotalBytes, double? diskReadRate, double? diskWriteRate, double? netRxRate, double? netTxRate, List<double>? loadAverage, int? uptimeSeconds
});




}
/// @nodoc
class _$ActivityDashboardStateCopyWithImpl<$Res>
    implements $ActivityDashboardStateCopyWith<$Res> {
  _$ActivityDashboardStateCopyWithImpl(this._self, this._then);

  final ActivityDashboardState _self;
  final $Res Function(ActivityDashboardState) _then;

/// Create a copy of ActivityDashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cpu = freezed,Object? cores = null,Object? coreCount = null,Object? memoryUsedBytes = null,Object? memoryTotalBytes = null,Object? swapUsedBytes = freezed,Object? swapTotalBytes = freezed,Object? diskReadRate = freezed,Object? diskWriteRate = freezed,Object? netRxRate = freezed,Object? netTxRate = freezed,Object? loadAverage = freezed,Object? uptimeSeconds = freezed,}) {
  return _then(_self.copyWith(
cpu: freezed == cpu ? _self.cpu : cpu // ignore: cast_nullable_to_non_nullable
as double?,cores: null == cores ? _self.cores : cores // ignore: cast_nullable_to_non_nullable
as List<double>,coreCount: null == coreCount ? _self.coreCount : coreCount // ignore: cast_nullable_to_non_nullable
as int,memoryUsedBytes: null == memoryUsedBytes ? _self.memoryUsedBytes : memoryUsedBytes // ignore: cast_nullable_to_non_nullable
as int,memoryTotalBytes: null == memoryTotalBytes ? _self.memoryTotalBytes : memoryTotalBytes // ignore: cast_nullable_to_non_nullable
as int,swapUsedBytes: freezed == swapUsedBytes ? _self.swapUsedBytes : swapUsedBytes // ignore: cast_nullable_to_non_nullable
as int?,swapTotalBytes: freezed == swapTotalBytes ? _self.swapTotalBytes : swapTotalBytes // ignore: cast_nullable_to_non_nullable
as int?,diskReadRate: freezed == diskReadRate ? _self.diskReadRate : diskReadRate // ignore: cast_nullable_to_non_nullable
as double?,diskWriteRate: freezed == diskWriteRate ? _self.diskWriteRate : diskWriteRate // ignore: cast_nullable_to_non_nullable
as double?,netRxRate: freezed == netRxRate ? _self.netRxRate : netRxRate // ignore: cast_nullable_to_non_nullable
as double?,netTxRate: freezed == netTxRate ? _self.netTxRate : netTxRate // ignore: cast_nullable_to_non_nullable
as double?,loadAverage: freezed == loadAverage ? _self.loadAverage : loadAverage // ignore: cast_nullable_to_non_nullable
as List<double>?,uptimeSeconds: freezed == uptimeSeconds ? _self.uptimeSeconds : uptimeSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityDashboardState].
extension ActivityDashboardStatePatterns on ActivityDashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityDashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityDashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityDashboardState value)  $default,){
final _that = this;
switch (_that) {
case _ActivityDashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityDashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityDashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? cpu,  List<double> cores,  int coreCount,  int memoryUsedBytes,  int memoryTotalBytes,  int? swapUsedBytes,  int? swapTotalBytes,  double? diskReadRate,  double? diskWriteRate,  double? netRxRate,  double? netTxRate,  List<double>? loadAverage,  int? uptimeSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityDashboardState() when $default != null:
return $default(_that.cpu,_that.cores,_that.coreCount,_that.memoryUsedBytes,_that.memoryTotalBytes,_that.swapUsedBytes,_that.swapTotalBytes,_that.diskReadRate,_that.diskWriteRate,_that.netRxRate,_that.netTxRate,_that.loadAverage,_that.uptimeSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? cpu,  List<double> cores,  int coreCount,  int memoryUsedBytes,  int memoryTotalBytes,  int? swapUsedBytes,  int? swapTotalBytes,  double? diskReadRate,  double? diskWriteRate,  double? netRxRate,  double? netTxRate,  List<double>? loadAverage,  int? uptimeSeconds)  $default,) {final _that = this;
switch (_that) {
case _ActivityDashboardState():
return $default(_that.cpu,_that.cores,_that.coreCount,_that.memoryUsedBytes,_that.memoryTotalBytes,_that.swapUsedBytes,_that.swapTotalBytes,_that.diskReadRate,_that.diskWriteRate,_that.netRxRate,_that.netTxRate,_that.loadAverage,_that.uptimeSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? cpu,  List<double> cores,  int coreCount,  int memoryUsedBytes,  int memoryTotalBytes,  int? swapUsedBytes,  int? swapTotalBytes,  double? diskReadRate,  double? diskWriteRate,  double? netRxRate,  double? netTxRate,  List<double>? loadAverage,  int? uptimeSeconds)?  $default,) {final _that = this;
switch (_that) {
case _ActivityDashboardState() when $default != null:
return $default(_that.cpu,_that.cores,_that.coreCount,_that.memoryUsedBytes,_that.memoryTotalBytes,_that.swapUsedBytes,_that.swapTotalBytes,_that.diskReadRate,_that.diskWriteRate,_that.netRxRate,_that.netTxRate,_that.loadAverage,_that.uptimeSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityDashboardState extends ActivityDashboardState {
  const _ActivityDashboardState({this.cpu, final  List<double> cores = const <double>[], this.coreCount = 0, this.memoryUsedBytes = 0, this.memoryTotalBytes = 0, this.swapUsedBytes, this.swapTotalBytes, this.diskReadRate, this.diskWriteRate, this.netRxRate, this.netTxRate, final  List<double>? loadAverage, this.uptimeSeconds}): _cores = cores,_loadAverage = loadAverage,super._();
  

/// CPU 使用率（0–1）。差分が取れるまでは null。
@override final  double? cpu;
/// コア別 CPU 使用率（0–1）。取得できない環境では空。
 final  List<double> _cores;
/// コア別 CPU 使用率（0–1）。取得できない環境では空。
@override@JsonKey() List<double> get cores {
  if (_cores is EqualUnmodifiableListView) return _cores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cores);
}

/// 論理コア数（ロードアベレージの満点に使う）。不明なら 0。
@override@JsonKey() final  int coreCount;
@override@JsonKey() final  int memoryUsedBytes;
@override@JsonKey() final  int memoryTotalBytes;
@override final  int? swapUsedBytes;
@override final  int? swapTotalBytes;
/// ディスク読み込み / 書き込み（B/s）。
@override final  double? diskReadRate;
@override final  double? diskWriteRate;
/// ネットワーク受信 / 送信（B/s）。
@override final  double? netRxRate;
@override final  double? netTxRate;
/// ロードアベレージ `[1 分, 5 分, 15 分]`。macOS のみ。
 final  List<double>? _loadAverage;
/// ロードアベレージ `[1 分, 5 分, 15 分]`。macOS のみ。
@override List<double>? get loadAverage {
  final value = _loadAverage;
  if (value == null) return null;
  if (_loadAverage is EqualUnmodifiableListView) return _loadAverage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? uptimeSeconds;

/// Create a copy of ActivityDashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityDashboardStateCopyWith<_ActivityDashboardState> get copyWith => __$ActivityDashboardStateCopyWithImpl<_ActivityDashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityDashboardState&&(identical(other.cpu, cpu) || other.cpu == cpu)&&const DeepCollectionEquality().equals(other._cores, _cores)&&(identical(other.coreCount, coreCount) || other.coreCount == coreCount)&&(identical(other.memoryUsedBytes, memoryUsedBytes) || other.memoryUsedBytes == memoryUsedBytes)&&(identical(other.memoryTotalBytes, memoryTotalBytes) || other.memoryTotalBytes == memoryTotalBytes)&&(identical(other.swapUsedBytes, swapUsedBytes) || other.swapUsedBytes == swapUsedBytes)&&(identical(other.swapTotalBytes, swapTotalBytes) || other.swapTotalBytes == swapTotalBytes)&&(identical(other.diskReadRate, diskReadRate) || other.diskReadRate == diskReadRate)&&(identical(other.diskWriteRate, diskWriteRate) || other.diskWriteRate == diskWriteRate)&&(identical(other.netRxRate, netRxRate) || other.netRxRate == netRxRate)&&(identical(other.netTxRate, netTxRate) || other.netTxRate == netTxRate)&&const DeepCollectionEquality().equals(other._loadAverage, _loadAverage)&&(identical(other.uptimeSeconds, uptimeSeconds) || other.uptimeSeconds == uptimeSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,cpu,const DeepCollectionEquality().hash(_cores),coreCount,memoryUsedBytes,memoryTotalBytes,swapUsedBytes,swapTotalBytes,diskReadRate,diskWriteRate,netRxRate,netTxRate,const DeepCollectionEquality().hash(_loadAverage),uptimeSeconds);

@override
String toString() {
  return 'ActivityDashboardState(cpu: $cpu, cores: $cores, coreCount: $coreCount, memoryUsedBytes: $memoryUsedBytes, memoryTotalBytes: $memoryTotalBytes, swapUsedBytes: $swapUsedBytes, swapTotalBytes: $swapTotalBytes, diskReadRate: $diskReadRate, diskWriteRate: $diskWriteRate, netRxRate: $netRxRate, netTxRate: $netTxRate, loadAverage: $loadAverage, uptimeSeconds: $uptimeSeconds)';
}


}

/// @nodoc
abstract mixin class _$ActivityDashboardStateCopyWith<$Res> implements $ActivityDashboardStateCopyWith<$Res> {
  factory _$ActivityDashboardStateCopyWith(_ActivityDashboardState value, $Res Function(_ActivityDashboardState) _then) = __$ActivityDashboardStateCopyWithImpl;
@override @useResult
$Res call({
 double? cpu, List<double> cores, int coreCount, int memoryUsedBytes, int memoryTotalBytes, int? swapUsedBytes, int? swapTotalBytes, double? diskReadRate, double? diskWriteRate, double? netRxRate, double? netTxRate, List<double>? loadAverage, int? uptimeSeconds
});




}
/// @nodoc
class __$ActivityDashboardStateCopyWithImpl<$Res>
    implements _$ActivityDashboardStateCopyWith<$Res> {
  __$ActivityDashboardStateCopyWithImpl(this._self, this._then);

  final _ActivityDashboardState _self;
  final $Res Function(_ActivityDashboardState) _then;

/// Create a copy of ActivityDashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cpu = freezed,Object? cores = null,Object? coreCount = null,Object? memoryUsedBytes = null,Object? memoryTotalBytes = null,Object? swapUsedBytes = freezed,Object? swapTotalBytes = freezed,Object? diskReadRate = freezed,Object? diskWriteRate = freezed,Object? netRxRate = freezed,Object? netTxRate = freezed,Object? loadAverage = freezed,Object? uptimeSeconds = freezed,}) {
  return _then(_ActivityDashboardState(
cpu: freezed == cpu ? _self.cpu : cpu // ignore: cast_nullable_to_non_nullable
as double?,cores: null == cores ? _self._cores : cores // ignore: cast_nullable_to_non_nullable
as List<double>,coreCount: null == coreCount ? _self.coreCount : coreCount // ignore: cast_nullable_to_non_nullable
as int,memoryUsedBytes: null == memoryUsedBytes ? _self.memoryUsedBytes : memoryUsedBytes // ignore: cast_nullable_to_non_nullable
as int,memoryTotalBytes: null == memoryTotalBytes ? _self.memoryTotalBytes : memoryTotalBytes // ignore: cast_nullable_to_non_nullable
as int,swapUsedBytes: freezed == swapUsedBytes ? _self.swapUsedBytes : swapUsedBytes // ignore: cast_nullable_to_non_nullable
as int?,swapTotalBytes: freezed == swapTotalBytes ? _self.swapTotalBytes : swapTotalBytes // ignore: cast_nullable_to_non_nullable
as int?,diskReadRate: freezed == diskReadRate ? _self.diskReadRate : diskReadRate // ignore: cast_nullable_to_non_nullable
as double?,diskWriteRate: freezed == diskWriteRate ? _self.diskWriteRate : diskWriteRate // ignore: cast_nullable_to_non_nullable
as double?,netRxRate: freezed == netRxRate ? _self.netRxRate : netRxRate // ignore: cast_nullable_to_non_nullable
as double?,netTxRate: freezed == netTxRate ? _self.netTxRate : netTxRate // ignore: cast_nullable_to_non_nullable
as double?,loadAverage: freezed == loadAverage ? _self._loadAverage : loadAverage // ignore: cast_nullable_to_non_nullable
as List<double>?,uptimeSeconds: freezed == uptimeSeconds ? _self.uptimeSeconds : uptimeSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
