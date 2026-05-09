import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/http/hooks.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../site/provider/site_provider.dart' as site_providers;
import '../model/torrent_model.dart';
import '../model/torrent_site_matcher.dart';

// ────────────────────── WS URL ──────────────────────

String _buildWsUrl(String path) {
  final raw = HiveManager.get(StorageKeys.baseUrl) as String? ?? '';
  final cleaned = raw.replaceAll(RegExp(r'[/#]+$'), '');
  final wsBase = cleaned.startsWith('https://')
      ? cleaned.replaceFirst('https://', 'wss://')
      : cleaned.replaceFirst('http://', 'ws://');
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  final url = '$wsBase$normalizedPath';
  debugPrint('[WS_URL] base="$raw" -> cleaned="$cleaned" -> final="$url"');
  return url;
}

// ────────────────────── Maindata ──────────────────────

Future<DownloaderData> fetchMainData(int downloaderId) async {
  final path = '/api/option/downloaders/main/$downloaderId';
  debugPrint('[MainData] 请求 $path');
  try {
    final data = await fetchModel<DownloaderData>(
      path,
      DownloaderData.fromJson,
    );
    debugPrint(
      '[MainData] 成功, torrents=${data?.torrents.length ?? 0}, '
      'status=${data?.status?.torrentCount ?? 0}',
    );
    AppLogger.info('[MainData] 成功, torrents=${data?.torrents[0]}');
    return data ?? const DownloaderData(torrents: []);
  } catch (e, st) {
    debugPrint('[MainData] 失败: $e');
    debugPrint('[MainData] stacktrace: $st');
    return const DownloaderData(torrents: []);
  }
}

// ────────────────────── StateNotifier ──────────────────────

class TorrentListNotifier extends StateNotifier<AsyncValue<DownloaderData>> {
  final int downloaderId;
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  bool _disposed = false;
  bool _wsPaused = false;

  TorrentListNotifier(this.downloaderId) : super(const AsyncValue.loading()) {
    debugPrint('[TorrentList] 初始化 downloaderId=$downloaderId');
    _init();
  }

  Future<void> _init() async {
    // 1) maindata
    debugPrint('[TorrentList] 开始拉取 maindata...');
    await _refreshMainData(preservePrevious: false);

    // 2) WS
    if (!_disposed && !_wsPaused) {
      debugPrint('[TorrentList] 开始连接 WS...');
      _connectWs();
    }
  }

  Future<void> refresh() {
    return _refreshMainData(preservePrevious: true);
  }

  Future<void> _refreshMainData({required bool preservePrevious}) async {
    final previous = state.valueOrNull;
    try {
      final data = await fetchMainData(downloaderId);
      debugPrint(
        '[TorrentList] maindata 结果: '
        'torrents=${data.torrents.length}',
      );
      if (!_disposed) {
        if (data.torrents.isNotEmpty || !preservePrevious || previous == null) {
          state = AsyncValue.data(data);
          debugPrint('[TorrentList] maindata 已设置到 state');
        } else {
          state = AsyncValue.data(previous);
          debugPrint('[TorrentList] maindata 为空, 保留现有 state');
        }
      } else {
        debugPrint('[TorrentList] 已 disposed, 跳过 maindata');
      }
    } catch (e, st) {
      debugPrint('[TorrentList] maindata 异常: $e');
      debugPrint('[TorrentList] $st');
      if (!_disposed) {
        if (preservePrevious && previous != null) {
          state = AsyncValue.data(previous);
        } else {
          state = AsyncValue.error(e, st);
        }
      }
    }
  }

