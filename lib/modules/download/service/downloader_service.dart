import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/utils/utils.dart';

import '../../../core/http/hooks.dart';
import '../model/downloader.dart';
import '../model/downloader_category.dart';

class DownloaderService {
  static const _endpoint = API.DOWNLOADER_LIST;

  static Future<List<String>> fetchPaths() async {
    final list = await fetchBasicList(API.DOWNLOADER_PATHS);
    return list
        .map(_pathFromDynamic)
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList();
  }

  static String _pathFromDynamic(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      for (final key in const [
        'path',
        'save_path',
        'savePath',
        'download_dir',
        'downloadDir',
        'value',
        'name',
      ]) {
        final path = map[key]?.toString().trim();
        if (path != null && path.isNotEmpty) return path;
      }
      return '';
    }
    return value?.toString().trim() ?? '';
  }

  /// 获取下载器 prefs（带 with_status=true 返回 prefs）
  static Future<Map<String, dynamic>?> fetchPrefs(int id) async {
    final d = await fetchBasic(
      '${API.DOWNLOADER_PREFERENCES}/$id',
      queryParameters: {'with_status': true},
    );
    return d;
  }

  /// 保存下载器 prefs
  static Future<void> savePrefs(int id, Map<String, dynamic> prefs) {
    AppLogger.info(
      '[Downloader] saving prefs id=$id keys=${prefs.keys.length}',
    );
    return editData('${API.DOWNLOADER_PREFERENCES}/$id', prefs);
  }

  /// 切换下载器极速/龟速模式。
  static Future<void> toggleSpeedLimitMode(
    int id, {
    required bool enabled,
  }) async {
    await Http.get<dynamic>(
      '${API.DOWNLOADER_TOGGLE_SPEED_LIMIT_ENABLE}$id',
      queryParameters: {'state': enabled},
    );
  }

  /// 获取下载器列表
  static Future<List<Downloader>> fetchList({bool withStatus = false}) {
    return fetchModelList<Downloader>(
      _endpoint,
      Downloader.fromJson,
      queryParameters: {'with_status': withStatus},
    );
  }

  /// 获取单个下载器
  static Future<Downloader?> fetchOne(int id) {
    return fetchModel<Downloader>('$_endpoint/$id', Downloader.fromJson);
  }

  /// 新增下载器
  static Future<void> add(Downloader d) {
    return addData(_endpoint, d.toJson()..remove('id'));
  }

  /// 修改下载器
  static Future<void> edit(Downloader d) {
    return editData('$_endpoint/${d.id}', d.toJson());
  }

  /// 删除下载器
  static Future<void> remove(int id) {
    return removeData('$_endpoint/$id');
  }

  /// 获取下载器标签列表
  static Future<List<String>> fetchTags(int downloaderId) async {
    final data = await Http.get<dynamic>('${API.DOWNLOADER_TAGS}$downloaderId');
    if (data is List) {
      return data
          .map((e) {
            if (e is Map) return (e['name'] ?? e['tag'] ?? '').toString();
            return e.toString();
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  /// 获取下载器分类列表（QB）
  static Future<List<DownloaderCategory>> fetchCategories(
    int downloaderId,
  ) async {
    final data = await Http.get<dynamic>(
      '${API.DOWNLOADER_CATEGORY}$downloaderId',
    );
    if (data is List) {
      return data.map((e) {
        if (e is Map) {
          return DownloaderCategory.fromJson(Map<String, dynamic>.from(e));
        }
        return DownloaderCategory(name: e.toString(), savePath: '');
      }).toList();
    }
    if (data is Map) {
      return data.entries.map((entry) {
        final value = entry.value;
        if (value is Map) {
          return DownloaderCategory.fromJson({
            'name': entry.key,
            ...Map<String, dynamic>.from(value),
          });
        }
        return DownloaderCategory(
          name: entry.key.toString(),
          savePath: value?.toString() ?? '',
        );
      }).toList();
    }
    return const <DownloaderCategory>[];
  }

  static Future<void> createCategory(
    int downloaderId, {
    required String category,
    String savePath = '',
  }) {
    return addData('${API.DOWNLOADER_CATEGORY}$downloaderId', {
      'category': category,
      'save_path': savePath,
    });
  }

  static Future<void> editCategory(
    int downloaderId, {
    required String category,
    String savePath = '',
  }) {
    return editData('${API.DOWNLOADER_CATEGORY}$downloaderId', {
      'category': category,
      'save_path': savePath,
    });
  }

  static Future<void> deleteCategory(int downloaderId, String category) async {
    await Http.delete<dynamic>(
      '${API.DOWNLOADER_CATEGORY}$downloaderId',
      data: {'category': category},
    );
  }

  static Future<void> createTag(int downloaderId, String tag) {
    return addData('${API.DOWNLOADER_TAGS}$downloaderId', {'tag': tag});
  }

  static Future<void> deleteTag(int downloaderId, String tag) async {
    await Http.delete<dynamic>(
      '${API.DOWNLOADER_TAGS}$downloaderId',
      data: {'tag': tag},
    );
  }

  static Future<Map<String, dynamic>> fetchTorrentDetail(
    int downloaderId,
    String torrentHash,
  ) async {
    final data = await Http.get<dynamic>(
      '${API.DOWNLOADER_TORRENT_DETAIL}$downloaderId',
      queryParameters: {'torrent_hash': torrentHash},
    );
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'detail': data};
  }

  static Future<void> replaceTrackers(
    int downloaderId, {
    required List<String> torrentHashes,
    required String newTracker,
  }) {
    return editData('${API.DOWNLOADER_TRACKER_REPLACE}$downloaderId', {
      'torrent_hashes': torrentHashes,
      'new_tracker': newTracker,
    });
  }

  /// 推送种子到下载器
  static Future<void> pushTorrent(
    int downloaderId,
    Map<String, dynamic> params,
  ) async {
    await addData('${API.PUSH_TORRENT_URL}$downloaderId', params);
  }

  /// 批量推送（油猴接口）
  static Future<void> pushTorrentFromMonkey(
    int downloaderId,
    int mySiteId,
    Map<String, dynamic> params,
  ) async {
    await addData(
      '${API.PUSH_TORRENT_MONKEY_URL}$downloaderId/$mySiteId',
      params,
    );
  }
}
