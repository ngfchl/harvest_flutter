String calcWeeksDays(String datetime) {
  int days = DateTime.now().difference(DateTime.parse(datetime)).inDays;
  int weeks = days ~/ 7;
  int day = days % 7;
  if (day == 0) {
    return '🔥$weeks周';
  }
  return '🔥$weeks周$day天';
}
