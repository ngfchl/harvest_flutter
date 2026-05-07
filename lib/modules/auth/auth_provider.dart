import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:harvest/modules/auth/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/http/api.dart';
import '../../core/http/dio_client.dart';
import '../../core/http/http_error.dart';
import '../../core/http/hooks.dart';
import '../../core/http/http.dart';
import '../../core/config/app_config.dart';
import '../../core/storage/hive_manager.dart';
import '../../core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';
import '../../router/app_router.dart';
import '../login/login_history_provider.dart';
import '../login/login_record.dart';
import 'session_state_reset.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

/// 合并后的状态：认证信息 + 用户信息
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool loading,
    @Default(false) bool loggedIn,
    String? accessToken,
    String? refreshToken,
    User? user,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) =>
      _$AuthStateFromJson(json);
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  bool _autoLoginAttempted = false; // ✅ 放在 provider 层，不受 widget 重建影响
  bool _logoutInProgress = false;

  @override
  AuthState build() {
    final json = HiveManager.get(StorageKeys.authState);
    if (json != null) {
      final restored = AuthState.fromJson(json);
      if (restored.user != null) {
        HiveManager.setScope(
          server: AppConfig.baseUrl,
          username: restored.user!.username,
        );
      }
      if (restored.accessToken != null) {
        HiveManager.set(StorageKeys.accessToken, restored.accessToken!);
      }
      if (restored.refreshToken != null) {
        HiveManager.set(StorageKeys.refreshToken, restored.refreshToken!);
      }
      Future<void>.delayed(Duration.zero, getUser);
      return restored.copyWith(loading: false);
    }
    return const AuthState();
  }

  /// debug 模式自动登录
  Future<void> autoLogin(
    String baseUrl,
    String username,
    String password,
  ) async {
    if (_autoLoginAttempted) return; // ✅ 只执行一次
    _autoLoginAttempted = true;
    await login(baseUrl, username, password);
  }

  /// 获取用户信息
  Future<void> getUser() async {
    AppLogger.debug("开始获取登录用户信息");
    try {
      final user = await fetchModel(API.USER_INFO, User.fromJson);
      if (user != null) {
        state = state.copyWith(user: user);
        _saveState();
      }
    } catch (e) {
      if (isSilentAuthCancel(e)) return;
      AppLogger.error("getUser 失败: $e");
    }
  }

  /// 登录
  Future<void> login(String baseUrl, String username, String password) async {
    state = state.copyWith(loading: true, user: null);

    try {
      final normalizedBaseUrl = AppConfig.normalizeBaseUrl(baseUrl);
      await AppConfig.setBaseUrl(normalizedBaseUrl);
      DioClient.setBaseUrl(normalizedBaseUrl);
      HiveManager.setScope(server: normalizedBaseUrl, username: username);

      final res = await Http.post<Map>(
        API.TOKEN_PAIR,
        data: {'username': username, 'password': password},
      );

      final access = res['access'];
      final refresh = res['refresh'];

      await HiveManager.set(StorageKeys.accessToken, access);
      await HiveManager.set(StorageKeys.refreshToken, refresh);

      await ref
          .read(loginHistoryProvider.notifier)
          .add(
            LoginRecord(
              server: normalizedBaseUrl,
              username: username,
              password: password,
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );

      state = state.copyWith(
        loading: false,
        loggedIn: true,
        accessToken: access,
        refreshToken: refresh,
        user: User(id: 0, username: username),
      );
      _saveState();

      await getUser();
      ref.read(postLogoutRouteProvider.notifier).state = null;
      invalidateSessionState(ref);

      // ✅ 只有登录成功才刷新路由
      ref.read(routerRefreshProvider).refresh();
    } catch (e) {
      // ✅ 登录失败，不刷新路由，只更新状态
      AppLogger.error("登录失败: $e");
      state = state.copyWith(loading: false);
      rethrow;
    } finally {
      AppLogger.debug("登录过程结束，最终状态：${state.toJson()}");
    }
  }

  /// 登出
  Future<void> logout({String? redirectTo}) async {
    if (_logoutInProgress) return;
    _logoutInProgress = true;

    try {
      ref.read(postLogoutRouteProvider.notifier).state = redirectTo;
      await Future.wait([
        HiveManager.delete(StorageKeys.accessToken),
        HiveManager.delete(StorageKeys.refreshToken),
        HiveManager.delete(StorageKeys.authState),
      ]);
      HiveManager.clearScope();
      state = const AuthState(loading: false, loggedIn: false);
      ref.read(routerRefreshProvider).refresh();

      Future<void>.delayed(Duration.zero, () {
        invalidateSessionState(ref);
      });
    } finally {
      _logoutInProgress = false;
    }
  }

  /// 持久化状态
  void _saveState() {
    final json = state.toJson();
    // user 是嵌套对象，需要手动转成 Map
    if (state.user != null) {
      json['user'] = state.user!.toJson();
      HiveManager.setScope(
        server: AppConfig.baseUrl,
        username: state.user!.username,
      );
    }
    HiveManager.set(StorageKeys.authState, json);
  }
}
