import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/browser_page.dart';
import 'package:harvest/widgets/debug_theme_button.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:install_plugin_v3/install_plugin_v3.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show IconExtension, TextExtension;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'option_form_card.dart';

const _appUpgradeLatestUrl = 'https://repeat.ptools.fun/api/app/version/latest';
const _appUpgradeVersionListUrl =
    'https://repeat.ptools.fun/api/app/version/list';
const _appUpgradeDownloadPageUrl = 'https://repeat.ptools.fun';
const _appUpgradeTestFlightUrl = 'https://testflight.apple.com/join/kwLil5xf';
const _appUpgradeIgnoreVersionKey = 'app_upgrade_ignore_version';
const _appUpgradeUseGithubProxyKey = 'app_upgrade_use_github_proxy';
const _appUpgradeGithubProxyKey = 'app_upgrade_github_proxy';
const _appUpgradeGithubProxyResultsKey = 'app_upgrade_github_proxy_results';

final appUpgradeStatusProvider = FutureProvider<AppUpgradeStatus>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = _formatAppVersion(packageInfo);
  if (kIsWeb) {
    return AppUpgradeStatus(
      currentVersion: currentVersion,
      latest: const AppUpdateInfo(
        version: '',
        changelog: '',
        downloadLinks: {},
      ),
      hasNewVersion: false,
      ignored: false,
    );
  }
  final response = await Dio().get<Map<String, dynamic>>(_appUpgradeLatestUrl);
  final latest = AppUpdateInfo.fromApiResponse(response.data);
  final ignored = isAppUpgradeVersionIgnored(latest.version);
  final macosArch = await _detectCurrentMacosArch();
  final hasCurrentPlatformAsset = _hasPreferredCurrentPlatformAsset(
    latest,
    macosArch: macosArch,
  );
  final hasNewVersion =
      latest.version.trim().isNotEmpty &&
      _compareVersions(latest.version, currentVersion) > 0 &&
      hasCurrentPlatformAsset;

  return AppUpgradeStatus(
    currentVersion: currentVersion,
    latest: latest,
    hasNewVersion: hasNewVersion,
    ignored: ignored,
  );
});

bool isAppUpgradeVersionIgnored(String version) {
  final ignoredVersion = HiveManager.get<String>(_appUpgradeIgnoreVersionKey);
  return ignoredVersion?.trim() == version.trim();
}

class AppUpgradeStatus {
  final String currentVersion;
  final AppUpdateInfo latest;
  final bool hasNewVersion;
  final bool ignored;

  const AppUpgradeStatus({
    required this.currentVersion,
    required this.latest,
    required this.hasNewVersion,
    required this.ignored,
  });

  bool get shouldPrompt => hasNewVersion && !ignored;
}

class AppUpgradeSummaryCard extends ConsumerWidget {
  const AppUpgradeSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) return const SizedBox.shrink();

    final status = ref.watch(appUpgradeStatusProvider);
    final data = status.value;
    final hasUpdate = data?.shouldPrompt == true;
    final summary = status.isLoading
        ? '正在检查 APP 版本'
        : kIsWeb
        ? 'Web 端不支持 APP 更新检测'
        : hasUpdate
        ? '发现 APP 新版本 v${data!.latest.version}'
        : data?.hasNewVersion == true && data?.ignored == true
        ? '已忽略 v${data!.latest.version}，点击查看'
        : data != null
        ? '当前已是最新版本'
        : '点击检查 APP 更新';

    return ExpandableCard(
      title: 'APP更新',
      leading: hasUpdate
          ? const Icon(shadcn.LucideIcons.circleAlert).iconSmall.iconPrimary
          : const Icon(
              shadcn.LucideIcons.circleArrowUp,
            ).iconSmall.iconMutedForeground,
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hasUpdate ? Text(summary).small.bold : Text(summary).small.muted,
          const SizedBox(height: 12),
          const AppUpgradeEmbeddedPanel(),
        ],
      ),
    );
  }
}

class AppUpgradeEmbeddedPanel extends StatelessWidget {
  const AppUpgradeEmbeddedPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return AppUpgradePage(autoCheck: false, embedded: true);
  }
}

class AppUpgradePage extends ConsumerStatefulWidget {
  final Widget? child;
  final bool autoCheck;
  final bool embedded;
  final FutureOr<void> Function()? onBeforeOpen;
  final AppUpgradeController? controller;

  const AppUpgradePage({
    super.key,
    this.child,
    this.autoCheck = true,
    this.embedded = false,
    this.onBeforeOpen,
    this.controller,
  });

  @override
  ConsumerState<AppUpgradePage> createState() => _AppUpgradePageState();
}

class AppUpgradeController {
  _AppUpgradePageState? _state;

  Future<void> openDialog() async {
    await _state?._handleOpenUpgradeDialog();
  }
}

class _AppUpgradePageState extends ConsumerState<AppUpgradePage> {
  final _dio = Dio();
  CancelToken? _cancelToken;
  StateSetter? _dialogSetState;
  ProviderSubscription<AsyncValue<AppUpgradeStatus>>? _statusSubscription;

  PackageInfo? _packageInfo;
  AppUpdateInfo? _latest;
  List<AppUpdateInfo> _versions = const [];
  String _macosArch = 'x86_64';
  bool _loadingLatest = false;
  bool _loadingVersions = false;
  bool _downloading = false;
  bool _useGithubProxy = false;
  bool _testingGithubProxy = false;
  bool _autoPromptOpen = false;
  int _dialogTabIndex = 0;
  double _progress = 0;
  String? _error;
  String? _activeDownloadPath;
  ResponseInfo? _githubProxy;
  List<ResponseInfo> _githubProxyResults = const [];

  String get _currentVersion {
    final info = _packageInfo;
    if (info == null) return '-';
    return _formatAppVersion(info);
  }

  Future<void> _handleOpenUpgradeDialog() async {
    if (kIsWeb) return;
    await widget.onBeforeOpen?.call();
    if (!mounted) return;
    await _openUpgradeDialog();
  }

  bool get _hasNewVersion {
    final latest = _latest?.version.trim();
    if (latest == null || latest.isEmpty || _packageInfo == null) return false;
    return _compareVersions(latest, _currentVersion) > 0 &&
        _hasPreferredCurrentPlatformAsset(_latest, macosArch: _macosArch);
  }

  bool get _ignoredLatest {
    final latest = _latest?.version.trim();
    if (latest == null || latest.isEmpty) return false;
    return isAppUpgradeVersionIgnored(latest);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    if (!kIsWeb) {
      _statusSubscription = ref.listenManual<AsyncValue<AppUpgradeStatus>>(
        appUpgradeStatusProvider,
        (_, next) => _applyAppUpgradeStatus(next),
        fireImmediately: true,
      );
    }
    _init();
  }

