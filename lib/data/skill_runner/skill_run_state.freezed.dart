// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skill_run_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SkillRunState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillRunState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SkillRunState()';
}


}

/// @nodoc
class $SkillRunStateCopyWith<$Res>  {
$SkillRunStateCopyWith(SkillRunState _, $Res Function(SkillRunState) __);
}


/// Adds pattern-matching-related methods to [SkillRunState].
extension SkillRunStatePatterns on SkillRunState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SkillRunIdle value)?  idle,TResult Function( SkillRunStarting value)?  starting,TResult Function( SkillRunRunning value)?  running,TResult Function( SkillRunWaitingInput value)?  waitingInput,TResult Function( SkillRunCompleted value)?  completed,TResult Function( SkillRunFailed value)?  failed,TResult Function( SkillRunCancelled value)?  cancelled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SkillRunIdle() when idle != null:
return idle(_that);case SkillRunStarting() when starting != null:
return starting(_that);case SkillRunRunning() when running != null:
return running(_that);case SkillRunWaitingInput() when waitingInput != null:
return waitingInput(_that);case SkillRunCompleted() when completed != null:
return completed(_that);case SkillRunFailed() when failed != null:
return failed(_that);case SkillRunCancelled() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SkillRunIdle value)  idle,required TResult Function( SkillRunStarting value)  starting,required TResult Function( SkillRunRunning value)  running,required TResult Function( SkillRunWaitingInput value)  waitingInput,required TResult Function( SkillRunCompleted value)  completed,required TResult Function( SkillRunFailed value)  failed,required TResult Function( SkillRunCancelled value)  cancelled,}){
final _that = this;
switch (_that) {
case SkillRunIdle():
return idle(_that);case SkillRunStarting():
return starting(_that);case SkillRunRunning():
return running(_that);case SkillRunWaitingInput():
return waitingInput(_that);case SkillRunCompleted():
return completed(_that);case SkillRunFailed():
return failed(_that);case SkillRunCancelled():
return cancelled(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SkillRunIdle value)?  idle,TResult? Function( SkillRunStarting value)?  starting,TResult? Function( SkillRunRunning value)?  running,TResult? Function( SkillRunWaitingInput value)?  waitingInput,TResult? Function( SkillRunCompleted value)?  completed,TResult? Function( SkillRunFailed value)?  failed,TResult? Function( SkillRunCancelled value)?  cancelled,}){
final _that = this;
switch (_that) {
case SkillRunIdle() when idle != null:
return idle(_that);case SkillRunStarting() when starting != null:
return starting(_that);case SkillRunRunning() when running != null:
return running(_that);case SkillRunWaitingInput() when waitingInput != null:
return waitingInput(_that);case SkillRunCompleted() when completed != null:
return completed(_that);case SkillRunFailed() when failed != null:
return failed(_that);case SkillRunCancelled() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  starting,TResult Function()?  running,TResult Function()?  waitingInput,TResult Function( int exitCode)?  completed,TResult Function( String message)?  failed,TResult Function()?  cancelled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SkillRunIdle() when idle != null:
return idle();case SkillRunStarting() when starting != null:
return starting();case SkillRunRunning() when running != null:
return running();case SkillRunWaitingInput() when waitingInput != null:
return waitingInput();case SkillRunCompleted() when completed != null:
return completed(_that.exitCode);case SkillRunFailed() when failed != null:
return failed(_that.message);case SkillRunCancelled() when cancelled != null:
return cancelled();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  starting,required TResult Function()  running,required TResult Function()  waitingInput,required TResult Function( int exitCode)  completed,required TResult Function( String message)  failed,required TResult Function()  cancelled,}) {final _that = this;
switch (_that) {
case SkillRunIdle():
return idle();case SkillRunStarting():
return starting();case SkillRunRunning():
return running();case SkillRunWaitingInput():
return waitingInput();case SkillRunCompleted():
return completed(_that.exitCode);case SkillRunFailed():
return failed(_that.message);case SkillRunCancelled():
return cancelled();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  starting,TResult? Function()?  running,TResult? Function()?  waitingInput,TResult? Function( int exitCode)?  completed,TResult? Function( String message)?  failed,TResult? Function()?  cancelled,}) {final _that = this;
switch (_that) {
case SkillRunIdle() when idle != null:
return idle();case SkillRunStarting() when starting != null:
return starting();case SkillRunRunning() when running != null:
return running();case SkillRunWaitingInput() when waitingInput != null:
return waitingInput();case SkillRunCompleted() when completed != null:
return completed(_that.exitCode);case SkillRunFailed() when failed != null:
return failed(_that.message);case SkillRunCancelled() when cancelled != null:
return cancelled();case _:
  return null;

}
}

}

