import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/notice_history.dart';
import '../service/local_notice_notification_service.dart';
import '../service/notice_service.dart';

final noticeHistoryProvider =
    AsyncNotifierProvider<NoticeHistoryNotifier, List<NoticeHistory>>(
      NoticeHistoryNotifier.new,
    );

final noticeUnreadCountProvider = StateProvider<int>((_) => 0);

class NoticeHistoryNotifier extends AsyncNotifier<List<NoticeHistory>> {
  @override
  Future<List<NoticeHistory>> build() {
    if (!HiveManager.hasAccessToken) {
      _syncBadgeFor(const <NoticeHistory>[]);
      return Future.value(const <NoticeHistory>[]);
    }
    return _fetchNoticeHistoryWithNotification();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = const AsyncValue.data(<NoticeHistory>[]);
      _syncBadgeFor(const <NoticeHistory>[]);
      return;
    }

    final previous = state.value;
    if (previous == null) state = const AsyncValue.loading();

    final result = await AsyncValue.guard(_fetchNoticeHistoryWithNotification);
    if (result.hasError && previous != null) {
      state = AsyncValue.data(previous);
      _syncBadgeFor(previous);
      return;
    }
    state = result;
    final notices = result.value;
    if (notices != null) _syncBadgeFor(notices);
  }

  Future<void> markRead(NoticeHistory notice) async {
    if (!HiveManager.hasAccessToken) return;
    if (notice.isRead || notice.id <= 0) return;

    final previous = state.value;
    final previousUnreadCount = ref.read(noticeUnreadCountProvider);
    final changedLocally = _setReadLocally({notice.id}, syncBadge: false);
    _syncUnreadCount(previousUnreadCount - 1, forceBadgeSync: true);
    if (!changedLocally && previous != null) state = AsyncValue.data(previous);
    unawaited(LocalNoticeNotificationService.instance.clearNotice(notice.id));

    try {
      await NoticeService.markRead(notice.id);
    } catch (_) {
      if (previous != null) {
        state = AsyncValue.data(previous);
        _syncBadgeFor(previous);
      } else {
        _syncUnreadCount(previousUnreadCount);
      }
      rethrow;
    }
  }

  Future<void> deleteNotice(NoticeHistory notice) async {
    if (!HiveManager.hasAccessToken) return;
    if (notice.id <= 0) return;

    final previous = state.value;
    final previousUnreadCount = ref.read(noticeUnreadCountProvider);
    final notices = previous ?? const <NoticeHistory>[];
    final removedUnread = notices.any(
      (item) => item.id == notice.id && !item.isRead,
    );
    state = AsyncValue.data([
      for (final item in notices)
        if (item.id != notice.id) item,
    ]);
    _syncBadgeFor(state.value ?? const <NoticeHistory>[]);
    if (previous == null && !notice.isRead) {
      _syncUnreadCount(previousUnreadCount - 1, forceBadgeSync: true);
    } else if (!removedUnread && !notice.isRead) {
      _syncUnreadCount(previousUnreadCount - 1, forceBadgeSync: true);
    }
    unawaited(LocalNoticeNotificationService.instance.clearNotice(notice.id));

    try {
      await NoticeService.deleteNotice(notice.id);
    } catch (_) {
      if (previous != null) {
        state = AsyncValue.data(previous);
        _syncBadgeFor(previous);
      } else {
        _syncUnreadCount(previousUnreadCount);
      }
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    if (!HiveManager.hasAccessToken) return;

    final notices = state.value ?? const <NoticeHistory>[];
    final unreadIds = notices
        .where((notice) => !notice.isRead && notice.id > 0)
        .map((notice) => notice.id)
        .toSet();
    final previousUnreadCount = ref.read(noticeUnreadCountProvider);
    if (unreadIds.isEmpty && previousUnreadCount <= 0) return;

    final previous = List<NoticeHistory>.from(notices);
    if (unreadIds.isEmpty) {
      _syncUnreadCount(0, forceBadgeSync: true);
    } else {
      _setReadLocally(unreadIds, syncBadge: false);
      _syncUnreadCount(0, forceBadgeSync: true);
    }
    unawaited(LocalNoticeNotificationService.instance.clearAllNotices());

    try {
      await NoticeService.markAllRead();
    } catch (_) {
      state = AsyncValue.data(previous);
      if (previous.isEmpty) {
        _syncUnreadCount(previousUnreadCount);
      } else {
        _syncBadgeFor(previous);
      }
      rethrow;
    }
  }

  Future<void> deleteAll() async {
    if (!HiveManager.hasAccessToken) return;

    final previous = state.value;
    final notices = previous ?? const <NoticeHistory>[];
    final previousUnreadCount = ref.read(noticeUnreadCountProvider);
    if (notices.isEmpty && previousUnreadCount <= 0) return;

    state = const AsyncValue.data(<NoticeHistory>[]);
    _syncBadgeFor(const <NoticeHistory>[]);
    unawaited(LocalNoticeNotificationService.instance.clearAllNotices());

    try {
      await NoticeService.deleteAll();
    } catch (_) {
      if (previous != null) {
        state = AsyncValue.data(previous);
        _syncBadgeFor(previous);
      } else {
        _syncUnreadCount(previousUnreadCount);
      }
      rethrow;
    }
  }

  bool _setReadLocally(Set<int> ids, {bool syncBadge = true}) {
    final notices = state.value;
    if (notices == null) return false;
    var changed = false;

    state = AsyncValue.data([
      for (final notice in notices)
        if (ids.contains(notice.id) && !notice.isRead) ...[
          notice.copyWith(isRead: true),
        ] else
          notice,
    ]);
    for (final notice in notices) {
      if (ids.contains(notice.id) && !notice.isRead) {
        changed = true;
        break;
      }
    }
    if (syncBadge) _syncBadgeFor(state.value ?? const <NoticeHistory>[]);
    return changed;
  }

  Future<List<NoticeHistory>> _fetchNoticeHistoryWithNotification() async {
    final notices = await NoticeService.fetchNoticeHistory();
    try {
      await LocalNoticeNotificationService.instance.showNewNotices(notices);
    } catch (_) {
      // 系统通知失败不应影响站内通知列表刷新。
    }
    _syncBadgeFor(notices);
    return notices;
  }

  void _syncBadgeFor(List<NoticeHistory> notices) {
    final unreadCount = notices.where((notice) => !notice.isRead).length;
    _syncUnreadCount(unreadCount);
  }

  void _syncUnreadCount(int count, {bool forceBadgeSync = false}) {
    final unreadCount = count < 0 ? 0 : count;
    ref.read(noticeUnreadCountProvider.notifier).state = unreadCount;
    unawaited(
      LocalNoticeNotificationService.instance
          .syncBadgeCount(unreadCount, force: forceBadgeSync)
          .catchError((Object error) {
            // 系统角标同步失败不能影响站内未读状态。
          }),
    );
  }
}
