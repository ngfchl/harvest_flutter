// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Schedule {

 int get id; String get name; String get task; String get description;@JsonKey(name: 'crontab_id') int? get crontabId; CrontabItem? get crontab; String get args; String get kwargs; bool get enabled;
/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleCopyWith<Schedule> get copyWith => _$ScheduleCopyWithImpl<Schedule>(this as Schedule, _$identity);

  /// Serializes this Schedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Schedule&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.task, task) || other.task == task)&&(identical(other.description, description) || other.description == description)&&(identical(other.crontabId, crontabId) || other.crontabId == crontabId)&&(identical(other.crontab, crontab) || other.crontab == crontab)&&(identical(other.args, args) || other.args == args)&&(identical(other.kwargs, kwargs) || other.kwargs == kwargs)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,task,description,crontabId,crontab,args,kwargs,enabled);

@override
String toString() {
  return 'Schedule(id: $id, name: $name, task: $task, description: $description, crontabId: $crontabId, crontab: $crontab, args: $args, kwargs: $kwargs, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $ScheduleCopyWith<$Res>  {
  factory $ScheduleCopyWith(Schedule value, $Res Function(Schedule) _then) = _$ScheduleCopyWithImpl;
@useResult
$Res call({
 int id, String name, String task, String description,@JsonKey(name: 'crontab_id') int? crontabId, CrontabItem? crontab, String args, String kwargs, bool enabled
});


$CrontabItemCopyWith<$Res>? get crontab;

}
/// @nodoc
class _$ScheduleCopyWithImpl<$Res>
    implements $ScheduleCopyWith<$Res> {
  _$ScheduleCopyWithImpl(this._self, this._then);

  final Schedule _self;
  final $Res Function(Schedule) _then;

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? task = null,Object? description = null,Object? crontabId = freezed,Object? crontab = freezed,Object? args = null,Object? kwargs = null,Object? enabled = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,crontabId: freezed == crontabId ? _self.crontabId : crontabId // ignore: cast_nullable_to_non_nullable
as int?,crontab: freezed == crontab ? _self.crontab : crontab // ignore: cast_nullable_to_non_nullable
as CrontabItem?,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as String,kwargs: null == kwargs ? _self.kwargs : kwargs // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CrontabItemCopyWith<$Res>? get crontab {
    if (_self.crontab == null) {
    return null;
  }

  return $CrontabItemCopyWith<$Res>(_self.crontab!, (value) {
    return _then(_self.copyWith(crontab: value));
  });
}
}


/// Adds pattern-matching-related methods to [Schedule].
extension SchedulePatterns on Schedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Schedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Schedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Schedule value)  $default,){
final _that = this;
switch (_that) {
case _Schedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Schedule value)?  $default,){
final _that = this;
switch (_that) {
case _Schedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String task,  String description, @JsonKey(name: 'crontab_id')  int? crontabId,  CrontabItem? crontab,  String args,  String kwargs,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Schedule() when $default != null:
return $default(_that.id,_that.name,_that.task,_that.description,_that.crontabId,_that.crontab,_that.args,_that.kwargs,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String task,  String description, @JsonKey(name: 'crontab_id')  int? crontabId,  CrontabItem? crontab,  String args,  String kwargs,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _Schedule():
return $default(_that.id,_that.name,_that.task,_that.description,_that.crontabId,_that.crontab,_that.args,_that.kwargs,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String task,  String description, @JsonKey(name: 'crontab_id')  int? crontabId,  CrontabItem? crontab,  String args,  String kwargs,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _Schedule() when $default != null:
return $default(_that.id,_that.name,_that.task,_that.description,_that.crontabId,_that.crontab,_that.args,_that.kwargs,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Schedule extends Schedule {
  const _Schedule({required this.id, this.name = '', this.task = '', this.description = '', @JsonKey(name: 'crontab_id') this.crontabId, this.crontab, this.args = '[]', this.kwargs = '{}', this.enabled = true}): super._();
  factory _Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

@override final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String task;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'crontab_id') final  int? crontabId;
@override final  CrontabItem? crontab;
@override@JsonKey() final  String args;
@override@JsonKey() final  String kwargs;
@override@JsonKey() final  bool enabled;

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleCopyWith<_Schedule> get copyWith => __$ScheduleCopyWithImpl<_Schedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Schedule&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.task, task) || other.task == task)&&(identical(other.description, description) || other.description == description)&&(identical(other.crontabId, crontabId) || other.crontabId == crontabId)&&(identical(other.crontab, crontab) || other.crontab == crontab)&&(identical(other.args, args) || other.args == args)&&(identical(other.kwargs, kwargs) || other.kwargs == kwargs)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,task,description,crontabId,crontab,args,kwargs,enabled);

@override
String toString() {
  return 'Schedule(id: $id, name: $name, task: $task, description: $description, crontabId: $crontabId, crontab: $crontab, args: $args, kwargs: $kwargs, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$ScheduleCopyWith<$Res> implements $ScheduleCopyWith<$Res> {
  factory _$ScheduleCopyWith(_Schedule value, $Res Function(_Schedule) _then) = __$ScheduleCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String task, String description,@JsonKey(name: 'crontab_id') int? crontabId, CrontabItem? crontab, String args, String kwargs, bool enabled
});


@override $CrontabItemCopyWith<$Res>? get crontab;

}
/// @nodoc
class __$ScheduleCopyWithImpl<$Res>
    implements _$ScheduleCopyWith<$Res> {
  __$ScheduleCopyWithImpl(this._self, this._then);

  final _Schedule _self;
  final $Res Function(_Schedule) _then;

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? task = null,Object? description = null,Object? crontabId = freezed,Object? crontab = freezed,Object? args = null,Object? kwargs = null,Object? enabled = null,}) {
  return _then(_Schedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,crontabId: freezed == crontabId ? _self.crontabId : crontabId // ignore: cast_nullable_to_non_nullable
as int?,crontab: freezed == crontab ? _self.crontab : crontab // ignore: cast_nullable_to_non_nullable
as CrontabItem?,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as String,kwargs: null == kwargs ? _self.kwargs : kwargs // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CrontabItemCopyWith<$Res>? get crontab {
    if (_self.crontab == null) {
    return null;
  }

  return $CrontabItemCopyWith<$Res>(_self.crontab!, (value) {
    return _then(_self.copyWith(crontab: value));
  });
}
}

// dart format on
