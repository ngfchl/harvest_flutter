import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/router/router_refresh.dart';

import 'package:harvest/core/utils/utils.dart';
import '../modules/auth/auth_provider.dart';
import '../modules/auth/login_page.dart';
import '../modules/login/account_switcher.dart';
import '../modules/option/widgets/app_upgrade_page.dart';
import '../modules/shell/shell_page.dart';

final routerRefreshProvider = Provider((ref) {
  return RouterRefreshNotifier();
});

final postLogoutRouteProvider = StateProvider<String?>((_) => null);

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);
  final isLogin = ref.watch(authNotifierProvider);
  final postLogoutRoute = ref.watch(postLogoutRouteProvider);

  final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/dashboard',

    /// ✅ 正确方式
    refreshListenable: refreshNotifier,

    redirect: (context, state) {
      // AppLogger.info('isLogin: ${isLogin.loggedIn}');
      // AppLogger.info('redirect: ${state.uri.path}');
      final authRoute =
          state.uri.path == '/login' || state.uri.path == '/login-history';

      if (!isLogin.loggedIn && !authRoute) {
        return postLogoutRoute ?? '/login';
      }

      if (isLogin.loggedIn && authRoute) {
        return '/dashboard';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/login-history',
        builder: (_, __) => const AccountSwitcher(),
      ),
      GoRoute(
        path: '/app-upgrade',
        redirect: (_, __) => kIsWeb ? '/dashboard' : null,
        builder: (_, __) => const AppUpgradePage(),
      ),
      GoRoute(path: '/:tab', builder: (context, state) => const ShellPage()),

      /// ⭐ Shell 主框架
      // ShellRoute(
      //   builder: (context, state, child) {
      //     return ShellPage(child: child);
      //   },
      //   routes: [
      //     GoRoute(path: '/home', builder: (_, __) => const NewsPage()),
      //     GoRoute(path: '/site', builder: (_, __) => const SitePage()),
      //     GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      //     GoRoute(path: '/download', builder: (_, __) => const DownloadPage()),
      //     GoRoute(path: '/task', builder: (_, __) => const TaskPage()),
      //   ],
      // ),
    ],
  );
  // 挂载全局引用
  globalLogout = () => ref.read(authNotifierProvider.notifier).logout();

  return router;
});
