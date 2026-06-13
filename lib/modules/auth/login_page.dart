import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/http_error.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/media/media.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/option/widgets/app_upgrade_page.dart';
import 'package:harvest/modules/shell/widgets/log_floating_overlay.dart';
import 'package:harvest/router/app_router.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../login/login_history_provider.dart';
import '../login/login_record.dart';
import '../login/login_storage.dart';
import 'auth_provider.dart';
import 'setup_prompt_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _appUpgradeController = AppUpgradeController();
  final _screenshotKey = GlobalKey();
  late final TextEditingController _serverController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _filledFromHistory = false;
  bool _setupDialogOpening = false;
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
        text:
            webServer ?? (savedServer.isNotEmpty ? savedServer : _debugServer),
      );
      _usernameController = TextEditingController(text: _debugUsername);
      _passwordController = TextEditingController(text: _debugPassword);
    } else {
      _serverController = TextEditingController(text: webServer ?? savedServer);
      _usernameController = TextEditingController();
      _passwordController = TextEditingController();
    }
    Future<void>.delayed(Duration.zero, () {
      ref.read(postLogoutRouteProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _takeScreenshot() async {
    try {
      final bytes = await ScreenshotSaver.capture(_screenshotKey);
      if (bytes == null) {
        Toast.error('截图失败');
        return;
      }
      await ScreenshotSaver.saveAndShare(bytes);
      Toast.success('截图已保存');
    } catch (e, st) {
      AppLogger.error('登录页截图失败', e, st);
      if (mounted) Toast.error('截图失败');
    }
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
    ref.listen(
      loginHistoryProvider,
      (prev, next) => _fillFromLoginHistory(next),
    );
    ref.listen<String?>(setupDialogBaseUrlProvider, (prev, next) {
      if (next == null || next.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openPendingSetupDialog(next);
      });
    });
    final pendingSetupBaseUrl = ref.watch(setupDialogBaseUrlProvider);
    if (pendingSetupBaseUrl != null && pendingSetupBaseUrl.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openPendingSetupDialog(pendingSetupBaseUrl);
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: ColoredBox(
        color: cs.background,
        child: Stack(
          children: [
            RepaintBoundary(
              key: _screenshotKey,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final verticalPadding = tokens.size(24);
                      final minHeight =
                          (constraints.maxHeight - verticalPadding * 2)
                              .clamp(0.0, double.infinity)
                              .toDouble();

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: tokens.edgeSymmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: minHeight),
                          child: Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: tokens.formWidth,
                              ),
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
                                    onSubmitted: (_) =>
                                        FocusScope.of(context).unfocus(),
                                  ),
                                  tokens.fieldGap,
                                  ShadTextField(
                                    controller: _usernameController,
                                    placeholder: const Text('账号'),
                                    onSubmitted: (_) =>
                                        FocusScope.of(context).unfocus(),
                                  ),
                                  tokens.fieldGap,
                                  ShadTextField(
                                    controller: _passwordController,
                                    placeholder: const Text('密码'),
                                    obscureText: true,
                                    maxLines: 1,
                                    features: const [
                                      shadcn.InputFeature.passwordToggle(),
                                    ],
                                    onSubmitted: (_) =>
                                        FocusScope.of(context).unfocus(),
                                  ),
                                  tokens.vGap(20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: shadcn.Button.primary(
                                          onPressed: auth.loading
                                              ? null
                                              : () async {
                                                  final serverError =
                                                      _validateServerAddress(
                                                        _serverController.text,
                                                      );
                                                  if (serverError != null) {
                                                    Toast.error(serverError);
                                                    return;
                                                  }
                                                  final baseUrl =
                                                      AppConfig.normalizeBaseUrl(
                                                        _serverController.text,
                                                      );
                                                  final setupStatus =
                                                      await _fetchSetupStatus(
                                                        baseUrl,
                                                      );
                                                  if (setupStatus?.needsSetup ==
                                                      true) {
                                                    await _showSetupDialog(
                                                      baseUrl,
                                                      setupStatus: setupStatus,
                                                    );
                                                    return;
                                                  }
                                                  try {
                                                    await ref
                                                        .read(
                                                          authNotifierProvider
                                                              .notifier,
                                                        )
                                                        .login(
                                                          baseUrl,
                                                          _usernameController
                                                              .text
                                                              .trim(),
                                                          _passwordController
                                                              .text,
                                                        );
                                                  } catch (e, trace) {
                                                    AppLogger.error(e);
                                                    AppLogger.error(trace);
                                                    if (_isSetupRequiredError(
                                                      e,
                                                    )) {
                                                      if (context.mounted) {
                                                        await _showSetupDialog(
                                                          baseUrl,
                                                        );
                                                      }
                                                      return;
                                                    }
                                                    if (context.mounted) {
                                                      Toast.error(
                                                        _loginErrorMessage(e),
                                                      );
                                                    }
                                                  }
                                                },
                                          child: Center(
                                            child: Text(
                                              auth.loading ? '登录中...' : '登录',
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (showLoginHistory) ...[
                                        tokens.actionGap,
                                        shadcn.IconButton.outline(
                                          onPressed: auth.loading
                                              ? null
                                              : () => context.go(
                                                  '/login-history',
                                                ),
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
                                        onPressed: () =>
                                            LogOverlayManager.toggle(context),
                                        icon: shadcn.Tooltip(
                                          tooltip: (_) => const Text('日志中心'),
                                          child: Icon(
                                            shadcn.LucideIcons.terminal,
                                            size: tokens.iconSize,
                                          ),
                                        ),
                                      ),
                                      tokens.actionGap,
                                      shadcn.IconButton.outline(
                                        onPressed: auth.loading
                                            ? null
                                            : _clearAllPersistentData,
                                        icon: shadcn.Tooltip(
                                          tooltip: (_) =>
                                              const Text('清理所有持久化数据'),
                                          child: Icon(
                                            shadcn.LucideIcons.databaseZap,
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
                      );
                    },
                  ),
                ),
              ),
            ),
            if (!kIsWeb) ...[
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: AppUpgradePage(
                    autoCheck: false,
                    controller: _appUpgradeController,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: appStandaloneHeaderPadding(
                    context,
                    left: 16,
                    top: MediaQuery.paddingOf(context).top + 12,
                    right: 16,
                    bottom: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      shadcn.IconButton.outline(
                        onPressed: _takeScreenshot,
                        icon: shadcn.Tooltip(
                          tooltip: (_) => const Text('截图分享'),
                          child: Icon(
                            shadcn.LucideIcons.camera,
                            size: tokens.iconSize,
                          ),
                        ),
                      ),
                      tokens.actionGap,
                      shadcn.IconButton.outline(
                        onPressed: () =>
                            unawaited(_appUpgradeController.openDialog()),
                        icon: shadcn.Tooltip(
                          tooltip: (_) => const Text('APP 升级'),
                          child: Icon(
                            shadcn.LucideIcons.circleArrowUp,
                            size: tokens.iconSize,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
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

  Future<_SetupStatus?> _fetchSetupStatus(String baseUrl) async {
    try {
      final res = await Dio().get<Map<String, dynamic>>(
        '$baseUrl${API.setupStatus}',
        options: Options(validateStatus: (_) => true),
      );
      final body = res.data;
      if (body == null) return null;
      if (body.containsKey('succeed') && body['succeed'] != true) return null;
      final data = body.containsKey('data') ? body['data'] : body;
      if (data is! Map) return null;
      return _SetupStatus.fromMap(data);
    } catch (e) {
      AppLogger.warn('获取初始化状态失败: $e');
      return null;
    }
  }

  Future<void> _showSetupDialog(
    String baseUrl, {
    _SetupStatus? setupStatus,
  }) async {
    if (!mounted) return;
    final status = setupStatus ?? await _fetchSetupStatus(baseUrl);
    if (!mounted) return;
    final credentials = await shadcn.showDialog<_SetupCredentials>(
      context: context,
      builder: (ctx) {
        final size = MediaQuery.sizeOf(ctx);
        return shadcn.AlertDialog(
          content: SizedBox(
            width: min(size.width - 32, 760),
            child: _SetupDialogContent(baseUrl: baseUrl, setupStatus: status),
          ),
        );
      },
    );
    if (!mounted || credentials == null) return;
    _usernameController.text = credentials.username;
    _passwordController.text = credentials.password;
    Toast.success('初始化完成，请登录');
  }

  Future<void> _openPendingSetupDialog(String baseUrl) async {
    if (_setupDialogOpening || !mounted) return;
    _setupDialogOpening = true;
    ref.read(setupDialogBaseUrlProvider.notifier).state = null;

    final normalizedBaseUrl = AppConfig.normalizeBaseUrl(baseUrl);
    _serverController.text = normalizedBaseUrl;
    try {
      await _showSetupDialog(normalizedBaseUrl);
    } finally {
      _setupDialogOpening = false;
    }
  }

  Future<void> _clearAllPersistentData() async {
    final confirmed = await shadcn.showDialog<bool>(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        title: const Text('清理所有持久化数据'),
        content: const Text('将清理登录态、登录历史、全局设置和所有本地空间数据。当前输入框内容也会清空。'),
        actions: [
          shadcn.Button.outline(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          shadcn.Button.destructive(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('清理'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await HiveManager.clear();
      await LoginStorage.clearAll();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      ref.invalidate(authNotifierProvider);
      ref.invalidate(loginHistoryProvider);
      ref.read(postLogoutRouteProvider.notifier).state = null;
      ref.read(setupDialogBaseUrlProvider.notifier).state = null;

      if (!kIsWeb) _serverController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _filledFromHistory = false;

      Toast.success('持久化数据已清理');
    } catch (e, st) {
      AppLogger.error('清理持久化数据失败', e, st);
      Toast.error('持久化数据清理失败');
    }
  }

  bool _isSetupRequiredError(Object error) {
    return isServerSetupRequiredError(error);
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

  _LoginThemeTokens._({
    required this.theme,
    required this.densityScale,
    required this.textScale,
  });

  factory _LoginThemeTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityScale =
        ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(
          0.62,
          1.45,
        );
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
      EdgeInsets.symmetric(
        horizontal: size(horizontal),
        vertical: size(vertical),
      );

  SizedBox hGap(num value) => SizedBox(width: size(value));

  SizedBox vGap(num value) => SizedBox(height: size(value));
}

class _SetupStatus {
  final bool initialized;
  final bool needsSetup;
  final Map<String, _DatabaseDefaults> databaseDefaults;

  const _SetupStatus({
    required this.initialized,
    required this.needsSetup,
    required this.databaseDefaults,
  });

  factory _SetupStatus.fromMap(Map<dynamic, dynamic> data) {
    final defaults = <String, _DatabaseDefaults>{};
    final rawDefaults = data['database_defaults'];
    if (rawDefaults is Map) {
      for (final entry in rawDefaults.entries) {
        final value = entry.value;
        if (value is Map) {
          defaults[entry.key.toString()] = _DatabaseDefaults.fromMap(value);
        }
      }
    }

    return _SetupStatus(
      initialized: data['initialized'] == true,
      needsSetup: data['needs_setup'] == true,
      databaseDefaults: defaults,
    );
  }
}

class _DatabaseDefaults {
  final String type;
  final String host;
  final String port;
  final String name;
  final String user;
  final String pass;
  final bool hasPassword;

  const _DatabaseDefaults({
    required this.type,
    required this.host,
    required this.port,
    required this.name,
    required this.user,
    required this.pass,
    required this.hasPassword,
  });

  factory _DatabaseDefaults.fromMap(Map<dynamic, dynamic> data) {
    String read(String key) => data[key]?.toString() ?? '';

    return _DatabaseDefaults(
      type: read('type'),
      host: read('host'),
      port: read('port'),
      name: read('name'),
      user: read('user'),
      pass: read('pass'),
      hasPassword: data['has_password'] == true,
    );
  }
}

class _SetupCredentials {
  final String username;
  final String password;

  const _SetupCredentials({required this.username, required this.password});
}

class _SetupDialogContent extends StatefulWidget {
  final String baseUrl;
  final _SetupStatus? setupStatus;

  const _SetupDialogContent({required this.baseUrl, this.setupStatus});

  @override
  State<_SetupDialogContent> createState() => _SetupDialogContentState();
}

class _SetupDialogContentState extends State<_SetupDialogContent> {
  final _stepperController = shadcn.StepperController();
  final _hostCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _adminUserCtrl = TextEditingController(text: 'admin');
  final _adminPassCtrl = TextEditingController(text: 'adminadmin');
  final _adminPassConfirmCtrl = TextEditingController(text: 'adminadmin');
  String _databaseType = 'pgsql';
  bool _debug = false;
  bool _submitting = false;
  bool _databaseReady = false;
  String? _error;

  int get _step => _stepperController.value.currentStep;

  @override
  void initState() {
    super.initState();
    _applyDefaultsForDatabaseType(_databaseType);
  }

  @override
  void dispose() {
    _stepperController.dispose();
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    _adminPassConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Go Harvest 初始化',
                          style: theme.typography.large.copyWith(
                            color: cs.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _stepSubtitle,
                          style: theme.typography.small.copyWith(
                            color: cs.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(context),
                ],
              ),
              const SizedBox(height: 18),
              _setupStepper(context),
              if (_error != null) ...[
                const SizedBox(height: 12),
                shadcn.Alert.destructive(
                  leading: const Icon(shadcn.LucideIcons.circleAlert),
                  content: Text(
                    _error!,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _actions(context),
            ],
          ),
        ),
      ),
    );
  }

  String get _stepSubtitle {
    return switch (_step) {
      0 => '选择要使用的数据库类型。',
      1 => '确认数据库信息，校验通过后自动同步数据库结构。',
      _ => '设置初始化管理员账号。',
    };
  }

  Widget _statusBadge(BuildContext context) {
    final label = Text(_submitting ? '处理中' : '第 ${_step + 1}/3 步');
    if (_submitting) {
      return shadcn.OutlineBadge(
        leading: const SizedBox(
          width: 12,
          height: 12,
          child: shadcn.CircularProgressIndicator(strokeWidth: 2),
        ),
        child: label,
      );
    }

    return shadcn.OutlineBadge(child: label);
  }

  Widget _setupStepper(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width >= 720;
    final stepper = shadcn.Stepper(
      controller: _stepperController,
      direction: horizontal ? Axis.horizontal : Axis.vertical,
      size: shadcn.StepSize.small,
      variant: shadcn.StepVariant.line,
      steps: [
        shadcn.Step(
          title: const Text('数据库类型'),
          contentBuilder: _databaseTypeStep,
        ),
        shadcn.Step(
          title: const Text('数据库同步'),
          contentBuilder: _databaseSyncStep,
        ),
        shadcn.Step(title: const Text('管理员账号'), contentBuilder: _adminStep),
      ],
    );

    if (!horizontal) return stepper;

    return SizedBox(height: 300, child: stepper);
  }

  Widget _databaseTypeStep(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 620;
    final choices = [
      _databaseTypeCard(
        context,
        type: 'pgsql',
        title: 'PostgreSQL',
        description: '使用接口返回的 PGSQL 配置',
        icon: shadcn.LucideIcons.server,
      ),
      _databaseTypeCard(
        context,
        type: 'sqlite',
        title: 'SQLite',
        description: '使用本地 sqlite 数据库文件',
        icon: shadcn.LucideIcons.fileText,
      ),
    ];

    return shadcn.RadioGroup<String>(
      value: _databaseType,
      enabled: !_submitting,
      onChanged: _selectDatabaseType,
      child: Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (compact)
              Column(
                children: [
                  for (var i = 0; i < choices.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    choices[i],
                  ],
                ],
              )
            else
              Row(
                children: [
                  for (var i = 0; i < choices.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: choices[i]),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _databaseTypeCard(
    BuildContext context, {
    required String type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final selected = _databaseType == type;

    return shadcn.RadioCard<String>(
      value: type,
      enabled: !_submitting,
      filled: false,
      child: SizedBox(
        height: 78,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? cs.primary.withValues(alpha: 0.10)
                    : cs.muted.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.32)
                      : cs.border.withValues(alpha: 0.70),
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? cs.primary : cs.mutedForeground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.small.copyWith(
                      color: cs.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.xSmall.copyWith(
                      color: cs.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: selected
                  ? Icon(
                      shadcn.LucideIcons.circleCheck,
                      key: const ValueKey('selected'),
                      size: 18,
                      color: cs.primary,
                    )
                  : SizedBox(
                      key: const ValueKey('empty'),
                      width: 18,
                      height: 18,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _databaseSyncStep(BuildContext context) {
    if (_databaseType == 'sqlite') {
      return _stepPanel(
        context,
        child: _fieldGrid(
          context,
          children: [
            _setupTextField(
              context,
              controller: _nameCtrl,
              label: _requiredLabel(context, '数据库文件（不可修改）'),
              enabled: false,
              readOnly: true,
            ),
            _debugSwitchField(context),
          ],
        ),
      );
    }

    return _stepPanel(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldGrid(
            context,
            maxColumns: 3,
            children: [
              _setupTextField(
                context,
                controller: _hostCtrl,
                label: _requiredLabel(context, '地址'),
                placeholder: const Text('go-harvest-postgres'),
                keyboardType: TextInputType.url,
                onChanged: (_) => _markDatabaseDirty(),
              ),
              _setupTextField(
                context,
                controller: _portCtrl,
                label: _requiredLabel(context, '端口'),
                placeholder: const Text('5432'),
                keyboardType: TextInputType.number,
                onChanged: (_) => _markDatabaseDirty(),
              ),
              _setupTextField(
                context,
                controller: _nameCtrl,
                label: _requiredLabel(context, '数据库名'),
                placeholder: const Text('goharvest'),
                onChanged: (_) => _markDatabaseDirty(),
              ),
              _setupTextField(
                context,
                controller: _userCtrl,
                label: _requiredLabel(context, '数据库用户'),
                placeholder: const Text('goharvest'),
                onChanged: (_) => _markDatabaseDirty(),
              ),
              _setupTextField(
                context,
                controller: _passCtrl,
                labelText: '数据库密码',
                obscureText: true,
                maxLines: 1,
                features: const [shadcn.InputFeature.passwordToggle()],
                onChanged: (_) => _markDatabaseDirty(),
              ),
              _debugSwitchField(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _setupTextField(
    BuildContext context, {
    TextEditingController? controller,
    Widget? label,
    String? labelText,
    Widget? placeholder,
    bool enabled = true,
    bool readOnly = false,
    bool obscureText = false,
    int? maxLines = 1,
    TextInputType? keyboardType,
    List<shadcn.InputFeature> features = const [],
    ValueChanged<String>? onChanged,
  }) {
    return ShadTextField(
      controller: controller,
      label: label,
      labelText: labelText,
      placeholder: placeholder,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      features: features,
      onChanged: onChanged,
      decoration: _formFieldDecoration(context, readOnly: readOnly || !enabled),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  BoxDecoration _formFieldDecoration(
    BuildContext context, {
    bool readOnly = false,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = readOnly
        ? cs.muted.withValues(alpha: dark ? 0.20 : 0.24)
        : Color.alphaBlend(
            cs.primary.withValues(alpha: dark ? 0.035 : 0.018),
            cs.background,
          );

    return BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: readOnly
            ? cs.border.withValues(alpha: 0.56)
            : cs.border.withValues(alpha: 0.82),
      ),
      boxShadow: readOnly
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.18 : 0.035),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
    );
  }

  Widget _debugSwitchField(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, '调试日志'),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: _formFieldDecoration(context),
          child: Row(
            children: [
              Icon(
                shadcn.LucideIcons.terminal,
                size: 16,
                color: cs.mutedForeground,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '开启',
                  style: theme.typography.small.copyWith(
                    color: cs.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              shadcn.Switch(
                value: _debug,
                enabled: !_submitting,
                onChanged: _submitting
                    ? null
                    : (value) => setState(() {
                        _debug = value;
                        _databaseReady = false;
                      }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adminStep(BuildContext context) {
    return _stepPanel(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _setupTextField(
            context,
            controller: _adminUserCtrl,
            label: _requiredLabel(context, '用户名'),
            placeholder: const Text('admin'),
          ),
          const SizedBox(height: 10),
          _fieldGrid(
            context,
            children: [
              _setupTextField(
                context,
                controller: _adminPassCtrl,
                label: _requiredLabel(context, '密码'),
                obscureText: true,
                maxLines: 1,
                features: const [shadcn.InputFeature.passwordToggle()],
              ),
              _setupTextField(
                context,
                controller: _adminPassConfirmCtrl,
                label: _requiredLabel(context, '确认密码'),
                obscureText: true,
                maxLines: 1,
                features: const [shadcn.InputFeature.passwordToggle()],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepPanel(BuildContext context, {required Widget child}) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: shadcn.Card(
        padding: const EdgeInsets.all(16),
        filled: true,
        fillColor: cs.muted.withValues(alpha: 0.08),
        borderColor: cs.border.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }

  Widget _fieldGrid(
    BuildContext context, {
    required List<Widget> children,
    int maxColumns = 2,
  }) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            children[i],
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = min(maxColumns, children.length);
        final width = (constraints.maxWidth - 16 * (columns - 1)) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Text(
      text,
      style: theme.typography.small.copyWith(
        color: cs.foreground,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _requiredLabel(BuildContext context, String text) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: theme.typography.small.copyWith(
            color: cs.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '*',
          style: theme.typography.small.copyWith(
            color: cs.destructive,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _actions(BuildContext context) {
    final primaryText = switch (_step) {
      0 => '下一步',
      1 =>
        _submitting
            ? '同步中...'
            : (_databaseType == 'sqlite' ? '同步数据库' : '校验并同步'),
      _ => _submitting ? '初始化中...' : '完成初始化',
    };

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        shadcn.Button.outline(
          onPressed: _submitting ? null : _handleSecondaryAction,
          alignment: Alignment.center,
          leading: Icon(
            _step == 0 ? shadcn.LucideIcons.x : shadcn.LucideIcons.arrowLeft,
            size: 16,
          ),
          child: Text(_step == 0 ? '取消' : '上一步'),
        ),
        shadcn.Button.primary(
          onPressed: _submitting ? null : _handlePrimaryAction,
          alignment: Alignment.center,
          leading: _submitting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: shadcn.CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _step == 2
                      ? shadcn.LucideIcons.check
                      : shadcn.LucideIcons.arrowRight,
                  size: 16,
                ),
          child: Text(primaryText),
        ),
      ],
    );
  }

  void _handlePrimaryAction() {
    if (_step == 0) {
      _goToStep(1);
      return;
    }

    if (_step == 1) {
      unawaited(_prepareDatabase());
      return;
    }

    unawaited(_submitAdmin());
  }

  void _handleSecondaryAction() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }

    _goToStep(_step - 1);
  }

  void _goToStep(int step) {
    final target = step.clamp(0, 2).toInt();
    _stepperController.jumpToStep(target);
    setState(() => _error = null);
  }

  void _selectDatabaseType(String value) {
    if (value == _databaseType) return;
    setState(() {
      _databaseType = value;
      _databaseReady = false;
      _error = null;
      _applyDefaultsForDatabaseType(value);
      _stepperController.setStatus(0, null);
      _stepperController.setStatus(1, null);
    });
  }

  void _applyDefaultsForDatabaseType(String type) {
    if (type == 'sqlite') {
      final defaults = widget.setupStatus?.databaseDefaults['sqlite'];
      _nameCtrl.text = _fallback(defaults?.name, 'db/data.sqlite3');
      return;
    }

    final defaults = widget.setupStatus?.databaseDefaults['pgsql'];
    _hostCtrl.text = _fallback(defaults?.host, 'go-harvest-postgres');
    _portCtrl.text = _fallback(defaults?.port, '5432');
    _nameCtrl.text = _fallback(defaults?.name, 'goharvest');
    _userCtrl.text = _fallback(defaults?.user, 'goharvest');
    _passCtrl.text = defaults?.pass ?? '';
  }

  String _fallback(String? value, String fallback) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
  }

  void _markDatabaseDirty() {
    if (!_databaseReady) return;
    setState(() => _databaseReady = false);
  }

  Future<void> _prepareDatabase() async {
    final validationError = _validateDatabase();
    if (validationError != null) {
      _stepperController.setStatus(_step, shadcn.StepState.failed);
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _postSetup(API.setupDatabase, _databasePayload());
      if (!mounted) return;
      _stepperController.setStatus(0, null);
      _stepperController.setStatus(1, null);
      _stepperController.jumpToStep(2);
      setState(() {
        _databaseReady = true;
      });
    } catch (e, st) {
      AppLogger.error('数据库初始化失败', e, st);
      if (mounted) {
        _stepperController.setStatus(_step, shadcn.StepState.failed);
        setState(() => _error = _extractSetupMessage(e) ?? '$e');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitAdmin() async {
    final adminUser = _adminUserCtrl.text.trim();
    final adminPass = _adminPassCtrl.text;
    final adminPassConfirm = _adminPassConfirmCtrl.text;
    final validationError = _validateAdmin(
      adminUser,
      adminPass,
      adminPassConfirm,
    );
    if (validationError != null) {
      _stepperController.setStatus(2, shadcn.StepState.failed);
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _postSetup(API.setupInit, {
        'admin_user': adminUser,
        'admin_pass': adminPass,
      });
      if (mounted) {
        Navigator.of(
          context,
        ).pop(_SetupCredentials(username: adminUser, password: adminPass));
      }
    } catch (e, st) {
      AppLogger.error('初始化失败', e, st);
      if (mounted) {
        _stepperController.setStatus(2, shadcn.StepState.failed);
        setState(() => _error = _extractSetupMessage(e) ?? '$e');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Map<String, dynamic> _databasePayload() {
    if (_databaseType == 'sqlite') {
      return <String, dynamic>{
        'database_type': 'sqlite',
        'debug': _debug,
        'name': _nameCtrl.text.trim(),
      };
    }

    return <String, dynamic>{
      'database_type': 'pgsql',
      'debug': _debug,
      'host': _hostCtrl.text.trim(),
      'port': _portCtrl.text.trim(),
      'name': _nameCtrl.text.trim(),
      'user': _userCtrl.text.trim(),
      'pass': _passCtrl.text,
    };
  }

  Future<void> _postSetup(String path, Map<String, dynamic> payload) async {
    final res = await Dio().post<dynamic>(
      '${widget.baseUrl}$path',
      data: payload,
      options: Options(validateStatus: (_) => true),
    );
    final statusCode = res.statusCode ?? 0;
    final body = res.data;
    if (statusCode >= 400) {
      throw StateError(_extractSetupMessage(body) ?? '请求失败 ($statusCode)');
    }
    if (body is Map && body.containsKey('succeed') && body['succeed'] != true) {
      throw StateError(_extractSetupMessage(body) ?? '初始化失败');
    }
  }

  String? _validateDatabase() {
    if (_databaseType == 'pgsql') {
      if (_hostCtrl.text.trim().isEmpty) return '数据库地址不能为空';
      if (_portCtrl.text.trim().isEmpty) return '数据库端口不能为空';
      final port = int.tryParse(_portCtrl.text.trim());
      if (port == null || port <= 0 || port > 65535) {
        return '数据库端口不正确';
      }
      if (_nameCtrl.text.trim().isEmpty) return '数据库名称不能为空';
      if (_userCtrl.text.trim().isEmpty) return '数据库用户名不能为空';
    } else if (_nameCtrl.text.trim().isEmpty) {
      return '数据库文件不能为空';
    }
    return null;
  }

  String? _validateAdmin(
    String adminUser,
    String adminPass,
    String adminPassConfirm,
  ) {
    if (!_databaseReady) return '请先完成数据库同步';
    if (adminUser.isEmpty) return '管理员用户名不能为空';
    if (adminPass.isEmpty) return '管理员密码不能为空';
    if (adminPass.length < 6) return '管理员密码至少需要 6 位';
    if (adminPass != adminPassConfirm) return '两次输入的密码不一致';
    return null;
  }

  String? _extractSetupMessage(dynamic value) {
    if (value is DioException) {
      return _extractSetupMessage(value.response?.data) ??
          value.error?.toString();
    }
    if (value is StateError) return value.message;
    if (value is Map) {
      for (final key in const ['msg', 'message', 'detail', 'error']) {
        final message = value[key]?.toString().trim();
        if (message != null && message.isNotEmpty) return message;
      }
      final data = value['data'];
      if (data is Map && !identical(data, value)) {
        return _extractSetupMessage(data);
      }
    }
    return null;
  }
}
