import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/shell/widgets/log_floating_overlay.dart';

import '../login/login_history_provider.dart';
import 'auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _serverController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _filledFromHistory = false;

  @override
  void initState() {
    super.initState();
    final savedServer = HiveManager.get<String>(StorageKeys.baseUrl) ?? '';
    if (kDebugMode) {
      _serverController = TextEditingController(
        text: savedServer.isNotEmpty ? savedServer : 'http://127.0.0.1:8000',
      );
      _usernameController = TextEditingController(text: 'admin');
      _passwordController = TextEditingController(text: 'adminadmin');
    } else {
      _serverController = TextEditingController(text: savedServer);
      _usernameController = TextEditingController();
      _passwordController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    ref.listen(loginHistoryProvider, (prev, next) {
      if (!_filledFromHistory && next.isNotEmpty) {
        final latest = next.first;
        if (_serverController.text.trim().isEmpty) {
          _serverController.text = latest.server;
        }
        if (_usernameController.text.trim().isEmpty) {
          _usernameController.text = latest.username;
        }
        if (_passwordController.text.trim().isEmpty) {
          _passwordController.text = latest.password;
        }
        _filledFromHistory = true;
      }
    });

    return FScaffold(
      childPad: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    kDebugMode ? '调试模式' : '登录系统',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  FTextField(
                    controller: _serverController,
                    label: const Text('服务器地址'),
                  ),
                  const SizedBox(height: 12),
                  FTextField(
                    controller: _usernameController,
                    label: const Text('账号'),
                  ),
                  const SizedBox(height: 12),
                  FTextField(
                    controller: _passwordController,
                    label: const Text('密码'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          onPress: auth.loading
                              ? null
                              : () async {
                                  try {
                                    await ref
                                        .read(authNotifierProvider.notifier)
                                        .login(
                                          AppConfig.normalizeBaseUrl(
                                            _serverController.text,
                                          ),
                                          _usernameController.text.trim(),
                                          _passwordController.text,
                                        );
                                  } catch (e, trace) {
                                    AppLogger.error(e);
                                    AppLogger.error(trace);
                                  }
                                },
                          child: Text(auth.loading ? '登录中...' : '登录'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FButton.icon(
                        style: FButtonStyle.outline(),
                        onPress: auth.loading
                            ? null
                            : () => context.go('/login-history'),
                        child: FTooltip(
                          tipBuilder: (_, __) => const Text('登录历史'),
                          child: const Icon(FIcons.history, size: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FButton.icon(
                        style: FButtonStyle.outline(),
                        onPress: () => LogOverlayManager.toggle(context),
                        child: FTooltip(
                          tipBuilder: (_, __) => const Text('日志中心'),
                          child: const Icon(FIcons.terminal, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
