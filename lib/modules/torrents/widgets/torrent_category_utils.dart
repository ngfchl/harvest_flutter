import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/torrent_model.dart';
import 'desktop_filter_item.dart';

List<String> torrentPathCategoryLevels(String rawPath) {
  final path = rawPath.trim();
  if (path.isEmpty) return const [];
  final normalized = path.replaceAll('\\', '/');
  final parts = normalized
      .split('/')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return const [];
  return [for (var i = 0; i < parts.length; i++) parts.take(i + 1).join('/')];
}

String torrentCategoryLabel(Torrent torrent) {
  if (torrent.category.isNotEmpty) return torrent.category;
  final levels = torrentPathCategoryLevels(torrent.downloadDir);
  return levels.isEmpty ? '' : levels.last;
}

List<String> torrentCategoryFilterLabels(Torrent torrent) {
  if (torrent.category.isNotEmpty) return [torrent.category];
  return torrentPathCategoryLevels(torrent.downloadDir);
}

int compareCategoryPath(String a, String b) {
  final aParts = a.split('/');
  final bParts = b.split('/');
  for (var i = 0; i < min(aParts.length, bParts.length); i++) {
    final cmp = aParts[i].toLowerCase().compareTo(bParts[i].toLowerCase());
    if (cmp != 0) return cmp;
  }
  return aParts.length.compareTo(bParts.length);
}

String categoryTreeLabel(String category) {
  final parts = category.split('/').where((part) => part.isNotEmpty).toList();
  return parts.isEmpty ? category : parts.last;
}

double categoryTreeIndent(String category) {
  final depth = category.split('/').where((part) => part.isNotEmpty).length - 1;
  return max(0, depth) * 14.0;
}

IconData categoryTreeIcon(String category) {
  final depth = category.split('/').where((part) => part.isNotEmpty).length;
  return depth <= 1 ? shadcn.LucideIcons.folder : shadcn.LucideIcons.folderOpen;
}

List<Widget> desktopCategoryFilterItems({
  required List<String> categories,
  required Map<String, int> counts,
  required String selectedCategory,
  required bool tree,
  required ValueChanged<String> onSelect,
  required List<Widget> Function(String item) trailingActionsBuilder,
}) {
  final sorted = List<String>.from(categories)..sort(compareCategoryPath);
  return [
    for (final item in sorted)
      DesktopFilterItem(
        icon: tree ? categoryTreeIcon(item) : shadcn.LucideIcons.folder,
        label: tree ? categoryTreeLabel(item) : item,
        count: counts[item] ?? 0,
        selected: selectedCategory == item,
        onTap: () => onSelect(item),
        indent: tree ? categoryTreeIndent(item) : 0,
        trailingActions: trailingActionsBuilder(item),
      ),
  ];
}
