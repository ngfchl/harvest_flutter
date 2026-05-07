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
import 'package:forui/forui.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/browser_page.dart';
import 'package:install_plugin_v3/install_plugin_v3.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

final appUpgradeStatusProvider = FutureProvider<AppUpgradeStatus>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final response = await Dio().get<Map<String, dynamic>>(_appUpgradeLatestUrl);
  final latest = AppUpdateInfo.fromApiResponse(response.data);
  final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
  final ignored = isAppUpgradeVersionIgnored(latest.version);
  final hasNewVersion =
      latest.version.trim().isNotEmpty &&
      _compareVersions(latest.version, currentVersion) > 0;

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
    final status = ref.watch(appUpgradeStatusProvider);
    final data = status.valueOrNull;
    final cs = FTheme.of(context).colors;
    final hasUpdate = data?.shouldPrompt == true;
    final accent = hasUpdate
        ? const Color(0xFFF59E0B)
        : cs.foreground.withOpacity(0.55);
    final summary = status.isLoading
        ? '正在检查 APP 版本'
        : hasUpdate
        ? '发现 APP 新版本 v${data!.latest.version}'
        : data?.hasNewVersion == true && data?.ignored == true
        ? '已忽略 v${data!.latest.version}，点击查看'
        : data != null
        ? '当前已是最新版本'
        : '点击检查 APP 更新';

    return ExpandableCard(
      title: 'APP更新',
      leading: Icon(
        hasUpdate ? FIcons.circleAlert : FIcons.circleArrowUp,
        size: 18,
        color: accent,
      ),
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary,
            style: TextStyle(
              color: hasUpdate ? accent : cs.foreground.withOpacity(0.62),
              fontSize: 13,
              fontWeight: hasUpdate ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
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

  PackageInfo? _packageInfo;
  AppUpdateInfo? _latest;
  List<AppUpdateInfo> _versions = const [];
  bool _loadingLatest = false;
  bool _loadingVersions = false;
  bool _downloading = false;
  bool _useGithubProxy = false;
  bool _testingGithubProxy = false;
  bool _autoPromptOpen = false;
  double _progress = 0;
  String? _error;
  ResponseInfo? _githubProxy;

  String get _currentVersion {
    final info = _packageInfo;
    if (info == null) return '-';
    return '${info.version}+${info.buildNumber}';
  }

  Future<void> _handleOpenUpgradeDialog() async {
    await widget.onBeforeOpen?.call();
    if (!mounted) return;
    await _openUpgradeDialog();
  }

  bool get _hasNewVersion {
    final latest = _latest?.version.trim();
    if (latest == null || latest.isEmpty || _packageInfo == null) return false;
    return _compareVersions(latest, _currentVersion) > 0;
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
    _init();
  }

  @override
  void didUpdateWidget(covariant AppUpgradePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._state == this)
        oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
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
      _useGithubProxy =
          HiveManager.get<bool>(_appUpgradeUseGithubProxyKey) ?? false;
      if (widget.autoCheck || widget.embedded) {
        await _checkLatest(silent: true);
        if (widget.autoCheck && mounted && _hasNewVersion && !_ignoredLatest) {
          unawaited(_openUpgradeDialog(autoPrompt: true));
        }
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

  Future<void> _checkLatest({bool silent = false}) async {
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
    if (_latest == null) await _checkLatest(silent: true);
    if (_versions.isEmpty) unawaited(_loadVersions());
    if (!mounted) return;

    if (autoPrompt) _autoPromptOpen = true;
    await showFDialog<void>(
      context: context,
      builder: (ctx, style, animation) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            _dialogSetState = setDialogState;
            final size = MediaQuery.sizeOf(context);
            final isCompactDialog = size.width < 568;
            final dialogInsetPadding = EdgeInsets.symmetric(
              horizontal: isCompactDialog ? 8 : 12,
              vertical: 24,
            );
            const dialogContentPadding = EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 25,
            );
            final dialogWidth = isCompactDialog
                ? (size.width - dialogInsetPadding.horizontal)
                      .clamp(320.0, size.width)
                      .toDouble()
                : 520.0;
            final dialogHeight = isCompactDialog
                ? (size.height * 0.48).clamp(180.0, 360.0).toDouble()
                : (size.height - 230).clamp(180.0, 520.0).toDouble();
            return FDialog.raw(
              constraints: BoxConstraints(
                minWidth: 280,
                maxWidth: isCompactDialog ? dialogWidth : 560,
              ),
              style: (_) => isCompactDialog
                  ? style.copyWith(insetPadding: dialogInsetPadding)
                  : style,
              animation: animation,
              builder: (_, _) => Padding(
                padding: dialogContentPadding,
                child: SizedBox(
                  width: dialogWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _hasNewVersion
                                ? FIcons.circleArrowUp
                                : FIcons.badgeCheck,
                            size: 18,
                            color: _hasNewVersion
                                ? FTheme.of(context).colors.destructive
                                : FTheme.of(context).colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_hasNewVersion ? '发现新版本' : 'APP 更新'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                        onProxyChanged: _setUseGithubProxy,
                        onProxyTest: _useGithubProxy && !_testingGithubProxy
                            ? () => _resolveGithubProxy(force: true)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      _DialogActionBar(
                        loadingLatest: _loadingLatest,
                        downloading: _downloading,
                        hasNewVersion: _hasNewVersion,
                        onCheck: _loadingLatest ? null : () => _checkLatest(),
                        onDownload: _downloading
                            ? _cancelDownload
                            : () => _downloadPreferred(_latest),
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
        return FTabs(
          physics: const BouncingScrollPhysics(),
          children: [
            FTabEntry(
              label: const Text('最新版本'),
              child: SizedBox(
                height: contentHeight,
                child: _buildLatestTab(context),
              ),
            ),
            FTabEntry(
              label: const Text('历史版本'),
              child: SizedBox(
                height: contentHeight,
                child: _buildVersionsTab(context),
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
        if (_downloading) ...[
          const SizedBox(height: 12),
          _DownloadProgress(progress: _progress),
        ],
        SizedBox(height: compact ? 8 : 12),
        _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('更新日志'),
              SizedBox(height: compact ? 5 : 8),
              if (_loadingLatest && latest == null)
                const Center(child: FProgress.circularIcon())
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
              FButton(
                style: FButtonStyle.outline(),
                onPress: _loadingVersions ? null : _loadVersions,
                child: _loadingVersions
                    ? const _SmallProgress(label: '加载中')
                    : const Text('刷新'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loadingVersions && _versions.isEmpty)
            const Center(child: FProgress.circularIcon())
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

  Future<void> _downloadEntry(
    AppUpdateInfo info,
    MapEntry<String, String> entry,
  ) async {
    if (_downloading) return;
    _cancelToken = CancelToken();
    _downloading = true;
    _progress = 0;
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
          await _downloadToPath(url, savePath, _cancelToken!);
          Toast.success('安装包已下载，正在启动安装器');
          await _tryOpenInstaller(savePath);
          return;
        }

        final savePath = await FilePicker.saveFile(
          dialogTitle: '保存安装包',
          fileName: fileName,
          type: FileType.any,
        );
        if (savePath == null) return;
        await _downloadToPath(url, savePath, _cancelToken!);
        Toast.success('安装包已保存');
        await _tryOpenInstaller(savePath);
      } else {
        final dir = await getTemporaryDirectory();
        final savePath = p.join(dir.path, fileName);
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
      _refreshUi();
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

  Future<MapEntry<String, String>?> _selectPreferredAsset(
    AppUpdateInfo info,
  ) async {
    if (info.downloadLinks.isEmpty) {
      AppLogger.debug('[AppUpgrade] select asset skipped: empty downloadLinks');
      return null;
    }
    final entries = info.downloadLinks.entries.toList();
    bool contains(MapEntry<String, String> entry, List<String> keys) {
      final text = '${entry.key} ${entry.value}'.toLowerCase();
      return keys.every(text.contains);
    }

    List<List<String>> patterns;
    String? targetArch;
    if (kIsWeb) {
      patterns = const [
        ['web'],
      ];
    } else if (Platform.isAndroid) {
      patterns = const [
        ['android', 'arm64'],
        ['android', 'apk'],
        ['apk'],
      ];
    } else if (Platform.isIOS) {
      patterns = const [
        ['ios', 'ipa'],
        ['ipa'],
      ];
    } else if (Platform.isMacOS) {
      final arch = await _currentInstallerArch();
      targetArch = arch;
      patterns = [
        ['$arch-macos.pkg'],
        [arch, 'macos', 'pkg'],
        [arch, 'mac', 'pkg'],
        ['macos', 'pkg'],
        ['mac', 'pkg'],
        ['pkg'],
      ];
    } else if (Platform.isWindows) {
      patterns = const [
        ['x86_64-windows-setup.exe'],
        ['x86_64', 'windows', 'setup', 'exe'],
        ['windows', 'setup'],
        ['exe'],
      ];
    } else {
      patterns = const [
        ['linux'],
        ['appimage'],
        ['deb'],
      ];
    }

    AppLogger.debug(
      '[AppUpgrade] select asset candidates: platform=${_platformDebugName()}, '
      'arch=$targetArch, patterns=$patterns, '
      'entries=${entries.map((e) => '${e.key}=>${e.value}').toList()}',
    );

    for (final pattern in patterns) {
      for (final entry in entries) {
        if (contains(entry, pattern)) {
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

  Future<String> _currentInstallerArch() async {
    if (kIsWeb || !Platform.isMacOS) return 'x86_64';
    try {
      final info = await DeviceInfoPlugin().macOsInfo;
      final raw = info.arch.trim().toLowerCase();
      AppLogger.debug('[AppUpgrade] macos installer arch parsed: raw=$raw');
      if (raw.contains('arm64') || raw.contains('aarch64')) return 'arm64';
      return 'x86_64';
    } catch (e, st) {
      AppLogger.warn('解析 macOS 安装包架构失败: $e\n$st');
      return 'x86_64';
    }
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
    _refreshUi();
    if (value) unawaited(_resolveGithubProxy(force: true));
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
    if (_githubProxy != null && !force) {
      AppLogger.debug(
        '[AppUpgrade] reuse github proxy: proxy=${_githubProxy!.url}, time=${_githubProxy!.time}',
      );
      return _githubProxy;
    }
    if (_testingGithubProxy) {
      AppLogger.debug('[AppUpgrade] github proxy test already running');
      return _githubProxy;
    }

    _testingGithubProxy = true;
    _refreshUi();
    try {
      AppLogger.debug('[AppUpgrade] github proxy test start: force=$force');
      final result = await fetchFasterGithubProxy();
      if (result.success && result.data != null) {
        _githubProxy = result.data;
        AppLogger.debug(
          '[AppUpgrade] github proxy selected: proxy=${_githubProxy!.url}, '
          'time=${_githubProxy!.time}, status=${_githubProxy!.status}',
        );
        Toast.success('已选择加速地址 ${_githubProxy!.time}ms');
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
    if (widget.embedded) return _buildEmbeddedPanel(context);

    final child = widget.child;
    if (child != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleOpenUpgradeDialog,
        child: child,
      );
    }

    return FButton.icon(
      style: _hasNewVersion ? FButtonStyle.destructive() : FButtonStyle.ghost(),
      onPress: _handleOpenUpgradeDialog,
      child: _loadingLatest
          ? const SizedBox(
              width: 18,
              height: 18,
              child: FProgress.circularIcon(),
            )
          : Icon(
              _hasNewVersion ? FIcons.circleArrowUp : FIcons.refreshCw,
              size: 20,
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
          onProxyChanged: _setUseGithubProxy,
          onProxyTest: _useGithubProxy && !_testingGithubProxy
              ? () => _resolveGithubProxy(force: true)
              : null,
        ),
        const SizedBox(height: 8),
        _DialogActionBar(
          loadingLatest: _loadingLatest,
          downloading: _downloading,
          hasNewVersion: _hasNewVersion,
          onCheck: _loadingLatest ? null : () => _checkLatest(),
          onDownload: _downloading
              ? _cancelDownload
              : () => _downloadPreferred(_latest),
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
    if (data is Map)
      return AppUpdateInfo.fromJson(Map<String, dynamic>.from(data));
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
      padding: const EdgeInsets.fromLTRB(2, 14, 8, 6),
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
    final cs = FTheme.of(context).colors;
    final accent = hasNewVersion ? const Color(0xFFF59E0B) : cs.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasNewVersion
            ? accent.withValues(alpha: 0.10)
            : cs.muted.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasNewVersion ? accent.withValues(alpha: 0.35) : cs.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              hasNewVersion ? FIcons.circleArrowUp : FIcons.badgeCheck,
              size: 20,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasNewVersion ? '发现可用新版本' : '已是最新版本',
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                _InfoLine(label: '当前', value: 'v$currentVersion'),
                if (hasNewVersion) ...[
                  const SizedBox(height: 4),
                  _InfoLine(
                    label: '最新',
                    value: latestVersion?.isNotEmpty == true
                        ? 'v$latestVersion'
                        : '-',
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  const _InfoLine(label: '状态', value: '无需更新'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final Widget child;

  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: child,
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
  final ValueChanged<bool> onProxyChanged;
  final VoidCallback? onProxyTest;

  const _UpgradeOptionRow({
    required this.ignored,
    required this.ignoreEnabled,
    required this.onIgnoreChanged,
    required this.proxyEnabled,
    required this.proxyTesting,
    required this.proxy,
    required this.onProxyChanged,
    required this.onProxyTest,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final dense = MediaQuery.sizeOf(context).width < 568;
    final proxySubtitle = proxyTesting
        ? '正在测速 GitHub 加速地址'
        : proxyEnabled && proxy != null
        ? '${proxy!.url} · ${proxy!.time}ms'
        : proxyEnabled
        ? '下载前自动测速'
        : '原始下载地址';

    final ignoreOption = _InlineSwitchOption(
      icon: FIcons.circleAlert,
      title: '不再提醒',
      subtitle: ignored ? '已忽略当前版本' : '打开后忽略当前版本',
      tooltip: ignored ? '当前版本已被忽略，关闭后恢复更新提醒' : '打开后将忽略当前版本，不再自动弹出更新提醒',
      dense: dense,
      value: ignored,
      enabled: ignoreEnabled,
      onChanged: onIgnoreChanged,
    );
    final proxyOption = _InlineSwitchOption(
      icon: FIcons.gauge,
      title: 'GitHub 加速',
      subtitle: proxySubtitle,
      tooltip: proxyEnabled
          ? '下载 GitHub Release 资源前自动测速并使用可用加速地址'
          : '关闭后直接使用原始下载地址',
      dense: dense,
      value: proxyEnabled,
      enabled: !proxyTesting,
      onChanged: onProxyChanged,
      trailing: proxyEnabled
          ? FButton(
              style: FButtonStyle.ghost(_tinyAppUpgradeButtonStyle),
              onPress: onProxyTest,
              child: proxyTesting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: FProgress.circularIcon(),
                    )
                  : const Icon(FIcons.refreshCw, size: 14),
            )
          : null,
    );

    return _PanelCard(
      child: Row(
        children: [
          Expanded(child: ignoreOption),
          Container(width: 0.5, height: 42, color: cs.border),
          SizedBox(width: dense ? 6 : 10),
          Expanded(child: proxyOption),
        ],
      ),
    );
  }
}

class _InlineSwitchOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tooltip;
  final bool dense;
  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;
  final Widget? trailing;

  const _InlineSwitchOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tooltip,
    this.dense = false,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return FTooltip(
      tipBuilder: (_, _) => Text(tooltip),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  icon,
                  size: dense ? 13 : 15,
                  color: enabled ? cs.primary : cs.mutedForeground,
                ),
                SizedBox(width: dense ? 4 : 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.foreground,
                          fontSize: dense ? 10.5 : 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: dense ? 1 : 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.mutedForeground,
                          fontSize: dense ? 8.5 : 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: dense ? 4 : 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) ...[
                SizedBox(
                  width: dense ? 20 : 24,
                  height: dense ? 24 : 28,
                  child: trailing!,
                ),
                SizedBox(width: dense ? 1 : 3),
              ],
              Transform.scale(
                scale: dense ? 0.66 : 0.78,
                child: FSwitch(
                  value: value,
                  enabled: enabled && onChanged != null,
                  onChange: onChanged,
                ),
              ),
            ],
          ),
        ],
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
    final cs = FTheme.of(context).colors;
    final current = _compareVersions(info.version, currentVersion) == 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: current ? cs.primary.withValues(alpha: 0.5) : cs.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'v${info.version}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: current ? cs.primary : cs.foreground,
                  ),
                ),
              ),
              if (current)
                Text(
                  '当前版本',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
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

  const _DownloadLinks({
    required this.info,
    required this.onDownload,
    required this.onCopy,
    this.onOpenPage,
    this.compact = false,
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
      final info = await DeviceInfoPlugin().macOsInfo;
      final raw = info.arch.trim().toLowerCase();
      final arch = raw.contains('arm64') || raw.contains('aarch64')
          ? 'arm64'
          : 'x86_64';
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
    final platformEntries = entries.where(_isCurrentPlatformAsset).toList();
    final otherEntries = entries
        .where((entry) => !_isCurrentPlatformAsset(entry))
        .toList();
    final primaryEntries = platformEntries.isNotEmpty
        ? platformEntries
        : entries.take(1).toList();
    final visibleEntries = widget.compact && primaryEntries.length > 1
        ? primaryEntries.take(1).toList()
        : primaryEntries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onOpenPage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FButton(
              style: FButtonStyle.outline(_compactAppUpgradeButtonStyle),
              onPress: widget.onOpenPage,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FIcons.externalLink, size: 15),
                  SizedBox(width: 6),
                  Text('打开下载页'),
                ],
              ),
            ),
          ),
        if (current == null || entries.isEmpty)
          const _MessageBox(message: '暂无安装包下载链接')
        else ...[
          for (final entry in visibleEntries)
            _downloadEntryTile(context, current, entry),
          if (!widget.compact && otherEntries.isNotEmpty) ...[
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
    final cs = FTheme.of(context).colors;
    return Container(
      margin: EdgeInsets.only(bottom: widget.compact ? 6 : 8),
      padding: EdgeInsets.symmetric(
        horizontal: 9,
        vertical: widget.compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(FIcons.package, size: 15, color: cs.primary),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _downloadHost(entry.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.mutedForeground, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _MiniActionButton(
            icon: FIcons.copy,
            tip: '复制链接',
            onPress: () => widget.onCopy(current, entry),
          ),
          const SizedBox(width: 4),
          _MiniActionButton(
            icon: FIcons.download,
            tip: '下载',
            onPress: () => widget.onDownload(current, entry),
            outlined: true,
          ),
        ],
      ),
    );
  }

  bool _isCurrentPlatformAsset(MapEntry<String, String> entry) {
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
    if (Platform.isWindows)
      return isWindows && !isMacos && !isLinux && !isAndroid && !isIos;
    if (Platform.isMacOS) {
      if (!isMacos || isWindows || isLinux || isAndroid || isIos) return false;
      if (_macosArch == 'arm64') return hasArm64 || (!hasX64 && !hasArm64);
      return hasX64 || (!hasX64 && !hasArm64);
    }
    if (Platform.isLinux)
      return isLinux && !isWindows && !isMacos && !isAndroid && !isIos;
    if (Platform.isAndroid)
      return isAndroid && !isWindows && !isMacos && !isLinux && !isIos;
    if (Platform.isIOS)
      return isIos && !isWindows && !isMacos && !isLinux && !isAndroid;
    return false;
  }

  String _downloadHost(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return '远端安装包';
    return uri.host;
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
    final cs = FTheme.of(context).colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '其他平台安装包 $count 个',
                style: TextStyle(
                  color: cs.mutedForeground,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                FIcons.chevronDown,
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

    return MarkdownBody(
      data: data,
      selectable: true,
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
    );
  }
}

MarkdownStyleSheet _changeLogMarkdownStyleSheet(
  BuildContext context, {
  required bool compact,
}) {
  final cs = FTheme.of(context).colors;
  final body = TextStyle(
    fontSize: compact ? 12 : 13,
    height: 1.45,
    color: cs.foreground,
  );
  final code = TextStyle(
    fontSize: compact ? 11 : 12,
    height: 1.35,
    color: cs.foreground,
    backgroundColor: cs.muted.withValues(alpha: 0.65),
  );

  return MarkdownStyleSheet(
    a: body.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
    p: body,
    pPadding: EdgeInsets.only(bottom: compact ? 6 : 8),
    h1: body.copyWith(fontSize: compact ? 16 : 18, fontWeight: FontWeight.w900),
    h1Padding: EdgeInsets.only(bottom: compact ? 8 : 10),
    h2: body.copyWith(fontSize: compact ? 15 : 16, fontWeight: FontWeight.w900),
    h2Padding: EdgeInsets.only(bottom: compact ? 6 : 8),
    h3: body.copyWith(fontSize: compact ? 13 : 14, fontWeight: FontWeight.w900),
    h3Padding: EdgeInsets.only(bottom: compact ? 6 : 8),
    listBullet: body.copyWith(color: cs.mutedForeground),
    blockquote: body.copyWith(color: cs.mutedForeground),
    blockquoteDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      border: Border(left: BorderSide(color: cs.border, width: 3)),
    ),
    code: code,
    codeblockDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

class _DownloadProgress extends StatelessWidget {
  final double progress;

  const _DownloadProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final pct = (progress * 100).clamp(0, 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '下载进度 $pct%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: cs.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress <= 0 ? null : progress,
            minHeight: 6,
          ),
        ),
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
    final cs = FTheme.of(context).colors;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: cs.mutedForeground),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: cs.foreground,
            ),
          ),
        ),
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
    final cs = FTheme.of(context).colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: (destructive ? cs.destructive : cs.mutedForeground).withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: destructive ? cs.destructive : cs.mutedForeground,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: FTheme.of(context).colors.foreground,
      ),
    );
  }
}

class _SmallProgress extends StatelessWidget {
  final String label;

  const _SmallProgress({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 14, height: 14, child: FProgress.circularIcon()),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _DialogActionBar extends StatelessWidget {
  final bool loadingLatest;
  final bool downloading;
  final bool hasNewVersion;
  final VoidCallback? onCheck;
  final VoidCallback onDownload;
  final VoidCallback? onTestFlight;

  const _DialogActionBar({
    required this.loadingLatest,
    required this.downloading,
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
          child: FButton(
            style: FButtonStyle.ghost(_compactAppUpgradeButtonStyle),
            onPress: onCheck,
            child: loadingLatest
                ? const _SmallProgress(label: '检查')
                : const Text('检查'),
          ),
        ),
        if (onTestFlight != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: FButton(
              style: FButtonStyle.outline(_compactAppUpgradeButtonStyle),
              onPress: onTestFlight,
              child: const Text('TF跳转'),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Expanded(
          child: FButton(
            style: FButtonStyle.primary(_compactAppUpgradeButtonStyle),
            onPress: onDownload,
            child: downloading
                ? const Text('取消')
                : Text(hasNewVersion ? '更新' : '重装'),
          ),
        ),
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
    return FTooltip(
      tipBuilder: (_, _) => Text(tip),
      child: SizedBox(
        width: 30,
        height: 38,
        child: FButton(
          style: outlined
              ? FButtonStyle.outline(_tinyAppUpgradeButtonStyle)
              : FButtonStyle.ghost(_tinyAppUpgradeButtonStyle),
          onPress: onPress,
          child: Icon(icon, size: 14),
        ),
      ),
    );
  }
}

FButtonStyle _compactAppUpgradeButtonStyle(FButtonStyle style) {
  return style.copyWith(
    contentStyle: (content) => content.copyWith(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    ),
  );
}

FButtonStyle _tinyAppUpgradeButtonStyle(FButtonStyle style) {
  return style.copyWith(
    contentStyle: (content) => content.copyWith(padding: EdgeInsets.zero),
    iconContentStyle: (content) => content.copyWith(padding: EdgeInsets.zero),
  );
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
