import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/ai_models.dart';
import '../service/ai_service.dart';

/// AI 配置。
final aiConfigProvider = AsyncNotifierProvider<AiConfigNotifier, AiConfig>(
  AiConfigNotifier.new,
);

class AiConfigNotifier extends AsyncNotifier<AiConfig> {
  @override
  Future<AiConfig> build() async {
    if (!HiveManager.hasAccessToken) return const AiConfig();
    return AiService.fetchConfig();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.value ?? const AiConfig());
      return;
    }
    state = await AsyncValue.guard(AiService.fetchConfig);
  }

  Future<AiConfig> save(AiConfig config) async {
    final saved = await AiService.saveConfig(config);
    state = AsyncValue.data(saved);
    return saved;
  }
}

/// AI 调用用量。
final aiUsageProvider = AsyncNotifierProvider<AiUsageNotifier, AiUsage>(
  AiUsageNotifier.new,
);

class AiUsageNotifier extends AsyncNotifier<AiUsage> {
  @override
  Future<AiUsage> build() async {
    if (!HiveManager.hasAccessToken) return const AiUsage();
    return AiService.fetchUsage();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.value ?? const AiUsage());
      return;
    }
    state = await AsyncValue.guard(AiService.fetchUsage);
  }
}
