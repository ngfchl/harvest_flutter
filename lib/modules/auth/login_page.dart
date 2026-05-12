import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/shell/widgets/log_floating_overlay.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../login/login_history_provider.dart';
import '../login/login_record.dart';
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
  static const _debugUsername = 'admin';
  static const _debugPassword = 'adminadmin';
  static const _debugServer = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    final savedServer = HiveManager.get<String>(StorageKeys.baseUrl) ?? '';
    final webServer = kIsWeb ? _webServerFromPageUrl() : null;
    if (kDebugMode) {
      _serverController = TextEditingController(
        text: webServer ??
            (savedServer.isNotEmpty ? savedServer : _debugServer),
      );
      _usernameController = TextEditingController(text: _debugUsername);
      _passwordController = TextEditingController(text: _debugPassword);
    } else {
      _serverController = TextEditingController(text: webServer ?? savedServer);
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
    final loginHistory = ref.watch(loginHistoryProvider);
    final showLoginHistory = loginHistory.length >= 2;
    final tokens = _LoginThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = theme.colorScheme;

    _fillFromLoginHistory(loginHistory);
    ref.listen(loginHistoryProvider, (prev, next) => _fillFromLoginHistory(next));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: ColoredBox(
        color: cs.background,
        child: Padding(
          padding: tokens.edgeSymmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: tokens.formWidth),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  tokens.vGap(40),
                  Image.asset(
                    'assets/images/logo.png',
                    width: tokens.logoSize,
                    height: tokens.logoSize,
                    fit: BoxFit.contain,
                  ),
                  tokens.vGap(16),
                  Text(
                    kDebugMode ? '调试模式' : 'PT 一下',
                    style: theme.typography.xLarge.copyWith(
                      color: cs.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  tokens.vGap(20),
                  ShadTextField(
                    controller: _serverController,
                    placeholder: const Text('服务器地址'),
                    enabled: !kIsWeb,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  ),
                  tokens.fieldGap,
                  ShadTextField(
                    controller: _usernameController,
                    placeholder: const Text('账号'),
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  ),
                  tokens.fieldGap,
                  ShadTextField(
                    controller: _passwordController,
                    placeholder: const Text('密码'),
                    obscureText: true,
                    maxLines: 1,
                    features: const [shadcn.InputFeature.passwordToggle()],
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  ),
                  tokens.vGap(20),
                  Row(
                    children: [
                      Expanded(
                        child: shadcn.Button.primary(
                          onPressed: auth.loading
                              ? null
                              : () async {
                                  final serverError = _validateServerAddress(
                                    _serverController.text,
                                  );
                                  if (serverError != null) {
                                    Toast.error(serverError);
                                    return;
                                  }
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
                                    if (context.mounted) {
                                      Toast.error(_loginErrorMessage(e));
                                    }
                                  }
                                },
                          child: Center(child: Text(auth.loading ? '登录中...' : '登录')),
                        ),
                      ),
                      if (showLoginHistory) ...[
                        tokens.actionGap,
                        shadcn.IconButton.outline(
                          onPressed: auth.loading
                              ? null
                              : () => context.go('/login-history'),
                          icon: shadcn.Tooltip(
                            tooltip: (_) => const Text('登录历史'),
                            child: Icon(
                              shadcn.LucideIcons.history,
                              size: tokens.iconSize,
                            ),
                          ),
                        ),
                      ],
                      tokens.actionGap,
                      shadcn.IconButton.outline(
                        onPressed: () => LogOverlayManager.toggle(context),
                        icon: shadcn.Tooltip(
                          tooltip: (_) => const Text('日志中心'),
                          child: Icon(
                            shadcn.LucideIcons.terminal,
                            size: tokens.iconSize,
                          ),
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
      ),
    );
  }

  void _fillFromLoginHistory(List<LoginRecord> history) {
    if (_filledFromHistory || history.isEmpty) return;
    final latest = history.first;
    if (!kIsWeb && _canFillServer()) {
      _serverController.text = latest.server;
    }
    if (_canFillUsername()) {
      _usernameController.text = latest.username;
    }
    if (_canFillPassword()) {
      _passwordController.text = latest.password;
    }
    _filledFromHistory = true;
  }

  bool _canFillServer() {
    final value = _serverController.text.trim();
    return value.isEmpty || (kDebugMode && value == _debugServer);
  }

  bool _canFillUsername() {
    final value = _usernameController.text.trim();
    return value.isEmpty || (kDebugMode && value == _debugUsername);
  }

  bool _canFillPassword() {
    final value = _passwordController.text;
    return value.isEmpty || (kDebugMode && value == _debugPassword);
  }

  String _loginErrorMessage(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.cancel &&
          _isCredentialErrorMessage(error.error?.toString())) {
        return '账号或密码错误';
      }
      final status = error.response?.statusCode;
      final data = error.response?.data;
      final serverMessage = _extractLoginErrorMessage(data);
      if (_isCredentialErrorMessage(serverMessage)) return '账号或密码错误';
      if (serverMessage != null) return serverMessage;
      if (status == 400 || status == 401) return '账号或密码错误';
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return '服务器连接失败，请检查网络或服务器地址';
      }
    }
    return '登录失败，请检查账号信息';
  }

  bool _isCredentialErrorMessage(String? message) {
    final normalized = message?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return false;
    return normalized == 'token_expired' ||
        normalized.contains('token_expired') ||
        normalized.contains('no active account') ||
        normalized.contains('invalid credentials') ||
        normalized.contains('incorrect');
  }

  String? _extractLoginErrorMessage(dynamic data) {
    if (data is! Map) return null;
    for (final key in const ['msg', 'message', 'detail', 'error']) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String _webServerFromPageUrl() {
    final uri = Uri.base;
    if (uri.host.isEmpty) return uri.origin;
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  String? _validateServerAddress(String input) {
    final server = input.trim();
    if (server.length < 10) return '服务器地址长度不能少于 10 位';
    if (!(server.startsWith('http://') || server.startsWith('https://'))) {
      return '服务器地址必须以 http:// 或 https:// 开头';
    }
    return null;
  }
}

class _LoginThemeTokens {
  final shadcn.ThemeData theme;
  final double densityScale;
  final double textScale;

  _LoginThemeTokens._({required this.theme, required this.densityScale, required this.textScale});

  factory _LoginThemeTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityScale = ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(0.62, 1.45);
    final textScale = theme.scaling.clamp(0.86, 1.30);
    return _LoginThemeTokens._(
      theme: theme,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  double get formWidth => size(320);

  double get logoSize => size(136);

  double get iconSize => font(18);

  SizedBox get fieldGap => vGap(12);

  SizedBox get actionGap => hGap(10);

  EdgeInsets edgeSymmetric({num horizontal = 0, num vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: size(horizontal), vertical: size(vertical));

  SizedBox hGap(num value) => SizedBox(width: size(value));

  SizedBox vGap(num value) => SizedBox(height: size(value));
}
