// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SystemSnapshot {

/// コアごとの累積 tick `[user, system, idle, nice]`。取得不可なら null。
 List<List<int>>? get cpuTicks;/// 使用中メモリ（bytes）。
 int get memoryUsedBytes;/// 物理メモリ総容量（bytes）。
 int get memoryTotalBytes;/// スワップ（ページファイル）使用量 / 容量（bytes）。
 int? get swapUsedBytes; int? get swapTotalBytes;/// ディスク読み込み / 書き込みの累積バイト。
 int? get diskReadBytes; int? get diskWriteBytes;/// 物理ネットワーク IF ごとの累積バイト。
 List<NetInterfaceCounters> get netInterfaces;/// ロードアベレージ `[1 分, 5 分, 15 分]`。macOS のみ。
 List<double>? get loadAverage;/// 起動からの経過秒数。
 int? get uptimeSeconds;
/// Create a copy of SystemSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemSnapshotCopyWith<SystemSnapshot> get copyWith => _$SystemSnapshotCopyWithImpl<SystemSnapshot>(this as SystemSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemSnapshot&&const DeepCollectionEquality().equals(other.cpuTicks, cpuTicks)&&(identical(other.memoryUsedBytes, memoryUsedBytes) || other.memoryUsedBytes == memoryUsedBytes)&&(identical(other.memoryTotalBytes, memoryTotalBytes) || other.memoryTotalBytes == memoryTotalBytes)&&(identical(other.swapUsedBytes, swapUsedBytes) || other.swapUsedBytes == swapUsedBytes)&&(identical(other.swapTotalBytes, swapTotalBytes) || other.swapTotalBytes == swapTotalBytes)&&(identical(other.diskReadBytes, diskReadBytes) || other.diskReadBytes == diskReadBytes)&&(identical(other.diskWriteBytes, diskWriteBytes) || other.diskWriteBytes == diskWriteBytes)&&const DeepCollectionEquality().equals(other.netInterfaces, netInterfaces)&&const DeepCollectionEquality().equals(other.loadAverage, loadAverage)&&(identical(other.uptimeSeconds, uptimeSeconds) || other.uptimeSeconds == uptimeSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(cpuTicks),memoryUsedBytes,memoryTotalBytes,swapUsedBytes,swapTotalBytes,diskReadBytes,diskWriteBytes,const DeepCollectionEquality().hash(netInterfaces),const DeepCollectionEquality().hash(loadAverage),uptimeSeconds);

@override
String toString() {
  return 'SystemSnapshot(cpuTicks: $cpuTicks, memoryUsedBytes: $memoryUsedBytes, memoryTotalBytes: $memoryTotalBytes, swapUsedBytes: $swapUsedBytes, swapTotalBytes: $swapTotalBytes, diskReadBytes: $diskReadBytes, diskWriteBytes: $diskWriteBytes, netInterfaces: $netInterfaces, loadAverage: $loadAverage, uptimeSeconds: $uptimeSeconds)';
}


}

