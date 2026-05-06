int parseSizeToBytes(String value) {
  final text = value.trim();
  if (text.isEmpty || text == '0') return 0;

  final match = RegExp(r'^([\d.]+)\s*([A-Za-z]+)$').firstMatch(text);
  if (match == null) return int.tryParse(text) ?? 0;

  final size = double.tryParse(match.group(1)!) ?? 0;
  final unit = match.group(2)!.toUpperCase();
  return switch (unit) {
    'B' => size.toInt(),
    'KB' => (size * 1024).toInt(),
    'MB' => (size * 1024 * 1024).toInt(),
    'GB' => (size * 1024 * 1024 * 1024).toInt(),
    'TB' => (size * 1024 * 1024 * 1024 * 1024).toInt(),
    'PB' => (size * 1024 * 1024 * 1024 * 1024 * 1024).toInt(),
    _ => size.toInt(),
  };
}
