import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/utils/utils.dart';

class CachedValue<T> {
  final T data;
  final DateTime cachedAt;

  const CachedValue({required this.data, required this.cachedAt});
}

class DataCacheInfo {
  final bool isCached;
  final DateTime? cachedAt;

  const DataCacheInfo({required this.isCached, this.cachedAt});

  const DataCacheInfo.none() : this(isCached: false);

  DataCacheInfo.cached(DateTime cachedAt)
    : this(isCached: true, cachedAt: cachedAt);
}

class SessionCache {
  static const _namespace = 'session_cache';

  static CachedValue<T>? read<T>(
    String name,
    T Function(dynamic data) fromCache,
  ) {
    final raw = HiveManager.get<Map<String, dynamic>>(_key(name));
    if (raw == null) {
      AppLogger.debug('[Cache] miss: $name');
      return null;
    }

    final cachedAtValue = raw['cachedAt'];
    final data = raw['data'];
    if (cachedAtValue == null || data == null) {
      AppLogger.warn('[Cache] invalid entry: $name');
      return null;
    }

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(cachedAtValue.toString()) ?? 0,
    );
    if (cachedAt.millisecondsSinceEpoch <= 0) {
      AppLogger.warn('[Cache] invalid timestamp: $name');
      return null;
    }

    try {
      final value = CachedValue<T>(data: fromCache(data), cachedAt: cachedAt);
      AppLogger.info(
        '[Cache] hit: $name cachedAt=${cachedAt.toIso8601String()}',
      );
      return value;
    } catch (e, st) {
      AppLogger.error('[Cache] failed to decode: $name', e, st);
      return null;
    }
  }

  static Future<DataCacheInfo> write(String name, dynamic data) async {
    final cachedAt = DateTime.now();
    await HiveManager.set(_key(name), {
      'cachedAt': cachedAt.millisecondsSinceEpoch,
      'data': data,
    });
    AppLogger.debug('[Cache] write: $name data=${_shape(data)}');
    return DataCacheInfo(isCached: false, cachedAt: cachedAt);
  }

  static String _key(String name) => '$_namespace::$name';

  static String _shape(dynamic data) {
    if (data is List) return 'List(${data.length})';
    if (data is Map) return 'Map(${data.length})';
    if (data == null) return 'null';
    return data.runtimeType.toString();
  }
}
