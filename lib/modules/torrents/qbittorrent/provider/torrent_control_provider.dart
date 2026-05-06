import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/hooks.dart';

// ══════════════════════════════════════════════════════════
//  种子控制 Provider
// ══════════════════════════════════════════════════════════

class TorrentControlNotifier extends StateNotifier<AsyncValue<void>> {
  TorrentControlNotifier() : super(const AsyncValue.data(null));

  Future<bool> control({required int downloaderId, required Map<String, dynamic> command}) async {
    state = const AsyncValue.loading();
    try {
      await addData('${API.DOWNLOADER_CONTROL}$downloaderId', command);
      debugPrint('[Control] 成功: $command');
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      debugPrint('[Control] 失败: $e');
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final torrentControlProvider = StateNotifierProvider<TorrentControlNotifier, AsyncValue<void>>(
  (ref) => TorrentControlNotifier(),
);

// ══════════════════════════════════════════════════════════
//  统一执行入口
// ══════════════════════════════════════════════════════════

Future<bool> executeTorrentAction({
  required WidgetRef ref,
  required int downloaderId,
  required String action,
  required Map<String, dynamic> params,
}) async {
  final control = ref.read(torrentControlProvider.notifier);

  switch (action) {
    // ── QB 命令 ──

    case 'resume':
    case 'pause':
    case 'recheck':
    case 'reannounce':
    case 'increase_priority':
    case 'decrease_priority':
    case 'top_priority':
    case 'bottom_priority':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': action, 'torrent_hashes': params['hashes']},
      );

    case 'delete':
      return control.control(
        downloaderId: downloaderId,
        command: {
          'command': 'delete',
          'torrent_hashes': params['hashes'],
          'delete_files': params['deleteFiles'] ?? false,
        },
      );

    case 'set_force_start':
    case 'set_auto_management':
    case 'set_super_seeding':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': action, 'torrent_hashes': params['hashes'], 'enable': params['enable']},
      );

    case 'set_location':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': 'set_location', 'torrent_hashes': params['hashes'], 'location': params['savePath']},
      );

    case 'set_category':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': 'set_category', 'torrent_hashes': params['hashes'], 'category': params['category']},
      );

    case 'add_tags':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': 'add_tags', 'torrent_hashes': params['hashes'], 'tags': params['tags']},
      );

    case 'set_upload_limit':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': 'set_upload_limit', 'torrent_hashes': params['hashes'], 'limit': params['limit']},
      );

    case 'set_share_limits':
      return control.control(
        downloaderId: downloaderId,
        command: {
          'command': 'set_share_limits',
          'torrent_hashes': params['hashes'],
          'ratio_limit': params['ratioLimit'],
          'seeding_time_limit': params['seedingTimeLimit'],
        },
      );

    case 'export':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': 'export', 'torrent_hash': (params['hashes'] as List).first},
      );

    // ── TR 命令 ──

    case 'start_torrent':
    case 'stop_torrent':
    case 'verify_torrent':
    case 'reannounce_torrent':
      return control.control(downloaderId: downloaderId, command: {'command': action, 'ids': params['ids']});

    case 'start_torrent_now':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': 'start_torrent', 'ids': params['ids'], 'bypass_queue': true},
      );

    case 'remove_torrent':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': 'remove_torrent', 'ids': params['ids'], 'delete_data': params['deleteFiles'] ?? false},
      );

    case 'move_torrent_data':
      return control.control(
        downloaderId: downloaderId,
        command: {'command': 'move_torrent_data', 'ids': params['ids'], 'location': params['savePath'], 'move': true},
      );

    case 'queue_top':
    case 'queue_up':
    case 'queue_down':
    case 'queue_bottom':
      return control.control(downloaderId: downloaderId, command: {'command': action, 'ids': params['ids']});

    case 'change_torrent':
      return control.control(
        downloaderId: downloaderId,
        command: {
          'command': 'change_torrent',
          'ids': params['ids'],
          if (params['labels'] != null) 'labels': params['labels'],
          if (params['trackerList'] != null) 'tracker_list': params['trackerList'],
        },
      );

    default:
      debugPrint('[Control] 未知命令: $action');
      return false;
  }
}
