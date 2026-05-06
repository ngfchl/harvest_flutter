String formatCompactNumber(num value) {
  final number = value.toDouble();
  if (!number.isFinite) return '-';
  final sign = number < 0 ? '-' : '';
  final abs = number.abs();
  if (abs >= 10000) return '$sign${_trimFixed(abs / 10000, 1)}W';
  if (abs >= 1000) return '$sign${_trimFixed(abs / 1000, 1)}K';
  return '$sign${_trimFixed(abs, abs == abs.roundToDouble() ? 0 : 1)}';
}

String _trimFixed(num value, int digits) {
  var text = value.toDouble().toStringAsFixed(digits);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}

String formatRatio(num value, {int digits = 2}) {
  final number = value.toDouble();
  if (!number.isFinite) return '-';
  var text = number.toStringAsFixed(digits);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}
