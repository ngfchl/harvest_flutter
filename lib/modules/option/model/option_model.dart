import 'package:freezed_annotation/freezed_annotation.dart';

part 'option_model.freezed.dart';
part 'option_model.g.dart';

String? _dynamicToString(dynamic v) => v?.toString();

@freezed
abstract class OptionValue with _$OptionValue {
  @JsonSerializable(includeIfNull: false)
  const factory OptionValue({
    String? token,
    @JsonKey(name: 'refresh_token', fromJson: _dynamicToString) String? refreshToken,
    String? server,
    String? key,
    String? password,
    @JsonKey(name: 'api_key') String? apiKey,
    @JsonKey(name: 'secret_key') String? secretKey,
    @JsonKey(name: 'app_id') String? appId,
    String? uids,
    @JsonKey(name: 'pushkey') String? pushKey,
    @JsonKey(name: 'device_key') String? deviceKey,
    bool? repeat,
    bool? welfare,
    String? proxy,
    @JsonKey(name: 'telegram_token') String? telegramToken,
    @JsonKey(name: 'telegram_chat_id') String? telegramChatId,
    String? template,
    @JsonKey(name: 'corp_id') String? corpId,
    @JsonKey(name: 'corpsecret') String? corpSecret,
    @JsonKey(name: 'agent_id') String? agentId,
    @JsonKey(name: 'to_uid') String? toUid,
    String? username,
    String? cookie,
    @JsonKey(name: 'user_agent') String? userAgent,
    @JsonKey(name: 'todaysay', fromJson: _dynamicToString) String? todaySay,
    @JsonKey(name: 'aliyundrive_notice') bool? aliyundriveNotice,
    @JsonKey(name: 'site_data') bool? siteData,
    @JsonKey(name: 'site_data_success') bool? siteDataSuccess,
    @JsonKey(name: 'today_data') bool? todayData,
    @JsonKey(name: 'package_torrent') bool? packageTorrent,
    @JsonKey(name: 'delete_torrent') bool? deleteTorrent,
    @JsonKey(name: 'rss_torrent') bool? rssTorrent,
    @JsonKey(name: 'push_torrent') bool? pushTorrent,
    @JsonKey(name: 'program_upgrade') bool? programUpgrade,
    @JsonKey(name: 'ptpp_import') bool? ptppImport,
    bool? announcement,
    bool? message,
    @JsonKey(name: 'sign_in_success') bool? signInSuccess,
    @JsonKey(name: 'cookie_sync') bool? cookieSync,
    bool? level,
    bool? bonus,
    @JsonKey(name: 'per_bonus') bool? perBonus,
    bool? score,
    bool? ratio,
    @JsonKey(name: 'seeding_vol') bool? seedingVol,
    bool? uploaded,
    bool? downloaded,
    bool? seeding,
    bool? leeching,
    bool? invite,
    bool? hr,
    int? count,
    @JsonKey(name: 'max_count') int? maxCount,
    int? limit,
  }) = _OptionValue;

  factory OptionValue.fromJson(Map<String, dynamic> json) => _$OptionValueFromJson(json);
}

@freezed
abstract class Option with _$Option {
  const factory Option({
    required int? id,
    required String name,
    required OptionValue value,
    @JsonKey(name: 'is_active') required bool isActive,
  }) = _Option;

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
}

@freezed
abstract class SelectOption with _$SelectOption {
  const factory SelectOption({required String name, required String value}) = _SelectOption;

  factory SelectOption.fromJson(Map<String, dynamic> json) => _$SelectOptionFromJson(json);
}