  void _connectWs() {
    if (_disposed) {
      debugPrint('[WS] 已 disposed, 不连接');
      return;
    }
    if (_wsPaused) {
      debugPrint('[WS] 已暂停, 不连接');
      return;
    }

    try {
      _disconnectWs();
      final wsUrl = _buildWsUrl('/api/ws/downloader');
      debugPrint('[WS] 正在连接: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // 先监听再发消息，避免错过数据
      _sub = _channel!.stream.listen(
        (msg) {
          if (_disposed || _wsPaused) return;
          try {
            final json = jsonDecode(msg as String) as Map<String, dynamic>;
            if (json['code'] == 0 && json['data'] != null) {
              final dataMap = json['data'] as Map<String, dynamic>;

              // ── 调试：打印第一个 torrent 的原始 JSON keys ──
              final raw = dataMap['torrents'];
              if (raw is Map && raw.isNotEmpty) {
                final firstKey = raw.keys.first;
                final firstTorrent = raw[firstKey] as Map<String, dynamic>;
                debugPrint('[WS_RAW] 第一个种子的原始 keys: $firstTorrent');
                debugPrint(
                  '[WS_RAW] name=${firstTorrent['name']}, '
                  'status/state=${firstTorrent['status'] ?? firstTorrent['state']}, '
                  'sizeWhenDone/size=${firstTorrent['sizeWhenDone'] ?? firstTorrent['size'] ?? firstTorrent['total_size']}',
                );
              }

              final parsed = DownloaderData.fromJson(dataMap);
              debugPrint('[WS] 解析成功: ${parsed.torrents.length} 个种子');
              if (parsed.torrents.isNotEmpty) {
                final Torrent first = parsed.torrents.first;
                debugPrint('[WS] 第一个: name=${first.toJson()}, ');
              }

              state = AsyncValue.data(parsed);
            }
          } catch (e, st) {
            debugPrint('[WS] 解析失败: $e\n$st');
          }
        },
        onError: (e) {
          debugPrint('[WS] 连接错误: $e');
          if (!_disposed && !_wsPaused) _reconnect();
        },
        onDone: () {
          debugPrint('[WS] 连接关闭');
          if (!_disposed && !_wsPaused) _reconnect();
        },
      );

      // 发送订阅参数
      final params = jsonEncode({'downloader_id': downloaderId, 'interval': 5});
      debugPrint('[WS] 发送参数: $params');
      _channel!.sink.add(params);

      debugPrint('[WS] 连接完成, 等待数据...');
    } catch (e, st) {
      debugPrint('[WS] 连接异常: $e');
      debugPrint('[WS] $st');
      if (!_disposed && !_wsPaused) _reconnect();
    }
  }

  void _reconnect() {
    if (_disposed || _wsPaused) {
      debugPrint('[WS] 已 disposed, 不重连');
      return;
    }
    debugPrint('[WS] 3秒后重连...');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_disposed && !_wsPaused) {
        debugPrint('[WS] 开始重连...');
        _connectWs();
      }
    });
  }

  void setWsPaused(bool paused) {
    if (_disposed || _wsPaused == paused) return;
    _wsPaused = paused;
    if (paused) {
      debugPrint('[WS] 暂停, 断开 downloaderId=$downloaderId');
      _disconnectWs();
    } else {
      debugPrint('[WS] 恢复, 重连 downloaderId=$downloaderId');
      _connectWs();
    }
  }

  void _disconnectWs() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    final sub = _sub;
    final channel = _channel;
    _sub = null;
    _channel = null;
    try {
      unawaited(channel?.sink.close(ws_status.normalClosure));
    } catch (_) {}
    unawaited(sub?.cancel());
    debugPrint('[WS] 已断开 downloaderId=$downloaderId');
  }

  @override
  void dispose() {
    debugPrint('[TorrentList] dispose downloaderId=$downloaderId');
    _disposed = true;
    _disconnectWs();
    super.dispose();
  }
}

// ────────────────────── Providers ──────────────────────

final torrentListProvider = StateNotifierProvider.autoDispose
    .family<TorrentListNotifier, AsyncValue<DownloaderData>, int>((ref, id) {
      debugPrint('[Provider] torrentListProvider 创建 id=$id');
      return TorrentListNotifier(id);
    });

final torrentFilterProvider = StateProvider.autoDispose<TorrentFilter>(
  (_) => TorrentFilter.all,
);

final desktopTorrentStatusFilterProvider =
    StateProvider.autoDispose<DesktopTorrentStatusFilter>(
      (_) => DesktopTorrentStatusFilter.all,
    );

final torrentSearchProvider = StateProvider.autoDispose<String>((_) => '');

final torrentSortProvider = StateProvider.autoDispose<TorrentSort>(
  (_) => TorrentSort.queuePosition,
);

final torrentSortAscProvider = StateProvider.autoDispose<bool>((_) => true);

final torrentRefreshPausedProvider = StateProvider.autoDispose
    .family<bool, int>((_, _) => false);

final torrentRefreshRemainingProvider = StateProvider.autoDispose
    .family<int, int>((_, _) => 0);

final downloaderStatusProvider = Provider.autoDispose
    .family<DownloaderStatus?, int>((ref, id) {
      final status = ref.watch(torrentListProvider(id)).valueOrNull?.status;
      debugPrint('[Provider] status 更新: ${status?.torrentCount ?? "null"}');
      return status;
    });

// ── 新增：分类筛选 ──
final torrentCategoryProvider = StateProvider.autoDispose<String>((_) => '');

// ── 新增：标签筛选 ──
final torrentTagProvider = StateProvider.autoDispose<String>((_) => '');

