// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EarliestSite {

 int get id; String get site;@JsonKey(name: 'time_join') String? get timeJoin;@JsonKey(name: 'latest_active') String? get latestActive;
/// Create a copy of EarliestSite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarliestSiteCopyWith<EarliestSite> get copyWith => _$EarliestSiteCopyWithImpl<EarliestSite>(this as EarliestSite, _$identity);

  /// Serializes this EarliestSite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarliestSite&&(identical(other.id, id) || other.id == id)&&(identical(other.site, site) || other.site == site)&&(identical(other.timeJoin, timeJoin) || other.timeJoin == timeJoin)&&(identical(other.latestActive, latestActive) || other.latestActive == latestActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,site,timeJoin,latestActive);

@override
String toString() {
  return 'EarliestSite(id: $id, site: $site, timeJoin: $timeJoin, latestActive: $latestActive)';
}


}

/// @nodoc
abstract mixin class $EarliestSiteCopyWith<$Res>  {
  factory $EarliestSiteCopyWith(EarliestSite value, $Res Function(EarliestSite) _then) = _$EarliestSiteCopyWithImpl;
@useResult
$Res call({
 int id, String site,@JsonKey(name: 'time_join') String? timeJoin,@JsonKey(name: 'latest_active') String? latestActive
});




}
/// @nodoc
class _$EarliestSiteCopyWithImpl<$Res>
    implements $EarliestSiteCopyWith<$Res> {
  _$EarliestSiteCopyWithImpl(this._self, this._then);

  final EarliestSite _self;
  final $Res Function(EarliestSite) _then;

/// Create a copy of EarliestSite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? site = null,Object? timeJoin = freezed,Object? latestActive = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,site: null == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String,timeJoin: freezed == timeJoin ? _self.timeJoin : timeJoin // ignore: cast_nullable_to_non_nullable
as String?,latestActive: freezed == latestActive ? _self.latestActive : latestActive // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EarliestSite].
extension EarliestSitePatterns on EarliestSite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarliestSite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarliestSite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarliestSite value)  $default,){
final _that = this;
switch (_that) {
case _EarliestSite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarliestSite value)?  $default,){
final _that = this;
switch (_that) {
case _EarliestSite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String site, @JsonKey(name: 'time_join')  String? timeJoin, @JsonKey(name: 'latest_active')  String? latestActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarliestSite() when $default != null:
return $default(_that.id,_that.site,_that.timeJoin,_that.latestActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String site, @JsonKey(name: 'time_join')  String? timeJoin, @JsonKey(name: 'latest_active')  String? latestActive)  $default,) {final _that = this;
switch (_that) {
case _EarliestSite():
return $default(_that.id,_that.site,_that.timeJoin,_that.latestActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String site, @JsonKey(name: 'time_join')  String? timeJoin, @JsonKey(name: 'latest_active')  String? latestActive)?  $default,) {final _that = this;
switch (_that) {
case _EarliestSite() when $default != null:
return $default(_that.id,_that.site,_that.timeJoin,_that.latestActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EarliestSite implements EarliestSite {
  const _EarliestSite({this.id = 0, required this.site, @JsonKey(name: 'time_join') this.timeJoin, @JsonKey(name: 'latest_active') this.latestActive});
  factory _EarliestSite.fromJson(Map<String, dynamic> json) => _$EarliestSiteFromJson(json);

@override@JsonKey() final  int id;
@override final  String site;
@override@JsonKey(name: 'time_join') final  String? timeJoin;
@override@JsonKey(name: 'latest_active') final  String? latestActive;

/// Create a copy of EarliestSite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarliestSiteCopyWith<_EarliestSite> get copyWith => __$EarliestSiteCopyWithImpl<_EarliestSite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarliestSiteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarliestSite&&(identical(other.id, id) || other.id == id)&&(identical(other.site, site) || other.site == site)&&(identical(other.timeJoin, timeJoin) || other.timeJoin == timeJoin)&&(identical(other.latestActive, latestActive) || other.latestActive == latestActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,site,timeJoin,latestActive);

@override
String toString() {
  return 'EarliestSite(id: $id, site: $site, timeJoin: $timeJoin, latestActive: $latestActive)';
}


}

/// @nodoc
abstract mixin class _$EarliestSiteCopyWith<$Res> implements $EarliestSiteCopyWith<$Res> {
  factory _$EarliestSiteCopyWith(_EarliestSite value, $Res Function(_EarliestSite) _then) = __$EarliestSiteCopyWithImpl;
@override @useResult
$Res call({
 int id, String site,@JsonKey(name: 'time_join') String? timeJoin,@JsonKey(name: 'latest_active') String? latestActive
});




}
/// @nodoc
class __$EarliestSiteCopyWithImpl<$Res>
    implements _$EarliestSiteCopyWith<$Res> {
  __$EarliestSiteCopyWithImpl(this._self, this._then);

  final _EarliestSite _self;
  final $Res Function(_EarliestSite) _then;

/// Create a copy of EarliestSite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? site = null,Object? timeJoin = freezed,Object? latestActive = freezed,}) {
  return _then(_EarliestSite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,site: null == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String,timeJoin: freezed == timeJoin ? _self.timeJoin : timeJoin // ignore: cast_nullable_to_non_nullable
as String?,latestActive: freezed == latestActive ? _self.latestActive : latestActive // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StatusRecord {

@JsonKey(name: 'created_at') String get createdAt; num get uploaded; num get downloaded; num get published;
/// Create a copy of StatusRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusRecordCopyWith<StatusRecord> get copyWith => _$StatusRecordCopyWithImpl<StatusRecord>(this as StatusRecord, _$identity);

  /// Serializes this StatusRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusRecord&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded)&&(identical(other.published, published) || other.published == published));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,uploaded,downloaded,published);

@override
String toString() {
  return 'StatusRecord(createdAt: $createdAt, uploaded: $uploaded, downloaded: $downloaded, published: $published)';
}


}

/// @nodoc
abstract mixin class $StatusRecordCopyWith<$Res>  {
  factory $StatusRecordCopyWith(StatusRecord value, $Res Function(StatusRecord) _then) = _$StatusRecordCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'created_at') String createdAt, num uploaded, num downloaded, num published
});




}
/// @nodoc
class _$StatusRecordCopyWithImpl<$Res>
    implements $StatusRecordCopyWith<$Res> {
  _$StatusRecordCopyWithImpl(this._self, this._then);

  final StatusRecord _self;
  final $Res Function(StatusRecord) _then;

/// Create a copy of StatusRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? uploaded = null,Object? downloaded = null,Object? published = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,uploaded: null == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as num,downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as num,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusRecord].
extension StatusRecordPatterns on StatusRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusRecord value)  $default,){
final _that = this;
switch (_that) {
case _StatusRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusRecord value)?  $default,){
final _that = this;
switch (_that) {
case _StatusRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'created_at')  String createdAt,  num uploaded,  num downloaded,  num published)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusRecord() when $default != null:
return $default(_that.createdAt,_that.uploaded,_that.downloaded,_that.published);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'created_at')  String createdAt,  num uploaded,  num downloaded,  num published)  $default,) {final _that = this;
switch (_that) {
case _StatusRecord():
return $default(_that.createdAt,_that.uploaded,_that.downloaded,_that.published);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'created_at')  String createdAt,  num uploaded,  num downloaded,  num published)?  $default,) {final _that = this;
switch (_that) {
case _StatusRecord() when $default != null:
return $default(_that.createdAt,_that.uploaded,_that.downloaded,_that.published);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatusRecord implements StatusRecord {
  const _StatusRecord({@JsonKey(name: 'created_at') required this.createdAt, this.uploaded = 0, this.downloaded = 0, this.published = 0});
  factory _StatusRecord.fromJson(Map<String, dynamic> json) => _$StatusRecordFromJson(json);

@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey() final  num uploaded;
@override@JsonKey() final  num downloaded;
@override@JsonKey() final  num published;

/// Create a copy of StatusRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusRecordCopyWith<_StatusRecord> get copyWith => __$StatusRecordCopyWithImpl<_StatusRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusRecord&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded)&&(identical(other.published, published) || other.published == published));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,uploaded,downloaded,published);

@override
String toString() {
  return 'StatusRecord(createdAt: $createdAt, uploaded: $uploaded, downloaded: $downloaded, published: $published)';
}


}

/// @nodoc
abstract mixin class _$StatusRecordCopyWith<$Res> implements $StatusRecordCopyWith<$Res> {
  factory _$StatusRecordCopyWith(_StatusRecord value, $Res Function(_StatusRecord) _then) = __$StatusRecordCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'created_at') String createdAt, num uploaded, num downloaded, num published
});




}
/// @nodoc
class __$StatusRecordCopyWithImpl<$Res>
    implements _$StatusRecordCopyWith<$Res> {
  __$StatusRecordCopyWithImpl(this._self, this._then);

  final _StatusRecord _self;
  final $Res Function(_StatusRecord) _then;

/// Create a copy of StatusRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? uploaded = null,Object? downloaded = null,Object? published = null,}) {
  return _then(_StatusRecord(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,uploaded: null == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as num,downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as num,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$UploadRecord {

@JsonKey(name: 'created_at') String get createdAt; num get uploaded; num get downloaded;
/// Create a copy of UploadRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadRecordCopyWith<UploadRecord> get copyWith => _$UploadRecordCopyWithImpl<UploadRecord>(this as UploadRecord, _$identity);

  /// Serializes this UploadRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadRecord&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,uploaded,downloaded);

@override
String toString() {
  return 'UploadRecord(createdAt: $createdAt, uploaded: $uploaded, downloaded: $downloaded)';
}


}

/// @nodoc
abstract mixin class $UploadRecordCopyWith<$Res>  {
  factory $UploadRecordCopyWith(UploadRecord value, $Res Function(UploadRecord) _then) = _$UploadRecordCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'created_at') String createdAt, num uploaded, num downloaded
});




}
/// @nodoc
class _$UploadRecordCopyWithImpl<$Res>
    implements $UploadRecordCopyWith<$Res> {
  _$UploadRecordCopyWithImpl(this._self, this._then);

  final UploadRecord _self;
  final $Res Function(UploadRecord) _then;

/// Create a copy of UploadRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? uploaded = null,Object? downloaded = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,uploaded: null == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as num,downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadRecord].
extension UploadRecordPatterns on UploadRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadRecord value)  $default,){
final _that = this;
switch (_that) {
case _UploadRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadRecord value)?  $default,){
final _that = this;
switch (_that) {
case _UploadRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'created_at')  String createdAt,  num uploaded,  num downloaded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadRecord() when $default != null:
return $default(_that.createdAt,_that.uploaded,_that.downloaded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'created_at')  String createdAt,  num uploaded,  num downloaded)  $default,) {final _that = this;
switch (_that) {
case _UploadRecord():
return $default(_that.createdAt,_that.uploaded,_that.downloaded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'created_at')  String createdAt,  num uploaded,  num downloaded)?  $default,) {final _that = this;
switch (_that) {
case _UploadRecord() when $default != null:
return $default(_that.createdAt,_that.uploaded,_that.downloaded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadRecord implements UploadRecord {
  const _UploadRecord({@JsonKey(name: 'created_at') required this.createdAt, this.uploaded = 0, this.downloaded = 0});
  factory _UploadRecord.fromJson(Map<String, dynamic> json) => _$UploadRecordFromJson(json);

@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey() final  num uploaded;
@override@JsonKey() final  num downloaded;

/// Create a copy of UploadRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadRecordCopyWith<_UploadRecord> get copyWith => __$UploadRecordCopyWithImpl<_UploadRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadRecord&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,uploaded,downloaded);

@override
String toString() {
  return 'UploadRecord(createdAt: $createdAt, uploaded: $uploaded, downloaded: $downloaded)';
}


}

/// @nodoc
abstract mixin class _$UploadRecordCopyWith<$Res> implements $UploadRecordCopyWith<$Res> {
  factory _$UploadRecordCopyWith(_UploadRecord value, $Res Function(_UploadRecord) _then) = __$UploadRecordCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'created_at') String createdAt, num uploaded, num downloaded
});




}
/// @nodoc
class __$UploadRecordCopyWithImpl<$Res>
    implements _$UploadRecordCopyWith<$Res> {
  __$UploadRecordCopyWithImpl(this._self, this._then);

  final _UploadRecord _self;
  final $Res Function(_UploadRecord) _then;

/// Create a copy of UploadRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? uploaded = null,Object? downloaded = null,}) {
  return _then(_UploadRecord(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,uploaded: null == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as num,downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$MonthSiteData {

 String get name; List<StatusRecord> get value;
/// Create a copy of MonthSiteData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthSiteDataCopyWith<MonthSiteData> get copyWith => _$MonthSiteDataCopyWithImpl<MonthSiteData>(this as MonthSiteData, _$identity);

  /// Serializes this MonthSiteData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthSiteData&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'MonthSiteData(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class $MonthSiteDataCopyWith<$Res>  {
  factory $MonthSiteDataCopyWith(MonthSiteData value, $Res Function(MonthSiteData) _then) = _$MonthSiteDataCopyWithImpl;
@useResult
$Res call({
 String name, List<StatusRecord> value
});




}
/// @nodoc
class _$MonthSiteDataCopyWithImpl<$Res>
    implements $MonthSiteDataCopyWith<$Res> {
  _$MonthSiteDataCopyWithImpl(this._self, this._then);

  final MonthSiteData _self;
  final $Res Function(MonthSiteData) _then;

/// Create a copy of MonthSiteData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as List<StatusRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthSiteData].
extension MonthSiteDataPatterns on MonthSiteData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthSiteData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthSiteData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthSiteData value)  $default,){
final _that = this;
switch (_that) {
case _MonthSiteData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthSiteData value)?  $default,){
final _that = this;
switch (_that) {
case _MonthSiteData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<StatusRecord> value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthSiteData() when $default != null:
return $default(_that.name,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<StatusRecord> value)  $default,) {final _that = this;
switch (_that) {
case _MonthSiteData():
return $default(_that.name,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<StatusRecord> value)?  $default,) {final _that = this;
switch (_that) {
case _MonthSiteData() when $default != null:
return $default(_that.name,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthSiteData implements MonthSiteData {
  const _MonthSiteData({required this.name, final  List<StatusRecord> value = const []}): _value = value;
  factory _MonthSiteData.fromJson(Map<String, dynamic> json) => _$MonthSiteDataFromJson(json);

@override final  String name;
 final  List<StatusRecord> _value;
@override@JsonKey() List<StatusRecord> get value {
  if (_value is EqualUnmodifiableListView) return _value;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_value);
}


/// Create a copy of MonthSiteData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthSiteDataCopyWith<_MonthSiteData> get copyWith => __$MonthSiteDataCopyWithImpl<_MonthSiteData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthSiteDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthSiteData&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._value, _value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_value));

@override
String toString() {
  return 'MonthSiteData(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class _$MonthSiteDataCopyWith<$Res> implements $MonthSiteDataCopyWith<$Res> {
  factory _$MonthSiteDataCopyWith(_MonthSiteData value, $Res Function(_MonthSiteData) _then) = __$MonthSiteDataCopyWithImpl;
@override @useResult
$Res call({
 String name, List<StatusRecord> value
});




}
/// @nodoc
class __$MonthSiteDataCopyWithImpl<$Res>
    implements _$MonthSiteDataCopyWith<$Res> {
  __$MonthSiteDataCopyWithImpl(this._self, this._then);

  final _MonthSiteData _self;
  final $Res Function(_MonthSiteData) _then;

/// Create a copy of MonthSiteData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,}) {
  return _then(_MonthSiteData(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self._value : value // ignore: cast_nullable_to_non_nullable
as List<StatusRecord>,
  ));
}


}


/// @nodoc
mixin _$SiteStatusData {

 String get name; StatusRecord get value;
/// Create a copy of SiteStatusData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteStatusDataCopyWith<SiteStatusData> get copyWith => _$SiteStatusDataCopyWithImpl<SiteStatusData>(this as SiteStatusData, _$identity);

  /// Serializes this SiteStatusData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteStatusData&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'SiteStatusData(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class $SiteStatusDataCopyWith<$Res>  {
  factory $SiteStatusDataCopyWith(SiteStatusData value, $Res Function(SiteStatusData) _then) = _$SiteStatusDataCopyWithImpl;
@useResult
$Res call({
 String name, StatusRecord value
});


$StatusRecordCopyWith<$Res> get value;

}
/// @nodoc
class _$SiteStatusDataCopyWithImpl<$Res>
    implements $SiteStatusDataCopyWith<$Res> {
  _$SiteStatusDataCopyWithImpl(this._self, this._then);

  final SiteStatusData _self;
  final $Res Function(SiteStatusData) _then;

/// Create a copy of SiteStatusData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as StatusRecord,
  ));
}
/// Create a copy of SiteStatusData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatusRecordCopyWith<$Res> get value {
  
  return $StatusRecordCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}


/// Adds pattern-matching-related methods to [SiteStatusData].
extension SiteStatusDataPatterns on SiteStatusData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteStatusData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteStatusData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteStatusData value)  $default,){
final _that = this;
switch (_that) {
case _SiteStatusData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteStatusData value)?  $default,){
final _that = this;
switch (_that) {
case _SiteStatusData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  StatusRecord value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteStatusData() when $default != null:
return $default(_that.name,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  StatusRecord value)  $default,) {final _that = this;
switch (_that) {
case _SiteStatusData():
return $default(_that.name,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  StatusRecord value)?  $default,) {final _that = this;
switch (_that) {
case _SiteStatusData() when $default != null:
return $default(_that.name,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SiteStatusData implements SiteStatusData {
  const _SiteStatusData({required this.name, required this.value});
  factory _SiteStatusData.fromJson(Map<String, dynamic> json) => _$SiteStatusDataFromJson(json);

@override final  String name;
@override final  StatusRecord value;

/// Create a copy of SiteStatusData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteStatusDataCopyWith<_SiteStatusData> get copyWith => __$SiteStatusDataCopyWithImpl<_SiteStatusData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteStatusDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteStatusData&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'SiteStatusData(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class _$SiteStatusDataCopyWith<$Res> implements $SiteStatusDataCopyWith<$Res> {
  factory _$SiteStatusDataCopyWith(_SiteStatusData value, $Res Function(_SiteStatusData) _then) = __$SiteStatusDataCopyWithImpl;
@override @useResult
$Res call({
 String name, StatusRecord value
});


@override $StatusRecordCopyWith<$Res> get value;

}
/// @nodoc
class __$SiteStatusDataCopyWithImpl<$Res>
    implements _$SiteStatusDataCopyWith<$Res> {
  __$SiteStatusDataCopyWithImpl(this._self, this._then);

  final _SiteStatusData _self;
  final $Res Function(_SiteStatusData) _then;

/// Create a copy of SiteStatusData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,}) {
  return _then(_SiteStatusData(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as StatusRecord,
  ));
}

/// Create a copy of SiteStatusData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatusRecordCopyWith<$Res> get value {
  
  return $StatusRecordCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}


/// @nodoc
mixin _$StackSiteData {

 String get name; List<UploadRecord> get value;
/// Create a copy of StackSiteData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StackSiteDataCopyWith<StackSiteData> get copyWith => _$StackSiteDataCopyWithImpl<StackSiteData>(this as StackSiteData, _$identity);

  /// Serializes this StackSiteData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StackSiteData&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'StackSiteData(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class $StackSiteDataCopyWith<$Res>  {
  factory $StackSiteDataCopyWith(StackSiteData value, $Res Function(StackSiteData) _then) = _$StackSiteDataCopyWithImpl;
@useResult
$Res call({
 String name, List<UploadRecord> value
});




}
/// @nodoc
class _$StackSiteDataCopyWithImpl<$Res>
    implements $StackSiteDataCopyWith<$Res> {
  _$StackSiteDataCopyWithImpl(this._self, this._then);

  final StackSiteData _self;
  final $Res Function(StackSiteData) _then;

/// Create a copy of StackSiteData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as List<UploadRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [StackSiteData].
extension StackSiteDataPatterns on StackSiteData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StackSiteData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StackSiteData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StackSiteData value)  $default,){
final _that = this;
switch (_that) {
case _StackSiteData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StackSiteData value)?  $default,){
final _that = this;
switch (_that) {
case _StackSiteData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<UploadRecord> value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StackSiteData() when $default != null:
return $default(_that.name,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<UploadRecord> value)  $default,) {final _that = this;
switch (_that) {
case _StackSiteData():
return $default(_that.name,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<UploadRecord> value)?  $default,) {final _that = this;
switch (_that) {
case _StackSiteData() when $default != null:
return $default(_that.name,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StackSiteData implements StackSiteData {
  const _StackSiteData({required this.name, final  List<UploadRecord> value = const []}): _value = value;
  factory _StackSiteData.fromJson(Map<String, dynamic> json) => _$StackSiteDataFromJson(json);

@override final  String name;
 final  List<UploadRecord> _value;
@override@JsonKey() List<UploadRecord> get value {
  if (_value is EqualUnmodifiableListView) return _value;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_value);
}


/// Create a copy of StackSiteData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StackSiteDataCopyWith<_StackSiteData> get copyWith => __$StackSiteDataCopyWithImpl<_StackSiteData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StackSiteDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StackSiteData&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._value, _value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_value));

@override
String toString() {
  return 'StackSiteData(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class _$StackSiteDataCopyWith<$Res> implements $StackSiteDataCopyWith<$Res> {
  factory _$StackSiteDataCopyWith(_StackSiteData value, $Res Function(_StackSiteData) _then) = __$StackSiteDataCopyWithImpl;
@override @useResult
$Res call({
 String name, List<UploadRecord> value
});




}
/// @nodoc
class __$StackSiteDataCopyWithImpl<$Res>
    implements _$StackSiteDataCopyWith<$Res> {
  __$StackSiteDataCopyWithImpl(this._self, this._then);

  final _StackSiteData _self;
  final $Res Function(_StackSiteData) _then;

/// Create a copy of StackSiteData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,}) {
  return _then(_StackSiteData(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self._value : value // ignore: cast_nullable_to_non_nullable
as List<UploadRecord>,
  ));
}


}


/// @nodoc
mixin _$DashboardData {

 List<KV> get emailCount; List<KV> get usernameCount; num get totalUploaded; num get totalDownloaded; num get totalSeedVol; num get totalSeeding; num get totalLeeching; num get todayUploadIncrement; num get todayDownloadIncrement; num get totalPublished; List<KV> get uploadIncrementDataList; List<KV> get downloadIncrementDataList; List<MonthSiteData> get uploadMonthIncrementDataList; List<SiteStatusData> get statusList; List<StackSiteData> get stackChartDataList; List<KV> get seedDataList; num get siteCount; String? get updatedAt; EarliestSite? get earliestSite;
/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardDataCopyWith<DashboardData> get copyWith => _$DashboardDataCopyWithImpl<DashboardData>(this as DashboardData, _$identity);

  /// Serializes this DashboardData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardData&&const DeepCollectionEquality().equals(other.emailCount, emailCount)&&const DeepCollectionEquality().equals(other.usernameCount, usernameCount)&&(identical(other.totalUploaded, totalUploaded) || other.totalUploaded == totalUploaded)&&(identical(other.totalDownloaded, totalDownloaded) || other.totalDownloaded == totalDownloaded)&&(identical(other.totalSeedVol, totalSeedVol) || other.totalSeedVol == totalSeedVol)&&(identical(other.totalSeeding, totalSeeding) || other.totalSeeding == totalSeeding)&&(identical(other.totalLeeching, totalLeeching) || other.totalLeeching == totalLeeching)&&(identical(other.todayUploadIncrement, todayUploadIncrement) || other.todayUploadIncrement == todayUploadIncrement)&&(identical(other.todayDownloadIncrement, todayDownloadIncrement) || other.todayDownloadIncrement == todayDownloadIncrement)&&(identical(other.totalPublished, totalPublished) || other.totalPublished == totalPublished)&&const DeepCollectionEquality().equals(other.uploadIncrementDataList, uploadIncrementDataList)&&const DeepCollectionEquality().equals(other.downloadIncrementDataList, downloadIncrementDataList)&&const DeepCollectionEquality().equals(other.uploadMonthIncrementDataList, uploadMonthIncrementDataList)&&const DeepCollectionEquality().equals(other.statusList, statusList)&&const DeepCollectionEquality().equals(other.stackChartDataList, stackChartDataList)&&const DeepCollectionEquality().equals(other.seedDataList, seedDataList)&&(identical(other.siteCount, siteCount) || other.siteCount == siteCount)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.earliestSite, earliestSite) || other.earliestSite == earliestSite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(emailCount),const DeepCollectionEquality().hash(usernameCount),totalUploaded,totalDownloaded,totalSeedVol,totalSeeding,totalLeeching,todayUploadIncrement,todayDownloadIncrement,totalPublished,const DeepCollectionEquality().hash(uploadIncrementDataList),const DeepCollectionEquality().hash(downloadIncrementDataList),const DeepCollectionEquality().hash(uploadMonthIncrementDataList),const DeepCollectionEquality().hash(statusList),const DeepCollectionEquality().hash(stackChartDataList),const DeepCollectionEquality().hash(seedDataList),siteCount,updatedAt,earliestSite]);

@override
String toString() {
  return 'DashboardData(emailCount: $emailCount, usernameCount: $usernameCount, totalUploaded: $totalUploaded, totalDownloaded: $totalDownloaded, totalSeedVol: $totalSeedVol, totalSeeding: $totalSeeding, totalLeeching: $totalLeeching, todayUploadIncrement: $todayUploadIncrement, todayDownloadIncrement: $todayDownloadIncrement, totalPublished: $totalPublished, uploadIncrementDataList: $uploadIncrementDataList, downloadIncrementDataList: $downloadIncrementDataList, uploadMonthIncrementDataList: $uploadMonthIncrementDataList, statusList: $statusList, stackChartDataList: $stackChartDataList, seedDataList: $seedDataList, siteCount: $siteCount, updatedAt: $updatedAt, earliestSite: $earliestSite)';
}


}

/// @nodoc
abstract mixin class $DashboardDataCopyWith<$Res>  {
  factory $DashboardDataCopyWith(DashboardData value, $Res Function(DashboardData) _then) = _$DashboardDataCopyWithImpl;
@useResult
$Res call({
 List<KV> emailCount, List<KV> usernameCount, num totalUploaded, num totalDownloaded, num totalSeedVol, num totalSeeding, num totalLeeching, num todayUploadIncrement, num todayDownloadIncrement, num totalPublished, List<KV> uploadIncrementDataList, List<KV> downloadIncrementDataList, List<MonthSiteData> uploadMonthIncrementDataList, List<SiteStatusData> statusList, List<StackSiteData> stackChartDataList, List<KV> seedDataList, num siteCount, String? updatedAt, EarliestSite? earliestSite
});


$EarliestSiteCopyWith<$Res>? get earliestSite;

}
/// @nodoc
class _$DashboardDataCopyWithImpl<$Res>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._self, this._then);

  final DashboardData _self;
  final $Res Function(DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emailCount = null,Object? usernameCount = null,Object? totalUploaded = null,Object? totalDownloaded = null,Object? totalSeedVol = null,Object? totalSeeding = null,Object? totalLeeching = null,Object? todayUploadIncrement = null,Object? todayDownloadIncrement = null,Object? totalPublished = null,Object? uploadIncrementDataList = null,Object? downloadIncrementDataList = null,Object? uploadMonthIncrementDataList = null,Object? statusList = null,Object? stackChartDataList = null,Object? seedDataList = null,Object? siteCount = null,Object? updatedAt = freezed,Object? earliestSite = freezed,}) {
  return _then(_self.copyWith(
emailCount: null == emailCount ? _self.emailCount : emailCount // ignore: cast_nullable_to_non_nullable
as List<KV>,usernameCount: null == usernameCount ? _self.usernameCount : usernameCount // ignore: cast_nullable_to_non_nullable
as List<KV>,totalUploaded: null == totalUploaded ? _self.totalUploaded : totalUploaded // ignore: cast_nullable_to_non_nullable
as num,totalDownloaded: null == totalDownloaded ? _self.totalDownloaded : totalDownloaded // ignore: cast_nullable_to_non_nullable
as num,totalSeedVol: null == totalSeedVol ? _self.totalSeedVol : totalSeedVol // ignore: cast_nullable_to_non_nullable
as num,totalSeeding: null == totalSeeding ? _self.totalSeeding : totalSeeding // ignore: cast_nullable_to_non_nullable
as num,totalLeeching: null == totalLeeching ? _self.totalLeeching : totalLeeching // ignore: cast_nullable_to_non_nullable
as num,todayUploadIncrement: null == todayUploadIncrement ? _self.todayUploadIncrement : todayUploadIncrement // ignore: cast_nullable_to_non_nullable
as num,todayDownloadIncrement: null == todayDownloadIncrement ? _self.todayDownloadIncrement : todayDownloadIncrement // ignore: cast_nullable_to_non_nullable
as num,totalPublished: null == totalPublished ? _self.totalPublished : totalPublished // ignore: cast_nullable_to_non_nullable
as num,uploadIncrementDataList: null == uploadIncrementDataList ? _self.uploadIncrementDataList : uploadIncrementDataList // ignore: cast_nullable_to_non_nullable
as List<KV>,downloadIncrementDataList: null == downloadIncrementDataList ? _self.downloadIncrementDataList : downloadIncrementDataList // ignore: cast_nullable_to_non_nullable
as List<KV>,uploadMonthIncrementDataList: null == uploadMonthIncrementDataList ? _self.uploadMonthIncrementDataList : uploadMonthIncrementDataList // ignore: cast_nullable_to_non_nullable
as List<MonthSiteData>,statusList: null == statusList ? _self.statusList : statusList // ignore: cast_nullable_to_non_nullable
as List<SiteStatusData>,stackChartDataList: null == stackChartDataList ? _self.stackChartDataList : stackChartDataList // ignore: cast_nullable_to_non_nullable
as List<StackSiteData>,seedDataList: null == seedDataList ? _self.seedDataList : seedDataList // ignore: cast_nullable_to_non_nullable
as List<KV>,siteCount: null == siteCount ? _self.siteCount : siteCount // ignore: cast_nullable_to_non_nullable
as num,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,earliestSite: freezed == earliestSite ? _self.earliestSite : earliestSite // ignore: cast_nullable_to_non_nullable
as EarliestSite?,
  ));
}
/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EarliestSiteCopyWith<$Res>? get earliestSite {
    if (_self.earliestSite == null) {
    return null;
  }

  return $EarliestSiteCopyWith<$Res>(_self.earliestSite!, (value) {
    return _then(_self.copyWith(earliestSite: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardData].
extension DashboardDataPatterns on DashboardData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardData value)  $default,){
final _that = this;
switch (_that) {
case _DashboardData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardData value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<KV> emailCount,  List<KV> usernameCount,  num totalUploaded,  num totalDownloaded,  num totalSeedVol,  num totalSeeding,  num totalLeeching,  num todayUploadIncrement,  num todayDownloadIncrement,  num totalPublished,  List<KV> uploadIncrementDataList,  List<KV> downloadIncrementDataList,  List<MonthSiteData> uploadMonthIncrementDataList,  List<SiteStatusData> statusList,  List<StackSiteData> stackChartDataList,  List<KV> seedDataList,  num siteCount,  String? updatedAt,  EarliestSite? earliestSite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.emailCount,_that.usernameCount,_that.totalUploaded,_that.totalDownloaded,_that.totalSeedVol,_that.totalSeeding,_that.totalLeeching,_that.todayUploadIncrement,_that.todayDownloadIncrement,_that.totalPublished,_that.uploadIncrementDataList,_that.downloadIncrementDataList,_that.uploadMonthIncrementDataList,_that.statusList,_that.stackChartDataList,_that.seedDataList,_that.siteCount,_that.updatedAt,_that.earliestSite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<KV> emailCount,  List<KV> usernameCount,  num totalUploaded,  num totalDownloaded,  num totalSeedVol,  num totalSeeding,  num totalLeeching,  num todayUploadIncrement,  num todayDownloadIncrement,  num totalPublished,  List<KV> uploadIncrementDataList,  List<KV> downloadIncrementDataList,  List<MonthSiteData> uploadMonthIncrementDataList,  List<SiteStatusData> statusList,  List<StackSiteData> stackChartDataList,  List<KV> seedDataList,  num siteCount,  String? updatedAt,  EarliestSite? earliestSite)  $default,) {final _that = this;
switch (_that) {
case _DashboardData():
return $default(_that.emailCount,_that.usernameCount,_that.totalUploaded,_that.totalDownloaded,_that.totalSeedVol,_that.totalSeeding,_that.totalLeeching,_that.todayUploadIncrement,_that.todayDownloadIncrement,_that.totalPublished,_that.uploadIncrementDataList,_that.downloadIncrementDataList,_that.uploadMonthIncrementDataList,_that.statusList,_that.stackChartDataList,_that.seedDataList,_that.siteCount,_that.updatedAt,_that.earliestSite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<KV> emailCount,  List<KV> usernameCount,  num totalUploaded,  num totalDownloaded,  num totalSeedVol,  num totalSeeding,  num totalLeeching,  num todayUploadIncrement,  num todayDownloadIncrement,  num totalPublished,  List<KV> uploadIncrementDataList,  List<KV> downloadIncrementDataList,  List<MonthSiteData> uploadMonthIncrementDataList,  List<SiteStatusData> statusList,  List<StackSiteData> stackChartDataList,  List<KV> seedDataList,  num siteCount,  String? updatedAt,  EarliestSite? earliestSite)?  $default,) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.emailCount,_that.usernameCount,_that.totalUploaded,_that.totalDownloaded,_that.totalSeedVol,_that.totalSeeding,_that.totalLeeching,_that.todayUploadIncrement,_that.todayDownloadIncrement,_that.totalPublished,_that.uploadIncrementDataList,_that.downloadIncrementDataList,_that.uploadMonthIncrementDataList,_that.statusList,_that.stackChartDataList,_that.seedDataList,_that.siteCount,_that.updatedAt,_that.earliestSite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardData implements DashboardData {
  const _DashboardData({final  List<KV> emailCount = const [], final  List<KV> usernameCount = const [], this.totalUploaded = 0, this.totalDownloaded = 0, this.totalSeedVol = 0, this.totalSeeding = 0, this.totalLeeching = 0, this.todayUploadIncrement = 0, this.todayDownloadIncrement = 0, this.totalPublished = 0, final  List<KV> uploadIncrementDataList = const [], final  List<KV> downloadIncrementDataList = const [], final  List<MonthSiteData> uploadMonthIncrementDataList = const [], final  List<SiteStatusData> statusList = const [], final  List<StackSiteData> stackChartDataList = const [], final  List<KV> seedDataList = const [], this.siteCount = 0, this.updatedAt, this.earliestSite}): _emailCount = emailCount,_usernameCount = usernameCount,_uploadIncrementDataList = uploadIncrementDataList,_downloadIncrementDataList = downloadIncrementDataList,_uploadMonthIncrementDataList = uploadMonthIncrementDataList,_statusList = statusList,_stackChartDataList = stackChartDataList,_seedDataList = seedDataList;
  factory _DashboardData.fromJson(Map<String, dynamic> json) => _$DashboardDataFromJson(json);

 final  List<KV> _emailCount;
@override@JsonKey() List<KV> get emailCount {
  if (_emailCount is EqualUnmodifiableListView) return _emailCount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_emailCount);
}

 final  List<KV> _usernameCount;
@override@JsonKey() List<KV> get usernameCount {
  if (_usernameCount is EqualUnmodifiableListView) return _usernameCount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usernameCount);
}

@override@JsonKey() final  num totalUploaded;
@override@JsonKey() final  num totalDownloaded;
@override@JsonKey() final  num totalSeedVol;
@override@JsonKey() final  num totalSeeding;
@override@JsonKey() final  num totalLeeching;
@override@JsonKey() final  num todayUploadIncrement;
@override@JsonKey() final  num todayDownloadIncrement;
@override@JsonKey() final  num totalPublished;
 final  List<KV> _uploadIncrementDataList;
@override@JsonKey() List<KV> get uploadIncrementDataList {
  if (_uploadIncrementDataList is EqualUnmodifiableListView) return _uploadIncrementDataList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uploadIncrementDataList);
}

 final  List<KV> _downloadIncrementDataList;
@override@JsonKey() List<KV> get downloadIncrementDataList {
  if (_downloadIncrementDataList is EqualUnmodifiableListView) return _downloadIncrementDataList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_downloadIncrementDataList);
}

 final  List<MonthSiteData> _uploadMonthIncrementDataList;
@override@JsonKey() List<MonthSiteData> get uploadMonthIncrementDataList {
  if (_uploadMonthIncrementDataList is EqualUnmodifiableListView) return _uploadMonthIncrementDataList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uploadMonthIncrementDataList);
}

 final  List<SiteStatusData> _statusList;
@override@JsonKey() List<SiteStatusData> get statusList {
  if (_statusList is EqualUnmodifiableListView) return _statusList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusList);
}

 final  List<StackSiteData> _stackChartDataList;
@override@JsonKey() List<StackSiteData> get stackChartDataList {
  if (_stackChartDataList is EqualUnmodifiableListView) return _stackChartDataList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stackChartDataList);
}

 final  List<KV> _seedDataList;
@override@JsonKey() List<KV> get seedDataList {
  if (_seedDataList is EqualUnmodifiableListView) return _seedDataList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seedDataList);
}

@override@JsonKey() final  num siteCount;
@override final  String? updatedAt;
@override final  EarliestSite? earliestSite;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardDataCopyWith<_DashboardData> get copyWith => __$DashboardDataCopyWithImpl<_DashboardData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardData&&const DeepCollectionEquality().equals(other._emailCount, _emailCount)&&const DeepCollectionEquality().equals(other._usernameCount, _usernameCount)&&(identical(other.totalUploaded, totalUploaded) || other.totalUploaded == totalUploaded)&&(identical(other.totalDownloaded, totalDownloaded) || other.totalDownloaded == totalDownloaded)&&(identical(other.totalSeedVol, totalSeedVol) || other.totalSeedVol == totalSeedVol)&&(identical(other.totalSeeding, totalSeeding) || other.totalSeeding == totalSeeding)&&(identical(other.totalLeeching, totalLeeching) || other.totalLeeching == totalLeeching)&&(identical(other.todayUploadIncrement, todayUploadIncrement) || other.todayUploadIncrement == todayUploadIncrement)&&(identical(other.todayDownloadIncrement, todayDownloadIncrement) || other.todayDownloadIncrement == todayDownloadIncrement)&&(identical(other.totalPublished, totalPublished) || other.totalPublished == totalPublished)&&const DeepCollectionEquality().equals(other._uploadIncrementDataList, _uploadIncrementDataList)&&const DeepCollectionEquality().equals(other._downloadIncrementDataList, _downloadIncrementDataList)&&const DeepCollectionEquality().equals(other._uploadMonthIncrementDataList, _uploadMonthIncrementDataList)&&const DeepCollectionEquality().equals(other._statusList, _statusList)&&const DeepCollectionEquality().equals(other._stackChartDataList, _stackChartDataList)&&const DeepCollectionEquality().equals(other._seedDataList, _seedDataList)&&(identical(other.siteCount, siteCount) || other.siteCount == siteCount)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.earliestSite, earliestSite) || other.earliestSite == earliestSite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_emailCount),const DeepCollectionEquality().hash(_usernameCount),totalUploaded,totalDownloaded,totalSeedVol,totalSeeding,totalLeeching,todayUploadIncrement,todayDownloadIncrement,totalPublished,const DeepCollectionEquality().hash(_uploadIncrementDataList),const DeepCollectionEquality().hash(_downloadIncrementDataList),const DeepCollectionEquality().hash(_uploadMonthIncrementDataList),const DeepCollectionEquality().hash(_statusList),const DeepCollectionEquality().hash(_stackChartDataList),const DeepCollectionEquality().hash(_seedDataList),siteCount,updatedAt,earliestSite]);

