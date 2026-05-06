import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';

import '../../config/app_config.dart';
import '../../storage/hive_manager.dart';
import '../api.dart';
import '../dio_client.dart';

class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  bool _logoutScheduled = false;
  final List<Completer<void>> _waitQueue = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = HiveManager.get<String>(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      _logoutScheduled = false;
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.debug(
        '[Auth] token attached: ${options.method} ${options.path}',
      );
      return handler.next(options);
    }

    if (_isAuthExemptPath(options.path)) {
      AppLogger.debug(
        '[Auth] auth exempt request: ${options.method} ${options.path}',
      );
      return handler.next(options);
    }

    AppLogger.warn(
      '[Auth] request canceled without token: ${options.method} ${options.path}',
    );
    return handler.reject(_silentCancel(options));
  }

  bool _isAuthExemptPath(String path) {
    return path.contains(API.TOKEN_PAIR) ||
        path.contains(API.TOKEN_REFRESH) ||
        path.contains(API.TOKEN_VERIFY) ||
        path.contains(API.LOGIN_URL);
  }

  bool _isSilentCancel(DioException err) {
    return err.type == DioExceptionType.cancel &&
        err.error?.toString() == 'token_expired';
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isSilentCancel(err)) {
      return handler.next(err);
    }

    final status = err.response?.statusCode;
    final responseData = err.response?.data;
    final alreadyLoggedOut = status == 401 && _isAlreadyLoggedOut;

    if (!alreadyLoggedOut) {
      AppLogger.warn(
        '[Auth] request error path=${err.requestOptions.path} status=$status',
      );
    }

    // 网络错误
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      Toast.error("服务器连接失败，请检查网络或服务器地址");
      return handler.next(err);
    }

    // 非 401 → 直接提示
    if (status != 401) {
      Toast.error(_extractMsg(status, responseData));
      return handler.next(err);
    }

    // 以下全部是 401 处理
    if (alreadyLoggedOut) {
      return handler.reject(_silentCancel(err.requestOptions));
    }

    // 刷新接口本身 401 → refreshToken 也失效了，静默登出
    if (err.requestOptions.path.contains(API.TOKEN_REFRESH)) {
      AppLogger.warn('[Auth] refresh endpoint returned 401, session expired');
      await _logout();
      return handler.reject(_silentCancel(err.requestOptions));
    }

    // 获取 refreshToken
    final refreshToken = HiveManager.get<String>(StorageKeys.refreshToken);
    AppLogger.debug(
      '[Auth] refresh token exists=${refreshToken?.isNotEmpty == true}',
    );

    // 没有 refreshToken → 静默登出
    if (refreshToken == null || refreshToken.isEmpty) {
      AppLogger.warn('[Auth] missing refresh token, logout scheduled');
      await _logout();
      return handler.reject(_silentCancel(err.requestOptions));
    }

    // 已经在刷新中 → 排队等待
    if (_isRefreshing) {
      AppLogger.info('[Auth] token refresh in progress, request queued');
      final completer = Completer<void>();
      _waitQueue.add(completer);
      await completer.future;

      // 刷新完成后用新 token 重试
      final newToken = HiveManager.get(StorageKeys.accessToken);

      // 如果刷新失败 token 被清空了，直接拒绝
      if (newToken == null || newToken.isEmpty) {
        return handler.reject(_silentCancel(err.requestOptions));
      }

      final request = err.requestOptions;
      request.headers['Authorization'] = 'Bearer $newToken';

      try {
        final response = await DioClient.dio.fetch(request);
        return handler.resolve(response);
      } catch (e) {
        return handler.reject(_silentCancel(err.requestOptions));
      }
    }

    // 开始刷新
    _isRefreshing = true;
    AppLogger.info('[Auth] refreshing access token');

    try {
      final res = await Dio().post(
        '${AppConfig.baseUrl}${API.TOKEN_REFRESH}',
        data: {'refresh': refreshToken},
      );

      AppLogger.info('[Auth] access token refreshed');

      final currentRefreshToken = HiveManager.get<String>(
        StorageKeys.refreshToken,
      );
      if (currentRefreshToken != refreshToken) {
        AppLogger.warn(
          '[Auth] auth state changed during refresh, retry canceled',
        );
        for (var c in _waitQueue) {
          c.complete();
        }
        _waitQueue.clear();
        return handler.reject(_silentCancel(err.requestOptions));
      }

      final data = res.data['data'];
      final newAccess = data['access'];
      final newRefresh = data['refresh'];

      // 保存新 token
      await HiveManager.set(StorageKeys.accessToken, newAccess);
      if (newRefresh != null) {
        await HiveManager.set(StorageKeys.refreshToken, newRefresh);
      }

      // 唤醒排队的请求
      for (var c in _waitQueue) {
        c.complete();
      }
      _waitQueue.clear();

      // 用新 token 重试当前请求
      final request = err.requestOptions;
      request.headers['Authorization'] = 'Bearer $newAccess';

      final response = await DioClient.dio.fetch(request);
      return handler.resolve(response);
    } catch (e) {
      AppLogger.error('[Auth] token refresh failed', e);

      // 刷新失败 → 唤醒排队请求（它们会发现 token 为空直接拒绝）
      for (var c in _waitQueue) {
        c.complete();
      }
      _waitQueue.clear();

      await _logout();
      return handler.reject(_silentCancel(err.requestOptions));
    } finally {
      _isRefreshing = false;
    }
  }

  /// 构造一个静默取消的 DioException，不会被 UI 层当作真正的错误弹出
  DioException _silentCancel(RequestOptions options) {
    return DioException(
      requestOptions: options,
      type: DioExceptionType.cancel,
      error: 'token_expired',
    );
  }

  /// 提取错误消息
  String _extractMsg(int? status, dynamic data) {
    if (data is Map) {
      final msg = data['msg']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    if (status == 400) return '请求参数错误';
    if (status == 403) return '没有权限执行此操作';
    if (status == 404) return '接口不存在';
    if (status == 405) return '请求方法不正确';
    if (status == 500) return '服务器内部错误';
    return '请求失败 (${status ?? '网络异常'})';
  }

  Future<void> _logout() async {
    if (_logoutScheduled) return;

    final accessToken = HiveManager.get(StorageKeys.accessToken);
    final refreshToken = HiveManager.get(StorageKeys.refreshToken);
    final authState = HiveManager.get(StorageKeys.authState);
    if (accessToken == null && refreshToken == null && authState == null) {
      return;
    }

    _logoutScheduled = true;
    AppLogger.warn('[Auth] logout scheduled, clearing auth session');
    await Future.wait([
      HiveManager.delete(StorageKeys.accessToken),
      HiveManager.delete(StorageKeys.refreshToken),
      HiveManager.delete(StorageKeys.authState),
    ]);
    HiveManager.clearScope();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final logout = globalLogout;
      if (logout != null) {
        unawaited(logout());
      }
      _logoutScheduled = false;
    });
  }

  bool get _isAlreadyLoggedOut {
    final accessToken = HiveManager.get(StorageKeys.accessToken);
    final refreshToken = HiveManager.get(StorageKeys.refreshToken);
    final authState = HiveManager.get(StorageKeys.authState);
    return accessToken == null && refreshToken == null && authState == null;
  }
}
