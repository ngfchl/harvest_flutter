// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'option_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OptionValue {

 String? get token;@JsonKey(name: 'refresh_token', fromJson: _dynamicToString) String? get refreshToken; String? get server; String? get key; String? get password;@JsonKey(name: 'api_key') String? get apiKey;@JsonKey(name: 'secret_key') String? get secretKey;@JsonKey(name: 'app_id') String? get appId; String? get uids;@JsonKey(name: 'pushkey') String? get pushKey;@JsonKey(name: 'device_key') String? get deviceKey; bool? get repeat; bool? get welfare; String? get proxy;@JsonKey(name: 'telegram_token') String? get telegramToken;@JsonKey(name: 'telegram_chat_id') String? get telegramChatId; String? get template;@JsonKey(name: 'corp_id') String? get corpId;@JsonKey(name: 'corpsecret') String? get corpSecret;@JsonKey(name: 'agent_id') String? get agentId;@JsonKey(name: 'to_uid') String? get toUid; String? get username; String? get cookie;@JsonKey(name: 'user_agent') String? get userAgent;@JsonKey(name: 'todaysay', fromJson: _dynamicToString) String? get todaySay;@JsonKey(name: 'aliyundrive_notice') bool? get aliyundriveNotice;@JsonKey(name: 'site_data') bool? get siteData;@JsonKey(name: 'site_data_success') bool? get siteDataSuccess;@JsonKey(name: 'today_data') bool? get todayData;@JsonKey(name: 'package_torrent') bool? get packageTorrent;@JsonKey(name: 'delete_torrent') bool? get deleteTorrent;@JsonKey(name: 'rss_torrent') bool? get rssTorrent;@JsonKey(name: 'push_torrent') bool? get pushTorrent;@JsonKey(name: 'program_upgrade') bool? get programUpgrade;@JsonKey(name: 'ptpp_import') bool? get ptppImport; bool? get announcement; bool? get message;@JsonKey(name: 'sign_in_success') bool? get signInSuccess;@JsonKey(name: 'cookie_sync') bool? get cookieSync; bool? get level; bool? get bonus;@JsonKey(name: 'per_bonus') bool? get perBonus; bool? get score; bool? get ratio;@JsonKey(name: 'seeding_vol') bool? get seedingVol; bool? get uploaded; bool? get downloaded; bool? get seeding; bool? get leeching; bool? get invite; bool? get hr; int? get count;@JsonKey(name: 'max_count') int? get maxCount; int? get limit;
/// Create a copy of OptionValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OptionValueCopyWith<OptionValue> get copyWith => _$OptionValueCopyWithImpl<OptionValue>(this as OptionValue, _$identity);

  /// Serializes this OptionValue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OptionValue&&(identical(other.token, token) || other.token == token)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.server, server) || other.server == server)&&(identical(other.key, key) || other.key == key)&&(identical(other.password, password) || other.password == password)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.secretKey, secretKey) || other.secretKey == secretKey)&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.uids, uids) || other.uids == uids)&&(identical(other.pushKey, pushKey) || other.pushKey == pushKey)&&(identical(other.deviceKey, deviceKey) || other.deviceKey == deviceKey)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.welfare, welfare) || other.welfare == welfare)&&(identical(other.proxy, proxy) || other.proxy == proxy)&&(identical(other.telegramToken, telegramToken) || other.telegramToken == telegramToken)&&(identical(other.telegramChatId, telegramChatId) || other.telegramChatId == telegramChatId)&&(identical(other.template, template) || other.template == template)&&(identical(other.corpId, corpId) || other.corpId == corpId)&&(identical(other.corpSecret, corpSecret) || other.corpSecret == corpSecret)&&(identical(other.agentId, agentId) || other.agentId == agentId)&&(identical(other.toUid, toUid) || other.toUid == toUid)&&(identical(other.username, username) || other.username == username)&&(identical(other.cookie, cookie) || other.cookie == cookie)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.todaySay, todaySay) || other.todaySay == todaySay)&&(identical(other.aliyundriveNotice, aliyundriveNotice) || other.aliyundriveNotice == aliyundriveNotice)&&(identical(other.siteData, siteData) || other.siteData == siteData)&&(identical(other.siteDataSuccess, siteDataSuccess) || other.siteDataSuccess == siteDataSuccess)&&(identical(other.todayData, todayData) || other.todayData == todayData)&&(identical(other.packageTorrent, packageTorrent) || other.packageTorrent == packageTorrent)&&(identical(other.deleteTorrent, deleteTorrent) || other.deleteTorrent == deleteTorrent)&&(identical(other.rssTorrent, rssTorrent) || other.rssTorrent == rssTorrent)&&(identical(other.pushTorrent, pushTorrent) || other.pushTorrent == pushTorrent)&&(identical(other.programUpgrade, programUpgrade) || other.programUpgrade == programUpgrade)&&(identical(other.ptppImport, ptppImport) || other.ptppImport == ptppImport)&&(identical(other.announcement, announcement) || other.announcement == announcement)&&(identical(other.message, message) || other.message == message)&&(identical(other.signInSuccess, signInSuccess) || other.signInSuccess == signInSuccess)&&(identical(other.cookieSync, cookieSync) || other.cookieSync == cookieSync)&&(identical(other.level, level) || other.level == level)&&(identical(other.bonus, bonus) || other.bonus == bonus)&&(identical(other.perBonus, perBonus) || other.perBonus == perBonus)&&(identical(other.score, score) || other.score == score)&&(identical(other.ratio, ratio) || other.ratio == ratio)&&(identical(other.seedingVol, seedingVol) || other.seedingVol == seedingVol)&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded)&&(identical(other.seeding, seeding) || other.seeding == seeding)&&(identical(other.leeching, leeching) || other.leeching == leeching)&&(identical(other.invite, invite) || other.invite == invite)&&(identical(other.hr, hr) || other.hr == hr)&&(identical(other.count, count) || other.count == count)&&(identical(other.maxCount, maxCount) || other.maxCount == maxCount)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,token,refreshToken,server,key,password,apiKey,secretKey,appId,uids,pushKey,deviceKey,repeat,welfare,proxy,telegramToken,telegramChatId,template,corpId,corpSecret,agentId,toUid,username,cookie,userAgent,todaySay,aliyundriveNotice,siteData,siteDataSuccess,todayData,packageTorrent,deleteTorrent,rssTorrent,pushTorrent,programUpgrade,ptppImport,announcement,message,signInSuccess,cookieSync,level,bonus,perBonus,score,ratio,seedingVol,uploaded,downloaded,seeding,leeching,invite,hr,count,maxCount,limit]);

