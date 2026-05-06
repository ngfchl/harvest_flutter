// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SiteInfo {

 int get id; String get site; String get nickname;@JsonKey(name: 'sort_id') int get sortId; List<String> get tags;@JsonKey(name: 'user_id') String? get userId; String? get username; String? get email; String? get passkey; String? get authkey; String? get cookie;@JsonKey(name: 'user_agent') String? get userAgent; String? get rss; String? get torrents; bool get available;@JsonKey(name: 'sign_in') bool get signIn;@JsonKey(name: 'get_info') bool get getInfo;@JsonKey(name: 'repeat_torrents') bool get repeatTorrents;@JsonKey(name: 'brush_free') bool get brushFree;@JsonKey(name: 'brush_rss') bool get brushRss;@JsonKey(name: 'package_file') bool get packageFile;@JsonKey(name: 'hr_discern') bool get hrDiscern;@JsonKey(name: 'search_torrents') bool get searchTorrents;@JsonKey(name: 'show_in_dash') bool get showInDash; String? get proxy; Map<String, dynamic> get removeTorrentRules; String? get mirror;@JsonKey(name: 'time_join') String? get timeJoin;@JsonKey(name: 'latest_active') String? get latestActive; int get mail; int get notice;@JsonKey(name: 'sign_info') Map<String, dynamic>? get signInfo;@JsonKey(fromJson: _statusFromJson) Map<String, SiteDailyStatus>? get status;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of SiteInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteInfoCopyWith<SiteInfo> get copyWith => _$SiteInfoCopyWithImpl<SiteInfo>(this as SiteInfo, _$identity);

  /// Serializes this SiteInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.site, site) || other.site == site)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.sortId, sortId) || other.sortId == sortId)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.passkey, passkey) || other.passkey == passkey)&&(identical(other.authkey, authkey) || other.authkey == authkey)&&(identical(other.cookie, cookie) || other.cookie == cookie)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.rss, rss) || other.rss == rss)&&(identical(other.torrents, torrents) || other.torrents == torrents)&&(identical(other.available, available) || other.available == available)&&(identical(other.signIn, signIn) || other.signIn == signIn)&&(identical(other.getInfo, getInfo) || other.getInfo == getInfo)&&(identical(other.repeatTorrents, repeatTorrents) || other.repeatTorrents == repeatTorrents)&&(identical(other.brushFree, brushFree) || other.brushFree == brushFree)&&(identical(other.brushRss, brushRss) || other.brushRss == brushRss)&&(identical(other.packageFile, packageFile) || other.packageFile == packageFile)&&(identical(other.hrDiscern, hrDiscern) || other.hrDiscern == hrDiscern)&&(identical(other.searchTorrents, searchTorrents) || other.searchTorrents == searchTorrents)&&(identical(other.showInDash, showInDash) || other.showInDash == showInDash)&&(identical(other.proxy, proxy) || other.proxy == proxy)&&const DeepCollectionEquality().equals(other.removeTorrentRules, removeTorrentRules)&&(identical(other.mirror, mirror) || other.mirror == mirror)&&(identical(other.timeJoin, timeJoin) || other.timeJoin == timeJoin)&&(identical(other.latestActive, latestActive) || other.latestActive == latestActive)&&(identical(other.mail, mail) || other.mail == mail)&&(identical(other.notice, notice) || other.notice == notice)&&const DeepCollectionEquality().equals(other.signInfo, signInfo)&&const DeepCollectionEquality().equals(other.status, status)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,site,nickname,sortId,const DeepCollectionEquality().hash(tags),userId,username,email,passkey,authkey,cookie,userAgent,rss,torrents,available,signIn,getInfo,repeatTorrents,brushFree,brushRss,packageFile,hrDiscern,searchTorrents,showInDash,proxy,const DeepCollectionEquality().hash(removeTorrentRules),mirror,timeJoin,latestActive,mail,notice,const DeepCollectionEquality().hash(signInfo),const DeepCollectionEquality().hash(status),updatedAt]);

