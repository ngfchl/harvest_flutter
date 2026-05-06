// models/dashboard/dashboard_chart_config.dart

import '../../../core/storage/hive_manager.dart';
import '../../../core/storage/storage_keys.dart';

class DashboardChartConfig {
  static const defaultOrder = [
    'status', 'email', 'username', 'uploaded',
    'todayUpload', 'todayDownload', 'publishedCount', 'seed',
    'monthUpload', 'monthDownload', 'monthPublished', 'dailyStack',
  ];

  static const names = {
    'status': '站点状态',
    'email': '邮箱分布',
    'username': '用户名分布',
    'uploaded': '站点上传量',
    'todayUpload': '今日上传增量',
    'todayDownload': '今日下载增量',
    'publishedCount': '站点发种数量',
    'seed': '做种分布',
    'monthUpload': '月度上传增量趋势',
    'monthDownload': '月度下载增量趋势',
    'monthPublished': '月度发种增量趋势',
    'dailyStack': '每日上传趋势',
  };

  static List<String> getOrder() {
    final saved = HiveManager.get<List>(StorageKeys.dashboardChartOrder);
    if (saved != null) {
      final order = List<String>.from(saved);
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
      for (final id in defaultOrder) {
        vis.putIfAbsent(id, () => true);
      }
      return vis;
    }
    return {for (final id in defaultOrder) id: true};
  }

  static Future<void> setVisibility(String id, bool visible) async {
    final vis = getVisibility();
    vis[id] = visible;
    await HiveManager.set(StorageKeys.dashboardChartVisibility, vis);
  }

  // ———————————————— 图表高度 ————————————————

  static const double defaultChartHeight = 260.0;
  static const double minChartHeight = 120.0;
  static const double maxChartHeight = 400.0;

  static double getChartHeight() {
    return HiveManager.get<double>(StorageKeys.dashboardChartHeight) ?? defaultChartHeight;
  }

  static Future<void> saveChartHeight(double height) async {
    await HiveManager.set(StorageKeys.dashboardChartHeight, height);
  }

  static Future<void> reset() async {
    await HiveManager.set(StorageKeys.dashboardChartOrder, defaultOrder);
    await HiveManager.set(StorageKeys.dashboardChartVisibility, {
      for (final id in defaultOrder) id: true,
    });
    await HiveManager.set(StorageKeys.dashboardChartHeight, defaultChartHeight);
  }


  static const int defaultTreemapCount = 15;
  static const int minTreemapCount = 10;
  static const int maxTreemapCount = 50;

  static int getTreemapCount() {
    return HiveManager.get<int>(StorageKeys.dashboardTreemapCount) ?? defaultTreemapCount;
  }

  static Future<void> saveTreemapCount(int count) async {
    await HiveManager.set(StorageKeys.dashboardTreemapCount, count);
  }
}
