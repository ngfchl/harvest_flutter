import 'package:flutter_riverpod/legacy.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';

/// 控制「AI 管理」「RSS 订阅」菜单入口是否显示。
///
/// 默认关闭，需在「设置中心 → 常用工具」中开启后菜单才出现。
class FeatureToggles {
  final bool aiEnabled;
  final bool rssEnabled;

  const FeatureToggles({this.aiEnabled = false, this.rssEnabled = false});

  FeatureToggles copyWith({bool? aiEnabled, bool? rssEnabled}) => FeatureToggles(
        aiEnabled: aiEnabled ?? this.aiEnabled,
        rssEnabled: rssEnabled ?? this.rssEnabled,
      );

  static FeatureToggles load() {
    final raw = HiveManager.get<Map>(StorageKeys.featureToggles);
    if (raw == null) return const FeatureToggles();
    return FeatureToggles(
      aiEnabled: raw['ai_enabled'] as bool? ?? false,
      rssEnabled: raw['rss_enabled'] as bool? ?? false,
    );
  }

  Future<void> save() {
    return HiveManager.set(StorageKeys.featureToggles, {
      'ai_enabled': aiEnabled,
      'rss_enabled': rssEnabled,
    });
  }
}

final featureTogglesProvider =
    StateNotifierProvider<FeatureTogglesNotifier, FeatureToggles>(
  (ref) => FeatureTogglesNotifier(),
);

class FeatureTogglesNotifier extends StateNotifier<FeatureToggles> {
  FeatureTogglesNotifier() : super(FeatureToggles.load());

  Future<void> setAiEnabled(bool value) async {
    state = state.copyWith(aiEnabled: value);
    await state.save();
  }

  Future<void> setRssEnabled(bool value) async {
    state = state.copyWith(rssEnabled: value);
    await state.save();
  }
}