// ── 新增：站点筛选 ──
final torrentSiteFilterProvider = StateProvider.autoDispose<String>((_) => '');
final torrentErrorDetailFilterProvider = StateProvider.autoDispose<String>(
  (_) => '',
);

final torrentSiteMatcherProvider = Provider.autoDispose<TorrentSiteMatcher>((
  ref,
) {
  final sites =
      ref.watch(site_providers.websiteListProvider).valueOrNull ?? const [];
  return TorrentSiteMatcher(sites);
});

final availableTorrentSitesProvider = Provider.autoDispose
    .family<List<TorrentSiteMatch>, int>((ref, id) {
      final data = ref.watch(torrentListProvider(id)).valueOrNull;
      if (data == null) return const <TorrentSiteMatch>[];

      final matcher = ref.watch(torrentSiteMatcherProvider);
      final byKey = <String, TorrentSiteMatch>{};
      for (final torrent in data.torrents) {
        final match = matcher.match(torrent);
        if (match != null) byKey[match.key] = match;
      }

      final list = byKey.values.toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
      return list;
    });

// ── 新增：所有可用分类 ──
final availableCategoriesProvider = Provider.autoDispose
    .family<List<String>, int>((ref, id) {
      final data = ref.watch(torrentListProvider(id)).valueOrNull;
      if (data == null) return [];
      final cats = <String>{};
      for (final torrent in data.torrents) {
        if (torrent.category.isNotEmpty) {
          cats.add(torrent.category);
          continue;
        }
        cats.addAll(_pathCategoryLevels(torrent.downloadDir));
      }
      final list = cats.toList();
      list.sort();
      return list;
    });

List<String> _pathCategoryLevels(String rawPath) {
  final path = rawPath.trim();
  if (path.isEmpty) return const [];
  final normalized = path.replaceAll('\\\\', '/');
  final parts = normalized
      .split('/')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return const [];

  final levels = <String>[];
  for (var i = 0; i < parts.length; i++) {
    levels.add(parts.take(i + 1).join('/'));
  }
  return levels;
}

bool _matchesCategory(Torrent torrent, String category) {
  if (torrent.category.isNotEmpty) return torrent.category == category;
  return _pathCategoryLevels(torrent.downloadDir).contains(category);
}

// ── 新增：所有可用标签 ──
final availableTagsProvider = Provider.autoDispose.family<List<String>, int>((
  ref,
  id,
) {
  final data = ref.watch(torrentListProvider(id)).valueOrNull;
  if (data == null) return [];
  final tags = <String>{};
  for (final t in data.torrents) {
    tags.addAll(t.labels);
  }
  final list = tags.toList();
  list.sort();
  return list;
});

String _normalizedErrorDetail(Torrent torrent) {
  return torrent.effectiveErrorMessage.trim();
}

final availableErrorDetailsProvider = Provider.autoDispose
    .family<List<String>, int>((ref, id) {
      final data = ref.watch(torrentListProvider(id)).valueOrNull;
      if (data == null) return const <String>[];
      final details = <String>{};
      for (final torrent in data.torrents) {
        final detail = _normalizedErrorDetail(torrent);
        if (detail.isNotEmpty) {
          details.add(detail);
        }
      }
      final list = details.toList()..sort();
      return list;
    });