@override
String toString() {
  return 'DashboardData(emailCount: $emailCount, usernameCount: $usernameCount, totalUploaded: $totalUploaded, totalDownloaded: $totalDownloaded, totalSeedVol: $totalSeedVol, totalSeeding: $totalSeeding, totalLeeching: $totalLeeching, todayUploadIncrement: $todayUploadIncrement, todayDownloadIncrement: $todayDownloadIncrement, totalPublished: $totalPublished, uploadIncrementDataList: $uploadIncrementDataList, downloadIncrementDataList: $downloadIncrementDataList, uploadMonthIncrementDataList: $uploadMonthIncrementDataList, statusList: $statusList, stackChartDataList: $stackChartDataList, seedDataList: $seedDataList, siteCount: $siteCount, updatedAt: $updatedAt, earliestSite: $earliestSite)';
}


}

/// @nodoc
abstract mixin class _$DashboardDataCopyWith<$Res> implements $DashboardDataCopyWith<$Res> {
  factory _$DashboardDataCopyWith(_DashboardData value, $Res Function(_DashboardData) _then) = __$DashboardDataCopyWithImpl;
@override @useResult
$Res call({
 List<KV> emailCount, List<KV> usernameCount, num totalUploaded, num totalDownloaded, num totalSeedVol, num totalSeeding, num totalLeeching, num todayUploadIncrement, num todayDownloadIncrement, num totalPublished, List<KV> uploadIncrementDataList, List<KV> downloadIncrementDataList, List<MonthSiteData> uploadMonthIncrementDataList, List<SiteStatusData> statusList, List<StackSiteData> stackChartDataList, List<KV> seedDataList, num siteCount, String? updatedAt, EarliestSite? earliestSite
});


@override $EarliestSiteCopyWith<$Res>? get earliestSite;

}
/// @nodoc
class __$DashboardDataCopyWithImpl<$Res>
    implements _$DashboardDataCopyWith<$Res> {
  __$DashboardDataCopyWithImpl(this._self, this._then);

  final _DashboardData _self;
  final $Res Function(_DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emailCount = null,Object? usernameCount = null,Object? totalUploaded = null,Object? totalDownloaded = null,Object? totalSeedVol = null,Object? totalSeeding = null,Object? totalLeeching = null,Object? todayUploadIncrement = null,Object? todayDownloadIncrement = null,Object? totalPublished = null,Object? uploadIncrementDataList = null,Object? downloadIncrementDataList = null,Object? uploadMonthIncrementDataList = null,Object? statusList = null,Object? stackChartDataList = null,Object? seedDataList = null,Object? siteCount = null,Object? updatedAt = freezed,Object? earliestSite = freezed,}) {
  return _then(_DashboardData(
emailCount: null == emailCount ? _self._emailCount : emailCount // ignore: cast_nullable_to_non_nullable
as List<KV>,usernameCount: null == usernameCount ? _self._usernameCount : usernameCount // ignore: cast_nullable_to_non_nullable
as List<KV>,totalUploaded: null == totalUploaded ? _self.totalUploaded : totalUploaded // ignore: cast_nullable_to_non_nullable
as num,totalDownloaded: null == totalDownloaded ? _self.totalDownloaded : totalDownloaded // ignore: cast_nullable_to_non_nullable
as num,totalSeedVol: null == totalSeedVol ? _self.totalSeedVol : totalSeedVol // ignore: cast_nullable_to_non_nullable
as num,totalSeeding: null == totalSeeding ? _self.totalSeeding : totalSeeding // ignore: cast_nullable_to_non_nullable
as num,totalLeeching: null == totalLeeching ? _self.totalLeeching : totalLeeching // ignore: cast_nullable_to_non_nullable
as num,todayUploadIncrement: null == todayUploadIncrement ? _self.todayUploadIncrement : todayUploadIncrement // ignore: cast_nullable_to_non_nullable
as num,todayDownloadIncrement: null == todayDownloadIncrement ? _self.todayDownloadIncrement : todayDownloadIncrement // ignore: cast_nullable_to_non_nullable
as num,totalPublished: null == totalPublished ? _self.totalPublished : totalPublished // ignore: cast_nullable_to_non_nullable
as num,uploadIncrementDataList: null == uploadIncrementDataList ? _self._uploadIncrementDataList : uploadIncrementDataList // ignore: cast_nullable_to_non_nullable
as List<KV>,downloadIncrementDataList: null == downloadIncrementDataList ? _self._downloadIncrementDataList : downloadIncrementDataList // ignore: cast_nullable_to_non_nullable
as List<KV>,uploadMonthIncrementDataList: null == uploadMonthIncrementDataList ? _self._uploadMonthIncrementDataList : uploadMonthIncrementDataList // ignore: cast_nullable_to_non_nullable
as List<MonthSiteData>,statusList: null == statusList ? _self._statusList : statusList // ignore: cast_nullable_to_non_nullable
as List<SiteStatusData>,stackChartDataList: null == stackChartDataList ? _self._stackChartDataList : stackChartDataList // ignore: cast_nullable_to_non_nullable
as List<StackSiteData>,seedDataList: null == seedDataList ? _self._seedDataList : seedDataList // ignore: cast_nullable_to_non_nullable
as List<KV>,siteCount: null == siteCount ? _self.siteCount : siteCount // ignore: cast_nullable_to_non_nullable
as num,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,earliestSite: freezed == earliestSite ? _self.earliestSite : earliestSite // ignore: cast_nullable_to_non_nullable
as EarliestSite?,
  ));
}

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EarliestSiteCopyWith<$Res>? get earliestSite {
    if (_self.earliestSite == null) {
    return null;
  }

  return $EarliestSiteCopyWith<$Res>(_self.earliestSite!, (value) {
    return _then(_self.copyWith(earliestSite: value));
  });
}
}

// dart format on
