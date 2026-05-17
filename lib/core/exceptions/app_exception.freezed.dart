// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppException {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppException);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppException()';
}


}

/// @nodoc
class $AppExceptionCopyWith<$Res>  {
$AppExceptionCopyWith(AppException _, $Res Function(AppException) __);
}


/// Adds pattern-matching-related methods to [AppException].
extension AppExceptionPatterns on AppException {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( InvariantViolation value)?  invariant,TResult Function( RepositoryNotFound value)?  repositoryNotFound,TResult Function( ClaudeNotFound value)?  claudeNotFound,TResult Function( PersistenceFailure value)?  persistenceFailure,TResult Function( ProcessFailure value)?  processFailure,TResult Function( GitNotFound value)?  gitNotFound,TResult Function( GitCommandFailure value)?  gitCommandFailure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case InvariantViolation() when invariant != null:
return invariant(_that);case RepositoryNotFound() when repositoryNotFound != null:
return repositoryNotFound(_that);case ClaudeNotFound() when claudeNotFound != null:
return claudeNotFound(_that);case PersistenceFailure() when persistenceFailure != null:
return persistenceFailure(_that);case ProcessFailure() when processFailure != null:
return processFailure(_that);case GitNotFound() when gitNotFound != null:
return gitNotFound(_that);case GitCommandFailure() when gitCommandFailure != null:
return gitCommandFailure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( InvariantViolation value)  invariant,required TResult Function( RepositoryNotFound value)  repositoryNotFound,required TResult Function( ClaudeNotFound value)  claudeNotFound,required TResult Function( PersistenceFailure value)  persistenceFailure,required TResult Function( ProcessFailure value)  processFailure,required TResult Function( GitNotFound value)  gitNotFound,required TResult Function( GitCommandFailure value)  gitCommandFailure,}){
final _that = this;
switch (_that) {
case InvariantViolation():
return invariant(_that);case RepositoryNotFound():
return repositoryNotFound(_that);case ClaudeNotFound():
return claudeNotFound(_that);case PersistenceFailure():
return persistenceFailure(_that);case ProcessFailure():
return processFailure(_that);case GitNotFound():
return gitNotFound(_that);case GitCommandFailure():
return gitCommandFailure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( InvariantViolation value)?  invariant,TResult? Function( RepositoryNotFound value)?  repositoryNotFound,TResult? Function( ClaudeNotFound value)?  claudeNotFound,TResult? Function( PersistenceFailure value)?  persistenceFailure,TResult? Function( ProcessFailure value)?  processFailure,TResult? Function( GitNotFound value)?  gitNotFound,TResult? Function( GitCommandFailure value)?  gitCommandFailure,}){
final _that = this;
switch (_that) {
case InvariantViolation() when invariant != null:
return invariant(_that);case RepositoryNotFound() when repositoryNotFound != null:
return repositoryNotFound(_that);case ClaudeNotFound() when claudeNotFound != null:
return claudeNotFound(_that);case PersistenceFailure() when persistenceFailure != null:
return persistenceFailure(_that);case ProcessFailure() when processFailure != null:
return processFailure(_that);case GitNotFound() when gitNotFound != null:
return gitNotFound(_that);case GitCommandFailure() when gitCommandFailure != null:
return gitCommandFailure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message)?  invariant,TResult Function( String path)?  repositoryNotFound,TResult Function()?  claudeNotFound,TResult Function( String message)?  persistenceFailure,TResult Function( String message)?  processFailure,TResult Function()?  gitNotFound,TResult Function( String message)?  gitCommandFailure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case InvariantViolation() when invariant != null:
return invariant(_that.message);case RepositoryNotFound() when repositoryNotFound != null:
return repositoryNotFound(_that.path);case ClaudeNotFound() when claudeNotFound != null:
return claudeNotFound();case PersistenceFailure() when persistenceFailure != null:
return persistenceFailure(_that.message);case ProcessFailure() when processFailure != null:
return processFailure(_that.message);case GitNotFound() when gitNotFound != null:
return gitNotFound();case GitCommandFailure() when gitCommandFailure != null:
return gitCommandFailure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message)  invariant,required TResult Function( String path)  repositoryNotFound,required TResult Function()  claudeNotFound,required TResult Function( String message)  persistenceFailure,required TResult Function( String message)  processFailure,required TResult Function()  gitNotFound,required TResult Function( String message)  gitCommandFailure,}) {final _that = this;
switch (_that) {
case InvariantViolation():
return invariant(_that.message);case RepositoryNotFound():
return repositoryNotFound(_that.path);case ClaudeNotFound():
return claudeNotFound();case PersistenceFailure():
return persistenceFailure(_that.message);case ProcessFailure():
return processFailure(_that.message);case GitNotFound():
return gitNotFound();case GitCommandFailure():
return gitCommandFailure(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message)?  invariant,TResult? Function( String path)?  repositoryNotFound,TResult? Function()?  claudeNotFound,TResult? Function( String message)?  persistenceFailure,TResult? Function( String message)?  processFailure,TResult? Function()?  gitNotFound,TResult? Function( String message)?  gitCommandFailure,}) {final _that = this;
switch (_that) {
case InvariantViolation() when invariant != null:
return invariant(_that.message);case RepositoryNotFound() when repositoryNotFound != null:
return repositoryNotFound(_that.path);case ClaudeNotFound() when claudeNotFound != null:
return claudeNotFound();case PersistenceFailure() when persistenceFailure != null:
return persistenceFailure(_that.message);case ProcessFailure() when processFailure != null:
return processFailure(_that.message);case GitNotFound() when gitNotFound != null:
return gitNotFound();case GitCommandFailure() when gitCommandFailure != null:
return gitCommandFailure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class InvariantViolation implements AppException {
  const InvariantViolation(this.message);
  

 final  String message;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvariantViolationCopyWith<InvariantViolation> get copyWith => _$InvariantViolationCopyWithImpl<InvariantViolation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvariantViolation&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppException.invariant(message: $message)';
}


}

/// @nodoc
abstract mixin class $InvariantViolationCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $InvariantViolationCopyWith(InvariantViolation value, $Res Function(InvariantViolation) _then) = _$InvariantViolationCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$InvariantViolationCopyWithImpl<$Res>
    implements $InvariantViolationCopyWith<$Res> {
  _$InvariantViolationCopyWithImpl(this._self, this._then);

  final InvariantViolation _self;
  final $Res Function(InvariantViolation) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(InvariantViolation(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RepositoryNotFound implements AppException {
  const RepositoryNotFound(this.path);
  

 final  String path;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepositoryNotFoundCopyWith<RepositoryNotFound> get copyWith => _$RepositoryNotFoundCopyWithImpl<RepositoryNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepositoryNotFound&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'AppException.repositoryNotFound(path: $path)';
}


}

/// @nodoc
abstract mixin class $RepositoryNotFoundCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $RepositoryNotFoundCopyWith(RepositoryNotFound value, $Res Function(RepositoryNotFound) _then) = _$RepositoryNotFoundCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$RepositoryNotFoundCopyWithImpl<$Res>
    implements $RepositoryNotFoundCopyWith<$Res> {
  _$RepositoryNotFoundCopyWithImpl(this._self, this._then);

  final RepositoryNotFound _self;
  final $Res Function(RepositoryNotFound) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(RepositoryNotFound(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ClaudeNotFound implements AppException {
  const ClaudeNotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppException.claudeNotFound()';
}


}




/// @nodoc


class PersistenceFailure implements AppException {
  const PersistenceFailure(this.message);
  

 final  String message;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersistenceFailureCopyWith<PersistenceFailure> get copyWith => _$PersistenceFailureCopyWithImpl<PersistenceFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersistenceFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppException.persistenceFailure(message: $message)';
}


}

/// @nodoc
abstract mixin class $PersistenceFailureCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $PersistenceFailureCopyWith(PersistenceFailure value, $Res Function(PersistenceFailure) _then) = _$PersistenceFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PersistenceFailureCopyWithImpl<$Res>
    implements $PersistenceFailureCopyWith<$Res> {
  _$PersistenceFailureCopyWithImpl(this._self, this._then);

  final PersistenceFailure _self;
  final $Res Function(PersistenceFailure) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(PersistenceFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ProcessFailure implements AppException {
  const ProcessFailure(this.message);
  

 final  String message;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessFailureCopyWith<ProcessFailure> get copyWith => _$ProcessFailureCopyWithImpl<ProcessFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppException.processFailure(message: $message)';
}


}

/// @nodoc
abstract mixin class $ProcessFailureCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $ProcessFailureCopyWith(ProcessFailure value, $Res Function(ProcessFailure) _then) = _$ProcessFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ProcessFailureCopyWithImpl<$Res>
    implements $ProcessFailureCopyWith<$Res> {
  _$ProcessFailureCopyWithImpl(this._self, this._then);

  final ProcessFailure _self;
  final $Res Function(ProcessFailure) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ProcessFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GitNotFound implements AppException {
  const GitNotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppException.gitNotFound()';
}


}




/// @nodoc


class GitCommandFailure implements AppException {
  const GitCommandFailure(this.message);
  

 final  String message;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitCommandFailureCopyWith<GitCommandFailure> get copyWith => _$GitCommandFailureCopyWithImpl<GitCommandFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitCommandFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppException.gitCommandFailure(message: $message)';
}


}

/// @nodoc
abstract mixin class $GitCommandFailureCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $GitCommandFailureCopyWith(GitCommandFailure value, $Res Function(GitCommandFailure) _then) = _$GitCommandFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$GitCommandFailureCopyWithImpl<$Res>
    implements $GitCommandFailureCopyWith<$Res> {
  _$GitCommandFailureCopyWithImpl(this._self, this._then);

  final GitCommandFailure _self;
  final $Res Function(GitCommandFailure) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(GitCommandFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