/// @nodoc


class SkillRunIdle implements SkillRunState {
  const SkillRunIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillRunIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SkillRunState.idle()';
}


}




/// @nodoc


class SkillRunStarting implements SkillRunState {
  const SkillRunStarting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillRunStarting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SkillRunState.starting()';
}


}




/// @nodoc


class SkillRunRunning implements SkillRunState {
  const SkillRunRunning();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillRunRunning);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SkillRunState.running()';
}


}




/// @nodoc


class SkillRunWaitingInput implements SkillRunState {
  const SkillRunWaitingInput();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillRunWaitingInput);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SkillRunState.waitingInput()';
}


}




/// @nodoc


class SkillRunCompleted implements SkillRunState {
  const SkillRunCompleted(this.exitCode);
  

 final  int exitCode;

/// Create a copy of SkillRunState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkillRunCompletedCopyWith<SkillRunCompleted> get copyWith => _$SkillRunCompletedCopyWithImpl<SkillRunCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillRunCompleted&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode));
}


@override
int get hashCode => Object.hash(runtimeType,exitCode);

@override
String toString() {
  return 'SkillRunState.completed(exitCode: $exitCode)';
}


}

/// @nodoc
abstract mixin class $SkillRunCompletedCopyWith<$Res> implements $SkillRunStateCopyWith<$Res> {
  factory $SkillRunCompletedCopyWith(SkillRunCompleted value, $Res Function(SkillRunCompleted) _then) = _$SkillRunCompletedCopyWithImpl;
@useResult
$Res call({
 int exitCode
});




}
/// @nodoc
class _$SkillRunCompletedCopyWithImpl<$Res>
    implements $SkillRunCompletedCopyWith<$Res> {
  _$SkillRunCompletedCopyWithImpl(this._self, this._then);

  final SkillRunCompleted _self;
  final $Res Function(SkillRunCompleted) _then;

/// Create a copy of SkillRunState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exitCode = null,}) {
  return _then(SkillRunCompleted(
null == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SkillRunFailed implements SkillRunState {
  const SkillRunFailed(this.message);
  

 final  String message;

/// Create a copy of SkillRunState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkillRunFailedCopyWith<SkillRunFailed> get copyWith => _$SkillRunFailedCopyWithImpl<SkillRunFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillRunFailed&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SkillRunState.failed(message: $message)';
}


}

/// @nodoc
abstract mixin class $SkillRunFailedCopyWith<$Res> implements $SkillRunStateCopyWith<$Res> {
  factory $SkillRunFailedCopyWith(SkillRunFailed value, $Res Function(SkillRunFailed) _then) = _$SkillRunFailedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SkillRunFailedCopyWithImpl<$Res>
    implements $SkillRunFailedCopyWith<$Res> {
  _$SkillRunFailedCopyWithImpl(this._self, this._then);

  final SkillRunFailed _self;
  final $Res Function(SkillRunFailed) _then;

/// Create a copy of SkillRunState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SkillRunFailed(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SkillRunCancelled implements SkillRunState {
  const SkillRunCancelled();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillRunCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SkillRunState.cancelled()';
}


}




// dart format on
