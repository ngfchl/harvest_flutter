String formatNumber(num value, {int fixed = 2}) {
  List<String> sizes = ['', 'W', 'E'];
  int i = 0;
  while (value >= 10000 && i < sizes.length - 1) {
    value /= 10000;
    i++;
  }
  return '${value.toStringAsFixed(fixed)}${sizes[i]}';
}
