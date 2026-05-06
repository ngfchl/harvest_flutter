import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';

enum SiteCardStyle {
  style1,
  style2,
  style3,
}

final siteCardStyleProvider = StateProvider<SiteCardStyle>((ref) {
  final index = HiveManager.get<int>(StorageKeys.siteCardStyle) ?? 0;
  if (index < 0 || index >= SiteCardStyle.values.length) {
    return SiteCardStyle.style1;
  }
  return SiteCardStyle.values[index];
});

void setSiteCardStyle(WidgetRef ref, SiteCardStyle style) {
  ref.read(siteCardStyleProvider.notifier).state = style;
  HiveManager.set(StorageKeys.siteCardStyle, style.index);
}
