// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'option_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OptionState {

 List<Option> get options; bool get isLoading; String? get error;
/// Create a copy of OptionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OptionStateCopyWith<OptionState> get copyWith => _$OptionStateCopyWithImpl<OptionState>(this as OptionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OptionState&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(options),isLoading,error);

@override
String toString() {
  return 'OptionState(options: $options, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $OptionStateCopyWith<$Res>  {
  factory $OptionStateCopyWith(OptionState value, $Res Function(OptionState) _then) = _$OptionStateCopyWithImpl;
@useResult
$Res call({
 List<Option> options, bool isLoading, String? error
});




}
/// @nodoc
class _$OptionStateCopyWithImpl<$Res>
    implements $OptionStateCopyWith<$Res> {
  _$OptionStateCopyWithImpl(this._self, this._then);

  final OptionState _self;
  final $Res Function(OptionState) _then;

/// Create a copy of OptionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? options = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<Option>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OptionState].
extension OptionStatePatterns on OptionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OptionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OptionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OptionState value)  $default,){
final _that = this;
switch (_that) {
case _OptionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OptionState value)?  $default,){
final _that = this;
switch (_that) {
case _OptionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Option> options,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OptionState() when $default != null:
return $default(_that.options,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Option> options,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _OptionState():
return $default(_that.options,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Option> options,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _OptionState() when $default != null:
return $default(_that.options,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _OptionState extends OptionState {
  const _OptionState({final  List<Option> options = const [], this.isLoading = false, this.error}): _options = options,super._();
  

 final  List<Option> _options;
@override@JsonKey() List<Option> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of OptionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OptionStateCopyWith<_OptionState> get copyWith => __$OptionStateCopyWithImpl<_OptionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OptionState&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_options),isLoading,error);

@override
String toString() {
  return 'OptionState(options: $options, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$OptionStateCopyWith<$Res> implements $OptionStateCopyWith<$Res> {
  factory _$OptionStateCopyWith(_OptionState value, $Res Function(_OptionState) _then) = __$OptionStateCopyWithImpl;
@override @useResult
$Res call({
 List<Option> options, bool isLoading, String? error
});




}
/// @nodoc
class __$OptionStateCopyWithImpl<$Res>
    implements _$OptionStateCopyWith<$Res> {
  __$OptionStateCopyWithImpl(this._self, this._then);

  final _OptionState _self;
  final $Res Function(_OptionState) _then;

/// Create a copy of OptionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? options = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_OptionState(
options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<Option>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
