import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/logging/logger.dart';
import 'package:harvest/core/utils/navigation/navigator_key.dart';

import '../model/notice_history.dart';
import '../notice_history_page.dart';

class LocalNoticeNotificationService {
  LocalNoticeNotificationService._();

  static final LocalNoticeNotificationService instance =
      LocalNoticeNotificationService._();

  static const String _channelId = 'harvest_notice';
  static const String _channelName = 'Harvest 通知';
  static const String _channelDescription = 'Harvest 站内通知提醒';
  static const MethodChannel _badgeChannel = MethodChannel(
    'com.ptools.harvest/app_badge',
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _initializationFailed = false;
  int? _pendingBadgeCount;
  bool _pendingBadgeForce = false;
  int? _lastSyncedBadgeCount;
  Future<void>? _badgeSyncTask;

  Future<void> initialize() async {
    if (_initialized ||
        _initializationFailed ||
        kIsWeb ||
        !_isSupportedPlatform) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      windows: WindowsInitializationSettings(
        appName: 'Harvest',
        appUserModelId: 'com.ptools.harvest',
        guid: '7ecf6eb2-5a0e-4d16-bf2e-2a69d7b1083c',
      ),
    );

    try {
      await _plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      await _requestPermissions();
      _initialized = true;
    } catch (e, st) {
      _initializationFailed = true;
      AppLogger.error('本地通知初始化失败', e, st);
    }
  }

  Future<void> handleLaunchNotificationTap() async {
    if (kIsWeb || !_isSupportedPlatform) return;
    await initialize();
    if (!_initialized) return;

    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openNoticeHistory();
    });
  }

  Future<void> showNewNotices(List<NoticeHistory> notices) async {
    if (kIsWeb || !_isSupportedPlatform) return;

    final unreadCount = notices.where((notice) => !notice.isRead).length;
    await syncBadgeCount(unreadCount);
    if (notices.isEmpty) return;

    final maxNoticeId = notices
        .map((notice) => notice.id)
        .where((id) => id > 0)
        .fold<int>(0, (max, id) => id > max ? id : max);
    if (maxNoticeId <= 0) return;

    final lastNotifiedId = HiveManager.get<int>(
      StorageKeys.localNoticeLastNotifiedId,
    );

    if (lastNotifiedId == null) {
      await HiveManager.set(StorageKeys.localNoticeLastNotifiedId, maxNoticeId);
      return;
    }

    final newUnreadNotices =
        notices
            .where((notice) => !notice.isRead && notice.id > lastNotifiedId)
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    if (newUnreadNotices.isEmpty) {
      if (maxNoticeId > lastNotifiedId) {
        await HiveManager.set(
          StorageKeys.localNoticeLastNotifiedId,
          maxNoticeId,
        );
      }
      return;
    }

    await initialize();
    if (!_initialized) return;
    for (final notice in newUnreadNotices) {
      await _showNotice(notice, badgeCount: unreadCount);
    }

    await HiveManager.set(StorageKeys.localNoticeLastNotifiedId, maxNoticeId);
  }

  Future<void> syncBadgeCount(int count, {bool force = false}) async {
    if (kIsWeb || !_isBadgeSupportedPlatform) return;

    final effectiveCount = count < 0 ? 0 : count;
    _pendingBadgeCount = effectiveCount;
    _pendingBadgeForce = _pendingBadgeForce || force;
    _badgeSyncTask ??= _drainBadgeSyncQueue();
    await _badgeSyncTask;
  }

  Future<void> clearNotice(int id) async {
    if (kIsWeb || !_isSupportedPlatform || id <= 0) return;
    await initialize();
    if (!_initialized) return;

    try {
      await _plugin.cancel(id: id);
    } catch (e, st) {
      AppLogger.error('清理本地通知失败', e, st);
    }
  }

  Future<void> clearAllNotices() async {
    if (kIsWeb || !_isSupportedPlatform) return;
    await initialize();
    if (!_initialized) return;

    try {
      await _plugin.cancelAll();
    } catch (e, st) {
      AppLogger.error('清理全部本地通知失败', e, st);
    }
  }

  Future<void> _drainBadgeSyncQueue() async {
    while (true) {
      final count = _pendingBadgeCount;
      if (count == null) {
        _badgeSyncTask = null;
        if (_pendingBadgeCount == null) return;
        _badgeSyncTask ??= _drainBadgeSyncQueue();
        await _badgeSyncTask;
        return;
      }

      final force = _pendingBadgeForce;
      _pendingBadgeCount = null;
      _pendingBadgeForce = false;
      if (!force && _lastSyncedBadgeCount == count) continue;

      try {
        await _badgeChannel.invokeMethod<void>('setBadgeCount', count);
        _lastSyncedBadgeCount = count;
        AppLogger.debug('同步应用角标: $count');
      } catch (e, st) {
        AppLogger.error('同步应用角标失败', e, st);
      }
    }
  }

  Future<void> _showNotice(NoticeHistory notice, {required int badgeCount}) {
    final effectiveBadgeCount = badgeCount < 0 ? 0 : badgeCount;
    return _plugin.show(
      id: notice.id,
      title: notice.title.isEmpty ? 'Harvest 通知' : notice.title,
      body: notice.content,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(notice.content),
          number: effectiveBadgeCount,
        ),
        iOS: DarwinNotificationDetails(
          presentBadge: true,
          badgeNumber: effectiveBadgeCount,
        ),
        macOS: DarwinNotificationDetails(
          presentBadge: true,
          badgeNumber: effectiveBadgeCount,
        ),
        windows: const WindowsNotificationDetails(),
      ),
      payload: '${notice.id}',
    );
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _handleNotificationResponse(NotificationResponse response) {
    _openNoticeHistory();
  }

  void _openNoticeHistory() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      PageRouteBuilder(pageBuilder: (_, _, _) => const NoticeHistoryPage()),
    );
  }

  bool get _isSupportedPlatform {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  bool get _isBadgeSupportedPlatform {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
  }
}
