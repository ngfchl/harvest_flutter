// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crontab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CrontabItem {

 int get id; String get express; String get minute; String get hour;@JsonKey(name: 'day_of_month') String get dayOfMonth;@JsonKey(name: 'month_of_year') String get monthOfYear;@JsonKey(name: 'day_of_week') String get dayOfWeek;
/// Create a copy of CrontabItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CrontabItemCopyWith<CrontabItem> get copyWith => _$CrontabItemCopyWithImpl<CrontabItem>(this as CrontabItem, _$identity);

  /// Serializes this CrontabItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CrontabItem&&(identical(other.id, id) || other.id == id)&&(identical(other.express, express) || other.express == express)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.monthOfYear, monthOfYear) || other.monthOfYear == monthOfYear)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,express,minute,hour,dayOfMonth,monthOfYear,dayOfWeek);

@override
String toString() {
  return 'CrontabItem(id: $id, express: $express, minute: $minute, hour: $hour, dayOfMonth: $dayOfMonth, monthOfYear: $monthOfYear, dayOfWeek: $dayOfWeek)';
}


}

/// @nodoc
abstract mixin class $CrontabItemCopyWith<$Res>  {
  factory $CrontabItemCopyWith(CrontabItem value, $Res Function(CrontabItem) _then) = _$CrontabItemCopyWithImpl;
@useResult
$Res call({
 int id, String express, String minute, String hour,@JsonKey(name: 'day_of_month') String dayOfMonth,@JsonKey(name: 'month_of_year') String monthOfYear,@JsonKey(name: 'day_of_week') String dayOfWeek
});




}
/// @nodoc
class _$CrontabItemCopyWithImpl<$Res>
    implements $CrontabItemCopyWith<$Res> {
  _$CrontabItemCopyWithImpl(this._self, this._then);

  final CrontabItem _self;
  final $Res Function(CrontabItem) _then;

/// Create a copy of CrontabItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? express = null,Object? minute = null,Object? hour = null,Object? dayOfMonth = null,Object? monthOfYear = null,Object? dayOfWeek = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,express: null == express ? _self.express : express // ignore: cast_nullable_to_non_nullable
as String,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as String,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as String,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as String,monthOfYear: null == monthOfYear ? _self.monthOfYear : monthOfYear // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CrontabItem].
extension CrontabItemPatterns on CrontabItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CrontabItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CrontabItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CrontabItem value)  $default,){
final _that = this;
switch (_that) {
case _CrontabItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CrontabItem value)?  $default,){
final _that = this;
switch (_that) {
case _CrontabItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String express,  String minute,  String hour, @JsonKey(name: 'day_of_month')  String dayOfMonth, @JsonKey(name: 'month_of_year')  String monthOfYear, @JsonKey(name: 'day_of_week')  String dayOfWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CrontabItem() when $default != null:
return $default(_that.id,_that.express,_that.minute,_that.hour,_that.dayOfMonth,_that.monthOfYear,_that.dayOfWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String express,  String minute,  String hour, @JsonKey(name: 'day_of_month')  String dayOfMonth, @JsonKey(name: 'month_of_year')  String monthOfYear, @JsonKey(name: 'day_of_week')  String dayOfWeek)  $default,) {final _that = this;
switch (_that) {
case _CrontabItem():
return $default(_that.id,_that.express,_that.minute,_that.hour,_that.dayOfMonth,_that.monthOfYear,_that.dayOfWeek);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String express,  String minute,  String hour, @JsonKey(name: 'day_of_month')  String dayOfMonth, @JsonKey(name: 'month_of_year')  String monthOfYear, @JsonKey(name: 'day_of_week')  String dayOfWeek)?  $default,) {final _that = this;
switch (_that) {
case _CrontabItem() when $default != null:
return $default(_that.id,_that.express,_that.minute,_that.hour,_that.dayOfMonth,_that.monthOfYear,_that.dayOfWeek);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CrontabItem extends CrontabItem {
  const _CrontabItem({required this.id, required this.express, required this.minute, required this.hour, @JsonKey(name: 'day_of_month') this.dayOfMonth = '*', @JsonKey(name: 'month_of_year') this.monthOfYear = '*', @JsonKey(name: 'day_of_week') this.dayOfWeek = '*'}): super._();
  factory _CrontabItem.fromJson(Map<String, dynamic> json) => _$CrontabItemFromJson(json);

@override final  int id;
@override final  String express;
@override final  String minute;
@override final  String hour;
@override@JsonKey(name: 'day_of_month') final  String dayOfMonth;
@override@JsonKey(name: 'month_of_year') final  String monthOfYear;
@override@JsonKey(name: 'day_of_week') final  String dayOfWeek;

/// Create a copy of CrontabItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CrontabItemCopyWith<_CrontabItem> get copyWith => __$CrontabItemCopyWithImpl<_CrontabItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CrontabItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CrontabItem&&(identical(other.id, id) || other.id == id)&&(identical(other.express, express) || other.express == express)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.monthOfYear, monthOfYear) || other.monthOfYear == monthOfYear)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,express,minute,hour,dayOfMonth,monthOfYear,dayOfWeek);

@override
String toString() {
  return 'CrontabItem(id: $id, express: $express, minute: $minute, hour: $hour, dayOfMonth: $dayOfMonth, monthOfYear: $monthOfYear, dayOfWeek: $dayOfWeek)';
}


}

/// @nodoc
abstract mixin class _$CrontabItemCopyWith<$Res> implements $CrontabItemCopyWith<$Res> {
  factory _$CrontabItemCopyWith(_CrontabItem value, $Res Function(_CrontabItem) _then) = __$CrontabItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String express, String minute, String hour,@JsonKey(name: 'day_of_month') String dayOfMonth,@JsonKey(name: 'month_of_year') String monthOfYear,@JsonKey(name: 'day_of_week') String dayOfWeek
});




}
/// @nodoc
class __$CrontabItemCopyWithImpl<$Res>
    implements _$CrontabItemCopyWith<$Res> {
  __$CrontabItemCopyWithImpl(this._self, this._then);

  final _CrontabItem _self;
  final $Res Function(_CrontabItem) _then;

/// Create a copy of CrontabItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? express = null,Object? minute = null,Object? hour = null,Object? dayOfMonth = null,Object? monthOfYear = null,Object? dayOfWeek = null,}) {
  return _then(_CrontabItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,express: null == express ? _self.express : express // ignore: cast_nullable_to_non_nullable
as String,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as String,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as String,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as String,monthOfYear: null == monthOfYear ? _self.monthOfYear : monthOfYear // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