@override
String toString() {
  return 'SiteInfo(id: $id, site: $site, nickname: $nickname, sortId: $sortId, tags: $tags, userId: $userId, username: $username, email: $email, passkey: $passkey, authkey: $authkey, cookie: $cookie, userAgent: $userAgent, rss: $rss, torrents: $torrents, available: $available, signIn: $signIn, getInfo: $getInfo, repeatTorrents: $repeatTorrents, brushFree: $brushFree, brushRss: $brushRss, packageFile: $packageFile, hrDiscern: $hrDiscern, searchTorrents: $searchTorrents, showInDash: $showInDash, proxy: $proxy, removeTorrentRules: $removeTorrentRules, mirror: $mirror, timeJoin: $timeJoin, latestActive: $latestActive, mail: $mail, notice: $notice, signInfo: $signInfo, status: $status, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SiteInfoCopyWith<$Res>  {
  factory $SiteInfoCopyWith(SiteInfo value, $Res Function(SiteInfo) _then) = _$SiteInfoCopyWithImpl;
@useResult
$Res call({
 int id, String site, String nickname,@JsonKey(name: 'sort_id') int sortId, List<String> tags,@JsonKey(name: 'user_id') String? userId, String? username, String? email, String? passkey, String? authkey, String? cookie,@JsonKey(name: 'user_agent') String? userAgent, String? rss, String? torrents, bool available,@JsonKey(name: 'sign_in') bool signIn,@JsonKey(name: 'get_info') bool getInfo,@JsonKey(name: 'repeat_torrents') bool repeatTorrents,@JsonKey(name: 'brush_free') bool brushFree,@JsonKey(name: 'brush_rss') bool brushRss,@JsonKey(name: 'package_file') bool packageFile,@JsonKey(name: 'hr_discern') bool hrDiscern,@JsonKey(name: 'search_torrents') bool searchTorrents,@JsonKey(name: 'show_in_dash') bool showInDash, String? proxy, Map<String, dynamic> removeTorrentRules, String? mirror,@JsonKey(name: 'time_join') String? timeJoin,@JsonKey(name: 'latest_active') String? latestActive, int mail, int notice,@JsonKey(name: 'sign_info') Map<String, dynamic>? signInfo,@JsonKey(fromJson: _statusFromJson) Map<String, SiteDailyStatus>? status,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$SiteInfoCopyWithImpl<$Res>
    implements $SiteInfoCopyWith<$Res> {
  _$SiteInfoCopyWithImpl(this._self, this._then);

  final SiteInfo _self;
  final $Res Function(SiteInfo) _then;

/// Create a copy of SiteInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? site = null,Object? nickname = null,Object? sortId = null,Object? tags = null,Object? userId = freezed,Object? username = freezed,Object? email = freezed,Object? passkey = freezed,Object? authkey = freezed,Object? cookie = freezed,Object? userAgent = freezed,Object? rss = freezed,Object? torrents = freezed,Object? available = null,Object? signIn = null,Object? getInfo = null,Object? repeatTorrents = null,Object? brushFree = null,Object? brushRss = null,Object? packageFile = null,Object? hrDiscern = null,Object? searchTorrents = null,Object? showInDash = null,Object? proxy = freezed,Object? removeTorrentRules = null,Object? mirror = freezed,Object? timeJoin = freezed,Object? latestActive = freezed,Object? mail = null,Object? notice = null,Object? signInfo = freezed,Object? status = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,site: null == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,sortId: null == sortId ? _self.sortId : sortId // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,passkey: freezed == passkey ? _self.passkey : passkey // ignore: cast_nullable_to_non_nullable
as String?,authkey: freezed == authkey ? _self.authkey : authkey // ignore: cast_nullable_to_non_nullable
as String?,cookie: freezed == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,rss: freezed == rss ? _self.rss : rss // ignore: cast_nullable_to_non_nullable
as String?,torrents: freezed == torrents ? _self.torrents : torrents // ignore: cast_nullable_to_non_nullable
as String?,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,signIn: null == signIn ? _self.signIn : signIn // ignore: cast_nullable_to_non_nullable
as bool,getInfo: null == getInfo ? _self.getInfo : getInfo // ignore: cast_nullable_to_non_nullable
as bool,repeatTorrents: null == repeatTorrents ? _self.repeatTorrents : repeatTorrents // ignore: cast_nullable_to_non_nullable
as bool,brushFree: null == brushFree ? _self.brushFree : brushFree // ignore: cast_nullable_to_non_nullable
as bool,brushRss: null == brushRss ? _self.brushRss : brushRss // ignore: cast_nullable_to_non_nullable
as bool,packageFile: null == packageFile ? _self.packageFile : packageFile // ignore: cast_nullable_to_non_nullable
as bool,hrDiscern: null == hrDiscern ? _self.hrDiscern : hrDiscern // ignore: cast_nullable_to_non_nullable
as bool,searchTorrents: null == searchTorrents ? _self.searchTorrents : searchTorrents // ignore: cast_nullable_to_non_nullable
as bool,showInDash: null == showInDash ? _self.showInDash : showInDash // ignore: cast_nullable_to_non_nullable
as bool,proxy: freezed == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as String?,removeTorrentRules: null == removeTorrentRules ? _self.removeTorrentRules : removeTorrentRules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,mirror: freezed == mirror ? _self.mirror : mirror // ignore: cast_nullable_to_non_nullable
as String?,timeJoin: freezed == timeJoin ? _self.timeJoin : timeJoin // ignore: cast_nullable_to_non_nullable
as String?,latestActive: freezed == latestActive ? _self.latestActive : latestActive // ignore: cast_nullable_to_non_nullable
as String?,mail: null == mail ? _self.mail : mail // ignore: cast_nullable_to_non_nullable
as int,notice: null == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as int,signInfo: freezed == signInfo ? _self.signInfo : signInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Map<String, SiteDailyStatus>?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteInfo].
extension SiteInfoPatterns on SiteInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteInfo value)  $default,){
final _that = this;
switch (_that) {
case _SiteInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SiteInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String site,  String nickname, @JsonKey(name: 'sort_id')  int sortId,  List<String> tags, @JsonKey(name: 'user_id')  String? userId,  String? username,  String? email,  String? passkey,  String? authkey,  String? cookie, @JsonKey(name: 'user_agent')  String? userAgent,  String? rss,  String? torrents,  bool available, @JsonKey(name: 'sign_in')  bool signIn, @JsonKey(name: 'get_info')  bool getInfo, @JsonKey(name: 'repeat_torrents')  bool repeatTorrents, @JsonKey(name: 'brush_free')  bool brushFree, @JsonKey(name: 'brush_rss')  bool brushRss, @JsonKey(name: 'package_file')  bool packageFile, @JsonKey(name: 'hr_discern')  bool hrDiscern, @JsonKey(name: 'search_torrents')  bool searchTorrents, @JsonKey(name: 'show_in_dash')  bool showInDash,  String? proxy,  Map<String, dynamic> removeTorrentRules,  String? mirror, @JsonKey(name: 'time_join')  String? timeJoin, @JsonKey(name: 'latest_active')  String? latestActive,  int mail,  int notice, @JsonKey(name: 'sign_info')  Map<String, dynamic>? signInfo, @JsonKey(fromJson: _statusFromJson)  Map<String, SiteDailyStatus>? status, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteInfo() when $default != null:
return $default(_that.id,_that.site,_that.nickname,_that.sortId,_that.tags,_that.userId,_that.username,_that.email,_that.passkey,_that.authkey,_that.cookie,_that.userAgent,_that.rss,_that.torrents,_that.available,_that.signIn,_that.getInfo,_that.repeatTorrents,_that.brushFree,_that.brushRss,_that.packageFile,_that.hrDiscern,_that.searchTorrents,_that.showInDash,_that.proxy,_that.removeTorrentRules,_that.mirror,_that.timeJoin,_that.latestActive,_that.mail,_that.notice,_that.signInfo,_that.status,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String site,  String nickname, @JsonKey(name: 'sort_id')  int sortId,  List<String> tags, @JsonKey(name: 'user_id')  String? userId,  String? username,  String? email,  String? passkey,  String? authkey,  String? cookie, @JsonKey(name: 'user_agent')  String? userAgent,  String? rss,  String? torrents,  bool available, @JsonKey(name: 'sign_in')  bool signIn, @JsonKey(name: 'get_info')  bool getInfo, @JsonKey(name: 'repeat_torrents')  bool repeatTorrents, @JsonKey(name: 'brush_free')  bool brushFree, @JsonKey(name: 'brush_rss')  bool brushRss, @JsonKey(name: 'package_file')  bool packageFile, @JsonKey(name: 'hr_discern')  bool hrDiscern, @JsonKey(name: 'search_torrents')  bool searchTorrents, @JsonKey(name: 'show_in_dash')  bool showInDash,  String? proxy,  Map<String, dynamic> removeTorrentRules,  String? mirror, @JsonKey(name: 'time_join')  String? timeJoin, @JsonKey(name: 'latest_active')  String? latestActive,  int mail,  int notice, @JsonKey(name: 'sign_info')  Map<String, dynamic>? signInfo, @JsonKey(fromJson: _statusFromJson)  Map<String, SiteDailyStatus>? status, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SiteInfo():
return $default(_that.id,_that.site,_that.nickname,_that.sortId,_that.tags,_that.userId,_that.username,_that.email,_that.passkey,_that.authkey,_that.cookie,_that.userAgent,_that.rss,_that.torrents,_that.available,_that.signIn,_that.getInfo,_that.repeatTorrents,_that.brushFree,_that.brushRss,_that.packageFile,_that.hrDiscern,_that.searchTorrents,_that.showInDash,_that.proxy,_that.removeTorrentRules,_that.mirror,_that.timeJoin,_that.latestActive,_that.mail,_that.notice,_that.signInfo,_that.status,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String site,  String nickname, @JsonKey(name: 'sort_id')  int sortId,  List<String> tags, @JsonKey(name: 'user_id')  String? userId,  String? username,  String? email,  String? passkey,  String? authkey,  String? cookie, @JsonKey(name: 'user_agent')  String? userAgent,  String? rss,  String? torrents,  bool available, @JsonKey(name: 'sign_in')  bool signIn, @JsonKey(name: 'get_info')  bool getInfo, @JsonKey(name: 'repeat_torrents')  bool repeatTorrents, @JsonKey(name: 'brush_free')  bool brushFree, @JsonKey(name: 'brush_rss')  bool brushRss, @JsonKey(name: 'package_file')  bool packageFile, @JsonKey(name: 'hr_discern')  bool hrDiscern, @JsonKey(name: 'search_torrents')  bool searchTorrents, @JsonKey(name: 'show_in_dash')  bool showInDash,  String? proxy,  Map<String, dynamic> removeTorrentRules,  String? mirror, @JsonKey(name: 'time_join')  String? timeJoin, @JsonKey(name: 'latest_active')  String? latestActive,  int mail,  int notice, @JsonKey(name: 'sign_info')  Map<String, dynamic>? signInfo, @JsonKey(fromJson: _statusFromJson)  Map<String, SiteDailyStatus>? status, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SiteInfo() when $default != null:
return $default(_that.id,_that.site,_that.nickname,_that.sortId,_that.tags,_that.userId,_that.username,_that.email,_that.passkey,_that.authkey,_that.cookie,_that.userAgent,_that.rss,_that.torrents,_that.available,_that.signIn,_that.getInfo,_that.repeatTorrents,_that.brushFree,_that.brushRss,_that.packageFile,_that.hrDiscern,_that.searchTorrents,_that.showInDash,_that.proxy,_that.removeTorrentRules,_that.mirror,_that.timeJoin,_that.latestActive,_that.mail,_that.notice,_that.signInfo,_that.status,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SiteInfo extends SiteInfo {
  const _SiteInfo({this.id = 0, this.site = '', this.nickname = '', @JsonKey(name: 'sort_id') this.sortId = 0, final  List<String> tags = const [], @JsonKey(name: 'user_id') this.userId, this.username, this.email, this.passkey, this.authkey, this.cookie, @JsonKey(name: 'user_agent') this.userAgent, this.rss, this.torrents, this.available = false, @JsonKey(name: 'sign_in') this.signIn = false, @JsonKey(name: 'get_info') this.getInfo = false, @JsonKey(name: 'repeat_torrents') this.repeatTorrents = false, @JsonKey(name: 'brush_free') this.brushFree = false, @JsonKey(name: 'brush_rss') this.brushRss = false, @JsonKey(name: 'package_file') this.packageFile = false, @JsonKey(name: 'hr_discern') this.hrDiscern = false, @JsonKey(name: 'search_torrents') this.searchTorrents = false, @JsonKey(name: 'show_in_dash') this.showInDash = true, this.proxy, final  Map<String, dynamic> removeTorrentRules = const {}, this.mirror, @JsonKey(name: 'time_join') this.timeJoin, @JsonKey(name: 'latest_active') this.latestActive, this.mail = 0, this.notice = 0, @JsonKey(name: 'sign_info') final  Map<String, dynamic>? signInfo, @JsonKey(fromJson: _statusFromJson) final  Map<String, SiteDailyStatus>? status, @JsonKey(name: 'updated_at') this.updatedAt}): _tags = tags,_removeTorrentRules = removeTorrentRules,_signInfo = signInfo,_status = status,super._();
  factory _SiteInfo.fromJson(Map<String, dynamic> json) => _$SiteInfoFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String site;
@override@JsonKey() final  String nickname;
@override@JsonKey(name: 'sort_id') final  int sortId;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'user_id') final  String? userId;
@override final  String? username;
@override final  String? email;
@override final  String? passkey;
@override final  String? authkey;
@override final  String? cookie;
@override@JsonKey(name: 'user_agent') final  String? userAgent;
@override final  String? rss;
@override final  String? torrents;
@override@JsonKey() final  bool available;
@override@JsonKey(name: 'sign_in') final  bool signIn;
@override@JsonKey(name: 'get_info') final  bool getInfo;
@override@JsonKey(name: 'repeat_torrents') final  bool repeatTorrents;
@override@JsonKey(name: 'brush_free') final  bool brushFree;
@override@JsonKey(name: 'brush_rss') final  bool brushRss;
@override@JsonKey(name: 'package_file') final  bool packageFile;
@override@JsonKey(name: 'hr_discern') final  bool hrDiscern;
@override@JsonKey(name: 'search_torrents') final  bool searchTorrents;
@override@JsonKey(name: 'show_in_dash') final  bool showInDash;
@override final  String? proxy;
 final  Map<String, dynamic> _removeTorrentRules;
@override@JsonKey() Map<String, dynamic> get removeTorrentRules {
  if (_removeTorrentRules is EqualUnmodifiableMapView) return _removeTorrentRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_removeTorrentRules);
}

@override final  String? mirror;
@override@JsonKey(name: 'time_join') final  String? timeJoin;
@override@JsonKey(name: 'latest_active') final  String? latestActive;
@override@JsonKey() final  int mail;
@override@JsonKey() final  int notice;
 final  Map<String, dynamic>? _signInfo;
@override@JsonKey(name: 'sign_info') Map<String, dynamic>? get signInfo {
  final value = _signInfo;
  if (value == null) return null;
  if (_signInfo is EqualUnmodifiableMapView) return _signInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, SiteDailyStatus>? _status;
@override@JsonKey(fromJson: _statusFromJson) Map<String, SiteDailyStatus>? get status {
  final value = _status;
  if (value == null) return null;
  if (_status is EqualUnmodifiableMapView) return _status;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of SiteInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteInfoCopyWith<_SiteInfo> get copyWith => __$SiteInfoCopyWithImpl<_SiteInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.site, site) || other.site == site)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.sortId, sortId) || other.sortId == sortId)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.passkey, passkey) || other.passkey == passkey)&&(identical(other.authkey, authkey) || other.authkey == authkey)&&(identical(other.cookie, cookie) || other.cookie == cookie)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.rss, rss) || other.rss == rss)&&(identical(other.torrents, torrents) || other.torrents == torrents)&&(identical(other.available, available) || other.available == available)&&(identical(other.signIn, signIn) || other.signIn == signIn)&&(identical(other.getInfo, getInfo) || other.getInfo == getInfo)&&(identical(other.repeatTorrents, repeatTorrents) || other.repeatTorrents == repeatTorrents)&&(identical(other.brushFree, brushFree) || other.brushFree == brushFree)&&(identical(other.brushRss, brushRss) || other.brushRss == brushRss)&&(identical(other.packageFile, packageFile) || other.packageFile == packageFile)&&(identical(other.hrDiscern, hrDiscern) || other.hrDiscern == hrDiscern)&&(identical(other.searchTorrents, searchTorrents) || other.searchTorrents == searchTorrents)&&(identical(other.showInDash, showInDash) || other.showInDash == showInDash)&&(identical(other.proxy, proxy) || other.proxy == proxy)&&const DeepCollectionEquality().equals(other._removeTorrentRules, _removeTorrentRules)&&(identical(other.mirror, mirror) || other.mirror == mirror)&&(identical(other.timeJoin, timeJoin) || other.timeJoin == timeJoin)&&(identical(other.latestActive, latestActive) || other.latestActive == latestActive)&&(identical(other.mail, mail) || other.mail == mail)&&(identical(other.notice, notice) || other.notice == notice)&&const DeepCollectionEquality().equals(other._signInfo, _signInfo)&&const DeepCollectionEquality().equals(other._status, _status)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,site,nickname,sortId,const DeepCollectionEquality().hash(_tags),userId,username,email,passkey,authkey,cookie,userAgent,rss,torrents,available,signIn,getInfo,repeatTorrents,brushFree,brushRss,packageFile,hrDiscern,searchTorrents,showInDash,proxy,const DeepCollectionEquality().hash(_removeTorrentRules),mirror,timeJoin,latestActive,mail,notice,const DeepCollectionEquality().hash(_signInfo),const DeepCollectionEquality().hash(_status),updatedAt]);

