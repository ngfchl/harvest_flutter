class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const baseUrl = 'base_url';
  static const authState = 'auth_state';
  static const String loggerLevel = 'logger_level';
  static const String privacyMode = 'privacy_mode';
  static const String dashboardChartOrder = 'dashboard_chart_order'; // ← 新增
  static const String dashboardChartVisibility =
      'dashboard_chart_visibility'; // ← 新增
  static const String dashboardChartHeight = 'dashboard_chart_height'; // ← 新增
  static const String dashboardTreemapCount = 'dashboard_treemap_count';
  static const String dashboardDesktopTreemapCount =
      'dashboard_desktop_treemap_count';
  static const String dashboardPhoneTrendDays = 'dashboard_phone_trend_days';

  // ── 站点筛选 ──
  static const String siteFilterAvailability = 'site_filter_availability';
  static const String siteFilterCondition = 'site_filter_condition';
  static const String siteFilterSortField = 'site_filter_sort_field';
  static const String siteFilterSortAscending = 'site_filter_sort_ascending';
  static const String siteCardStyle = 'site_card_style';

  // ── 搜索设置 ──
  static const String searchSettings = 'search_settings';
  static const String searchSitesEnabled = 'search_sites_enabled';

  // ── 搜索历史 ──
  static const String searchHistory = 'search_history';

  // storage_keys.dart 里加
  static const String downloaderSpeedInterval = 'downloader_speed_interval';
  static const String downloaderSpeedEnabled = 'downloader_speed_enabled';
  static const String downloaderSpeedDuration = 'downloader_speed_duration';
  static const String serverResourceInterval = 'server_resource_interval';
  static const String serverResourceDuration = 'server_resource_duration';
  static const String serverResourceAutoStart = 'server_resource_auto_start';
}