@override
String toString() {
  return 'OptionValue(token: $token, refreshToken: $refreshToken, server: $server, key: $key, password: $password, apiKey: $apiKey, secretKey: $secretKey, appId: $appId, uids: $uids, pushKey: $pushKey, deviceKey: $deviceKey, repeat: $repeat, welfare: $welfare, proxy: $proxy, telegramToken: $telegramToken, telegramChatId: $telegramChatId, template: $template, corpId: $corpId, corpSecret: $corpSecret, agentId: $agentId, toUid: $toUid, username: $username, cookie: $cookie, userAgent: $userAgent, todaySay: $todaySay, aliyundriveNotice: $aliyundriveNotice, siteData: $siteData, siteDataSuccess: $siteDataSuccess, todayData: $todayData, packageTorrent: $packageTorrent, deleteTorrent: $deleteTorrent, rssTorrent: $rssTorrent, pushTorrent: $pushTorrent, programUpgrade: $programUpgrade, ptppImport: $ptppImport, announcement: $announcement, message: $message, signInSuccess: $signInSuccess, cookieSync: $cookieSync, level: $level, bonus: $bonus, perBonus: $perBonus, score: $score, ratio: $ratio, seedingVol: $seedingVol, uploaded: $uploaded, downloaded: $downloaded, seeding: $seeding, leeching: $leeching, invite: $invite, hr: $hr, count: $count, maxCount: $maxCount, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $OptionValueCopyWith<$Res>  {
  factory $OptionValueCopyWith(OptionValue value, $Res Function(OptionValue) _then) = _$OptionValueCopyWithImpl;
@useResult
$Res call({
 String? token,@JsonKey(name: 'refresh_token', fromJson: _dynamicToString) String? refreshToken, String? server, String? key, String? password,@JsonKey(name: 'api_key') String? apiKey,@JsonKey(name: 'secret_key') String? secretKey,@JsonKey(name: 'app_id') String? appId, String? uids,@JsonKey(name: 'pushkey') String? pushKey,@JsonKey(name: 'device_key') String? deviceKey, bool? repeat, bool? welfare, String? proxy,@JsonKey(name: 'telegram_token') String? telegramToken,@JsonKey(name: 'telegram_chat_id') String? telegramChatId, String? template,@JsonKey(name: 'corp_id') String? corpId,@JsonKey(name: 'corpsecret') String? corpSecret,@JsonKey(name: 'agent_id') String? agentId,@JsonKey(name: 'to_uid') String? toUid, String? username, String? cookie,@JsonKey(name: 'user_agent') String? userAgent,@JsonKey(name: 'todaysay', fromJson: _dynamicToString) String? todaySay,@JsonKey(name: 'aliyundrive_notice') bool? aliyundriveNotice,@JsonKey(name: 'site_data') bool? siteData,@JsonKey(name: 'site_data_success') bool? siteDataSuccess,@JsonKey(name: 'today_data') bool? todayData,@JsonKey(name: 'package_torrent') bool? packageTorrent,@JsonKey(name: 'delete_torrent') bool? deleteTorrent,@JsonKey(name: 'rss_torrent') bool? rssTorrent,@JsonKey(name: 'push_torrent') bool? pushTorrent,@JsonKey(name: 'program_upgrade') bool? programUpgrade,@JsonKey(name: 'ptpp_import') bool? ptppImport, bool? announcement, bool? message,@JsonKey(name: 'sign_in_success') bool? signInSuccess,@JsonKey(name: 'cookie_sync') bool? cookieSync, bool? level, bool? bonus,@JsonKey(name: 'per_bonus') bool? perBonus, bool? score, bool? ratio,@JsonKey(name: 'seeding_vol') bool? seedingVol, bool? uploaded, bool? downloaded, bool? seeding, bool? leeching, bool? invite, bool? hr, int? count,@JsonKey(name: 'max_count') int? maxCount, int? limit
});




}
/// @nodoc
class _$OptionValueCopyWithImpl<$Res>
    implements $OptionValueCopyWith<$Res> {
  _$OptionValueCopyWithImpl(this._self, this._then);

  final OptionValue _self;
  final $Res Function(OptionValue) _then;

/// Create a copy of OptionValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = freezed,Object? refreshToken = freezed,Object? server = freezed,Object? key = freezed,Object? password = freezed,Object? apiKey = freezed,Object? secretKey = freezed,Object? appId = freezed,Object? uids = freezed,Object? pushKey = freezed,Object? deviceKey = freezed,Object? repeat = freezed,Object? welfare = freezed,Object? proxy = freezed,Object? telegramToken = freezed,Object? telegramChatId = freezed,Object? template = freezed,Object? corpId = freezed,Object? corpSecret = freezed,Object? agentId = freezed,Object? toUid = freezed,Object? username = freezed,Object? cookie = freezed,Object? userAgent = freezed,Object? todaySay = freezed,Object? aliyundriveNotice = freezed,Object? siteData = freezed,Object? siteDataSuccess = freezed,Object? todayData = freezed,Object? packageTorrent = freezed,Object? deleteTorrent = freezed,Object? rssTorrent = freezed,Object? pushTorrent = freezed,Object? programUpgrade = freezed,Object? ptppImport = freezed,Object? announcement = freezed,Object? message = freezed,Object? signInSuccess = freezed,Object? cookieSync = freezed,Object? level = freezed,Object? bonus = freezed,Object? perBonus = freezed,Object? score = freezed,Object? ratio = freezed,Object? seedingVol = freezed,Object? uploaded = freezed,Object? downloaded = freezed,Object? seeding = freezed,Object? leeching = freezed,Object? invite = freezed,Object? hr = freezed,Object? count = freezed,Object? maxCount = freezed,Object? limit = freezed,}) {
  return _then(_self.copyWith(
token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,apiKey: freezed == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String?,secretKey: freezed == secretKey ? _self.secretKey : secretKey // ignore: cast_nullable_to_non_nullable
as String?,appId: freezed == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String?,uids: freezed == uids ? _self.uids : uids // ignore: cast_nullable_to_non_nullable
as String?,pushKey: freezed == pushKey ? _self.pushKey : pushKey // ignore: cast_nullable_to_non_nullable
as String?,deviceKey: freezed == deviceKey ? _self.deviceKey : deviceKey // ignore: cast_nullable_to_non_nullable
as String?,repeat: freezed == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as bool?,welfare: freezed == welfare ? _self.welfare : welfare // ignore: cast_nullable_to_non_nullable
as bool?,proxy: freezed == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as String?,telegramToken: freezed == telegramToken ? _self.telegramToken : telegramToken // ignore: cast_nullable_to_non_nullable
as String?,telegramChatId: freezed == telegramChatId ? _self.telegramChatId : telegramChatId // ignore: cast_nullable_to_non_nullable
as String?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String?,corpId: freezed == corpId ? _self.corpId : corpId // ignore: cast_nullable_to_non_nullable
as String?,corpSecret: freezed == corpSecret ? _self.corpSecret : corpSecret // ignore: cast_nullable_to_non_nullable
as String?,agentId: freezed == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as String?,toUid: freezed == toUid ? _self.toUid : toUid // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,cookie: freezed == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,todaySay: freezed == todaySay ? _self.todaySay : todaySay // ignore: cast_nullable_to_non_nullable
as String?,aliyundriveNotice: freezed == aliyundriveNotice ? _self.aliyundriveNotice : aliyundriveNotice // ignore: cast_nullable_to_non_nullable
as bool?,siteData: freezed == siteData ? _self.siteData : siteData // ignore: cast_nullable_to_non_nullable
as bool?,siteDataSuccess: freezed == siteDataSuccess ? _self.siteDataSuccess : siteDataSuccess // ignore: cast_nullable_to_non_nullable
as bool?,todayData: freezed == todayData ? _self.todayData : todayData // ignore: cast_nullable_to_non_nullable
as bool?,packageTorrent: freezed == packageTorrent ? _self.packageTorrent : packageTorrent // ignore: cast_nullable_to_non_nullable
as bool?,deleteTorrent: freezed == deleteTorrent ? _self.deleteTorrent : deleteTorrent // ignore: cast_nullable_to_non_nullable
as bool?,rssTorrent: freezed == rssTorrent ? _self.rssTorrent : rssTorrent // ignore: cast_nullable_to_non_nullable
as bool?,pushTorrent: freezed == pushTorrent ? _self.pushTorrent : pushTorrent // ignore: cast_nullable_to_non_nullable
as bool?,programUpgrade: freezed == programUpgrade ? _self.programUpgrade : programUpgrade // ignore: cast_nullable_to_non_nullable
as bool?,ptppImport: freezed == ptppImport ? _self.ptppImport : ptppImport // ignore: cast_nullable_to_non_nullable
as bool?,announcement: freezed == announcement ? _self.announcement : announcement // ignore: cast_nullable_to_non_nullable
as bool?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as bool?,signInSuccess: freezed == signInSuccess ? _self.signInSuccess : signInSuccess // ignore: cast_nullable_to_non_nullable
as bool?,cookieSync: freezed == cookieSync ? _self.cookieSync : cookieSync // ignore: cast_nullable_to_non_nullable
as bool?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as bool?,bonus: freezed == bonus ? _self.bonus : bonus // ignore: cast_nullable_to_non_nullable
as bool?,perBonus: freezed == perBonus ? _self.perBonus : perBonus // ignore: cast_nullable_to_non_nullable
as bool?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as bool?,ratio: freezed == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as bool?,seedingVol: freezed == seedingVol ? _self.seedingVol : seedingVol // ignore: cast_nullable_to_non_nullable
as bool?,uploaded: freezed == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as bool?,downloaded: freezed == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as bool?,seeding: freezed == seeding ? _self.seeding : seeding // ignore: cast_nullable_to_non_nullable
as bool?,leeching: freezed == leeching ? _self.leeching : leeching // ignore: cast_nullable_to_non_nullable
as bool?,invite: freezed == invite ? _self.invite : invite // ignore: cast_nullable_to_non_nullable
as bool?,hr: freezed == hr ? _self.hr : hr // ignore: cast_nullable_to_non_nullable
as bool?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,maxCount: freezed == maxCount ? _self.maxCount : maxCount // ignore: cast_nullable_to_non_nullable
as int?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [OptionValue].
extension OptionValuePatterns on OptionValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OptionValue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OptionValue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OptionValue value)  $default,){
final _that = this;
switch (_that) {
case _OptionValue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OptionValue value)?  $default,){
final _that = this;
switch (_that) {
case _OptionValue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? token, @JsonKey(name: 'refresh_token', fromJson: _dynamicToString)  String? refreshToken,  String? server,  String? key,  String? password, @JsonKey(name: 'api_key')  String? apiKey, @JsonKey(name: 'secret_key')  String? secretKey, @JsonKey(name: 'app_id')  String? appId,  String? uids, @JsonKey(name: 'pushkey')  String? pushKey, @JsonKey(name: 'device_key')  String? deviceKey,  bool? repeat,  bool? welfare,  String? proxy, @JsonKey(name: 'telegram_token')  String? telegramToken, @JsonKey(name: 'telegram_chat_id')  String? telegramChatId,  String? template, @JsonKey(name: 'corp_id')  String? corpId, @JsonKey(name: 'corpsecret')  String? corpSecret, @JsonKey(name: 'agent_id')  String? agentId, @JsonKey(name: 'to_uid')  String? toUid,  String? username,  String? cookie, @JsonKey(name: 'user_agent')  String? userAgent, @JsonKey(name: 'todaysay', fromJson: _dynamicToString)  String? todaySay, @JsonKey(name: 'aliyundrive_notice')  bool? aliyundriveNotice, @JsonKey(name: 'site_data')  bool? siteData, @JsonKey(name: 'site_data_success')  bool? siteDataSuccess, @JsonKey(name: 'today_data')  bool? todayData, @JsonKey(name: 'package_torrent')  bool? packageTorrent, @JsonKey(name: 'delete_torrent')  bool? deleteTorrent, @JsonKey(name: 'rss_torrent')  bool? rssTorrent, @JsonKey(name: 'push_torrent')  bool? pushTorrent, @JsonKey(name: 'program_upgrade')  bool? programUpgrade, @JsonKey(name: 'ptpp_import')  bool? ptppImport,  bool? announcement,  bool? message, @JsonKey(name: 'sign_in_success')  bool? signInSuccess, @JsonKey(name: 'cookie_sync')  bool? cookieSync,  bool? level,  bool? bonus, @JsonKey(name: 'per_bonus')  bool? perBonus,  bool? score,  bool? ratio, @JsonKey(name: 'seeding_vol')  bool? seedingVol,  bool? uploaded,  bool? downloaded,  bool? seeding,  bool? leeching,  bool? invite,  bool? hr,  int? count, @JsonKey(name: 'max_count')  int? maxCount,  int? limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OptionValue() when $default != null:
return $default(_that.token,_that.refreshToken,_that.server,_that.key,_that.password,_that.apiKey,_that.secretKey,_that.appId,_that.uids,_that.pushKey,_that.deviceKey,_that.repeat,_that.welfare,_that.proxy,_that.telegramToken,_that.telegramChatId,_that.template,_that.corpId,_that.corpSecret,_that.agentId,_that.toUid,_that.username,_that.cookie,_that.userAgent,_that.todaySay,_that.aliyundriveNotice,_that.siteData,_that.siteDataSuccess,_that.todayData,_that.packageTorrent,_that.deleteTorrent,_that.rssTorrent,_that.pushTorrent,_that.programUpgrade,_that.ptppImport,_that.announcement,_that.message,_that.signInSuccess,_that.cookieSync,_that.level,_that.bonus,_that.perBonus,_that.score,_that.ratio,_that.seedingVol,_that.uploaded,_that.downloaded,_that.seeding,_that.leeching,_that.invite,_that.hr,_that.count,_that.maxCount,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? token, @JsonKey(name: 'refresh_token', fromJson: _dynamicToString)  String? refreshToken,  String? server,  String? key,  String? password, @JsonKey(name: 'api_key')  String? apiKey, @JsonKey(name: 'secret_key')  String? secretKey, @JsonKey(name: 'app_id')  String? appId,  String? uids, @JsonKey(name: 'pushkey')  String? pushKey, @JsonKey(name: 'device_key')  String? deviceKey,  bool? repeat,  bool? welfare,  String? proxy, @JsonKey(name: 'telegram_token')  String? telegramToken, @JsonKey(name: 'telegram_chat_id')  String? telegramChatId,  String? template, @JsonKey(name: 'corp_id')  String? corpId, @JsonKey(name: 'corpsecret')  String? corpSecret, @JsonKey(name: 'agent_id')  String? agentId, @JsonKey(name: 'to_uid')  String? toUid,  String? username,  String? cookie, @JsonKey(name: 'user_agent')  String? userAgent, @JsonKey(name: 'todaysay', fromJson: _dynamicToString)  String? todaySay, @JsonKey(name: 'aliyundrive_notice')  bool? aliyundriveNotice, @JsonKey(name: 'site_data')  bool? siteData, @JsonKey(name: 'site_data_success')  bool? siteDataSuccess, @JsonKey(name: 'today_data')  bool? todayData, @JsonKey(name: 'package_torrent')  bool? packageTorrent, @JsonKey(name: 'delete_torrent')  bool? deleteTorrent, @JsonKey(name: 'rss_torrent')  bool? rssTorrent, @JsonKey(name: 'push_torrent')  bool? pushTorrent, @JsonKey(name: 'program_upgrade')  bool? programUpgrade, @JsonKey(name: 'ptpp_import')  bool? ptppImport,  bool? announcement,  bool? message, @JsonKey(name: 'sign_in_success')  bool? signInSuccess, @JsonKey(name: 'cookie_sync')  bool? cookieSync,  bool? level,  bool? bonus, @JsonKey(name: 'per_bonus')  bool? perBonus,  bool? score,  bool? ratio, @JsonKey(name: 'seeding_vol')  bool? seedingVol,  bool? uploaded,  bool? downloaded,  bool? seeding,  bool? leeching,  bool? invite,  bool? hr,  int? count, @JsonKey(name: 'max_count')  int? maxCount,  int? limit)  $default,) {final _that = this;
switch (_that) {
case _OptionValue():
return $default(_that.token,_that.refreshToken,_that.server,_that.key,_that.password,_that.apiKey,_that.secretKey,_that.appId,_that.uids,_that.pushKey,_that.deviceKey,_that.repeat,_that.welfare,_that.proxy,_that.telegramToken,_that.telegramChatId,_that.template,_that.corpId,_that.corpSecret,_that.agentId,_that.toUid,_that.username,_that.cookie,_that.userAgent,_that.todaySay,_that.aliyundriveNotice,_that.siteData,_that.siteDataSuccess,_that.todayData,_that.packageTorrent,_that.deleteTorrent,_that.rssTorrent,_that.pushTorrent,_that.programUpgrade,_that.ptppImport,_that.announcement,_that.message,_that.signInSuccess,_that.cookieSync,_that.level,_that.bonus,_that.perBonus,_that.score,_that.ratio,_that.seedingVol,_that.uploaded,_that.downloaded,_that.seeding,_that.leeching,_that.invite,_that.hr,_that.count,_that.maxCount,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? token, @JsonKey(name: 'refresh_token', fromJson: _dynamicToString)  String? refreshToken,  String? server,  String? key,  String? password, @JsonKey(name: 'api_key')  String? apiKey, @JsonKey(name: 'secret_key')  String? secretKey, @JsonKey(name: 'app_id')  String? appId,  String? uids, @JsonKey(name: 'pushkey')  String? pushKey, @JsonKey(name: 'device_key')  String? deviceKey,  bool? repeat,  bool? welfare,  String? proxy, @JsonKey(name: 'telegram_token')  String? telegramToken, @JsonKey(name: 'telegram_chat_id')  String? telegramChatId,  String? template, @JsonKey(name: 'corp_id')  String? corpId, @JsonKey(name: 'corpsecret')  String? corpSecret, @JsonKey(name: 'agent_id')  String? agentId, @JsonKey(name: 'to_uid')  String? toUid,  String? username,  String? cookie, @JsonKey(name: 'user_agent')  String? userAgent, @JsonKey(name: 'todaysay', fromJson: _dynamicToString)  String? todaySay, @JsonKey(name: 'aliyundrive_notice')  bool? aliyundriveNotice, @JsonKey(name: 'site_data')  bool? siteData, @JsonKey(name: 'site_data_success')  bool? siteDataSuccess, @JsonKey(name: 'today_data')  bool? todayData, @JsonKey(name: 'package_torrent')  bool? packageTorrent, @JsonKey(name: 'delete_torrent')  bool? deleteTorrent, @JsonKey(name: 'rss_torrent')  bool? rssTorrent, @JsonKey(name: 'push_torrent')  bool? pushTorrent, @JsonKey(name: 'program_upgrade')  bool? programUpgrade, @JsonKey(name: 'ptpp_import')  bool? ptppImport,  bool? announcement,  bool? message, @JsonKey(name: 'sign_in_success')  bool? signInSuccess, @JsonKey(name: 'cookie_sync')  bool? cookieSync,  bool? level,  bool? bonus, @JsonKey(name: 'per_bonus')  bool? perBonus,  bool? score,  bool? ratio, @JsonKey(name: 'seeding_vol')  bool? seedingVol,  bool? uploaded,  bool? downloaded,  bool? seeding,  bool? leeching,  bool? invite,  bool? hr,  int? count, @JsonKey(name: 'max_count')  int? maxCount,  int? limit)?  $default,) {final _that = this;
switch (_that) {
case _OptionValue() when $default != null:
return $default(_that.token,_that.refreshToken,_that.server,_that.key,_that.password,_that.apiKey,_that.secretKey,_that.appId,_that.uids,_that.pushKey,_that.deviceKey,_that.repeat,_that.welfare,_that.proxy,_that.telegramToken,_that.telegramChatId,_that.template,_that.corpId,_that.corpSecret,_that.agentId,_that.toUid,_that.username,_that.cookie,_that.userAgent,_that.todaySay,_that.aliyundriveNotice,_that.siteData,_that.siteDataSuccess,_that.todayData,_that.packageTorrent,_that.deleteTorrent,_that.rssTorrent,_that.pushTorrent,_that.programUpgrade,_that.ptppImport,_that.announcement,_that.message,_that.signInSuccess,_that.cookieSync,_that.level,_that.bonus,_that.perBonus,_that.score,_that.ratio,_that.seedingVol,_that.uploaded,_that.downloaded,_that.seeding,_that.leeching,_that.invite,_that.hr,_that.count,_that.maxCount,_that.limit);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _OptionValue implements OptionValue {
  const _OptionValue({this.token, @JsonKey(name: 'refresh_token', fromJson: _dynamicToString) this.refreshToken, this.server, this.key, this.password, @JsonKey(name: 'api_key') this.apiKey, @JsonKey(name: 'secret_key') this.secretKey, @JsonKey(name: 'app_id') this.appId, this.uids, @JsonKey(name: 'pushkey') this.pushKey, @JsonKey(name: 'device_key') this.deviceKey, this.repeat, this.welfare, this.proxy, @JsonKey(name: 'telegram_token') this.telegramToken, @JsonKey(name: 'telegram_chat_id') this.telegramChatId, this.template, @JsonKey(name: 'corp_id') this.corpId, @JsonKey(name: 'corpsecret') this.corpSecret, @JsonKey(name: 'agent_id') this.agentId, @JsonKey(name: 'to_uid') this.toUid, this.username, this.cookie, @JsonKey(name: 'user_agent') this.userAgent, @JsonKey(name: 'todaysay', fromJson: _dynamicToString) this.todaySay, @JsonKey(name: 'aliyundrive_notice') this.aliyundriveNotice, @JsonKey(name: 'site_data') this.siteData, @JsonKey(name: 'site_data_success') this.siteDataSuccess, @JsonKey(name: 'today_data') this.todayData, @JsonKey(name: 'package_torrent') this.packageTorrent, @JsonKey(name: 'delete_torrent') this.deleteTorrent, @JsonKey(name: 'rss_torrent') this.rssTorrent, @JsonKey(name: 'push_torrent') this.pushTorrent, @JsonKey(name: 'program_upgrade') this.programUpgrade, @JsonKey(name: 'ptpp_import') this.ptppImport, this.announcement, this.message, @JsonKey(name: 'sign_in_success') this.signInSuccess, @JsonKey(name: 'cookie_sync') this.cookieSync, this.level, this.bonus, @JsonKey(name: 'per_bonus') this.perBonus, this.score, this.ratio, @JsonKey(name: 'seeding_vol') this.seedingVol, this.uploaded, this.downloaded, this.seeding, this.leeching, this.invite, this.hr, this.count, @JsonKey(name: 'max_count') this.maxCount, this.limit});
  factory _OptionValue.fromJson(Map<String, dynamic> json) => _$OptionValueFromJson(json);

@override final  String? token;
@override@JsonKey(name: 'refresh_token', fromJson: _dynamicToString) final  String? refreshToken;
@override final  String? server;
@override final  String? key;
@override final  String? password;
@override@JsonKey(name: 'api_key') final  String? apiKey;
@override@JsonKey(name: 'secret_key') final  String? secretKey;
@override@JsonKey(name: 'app_id') final  String? appId;
@override final  String? uids;
@override@JsonKey(name: 'pushkey') final  String? pushKey;
@override@JsonKey(name: 'device_key') final  String? deviceKey;
@override final  bool? repeat;
@override final  bool? welfare;
@override final  String? proxy;
@override@JsonKey(name: 'telegram_token') final  String? telegramToken;
@override@JsonKey(name: 'telegram_chat_id') final  String? telegramChatId;
@override final  String? template;
@override@JsonKey(name: 'corp_id') final  String? corpId;
@override@JsonKey(name: 'corpsecret') final  String? corpSecret;
@override@JsonKey(name: 'agent_id') final  String? agentId;
@override@JsonKey(name: 'to_uid') final  String? toUid;
@override final  String? username;
@override final  String? cookie;
@override@JsonKey(name: 'user_agent') final  String? userAgent;
@override@JsonKey(name: 'todaysay', fromJson: _dynamicToString) final  String? todaySay;
@override@JsonKey(name: 'aliyundrive_notice') final  bool? aliyundriveNotice;
@override@JsonKey(name: 'site_data') final  bool? siteData;
@override@JsonKey(name: 'site_data_success') final  bool? siteDataSuccess;
@override@JsonKey(name: 'today_data') final  bool? todayData;
@override@JsonKey(name: 'package_torrent') final  bool? packageTorrent;
@override@JsonKey(name: 'delete_torrent') final  bool? deleteTorrent;
@override@JsonKey(name: 'rss_torrent') final  bool? rssTorrent;
@override@JsonKey(name: 'push_torrent') final  bool? pushTorrent;
@override@JsonKey(name: 'program_upgrade') final  bool? programUpgrade;
@override@JsonKey(name: 'ptpp_import') final  bool? ptppImport;
@override final  bool? announcement;
@override final  bool? message;
@override@JsonKey(name: 'sign_in_success') final  bool? signInSuccess;
@override@JsonKey(name: 'cookie_sync') final  bool? cookieSync;
@override final  bool? level;
@override final  bool? bonus;
@override@JsonKey(name: 'per_bonus') final  bool? perBonus;
@override final  bool? score;
@override final  bool? ratio;
@override@JsonKey(name: 'seeding_vol') final  bool? seedingVol;
@override final  bool? uploaded;
@override final  bool? downloaded;
@override final  bool? seeding;
@override final  bool? leeching;
@override final  bool? invite;
@override final  bool? hr;
@override final  int? count;
@override@JsonKey(name: 'max_count') final  int? maxCount;
@override final  int? limit;

/// Create a copy of OptionValue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OptionValueCopyWith<_OptionValue> get copyWith => __$OptionValueCopyWithImpl<_OptionValue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OptionValueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OptionValue&&(identical(other.token, token) || other.token == token)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.server, server) || other.server == server)&&(identical(other.key, key) || other.key == key)&&(identical(other.password, password) || other.password == password)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.secretKey, secretKey) || other.secretKey == secretKey)&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.uids, uids) || other.uids == uids)&&(identical(other.pushKey, pushKey) || other.pushKey == pushKey)&&(identical(other.deviceKey, deviceKey) || other.deviceKey == deviceKey)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.welfare, welfare) || other.welfare == welfare)&&(identical(other.proxy, proxy) || other.proxy == proxy)&&(identical(other.telegramToken, telegramToken) || other.telegramToken == telegramToken)&&(identical(other.telegramChatId, telegramChatId) || other.telegramChatId == telegramChatId)&&(identical(other.template, template) || other.template == template)&&(identical(other.corpId, corpId) || other.corpId == corpId)&&(identical(other.corpSecret, corpSecret) || other.corpSecret == corpSecret)&&(identical(other.agentId, agentId) || other.agentId == agentId)&&(identical(other.toUid, toUid) || other.toUid == toUid)&&(identical(other.username, username) || other.username == username)&&(identical(other.cookie, cookie) || other.cookie == cookie)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.todaySay, todaySay) || other.todaySay == todaySay)&&(identical(other.aliyundriveNotice, aliyundriveNotice) || other.aliyundriveNotice == aliyundriveNotice)&&(identical(other.siteData, siteData) || other.siteData == siteData)&&(identical(other.siteDataSuccess, siteDataSuccess) || other.siteDataSuccess == siteDataSuccess)&&(identical(other.todayData, todayData) || other.todayData == todayData)&&(identical(other.packageTorrent, packageTorrent) || other.packageTorrent == packageTorrent)&&(identical(other.deleteTorrent, deleteTorrent) || other.deleteTorrent == deleteTorrent)&&(identical(other.rssTorrent, rssTorrent) || other.rssTorrent == rssTorrent)&&(identical(other.pushTorrent, pushTorrent) || other.pushTorrent == pushTorrent)&&(identical(other.programUpgrade, programUpgrade) || other.programUpgrade == programUpgrade)&&(identical(other.ptppImport, ptppImport) || other.ptppImport == ptppImport)&&(identical(other.announcement, announcement) || other.announcement == announcement)&&(identical(other.message, message) || other.message == message)&&(identical(other.signInSuccess, signInSuccess) || other.signInSuccess == signInSuccess)&&(identical(other.cookieSync, cookieSync) || other.cookieSync == cookieSync)&&(identical(other.level, level) || other.level == level)&&(identical(other.bonus, bonus) || other.bonus == bonus)&&(identical(other.perBonus, perBonus) || other.perBonus == perBonus)&&(identical(other.score, score) || other.score == score)&&(identical(other.ratio, ratio) || other.ratio == ratio)&&(identical(other.seedingVol, seedingVol) || other.seedingVol == seedingVol)&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded)&&(identical(other.seeding, seeding) || other.seeding == seeding)&&(identical(other.leeching, leeching) || other.leeching == leeching)&&(identical(other.invite, invite) || other.invite == invite)&&(identical(other.hr, hr) || other.hr == hr)&&(identical(other.count, count) || other.count == count)&&(identical(other.maxCount, maxCount) || other.maxCount == maxCount)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,token,refreshToken,server,key,password,apiKey,secretKey,appId,uids,pushKey,deviceKey,repeat,welfare,proxy,telegramToken,telegramChatId,template,corpId,corpSecret,agentId,toUid,username,cookie,userAgent,todaySay,aliyundriveNotice,siteData,siteDataSuccess,todayData,packageTorrent,deleteTorrent,rssTorrent,pushTorrent,programUpgrade,ptppImport,announcement,message,signInSuccess,cookieSync,level,bonus,perBonus,score,ratio,seedingVol,uploaded,downloaded,seeding,leeching,invite,hr,count,maxCount,limit]);

@override
String toString() {
  return 'OptionValue(token: $token, refreshToken: $refreshToken, server: $server, key: $key, password: $password, apiKey: $apiKey, secretKey: $secretKey, appId: $appId, uids: $uids, pushKey: $pushKey, deviceKey: $deviceKey, repeat: $repeat, welfare: $welfare, proxy: $proxy, telegramToken: $telegramToken, telegramChatId: $telegramChatId, template: $template, corpId: $corpId, corpSecret: $corpSecret, agentId: $agentId, toUid: $toUid, username: $username, cookie: $cookie, userAgent: $userAgent, todaySay: $todaySay, aliyundriveNotice: $aliyundriveNotice, siteData: $siteData, siteDataSuccess: $siteDataSuccess, todayData: $todayData, packageTorrent: $packageTorrent, deleteTorrent: $deleteTorrent, rssTorrent: $rssTorrent, pushTorrent: $pushTorrent, programUpgrade: $programUpgrade, ptppImport: $ptppImport, announcement: $announcement, message: $message, signInSuccess: $signInSuccess, cookieSync: $cookieSync, level: $level, bonus: $bonus, perBonus: $perBonus, score: $score, ratio: $ratio, seedingVol: $seedingVol, uploaded: $uploaded, downloaded: $downloaded, seeding: $seeding, leeching: $leeching, invite: $invite, hr: $hr, count: $count, maxCount: $maxCount, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$OptionValueCopyWith<$Res> implements $OptionValueCopyWith<$Res> {
  factory _$OptionValueCopyWith(_OptionValue value, $Res Function(_OptionValue) _then) = __$OptionValueCopyWithImpl;
@override @useResult
$Res call({
 String? token,@JsonKey(name: 'refresh_token', fromJson: _dynamicToString) String? refreshToken, String? server, String? key, String? password,@JsonKey(name: 'api_key') String? apiKey,@JsonKey(name: 'secret_key') String? secretKey,@JsonKey(name: 'app_id') String? appId, String? uids,@JsonKey(name: 'pushkey') String? pushKey,@JsonKey(name: 'device_key') String? deviceKey, bool? repeat, bool? welfare, String? proxy,@JsonKey(name: 'telegram_token') String? telegramToken,@JsonKey(name: 'telegram_chat_id') String? telegramChatId, String? template,@JsonKey(name: 'corp_id') String? corpId,@JsonKey(name: 'corpsecret') String? corpSecret,@JsonKey(name: 'agent_id') String? agentId,@JsonKey(name: 'to_uid') String? toUid, String? username, String? cookie,@JsonKey(name: 'user_agent') String? userAgent,@JsonKey(name: 'todaysay', fromJson: _dynamicToString) String? todaySay,@JsonKey(name: 'aliyundrive_notice') bool? aliyundriveNotice,@JsonKey(name: 'site_data') bool? siteData,@JsonKey(name: 'site_data_success') bool? siteDataSuccess,@JsonKey(name: 'today_data') bool? todayData,@JsonKey(name: 'package_torrent') bool? packageTorrent,@JsonKey(name: 'delete_torrent') bool? deleteTorrent,@JsonKey(name: 'rss_torrent') bool? rssTorrent,@JsonKey(name: 'push_torrent') bool? pushTorrent,@JsonKey(name: 'program_upgrade') bool? programUpgrade,@JsonKey(name: 'ptpp_import') bool? ptppImport, bool? announcement, bool? message,@JsonKey(name: 'sign_in_success') bool? signInSuccess,@JsonKey(name: 'cookie_sync') bool? cookieSync, bool? level, bool? bonus,@JsonKey(name: 'per_bonus') bool? perBonus, bool? score, bool? ratio,@JsonKey(name: 'seeding_vol') bool? seedingVol, bool? uploaded, bool? downloaded, bool? seeding, bool? leeching, bool? invite, bool? hr, int? count,@JsonKey(name: 'max_count') int? maxCount, int? limit
});




}
/// @nodoc
class __$OptionValueCopyWithImpl<$Res>
    implements _$OptionValueCopyWith<$Res> {
  __$OptionValueCopyWithImpl(this._self, this._then);

  final _OptionValue _self;
  final $Res Function(_OptionValue) _then;

/// Create a copy of OptionValue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = freezed,Object? refreshToken = freezed,Object? server = freezed,Object? key = freezed,Object? password = freezed,Object? apiKey = freezed,Object? secretKey = freezed,Object? appId = freezed,Object? uids = freezed,Object? pushKey = freezed,Object? deviceKey = freezed,Object? repeat = freezed,Object? welfare = freezed,Object? proxy = freezed,Object? telegramToken = freezed,Object? telegramChatId = freezed,Object? template = freezed,Object? corpId = freezed,Object? corpSecret = freezed,Object? agentId = freezed,Object? toUid = freezed,Object? username = freezed,Object? cookie = freezed,Object? userAgent = freezed,Object? todaySay = freezed,Object? aliyundriveNotice = freezed,Object? siteData = freezed,Object? siteDataSuccess = freezed,Object? todayData = freezed,Object? packageTorrent = freezed,Object? deleteTorrent = freezed,Object? rssTorrent = freezed,Object? pushTorrent = freezed,Object? programUpgrade = freezed,Object? ptppImport = freezed,Object? announcement = freezed,Object? message = freezed,Object? signInSuccess = freezed,Object? cookieSync = freezed,Object? level = freezed,Object? bonus = freezed,Object? perBonus = freezed,Object? score = freezed,Object? ratio = freezed,Object? seedingVol = freezed,Object? uploaded = freezed,Object? downloaded = freezed,Object? seeding = freezed,Object? leeching = freezed,Object? invite = freezed,Object? hr = freezed,Object? count = freezed,Object? maxCount = freezed,Object? limit = freezed,}) {
  return _then(_OptionValue(
token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,apiKey: freezed == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String?,secretKey: freezed == secretKey ? _self.secretKey : secretKey // ignore: cast_nullable_to_non_nullable
as String?,appId: freezed == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String?,uids: freezed == uids ? _self.uids : uids // ignore: cast_nullable_to_non_nullable
as String?,pushKey: freezed == pushKey ? _self.pushKey : pushKey // ignore: cast_nullable_to_non_nullable
as String?,deviceKey: freezed == deviceKey ? _self.deviceKey : deviceKey // ignore: cast_nullable_to_non_nullable
as String?,repeat: freezed == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as bool?,welfare: freezed == welfare ? _self.welfare : welfare // ignore: cast_nullable_to_non_nullable
as bool?,proxy: freezed == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as String?,telegramToken: freezed == telegramToken ? _self.telegramToken : telegramToken // ignore: cast_nullable_to_non_nullable
as String?,telegramChatId: freezed == telegramChatId ? _self.telegramChatId : telegramChatId // ignore: cast_nullable_to_non_nullable
as String?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String?,corpId: freezed == corpId ? _self.corpId : corpId // ignore: cast_nullable_to_non_nullable
as String?,corpSecret: freezed == corpSecret ? _self.corpSecret : corpSecret // ignore: cast_nullable_to_non_nullable
as String?,agentId: freezed == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as String?,toUid: freezed == toUid ? _self.toUid : toUid // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,cookie: freezed == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,todaySay: freezed == todaySay ? _self.todaySay : todaySay // ignore: cast_nullable_to_non_nullable
as String?,aliyundriveNotice: freezed == aliyundriveNotice ? _self.aliyundriveNotice : aliyundriveNotice // ignore: cast_nullable_to_non_nullable
as bool?,siteData: freezed == siteData ? _self.siteData : siteData // ignore: cast_nullable_to_non_nullable
as bool?,siteDataSuccess: freezed == siteDataSuccess ? _self.siteDataSuccess : siteDataSuccess // ignore: cast_nullable_to_non_nullable
as bool?,todayData: freezed == todayData ? _self.todayData : todayData // ignore: cast_nullable_to_non_nullable
as bool?,packageTorrent: freezed == packageTorrent ? _self.packageTorrent : packageTorrent // ignore: cast_nullable_to_non_nullable
as bool?,deleteTorrent: freezed == deleteTorrent ? _self.deleteTorrent : deleteTorrent // ignore: cast_nullable_to_non_nullable
as bool?,rssTorrent: freezed == rssTorrent ? _self.rssTorrent : rssTorrent // ignore: cast_nullable_to_non_nullable
as bool?,pushTorrent: freezed == pushTorrent ? _self.pushTorrent : pushTorrent // ignore: cast_nullable_to_non_nullable
as bool?,programUpgrade: freezed == programUpgrade ? _self.programUpgrade : programUpgrade // ignore: cast_nullable_to_non_nullable
as bool?,ptppImport: freezed == ptppImport ? _self.ptppImport : ptppImport // ignore: cast_nullable_to_non_nullable
as bool?,announcement: freezed == announcement ? _self.announcement : announcement // ignore: cast_nullable_to_non_nullable
as bool?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as bool?,signInSuccess: freezed == signInSuccess ? _self.signInSuccess : signInSuccess // ignore: cast_nullable_to_non_nullable
as bool?,cookieSync: freezed == cookieSync ? _self.cookieSync : cookieSync // ignore: cast_nullable_to_non_nullable
as bool?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as bool?,bonus: freezed == bonus ? _self.bonus : bonus // ignore: cast_nullable_to_non_nullable
as bool?,perBonus: freezed == perBonus ? _self.perBonus : perBonus // ignore: cast_nullable_to_non_nullable
as bool?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as bool?,ratio: freezed == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as bool?,seedingVol: freezed == seedingVol ? _self.seedingVol : seedingVol // ignore: cast_nullable_to_non_nullable
as bool?,uploaded: freezed == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as bool?,downloaded: freezed == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as bool?,seeding: freezed == seeding ? _self.seeding : seeding // ignore: cast_nullable_to_non_nullable
as bool?,leeching: freezed == leeching ? _self.leeching : leeching // ignore: cast_nullable_to_non_nullable
as bool?,invite: freezed == invite ? _self.invite : invite // ignore: cast_nullable_to_non_nullable
as bool?,hr: freezed == hr ? _self.hr : hr // ignore: cast_nullable_to_non_nullable
as bool?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,maxCount: freezed == maxCount ? _self.maxCount : maxCount // ignore: cast_nullable_to_non_nullable
as int?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Option {

 int? get id; String get name; OptionValue get value;@JsonKey(name: 'is_active') bool get isActive;
/// Create a copy of Option
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OptionCopyWith<Option> get copyWith => _$OptionCopyWithImpl<Option>(this as Option, _$identity);

  /// Serializes this Option to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Option&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,value,isActive);

@override
String toString() {
  return 'Option(id: $id, name: $name, value: $value, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $OptionCopyWith<$Res>  {
  factory $OptionCopyWith(Option value, $Res Function(Option) _then) = _$OptionCopyWithImpl;
@useResult
$Res call({
 int? id, String name, OptionValue value,@JsonKey(name: 'is_active') bool isActive
});


$OptionValueCopyWith<$Res> get value;

}
/// @nodoc
class _$OptionCopyWithImpl<$Res>
    implements $OptionCopyWith<$Res> {
  _$OptionCopyWithImpl(this._self, this._then);

  final Option _self;
  final $Res Function(Option) _then;

/// Create a copy of Option
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? value = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as OptionValue,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Option
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OptionValueCopyWith<$Res> get value {
  
  return $OptionValueCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}


/// Adds pattern-matching-related methods to [Option].
extension OptionPatterns on Option {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Option value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Option() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Option value)  $default,){
final _that = this;
switch (_that) {
case _Option():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Option value)?  $default,){
final _that = this;
switch (_that) {
case _Option() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  OptionValue value, @JsonKey(name: 'is_active')  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Option() when $default != null:
return $default(_that.id,_that.name,_that.value,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  OptionValue value, @JsonKey(name: 'is_active')  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _Option():
return $default(_that.id,_that.name,_that.value,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  OptionValue value, @JsonKey(name: 'is_active')  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _Option() when $default != null:
return $default(_that.id,_that.name,_that.value,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Option implements Option {
  const _Option({required this.id, required this.name, required this.value, @JsonKey(name: 'is_active') required this.isActive});
  factory _Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);

@override final  int? id;
@override final  String name;
@override final  OptionValue value;
@override@JsonKey(name: 'is_active') final  bool isActive;

/// Create a copy of Option
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OptionCopyWith<_Option> get copyWith => __$OptionCopyWithImpl<_Option>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Option&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,value,isActive);

@override
String toString() {
  return 'Option(id: $id, name: $name, value: $value, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$OptionCopyWith<$Res> implements $OptionCopyWith<$Res> {
  factory _$OptionCopyWith(_Option value, $Res Function(_Option) _then) = __$OptionCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, OptionValue value,@JsonKey(name: 'is_active') bool isActive
});


@override $OptionValueCopyWith<$Res> get value;

}
/// @nodoc
class __$OptionCopyWithImpl<$Res>
    implements _$OptionCopyWith<$Res> {
  __$OptionCopyWithImpl(this._self, this._then);

  final _Option _self;
  final $Res Function(_Option) _then;

/// Create a copy of Option
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? value = null,Object? isActive = null,}) {
  return _then(_Option(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as OptionValue,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Option
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OptionValueCopyWith<$Res> get value {
  
  return $OptionValueCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}


/// @nodoc
mixin _$SelectOption {

 String get name; String get value;
/// Create a copy of SelectOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectOptionCopyWith<SelectOption> get copyWith => _$SelectOptionCopyWithImpl<SelectOption>(this as SelectOption, _$identity);

  /// Serializes this SelectOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectOption&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'SelectOption(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class $SelectOptionCopyWith<$Res>  {
  factory $SelectOptionCopyWith(SelectOption value, $Res Function(SelectOption) _then) = _$SelectOptionCopyWithImpl;
@useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class _$SelectOptionCopyWithImpl<$Res>
    implements $SelectOptionCopyWith<$Res> {
  _$SelectOptionCopyWithImpl(this._self, this._then);

  final SelectOption _self;
  final $Res Function(SelectOption) _then;

/// Create a copy of SelectOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectOption].
extension SelectOptionPatterns on SelectOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectOption value)  $default,){
final _that = this;
switch (_that) {
case _SelectOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectOption value)?  $default,){
final _that = this;
switch (_that) {
case _SelectOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectOption() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String value)  $default,) {final _that = this;
switch (_that) {
case _SelectOption():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String value)?  $default,) {final _that = this;
switch (_that) {
case _SelectOption() when $default != null:
return $default(_that.name,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SelectOption implements SelectOption {
  const _SelectOption({required this.name, required this.value});
  factory _SelectOption.fromJson(Map<String, dynamic> json) => _$SelectOptionFromJson(json);

@override final  String name;
@override final  String value;

/// Create a copy of SelectOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectOptionCopyWith<_SelectOption> get copyWith => __$SelectOptionCopyWithImpl<_SelectOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectOption&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'SelectOption(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class _$SelectOptionCopyWith<$Res> implements $SelectOptionCopyWith<$Res> {
  factory _$SelectOptionCopyWith(_SelectOption value, $Res Function(_SelectOption) _then) = __$SelectOptionCopyWithImpl;
@override @useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class __$SelectOptionCopyWithImpl<$Res>
    implements _$SelectOptionCopyWith<$Res> {
  __$SelectOptionCopyWithImpl(this._self, this._then);

  final _SelectOption _self;
  final $Res Function(_SelectOption) _then;

/// Create a copy of SelectOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,}) {
  return _then(_SelectOption(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