  @override
  void didUpdateWidget(covariant AppUpgradePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._state == this) {
        oldWidget.controller?._state = null;
      }
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    _statusSubscription?.close();
    if (widget.controller?._state == this) widget.controller?._state = null;
    if (_autoPromptOpen && _hasNewVersion && !_ignoredLatest) {
      final latest = _latest?.version.trim();
      if (latest != null && latest.isNotEmpty) {
        unawaited(HiveManager.set(_appUpgradeIgnoreVersionKey, latest));
      }
    }
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _macosArch = await _detectCurrentMacosArch();
      _useGithubProxy =
          HiveManager.get<bool>(_appUpgradeUseGithubProxyKey) ?? false;
      _githubProxy = _savedGithubProxy();
      _githubProxyResults = _savedGithubProxyResults();
      if (kIsWeb) {
        _error = 'Web 端不支持 APP 更新检测';
        return;
      }
      if (widget.autoCheck || widget.embedded) {
        unawaited(_runInitialVersionLoad());
      }
    } catch (e, st) {
      AppLogger.error('初始化 APP 升级模块失败', e, st);
    } finally {
      _refreshUi();
    }
  }

  void _refreshUi() {
    if (mounted) setState(() {});
    _dialogSetState?.call(() {});
  }

  void _applyAppUpgradeStatus(
    AsyncValue<AppUpgradeStatus> status, {
    bool refresh = true,
  }) {
    var changed = false;
    final data = status.value;
    if (data != null) {
      _latest = data.latest;
      _loadingLatest = false;
      _error = null;
      changed = true;
    } else if (status.isLoading && _latest == null) {
      _loadingLatest = true;
      _error = null;
      changed = true;
    } else if (status.hasError && _latest == null) {
      _loadingLatest = false;
      _error = '获取最新版本失败';
      changed = true;
    }
    if (changed && refresh) _refreshUi();
  }

  Future<void> _runInitialVersionLoad() async {
    await _loadLatestFromStartupProvider(silent: true);
    if (!mounted) return;
    if (widget.autoCheck && !widget.embedded && widget.child == null) {
      unawaited(_loadVersions());
    }
    if (widget.autoCheck && mounted && _hasNewVersion && !_ignoredLatest) {
      unawaited(_openUpgradeDialog(autoPrompt: true));
    }
  }

  Future<void> _loadLatestFromStartupProvider({bool silent = true}) async {
    if (kIsWeb) {
      _error = 'Web 端不支持 APP 更新检测';
      if (!silent) Toast.info(_error!);
      _refreshUi();
      return;
    }

    final current = ref.read(appUpgradeStatusProvider);
    _applyAppUpgradeStatus(current);
    if (current.value != null) return;

    _loadingLatest = true;
    _error = null;
    _refreshUi();
    try {
      final status = await ref.read(appUpgradeStatusProvider.future);
      if (!mounted) return;
      _latest = status.latest;
      _loadingLatest = false;
      _error = null;
      if (!silent) Toast.success('检查完成');
    } catch (e, st) {
      _loadingLatest = false;
      _error = '获取最新版本失败';
      AppLogger.error(_error!, e, st);
      if (!silent) Toast.error(_error!);
    } finally {
      _refreshUi();
    }
  }

  Future<void> _checkLatest({bool silent = false}) async {
    if (kIsWeb) {
      _error = 'Web 端不支持 APP 更新检测';
      if (!silent) Toast.info(_error!);
      _refreshUi();
      return;
    }
    _loadingLatest = true;
    _error = null;
    _refreshUi();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _appUpgradeLatestUrl,
      );
      _latest = AppUpdateInfo.fromApiResponse(response.data);
      AppLogger.debug(
        '[AppUpgrade] latest parsed: version=${_latest?.version}, '
        'links=${_latest?.downloadLinks.keys.toList()}',
      );
      ref.invalidate(appUpgradeStatusProvider);
      if (!silent) Toast.success('检查完成');
    } catch (e, st) {
      _error = '获取最新版本失败';
      AppLogger.error(_error!, e, st);
      if (!silent) Toast.error(_error!);
    } finally {
      _loadingLatest = false;
      _refreshUi();
    }
  }

  Future<void> _loadVersions() async {
    if (kIsWeb) {
      _versions = const [];
      _error = 'Web 端不支持 APP 更新检测';
      _refreshUi();
      return;
    }
    _loadingVersions = true;
    _error = null;
    _refreshUi();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _appUpgradeVersionListUrl,
      );
      _versions = AppUpdateInfo.listFromApiResponse(response.data);
      AppLogger.debug(
        '[AppUpgrade] version list parsed: count=${_versions.length}, '
        'versions=${_versions.map((item) => item.version).toList()}',
      );
    } catch (e, st) {
      _error = '获取版本列表失败';
      AppLogger.error(_error!, e, st);
      Toast.error(_error!);
    } finally {
      _loadingVersions = false;
      _refreshUi();
    }
  }

  Future<void> _openUpgradeDialog({bool autoPrompt = false}) async {
    if (!kIsWeb && _latest == null && !_loadingLatest) {
      unawaited(_loadLatestFromStartupProvider(silent: true));
    }
    if (!kIsWeb && _versions.isEmpty) unawaited(_loadVersions());
    if (!mounted) return;

    _dialogTabIndex = 0;
    if (autoPrompt) _autoPromptOpen = true;
    await shadcn.showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            _dialogSetState = setDialogState;
            final size = MediaQuery.sizeOf(context);
            final isCompactDialog = size.width < 568;
            final dialogInsetPadding = EdgeInsets.symmetric(
              horizontal: isCompactDialog ? 8 : 12,
              vertical: 24,
            );
            final cs = shadcn.Theme.of(context).colorScheme;
            final success = cs.chart2;
            final dialogWidth = isCompactDialog
                ? (size.width - dialogInsetPadding.horizontal)
                      .clamp(320.0, size.width)
                      .toDouble()
                : 520.0;
            final dialogHeight = isCompactDialog
                ? (size.height * 0.48).clamp(180.0, 360.0).toDouble()
                : (size.height - 230).clamp(180.0, 520.0).toDouble();
            return Padding(
              padding: dialogInsetPadding,
              child: shadcn.AlertDialog(
                title: SizedBox(
                  width: dialogWidth,
                  child: Row(
                    children: [
                      Icon(
                        _hasNewVersion
                            ? shadcn.LucideIcons.circleArrowUp
                            : shadcn.LucideIcons.badgeCheck,
                        size: 18,
                        color: _hasNewVersion ? cs.primary : success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_hasNewVersion ? '发现新版本' : 'APP 更新'),
                      ),
                    ],
                  ),
                ),
                content: SizedBox(
                  width: dialogWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: dialogHeight,
                        child: _buildDialogBody(context),
                      ),
                      const SizedBox(height: 10),
                      _UpgradeOptionRow(
                        ignored: _ignoredLatest,
                        ignoreEnabled: _latest != null,
                        onIgnoreChanged: _latest == null
                            ? null
                            : _setIgnoredLatest,
                        proxyEnabled: _useGithubProxy,
                        proxyTesting: _testingGithubProxy,
                        proxy: _githubProxy,
                        proxyResults: _githubProxyResults,
                        onProxyChanged: _setUseGithubProxy,
                        onProxySelected: _setGithubProxy,
                        onProxyTest: _useGithubProxy && !_testingGithubProxy
                            ? () => _resolveGithubProxy(force: true)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      if (_downloading) ...[
                        _DownloadProgress(progress: _progress),
                        const SizedBox(height: 10),
                      ],
                      _DialogActionBar(
                        loadingLatest: _loadingLatest,
                        downloading: _downloading,
                        progress: _progress,
                        hasNewVersion: _hasNewVersion,
                        onCheck: kIsWeb || _loadingLatest
                            ? null
                            : () => _checkLatest(),
                        onDownload:
                            kIsWeb ||
                                ((_latest == null && _versions.isEmpty) &&
                                    !_downloading)
                            ? null
                            : _downloading
                            ? _cancelDownload
                            : _downloadLatestOrReinstall,
                        onTestFlight: kIsWeb || !Platform.isIOS
                            ? null
                            : () => _openIosTestFlight(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    _dialogSetState = null;
    if (autoPrompt && mounted && _hasNewVersion && !_ignoredLatest) {
      await _setIgnoredLatest(true);
    }
    if (autoPrompt) _autoPromptOpen = false;
  }

  Widget _buildDialogBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = (constraints.maxHeight - 56)
            .clamp(120.0, constraints.maxHeight)
            .toDouble();
        return Column(
          children: [
            shadcn.Tabs(
              index: _dialogTabIndex,
              expand: true,
              onChanged: (index) {
                _dialogTabIndex = index;
                _refreshUi();
              },
              children: const [
                shadcn.TabItem(child: Text('最新版本')),
                shadcn.TabItem(child: Text('历史版本')),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: contentHeight,
              child: IndexedStack(
                index: _dialogTabIndex,
                children: [
                  _buildLatestTab(context),
                  _buildVersionsTab(context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLatestTab(BuildContext context) {
    return _DialogScroll(child: _buildLatestContent(context));
  }

  Widget _buildLatestContent(BuildContext context, {bool compact = false}) {
    final latest = _latest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VersionHeader(
          currentVersion: _currentVersion,
          latestVersion: latest?.version,
          hasNewVersion: _hasNewVersion,
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          _MessageBox(message: _error!, destructive: true),
        ],
        SizedBox(height: compact ? 8 : 12),
        _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('更新日志'),
              SizedBox(height: compact ? 5 : 8),
              if (_loadingLatest && latest == null)
                const OptionLoadingState(
                  label: '正在加载更新日志...',
                  compact: true,
                  padding: EdgeInsets.symmetric(vertical: 8),
                )
              else
                _ChangeLog(text: latest?.changelog, compact: compact),
            ],
          ),
        ),
        SizedBox(height: compact ? 8 : 14),
        _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('下载安装包'),
              SizedBox(height: compact ? 5 : 8),
              _DownloadLinks(
                info: latest,
                onDownload: _downloadEntry,
                onCopy: _copyDownloadUrl,
                showOtherPlatforms: false,
                onOpenPage: compact
                    ? null
                    : () => BrowserPage.open(
                        context,
                        url: _appUpgradeDownloadPageUrl,
                        title: 'APP 下载',
                      ),
                compact: compact,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionsTab(BuildContext context) {
    return _DialogScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionTitle('版本列表')),
              shadcn.Button.outline(
                onPressed: _loadingVersions ? null : _loadVersions,
                child: _loadingVersions
                    ? const OptionInlineProgress(label: '加载中')
                    : const Text('刷新'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loadingVersions && _versions.isEmpty)
            const OptionLoadingState(
              label: '正在加载版本列表...',
              compact: true,
              padding: EdgeInsets.symmetric(vertical: 8),
            )
          else if (_versions.isEmpty)
            const _MessageBox(message: '暂无版本记录')
          else
            ..._versions.map(
              (info) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _VersionCard(
                  info: info,
                  currentVersion: _currentVersion,
                  onDownload: _downloadEntry,
                  onCopy: _copyDownloadUrl,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _downloadPreferred(AppUpdateInfo? info) async {
    if (info == null) {
      Toast.warning('还没有获取到版本信息');
      return;
    }
    AppLogger.debug(
      '[AppUpgrade] download preferred requested: version=${info.version}, '
      'platform=${_platformDebugName()}, useGithubProxy=$_useGithubProxy, '
      'links=${info.downloadLinks}',
    );
    final entry = await _selectPreferredAsset(info);
    if (entry == null) {
      Toast.warning('没有找到适合当前平台的安装包');
      return;
    }
    await _downloadEntry(info, entry);
  }

  Future<void> _downloadLatestOrReinstall() async {
    final target = await _resolvePrimaryDownloadTarget();
    if (target == null) {
      Toast.warning('没有找到适合当前平台的安装包');
      return;
    }
    await _downloadPreferred(target);
  }

  Future<void> _downloadEntry(
    AppUpdateInfo info,
    MapEntry<String, String> entry,
  ) async {
    if (_downloading) return;
    _cancelToken = CancelToken();
    _downloading = true;
    _progress = 0;
    _activeDownloadPath = null;
    _refreshUi();

    final url = await _resolveEffectiveDownloadUrl(info, entry);
    final fileName = _resolveInstallerFileName(entry, url);
    AppLogger.debug(
      '[AppUpgrade] download entry: version=${info.version}, asset=${entry.key}, '
      'raw=${entry.value}, effective=$url, fileName=$fileName, '
      'platform=${_platformDebugName()}, useGithubProxy=$_useGithubProxy',
    );
    try {
      if (kIsWeb) {
        await _copyText(url);
        Toast.info('Web 端已复制下载链接');
        return;
      }

      if (PlatformTool.isDesktopOS()) {
        if (Platform.isMacOS || Platform.isWindows) {
          final dir = await getTemporaryDirectory();
          final packageDir = Directory(p.join(dir.path, 'harvest_app_upgrade'));
          await packageDir.create(recursive: true);
          final savePath = p.join(packageDir.path, fileName);
          AppLogger.debug(
            '[AppUpgrade] desktop installer download: asset=${entry.key}, '
            'platform=${_platformDebugName()}, savePath=$savePath',
          );
          _activeDownloadPath = savePath;
          await _downloadToPath(url, savePath, _cancelToken!);
          Toast.success('安装包已下载，正在启动安装器');
          await _tryOpenInstaller(savePath);
          return;
        }

        final savePath = await FilePicker.saveFile(
          dialogTitle: '保存安装包',
          fileName: fileName,
          type: FileType.any,
          bytes: Uint8List(0),
        );
        if (savePath == null) return;
        _activeDownloadPath = savePath;
        await _downloadToPath(url, savePath, _cancelToken!);
        Toast.success('安装包已保存');
        await _tryOpenInstaller(savePath);
      } else {
        final dir = await getTemporaryDirectory();
        final savePath = p.join(dir.path, fileName);
        _activeDownloadPath = savePath;
        await _downloadToPath(url, savePath, _cancelToken!);
        if (Platform.isAndroid) {
          Toast.success('安装包已下载，正在打开安装器');
          await _installAndroidApk(savePath);
        } else if (Platform.isIOS) {
          await SharePlus.instance.share(
            ShareParams(files: [XFile(savePath)], text: 'APP 安装包：$fileName'),
          );
        } else {
          Toast.info('安装包已下载到 $savePath');
        }
      }
    } on DioException catch (e, st) {
      if (CancelToken.isCancel(e)) {
        await _deleteActiveDownloadFile();
        Toast.info('已取消下载');
      } else {
        AppLogger.error('下载安装包失败', e, st);
        Toast.error('下载安装包失败');
      }
    } catch (e, st) {
      AppLogger.error('处理安装包失败', e, st);
      Toast.error('处理安装包失败');
    } finally {
      _downloading = false;
      _progress = 0;
      _cancelToken = null;
      _activeDownloadPath = null;
      _refreshUi();
    }
  }

  Future<void> _deleteActiveDownloadFile() async {
    final path = _activeDownloadPath;
    if (path == null || path.trim().isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
      AppLogger.debug('[AppUpgrade] cancelled download file removed: $path');
    } catch (e, st) {
      AppLogger.warn('清理已下载安装包失败: $e\n$st');
    }
  }

  Future<void> _installAndroidApk(String savePath) async {
    final result = await InstallPlugin.installApk(savePath);
    final success = result is Map && result['isSuccess'] == true;
    if (success) {
      Toast.success('安装完成');
      return;
    }

    final errorMessage = result is Map
        ? result['errorMessage']?.toString()
        : null;
    if (errorMessage?.trim().isNotEmpty == true) {
      Toast.error(errorMessage!.trim());
    } else {
      Toast.error('安装失败');
    }
  }

  Future<void> _openIosTestFlight([String? url]) async {
    final target = url?.trim().isNotEmpty == true
        ? url!.trim()
        : _appUpgradeTestFlightUrl;
    final uri = Uri.parse(target);
    AppLogger.debug('[AppUpgrade] ios open TestFlight url: url=$target');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened) {
      Toast.success('正在打开 TestFlight');
    } else {
      Toast.error('无法打开 TestFlight');
    }
  }

  Future<void> _downloadToPath(
    String url,
    String savePath,
    CancelToken token,
  ) async {
    await _dio.download(
      url,
      savePath,
      cancelToken: token,
      onReceiveProgress: (count, total) {
        if (total <= 0) return;
        _progress = (count / total).clamp(0, 1).toDouble();
        _refreshUi();
      },
    );
  }

  void _cancelDownload() {
    _cancelToken?.cancel('user cancelled');
  }

  Future<void> _tryOpenInstaller(String path) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isWindows) {
        await Process.start(path, const []);
      } else if (Platform.isLinux) {
        Toast.info('已保存到 $path');
      }
    } catch (e, st) {
      AppLogger.warn('打开安装包失败: $e\n$st');
      Toast.info('已保存到 $path');
    }
  }

  Future<void> _copyDownloadUrl(
    AppUpdateInfo info,
    MapEntry<String, String> entry,
  ) async {
    final url = await _resolveEffectiveDownloadUrl(info, entry);
    AppLogger.debug(
      '[AppUpgrade] copy download url: version=${info.version}, asset=${entry.key}, '
      'raw=${entry.value}, effective=$url, useGithubProxy=$_useGithubProxy',
    );
    await _copyText(url);
    Toast.success('下载链接已复制');
  }

  Future<void> _copyText(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }

  Future<AppUpdateInfo?> _resolvePrimaryDownloadTarget() async {
    if (_hasNewVersion && _latest != null) return _latest;

    AppUpdateInfo? current;
    for (final item in _versions) {
      if (_compareVersions(item.version, _currentVersion) == 0) {
        current = item;
        break;
      }
    }
    current ??=
        (_latest != null &&
            _compareVersions(_latest!.version, _currentVersion) == 0)
        ? _latest
        : null;
    if (current != null) return current;

    if (!_loadingVersions) {
      await _loadVersions();
      if (!mounted) return null;
      for (final item in _versions) {
        if (_compareVersions(item.version, _currentVersion) == 0) {
          return item;
        }
      }
    }
    return (_latest != null &&
            _compareVersions(_latest!.version, _currentVersion) == 0)
        ? _latest
        : null;
  }

  Future<MapEntry<String, String>?> _selectPreferredAsset(
    AppUpdateInfo info,
  ) async {
    if (info.downloadLinks.isEmpty) {
      AppLogger.debug('[AppUpgrade] select asset skipped: empty downloadLinks');
      return null;
    }
    final entries = info.downloadLinks.entries.toList();
    final patterns = _preferredAssetPatterns(macosArch: _macosArch);
    final targetArch = Platform.isMacOS ? _macosArch : null;

    AppLogger.debug(
      '[AppUpgrade] select asset candidates: platform=${_platformDebugName()}, '
      'arch=$targetArch, patterns=$patterns, '
      'entries=${entries.map((e) => '${e.key}=>${e.value}').toList()}',
    );

    for (final pattern in patterns) {
      for (final entry in entries) {
        if (_containsAssetPattern(entry, pattern)) {
          AppLogger.debug(
            '[AppUpgrade] select asset matched: pattern=$pattern, '
            'asset=${entry.key}, url=${entry.value}',
          );
          return entry;
        }
      }
    }
    AppLogger.debug(
      '[AppUpgrade] select asset fallback: asset=${entries.first.key}, url=${entries.first.value}',
    );
    return entries.first;
  }

  String _resolveDownloadUrl(
    AppUpdateInfo info,
    MapEntry<String, String> entry,
  ) {
    final raw = entry.value.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      AppLogger.debug(
        '[AppUpgrade] resolve raw url: asset=${entry.key}, url=$raw',
      );
      return raw;
    }
    final fallback =
        'https://github.com/ngfchl/harvest_flutter/releases/download/${info.version}/${entry.key}';
    AppLogger.debug(
      '[AppUpgrade] resolve github fallback url: asset=${entry.key}, url=$fallback',
    );
    return fallback;
  }

  Future<String> _resolveEffectiveDownloadUrl(
    AppUpdateInfo info,
    MapEntry<String, String> entry,
  ) async {
    final url = _resolveDownloadUrl(info, entry);
    if (!_useGithubProxy) {
      AppLogger.debug('[AppUpgrade] github proxy disabled: url=$url');
      return url;
    }
    if (!isGithubDownloadUrl(url)) {
      AppLogger.debug(
        '[AppUpgrade] url is not github, proxy skipped: url=$url',
      );
      return url;
    }

    final proxy = await _resolveGithubProxy();
    if (proxy == null) {
      AppLogger.debug(
        '[AppUpgrade] github proxy unavailable, fallback original: url=$url',
      );
      return url;
    }
    final proxied = buildGithubProxyUrl(proxy.url, url);
    AppLogger.debug(
      '[AppUpgrade] github proxy applied: proxy=${proxy.url}, time=${proxy.time}, '
      'original=$url, proxied=$proxied',
    );
    return proxied;
  }

  Future<void> _setUseGithubProxy(bool value) async {
    _useGithubProxy = value;
    await HiveManager.set(_appUpgradeUseGithubProxyKey, value);
    if (value) {
      _githubProxy ??= _savedGithubProxy();
      if (_githubProxyResults.isEmpty) {
        _githubProxyResults = _savedGithubProxyResults();
      }
    }
    _refreshUi();
  }

  Future<void> _setIgnoredLatest(bool value) async {
    final latest = _latest?.version.trim();
    if (latest == null || latest.isEmpty) return;
    if (value) {
      await HiveManager.set(_appUpgradeIgnoreVersionKey, latest);
    } else {
      await HiveManager.delete(_appUpgradeIgnoreVersionKey);
    }
    ref.invalidate(appUpgradeStatusProvider);
    _refreshUi();
  }

  Future<ResponseInfo?> _resolveGithubProxy({bool force = false}) async {
    if (!_useGithubProxy) return null;
    _githubProxy ??= _savedGithubProxy();
    if (_githubProxy != null && !force) {
      AppLogger.debug(
        '[AppUpgrade] reuse github proxy: proxy=${_githubProxy!.url}, time=${_githubProxy!.time}',
      );
      return _githubProxy;
    }
    if (!force) return null;
    if (_testingGithubProxy) {
      AppLogger.debug('[AppUpgrade] github proxy test already running');
      return _githubProxy;
    }

    _testingGithubProxy = true;
    _refreshUi();
    try {
      AppLogger.debug('[AppUpgrade] github proxy test start: force=$force');
      final result = await fetchFasterGithubProxy();
      final testedResults = _topGithubProxyResults(result.results);
      if (testedResults.isNotEmpty) {
        _githubProxyResults = testedResults;
        await HiveManager.set(
          _appUpgradeGithubProxyResultsKey,
          _githubProxyResults.map((entry) => entry.toJson()).toList(),
        );
      }
      if (result.success && result.data != null) {
        _githubProxy = result.data;
        await HiveManager.set(
          _appUpgradeGithubProxyKey,
          _githubProxy!.toJson(),
        );
        AppLogger.debug(
          '[AppUpgrade] github proxy selected: proxy=${_githubProxy!.url}, '
          'time=${_githubProxy!.time}, status=${_githubProxy!.status}, '
          'candidates=${_githubProxyResults.length}',
        );
        Toast.success('已选择最快加速地址 ${_githubProxy!.time}ms');
        return _githubProxy;
      }
      AppLogger.debug(
        '[AppUpgrade] github proxy test failed: msg=${result.msg}, '
        'results=${result.results.map((e) => e.toJson()).toList()}',
      );
      Toast.warning(result.msg);
      return null;
    } catch (e, st) {
      AppLogger.error('GitHub 加速测速失败', e, st);
      Toast.error('GitHub 加速测速失败');
      return null;
    } finally {
      _testingGithubProxy = false;
      _refreshUi();
    }
  }

  ResponseInfo? _savedGithubProxy() {
    final raw = HiveManager.get(_appUpgradeGithubProxyKey);
    if (raw is! Map) return null;
    final proxy = ResponseInfo.fromJson(Map<String, dynamic>.from(raw));
    return proxy.url.trim().isEmpty ? null : proxy;
  }

  List<ResponseInfo> _savedGithubProxyResults() {
    final raw = HiveManager.get(_appUpgradeGithubProxyResultsKey);
    if (raw is! List) return const [];
    return _topGithubProxyResults([
      for (final item in raw)
        if (item is Map) ResponseInfo.fromJson(Map<String, dynamic>.from(item)),
    ]);
  }

  Future<void> _setGithubProxy(ResponseInfo proxy) async {
    if (proxy.url.trim().isEmpty) return;
    _githubProxy = proxy;
    await HiveManager.set(_appUpgradeGithubProxyKey, proxy.toJson());
    _refreshUi();
    Toast.success('已切换加速地址 ${proxy.time}ms');
  }

  List<ResponseInfo> _topGithubProxyResults(List<ResponseInfo> results) {
    final byUrl = <String, ResponseInfo>{};
    for (final result in results) {
      if (result.url.trim().isEmpty) continue;
      final previous = byUrl[result.url];
      if (previous == null || result.time < previous.time) {
        byUrl[result.url] = result;
      }
    }
    final available = byUrl.values.where((entry) => entry.available).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return available.take(10).toList();
  }

  String _resolveInstallerFileName(
    MapEntry<String, String> entry,
    String effectiveUrl,
  ) {
    final candidates = <String?>[
      entry.key,
      _fileNameFromUrl(entry.value),
      _fileNameFromUrl(effectiveUrl),
    ];
    String? fallback;
    for (final candidate in candidates) {
      if (candidate == null || candidate.trim().isEmpty) continue;
      final safe = _safeFileName(candidate);
      fallback ??= safe;
      if (p.extension(safe).isNotEmpty) return safe;
    }
    return fallback ?? 'harvest_install_package';
  }

  String? _fileNameFromUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.pathSegments.isEmpty) return null;
    for (final segment in uri.pathSegments.reversed) {
      if (segment.trim().isEmpty) continue;
      return Uri.decodeComponent(segment);
    }
    return null;
  }

  String _safeFileName(String value) {
    final safe = value.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return safe.isEmpty ? 'harvest_install_package' : safe;
  }

  String _platformDebugName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    if (widget.embedded) return _buildEmbeddedPanel(context);

    final child = widget.child;
    if (child != null) {
      return shadcn.Clickable(
        behavior: HitTestBehavior.opaque,
        onPressed: _handleOpenUpgradeDialog,
        child: child,
      );
    }

    return _buildFullPage(context);
  }

  Widget _buildFullPage(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = shadcn.Theme.of(context).colorScheme;
    final pageBackground = appSurfaceColor(context, cs.background);
    return EscapeBackScope(
      onBack: () => Navigator.of(context).maybePop(),
      child: GlobalDrawerSwipeArea(
        child: AppBackground(
          child: shadcn.Scaffold(
            backgroundColor: pageBackground,
            headers: [
              shadcn.AppBar(
                height: kAppHeaderHeight - 12,
                padding: appHeaderPadding(context),
                backgroundColor: pageBackground,
                title: Text(
                  'APP 升级',
                  style: theme.typography.large.copyWith(
                    color: cs.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: [
                  shadcn.IconButton.ghost(
                    icon: const Icon(shadcn.LucideIcons.arrowLeft, size: 18),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
                trailing: [
                  shadcn.IconButton.ghost(
                    onPressed: kIsWeb || _loadingLatest
                        ? null
                        : () => _checkLatest(),
                    icon: _loadingLatest
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: shadcn.CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(shadcn.LucideIcons.refreshCw, size: 18),
                  ),
                  const DebugThemeButton.shadcn(),
                ],
              ),
            ],
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              children: [
                _buildLatestContent(context, compact: true),
                const SizedBox(height: 8),
                _UpgradeOptionRow(
                  ignored: _ignoredLatest,
                  ignoreEnabled: _latest != null,
                  onIgnoreChanged: _latest == null ? null : _setIgnoredLatest,
                  proxyEnabled: _useGithubProxy,
                  proxyTesting: _testingGithubProxy,
                  proxy: _githubProxy,
                  proxyResults: _githubProxyResults,
                  onProxyChanged: _setUseGithubProxy,
                  onProxySelected: _setGithubProxy,
                  onProxyTest: _useGithubProxy && !_testingGithubProxy
                      ? () => _resolveGithubProxy(force: true)
                      : null,
                ),
                const SizedBox(height: 8),
                if (_downloading) ...[
                  _DownloadProgress(progress: _progress),
                  const SizedBox(height: 8),
                ],
                _DialogActionBar(
                  loadingLatest: _loadingLatest,
                  downloading: _downloading,
                  progress: _progress,
                  hasNewVersion: _hasNewVersion,
                  onCheck: kIsWeb || _loadingLatest
                      ? null
                      : () => _checkLatest(),
                  onDownload:
                      kIsWeb ||
                          ((_latest == null && _versions.isEmpty) &&
                              !_downloading)
                      ? null
                      : _downloading
                      ? _cancelDownload
                      : _downloadLatestOrReinstall,
                  onTestFlight: kIsWeb || !Platform.isIOS
                      ? null
                      : () => _openIosTestFlight(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _SectionTitle('历史版本')),
                    shadcn.Button.outline(
                      onPressed: kIsWeb || _loadingVersions
                          ? null
                          : _loadVersions,
                      child: _loadingVersions
                          ? const OptionInlineProgress(label: '加载中')
                          : const Text('刷新'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (kIsWeb)
                  const _MessageBox(message: 'Web 端不支持 APP 更新检测')
                else if (_loadingVersions && _versions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: shadcn.CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_versions.isEmpty)
                  const _MessageBox(message: '暂无版本记录')
                else
                  for (final info in _versions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _VersionCard(
                        info: info,
                        currentVersion: _currentVersion,
                        onDownload: _downloadEntry,
                        onCopy: _copyDownloadUrl,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmbeddedPanel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLatestContent(context, compact: true),
        const SizedBox(height: 8),
        _UpgradeOptionRow(
          ignored: _ignoredLatest,
          ignoreEnabled: _latest != null,
          onIgnoreChanged: _latest == null ? null : _setIgnoredLatest,
          proxyEnabled: _useGithubProxy,
          proxyTesting: _testingGithubProxy,
          proxy: _githubProxy,
          proxyResults: _githubProxyResults,
          onProxyChanged: _setUseGithubProxy,
          onProxySelected: _setGithubProxy,
          onProxyTest: _useGithubProxy && !_testingGithubProxy
              ? () => _resolveGithubProxy(force: true)
              : null,
        ),
        const SizedBox(height: 8),
        if (_downloading) ...[
          _DownloadProgress(progress: _progress),
          const SizedBox(height: 8),
        ],
        _DialogActionBar(
          loadingLatest: _loadingLatest,
          downloading: _downloading,
          progress: _progress,
          hasNewVersion: _hasNewVersion,
          onCheck: kIsWeb || _loadingLatest ? null : () => _checkLatest(),
          onDownload:
              kIsWeb ||
                  ((_latest == null && _versions.isEmpty) && !_downloading)
              ? null
              : _downloading
              ? _cancelDownload
              : _downloadLatestOrReinstall,
          onTestFlight: kIsWeb || !Platform.isIOS
              ? null
              : () => _openIosTestFlight(),
        ),
      ],
    );
  }
}

class AppUpdateInfo {
  final String version;
  final String changelog;
  final Map<String, String> downloadLinks;

  const AppUpdateInfo({
    required this.version,
    required this.changelog,
    required this.downloadLinks,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    final linksValue =
        json['downloadLinks'] ??
        json['download_links'] ??
        json['downloads'] ??
        json['assets'];
    final links = <String, String>{};
    if (linksValue is Map) {
      for (final entry in linksValue.entries) {
        links[entry.key.toString()] = entry.value?.toString() ?? '';
      }
    } else if (linksValue is List) {
      for (final item in linksValue) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final name =
            (map['name'] ?? map['file'] ?? map['filename'] ?? map['label'])
                ?.toString();
        final url =
            (map['url'] ??
                    map['download_url'] ??
                    map['downloadUrl'] ??
                    map['link'])
                ?.toString();
        if (name != null && name.isNotEmpty) links[name] = url ?? '';
      }
    }

    return AppUpdateInfo(
      version: (json['version'] ?? json['tag'] ?? json['name'] ?? '')
          .toString(),
      changelog:
          (json['changelog'] ??
                  json['changeLog'] ??
                  json['notes'] ??
                  json['body'] ??
                  '')
              .toString(),
      downloadLinks: links,
    );
  }

  factory AppUpdateInfo.fromApiResponse(Map<String, dynamic>? response) {
    final data = _unwrapData(response);
    if (data is Map) {
      return AppUpdateInfo.fromJson(Map<String, dynamic>.from(data));
    }
    return const AppUpdateInfo(version: '', changelog: '', downloadLinks: {});
  }

  static List<AppUpdateInfo> listFromApiResponse(
    Map<String, dynamic>? response,
  ) {
    final data = _unwrapData(response);
    if (data is List) {
      return [
        for (final item in data)
          if (item is Map)
            AppUpdateInfo.fromJson(Map<String, dynamic>.from(item)),
      ];
    }
    return const [];
  }

  static dynamic _unwrapData(Map<String, dynamic>? response) {
    if (response == null) return null;
    if (response.containsKey('data')) return response['data'];
    return response;
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'changelog': changelog,
      'download_links': downloadLinks,
    };
  }
}

class _DialogScroll extends StatelessWidget {
  final Widget child;

  const _DialogScroll({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(2, 8, 8, 4),
      child: child,
    );
  }
}

class _VersionHeader extends StatelessWidget {
  final String currentVersion;
  final String? latestVersion;
  final bool hasNewVersion;

  const _VersionHeader({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasNewVersion,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final accent = hasNewVersion ? cs.primary : cs.chart2;
    return SizedBox(
      width: double.infinity,
      child: shadcn.Card(
        padding: const EdgeInsets.all(10),
        filled: true,
        fillColor: accent.withValues(alpha: 0.08),
        borderColor: accent.withValues(alpha: hasNewVersion ? 0.24 : 0.22),
        child: Row(
          children: [
            Icon(
              hasNewVersion
                  ? shadcn.LucideIcons.circleArrowUp
                  : shadcn.LucideIcons.badgeCheck,
              color: accent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hasNewVersion ? '发现可用新版本' : '已是最新版本').small.bold,
                  const SizedBox(height: 5),
                  _InfoLine(label: '当前', value: 'v$currentVersion'),
                  if (hasNewVersion) ...[
                    const SizedBox(height: 2),
                    _InfoLine(
                      label: '最新',
                      value: latestVersion?.isNotEmpty == true
                          ? 'v$latestVersion'
                          : '-',
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    const _InfoLine(label: '状态', value: '无需更新'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final Widget child;

  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppSurfaceCard(padding: const EdgeInsets.all(10), child: child),
    );
  }
}

class _UpgradeOptionRow extends StatelessWidget {
  final bool ignored;
  final bool ignoreEnabled;
  final ValueChanged<bool>? onIgnoreChanged;
  final bool proxyEnabled;
  final bool proxyTesting;
  final ResponseInfo? proxy;
  final List<ResponseInfo> proxyResults;
  final ValueChanged<bool> onProxyChanged;
  final ValueChanged<ResponseInfo> onProxySelected;
  final VoidCallback? onProxyTest;

  const _UpgradeOptionRow({
    required this.ignored,
    required this.ignoreEnabled,
    required this.onIgnoreChanged,
    required this.proxyEnabled,
    required this.proxyTesting,
    required this.proxy,
    required this.proxyResults,
    required this.onProxyChanged,
    required this.onProxySelected,
    required this.onProxyTest,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 568;
    final proxySubtitle = proxyTesting
        ? '正在测速 GitHub 加速地址'
        : proxyEnabled && proxy != null
        ? '${proxy!.url} · ${proxy!.time}ms'
        : proxyEnabled
        ? '点击测速选择加速地址'
        : '原始下载地址';

    final ignoreOption = _SwitchOptionCard(
      icon: shadcn.LucideIcons.bellOff,
      title: '不再提醒',
      subtitle: ignored ? '已忽略当前版本' : '打开后忽略当前版本',
      tooltip: ignored ? '当前版本已被忽略，关闭后恢复更新提醒' : '打开后将忽略当前版本，不再自动弹出更新提醒',
      value: ignored,
      enabled: ignoreEnabled,
      onChanged: onIgnoreChanged,
    );
    final proxyOption = _SwitchOptionCard(
      icon: shadcn.LucideIcons.gauge,
      title: 'GitHub 加速',
      subtitle: proxySubtitle,
      tooltip: proxyEnabled
          ? '下载 GitHub Release 资源时使用已选择的加速地址，可手动测速更新候选列表'
          : '关闭后直接使用原始下载地址',
      value: proxyEnabled,
      enabled: !proxyTesting,
      onChanged: onProxyChanged,
      trailing: proxyEnabled
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GithubProxyDropdownButton(
                  enabled: !proxyTesting,
                  selected: proxy,
                  results: proxyResults,
                  onSelected: onProxySelected,
                ),
                const SizedBox(width: 2),
                shadcn.IconButton.ghost(
                  size: shadcn.ButtonSize.small,
                  density: shadcn.ButtonDensity.iconDense,
                  onPressed: onProxyTest,
                  icon: proxyTesting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: shadcn.CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(shadcn.LucideIcons.refreshCw, size: 14),
                ),
              ],
            )
          : null,
    );

    return compact
        ? Column(
            children: [ignoreOption, const SizedBox(height: 8), proxyOption],
          )
        : Row(
            children: [
              Expanded(child: ignoreOption),
              const SizedBox(width: 8),
              Expanded(child: proxyOption),
            ],
          );
  }
}

class _GithubProxyDropdownButton extends StatelessWidget {
  final bool enabled;
  final ResponseInfo? selected;
  final List<ResponseInfo> results;
  final ValueChanged<ResponseInfo> onSelected;

  const _GithubProxyDropdownButton({
    required this.enabled,
    required this.selected,
    required this.results,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buttonContext) => shadcn.IconButton.ghost(
        size: shadcn.ButtonSize.small,
        density: shadcn.ButtonDensity.iconDense,
        onPressed: enabled ? () => _showMenu(buttonContext) : null,
        icon: const Icon(shadcn.LucideIcons.chevronDown, size: 14),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final entries = _menuEntries();
    final fastest = results.isEmpty || entries.isEmpty ? null : entries.first;

    shadcn.showDropdown<void>(
      context: context,
      alignment: Alignment.topRight,
      offset: const Offset(0, 8),
      widthConstraint: shadcn.PopoverConstraint.intrinsic,
      heightConstraint: shadcn.PopoverConstraint.intrinsic,
      consumeOutsideTaps: false,
      builder: (_) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: shadcn.DropdownMenu(
          children: [
            shadcn.MenuLabel(child: const Text('GitHub 加速地址')),
            const shadcn.MenuDivider(),
            if (entries.isEmpty)
              shadcn.MenuLabel(child: const Text('点击测速生成候选地址'))
            else
              for (final entry in entries)
                shadcn.MenuButton(
                  leading: Icon(_leadingIcon(entry, fastest), size: 15),
                  onPressed: (overlayContext) async {
                    await shadcn.closeOverlay(overlayContext);
                    onSelected(entry);
                  },
                  child: _GithubProxyMenuItem(
                    proxy: entry,
                    selected: selected?.url == entry.url,
                    fastest: fastest?.url == entry.url,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  IconData _leadingIcon(ResponseInfo entry, ResponseInfo? fastest) {
    if (selected?.url == entry.url) return shadcn.LucideIcons.check;
    if (fastest?.url == entry.url) return shadcn.LucideIcons.zap;
    return shadcn.LucideIcons.globe;
  }

  List<ResponseInfo> _menuEntries() {
    if (results.isEmpty) {
      final current = selected;
      if (current == null || current.url.trim().isEmpty) return const [];
      return [current];
    }
    final entries =
        results.where((entry) => entry.url.trim().isNotEmpty).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
    return entries.take(10).toList();
  }
}

class _GithubProxyMenuItem extends StatelessWidget {
  final ResponseInfo proxy;
  final bool selected;
  final bool fastest;

  const _GithubProxyMenuItem({
    required this.proxy,
    required this.selected,
    required this.fastest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final latencyColor = fastest ? cs.primary : cs.foreground;
    final latencyBorderColor = fastest
        ? cs.primary.withValues(alpha: 0.34)
        : cs.border.withValues(alpha: 0.58);
    final latencyFillColor = fastest
        ? cs.primary.withValues(alpha: 0.1)
        : cs.muted.withValues(alpha: 0.32);

    return SizedBox(
      width: 292,
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 58),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: latencyFillColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: latencyBorderColor, width: 0.5),
            ),
            child: Text(
              '${proxy.time}ms',
              maxLines: 1,
              style: theme.typography.xSmall.copyWith(
                color: latencyColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              proxy.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.small.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (fastest)
            Text(
              '最快',
              style: theme.typography.xSmall.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _SwitchOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tooltip;
  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;
  final Widget? trailing;

  const _SwitchOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tooltip,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final effectiveEnabled = enabled && onChanged != null;
    final accent = effectiveEnabled ? cs.primary : cs.mutedForeground;
    final tooltipText = subtitle.trim().isEmpty
        ? tooltip
        : '$subtitle\n$tooltip';

    return shadcn.Tooltip(
      tooltip: (_) => Text(
        tooltipText,
        style: theme.typography.xSmall.copyWith(
          color: cs.popoverForeground,
          height: 1.35,
        ),
      ),
      child: shadcn.Card(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: value
            ? cs.primary.withValues(alpha: 0.08)
            : cs.muted.withValues(alpha: 0.14),
        borderColor: value
            ? cs.primary.withValues(alpha: 0.24)
            : cs.border.withValues(alpha: 0.48),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            shadcn.Card(
              padding: const EdgeInsets.all(7),
              filled: true,
              fillColor: value
                  ? cs.primary.withValues(alpha: 0.12)
                  : appSurfaceColor(context, cs.background),
              borderColor: value
                  ? cs.primary.withValues(alpha: 0.18)
                  : cs.border.withValues(alpha: 0.36),
              child: Icon(icon, size: 16, color: accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.small.copyWith(
                            color: cs.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        shadcn.LucideIcons.info,
                        size: 13,
                        color: cs.mutedForeground,
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        style: theme.typography.xSmall.copyWith(
                          color: cs.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            const SizedBox(width: 8),
            shadcn.Switch(
              value: value,
              enabled: effectiveEnabled,
              onChanged: effectiveEnabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final AppUpdateInfo info;
  final String currentVersion;
  final Future<void> Function(AppUpdateInfo, MapEntry<String, String>)
  onDownload;
  final Future<void> Function(AppUpdateInfo, MapEntry<String, String>) onCopy;

  const _VersionCard({
    required this.info,
    required this.currentVersion,
    required this.onDownload,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final current = _compareVersions(info.version, currentVersion) == 0;
    return AppSurfaceCard(
      padding: const EdgeInsets.all(10),
      borderColor: current ? cs.primary.withValues(alpha: 0.5) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: current
                    ? Text('v${info.version}').small.bold(color: cs.primary)
                    : Text('v${info.version}').small.bold,
              ),
              if (current) shadcn.PrimaryBadge(child: const Text('当前版本')),
            ],
          ),
          const SizedBox(height: 8),
          _ChangeLog(text: info.changelog, compact: true),
          if (info.downloadLinks.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DownloadLinks(info: info, onDownload: onDownload, onCopy: onCopy),
          ],
        ],
      ),
    );
  }
}

class _DownloadLinks extends StatefulWidget {
  final AppUpdateInfo? info;
  final Future<void> Function(AppUpdateInfo, MapEntry<String, String>)
  onDownload;
  final Future<void> Function(AppUpdateInfo, MapEntry<String, String>) onCopy;
  final VoidCallback? onOpenPage;
  final bool compact;
  final bool showOtherPlatforms;

  const _DownloadLinks({
    required this.info,
    required this.onDownload,
    required this.onCopy,
    this.onOpenPage,
    this.compact = false,
    this.showOtherPlatforms = true,
  });

  @override
  State<_DownloadLinks> createState() => _DownloadLinksState();
}

class _DownloadLinksState extends State<_DownloadLinks> {
  bool _showOtherPlatforms = false;
  String _macosArch = 'x86_64';

  @override
  void initState() {
    super.initState();
    _loadCurrentPlatformArch();
  }

  Future<void> _loadCurrentPlatformArch() async {
    if (kIsWeb || !Platform.isMacOS) return;
    try {
      final arch = await _detectCurrentMacosArch();
      if (mounted) setState(() => _macosArch = arch);
    } catch (e, st) {
      AppLogger.warn('解析 macOS 安装包列表架构失败: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.info;
    final entries =
        current?.downloadLinks.entries.toList() ??
        const <MapEntry<String, String>>[];
    final platformEntries = entries
        .where((entry) => _isCurrentPlatformAsset(entry, macosArch: _macosArch))
        .toList();
    final otherEntries = entries
        .where(
          (entry) => !_isCurrentPlatformAsset(entry, macosArch: _macosArch),
        )
        .toList();
    final primaryEntries = platformEntries.isNotEmpty
        ? platformEntries
        : entries.take(1).toList();
    final visibleEntries = primaryEntries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onOpenPage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ColoredActionButton(
              icon: shadcn.LucideIcons.externalLink,
              label: '打开下载页',
              color: shadcn.Theme.of(context).colorScheme.primary,
              onPressed: widget.onOpenPage!,
            ),
          ),
        if (current == null || entries.isEmpty)
          const _MessageBox(message: '暂无安装包下载链接')
        else ...[
          for (final entry in visibleEntries)
            _downloadEntryTile(context, current, entry),
          if (widget.showOtherPlatforms &&
              !widget.compact &&
              otherEntries.isNotEmpty) ...[
            const SizedBox(height: 2),
            _OtherPlatformsToggle(
              count: otherEntries.length,
              expanded: _showOtherPlatforms,
              onTap: () =>
                  setState(() => _showOtherPlatforms = !_showOtherPlatforms),
            ),
            if (_showOtherPlatforms)
              for (final entry in otherEntries)
                _downloadEntryTile(context, current, entry),
          ],
        ],
      ],
    );
  }

  Widget _downloadEntryTile(
    BuildContext context,
    AppUpdateInfo current,
    MapEntry<String, String> entry,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final label = _buildDownloadLabel(entry, macosArch: _macosArch);
    return Padding(
      padding: EdgeInsets.only(bottom: widget.compact ? 6 : 8),
      child: shadcn.Card(
        padding: EdgeInsets.symmetric(
          horizontal: 9,
          vertical: widget.compact ? 6 : 8,
        ),
        filled: true,
        fillColor: cs.muted.withValues(alpha: 0.16),
        child: Row(
          children: [
            const Icon(shadcn.LucideIcons.package).iconSmall.iconPrimary,
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).small.bold,
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(label.subtitle).xSmall.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            _MiniActionButton(
              icon: shadcn.LucideIcons.copy,
              tip: '复制链接',
              onPress: () => widget.onCopy(current, entry),
            ),
            const SizedBox(width: 4),
            _MiniActionButton(
              icon: shadcn.LucideIcons.download,
              tip: '下载',
              onPress: () => widget.onDownload(current, entry),
              outlined: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherPlatformsToggle extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  const _OtherPlatformsToggle({
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return shadcn.Clickable(
      behavior: HitTestBehavior.opaque,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
        child: Row(
          children: [
            Expanded(child: Text('其他平台安装包 $count 个').small.semiBold.muted),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                shadcn.LucideIcons.chevronDown,
                size: 15,
                color: cs.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeLog extends StatelessWidget {
  final String? text;
  final bool compact;

  const _ChangeLog({this.text, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final data = (text ?? '').trim();
    if (data.isEmpty) return const _MessageBox(message: '暂无更新日志');

    return SelectionArea(
      child: MarkdownBody(
        data: data,
        selectable: false,
        fitContent: false,
        softLineBreak: true,
        styleSheet: _changeLogMarkdownStyleSheet(context, compact: compact),
        onTapLink: (label, href, title) {
          final url = href?.trim();
          if (url == null || url.isEmpty) return;
          BrowserPage.open(
            context,
            url: url,
            title: label.trim().isEmpty ? null : label.trim(),
          );
        },
      ),
    );
  }
}

MarkdownStyleSheet _changeLogMarkdownStyleSheet(
  BuildContext context, {
  required bool compact,
}) {
  final theme = shadcn.Theme.of(context);
  final cs = theme.colorScheme;
  final typography = theme.typography;
  final body = (compact ? typography.xSmall : typography.small)
      .merge(typography.sans)
      .copyWith(height: 1.45, color: cs.foreground);
  final code = (compact ? typography.xSmall : typography.small)
      .merge(typography.mono)
      .copyWith(
        height: 1.35,
        color: cs.foreground,
        backgroundColor: cs.muted.withValues(alpha: 0.65),
      );
  final h1 = (compact ? typography.large : typography.xLarge)
      .merge(typography.black)
      .copyWith(height: 1.25, color: cs.foreground);
  final h2 = (compact ? typography.small : typography.large)
      .merge(typography.black)
      .copyWith(height: 1.25, color: cs.foreground);
  final h3 = (compact ? typography.xSmall : typography.small)
      .merge(typography.black)
      .copyWith(height: 1.25, color: cs.foreground);

  return MarkdownStyleSheet(
    a: body.merge(typography.bold).copyWith(color: cs.primary),
    p: body,
    pPadding: EdgeInsets.only(bottom: compact ? 6 : 8),
    h1: h1,
    h1Padding: EdgeInsets.only(bottom: compact ? 8 : 10),
    h2: h2,
    h2Padding: EdgeInsets.only(bottom: compact ? 6 : 8),
    h3: h3,
    h3Padding: EdgeInsets.only(bottom: compact ? 6 : 8),
    listBullet: body.copyWith(color: cs.mutedForeground),
    blockquote: body.copyWith(color: cs.mutedForeground),
    blockquoteDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.5),
      borderRadius: theme.borderRadiusSm,
      border: Border(left: BorderSide(color: cs.border, width: 3)),
    ),
    code: code,
    codeblockDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.65),
      borderRadius: theme.borderRadiusSm,
    ),
  );
}

class _DownloadProgress extends StatelessWidget {
  final double progress;

  const _DownloadProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).clamp(0, 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('下载进度 $pct%').small.bold.muted,
        const SizedBox(height: 6),
        shadcn.LinearProgressIndicator(value: progress <= 0 ? null : progress),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 38, child: Text(label).xSmall.muted),
        Expanded(child: Text(value).xSmall.bold),
      ],
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;
  final bool destructive;

  const _MessageBox({required this.message, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: destructive
          ? shadcn.Alert.destructive(content: Text(message).small)
          : shadcn.Alert(content: Text(message).small.muted),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text).small.bold;
  }
}

class _DialogActionBar extends StatelessWidget {
  final bool loadingLatest;
  final bool downloading;
  final double progress;
  final bool hasNewVersion;
  final VoidCallback? onCheck;
  final VoidCallback? onDownload;
  final VoidCallback? onTestFlight;

  const _DialogActionBar({
    required this.loadingLatest,
    required this.downloading,
    required this.progress,
    required this.hasNewVersion,
    required this.onCheck,
    required this.onDownload,
    this.onTestFlight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: shadcn.Button.outline(
            onPressed: onCheck,
            alignment: Alignment.center,
            child: loadingLatest
                ? const OptionInlineProgress(label: '检查')
                : const Text('检查'),
          ),
        ),
        if (onTestFlight != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: shadcn.Button.outline(
              onPressed: onTestFlight,
              alignment: Alignment.center,
              child: const Text('TF跳转'),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Expanded(
          child: shadcn.Button.primary(
            onPressed: onDownload,
            alignment: Alignment.center,
            child: downloading
                ? _DownloadButtonLabel(progress: progress, label: '取消')
                : Text(hasNewVersion ? '更新' : '重装'),
          ),
        ),
      ],
    );
  }
}

class _DownloadButtonLabel extends StatelessWidget {
  final double progress;
  final String label;

  const _DownloadButtonLabel({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).clamp(0, 100).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: shadcn.CircularProgressIndicator(
            strokeWidth: 2,
            value: progress <= 0 ? null : progress,
          ),
        ),
        const SizedBox(width: 6),
        Text('$pct% $label'),
      ],
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String tip;
  final VoidCallback onPress;
  final bool outlined;

  const _MiniActionButton({
    required this.icon,
    required this.tip,
    required this.onPress,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = outlined ? const Color(0xFF16A34A) : const Color(0xFF0891B2);
    return shadcn.Tooltip(
      tooltip: (_) => Text(tip),
      child: SizedBox(
        width: 30,
        height: 38,
        child: _ColoredIconActionButton(
          icon: icon,
          color: color,
          onPressed: onPress,
          subtle: !outlined,
        ),
      ),
    );
  }
}

class _ColoredActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ColoredActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return shadcn.Clickable(
      behavior: HitTestBehavior.opaque,
      onPressed: onPressed,
      child: AppSurfaceContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.10),
        borderColor: color.withValues(alpha: 0.42),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: shadcn.Theme.of(context).typography.small.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColoredIconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool subtle;

  const _ColoredIconActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.subtle = false,
  });

  @override
  Widget build(BuildContext context) {
    return shadcn.Clickable(
      behavior: HitTestBehavior.opaque,
      onPressed: onPressed,
      child: AppSurfaceContainer(
        width: 30,
        height: 38,
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: subtle ? 0.08 : 0.12),
        borderColor: color.withValues(alpha: subtle ? 0.18 : 0.38),
        child: Center(child: Icon(icon, size: 14, color: color)),
      ),
    );
  }
}

String _formatAppVersion(PackageInfo info) {
  final version = info.version.trim().split('+').first.trim();
  final build = info.buildNumber.trim();
  if (build.isEmpty) return version.isEmpty ? '-' : version;
  return '${version.isEmpty ? '-' : version}+$build';
}

Future<String> _detectCurrentMacosArch() async {
  if (kIsWeb || !Platform.isMacOS) return 'x86_64';
  try {
    final info = await DeviceInfoPlugin().macOsInfo;
    final raw = info.arch.trim().toLowerCase();
    AppLogger.debug('[AppUpgrade] macos installer arch parsed: raw=$raw');
    if (raw.contains('arm64') || raw.contains('aarch64')) return 'arm64';
  } catch (e, st) {
    AppLogger.warn('解析 macOS 安装包架构失败: $e\n$st');
  }
  return 'x86_64';
}

bool _containsAssetPattern(MapEntry<String, String> entry, List<String> keys) {
  final text = '${entry.key} ${entry.value}'.toLowerCase();
  return keys.every(text.contains);
}

List<List<String>> _preferredAssetPatterns({required String macosArch}) {
  if (kIsWeb) {
    return const [
      ['web'],
    ];
  }
  if (Platform.isAndroid) {
    return const [
      ['android', 'arm64'],
      ['android', 'apk'],
      ['apk'],
    ];
  }
  if (Platform.isIOS) {
    return const [
      ['ios', 'ipa'],
      ['ipa'],
    ];
  }
  if (Platform.isMacOS) {
    return [
      [macosArch, 'macos', 'pkg'],
      [macosArch, 'mac', 'pkg'],
      ['macos', 'pkg'],
      ['mac', 'pkg'],
      ['pkg'],
      [macosArch, 'macos', 'dmg'],
      [macosArch, 'mac', 'dmg'],
      ['macos', 'dmg'],
      ['mac', 'dmg'],
      ['dmg'],
    ];
  }
  if (Platform.isWindows) {
    return const [
      ['x86_64-windows-setup.exe'],
      ['x86_64', 'windows', 'setup', 'exe'],
      ['windows', 'setup'],
      ['exe'],
      ['msi'],
    ];
  }
  return const [
    ['linux'],
    ['appimage'],
    ['deb'],
    ['rpm'],
  ];
}

bool _isCurrentPlatformAsset(
  MapEntry<String, String> entry, {
  required String macosArch,
}) {
  final text = '${entry.key} ${entry.value}'.toLowerCase();
  bool any(Iterable<String> values) => values.any(text.contains);
  final isWindows = any(['windows', '.exe', '.msi', 'setup.exe']);
  final isMacos = any(['macos', 'mac-os', 'mac_os', '.pkg', '.dmg']);
  final isLinux = any(['linux', '.appimage', '.deb', '.rpm']);
  final isAndroid = any(['android', '.apk']);
  final isIos = any(['ios', '.ipa']);
  final hasArm64 = any(['arm64', 'aarch64']);
  final hasX64 = any(['x86_64', 'x64', 'amd64']);

  if (kIsWeb) return any(['web']);
  if (Platform.isWindows) {
    return isWindows && !isMacos && !isLinux && !isAndroid && !isIos;
  }
  if (Platform.isMacOS) {
    if (!isMacos || isWindows || isLinux || isAndroid || isIos) return false;
    if (macosArch == 'arm64') return hasArm64 || (!hasX64 && !hasArm64);
    return hasX64 || (!hasX64 && !hasArm64);
  }
  if (Platform.isLinux) {
    return isLinux && !isWindows && !isMacos && !isAndroid && !isIos;
  }
  if (Platform.isAndroid) {
    return isAndroid && !isWindows && !isMacos && !isLinux && !isIos;
  }
  if (Platform.isIOS) {
    return isIos && !isWindows && !isMacos && !isLinux && !isAndroid;
  }
  return false;
}

bool _hasPreferredCurrentPlatformAsset(
  AppUpdateInfo? info, {
  required String macosArch,
}) {
  if (info == null || info.downloadLinks.isEmpty) return false;
  return info.downloadLinks.entries.any(
    (entry) => _isCurrentPlatformAsset(entry, macosArch: macosArch),
  );
}

class _DownloadLabel {
  final String title;
  final String subtitle;

  const _DownloadLabel({required this.title, required this.subtitle});
}

_DownloadLabel _buildDownloadLabel(
  MapEntry<String, String> entry, {
  required String macosArch,
}) {
  final text = '${entry.key} ${entry.value}'.toLowerCase();
  final isMac = [
    'macos',
    'mac-os',
    'mac_os',
    '.pkg',
    '.dmg',
  ].any(text.contains);
  final isWindows = ['windows', '.exe', '.msi', 'setup.exe'].any(text.contains);
  final isLinux = ['linux', '.appimage', '.deb', '.rpm'].any(text.contains);
  final isAndroid = ['android', '.apk'].any(text.contains);
  final isIos = ['ios', '.ipa'].any(text.contains);
  final hasArm64 = ['arm64', 'aarch64'].any(text.contains);
  final hasX64 = ['x86_64', 'x64', 'amd64'].any(text.contains);
  final fileName = _assetFileName(entry);

  if (isMac) {
    final arch = hasArm64
        ? 'ARM'
        : hasX64
        ? 'Intel'
        : macosArch == 'arm64'
        ? 'ARM'
        : 'Intel';
    return _DownloadLabel(title: 'macOS $arch', subtitle: fileName);
  }
  if (isWindows) {
    final arch = hasArm64
        ? 'ARM'
        : hasX64
        ? 'x64'
        : '通用';
    return _DownloadLabel(title: 'Windows $arch', subtitle: fileName);
  }
  if (isLinux) {
    final arch = hasArm64
        ? 'ARM'
        : hasX64
        ? 'x64'
        : '通用';
    return _DownloadLabel(title: 'Linux $arch', subtitle: fileName);
  }
  if (isAndroid) {
    final arch = hasArm64
        ? 'ARM64'
        : hasX64
        ? 'x64'
        : '通用';
    return _DownloadLabel(title: 'Android $arch', subtitle: fileName);
  }
  if (isIos) return _DownloadLabel(title: 'iOS 通用', subtitle: fileName);
  if (kIsWeb || text.contains('web')) {
    return _DownloadLabel(title: 'Web 平台', subtitle: fileName);
  }
  return _DownloadLabel(title: entry.key, subtitle: fileName);
}

String _assetFileName(MapEntry<String, String> entry) {
  final candidates = [entry.value, entry.key];
  for (final candidate in candidates) {
    final fileName = Uri.decodeComponent(
      p.basename(Uri.tryParse(candidate)?.path ?? candidate),
    ).trim();
    if (fileName.isNotEmpty &&
        fileName != '/' &&
        fileName != '.' &&
        fileName != '..') {
      return fileName;
    }
  }
  return entry.key.trim().isNotEmpty ? entry.key.trim() : 'unknown.bin';
}

int _compareVersions(String a, String b) {
  final left = _versionParts(a);
  final right = _versionParts(b);
  final length = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    final lv = i < left.length ? left[i] : 0;
    final rv = i < right.length ? right[i] : 0;
    if (lv != rv) return lv.compareTo(rv);
  }
  return 0;
}

List<int> _versionParts(String value) {
  return RegExp(r'\d+')
      .allMatches(value)
      .map((match) => int.tryParse(match.group(0) ?? '0') ?? 0)
      .toList();
}
