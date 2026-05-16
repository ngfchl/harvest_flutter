import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
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

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb || !_isSupportedPlatform) return;

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

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    await _requestPermissions();
    _initialized = true;
  }

  Future<void> handleLaunchNotificationTap() async {
    if (kIsWeb || !_isSupportedPlatform) return;
    await initialize();

    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openNoticeHistory();
    });
  }

  Future<void> showNewNotices(List<NoticeHistory> notices) async {
    if (kIsWeb || !_isSupportedPlatform || notices.isEmpty) return;

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
    final unreadCount = notices.where((notice) => !notice.isRead).length;

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
    for (final notice in newUnreadNotices) {
      await _showNotice(notice, badgeCount: unreadCount);
    }

    await HiveManager.set(StorageKeys.localNoticeLastNotifiedId, maxNoticeId);
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
      PageRouteBuilder(pageBuilder: (_, __, ___) => const NoticeHistoryPage()),
    );
  }

  bool get _isSupportedPlatform {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      _ => false,
    };
  }
}
