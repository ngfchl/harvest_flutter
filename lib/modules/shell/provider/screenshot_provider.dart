import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 截图模式：true 时页面切换为全量渲染（shrinkWrap），截图完成后恢复
final screenshotModeProvider = StateProvider<bool>((ref) => false);

/// 各页面注册的 ScrollController
final activeScrollControllerProvider = StateProvider<ScrollController?>(
  (ref) => null,
);

/// 按 Shell 页面索引注册 ScrollController，避免 KeepAlive 页面互相覆盖当前控制器。
final pageScrollControllersProvider = StateProvider<Map<int, ScrollController>>(
  (ref) => const {},
);

void registerPageScrollController(
  WidgetRef ref,
  int pageIndex,
  ScrollController controller,
) {
  final notifier = ref.read(pageScrollControllersProvider.notifier);
  final current = notifier.state;
  if (current[pageIndex] == controller) return;
  notifier.state = {...current, pageIndex: controller};
}

void unregisterPageScrollController(
  WidgetRef ref,
  int pageIndex,
  ScrollController controller,
) {
  final notifier = ref.read(pageScrollControllersProvider.notifier);
  final current = notifier.state;
  if (current[pageIndex] != controller) return;
  final next = Map<int, ScrollController>.of(current)..remove(pageIndex);
  notifier.state = next;
}
