import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/kv/kv.dart';

part 'dashboard_data.freezed.dart';
part 'dashboard_data.g.dart';

@freezed
abstract class EarliestSite with _$EarliestSite {
  const factory EarliestSite({
    @Default(0) int id,
    required String site,
    @JsonKey(name: 'time_join') String? timeJoin,
    @JsonKey(name: 'latest_active') String? latestActive,
  }) = _EarliestSite;

  factory EarliestSite.fromJson(Map<String, dynamic> json) => _$EarliestSiteFromJson(json);
}

@freezed
abstract class StatusRecord with _$StatusRecord {
  const factory StatusRecord({
    @JsonKey(name: 'created_at') required String createdAt,
    @Default(0) num uploaded,
    @Default(0) num downloaded,
    @Default(0) num published,
  }) = _StatusRecord;

  factory StatusRecord.fromJson(Map<String, dynamic> json) => _$StatusRecordFromJson(json);
}

@freezed
abstract class UploadRecord with _$UploadRecord {
  const factory UploadRecord({
    @JsonKey(name: 'created_at') required String createdAt,
    @Default(0) num uploaded,
    @Default(0) num downloaded,
  }) = _UploadRecord;

  factory UploadRecord.fromJson(Map<String, dynamic> json) => _$UploadRecordFromJson(json);
}

@freezed
abstract class MonthSiteData with _$MonthSiteData {
  const factory MonthSiteData({required String name, @Default([]) List<StatusRecord> value}) = _MonthSiteData;

  factory MonthSiteData.fromJson(Map<String, dynamic> json) => _$MonthSiteDataFromJson(json);
}

@freezed
abstract class SiteStatusData with _$SiteStatusData {
  const factory SiteStatusData({required String name, required StatusRecord value}) = _SiteStatusData;

  factory SiteStatusData.fromJson(Map<String, dynamic> json) => _$SiteStatusDataFromJson(json);
}

@freezed
abstract class StackSiteData with _$StackSiteData {
  const factory StackSiteData({required String name, @Default([]) List<UploadRecord> value}) = _StackSiteData;

  factory StackSiteData.fromJson(Map<String, dynamic> json) => _$StackSiteDataFromJson(json);
}

@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    @Default([]) List<KV> emailCount,
    @Default([]) List<KV> usernameCount,
    @Default(0) num totalUploaded,
    @Default(0) num totalDownloaded,
    @Default(0) num totalSeedVol,
    @Default(0) num totalSeeding,
    @Default(0) num totalLeeching,
    @Default(0) num todayUploadIncrement,
    @Default(0) num todayDownloadIncrement,
    @Default(0) num totalPublished,
    @Default([]) List<KV> uploadIncrementDataList,
    @Default([]) List<KV> downloadIncrementDataList,
    @Default([]) List<MonthSiteData> uploadMonthIncrementDataList,
    @Default([]) List<SiteStatusData> statusList,
    @Default([]) List<StackSiteData> stackChartDataList,
    @Default([]) List<KV> seedDataList,
    @Default(0) num siteCount,
    String? updatedAt,
    EarliestSite? earliestSite, // ← 新增
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) => _$DashboardDataFromJson(json);
}
