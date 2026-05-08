// models/dashboard/desktop_chart_config.dart

import '../../../core/storage/hive_manager.dart';
import '../../../core/storage/storage_keys.dart';

class DashboardChartConfig {
  static const defaultOrder = [
    'phoneServer',
    'phoneServerResource',
    'phoneServiceStatus',
    'phoneDesignation',
    'phoneOverview',
    'phoneActions',
    'phoneTrend',
    'phoneStatus',
    'phoneUploadShare',
    'phoneAccount',
    'phoneToday',
    'phoneSeedShare',
    'phoneMonthUpload',
    'phoneMonthDownload',
    'phoneMonthPublish',
  ];

  static const desktopOrder = [
    'desktopServerResource',
    'desktopServiceStatus',
    'desktopKpi',
    'desktopTrend',
    'desktopDesignation',
    'desktopResource',
    'desktopStatus',
    'desktopUploadShare',
    'desktopSeedShare',
    'desktopAccount',
    'desktopToday',
    'desktopRank',
    'desktopMonthlyPublish',
  ];

  static const allModuleIds = [...defaultOrder, ...desktopOrder];

  static const names = {
    'phoneServer': '用户信息',
    'phoneServerResource': '服务器状态',
    'phoneServiceStatus': '后台服务状态',
    'phoneDesignation': '称号进度',
    'phoneOverview': '数据总览',
    'phoneActions': '快捷操作',
    'phoneTrend': '上传 / 下载趋势',
    'phoneStatus': '站点状态',
    'phoneUploadShare': '上传量分布',
    'phoneAccount': '用户信息分布',
    'phoneToday': '增量排行',
    'phoneSeedShare': '做种分布',
    'phoneMonthUpload': '月度上传',
    'phoneMonthDownload': '月度下载',
    'phoneMonthPublish': '月度发种',
    'desktopKpi': '核心指标',
    'desktopServerResource': '服务器状态',
    'desktopServiceStatus': '后台服务状态',
    'desktopTrend': '吞吐趋势',
    'desktopDesignation': '称号',
    'desktopResource': '全局资源',
    'desktopStatus': '站点状态矩形图',
    'desktopUploadShare': '上传占比',
    'desktopSeedShare': '做种分布',
    'desktopAccount': '账号分布',
    'desktopToday': '今日增量',
    'desktopRank': '累计排行',
    'desktopMonthlyPublish': '月度发布',
  };

  static List<String> getOrder() {
    final saved = HiveManager.get<List>(StorageKeys.dashboardChartOrder);
    if (saved != null) {
      final order = List<String>.from(
        saved,
      ).where(defaultOrder.contains).toList();
      for (final id in defaultOrder) {
        if (!order.contains(id)) order.add(id);
      }
      return order;
    }
    return List.from(defaultOrder);
  }

  static Future<void> saveOrder(List<String> order) async {
    await HiveManager.set(StorageKeys.dashboardChartOrder, order);
  }

  static Map<String, bool> getVisibility() {
    final saved = HiveManager.get<Map>(StorageKeys.dashboardChartVisibility);
    if (saved != null) {
      final vis = Map<String, bool>.from(saved);
      for (final id in allModuleIds) {
        vis.putIfAbsent(id, () => true);
      }
      return vis;
    }
    return {for (final id in allModuleIds) id: true};
  }

  static Future<void> setVisibility(String id, bool visible) async {
    final vis = getVisibility();
    vis[id] = visible;
    await HiveManager.set(StorageKeys.dashboardChartVisibility, vis);
  }

  // ———————————————— 图表高度 ————————————————

  static const double defaultChartHeight = 260.0;
  static const double defaultDesktopChartHeight = 320.0;
  static const double minChartHeight = 120.0;
  static const double maxChartHeight = 480.0;

  static double getChartHeight() {
    return HiveManager.get<double>(StorageKeys.dashboardChartHeight) ??
        defaultChartHeight;
  }

  static Future<void> saveChartHeight(double height) async {
    await HiveManager.set(StorageKeys.dashboardChartHeight, height);
  }

  static Future<void> reset() async {
    await HiveManager.set(StorageKeys.dashboardChartOrder, defaultOrder);
    await HiveManager.set(StorageKeys.dashboardChartVisibility, {
      for (final id in allModuleIds) id: true,
    });
    await HiveManager.set(StorageKeys.dashboardChartHeight, defaultChartHeight);
    await HiveManager.set(
      StorageKeys.dashboardPhoneTrendDays,
      defaultPhoneTrendDays,
    );
  }

  static const int defaultTreemapCount = 15;
  static const int defaultDesktopTreemapCount = 32;
  static const int minTreemapCount = 10;
  static const int maxTreemapCount = 50;

  static int getTreemapCount() {
    return HiveManager.get<int>(StorageKeys.dashboardTreemapCount) ??
        defaultTreemapCount;
  }

  static Future<void> saveTreemapCount(int count) async {
    await HiveManager.set(StorageKeys.dashboardTreemapCount, count);
  }

  static int getDesktopTreemapCount() {
    return HiveManager.get<int>(StorageKeys.dashboardDesktopTreemapCount) ??
        defaultDesktopTreemapCount;
  }

  static Future<void> saveDesktopTreemapCount(int count) async {
    await HiveManager.set(StorageKeys.dashboardDesktopTreemapCount, count);
  }

  static const int defaultPhoneTrendDays = 7;
  static const phoneTrendDayOptions = [1, 7, 30];

  static int getPhoneTrendDays() {
    final saved = HiveManager.get<int>(StorageKeys.dashboardPhoneTrendDays);
    return phoneTrendDayOptions.contains(saved) ? saved! : defaultPhoneTrendDays;
  }

  static Future<void> savePhoneTrendDays(int days) async {
    final normalized = phoneTrendDayOptions.contains(days)
        ? days
        : defaultPhoneTrendDays;
    await HiveManager.set(StorageKeys.dashboardPhoneTrendDays, normalized);
  }
}
