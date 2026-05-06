// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crontab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CrontabItem _$CrontabItemFromJson(Map<String, dynamic> json) => _CrontabItem(
  id: (json['id'] as num).toInt(),
  express: json['express'] as String,
  minute: json['minute'] as String,
  hour: json['hour'] as String,
  dayOfMonth: json['day_of_month'] as String? ?? '*',
  monthOfYear: json['month_of_year'] as String? ?? '*',
  dayOfWeek: json['day_of_week'] as String? ?? '*',
);

Map<String, dynamic> _$CrontabItemToJson(_CrontabItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'express': instance.express,
      'minute': instance.minute,
      'hour': instance.hour,
      'day_of_month': instance.dayOfMonth,
      'month_of_year': instance.monthOfYear,
      'day_of_week': instance.dayOfWeek,
    };
