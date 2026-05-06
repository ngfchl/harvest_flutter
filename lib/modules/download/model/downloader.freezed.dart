// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'downloader.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Downloader {

 int get id; String get name; String get category; String get protocol; String get username; String get password;@JsonKey(name: 'is_active') bool get isActive; String get host; int get port;@JsonKey(name: 'external_host') String get externalHost;@JsonKey(name: 'sort_id') int get sortId; bool get brush;@JsonKey(name: 'torrent_path') String get torrentPath; Map<String, dynamic>? get prefs; Map<String, dynamic>? get status;
/// Create a copy of Downloader
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloaderCopyWith<Downloader> get copyWith => _$DownloaderCopyWithImpl<Downloader>(this as Downloader, _$identity);

  /// Serializes this Downloader to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Downloader&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.externalHost, externalHost) || other.externalHost == externalHost)&&(identical(other.sortId, sortId) || other.sortId == sortId)&&(identical(other.brush, brush) || other.brush == brush)&&(identical(other.torrentPath, torrentPath) || other.torrentPath == torrentPath)&&const DeepCollectionEquality().equals(other.prefs, prefs)&&const DeepCollectionEquality().equals(other.status, status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,protocol,username,password,isActive,host,port,externalHost,sortId,brush,torrentPath,const DeepCollectionEquality().hash(prefs),const DeepCollectionEquality().hash(status));

@override
String toString() {
  return 'Downloader(id: $id, name: $name, category: $category, protocol: $protocol, username: $username, password: $password, isActive: $isActive, host: $host, port: $port, externalHost: $externalHost, sortId: $sortId, brush: $brush, torrentPath: $torrentPath, prefs: $prefs, status: $status)';
}


}

