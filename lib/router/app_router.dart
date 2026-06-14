import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/router/router_refresh.dart';

import 'package:harvest/core/utils/utils.dart';
import '../modules/auth/auth_provider.dart';
import '../modules/auth/login_page.dart';
import '../modules/login/account_switcher.dart';
import '../modules/option/widgets/app_upgrade_page.dart';
import '../modules/shell/log_center_page.dart';
import '../modules/shell/shell_page.dart';

final routerRefreshProvider = Provider((ref) {
  return RouterRefreshNotifier();
});

final postLogoutRouteProvider = StateProvider<String?>((_) => null);

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);
  final isLogin = ref.watch(authProvider);
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
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(
        path: '/login-history',
        builder: (_, _) => const AccountSwitcher(),
      ),
      GoRoute(
        path: '/app-upgrade',
        redirect: (_, _) => kIsWeb ? '/dashboard' : null,
        builder: (_, _) => const AppUpgradePage(),
      ),
      GoRoute(path: '/log-center', builder: (_, _) => const LogCenterPage()),
      GoRoute(
        path: '/:tab',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          key: ValueKey<String>('shell-page'),
          child: ShellPage(),
        ),
      ),

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
  globalLogout =
      ({
        String? redirectTo,
        bool openSetupAfterLogout = false,
        String? setupBaseUrl,
      }) => ref
          .read(authProvider.notifier)
          .logout(
            redirectTo: redirectTo,
            openSetupAfterLogout: openSetupAfterLogout,
            setupBaseUrl: setupBaseUrl,
          );

  return router;
});
