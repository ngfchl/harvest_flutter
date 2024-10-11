class Schedule {
  int? id;
  String? name;
  String? task;
  dynamic crontab;
  bool? enabled;
  String? description;
  String? args;
  String? kwargs;

  Schedule(
      {this.id,
      this.name,
      this.task,
      this.crontab,
      this.enabled,
      this.description,
      this.args,
      this.kwargs});

  @override
  String toString() {
    return '计划任务：$name：$crontab';
  }

  Schedule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    task = json['task'];
    crontab = json['crontab_id'];
    enabled = json['enabled'];
    description = json['description'];
    args = json['args'];
    kwargs = json['kwargs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['task'] = task;
    data['crontab'] = crontab is Crontab ? crontab.toJson() : crontab;
    data['enabled'] = enabled;
    data['description'] = description;
    data['args'] = args;
    data['kwargs'] = kwargs;
    return data;
  }
}

class Task {
  String? task;
  String? desc;

  Task({this.task, this.desc});

  Task.fromJson(Map<String, dynamic> json) {
    task = json['task'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['task'] = task;
    data['desc'] = desc;
    return data;
  }

  @override
  String toString() {
    return '任务信息：$task - $desc';
  }
}

class Crontab {
  int? id;
  String? minute;
  String? hour;
  String? dayOfWeek;
  String? dayOfMonth;
  String? monthOfYear;
  String? express;

  Crontab(
      {this.id,
      this.minute,
      this.hour,
      this.dayOfWeek,
      this.dayOfMonth,
      this.monthOfYear,
      this.express});

  Crontab.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    minute = json['minute'];
    hour = json['hour'];
    dayOfWeek = json['day_of_week'];
    dayOfMonth = json['day_of_month'];
    monthOfYear = json['month_of_year'];
    express = json['express'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['minute'] = minute;
    data['hour'] = hour;
    data['day_of_week'] = dayOfWeek;
    data['day_of_month'] = dayOfMonth;
    data['month_of_year'] = monthOfYear;
    data['express'] = express;
    return data;
  }

  @override
  String toString() {
    return 'Cron 表达式：$express';
  }
}