/// @nodoc
abstract mixin class $DownloaderCopyWith<$Res>  {
  factory $DownloaderCopyWith(Downloader value, $Res Function(Downloader) _then) = _$DownloaderCopyWithImpl;
@useResult
$Res call({
 int id, String name, String category, String protocol, String username, String password,@JsonKey(name: 'is_active') bool isActive, String host, int port,@JsonKey(name: 'external_host') String externalHost,@JsonKey(name: 'sort_id') int sortId, bool brush,@JsonKey(name: 'torrent_path') String torrentPath, Map<String, dynamic>? prefs, Map<String, dynamic>? status
});




}
/// @nodoc
class _$DownloaderCopyWithImpl<$Res>
    implements $DownloaderCopyWith<$Res> {
  _$DownloaderCopyWithImpl(this._self, this._then);

  final Downloader _self;
  final $Res Function(Downloader) _then;

/// Create a copy of Downloader
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? protocol = null,Object? username = null,Object? password = null,Object? isActive = null,Object? host = null,Object? port = null,Object? externalHost = null,Object? sortId = null,Object? brush = null,Object? torrentPath = null,Object? prefs = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,externalHost: null == externalHost ? _self.externalHost : externalHost // ignore: cast_nullable_to_non_nullable
as String,sortId: null == sortId ? _self.sortId : sortId // ignore: cast_nullable_to_non_nullable
as int,brush: null == brush ? _self.brush : brush // ignore: cast_nullable_to_non_nullable
as bool,torrentPath: null == torrentPath ? _self.torrentPath : torrentPath // ignore: cast_nullable_to_non_nullable
as String,prefs: freezed == prefs ? _self.prefs : prefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Downloader].
extension DownloaderPatterns on Downloader {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Downloader value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Downloader() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Downloader value)  $default,){
final _that = this;
switch (_that) {
case _Downloader():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Downloader value)?  $default,){
final _that = this;
switch (_that) {
case _Downloader() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String category,  String protocol,  String username,  String password, @JsonKey(name: 'is_active')  bool isActive,  String host,  int port, @JsonKey(name: 'external_host')  String externalHost, @JsonKey(name: 'sort_id')  int sortId,  bool brush, @JsonKey(name: 'torrent_path')  String torrentPath,  Map<String, dynamic>? prefs,  Map<String, dynamic>? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Downloader() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.protocol,_that.username,_that.password,_that.isActive,_that.host,_that.port,_that.externalHost,_that.sortId,_that.brush,_that.torrentPath,_that.prefs,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String category,  String protocol,  String username,  String password, @JsonKey(name: 'is_active')  bool isActive,  String host,  int port, @JsonKey(name: 'external_host')  String externalHost, @JsonKey(name: 'sort_id')  int sortId,  bool brush, @JsonKey(name: 'torrent_path')  String torrentPath,  Map<String, dynamic>? prefs,  Map<String, dynamic>? status)  $default,) {final _that = this;
switch (_that) {
case _Downloader():
return $default(_that.id,_that.name,_that.category,_that.protocol,_that.username,_that.password,_that.isActive,_that.host,_that.port,_that.externalHost,_that.sortId,_that.brush,_that.torrentPath,_that.prefs,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String category,  String protocol,  String username,  String password, @JsonKey(name: 'is_active')  bool isActive,  String host,  int port, @JsonKey(name: 'external_host')  String externalHost, @JsonKey(name: 'sort_id')  int sortId,  bool brush, @JsonKey(name: 'torrent_path')  String torrentPath,  Map<String, dynamic>? prefs,  Map<String, dynamic>? status)?  $default,) {final _that = this;
switch (_that) {
case _Downloader() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.protocol,_that.username,_that.password,_that.isActive,_that.host,_that.port,_that.externalHost,_that.sortId,_that.brush,_that.torrentPath,_that.prefs,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Downloader extends Downloader {
  const _Downloader({this.id = 0, this.name = '', this.category = '', this.protocol = 'http', this.username = '', this.password = '', @JsonKey(name: 'is_active') this.isActive = true, this.host = '', this.port = 0, @JsonKey(name: 'external_host') this.externalHost = '', @JsonKey(name: 'sort_id') this.sortId = 0, this.brush = false, @JsonKey(name: 'torrent_path') this.torrentPath = '', final  Map<String, dynamic>? prefs, final  Map<String, dynamic>? status}): _prefs = prefs,_status = status,super._();
  factory _Downloader.fromJson(Map<String, dynamic> json) => _$DownloaderFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String category;
@override@JsonKey() final  String protocol;
@override@JsonKey() final  String username;
@override@JsonKey() final  String password;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey() final  String host;
@override@JsonKey() final  int port;
@override@JsonKey(name: 'external_host') final  String externalHost;
@override@JsonKey(name: 'sort_id') final  int sortId;
@override@JsonKey() final  bool brush;
@override@JsonKey(name: 'torrent_path') final  String torrentPath;
 final  Map<String, dynamic>? _prefs;
@override Map<String, dynamic>? get prefs {
  final value = _prefs;
  if (value == null) return null;
  if (_prefs is EqualUnmodifiableMapView) return _prefs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _status;
@override Map<String, dynamic>? get status {
  final value = _status;
  if (value == null) return null;
  if (_status is EqualUnmodifiableMapView) return _status;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of Downloader
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloaderCopyWith<_Downloader> get copyWith => __$DownloaderCopyWithImpl<_Downloader>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DownloaderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Downloader&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.externalHost, externalHost) || other.externalHost == externalHost)&&(identical(other.sortId, sortId) || other.sortId == sortId)&&(identical(other.brush, brush) || other.brush == brush)&&(identical(other.torrentPath, torrentPath) || other.torrentPath == torrentPath)&&const DeepCollectionEquality().equals(other._prefs, _prefs)&&const DeepCollectionEquality().equals(other._status, _status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,protocol,username,password,isActive,host,port,externalHost,sortId,brush,torrentPath,const DeepCollectionEquality().hash(_prefs),const DeepCollectionEquality().hash(_status));

@override
String toString() {
  return 'Downloader(id: $id, name: $name, category: $category, protocol: $protocol, username: $username, password: $password, isActive: $isActive, host: $host, port: $port, externalHost: $externalHost, sortId: $sortId, brush: $brush, torrentPath: $torrentPath, prefs: $prefs, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DownloaderCopyWith<$Res> implements $DownloaderCopyWith<$Res> {
  factory _$DownloaderCopyWith(_Downloader value, $Res Function(_Downloader) _then) = __$DownloaderCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String category, String protocol, String username, String password,@JsonKey(name: 'is_active') bool isActive, String host, int port,@JsonKey(name: 'external_host') String externalHost,@JsonKey(name: 'sort_id') int sortId, bool brush,@JsonKey(name: 'torrent_path') String torrentPath, Map<String, dynamic>? prefs, Map<String, dynamic>? status
});




}
/// @nodoc
class __$DownloaderCopyWithImpl<$Res>
    implements _$DownloaderCopyWith<$Res> {
  __$DownloaderCopyWithImpl(this._self, this._then);

  final _Downloader _self;
  final $Res Function(_Downloader) _then;

/// Create a copy of Downloader
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? protocol = null,Object? username = null,Object? password = null,Object? isActive = null,Object? host = null,Object? port = null,Object? externalHost = null,Object? sortId = null,Object? brush = null,Object? torrentPath = null,Object? prefs = freezed,Object? status = freezed,}) {
  return _then(_Downloader(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,externalHost: null == externalHost ? _self.externalHost : externalHost // ignore: cast_nullable_to_non_nullable
as String,sortId: null == sortId ? _self.sortId : sortId // ignore: cast_nullable_to_non_nullable
as int,brush: null == brush ? _self.brush : brush // ignore: cast_nullable_to_non_nullable
as bool,torrentPath: null == torrentPath ? _self.torrentPath : torrentPath // ignore: cast_nullable_to_non_nullable
as String,prefs: freezed == prefs ? _self._prefs : prefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: freezed == status ? _self._status : status // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
