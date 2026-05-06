String formatBytes(num bytes, {String suffix = '', bool showZero = true, int? decimals}) {
  if (bytes <= 0) return showZero ? '0 B$suffix' : '∞';
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  var index = 0;
  var value = bytes.toDouble();
  while (value >= 1024 && index < units.length - 1) {
    value /= 1024;
    index++;
  }
  final fractionDigits = decimals ?? (index >= 2 ? 2 : (index >= 1 ? 1 : 0));
  return '${value.toStringAsFixed(fractionDigits)} ${units[index]}$suffix';
}

String formatSpeed(num bytesPerSecond) => formatBytes(bytesPerSecond, suffix: '/s');

String formatCompactBytes(int bytes) {
  if (bytes == 0) return '0 B';
  final neg = bytes < 0;
  var size = bytes.abs().toDouble();
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  var index = 0;
  while (size >= 1024 && index < units.length - 1) {
    size /= 1024;
    index++;
  }
  return '${neg ? '-' : ''}${size.toStringAsFixed(index > 1 ? 1 : 0)} ${units[index]}';
}