@override
String toString() {
  return 'SiteInfo(id: $id, site: $site, nickname: $nickname, sortId: $sortId, tags: $tags, userId: $userId, username: $username, email: $email, passkey: $passkey, authkey: $authkey, cookie: $cookie, userAgent: $userAgent, rss: $rss, torrents: $torrents, available: $available, signIn: $signIn, getInfo: $getInfo, repeatTorrents: $repeatTorrents, brushFree: $brushFree, brushRss: $brushRss, packageFile: $packageFile, hrDiscern: $hrDiscern, searchTorrents: $searchTorrents, showInDash: $showInDash, proxy: $proxy, removeTorrentRules: $removeTorrentRules, mirror: $mirror, timeJoin: $timeJoin, latestActive: $latestActive, mail: $mail, notice: $notice, signInfo: $signInfo, status: $status, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SiteInfoCopyWith<$Res> implements $SiteInfoCopyWith<$Res> {
  factory _$SiteInfoCopyWith(_SiteInfo value, $Res Function(_SiteInfo) _then) = __$SiteInfoCopyWithImpl;
@override @useResult
$Res call({
 int id, String site, String nickname,@JsonKey(name: 'sort_id') int sortId, List<String> tags,@JsonKey(name: 'user_id') String? userId, String? username, String? email, String? passkey, String? authkey, String? cookie,@JsonKey(name: 'user_agent') String? userAgent, String? rss, String? torrents, bool available,@JsonKey(name: 'sign_in') bool signIn,@JsonKey(name: 'get_info') bool getInfo,@JsonKey(name: 'repeat_torrents') bool repeatTorrents,@JsonKey(name: 'brush_free') bool brushFree,@JsonKey(name: 'brush_rss') bool brushRss,@JsonKey(name: 'package_file') bool packageFile,@JsonKey(name: 'hr_discern') bool hrDiscern,@JsonKey(name: 'search_torrents') bool searchTorrents,@JsonKey(name: 'show_in_dash') bool showInDash, String? proxy, Map<String, dynamic> removeTorrentRules, String? mirror,@JsonKey(name: 'time_join') String? timeJoin,@JsonKey(name: 'latest_active') String? latestActive, int mail, int notice,@JsonKey(name: 'sign_info') Map<String, dynamic>? signInfo,@JsonKey(fromJson: _statusFromJson) Map<String, SiteDailyStatus>? status,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$SiteInfoCopyWithImpl<$Res>
    implements _$SiteInfoCopyWith<$Res> {
  __$SiteInfoCopyWithImpl(this._self, this._then);

  final _SiteInfo _self;
  final $Res Function(_SiteInfo) _then;

/// Create a copy of SiteInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? site = null,Object? nickname = null,Object? sortId = null,Object? tags = null,Object? userId = freezed,Object? username = freezed,Object? email = freezed,Object? passkey = freezed,Object? authkey = freezed,Object? cookie = freezed,Object? userAgent = freezed,Object? rss = freezed,Object? torrents = freezed,Object? available = null,Object? signIn = null,Object? getInfo = null,Object? repeatTorrents = null,Object? brushFree = null,Object? brushRss = null,Object? packageFile = null,Object? hrDiscern = null,Object? searchTorrents = null,Object? showInDash = null,Object? proxy = freezed,Object? removeTorrentRules = null,Object? mirror = freezed,Object? timeJoin = freezed,Object? latestActive = freezed,Object? mail = null,Object? notice = null,Object? signInfo = freezed,Object? status = freezed,Object? updatedAt = freezed,}) {
  return _then(_SiteInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,site: null == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,sortId: null == sortId ? _self.sortId : sortId // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,passkey: freezed == passkey ? _self.passkey : passkey // ignore: cast_nullable_to_non_nullable
as String?,authkey: freezed == authkey ? _self.authkey : authkey // ignore: cast_nullable_to_non_nullable
as String?,cookie: freezed == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,rss: freezed == rss ? _self.rss : rss // ignore: cast_nullable_to_non_nullable
as String?,torrents: freezed == torrents ? _self.torrents : torrents // ignore: cast_nullable_to_non_nullable
as String?,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,signIn: null == signIn ? _self.signIn : signIn // ignore: cast_nullable_to_non_nullable
as bool,getInfo: null == getInfo ? _self.getInfo : getInfo // ignore: cast_nullable_to_non_nullable
as bool,repeatTorrents: null == repeatTorrents ? _self.repeatTorrents : repeatTorrents // ignore: cast_nullable_to_non_nullable
as bool,brushFree: null == brushFree ? _self.brushFree : brushFree // ignore: cast_nullable_to_non_nullable
as bool,brushRss: null == brushRss ? _self.brushRss : brushRss // ignore: cast_nullable_to_non_nullable
as bool,packageFile: null == packageFile ? _self.packageFile : packageFile // ignore: cast_nullable_to_non_nullable
as bool,hrDiscern: null == hrDiscern ? _self.hrDiscern : hrDiscern // ignore: cast_nullable_to_non_nullable
as bool,searchTorrents: null == searchTorrents ? _self.searchTorrents : searchTorrents // ignore: cast_nullable_to_non_nullable
as bool,showInDash: null == showInDash ? _self.showInDash : showInDash // ignore: cast_nullable_to_non_nullable
as bool,proxy: freezed == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as String?,removeTorrentRules: null == removeTorrentRules ? _self._removeTorrentRules : removeTorrentRules // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,mirror: freezed == mirror ? _self.mirror : mirror // ignore: cast_nullable_to_non_nullable
as String?,timeJoin: freezed == timeJoin ? _self.timeJoin : timeJoin // ignore: cast_nullable_to_non_nullable
as String?,latestActive: freezed == latestActive ? _self.latestActive : latestActive // ignore: cast_nullable_to_non_nullable
as String?,mail: null == mail ? _self.mail : mail // ignore: cast_nullable_to_non_nullable
as int,notice: null == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as int,signInfo: freezed == signInfo ? _self._signInfo : signInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: freezed == status ? _self._status : status // ignore: cast_nullable_to_non_nullable
as Map<String, SiteDailyStatus>?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SiteDailyStatus {

 String get date; int get seed; int get leech;@JsonKey(name: 'my_hr') String get myHr; double get ratio; int get publish;@JsonKey(name: 'my_bonus') double get myBonus;@JsonKey(name: 'my_level') String get myLevel;@JsonKey(name: 'my_score') double get myScore; int get uploaded;@JsonKey(name: 'seed_days') int get seedDays;@JsonKey(name: 'bonus_hour') double get bonusHour; String get created_at; int get downloaded; int get invitation; String get updated_at;@JsonKey(name: 'seed_volume') int get seedVolume;
/// Create a copy of SiteDailyStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteDailyStatusCopyWith<SiteDailyStatus> get copyWith => _$SiteDailyStatusCopyWithImpl<SiteDailyStatus>(this as SiteDailyStatus, _$identity);

  /// Serializes this SiteDailyStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteDailyStatus&&(identical(other.date, date) || other.date == date)&&(identical(other.seed, seed) || other.seed == seed)&&(identical(other.leech, leech) || other.leech == leech)&&(identical(other.myHr, myHr) || other.myHr == myHr)&&(identical(other.ratio, ratio) || other.ratio == ratio)&&(identical(other.publish, publish) || other.publish == publish)&&(identical(other.myBonus, myBonus) || other.myBonus == myBonus)&&(identical(other.myLevel, myLevel) || other.myLevel == myLevel)&&(identical(other.myScore, myScore) || other.myScore == myScore)&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.seedDays, seedDays) || other.seedDays == seedDays)&&(identical(other.bonusHour, bonusHour) || other.bonusHour == bonusHour)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded)&&(identical(other.invitation, invitation) || other.invitation == invitation)&&(identical(other.updated_at, updated_at) || other.updated_at == updated_at)&&(identical(other.seedVolume, seedVolume) || other.seedVolume == seedVolume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,seed,leech,myHr,ratio,publish,myBonus,myLevel,myScore,uploaded,seedDays,bonusHour,created_at,downloaded,invitation,updated_at,seedVolume);

@override
String toString() {
  return 'SiteDailyStatus(date: $date, seed: $seed, leech: $leech, myHr: $myHr, ratio: $ratio, publish: $publish, myBonus: $myBonus, myLevel: $myLevel, myScore: $myScore, uploaded: $uploaded, seedDays: $seedDays, bonusHour: $bonusHour, created_at: $created_at, downloaded: $downloaded, invitation: $invitation, updated_at: $updated_at, seedVolume: $seedVolume)';
}


}

/// @nodoc
abstract mixin class $SiteDailyStatusCopyWith<$Res>  {
  factory $SiteDailyStatusCopyWith(SiteDailyStatus value, $Res Function(SiteDailyStatus) _then) = _$SiteDailyStatusCopyWithImpl;
@useResult
$Res call({
 String date, int seed, int leech,@JsonKey(name: 'my_hr') String myHr, double ratio, int publish,@JsonKey(name: 'my_bonus') double myBonus,@JsonKey(name: 'my_level') String myLevel,@JsonKey(name: 'my_score') double myScore, int uploaded,@JsonKey(name: 'seed_days') int seedDays,@JsonKey(name: 'bonus_hour') double bonusHour, String created_at, int downloaded, int invitation, String updated_at,@JsonKey(name: 'seed_volume') int seedVolume
});




}
/// @nodoc
class _$SiteDailyStatusCopyWithImpl<$Res>
    implements $SiteDailyStatusCopyWith<$Res> {
  _$SiteDailyStatusCopyWithImpl(this._self, this._then);

  final SiteDailyStatus _self;
  final $Res Function(SiteDailyStatus) _then;

/// Create a copy of SiteDailyStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? seed = null,Object? leech = null,Object? myHr = null,Object? ratio = null,Object? publish = null,Object? myBonus = null,Object? myLevel = null,Object? myScore = null,Object? uploaded = null,Object? seedDays = null,Object? bonusHour = null,Object? created_at = null,Object? downloaded = null,Object? invitation = null,Object? updated_at = null,Object? seedVolume = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,leech: null == leech ? _self.leech : leech // ignore: cast_nullable_to_non_nullable
as int,myHr: null == myHr ? _self.myHr : myHr // ignore: cast_nullable_to_non_nullable
as String,ratio: null == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as double,publish: null == publish ? _self.publish : publish // ignore: cast_nullable_to_non_nullable
as int,myBonus: null == myBonus ? _self.myBonus : myBonus // ignore: cast_nullable_to_non_nullable
as double,myLevel: null == myLevel ? _self.myLevel : myLevel // ignore: cast_nullable_to_non_nullable
as String,myScore: null == myScore ? _self.myScore : myScore // ignore: cast_nullable_to_non_nullable
as double,uploaded: null == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as int,seedDays: null == seedDays ? _self.seedDays : seedDays // ignore: cast_nullable_to_non_nullable
as int,bonusHour: null == bonusHour ? _self.bonusHour : bonusHour // ignore: cast_nullable_to_non_nullable
as double,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as int,invitation: null == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as int,updated_at: null == updated_at ? _self.updated_at : updated_at // ignore: cast_nullable_to_non_nullable
as String,seedVolume: null == seedVolume ? _self.seedVolume : seedVolume // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteDailyStatus].
extension SiteDailyStatusPatterns on SiteDailyStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteDailyStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteDailyStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteDailyStatus value)  $default,){
final _that = this;
switch (_that) {
case _SiteDailyStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteDailyStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SiteDailyStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  int seed,  int leech, @JsonKey(name: 'my_hr')  String myHr,  double ratio,  int publish, @JsonKey(name: 'my_bonus')  double myBonus, @JsonKey(name: 'my_level')  String myLevel, @JsonKey(name: 'my_score')  double myScore,  int uploaded, @JsonKey(name: 'seed_days')  int seedDays, @JsonKey(name: 'bonus_hour')  double bonusHour,  String created_at,  int downloaded,  int invitation,  String updated_at, @JsonKey(name: 'seed_volume')  int seedVolume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteDailyStatus() when $default != null:
return $default(_that.date,_that.seed,_that.leech,_that.myHr,_that.ratio,_that.publish,_that.myBonus,_that.myLevel,_that.myScore,_that.uploaded,_that.seedDays,_that.bonusHour,_that.created_at,_that.downloaded,_that.invitation,_that.updated_at,_that.seedVolume);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  int seed,  int leech, @JsonKey(name: 'my_hr')  String myHr,  double ratio,  int publish, @JsonKey(name: 'my_bonus')  double myBonus, @JsonKey(name: 'my_level')  String myLevel, @JsonKey(name: 'my_score')  double myScore,  int uploaded, @JsonKey(name: 'seed_days')  int seedDays, @JsonKey(name: 'bonus_hour')  double bonusHour,  String created_at,  int downloaded,  int invitation,  String updated_at, @JsonKey(name: 'seed_volume')  int seedVolume)  $default,) {final _that = this;
switch (_that) {
case _SiteDailyStatus():
return $default(_that.date,_that.seed,_that.leech,_that.myHr,_that.ratio,_that.publish,_that.myBonus,_that.myLevel,_that.myScore,_that.uploaded,_that.seedDays,_that.bonusHour,_that.created_at,_that.downloaded,_that.invitation,_that.updated_at,_that.seedVolume);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  int seed,  int leech, @JsonKey(name: 'my_hr')  String myHr,  double ratio,  int publish, @JsonKey(name: 'my_bonus')  double myBonus, @JsonKey(name: 'my_level')  String myLevel, @JsonKey(name: 'my_score')  double myScore,  int uploaded, @JsonKey(name: 'seed_days')  int seedDays, @JsonKey(name: 'bonus_hour')  double bonusHour,  String created_at,  int downloaded,  int invitation,  String updated_at, @JsonKey(name: 'seed_volume')  int seedVolume)?  $default,) {final _that = this;
switch (_that) {
case _SiteDailyStatus() when $default != null:
return $default(_that.date,_that.seed,_that.leech,_that.myHr,_that.ratio,_that.publish,_that.myBonus,_that.myLevel,_that.myScore,_that.uploaded,_that.seedDays,_that.bonusHour,_that.created_at,_that.downloaded,_that.invitation,_that.updated_at,_that.seedVolume);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SiteDailyStatus extends SiteDailyStatus {
  const _SiteDailyStatus({this.date = '', this.seed = 0, this.leech = 0, @JsonKey(name: 'my_hr') this.myHr = '0', this.ratio = 0.0, this.publish = 0, @JsonKey(name: 'my_bonus') this.myBonus = 0.0, @JsonKey(name: 'my_level') this.myLevel = '', @JsonKey(name: 'my_score') this.myScore = 0.0, this.uploaded = 0, @JsonKey(name: 'seed_days') this.seedDays = 0, @JsonKey(name: 'bonus_hour') this.bonusHour = 0.0, this.created_at = '', this.downloaded = 0, this.invitation = 0, this.updated_at = '', @JsonKey(name: 'seed_volume') this.seedVolume = 0}): super._();
  factory _SiteDailyStatus.fromJson(Map<String, dynamic> json) => _$SiteDailyStatusFromJson(json);

@override@JsonKey() final  String date;
@override@JsonKey() final  int seed;
@override@JsonKey() final  int leech;
@override@JsonKey(name: 'my_hr') final  String myHr;
@override@JsonKey() final  double ratio;
@override@JsonKey() final  int publish;
@override@JsonKey(name: 'my_bonus') final  double myBonus;
@override@JsonKey(name: 'my_level') final  String myLevel;
@override@JsonKey(name: 'my_score') final  double myScore;
@override@JsonKey() final  int uploaded;
@override@JsonKey(name: 'seed_days') final  int seedDays;
@override@JsonKey(name: 'bonus_hour') final  double bonusHour;
@override@JsonKey() final  String created_at;
@override@JsonKey() final  int downloaded;
@override@JsonKey() final  int invitation;
@override@JsonKey() final  String updated_at;
@override@JsonKey(name: 'seed_volume') final  int seedVolume;

/// Create a copy of SiteDailyStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteDailyStatusCopyWith<_SiteDailyStatus> get copyWith => __$SiteDailyStatusCopyWithImpl<_SiteDailyStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteDailyStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteDailyStatus&&(identical(other.date, date) || other.date == date)&&(identical(other.seed, seed) || other.seed == seed)&&(identical(other.leech, leech) || other.leech == leech)&&(identical(other.myHr, myHr) || other.myHr == myHr)&&(identical(other.ratio, ratio) || other.ratio == ratio)&&(identical(other.publish, publish) || other.publish == publish)&&(identical(other.myBonus, myBonus) || other.myBonus == myBonus)&&(identical(other.myLevel, myLevel) || other.myLevel == myLevel)&&(identical(other.myScore, myScore) || other.myScore == myScore)&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.seedDays, seedDays) || other.seedDays == seedDays)&&(identical(other.bonusHour, bonusHour) || other.bonusHour == bonusHour)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded)&&(identical(other.invitation, invitation) || other.invitation == invitation)&&(identical(other.updated_at, updated_at) || other.updated_at == updated_at)&&(identical(other.seedVolume, seedVolume) || other.seedVolume == seedVolume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,seed,leech,myHr,ratio,publish,myBonus,myLevel,myScore,uploaded,seedDays,bonusHour,created_at,downloaded,invitation,updated_at,seedVolume);

@override
String toString() {
  return 'SiteDailyStatus(date: $date, seed: $seed, leech: $leech, myHr: $myHr, ratio: $ratio, publish: $publish, myBonus: $myBonus, myLevel: $myLevel, myScore: $myScore, uploaded: $uploaded, seedDays: $seedDays, bonusHour: $bonusHour, created_at: $created_at, downloaded: $downloaded, invitation: $invitation, updated_at: $updated_at, seedVolume: $seedVolume)';
}


}

/// @nodoc
abstract mixin class _$SiteDailyStatusCopyWith<$Res> implements $SiteDailyStatusCopyWith<$Res> {
  factory _$SiteDailyStatusCopyWith(_SiteDailyStatus value, $Res Function(_SiteDailyStatus) _then) = __$SiteDailyStatusCopyWithImpl;
@override @useResult
$Res call({
 String date, int seed, int leech,@JsonKey(name: 'my_hr') String myHr, double ratio, int publish,@JsonKey(name: 'my_bonus') double myBonus,@JsonKey(name: 'my_level') String myLevel,@JsonKey(name: 'my_score') double myScore, int uploaded,@JsonKey(name: 'seed_days') int seedDays,@JsonKey(name: 'bonus_hour') double bonusHour, String created_at, int downloaded, int invitation, String updated_at,@JsonKey(name: 'seed_volume') int seedVolume
});




}
/// @nodoc
class __$SiteDailyStatusCopyWithImpl<$Res>
    implements _$SiteDailyStatusCopyWith<$Res> {
  __$SiteDailyStatusCopyWithImpl(this._self, this._then);

  final _SiteDailyStatus _self;
  final $Res Function(_SiteDailyStatus) _then;

/// Create a copy of SiteDailyStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? seed = null,Object? leech = null,Object? myHr = null,Object? ratio = null,Object? publish = null,Object? myBonus = null,Object? myLevel = null,Object? myScore = null,Object? uploaded = null,Object? seedDays = null,Object? bonusHour = null,Object? created_at = null,Object? downloaded = null,Object? invitation = null,Object? updated_at = null,Object? seedVolume = null,}) {
  return _then(_SiteDailyStatus(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,leech: null == leech ? _self.leech : leech // ignore: cast_nullable_to_non_nullable
as int,myHr: null == myHr ? _self.myHr : myHr // ignore: cast_nullable_to_non_nullable
as String,ratio: null == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as double,publish: null == publish ? _self.publish : publish // ignore: cast_nullable_to_non_nullable
as int,myBonus: null == myBonus ? _self.myBonus : myBonus // ignore: cast_nullable_to_non_nullable
as double,myLevel: null == myLevel ? _self.myLevel : myLevel // ignore: cast_nullable_to_non_nullable
as String,myScore: null == myScore ? _self.myScore : myScore // ignore: cast_nullable_to_non_nullable
as double,uploaded: null == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as int,seedDays: null == seedDays ? _self.seedDays : seedDays // ignore: cast_nullable_to_non_nullable
as int,bonusHour: null == bonusHour ? _self.bonusHour : bonusHour // ignore: cast_nullable_to_non_nullable
as double,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as int,invitation: null == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as int,updated_at: null == updated_at ? _self.updated_at : updated_at // ignore: cast_nullable_to_non_nullable
as String,seedVolume: null == seedVolume ? _self.seedVolume : seedVolume // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
