// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EarliestSite _$EarliestSiteFromJson(Map<String, dynamic> json) =>
    _EarliestSite(
      id: (json['id'] as num?)?.toInt() ?? 0,
      site: json['site'] as String,
      timeJoin: json['time_join'] as String?,
      latestActive: json['latest_active'] as String?,
    );

Map<String, dynamic> _$EarliestSiteToJson(_EarliestSite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'site': instance.site,
      'time_join': instance.timeJoin,
      'latest_active': instance.latestActive,
    };

_StatusRecord _$StatusRecordFromJson(Map<String, dynamic> json) =>
    _StatusRecord(
      createdAt: json['created_at'] as String,
      uploaded: json['uploaded'] as num? ?? 0,
      downloaded: json['downloaded'] as num? ?? 0,
      published: json['published'] as num? ?? 0,
    );

Map<String, dynamic> _$StatusRecordToJson(_StatusRecord instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt,
      'uploaded': instance.uploaded,
      'downloaded': instance.downloaded,
      'published': instance.published,
    };

_UploadRecord _$UploadRecordFromJson(Map<String, dynamic> json) =>
    _UploadRecord(
      createdAt: json['created_at'] as String,
      uploaded: json['uploaded'] as num? ?? 0,
      downloaded: json['downloaded'] as num? ?? 0,
    );

Map<String, dynamic> _$UploadRecordToJson(_UploadRecord instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt,
      'uploaded': instance.uploaded,
      'downloaded': instance.downloaded,
    };

_MonthSiteData _$MonthSiteDataFromJson(Map<String, dynamic> json) =>
    _MonthSiteData(
      name: json['name'] as String,
      value:
          (json['value'] as List<dynamic>?)
              ?.map((e) => StatusRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MonthSiteDataToJson(_MonthSiteData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value.map((e) => e.toJson()).toList(),
    };

_SiteStatusData _$SiteStatusDataFromJson(Map<String, dynamic> json) =>
    _SiteStatusData(
      name: json['name'] as String,
      value: StatusRecord.fromJson(json['value'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SiteStatusDataToJson(_SiteStatusData instance) =>
    <String, dynamic>{'name': instance.name, 'value': instance.value.toJson()};

_StackSiteData _$StackSiteDataFromJson(Map<String, dynamic> json) =>
    _StackSiteData(
      name: json['name'] as String,
      value:
          (json['value'] as List<dynamic>?)
              ?.map((e) => UploadRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StackSiteDataToJson(_StackSiteData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value.map((e) => e.toJson()).toList(),
    };

_DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    _DashboardData(
      emailCount:
          (json['emailCount'] as List<dynamic>?)
              ?.map((e) => KV.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      usernameCount:
          (json['usernameCount'] as List<dynamic>?)
              ?.map((e) => KV.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalUploaded: json['totalUploaded'] as num? ?? 0,
      totalDownloaded: json['totalDownloaded'] as num? ?? 0,
      totalSeedVol: json['totalSeedVol'] as num? ?? 0,
      totalSeeding: json['totalSeeding'] as num? ?? 0,
      totalLeeching: json['totalLeeching'] as num? ?? 0,
      todayUploadIncrement: json['todayUploadIncrement'] as num? ?? 0,
      todayDownloadIncrement: json['todayDownloadIncrement'] as num? ?? 0,
      totalPublished: json['totalPublished'] as num? ?? 0,
      uploadIncrementDataList:
          (json['uploadIncrementDataList'] as List<dynamic>?)
              ?.map((e) => KV.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      downloadIncrementDataList:
          (json['downloadIncrementDataList'] as List<dynamic>?)
              ?.map((e) => KV.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      uploadMonthIncrementDataList:
          (json['uploadMonthIncrementDataList'] as List<dynamic>?)
              ?.map((e) => MonthSiteData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      statusList:
          (json['statusList'] as List<dynamic>?)
              ?.map((e) => SiteStatusData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      stackChartDataList:
          (json['stackChartDataList'] as List<dynamic>?)
              ?.map((e) => StackSiteData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      seedDataList:
          (json['seedDataList'] as List<dynamic>?)
              ?.map((e) => KV.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      siteCount: json['siteCount'] as num? ?? 0,
      updatedAt: json['updatedAt'] as String?,
      earliestSite: json['earliestSite'] == null
          ? null
          : EarliestSite.fromJson(json['earliestSite'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardDataToJson(_DashboardData instance) =>
    <String, dynamic>{
      'emailCount': instance.emailCount.map((e) => e.toJson()).toList(),
      'usernameCount': instance.usernameCount.map((e) => e.toJson()).toList(),
      'totalUploaded': instance.totalUploaded,
      'totalDownloaded': instance.totalDownloaded,
      'totalSeedVol': instance.totalSeedVol,
      'totalSeeding': instance.totalSeeding,
      'totalLeeching': instance.totalLeeching,
      'todayUploadIncrement': instance.todayUploadIncrement,
      'todayDownloadIncrement': instance.todayDownloadIncrement,
      'totalPublished': instance.totalPublished,
      'uploadIncrementDataList': instance.uploadIncrementDataList
          .map((e) => e.toJson())
          .toList(),
      'downloadIncrementDataList': instance.downloadIncrementDataList
          .map((e) => e.toJson())
          .toList(),
      'uploadMonthIncrementDataList': instance.uploadMonthIncrementDataList
          .map((e) => e.toJson())
          .toList(),
      'statusList': instance.statusList.map((e) => e.toJson()).toList(),
      'stackChartDataList': instance.stackChartDataList
          .map((e) => e.toJson())
          .toList(),
      'seedDataList': instance.seedDataList.map((e) => e.toJson()).toList(),
      'siteCount': instance.siteCount,
      'updatedAt': instance.updatedAt,
      'earliestSite': instance.earliestSite?.toJson(),
    };