// ── 更新 filteredTorrentsProvider ──
final filteredTorrentsProvider = Provider.autoDispose
    .family<List<Torrent>, int>((ref, id) {
      final asyncData = ref.watch(torrentListProvider(id));
      final filter = ref.watch(torrentFilterProvider);
      final desktopStatusFilter = ref.watch(desktopTorrentStatusFilterProvider);
      final search = ref.watch(torrentSearchProvider).toLowerCase();
      final category = ref.watch(torrentCategoryProvider);
      final tag = ref.watch(torrentTagProvider);
      final site = ref.watch(torrentSiteFilterProvider);
      final errorDetail = ref.watch(torrentErrorDetailFilterProvider);
      final sort = ref.watch(torrentSortProvider);
      final asc = ref.watch(torrentSortAscProvider);
      final matcher = ref.watch(torrentSiteMatcherProvider);

      final data = asyncData.valueOrNull;
      if (data == null) return [];

      var list = List<Torrent>.from(data.torrents);

      // ── 状态过滤 ──
      if (filter != TorrentFilter.all) {
        list = list.where((t) {
          return switch (filter) {
            TorrentFilter.downloading =>
              t.torrentStatus == TorrentStatus.downloading ||
                  t.torrentStatus == TorrentStatus.downloadWait,
            TorrentFilter.seeding =>
              t.torrentStatus == TorrentStatus.seeding ||
                  t.torrentStatus == TorrentStatus.seedWait,
            TorrentFilter.stopped => t.torrentStatus == TorrentStatus.stopped,
            TorrentFilter.waiting =>
              t.torrentStatus == TorrentStatus.checkWait ||
                  t.torrentStatus == TorrentStatus.checking,
            TorrentFilter.error => t.hasError,
            TorrentFilter.all => true,
          };
        }).toList();
      }

      if (desktopStatusFilter != DesktopTorrentStatusFilter.all) {
        list = list
            .where((t) => matchesDesktopTorrentStatus(t, desktopStatusFilter))
            .toList();
      }

      // ── 分类过滤 ──
      if (category.isNotEmpty) {
        list = list.where((t) => _matchesCategory(t, category)).toList();
      }

      // ── 标签过滤 ──
      if (tag.isNotEmpty) {
        list = list.where((t) => t.labels.contains(tag)).toList();
      }

      // ── 站点过滤 ──
      if (site.isNotEmpty) {
        list = list.where((t) => matcher.match(t)?.key == site).toList();
      }

      if (desktopStatusFilter == DesktopTorrentStatusFilter.error &&
          errorDetail.isNotEmpty) {
        list = list
            .where((t) => _normalizedErrorDetail(t) == errorDetail)
            .toList();
      }

      // ── 搜索 ──
      if (search.isNotEmpty) {
        list = list
            .where((t) => t.name.toLowerCase().contains(search))
            .toList();
      }

      // ── 排序 ──
      list.sort((a, b) {
        final cmp = switch (sort) {
          TorrentSort.queuePosition => a.queuePosition.compareTo(
            b.queuePosition,
          ),
          TorrentSort.name => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
          TorrentSort.size => a.sizeWhenDone.compareTo(b.sizeWhenDone),
          TorrentSort.progress => a.percentDone.compareTo(b.percentDone),
          TorrentSort.downloadSpeed => a.rateDownload.compareTo(b.rateDownload),
          TorrentSort.uploadSpeed => a.rateUpload.compareTo(b.rateUpload),
          TorrentSort.ratio => a.uploadRatio.compareTo(b.uploadRatio),
          TorrentSort.addedDate => a.addedDate.compareTo(b.addedDate),
          TorrentSort.activityDate => a.activityDate.compareTo(b.activityDate),
        };
        return asc ? cmp : -cmp;
      });

      return list;
    });

bool matchesDesktopTorrentStatus(
  Torrent torrent,
  DesktopTorrentStatusFilter filter,
) {
  final status = torrent.torrentStatus;
  final completed = _isTorrentCompleted(torrent);

  return switch (filter) {
    DesktopTorrentStatusFilter.all => true,
    DesktopTorrentStatusFilter.active =>
      status == TorrentStatus.downloading || status == TorrentStatus.seeding,
    DesktopTorrentStatusFilter.downloadingActive =>
      status == TorrentStatus.downloading,
    DesktopTorrentStatusFilter.uploadingActive =>
      status == TorrentStatus.seeding,
    DesktopTorrentStatusFilter.waiting =>
      status == TorrentStatus.downloadWait || status == TorrentStatus.seedWait,
    DesktopTorrentStatusFilter.downloadWaiting =>
      status == TorrentStatus.downloadWait,
    DesktopTorrentStatusFilter.seedWaiting => status == TorrentStatus.seedWait,
    DesktopTorrentStatusFilter.checking => status == TorrentStatus.checking,
    DesktopTorrentStatusFilter.checkWaiting =>
      status == TorrentStatus.checkWait,
    DesktopTorrentStatusFilter.paused => status == TorrentStatus.stopped,
    DesktopTorrentStatusFilter.pausedDownloading =>
      status == TorrentStatus.stopped && !completed,
    DesktopTorrentStatusFilter.pausedCompleted =>
      status == TorrentStatus.stopped && completed,
    DesktopTorrentStatusFilter.stalledDownloading =>
      status == TorrentStatus.downloadWait && torrent.isStalled,
    DesktopTorrentStatusFilter.stalledUploading =>
      status == TorrentStatus.seedWait && torrent.isStalled,
    DesktopTorrentStatusFilter.completed => completed,
    DesktopTorrentStatusFilter.error => torrent.hasError,
  };
}

bool _isTorrentCompleted(Torrent torrent) {
  final status = torrent.torrentStatus;
  if (status == TorrentStatus.seeding || status == TorrentStatus.seedWait) {
    return true;
  }
  if (torrent.isFinished || torrent.doneDate > 0) return true;
  if (torrent.percentDone >= 0.999 || torrent.percentComplete >= 0.999) {
    return true;
  }
  return false;
}
