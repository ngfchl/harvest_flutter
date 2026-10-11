import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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
  final container = ref.container;
  final notifier = container.read(pageScrollControllersProvider.notifier);
  final current = notifier.state;
  if (current[pageIndex] != controller) return;
  final next = Map<int, ScrollController>.of(current)..remove(pageIndex);
  // 该函数会在页面 dispose（finalizeTree 期间）被调用，此时禁止同步
  // 修改 provider；延迟到当前帧构建结束后再更新
  Future.microtask(() {
    if (notifier.state == current) {
      notifier.state = next;
    }
  });
}
