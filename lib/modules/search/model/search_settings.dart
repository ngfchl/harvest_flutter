import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';

class SearchSettings {
  final int maxCount;

  /// Effective site list used by resource search.
  final List<String> sites;
  final List<String> storedSites;
  final bool sitesEnabled;

  const SearchSettings({
    this.maxCount = 5,
    this.sites = const [],
    List<String>? storedSites,
    this.sitesEnabled = true,
  }) : storedSites = storedSites ?? sites;

  static SearchSettings load() {
    final raw = HiveManager.get<Map>(StorageKeys.searchSettings);
    final sitesEnabled =
        HiveManager.get<bool>(StorageKeys.searchSitesEnabled) ?? true;
    if (raw == null) return SearchSettings(sitesEnabled: sitesEnabled);

    final storedSites =
        (raw['sites'] as List?)?.map((e) => e.toString()).toList() ?? [];
    return SearchSettings(
      maxCount: raw['max_count'] as int? ?? 5,
      sites: sitesEnabled ? storedSites : const [],
      storedSites: storedSites,
      sitesEnabled: sitesEnabled,
    );
  }

  void save() {
    HiveManager.set(StorageKeys.searchSettings, {
      'max_count': maxCount,
      'sites': storedSites,
    });
    HiveManager.set(StorageKeys.searchSitesEnabled, sitesEnabled);
  }
}
