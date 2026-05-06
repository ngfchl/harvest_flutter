import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:harvest/modules/task/model/crontab.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
abstract class Schedule with _$Schedule {
  const Schedule._();

  const factory Schedule({
    required int id,
    @Default('') String name,
    @Default('') String task,
    @Default('') String description,
    @JsonKey(name: 'crontab_id') int? crontabId,
    CrontabItem? crontab,
    @Default('[]') String args,
    @Default('{}') String kwargs,
    @Default(true) bool enabled,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);
}