/// @nodoc
abstract mixin class $SystemSnapshotCopyWith<$Res>  {
  factory $SystemSnapshotCopyWith(SystemSnapshot value, $Res Function(SystemSnapshot) _then) = _$SystemSnapshotCopyWithImpl;
@useResult
$Res call({
 List<List<int>>? cpuTicks, int memoryUsedBytes, int memoryTotalBytes, int? swapUsedBytes, int? swapTotalBytes, int? diskReadBytes, int? diskWriteBytes, List<NetInterfaceCounters> netInterfaces, List<double>? loadAverage, int? uptimeSeconds
});




}
/// @nodoc
class _$SystemSnapshotCopyWithImpl<$Res>
    implements $SystemSnapshotCopyWith<$Res> {
  _$SystemSnapshotCopyWithImpl(this._self, this._then);

  final SystemSnapshot _self;
  final $Res Function(SystemSnapshot) _then;

/// Create a copy of SystemSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cpuTicks = freezed,Object? memoryUsedBytes = null,Object? memoryTotalBytes = null,Object? swapUsedBytes = freezed,Object? swapTotalBytes = freezed,Object? diskReadBytes = freezed,Object? diskWriteBytes = freezed,Object? netInterfaces = null,Object? loadAverage = freezed,Object? uptimeSeconds = freezed,}) {
  return _then(_self.copyWith(
cpuTicks: freezed == cpuTicks ? _self.cpuTicks : cpuTicks // ignore: cast_nullable_to_non_nullable
as List<List<int>>?,memoryUsedBytes: null == memoryUsedBytes ? _self.memoryUsedBytes : memoryUsedBytes // ignore: cast_nullable_to_non_nullable
as int,memoryTotalBytes: null == memoryTotalBytes ? _self.memoryTotalBytes : memoryTotalBytes // ignore: cast_nullable_to_non_nullable
as int,swapUsedBytes: freezed == swapUsedBytes ? _self.swapUsedBytes : swapUsedBytes // ignore: cast_nullable_to_non_nullable
as int?,swapTotalBytes: freezed == swapTotalBytes ? _self.swapTotalBytes : swapTotalBytes // ignore: cast_nullable_to_non_nullable
as int?,diskReadBytes: freezed == diskReadBytes ? _self.diskReadBytes : diskReadBytes // ignore: cast_nullable_to_non_nullable
as int?,diskWriteBytes: freezed == diskWriteBytes ? _self.diskWriteBytes : diskWriteBytes // ignore: cast_nullable_to_non_nullable
as int?,netInterfaces: null == netInterfaces ? _self.netInterfaces : netInterfaces // ignore: cast_nullable_to_non_nullable
as List<NetInterfaceCounters>,loadAverage: freezed == loadAverage ? _self.loadAverage : loadAverage // ignore: cast_nullable_to_non_nullable
as List<double>?,uptimeSeconds: freezed == uptimeSeconds ? _self.uptimeSeconds : uptimeSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SystemSnapshot].
extension SystemSnapshotPatterns on SystemSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SystemSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SystemSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _SystemSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SystemSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _SystemSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<List<int>>? cpuTicks,  int memoryUsedBytes,  int memoryTotalBytes,  int? swapUsedBytes,  int? swapTotalBytes,  int? diskReadBytes,  int? diskWriteBytes,  List<NetInterfaceCounters> netInterfaces,  List<double>? loadAverage,  int? uptimeSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemSnapshot() when $default != null:
return $default(_that.cpuTicks,_that.memoryUsedBytes,_that.memoryTotalBytes,_that.swapUsedBytes,_that.swapTotalBytes,_that.diskReadBytes,_that.diskWriteBytes,_that.netInterfaces,_that.loadAverage,_that.uptimeSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<List<int>>? cpuTicks,  int memoryUsedBytes,  int memoryTotalBytes,  int? swapUsedBytes,  int? swapTotalBytes,  int? diskReadBytes,  int? diskWriteBytes,  List<NetInterfaceCounters> netInterfaces,  List<double>? loadAverage,  int? uptimeSeconds)  $default,) {final _that = this;
switch (_that) {
case _SystemSnapshot():
return $default(_that.cpuTicks,_that.memoryUsedBytes,_that.memoryTotalBytes,_that.swapUsedBytes,_that.swapTotalBytes,_that.diskReadBytes,_that.diskWriteBytes,_that.netInterfaces,_that.loadAverage,_that.uptimeSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<List<int>>? cpuTicks,  int memoryUsedBytes,  int memoryTotalBytes,  int? swapUsedBytes,  int? swapTotalBytes,  int? diskReadBytes,  int? diskWriteBytes,  List<NetInterfaceCounters> netInterfaces,  List<double>? loadAverage,  int? uptimeSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SystemSnapshot() when $default != null:
return $default(_that.cpuTicks,_that.memoryUsedBytes,_that.memoryTotalBytes,_that.swapUsedBytes,_that.swapTotalBytes,_that.diskReadBytes,_that.diskWriteBytes,_that.netInterfaces,_that.loadAverage,_that.uptimeSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _SystemSnapshot extends SystemSnapshot {
  const _SystemSnapshot({final  List<List<int>>? cpuTicks, required this.memoryUsedBytes, required this.memoryTotalBytes, this.swapUsedBytes, this.swapTotalBytes, this.diskReadBytes, this.diskWriteBytes, final  List<NetInterfaceCounters> netInterfaces = const <NetInterfaceCounters>[], final  List<double>? loadAverage, this.uptimeSeconds}): _cpuTicks = cpuTicks,_netInterfaces = netInterfaces,_loadAverage = loadAverage,super._();
  

/// コアごとの累積 tick `[user, system, idle, nice]`。取得不可なら null。
 final  List<List<int>>? _cpuTicks;
/// コアごとの累積 tick `[user, system, idle, nice]`。取得不可なら null。
@override List<List<int>>? get cpuTicks {
  final value = _cpuTicks;
  if (value == null) return null;
  if (_cpuTicks is EqualUnmodifiableListView) return _cpuTicks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// 使用中メモリ（bytes）。
@override final  int memoryUsedBytes;
/// 物理メモリ総容量（bytes）。
@override final  int memoryTotalBytes;
/// スワップ（ページファイル）使用量 / 容量（bytes）。
@override final  int? swapUsedBytes;
@override final  int? swapTotalBytes;
/// ディスク読み込み / 書き込みの累積バイト。
@override final  int? diskReadBytes;
@override final  int? diskWriteBytes;
/// 物理ネットワーク IF ごとの累積バイト。
 final  List<NetInterfaceCounters> _netInterfaces;
/// 物理ネットワーク IF ごとの累積バイト。
@override@JsonKey() List<NetInterfaceCounters> get netInterfaces {
  if (_netInterfaces is EqualUnmodifiableListView) return _netInterfaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_netInterfaces);
}

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

/// 起動からの経過秒数。
@override final  int? uptimeSeconds;

/// Create a copy of SystemSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemSnapshotCopyWith<_SystemSnapshot> get copyWith => __$SystemSnapshotCopyWithImpl<_SystemSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemSnapshot&&const DeepCollectionEquality().equals(other._cpuTicks, _cpuTicks)&&(identical(other.memoryUsedBytes, memoryUsedBytes) || other.memoryUsedBytes == memoryUsedBytes)&&(identical(other.memoryTotalBytes, memoryTotalBytes) || other.memoryTotalBytes == memoryTotalBytes)&&(identical(other.swapUsedBytes, swapUsedBytes) || other.swapUsedBytes == swapUsedBytes)&&(identical(other.swapTotalBytes, swapTotalBytes) || other.swapTotalBytes == swapTotalBytes)&&(identical(other.diskReadBytes, diskReadBytes) || other.diskReadBytes == diskReadBytes)&&(identical(other.diskWriteBytes, diskWriteBytes) || other.diskWriteBytes == diskWriteBytes)&&const DeepCollectionEquality().equals(other._netInterfaces, _netInterfaces)&&const DeepCollectionEquality().equals(other._loadAverage, _loadAverage)&&(identical(other.uptimeSeconds, uptimeSeconds) || other.uptimeSeconds == uptimeSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cpuTicks),memoryUsedBytes,memoryTotalBytes,swapUsedBytes,swapTotalBytes,diskReadBytes,diskWriteBytes,const DeepCollectionEquality().hash(_netInterfaces),const DeepCollectionEquality().hash(_loadAverage),uptimeSeconds);

@override
String toString() {
  return 'SystemSnapshot(cpuTicks: $cpuTicks, memoryUsedBytes: $memoryUsedBytes, memoryTotalBytes: $memoryTotalBytes, swapUsedBytes: $swapUsedBytes, swapTotalBytes: $swapTotalBytes, diskReadBytes: $diskReadBytes, diskWriteBytes: $diskWriteBytes, netInterfaces: $netInterfaces, loadAverage: $loadAverage, uptimeSeconds: $uptimeSeconds)';
}


}

/// @nodoc
abstract mixin class _$SystemSnapshotCopyWith<$Res> implements $SystemSnapshotCopyWith<$Res> {
  factory _$SystemSnapshotCopyWith(_SystemSnapshot value, $Res Function(_SystemSnapshot) _then) = __$SystemSnapshotCopyWithImpl;
@override @useResult
$Res call({
 List<List<int>>? cpuTicks, int memoryUsedBytes, int memoryTotalBytes, int? swapUsedBytes, int? swapTotalBytes, int? diskReadBytes, int? diskWriteBytes, List<NetInterfaceCounters> netInterfaces, List<double>? loadAverage, int? uptimeSeconds
});




}
/// @nodoc
class __$SystemSnapshotCopyWithImpl<$Res>
    implements _$SystemSnapshotCopyWith<$Res> {
  __$SystemSnapshotCopyWithImpl(this._self, this._then);

  final _SystemSnapshot _self;
  final $Res Function(_SystemSnapshot) _then;

/// Create a copy of SystemSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cpuTicks = freezed,Object? memoryUsedBytes = null,Object? memoryTotalBytes = null,Object? swapUsedBytes = freezed,Object? swapTotalBytes = freezed,Object? diskReadBytes = freezed,Object? diskWriteBytes = freezed,Object? netInterfaces = null,Object? loadAverage = freezed,Object? uptimeSeconds = freezed,}) {
  return _then(_SystemSnapshot(
cpuTicks: freezed == cpuTicks ? _self._cpuTicks : cpuTicks // ignore: cast_nullable_to_non_nullable
as List<List<int>>?,memoryUsedBytes: null == memoryUsedBytes ? _self.memoryUsedBytes : memoryUsedBytes // ignore: cast_nullable_to_non_nullable
as int,memoryTotalBytes: null == memoryTotalBytes ? _self.memoryTotalBytes : memoryTotalBytes // ignore: cast_nullable_to_non_nullable
as int,swapUsedBytes: freezed == swapUsedBytes ? _self.swapUsedBytes : swapUsedBytes // ignore: cast_nullable_to_non_nullable
as int?,swapTotalBytes: freezed == swapTotalBytes ? _self.swapTotalBytes : swapTotalBytes // ignore: cast_nullable_to_non_nullable
as int?,diskReadBytes: freezed == diskReadBytes ? _self.diskReadBytes : diskReadBytes // ignore: cast_nullable_to_non_nullable
as int?,diskWriteBytes: freezed == diskWriteBytes ? _self.diskWriteBytes : diskWriteBytes // ignore: cast_nullable_to_non_nullable
as int?,netInterfaces: null == netInterfaces ? _self._netInterfaces : netInterfaces // ignore: cast_nullable_to_non_nullable
as List<NetInterfaceCounters>,loadAverage: freezed == loadAverage ? _self._loadAverage : loadAverage // ignore: cast_nullable_to_non_nullable
as List<double>?,uptimeSeconds: freezed == uptimeSeconds ? _self.uptimeSeconds : uptimeSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$NetInterfaceCounters {

 String get name; int get rxBytes; int get txBytes;
/// Create a copy of NetInterfaceCounters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetInterfaceCountersCopyWith<NetInterfaceCounters> get copyWith => _$NetInterfaceCountersCopyWithImpl<NetInterfaceCounters>(this as NetInterfaceCounters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetInterfaceCounters&&(identical(other.name, name) || other.name == name)&&(identical(other.rxBytes, rxBytes) || other.rxBytes == rxBytes)&&(identical(other.txBytes, txBytes) || other.txBytes == txBytes));
}


@override
int get hashCode => Object.hash(runtimeType,name,rxBytes,txBytes);

@override
String toString() {
  return 'NetInterfaceCounters(name: $name, rxBytes: $rxBytes, txBytes: $txBytes)';
}


}

/// @nodoc
abstract mixin class $NetInterfaceCountersCopyWith<$Res>  {
  factory $NetInterfaceCountersCopyWith(NetInterfaceCounters value, $Res Function(NetInterfaceCounters) _then) = _$NetInterfaceCountersCopyWithImpl;
@useResult
$Res call({
 String name, int rxBytes, int txBytes
});




}
/// @nodoc
class _$NetInterfaceCountersCopyWithImpl<$Res>
    implements $NetInterfaceCountersCopyWith<$Res> {
  _$NetInterfaceCountersCopyWithImpl(this._self, this._then);

  final NetInterfaceCounters _self;
  final $Res Function(NetInterfaceCounters) _then;

/// Create a copy of NetInterfaceCounters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? rxBytes = null,Object? txBytes = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rxBytes: null == rxBytes ? _self.rxBytes : rxBytes // ignore: cast_nullable_to_non_nullable
as int,txBytes: null == txBytes ? _self.txBytes : txBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NetInterfaceCounters].
extension NetInterfaceCountersPatterns on NetInterfaceCounters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetInterfaceCounters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetInterfaceCounters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetInterfaceCounters value)  $default,){
final _that = this;
switch (_that) {
case _NetInterfaceCounters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetInterfaceCounters value)?  $default,){
final _that = this;
switch (_that) {
case _NetInterfaceCounters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int rxBytes,  int txBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetInterfaceCounters() when $default != null:
return $default(_that.name,_that.rxBytes,_that.txBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int rxBytes,  int txBytes)  $default,) {final _that = this;
switch (_that) {
case _NetInterfaceCounters():
return $default(_that.name,_that.rxBytes,_that.txBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int rxBytes,  int txBytes)?  $default,) {final _that = this;
switch (_that) {
case _NetInterfaceCounters() when $default != null:
return $default(_that.name,_that.rxBytes,_that.txBytes);case _:
  return null;

}
}

}

/// @nodoc


class _NetInterfaceCounters implements NetInterfaceCounters {
  const _NetInterfaceCounters({required this.name, required this.rxBytes, required this.txBytes});
  

@override final  String name;
@override final  int rxBytes;
@override final  int txBytes;

/// Create a copy of NetInterfaceCounters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetInterfaceCountersCopyWith<_NetInterfaceCounters> get copyWith => __$NetInterfaceCountersCopyWithImpl<_NetInterfaceCounters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetInterfaceCounters&&(identical(other.name, name) || other.name == name)&&(identical(other.rxBytes, rxBytes) || other.rxBytes == rxBytes)&&(identical(other.txBytes, txBytes) || other.txBytes == txBytes));
}


@override
int get hashCode => Object.hash(runtimeType,name,rxBytes,txBytes);

@override
String toString() {
  return 'NetInterfaceCounters(name: $name, rxBytes: $rxBytes, txBytes: $txBytes)';
}


}

/// @nodoc
abstract mixin class _$NetInterfaceCountersCopyWith<$Res> implements $NetInterfaceCountersCopyWith<$Res> {
  factory _$NetInterfaceCountersCopyWith(_NetInterfaceCounters value, $Res Function(_NetInterfaceCounters) _then) = __$NetInterfaceCountersCopyWithImpl;
@override @useResult
$Res call({
 String name, int rxBytes, int txBytes
});




}
/// @nodoc
class __$NetInterfaceCountersCopyWithImpl<$Res>
    implements _$NetInterfaceCountersCopyWith<$Res> {
  __$NetInterfaceCountersCopyWithImpl(this._self, this._then);

  final _NetInterfaceCounters _self;
  final $Res Function(_NetInterfaceCounters) _then;

/// Create a copy of NetInterfaceCounters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? rxBytes = null,Object? txBytes = null,}) {
  return _then(_NetInterfaceCounters(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rxBytes: null == rxBytes ? _self.rxBytes : rxBytes // ignore: cast_nullable_to_non_nullable
as int,txBytes: null == txBytes ? _self.txBytes : txBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
