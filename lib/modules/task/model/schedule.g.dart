// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Schedule _$ScheduleFromJson(Map<String, dynamic> json) => _Schedule(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? '',
  task: json['task'] as String? ?? '',
  description: json['description'] as String? ?? '',
  crontabId: (json['crontab_id'] as num?)?.toInt(),
  crontab: json['crontab'] == null
      ? null
      : CrontabItem.fromJson(json['crontab'] as Map<String, dynamic>),
  args: json['args'] as String? ?? '[]',
  kwargs: json['kwargs'] as String? ?? '{}',
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$ScheduleToJson(_Schedule instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'task': instance.task,
  'description': instance.description,
  'crontab_id': instance.crontabId,
  'crontab': instance.crontab?.toJson(),
  'args': instance.args,
  'kwargs': instance.kwargs,
  'enabled': instance.enabled,
};
