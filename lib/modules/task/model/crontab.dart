import 'package:freezed_annotation/freezed_annotation.dart';

part 'crontab.freezed.dart';
part 'crontab.g.dart';

@freezed
abstract class CrontabItem with _$CrontabItem {
  const CrontabItem._();

  const factory CrontabItem({
    required int id,
    required String express,
    required String minute,
    required String hour,
    @JsonKey(name: 'day_of_month') @Default('*') String dayOfMonth,
    @JsonKey(name: 'month_of_year') @Default('*') String monthOfYear,
    @JsonKey(name: 'day_of_week') @Default('*') String dayOfWeek,
  }) = _CrontabItem;

  factory CrontabItem.fromJson(Map<String, dynamic> json) => _$CrontabItemFromJson(json);

  String get readableExpress {
    final parts = <String>[];
    if (minute != '*') parts.add('第 $minute 分钟');
    if (hour != '*') parts.add('第 $hour 小时');
    if (dayOfMonth != '*') parts.add('每月 $dayOfMonth 号');
    if (monthOfYear != '*') parts.add('$monthOfYear 月');
    if (dayOfWeek != '*') parts.add('星期 $dayOfWeek');
    return parts.isEmpty ? '每分钟执行' : parts.join('，');
  }
}
