import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/notice_history.dart';
import '../service/notice_service.dart';

final noticeHistoryProvider =
    AsyncNotifierProvider<NoticeHistoryNotifier, List<NoticeHistory>>(
      NoticeHistoryNotifier.new,
    );

final noticeUnreadCountProvider = Provider<int>((ref) {
  final notices =
      ref.watch(noticeHistoryProvider).valueOrNull ?? const <NoticeHistory>[];
  return notices.where((notice) => !notice.isRead).length;
});

class NoticeHistoryNotifier extends AsyncNotifier<List<NoticeHistory>> {
  @override
  Future<List<NoticeHistory>> build() {
    if (!HiveManager.hasAccessToken) {
      return Future.value(const <NoticeHistory>[]);
    }
    return NoticeService.fetchNoticeHistory();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = const AsyncValue.data(<NoticeHistory>[]);
      return;
    }

    final previous = state.valueOrNull;
    if (previous == null) state = const AsyncValue.loading();

    final result = await AsyncValue.guard(NoticeService.fetchNoticeHistory);
    if (result.hasError && previous != null) {
      state = AsyncValue.data(previous);
      return;
    }
    state = result;
  }

  Future<void> markRead(NoticeHistory notice) async {
    if (!HiveManager.hasAccessToken) return;
    if (notice.isRead || notice.id <= 0) return;

    final previous = state.valueOrNull;
    _setReadLocally({notice.id});

    try {
      await NoticeService.markRead(notice.id);
    } catch (_) {
      if (previous != null) state = AsyncValue.data(previous);
      rethrow;
    }
  }

  Future<void> deleteNotice(NoticeHistory notice) async {
    if (!HiveManager.hasAccessToken) return;
    if (notice.id <= 0) return;

    final previous = state.valueOrNull;
    final notices = previous ?? const <NoticeHistory>[];
    state = AsyncValue.data([
      for (final item in notices)
        if (item.id != notice.id) item,
    ]);

    try {
      await NoticeService.deleteNotice(notice.id);
    } catch (_) {
      if (previous != null) state = AsyncValue.data(previous);
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    if (!HiveManager.hasAccessToken) return;

    final notices = state.valueOrNull ?? const <NoticeHistory>[];
    final unreadIds = notices
        .where((notice) => !notice.isRead && notice.id > 0)
        .map((notice) => notice.id)
        .toSet();
    if (unreadIds.isEmpty) return;

    final previous = List<NoticeHistory>.from(notices);
    _setReadLocally(unreadIds);

    try {
      await NoticeService.markAllRead();
    } catch (_) {
      state = AsyncValue.data(previous);
      rethrow;
    }
  }

  Future<void> deleteAll() async {
    if (!HiveManager.hasAccessToken) return;

    final previous = state.valueOrNull;
    final notices = previous ?? const <NoticeHistory>[];
    if (notices.isEmpty) return;

    state = const AsyncValue.data(<NoticeHistory>[]);

    try {
      await NoticeService.deleteAll();
    } catch (_) {
      if (previous != null) state = AsyncValue.data(previous);
      rethrow;
    }
  }

  void _setReadLocally(Set<int> ids) {
    final notices = state.valueOrNull;
    if (notices == null) return;

    state = AsyncValue.data([
      for (final notice in notices)
        ids.contains(notice.id) ? notice.copyWith(isRead: true) : notice,
    ]);
  }
}
