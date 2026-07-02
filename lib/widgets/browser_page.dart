import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/widgets/push_torrent_sheet.dart';
import 'package:harvest/modules/search/model/search_torrent_info.dart';
import 'package:harvest/modules/search/widgets/downloader_select_sheet.dart';
import 'package:harvest/modules/site/model/site_config.dart';
import 'package:harvest/modules/site/model/site_info.dart';
import 'package:harvest/modules/site/provider/site_provider.dart';
import 'package:harvest/modules/site/widgets/site_browser.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// ══════════════════════════════════════════════════════════
//  内置浏览器
// ══════════════════════════════════════════════════════════

const _safariIphoneUserAgent =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1';
const _safariMacosUserAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15';
const _localStorageInjectedKey = '__harvest_local_storage_injected__';

class BrowserPage extends StatefulWidget {
  final String url;
  final String? title;
  final String? cookie;
  final String? localStorage;
  final String? userAgent;
  final String? siteId;
  final WebSite? website;

  const BrowserPage({
    super.key,
    required this.url,
    this.title,
    this.cookie,
    this.localStorage,
    this.userAgent,
    this.siteId,
    this.website,
  });

  /// 快捷打开
  static void open(
    BuildContext context, {
    required String url,
    String? title,
    String? cookie,
    String? localStorage,
    String? userAgent,
    String? siteId,
    WebSite? website,
  }) {
    final normalizedUrl = _normalizeInitialBrowserUrl(url);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrowserPage(
          url: normalizedUrl,
          title: title,
          cookie: cookie,
          localStorage: localStorage,
          userAgent: userAgent,
          siteId: siteId,
          website: website,
        ),
      ),
    );
  }

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class BrowserCookieQuickMenu extends StatelessWidget {
  final List<SiteBrowseTarget> targets;
  final ValueChanged<SiteBrowseTarget> onSelected;
  final Widget? badge;
  final String menuLabel;

  const BrowserCookieQuickMenu({
    super.key,
    required this.targets,
    required this.onSelected,
    this.badge,
    this.menuLabel = '快速跳转',
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    // 检查是否有任何可显示的内容
    final hasContent = targets.isNotEmpty;
    final effectiveBadge = badge ?? _defaultCookieBadge(hasContent);

    if (!hasContent) return effectiveBadge;

    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: Builder(
        builder: (menuContext) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => shadcn.showDropdown<void>(
            context: menuContext,
            alignment: Alignment.topCenter,
            offset: const Offset(0, 8),
            widthConstraint: shadcn.PopoverConstraint.intrinsic,
            heightConstraint: shadcn.PopoverConstraint.intrinsic,
            consumeOutsideTaps: false,
            builder: (_) => AppDropdownMenu(
              children: [
                shadcn.MenuLabel(child: Text(menuLabel)),
                const shadcn.MenuDivider(),
                for (final target in targets)
                  shadcn.MenuButton(
                    leading: Icon(target.icon),
                    onPressed: (itemContext) {
                      shadcn.closeOverlay(itemContext);
                      onSelected(target);
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            target.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _browserDisplayUrl(target.url),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: cs.foreground.withValues(alpha: 0.48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          child: effectiveBadge,
        ),
      ),
    );
  }

  Widget _defaultCookieBadge(bool hasTargets) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Cookie',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hasTargets) ...[
            const SizedBox(width: 3),
            const Icon(
              shadcn.LucideIcons.chevronDown,
              size: 10,
              color: Color(0xFF10B981),
            ),
          ],
        ],
      ),
    );
  }
}

String _normalizeInitialBrowserUrl(String value) {
  final text = value.trim();
  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return text;
  final normalizedPath = uri.path.replaceAll(RegExp(r'/+'), '/');
  return uri
      .replace(path: normalizedPath.isEmpty ? null : normalizedPath)
      .toString();
}

String _browserDisplayUrl(String url) {
  if (url.startsWith('about:')) return url;
  try {
    final uri = Uri.parse(url);
    final display = uri.host + uri.path;
    return display.endsWith('/')
        ? display.substring(0, display.length - 1)
        : display;
  } catch (_) {
    return url;
  }
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? _controller;
  String _currentUrl = '';
  String _lastLoadedPageUrl = '';
  String _currentTitle = '';
  String? _activeUserAgent = _safariMacosUserAgent;
  String _activeUserAgentId = 'safari_macos';
  String? _defaultUserAgent;
  double _progress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isLoading = true;
  bool _cookiesReady = false;
  bool _hasReadableCookie = false;
  bool _hasReadableLocalStorage = false;
  bool _closing = false;
  bool _torrentSheetOpen = false;
  bool _retriedInitialUrlAfterLocalStorageInjection = false;
  String? _activeTorrentUrl;
  String? _error;
  bool _extractingTorrentList = false;
  bool _extractingUserProfile = false;
  bool _bonusExchanging = false;
  double _bonusCurrent = 0;
  bool _bonusPaused = false;
  bool _bonusCancelled = false;
  String _bonusItemName = '';
  int _bonusCurrentIdx = 0;
  int _bonusTotal = 0;
  double _bonusRemaining = 0;
  int _bonusCountdown = 0;
  int _bonusDelaySeconds = 15;
  bool _websiteConfigsLoadingStarted = false;
  List<WebSite> _websiteConfigs = const <WebSite>[];
  List<SiteInfo> _siteInfos = const <SiteInfo>[];

  @override
  void initState() {
    super.initState();
    _enableWebViewDebugging();
    _currentUrl = widget.url;
    _lastLoadedPageUrl = widget.url;
    _currentTitle = widget.title ?? '';
    _hasReadableCookie = widget.cookie?.trim().isNotEmpty == true;
    _hasReadableLocalStorage = widget.localStorage?.trim().isNotEmpty == true;
    _prepareCookies();
    _loadDefaultUserAgent();
  }

  void _enableWebViewDebugging() {
    if (!kDebugMode ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    unawaited(
      InAppWebViewController.setWebContentsDebuggingEnabled(true).catchError((
        Object e,
        StackTrace st,
      ) {
        AppLogger.warn('开启 Android WebView 调试失败: $e\n$st');
      }),
    );
  }

  @override
  void dispose() {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      unawaited(_stopLoadingSafely(controller));
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_websiteConfigsLoadingStarted) return;
    _websiteConfigsLoadingStarted = true;
    _loadWebsiteConfigs();
  }

  Future<void> _loadWebsiteConfigs() async {
    final container = ProviderScope.containerOf(context, listen: false);
    final currentConfigs = container.read(websiteListProvider).value;
    final currentSites = container.read(siteInfoListProvider).value;
    if (currentConfigs != null && currentSites != null) {
      _websiteConfigs = currentConfigs;
      _siteInfos = currentSites;
      return;
    }

    try {
      final configsFuture = currentConfigs != null
          ? Future<List<WebSite>>.value(currentConfigs)
          : container.read(websiteListProvider.future);
      final sitesFuture = currentSites != null
          ? Future<List<SiteInfo>>.value(currentSites)
          : container.read(siteInfoListProvider.future);
      final configs = await configsFuture;
      final sites = await sitesFuture;
      if (mounted && !_closing) {
        setState(() {
          _websiteConfigs = configs;
          _siteInfos = sites;
        });
      }
    } catch (e, st) {
      AppLogger.warn('读取站点数据失败: $e\n$st');
    }
  }

  Future<void> _closeBrowser() async {
    if (_closing) return;
    _closing = true;
    final navigator = Navigator.of(context);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _progress = 0;
      });
    }

    final controller = _controller;
    _controller = null;
    if (controller != null) {
      unawaited(_stopLoadingSafely(controller));
    }

    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    navigator.pop();
  }

  Future<void> _stopLoadingSafely(InAppWebViewController controller) async {
    try {
      await controller.stopLoading().timeout(const Duration(milliseconds: 300));
    } catch (e, st) {
      AppLogger.warn('停止 WebView 加载失败或超时: $e\n$st');
    }
  }

  // ────────────────── Cookie 注入 ──────────────────

  Future<void> _prepareCookies() async {
    if (_closing) return;
    if (widget.cookie == null || widget.cookie!.isEmpty) {
      if (mounted) setState(() => _cookiesReady = true);
      return;
    }

    try {
      final uri = Uri.parse(widget.url);
      final domain = uri.host;
      final scheme = uri.scheme;
      final cookieManager = CookieManager.instance();

      final pairs = widget.cookie!.split(';');
      var count = 0;

      for (final pair in pairs) {
        final trimmed = pair.trim();
        if (trimmed.isEmpty) continue;

        final eqIndex = trimmed.indexOf('=');
        if (eqIndex <= 0) continue;

        final name = trimmed.substring(0, eqIndex).trim();
        final value = trimmed.substring(eqIndex + 1).trim();
        if (name.isEmpty) continue;

        await cookieManager.setCookie(
          url: WebUri('$scheme://$domain'),
          name: name,
          value: value,
          domain: domain,
          path: '/',
          isSecure: scheme == 'https',
        );
        count++;
      }

      debugPrint('[Browser] 注入 $count 个 cookie → $domain');
    } catch (e) {
      debugPrint('[Browser] Cookie 注入失败: $e');
    }

    if (mounted && !_closing) setState(() => _cookiesReady = true);
  }

  UnmodifiableListView<UserScript>? _configuredLocalStorageUserScripts() {
    final source = _configuredLocalStorageInjectionScript();
    if (source == null) return null;
    return UnmodifiableListView([
      UserScript(
        source: source,
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      ),
    ]);
  }

  InAppWebViewInitialData? _configuredLocalStorageBootstrapInitialData() {
    final source = _configuredLocalStorageInjectionScript(url: widget.url);
    if (source == null) return null;

    final targetUrl = widget.url.trim();
    if (targetUrl.isEmpty) return null;

    return InAppWebViewInitialData(
      baseUrl: WebUri(targetUrl),
      historyUrl: WebUri(targetUrl),
      data: _buildLocalStorageBootstrapHtml(
        injectionScript: source,
        targetUrl: targetUrl,
      ),
    );
  }

  String _buildLocalStorageBootstrapHtml({
    required String injectionScript,
    required String targetUrl,
  }) {
    final encodedTargetUrl = jsonEncode(targetUrl);
    return '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script>
    (() => {
      try {
        $injectionScript
      } catch (_) {}
      window.location.replace($encodedTargetUrl);
    })();
  </script>
</head>
<body></body>
</html>
''';
  }

  Future<int> _injectConfiguredLocalStorage(
    InAppWebViewController controller,
    String? url,
  ) async {
    if (_closing) return 0;
    final source = _configuredLocalStorageInjectionScript(url: url);
    if (source == null) return 0;

    try {
      final raw = await controller.evaluateJavascript(source: source);
      final count = _javascriptInt(raw);
      AppLogger.info(
        '注入内置浏览器 localStorage: url=${url ?? _currentUrl}, count=$count, configuredLength=${widget.localStorage?.trim().length ?? 0}',
      );
      return count;
    } catch (e, st) {
      AppLogger.warn('注入内置浏览器 localStorage 失败: $e\n$st');
      return 0;
    }
  }

  int _javascriptInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  String? _configuredLocalStorageInjectionScript({String? url}) {
    final localStorage = widget.localStorage?.trim();
    if (localStorage == null || localStorage.isEmpty) return null;

    final allowedHosts = _configuredLocalStorageHosts();
    if (allowedHosts.isEmpty) {
      return null;
    }
    if (url?.trim().isNotEmpty == true) {
      final currentUri = Uri.tryParse(url!.trim());
      if (currentUri == null ||
          !_isConfiguredLocalStorageHost(currentUri.host)) {
        return null;
      }
    }
    return _buildLocalStorageInjectionScript(
      localStorage,
      allowedHosts: allowedHosts,
      installAuthBridge: _shouldInstallLocalStorageAuthBridge(localStorage),
    );
  }

  Set<String> _configuredLocalStorageHosts() {
    final hosts = <String>{};
    void addHost(String? value) {
      final uri = Uri.tryParse(value?.trim() ?? '');
      if (uri == null ||
          (uri.scheme != 'http' && uri.scheme != 'https') ||
          uri.host.isEmpty) {
        return;
      }
      final host = uri.host.toLowerCase();
      hosts.add(host);
      var baseHost = host;
      if (baseHost.startsWith('www.')) {
        baseHost = baseHost.substring(4);
      } else if (baseHost.startsWith('m.')) {
        baseHost = baseHost.substring(2);
      }
      hosts.add(baseHost);
      hosts.add('www.$baseHost');
      hosts.add('m.$baseHost');
    }

    addHost(widget.url);
    for (final url in widget.website?.url ?? const <String>[]) {
      addHost(url);
    }
    return hosts;
  }

  bool _isConfiguredLocalStorageHost(String host) {
    return _configuredLocalStorageHosts().contains(host.toLowerCase());
  }

  bool _shouldInstallLocalStorageAuthBridge(String localStorage) {
    final storageText = localStorage.toLowerCase();
    if (!storageText.contains('auth') && !storageText.contains('token')) {
      return false;
    }

    final siteText = [
      widget.url,
      widget.title,
      widget.siteId,
      widget.website?.name,
      widget.website?.nickname,
      widget.website?.tracker,
      ...?widget.website?.url,
    ].whereType<String>().join(' ').toLowerCase();

    return siteText.contains('m-team') ||
        siteText.contains('mteam') ||
        siteText.contains('rousi') ||
        siteText.contains('肉丝');
  }

  String _buildLocalStorageInjectionScript(
    String localStorage, {
    required Set<String> allowedHosts,
    required bool installAuthBridge,
  }) {
    final encodedHosts = jsonEncode(allowedHosts.toList()..sort());
    final encodedMarker = jsonEncode(_localStorageInjectedKey);
    final encodedStorage = jsonEncode(localStorage);
    final authBridgeEnabled = installAuthBridge ? 'true' : 'false';
    return '''
(() => {
  const allowedHosts = new Set($encodedHosts);
  if (allowedHosts.size > 0 && !allowedHosts.has(window.location.hostname.toLowerCase())) return 0;

  const marker = $encodedMarker;
  try {
    if (window.sessionStorage.getItem(marker) === 'cleared') return 0;
  } catch (_) {}

  const raw = $encodedStorage;
  const valueText = (value) => {
    if (value === undefined || value === null) return '';
    if (typeof value === 'string') return value;
    if (typeof value === 'object') {
      try { return JSON.stringify(value); } catch (_) {}
    }
    return String(value);
  };
  const setItem = (key, value) => {
    if (key === undefined || key === null) return 0;
    const textKey = String(key);
    if (textKey.length === 0) return 0;
    window.localStorage.setItem(textKey, valueText(value));
    return 1;
  };

  const applyObject = (data) => {
    let count = 0;
    if (Array.isArray(data)) {
      data.forEach((item) => {
        if (Array.isArray(item) && item.length >= 2) count += setItem(item[0], item[1]);
      });
      return count;
    }
    if (!data || typeof data !== 'object') return count;
    Object.keys(data).forEach((key) => count += setItem(key, data[key]));
    return count;
  };

  const applyStorageText = (text) => {
    let count = 0;
    text.split(';').forEach((part) => {
      const index = part.indexOf('=');
      if (index <= 0) return;
      count += setItem(part.slice(0, index).trim(), part.slice(index + 1).trim());
    });
    return count;
  };

  let count = 0;
  const text = String(raw || '').trim();
  if (text.startsWith('{') || text.startsWith('[')) {
    try {
      count = applyObject(JSON.parse(text));
    } catch (_) {
      count = applyStorageText(text);
    }
  } else {
    count = applyStorageText(text);
  }

  if (count > 0) {
    try { window.sessionStorage.setItem(marker, 'injected'); } catch (_) {}
  }

  const installAuthBridge = $authBridgeEnabled;
  const installApiAuthBridge = () => {
    if (!installAuthBridge || window.__harvest_api_auth_bridge_installed__) return;
    window.__harvest_api_auth_bridge_installed__ = true;

    const tokenFromStorage = () => {
      const keys = ['auth', 'token', 'accessToken', 'access_token', 'jwt'];
      for (const key of keys) {
        try {
          const value = window.localStorage.getItem(key);
          if (value && String(value).trim().length > 0) return String(value).trim();
        } catch (_) {}
      }
      return '';
    };
    const authHeader = () => {
      const token = tokenFromStorage();
      if (!token) return '';
      return token.toLowerCase().startsWith('bearer ') ? token : `Bearer \${token}`;
    };
    const apiHosts = () => {
      const hosts = new Set();
      const addHost = (value) => {
        if (!value) return;
        try {
          const url = new URL(String(value), window.location.href);
          if (url.host) hosts.add(url.host.toLowerCase());
        } catch (_) {}
      };
      ['apiHost', 'api_host', 'baseApi', 'base_api', 'apiBase', 'api_base'].forEach((key) => {
        try { addHost(window.localStorage.getItem(key)); } catch (_) {}
      });
      const currentHost = window.location.hostname.toLowerCase();
      if (currentHost.includes('m-team')) {
        hosts.add('api.m-team.cc');
        hosts.add('api2.m-team.cc');
      }
      return hosts;
    };
    const shouldAttachAuth = (value) => {
      if (!value) return false;
      try {
        const url = new URL(String(value), window.location.href);
        return apiHosts().has(url.host.toLowerCase());
      } catch (_) {
        return false;
      }
    };

    if (typeof window.fetch === 'function') {
      const nativeFetch = window.fetch.bind(window);
      window.fetch = (input, init) => {
        try {
          const target = input && typeof input === 'object' && 'url' in input ? input.url : input;
          const headerValue = authHeader();
          if (!headerValue || !shouldAttachAuth(target)) return nativeFetch(input, init);
          const headers = new Headers(typeof Request !== 'undefined' && input instanceof Request ? input.headers : undefined);
          if (init && init.headers) new Headers(init.headers).forEach((value, key) => headers.set(key, value));
          if (!headers.has('authorization')) headers.set('Authorization', headerValue);
          return nativeFetch(input, Object.assign({}, init || {}, { headers }));
        } catch (_) {
          return nativeFetch(input, init);
        }
      };
    }

    const xhr = window.XMLHttpRequest && window.XMLHttpRequest.prototype;
    if (xhr && xhr.open && xhr.send && xhr.setRequestHeader) {
      const nativeOpen = xhr.open;
      const nativeSend = xhr.send;
      const nativeSetRequestHeader = xhr.setRequestHeader;
      xhr.open = function(method, url) {
        this.__harvest_auth_url = url;
        this.__harvest_has_auth_header = false;
        return nativeOpen.apply(this, arguments);
      };
      xhr.setRequestHeader = function(name, value) {
        if (String(name || '').toLowerCase() === 'authorization') {
          this.__harvest_has_auth_header = true;
        }
        return nativeSetRequestHeader.apply(this, arguments);
      };
      xhr.send = function() {
        try {
          const headerValue = authHeader();
          if (headerValue && !this.__harvest_has_auth_header && shouldAttachAuth(this.__harvest_auth_url)) {
            nativeSetRequestHeader.call(this, 'Authorization', headerValue);
          }
        } catch (_) {}
        return nativeSend.apply(this, arguments);
      };
    }
  };
  installApiAuthBridge();
  return count;
})();
''';
  }

  Future<void> _refreshReadableCookieState([String? url]) async {
    if (_closing || !mounted) return;

    final targetUrl = (url ?? _currentUrl).trim();
    final uri = Uri.tryParse(targetUrl);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      if (_hasReadableCookie && mounted && !_closing) {
        setState(() => _hasReadableCookie = false);
      }
      return;
    }

    try {
      final cookies = await CookieManager.instance().getCookies(
        url: WebUri(targetUrl),
      );
      final hasCookie = cookies.any((cookie) => cookie.name.isNotEmpty);
      if (mounted && !_closing && _hasReadableCookie != hasCookie) {
        setState(() => _hasReadableCookie = hasCookie);
      }
    } catch (e, st) {
      AppLogger.warn('检查内置浏览器 Cookie 失败: $e\n$st');
    }
  }

  Future<void> _refreshReadableLocalStorageState([String? url]) async {
    if (_closing || !mounted) return;

    final targetUrl = (url ?? _currentUrl).trim();
    final uri = Uri.tryParse(targetUrl);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      if (_hasReadableLocalStorage && mounted && !_closing) {
        setState(() => _hasReadableLocalStorage = false);
      }
      return;
    }

    final localStorage = await _localStorageSnapshotFor(targetUrl);
    final hasLocalStorage = _optionalBrowserStorage(localStorage ?? '') != null;
    if (mounted && !_closing && _hasReadableLocalStorage != hasLocalStorage) {
      setState(() => _hasReadableLocalStorage = hasLocalStorage);
    }
  }

  // ────────────────── 导航状态 ──────────────────

  Future<void> _updateNavState() async {
    if (_controller == null || !mounted || _closing) return;
    final back = await _controller!.canGoBack();
    final forward = await _controller!.canGoForward();
    if (mounted && !_closing) {
      setState(() {
        _canGoBack = back;
        _canGoForward = forward;
      });
    }
  }

  Future<void> _loadDefaultUserAgent() async {
    try {
      final userAgent = await InAppWebViewController.getDefaultUserAgent();
      if (mounted) setState(() => _defaultUserAgent = userAgent);
    } catch (e, st) {
      AppLogger.warn('读取默认 WebView UA 失败: $e\n$st');
    }
  }

  // ────────────────── 构建 ──────────────────

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final torrentWebsite = _currentTorrentWebsiteConfig();
    final detailWebsite = _currentDetailWebsiteConfig();
    final userWebsite = _currentUserWebsiteConfig();
    final showTorrentFab =
        (torrentWebsite != null || detailWebsite != null) &&
        !_closing &&
        !_isLoading;
    final showUserProfileFab = userWebsite != null && !_closing && !_isLoading;
    final bonusWebsite = _currentBonusWebsiteConfig();
    final showBonusFab = bonusWebsite != null && !_closing && !_isLoading;

    final pageBackground = appSurfaceColor(context, cs.background);

    return PopScope(
      canPop: _closing,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_canGoBack) {
          _controller?.goBack();
        } else {
          await _closeBrowser();
        }
      },
      child: AppBackground(
        child: Scaffold(
          backgroundColor: pageBackground,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildTopBar(cs),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: (_progress > 0 && _progress < 1) ? 2 : 0,
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(cs.primary),
                      ),
                    ),
                    Expanded(
                      child: _closing
                          ? const SizedBox.shrink()
                          : _cookiesReady
                          ? _buildWebView()
                          : const Center(
                              child: shadcn.CircularProgressIndicator(),
                            ),
                    ),
                    _buildBottomBar(cs),
                  ],
                ),
                if (showBonusFab && !_bonusExchanging)
                  Positioned(
                    right: 16,
                    bottom: MediaQuery.of(context).size.height / 2 - 24,
                    child: GestureDetector(
                      onTap: () => _showBonusExchangeSheet(bonusWebsite),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Color(0x66F59E0B), blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        child: const Icon(shadcn.LucideIcons.gem, size: 22, color: Colors.white),
                      ),
                    ),
                  ),
                if (_bonusExchanging)
                  Positioned(
                    right: 16,
                    bottom: MediaQuery.of(context).size.height / 2 - 24,
                    child: _buildBonusFlutterOverlay(cs),
                  ),
                if (showTorrentFab || showUserProfileFab)
                  Positioned(
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showUserProfileFab) ...[
                          FloatingActionButton.small(
                            heroTag: 'browser_user_profile_fab',
                            onPressed: _extractingUserProfile
                                ? null
                                : () => _extractUserProfile(userWebsite),
                            backgroundColor: cs.primary,
                            foregroundColor: cs.primaryForeground,
                            child: _extractingUserProfile
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: shadcn.CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primaryForeground,
                                    ),
                                  )
                                : const Icon(
                                    shadcn.LucideIcons.userRound,
                                    size: 18,
                                  ),
                          ),
                          if (showTorrentFab) const SizedBox(height: 10),
                        ],
                        if (showTorrentFab)
                          FloatingActionButton.small(
                            heroTag: 'browser_torrent_list_fab',
                            onPressed: _extractingTorrentList
                                ? null
                                : () async {
                                    if (detailWebsite != null) {
                                      await _extractSingleTorrentDetail(
                                        detailWebsite,
                                      );
                                      return;
                                    }
                                    if (torrentWebsite != null) {
                                      await _extractTorrentList(torrentWebsite);
                                    }
                                  },
                            backgroundColor: cs.primary,
                            foregroundColor: cs.primaryForeground,
                            child: _extractingTorrentList
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: shadcn.CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primaryForeground,
                                    ),
                                  )
                                : Icon(
                                    detailWebsite != null
                                        ? shadcn.LucideIcons.download
                                        : shadcn.LucideIcons.listChecks,
                                    size: 18,
                                  ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(shadcn.ColorScheme cs) {
    return Container(
      padding: appHeaderPadding(
        context,
        left: 12,
        top: 8,
        right: 12,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: GestureDetector(
              onTap: () => _closeBrowser(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  shadcn.LucideIcons.x,
                  size: 18,
                  color: cs.foreground,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentTitle.isNotEmpty)
                  Text(
                    _currentTitle,
                    style: TextStyle(
                      color: cs.foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  _displayUrl(_currentUrl),
                  style: TextStyle(
                    color: cs.foreground.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Cookie 指示
          if (_shouldShowCookieQuickMenu()) _buildCookieQuickMenu(cs),
          // 加载状态
          if (_isLoading) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              height: 14,
              child: shadcn.CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(width: 8),
            Icon(
              shadcn.LucideIcons.circleAlert,
              size: 14,
              color: const Color(0xFFF85149),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCookieQuickMenu(shadcn.ColorScheme cs) {
    final targets = _siteQuickBrowseTargets();
    return BrowserCookieQuickMenu(
      targets: targets,
      onSelected: _openQuickBrowseTarget,
    );
  }

  bool _shouldShowExtractCookieButton() {
    final website = _websiteConfigForCurrentSite();
    final siteInfo = _currentSiteInfoForQuickLinks(website);
    return siteInfo != null;
  }

  Future<void> _extractAndSyncCookie() async {
    final website = _websiteConfigForCurrentSite();
    final siteInfo = _currentSiteInfoForQuickLinks(website);

    if (siteInfo == null) {
      Toast.warning('未找到对应的站点配置');
      return;
    }

    AppLogger.info('开始提取 Cookie: site=${siteInfo.site}, url=$_currentUrl');
    final notifier = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(siteInfoListProvider.notifier);
    final cookie = await _cookieHeaderFor(_currentUrl);
    final cookieText = cookie?.trim();
    final localStorage = await _localStorageSnapshotFor(_currentUrl);
    final hasCookie = cookieText?.isNotEmpty == true;
    final normalizedLocalStorage = localStorage == null
        ? null
        : _optionalBrowserStorage(localStorage);
    final hasLocalStorage = normalizedLocalStorage != null;

    if (!hasCookie && !hasLocalStorage) {
      Toast.warning('未检测到 Cookie 或 localStorage');
      AppLogger.warn('Cookie/localStorage 提取失败或为空');
      return;
    }

    if (hasCookie) {
      AppLogger.info('提取到的 Cookie 长度: ${cookieText!.length} 字符');
      AppLogger.info(
        'Cookie 内容预览: ${cookieText.substring(0, cookieText.length > 200 ? 200 : cookieText.length)}...',
      );
    }

    var copied = false;
    final clipboardText = _browserStorageClipboardJson(
      cookie: hasCookie ? cookieText : null,
      localStorage: normalizedLocalStorage,
    );
    try {
      await Clipboard.setData(ClipboardData(text: clipboardText));
      copied = true;
    } catch (e, st) {
      AppLogger.warn('复制提取的 Cookie/localStorage 失败: $e\n$st');
    }

    try {
      final updated = siteInfo.copyWith(
        cookie: hasCookie ? cookieText : '',
        localStorage: hasLocalStorage ? normalizedLocalStorage : '',
      );
      await notifier.updateSite(updated);

      AppLogger.info(
        'Cookie/localStorage 已同步到后端: site=${siteInfo.site}, cookieLength=${cookieText?.length ?? 0}, localStorageLength=${normalizedLocalStorage?.length ?? 0}',
      );
      if (hasCookie && !hasLocalStorage) {
        Toast.success(
          copied
              ? '数据已复制，Cookie 已同步 (${cookieText!.length} 字符)'
              : 'Cookie 已同步，复制失败 (${cookieText!.length} 字符)',
        );
      } else if (hasCookie) {
        Toast.success(
          copied
              ? '数据已复制，Cookie/localStorage 已同步'
              : 'Cookie/localStorage 已同步，复制失败',
        );
      } else {
        Toast.success(
          copied ? '数据已复制，localStorage 已同步' : 'localStorage 已同步，复制失败',
        );
      }
    } catch (e, st) {
      AppLogger.error('同步 Cookie/localStorage 失败', e, st);
      Toast.error(copied ? '数据已复制，同步失败' : '同步 Cookie/localStorage 失败');
    }
  }

  String? _optionalBrowserStorage(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  String _browserStorageClipboardJson({
    required String? cookie,
    required String? localStorage,
  }) {
    return jsonEncode(<String, Object?>{
      'cookie': cookie?.trim() ?? '',
      'localstorage': localStorage?.trim() ?? '',
    });
  }

  Future<void> _copyBrowserStorageClipboardJson() async {
    final cookie = await _cookieHeaderFor(_currentUrl);
    final localStorage = await _localStorageSnapshotFor(_currentUrl);
    final cookieText = cookie?.trim();
    final localStorageText = localStorage?.trim();
    final hasCookie = cookieText?.isNotEmpty == true;
    final hasLocalStorage = localStorageText?.isNotEmpty == true;

    if (!hasCookie && !hasLocalStorage) {
      Toast.warning('未检测到 Cookie 或 localStorage');
      return;
    }

    try {
      await Clipboard.setData(
        ClipboardData(
          text: _browserStorageClipboardJson(
            cookie: hasCookie ? cookieText : null,
            localStorage: hasLocalStorage ? localStorageText : null,
          ),
        ),
      );
      Toast.success('授权信息已复制');
    } catch (e, st) {
      AppLogger.warn('复制授权信息失败: $e\n$st');
      Toast.warning('授权信息复制失败');
    }
  }

  bool _shouldShowCookieQuickMenu() {
    final website = _websiteConfigForCurrentSite();
    return _currentSiteInfoForQuickLinks(website) != null || _hasReadableCookie;
  }

  List<SiteBrowseTarget> _siteQuickBrowseTargets() {
    final website = _websiteConfigForCurrentSite();
    final site = _currentSiteInfoForQuickLinks(website);
    if (site == null) return const [];
    return buildSiteBrowseTargets(site, website);
  }

  SiteInfo? _currentSiteInfoForQuickLinks(WebSite? website) {
    final sites = _siteInfos;
    if (sites.isEmpty) return null;

    final siteId = widget.siteId?.trim().toLowerCase() ?? '';
    final currentHost = _uriHost(_currentUrl);
    final websiteName = website?.name.trim().toLowerCase() ?? '';
    final websiteNickname = website?.nickname.trim().toLowerCase() ?? '';

    for (final site in sites) {
      final siteName = site.site.trim().toLowerCase();
      final nickname = site.nickname.trim().toLowerCase();
      if (siteId.isNotEmpty && (siteName == siteId || nickname == siteId)) {
        return site;
      }
      if (websiteName.isNotEmpty &&
          (siteName == websiteName || nickname == websiteName)) {
        return site;
      }
      if (websiteNickname.isNotEmpty &&
          (siteName == websiteNickname || nickname == websiteNickname)) {
        return site;
      }
    }

    if (currentHost == null) return null;
    for (final site in sites) {
      if (_uriHost(site.mirror ?? '') == currentHost) return site;
    }
    return null;
  }

  Future<void> _openQuickBrowseTarget(SiteBrowseTarget target) async {
    AppLogger.info('快速跳转: label=${target.label}, url=${target.url}');
    final controller = _controller;
    if (controller == null || _closing) {
      AppLogger.warn(
        '无法跳转: controller=${controller == null ? "null" : "ok"}, _closing=$_closing',
      );
      return;
    }
    try {
      AppLogger.info('开始加载 URL: ${target.url}');
      await controller.loadUrl(urlRequest: URLRequest(url: WebUri(target.url)));
      AppLogger.info('URL 加载请求已发送');
    } catch (e, st) {
      AppLogger.error('内置浏览器快速跳转失败', e, st);
      if (mounted) Toast.error('快速跳转失败');
    }
  }

  // ── 底部工具栏 ──

  Widget _buildBottomBar(shadcn.ColorScheme cs) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(top: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomBtn(cs, shadcn.LucideIcons.arrowLeft, '后退', _canGoBack, () {
            if (_canGoBack) {
              _controller?.goBack();
            } else {
              _closeBrowser();
            }
          }),
          _bottomBtn(
            cs,
            shadcn.LucideIcons.arrowRight,
            '前进',
            _canGoForward,
            () => _controller?.goForward(),
          ),
          _bottomBtn(
            cs,
            shadcn.LucideIcons.refreshCw,
            '刷新',
            true,
            () => _controller?.reload(),
          ),
          _bottomBtn(
            cs,
            shadcn.LucideIcons.globe,
            'UA',
            true,
            _showUserAgentPicker,
          ),
          _bottomBtn(
            cs,
            shadcn.LucideIcons.ellipsisVertical,
            '操作',
            true,
            _showBrowserActionMenu,
          ),
        ],
      ),
    );
  }

  Future<void> _showBrowserActionMenu() async {
    if (!mounted) return;
    final canExtractCookie = _shouldShowExtractCookieButton();
    shadcn.showDropdown<void>(
      context: context,
      alignment: Alignment.bottomCenter,
      offset: const Offset(0, -8),
      widthConstraint: shadcn.PopoverConstraint.intrinsic,
      heightConstraint: shadcn.PopoverConstraint.intrinsic,
      consumeOutsideTaps: true,
      builder: (_) => AppDropdownMenu(
        children: [
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.link),
            onPressed: (itemContext) {
              shadcn.closeOverlay(itemContext);
              Clipboard.setData(ClipboardData(text: _accessUrlText()));
              Toast.success('链接已复制');
            },
            child: const Text('复制链接'),
          ),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.share2),
            onPressed: (itemContext) {
              shadcn.closeOverlay(itemContext);
              SharePlus.instance.share(
                ShareParams(text: _accessUrlText(), subject: _currentTitle),
              );
            },
            child: const Text('分享链接'),
          ),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.camera),
            onPressed: (itemContext) {
              shadcn.closeOverlay(itemContext);
              unawaited(_captureBrowserLongScreenshot());
            },
            child: const Text('长截图'),
          ),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.externalLink),
            onPressed: (itemContext) {
              shadcn.closeOverlay(itemContext);
              unawaited(_openCurrentUrlExternally());
            },
            child: const Text('浏览器打开'),
          ),
          if (kDebugMode)
            shadcn.MenuButton(
              leading: const Icon(shadcn.LucideIcons.squareTerminal),
              onPressed: (itemContext) {
                shadcn.closeOverlay(itemContext);
                unawaited(_openWebViewDevTools());
              },
              child: const Text('开发者工具'),
            ),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.clipboardList),
            onPressed: (itemContext) {
              shadcn.closeOverlay(itemContext);
              unawaited(_copyBrowserStorageClipboardJson());
            },
            child: const Text('复制授权信息'),
          ),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.shieldCheck),
            onPressed: (itemContext) {
              shadcn.closeOverlay(itemContext);
              unawaited(_copyBrowserAuthDiagnostics());
            },
            child: const Text('授权诊断'),
          ),
          const shadcn.MenuDivider(),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.cloudDownload),
            enabled: canExtractCookie,
            onPressed: canExtractCookie
                ? (itemContext) {
                    shadcn.closeOverlay(itemContext);
                    unawaited(_extractAndSyncCookie());
                  }
                : null,
            child: const Text('同步Cookie'),
          ),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.cookie),
            onPressed: (itemContext) {
              shadcn.closeOverlay(itemContext);
              unawaited(_clearCurrentSiteCookies());
            },
            child: const Text('清理Cookie'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCurrentUrlExternally() async {
    final uri = Uri.tryParse(_accessUrlText());
    if (uri == null || !uri.hasScheme) {
      Toast.warning('当前链接无效');
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) Toast.warning('无法打开系统浏览器');
  }

  Future<void> _openWebViewDevTools() async {
    if (!kDebugMode) return;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final controller = _controller;
      if (controller == null || _closing) {
        Toast.warning('页面尚未加载完成');
        return;
      }
      try {
        await controller.openDevTools();
        Toast.success('开发者工具已打开');
      } catch (e, st) {
        AppLogger.warn('打开 WebView 开发者工具失败: $e\n$st');
        Toast.warning('开发者工具打开失败');
      }
      return;
    }

    final tip = _webViewDevToolsTip();
    try {
      await Clipboard.setData(ClipboardData(text: tip));
      Toast.info('调试入口已复制');
    } catch (_) {
      Toast.info(tip);
    }
  }

  Future<void> _copyBrowserAuthDiagnostics() async {
    final controller = _controller;
    if (controller == null || _closing) {
      Toast.warning('页面尚未加载完成');
      return;
    }

    final injectedCount = await _injectConfiguredLocalStorage(
      controller,
      _currentUrl,
    );
    final cookie = await _cookieHeaderFor(_currentUrl);
    final localStorage = await _localStorageRawSnapshotFor(_currentUrl);
    final filteredLocalStorage = await _localStorageSnapshotFor(_currentUrl);
    final data = <String, Object?>{
      'current_url': _currentUrl,
      'initial_url': widget.url,
      'configured_localstorage_length': widget.localStorage?.trim().length ?? 0,
      'configured_localstorage': widget.localStorage?.trim() ?? '',
      'injected_localstorage_count': injectedCount,
      'cookie_length': cookie?.length ?? 0,
      'cookie': cookie ?? '',
      'localstorage_length': localStorage?.length ?? 0,
      'localstorage': localStorage ?? '',
      'filtered_localstorage_length': filteredLocalStorage?.length ?? 0,
      'filtered_localstorage': filteredLocalStorage ?? '',
    };

    try {
      await Clipboard.setData(
        ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)),
      );
      Toast.success('授权诊断已复制');
    } catch (e, st) {
      AppLogger.warn('复制授权诊断失败: $e\n$st');
      Toast.warning('授权诊断复制失败');
    }
  }

  String _webViewDevToolsTip() {
    if (kIsWeb) return '使用浏览器自带开发者工具查看当前页面';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        'Chrome 打开 chrome://inspect/#devices，选择当前 App WebView',
      TargetPlatform.iOS ||
      TargetPlatform.macOS => 'Safari 开启 Develop 菜单后选择当前 WebView',
      TargetPlatform.windows => 'Windows 可直接打开 WebView2 开发者工具',
      _ => '当前平台暂未提供内置 WebView 开发者工具入口',
    };
  }

  bool _shouldRetryInitialUrlAfterLocalStorageInjection(String currentUrl) {
    if (_retriedInitialUrlAfterLocalStorageInjection) return false;
    if (widget.localStorage?.trim().isNotEmpty != true) return false;

    final currentUri = Uri.tryParse(currentUrl.trim());
    final initialUri = Uri.tryParse(widget.url.trim());
    if (currentUri == null ||
        initialUri == null ||
        (currentUri.scheme != 'http' && currentUri.scheme != 'https') ||
        (initialUri.scheme != 'http' && initialUri.scheme != 'https')) {
      return false;
    }
    if (!_isConfiguredLocalStorageHost(currentUri.host)) return false;
    return _sameBrowserUrl(currentUri, initialUri) ||
        _looksLikeLoginUrl(currentUri);
  }

  bool _sameBrowserUrl(Uri a, Uri b) {
    String normalizedPath(Uri uri) {
      final path = uri.path.isEmpty ? '/' : uri.path;
      return path.endsWith('/') && path.length > 1
          ? path.substring(0, path.length - 1)
          : path;
    }

    return a.scheme == b.scheme &&
        a.host.toLowerCase() == b.host.toLowerCase() &&
        normalizedPath(a) == normalizedPath(b) &&
        a.query == b.query;
  }

  bool _looksLikeLoginUrl(Uri uri) {
    final text = '${uri.path}?${uri.query}#${uri.fragment}'.toLowerCase();
    return text.contains('login') ||
        text.contains('signin') ||
        text.contains('sign-in') ||
        text.contains('auth') ||
        text.contains('passport');
  }

  Future<void> _clearCurrentSiteCookies() async {
    final controller = _controller;
    if (controller == null || _closing) {
      Toast.warning('页面尚未加载完成');
      return;
    }

    final currentUrl = _currentUrl.trim();
    final uri = Uri.tryParse(currentUrl);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      Toast.warning('当前链接无效');
      return;
    }

    final origin = uri.origin;
    final webUri = WebUri(origin);
    final cookieManager = CookieManager.instance();

    try {
      final cookies = await cookieManager.getCookies(
        url: webUri,
        webViewController: controller,
      );

      var deletedAny = false;
      for (final cookie in cookies) {
        final name = cookie.name.trim();
        if (name.isEmpty) continue;

        final domain = cookie.domain?.trim();
        final path = cookie.path?.trim();
        final deleted = await cookieManager.deleteCookie(
          url: webUri,
          name: name,
          domain: domain != null && domain.isNotEmpty ? domain : null,
          path: path != null && path.isNotEmpty ? path : '/',
          webViewController: controller,
        );
        deletedAny = deletedAny || deleted;
      }

      final domainCandidates = <String?>{null, uri.host};
      if (!_isIpHost(uri.host)) {
        domainCandidates.add('.${uri.host}');
      }

      for (final domain in domainCandidates) {
        final deleted = await cookieManager.deleteCookies(
          url: webUri,
          domain: domain,
          webViewController: controller,
        );
        deletedAny = deletedAny || deleted;
      }

      await _clearCurrentSiteBrowserStorage(controller);

      if (mounted && !_closing) {
        setState(() {
          _hasReadableCookie = false;
          _hasReadableLocalStorage = false;
        });
      }

      AppLogger.info(
        '已清理内置浏览器当前站点 Cookie: origin=$origin, count=${cookies.length}, deleted=$deletedAny',
      );
      Toast.success('已清理当前站点 Cookie');
      try {
        await controller.loadUrl(
          urlRequest: URLRequest(url: WebUri(currentUrl)),
        );
      } catch (e, st) {
        AppLogger.warn('清理 Cookie 后刷新当前页面失败: $e\n$st');
        if (mounted && !_closing) Toast.warning('Cookie 已清理，刷新页面失败');
      }
    } catch (e, st) {
      AppLogger.error('清理内置浏览器当前站点 Cookie 失败', e, st);
      if (mounted && !_closing) Toast.error('清理 Cookie 失败');
    }
  }

  Future<void> _clearCurrentSiteBrowserStorage(
    InAppWebViewController controller,
  ) async {
    try {
      await controller.evaluateJavascript(
        source:
            '''
(() => {
  const marker = ${jsonEncode(_localStorageInjectedKey)};
  try { window.localStorage.clear(); } catch (_) {}
  try { window.sessionStorage.clear(); } catch (_) {}
  try { window.sessionStorage.setItem(marker, 'cleared'); } catch (_) {}
})();
''',
      );
    } catch (e, st) {
      AppLogger.warn('清理当前页面本地存储失败: $e\n$st');
    }
  }

  bool _isIpHost(String host) {
    return RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host) ||
        host.contains(':');
  }

  Future<void> _captureBrowserLongScreenshot() async {
    final controller = _controller;
    if (controller == null || _closing) {
      Toast.warning('页面尚未加载完成');
      return;
    }

    Toast.info('正在生成长截图');
    try {
      final bytes = await _captureWebViewLongScreenshot(controller);
      if (bytes == null || bytes.isEmpty) {
        Toast.warning('截图失败');
        return;
      }
      await ScreenshotSaver.saveAndShare(bytes);
    } catch (e, st) {
      AppLogger.error('内置浏览器长截图失败', e, st);
      Toast.error('截图失败: $e');
    }
  }

  Future<Uint8List?> _captureWebViewLongScreenshot(
    InAppWebViewController controller,
  ) async {
    final metrics = await _readWebViewMetrics(controller);
    final viewportHeight = parseDouble(metrics['viewportHeight']);
    final contentHeight = parseDouble(metrics['contentHeight']);
    final originalY = parseDouble(metrics['scrollY']);
    if (viewportHeight <= 0 || contentHeight <= 0) {
      return controller.takeScreenshot();
    }

    final maxScroll = contentHeight > viewportHeight
        ? contentHeight - viewportHeight
        : 0.0;
    final offsets = <double>[0];
    if (maxScroll > 0) {
      final step = viewportHeight * 0.85;
      var next = 0.0;
      while (next < maxScroll) {
        next = (next + step).clamp(0.0, maxScroll);
        if (offsets.isNotEmpty && (offsets.last - next).abs() < 1) break;
        offsets.add(next);
      }
      if ((offsets.last - maxScroll).abs() > 1) offsets.add(maxScroll);
    }

    final pieces = <_BrowserScreenshotPiece>[];
    double? scale;
    for (final offset in offsets) {
      await controller.evaluateJavascript(
        source: 'window.scrollTo(0, ${offset.round()});',
      );
      await Future.delayed(const Duration(milliseconds: 320));
      final bytes = await controller.takeScreenshot();
      if (bytes == null || bytes.isEmpty) continue;
      final image = await _decodeImage(bytes);
      scale ??= image.height / viewportHeight;
      pieces.add(_BrowserScreenshotPiece(image: image, offset: offset));
    }

    await controller.evaluateJavascript(
      source: 'window.scrollTo(0, ${originalY.round()});',
    );

    if (pieces.isEmpty) return controller.takeScreenshot();
    return _stitchBrowserScreenshots(
      pieces: pieces,
      contentHeight: contentHeight,
      scale: scale ?? 1,
    );
  }

  Future<Map<String, dynamic>> _readWebViewMetrics(
    InAppWebViewController controller,
  ) async {
    final raw = await controller.evaluateJavascript(
      source: '''
JSON.stringify({
  scrollY: window.scrollY || document.documentElement.scrollTop || document.body.scrollTop || 0,
  viewportHeight: window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight || 0,
  contentHeight: Math.max(
    document.body ? document.body.scrollHeight : 0,
    document.documentElement ? document.documentElement.scrollHeight : 0,
    document.body ? document.body.offsetHeight : 0,
    document.documentElement ? document.documentElement.offsetHeight : 0
  )
})
''',
    );
    final data = raw is String ? jsonDecode(raw) : raw;
    return data is Map
        ? Map<String, dynamic>.from(data)
        : const <String, dynamic>{};
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<Uint8List?> _stitchBrowserScreenshots({
    required List<_BrowserScreenshotPiece> pieces,
    required double contentHeight,
    required double scale,
  }) async {
    final width = pieces.first.image.width;
    final totalHeight = (contentHeight * scale).round().clamp(1, 60000);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (final piece in pieces) {
      final image = piece.image;
      final dstY = (piece.offset * scale).round();
      final remaining = totalHeight - dstY;
      if (remaining <= 0) continue;
      final srcHeight = remaining < image.height ? remaining : image.height;
      final src = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        srcHeight.toDouble(),
      );
      final dst = Rect.fromLTWH(
        0,
        dstY.toDouble(),
        width.toDouble(),
        srcHeight.toDouble(),
      );
      canvas.drawImageRect(image, src, dst, Paint());
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, totalHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Widget _bottomBtn(
    shadcn.ColorScheme cs,
    IconData icon,
    String label,
    bool enabled,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: enabled
                  ? cs.foreground.withValues(alpha: 0.7)
                  : cs.foreground.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: enabled
                    ? cs.foreground.withValues(alpha: 0.5)
                    : cs.foreground.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────── WebView ──────────────────

  Widget _buildWebView() {
    final localStorageBootstrap = _configuredLocalStorageBootstrapInitialData();
    return InAppWebView(
      initialUrlRequest: localStorageBootstrap == null
          ? URLRequest(url: WebUri(widget.url))
          : null,
      initialData: localStorageBootstrap,
      initialUserScripts: _configuredLocalStorageUserScripts(),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        thirdPartyCookiesEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        sharedCookiesEnabled: true,
        cacheEnabled: true,
        userAgent: _activeUserAgent,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        useHybridComposition: true,
        allowsInlineMediaPlayback: true,
        supportMultipleWindows: true,
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,
        transparentBackground: true,
        useOnDownloadStart: true,
        isInspectable: kDebugMode,
      ),
      onWebViewCreated: (controller) {
        if (_closing) {
          unawaited(_stopLoadingSafely(controller));
          return;
        }
        _controller = controller;
        unawaited(_refreshReadableCookieState(widget.url));
      },
      onLoadStart: (controller, url) {
        if (!mounted || _closing) return;
        final urlText = url?.toString() ?? '';
        if (_isTorrentUrl(urlText)) {
          unawaited(controller.stopLoading());
          _showTorrentDownloadFlow(urlText, restoreUrl: _lastLoadedPageUrl);
          return;
        }
        setState(() {
          _currentUrl = urlText;
          _isLoading = true;
          _error = null;
        });
      },
      onLoadStop: (controller, url) async {
        if (!mounted || _closing) return;
        final urlText = url?.toString() ?? '';
        setState(() {
          _currentUrl = urlText;
          if (_isLoadedPageUrl(urlText)) {
            _lastLoadedPageUrl = urlText;
          }
          _isLoading = false;
        });
        final injectedLocalStorageCount = await _injectConfiguredLocalStorage(
          controller,
          urlText,
        );
        unawaited(_refreshReadableLocalStorageState(urlText));
        if (injectedLocalStorageCount > 0 &&
            _shouldRetryInitialUrlAfterLocalStorageInjection(urlText)) {
          _retriedInitialUrlAfterLocalStorageInjection = true;
          AppLogger.info(
            'localStorage 已写入登录页，重新打开初始地址: from=$urlText, to=${widget.url}',
          );
          await controller.loadUrl(
            urlRequest: URLRequest(url: WebUri(widget.url)),
          );
          return;
        }
        unawaited(_refreshReadableCookieState(url?.toString()));
        _updateNavState();
        final title = await controller.getTitle();
        if (title != null && title.isNotEmpty && mounted && !_closing) {
          setState(() => _currentTitle = title);
        }
      },
      onProgressChanged: (controller, progress) {
        if (!mounted || _closing) return;
        setState(() => _progress = progress / 100.0);
      },
      onReceivedError: (controller, request, error) {
        if (!mounted || _closing) return;
        setState(() {
          _error = '${error.type}: ${error.description}';
          _isLoading = false;
        });
      },
      onDownloadStartRequest: (controller, request) async {
        if (_closing) return;
        final url = request.url.toString();
        if (_isTorrentDownloadRequest(
          url: url,
          mimeType: request.mimeType,
          contentDisposition: request.contentDisposition,
          suggestedFilename: request.suggestedFilename,
        )) {
          await controller.stopLoading();
          _showTorrentDownloadFlow(url, restoreUrl: _lastLoadedPageUrl);
        }
      },
      shouldOverrideUrlLoading: (controller, action) async {
        if (_closing) return NavigationActionPolicy.CANCEL;
        final url = action.request.url?.toString() ?? '';
        if (_isTorrentUrl(url)) {
          _showTorrentDownloadFlow(url, restoreUrl: _lastLoadedPageUrl);
          return NavigationActionPolicy.CANCEL;
        }
        if (url.startsWith('http://') || url.startsWith('https://')) {
          return NavigationActionPolicy.ALLOW;
        }
        return NavigationActionPolicy.CANCEL;
      },
      onCreateWindow: (controller, action) async {
        if (_closing) return false;
        final url = action.request.url?.toString() ?? '';
        if (url.isEmpty) return false;
        if (_isTorrentUrl(url)) {
          _showTorrentDownloadFlow(url, restoreUrl: _lastLoadedPageUrl);
          return true;
        }
        if (url.startsWith('http://') || url.startsWith('https://')) {
          await controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
          return true;
        }
        return false;
      },
    );
  }

  List<_UserAgentPreset> get _userAgentPresets {
    final configuredUserAgent = widget.userAgent?.trim();
    return [
      if (configuredUserAgent != null && configuredUserAgent.isNotEmpty)
        _UserAgentPreset(
          id: 'site',
          label: '站点配置',
          description: configuredUserAgent,
          userAgent: configuredUserAgent,
        ),
      const _UserAgentPreset(
        id: 'safari_macos',
        label: 'Safari macOS',
        description: 'macOS Safari Desktop',
        userAgent: _safariMacosUserAgent,
      ),
      const _UserAgentPreset(
        id: 'safari_iphone',
        label: 'Safari iPhone',
        description: 'iOS Safari Mobile',
        userAgent: _safariIphoneUserAgent,
      ),
      _UserAgentPreset(
        id: 'default',
        label: '默认 WebView',
        description: _defaultUserAgent ?? 'flutter_inappwebview 默认 UA',
        userAgent: _defaultUserAgent,
      ),
    ];
  }

  List<_UserAgentPreset> get _fallbackUserAgentPresets => const [
    _UserAgentPreset(
      id: 'chrome_android',
      label: 'Chrome Android',
      description: 'Android Chrome Mobile',
      userAgent:
          'Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
    ),
    _UserAgentPreset(
      id: 'chrome_windows',
      label: 'Chrome Windows',
      description: 'Windows Chrome Desktop',
      userAgent:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    ),
    _UserAgentPreset(
      id: 'edge_windows',
      label: 'Edge Windows',
      description: 'Windows Microsoft Edge',
      userAgent:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0',
    ),
    _UserAgentPreset(
      id: 'firefox_windows',
      label: 'Firefox Windows',
      description: 'Windows Firefox Desktop',
      userAgent:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:125.0) Gecko/20100101 Firefox/125.0',
    ),
  ];

  Future<void> _showUserAgentPicker() async {
    if (_defaultUserAgent == null) await _loadDefaultUserAgent();
    if (!mounted) return;

    final cs = shadcn.Theme.of(context).colorScheme;
    await showAppSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.background,
      builder: (context) {
        var fallbackExpanded = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final presets = _userAgentPresets;
            final fallbackPresets = _fallbackUserAgentPresets;

            Widget presetTile(_UserAgentPreset preset) {
              final selected = preset.id == _activeUserAgentId;
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Icon(
                  selected
                      ? shadcn.LucideIcons.check
                      : shadcn.LucideIcons.globe,
                  size: 18,
                  color: selected
                      ? cs.primary
                      : cs.foreground.withValues(alpha: 0.62),
                ),
                title: Text(
                  preset.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: cs.foreground,
                  ),
                ),
                subtitle: Text(
                  preset.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.foreground.withValues(alpha: 0.56),
                  ),
                ),
                onTap: () async {
                  closeAppSheet(context);
                  await _applyUserAgentPreset(preset);
                },
              );
            }

            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                children: [
                  for (final preset in presets) ...[
                    presetTile(preset),
                    Divider(height: 1, color: cs.border),
                  ],
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Icon(
                      fallbackExpanded
                          ? shadcn.LucideIcons.chevronDown
                          : shadcn.LucideIcons.chevronRight,
                      size: 18,
                      color: cs.foreground.withValues(alpha: 0.62),
                    ),
                    title: Text(
                      '备选 UA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.foreground,
                      ),
                    ),
                    subtitle: Text(
                      'Chrome / Edge / Firefox',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.foreground.withValues(alpha: 0.56),
                      ),
                    ),
                    onTap: () {
                      setSheetState(() {
                        fallbackExpanded = !fallbackExpanded;
                      });
                    },
                  ),
                  if (fallbackExpanded)
                    for (final preset in fallbackPresets) ...[
                      Divider(height: 1, color: cs.border),
                      presetTile(preset),
                    ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _applyUserAgentPreset(_UserAgentPreset preset) async {
    _activeUserAgentId = preset.id;
    _activeUserAgent = preset.userAgent;
    if (mounted) setState(() {});

    try {
      await _controller?.setSettings(
        settings: InAppWebViewSettings(userAgent: _activeUserAgent),
      );
      await _controller?.reload();
      Toast.success('已切换 UA：${preset.label}');
    } catch (e, st) {
      AppLogger.error('切换 UA 失败', e, st);
      Toast.error('切换 UA 失败');
    }
  }

  // ────────────────── 工具栏 ──────────────────

  WebSite? _websiteConfigForCurrentSite() {
    final specifiedWebsite = widget.website;
    if (specifiedWebsite != null) return specifiedWebsite;
    final siteId = widget.siteId?.trim();
    final currentUrl = _currentUrl.trim();
    if ((siteId == null || siteId.isEmpty) && currentUrl.isEmpty) return null;

    final siteKey = siteId?.toLowerCase() ?? '';
    final currentHost = _uriHost(currentUrl);

    for (final config in _websiteConfigs) {
      if (config.name.toLowerCase() == siteKey ||
          config.nickname.toLowerCase() == siteKey) {
        return config;
      }
    }

    if (currentHost == null) return null;
    for (final config in _websiteConfigs) {
      for (final url in config.url) {
        if (_uriHost(url) == currentHost) return config;
      }
    }
    return null;
  }

  WebSite? _currentTorrentWebsiteConfig() {
    final currentUrl = _currentUrl.trim();
    if (currentUrl.isEmpty || !mounted) {
      return null;
    }
    final website = _websiteConfigForCurrentSite();
    if (website == null) return null;
    if (website.pageTorrents.trim().isEmpty ||
        website.torrentsRule.trim().isEmpty) {
      return null;
    }
    return _matchesWebsitePage(currentUrl, website.pageTorrents)
        ? website
        : null;
  }

  WebSite? _currentDetailWebsiteConfig() {
    final currentUrl = _currentUrl.trim();
    if (currentUrl.isEmpty || !mounted) {
      return null;
    }
    final website = _websiteConfigForCurrentSite();
    if (website == null) return null;
    if (website.pageDetail.trim().isEmpty) return null;
    if (website.detailDownloadUrlRule.trim().isEmpty &&
        website.detailTitleRule.trim().isEmpty) {
      return null;
    }
    return _matchesWebsitePage(currentUrl, website.pageDetail) ? website : null;
  }

  WebSite? _currentUserWebsiteConfig() {
    final currentUrl = _currentUrl.trim();
    if (currentUrl.isEmpty || !mounted) return null;
    final website = _websiteConfigForCurrentSite();
    if (website == null) return null;
    if (!_hasUserProfileRules(website)) return null;
    final pageUser = website.pageUser.trim();
    final pageControlPanel = website.pageControlPanel.trim();
    final matchesUser =
        pageUser.isNotEmpty && _matchesWebsitePage(currentUrl, pageUser);
    final matchesControlPanel =
        pageControlPanel.isNotEmpty &&
        _matchesWebsitePage(currentUrl, pageControlPanel);
    return matchesUser || matchesControlPanel ? website : null;
  }

  WebSite? _currentBonusWebsiteConfig() {
    final currentUrl = _currentUrl.trim();
    if (currentUrl.isEmpty || !mounted) return null;
    final website = _websiteConfigForCurrentSite();
    if (website == null) return null;
    final pageMybonus = website.pageMybonus.trim();
    final buyPage = website.buyPage.trim();
    if (pageMybonus.isEmpty && buyPage.isEmpty) return null;
    if (pageMybonus.isNotEmpty && _matchesWebsitePage(currentUrl, pageMybonus)) return website;
    if (buyPage.isNotEmpty && _matchesWebsitePage(currentUrl, buyPage)) return website;
    return null;
  }

  bool _hasUserProfileRules(WebSite website) {
    return website.pageUser.contains('{}') ||
        _userProfileRuleSpecs(
          website,
        ).any((spec) => spec.rule.trim().isNotEmpty);
  }

  List<_BrowserUserProfileRule> _userProfileRuleSpecs(WebSite website) {
    return [
      _BrowserUserProfileRule('username', '用户名', '账号', website.myUsernameRule),
      _BrowserUserProfileRule('email', '邮箱', '账号', website.myEmailRule),
      _BrowserUserProfileRule('uid', 'UID', '账号', website.myUidRule),
      _BrowserUserProfileRule(
        'passkey',
        'Passkey',
        '账号',
        website.myPasskeyRule,
      ),
      _BrowserUserProfileRule(
        'time_join',
        '注册时间',
        '时间',
        website.myTimeJoinRule,
      ),
      _BrowserUserProfileRule(
        'latest_active',
        '最后活动',
        '时间',
        website.myLatestActiveRule,
      ),
      _BrowserUserProfileRule('level', '等级', '账号', website.myLevelRule),
      _BrowserUserProfileRule('uploaded', '上传量', '流量', website.myUploadedRule),
      _BrowserUserProfileRule(
        'downloaded',
        '下载量',
        '流量',
        website.myDownloadedRule,
      ),
      _BrowserUserProfileRule('ratio', '分享率', '账号', website.myRatioRule),
      _BrowserUserProfileRule('bonus', '魔力值', '魔力/积分', website.myBonusRule),
      _BrowserUserProfileRule(
        'bonus_hour',
        '时魔',
        '魔力/积分',
        website.myPerHourBonusRule,
      ),
      _BrowserUserProfileRule('score', '积分', '魔力/积分', website.myScoreRule),
      _BrowserUserProfileRule(
        'invitation',
        '邀请',
        '统计',
        website.myInvitationRule,
      ),
      _BrowserUserProfileRule('hr', 'HR', '统计', website.myHrRule),
      _BrowserUserProfileRule('leech', '下载中', '统计', website.myLeechRule),
      _BrowserUserProfileRule('publish', '发布数', '统计', website.myPublishRule),
      _BrowserUserProfileRule('seed', '做种数', '统计', website.mySeedRule),
      _BrowserUserProfileRule(
        'seed_volume',
        '做种量',
        '统计',
        website.mySeedVolRule,
      ),
    ];
  }

  _BrowserUserProfileDisplay _userProfileDisplay(String key) {
    return switch (key) {
      'username' => const _BrowserUserProfileDisplay(
        Icons.person_outline,
        Color(0xFF2563EB),
      ),
      'email' => const _BrowserUserProfileDisplay(
        Icons.alternate_email,
        Color(0xFF0EA5E9),
      ),
      'uid' => const _BrowserUserProfileDisplay(
        Icons.badge_outlined,
        Color(0xFF64748B),
      ),
      'passkey' => const _BrowserUserProfileDisplay(
        Icons.key_outlined,
        Color(0xFF64748B),
      ),
      'time_join' => const _BrowserUserProfileDisplay(
        Icons.event_available_outlined,
        Color(0xFF14B8A6),
      ),
      'latest_active' => const _BrowserUserProfileDisplay(
        Icons.schedule_outlined,
        Color(0xFF06B6D4),
      ),
      'level' => const _BrowserUserProfileDisplay(
        Icons.workspace_premium_outlined,
        Color(0xFFF59E0B),
      ),
      'uploaded' => const _BrowserUserProfileDisplay(
        Icons.cloud_upload_outlined,
        Color(0xFF10B981),
      ),
      'downloaded' => const _BrowserUserProfileDisplay(
        Icons.cloud_download_outlined,
        Color(0xFFEF4444),
      ),
      'ratio' => const _BrowserUserProfileDisplay(
        Icons.balance_outlined,
        Color(0xFF8B5CF6),
      ),
      'bonus' => const _BrowserUserProfileDisplay(
        Icons.diamond_outlined,
        Color(0xFFF59E0B),
      ),
      'bonus_hour' => const _BrowserUserProfileDisplay(
        Icons.bolt_outlined,
        Color(0xFFF97316),
      ),
      'score' => const _BrowserUserProfileDisplay(
        Icons.star_border_outlined,
        Color(0xFFEAB308),
      ),
      'invitation' => const _BrowserUserProfileDisplay(
        Icons.group_add_outlined,
        Color(0xFF8B5CF6),
      ),
      'hr' => const _BrowserUserProfileDisplay(
        Icons.warning_amber_outlined,
        Color(0xFFEF4444),
      ),
      'leech' => const _BrowserUserProfileDisplay(
        Icons.arrow_downward,
        Color(0xFFF97316),
      ),
      'publish' => const _BrowserUserProfileDisplay(
        Icons.rocket_launch_outlined,
        Color(0xFF6366F1),
      ),
      'seed' => const _BrowserUserProfileDisplay(
        Icons.grass_outlined,
        Color(0xFF10B981),
      ),
      'seed_volume' => const _BrowserUserProfileDisplay(
        Icons.storage_outlined,
        Color(0xFF0EA5E9),
      ),
      _ => const _BrowserUserProfileDisplay(
        Icons.info_outline,
        Color(0xFF64748B),
      ),
    };
  }

  bool _matchesWebsitePage(String currentUrl, String pageRule) {
    final current = Uri.tryParse(currentUrl);
    if (current == null || !current.hasScheme) return false;

    final rawRule = pageRule.trim();
    if (rawRule.contains('{}')) {
      const marker = '__HARVEST_PAGE_MARKER__';
      final target = _resolveWebsitePageUri(
        current,
        rawRule.replaceAll('{}', marker),
      );
      if (target == null || !target.toString().contains(marker)) return false;

      if (target.queryParameters.containsValue(marker)) {
        if (current.scheme != target.scheme ||
            current.host != target.host ||
            current.port != target.port ||
            _normalizePath(current.path) != _normalizePath(target.path)) {
          return false;
        }
        for (final entry in target.queryParameters.entries) {
          if (entry.value == marker) {
            final value = current.queryParameters[entry.key]?.trim();
            return value != null && value.isNotEmpty;
          }
        }
      }

      final escaped = RegExp.escape(
        target.toString(),
      ).replaceAll(RegExp.escape(marker), r'([^/?#&]+)');
      return RegExp('^$escaped(?:[?#&].*)?\$').hasMatch(current.toString());
    }

    final target = _resolveWebsitePageUri(current, pageRule);
    if (target == null) return false;
    final currentPath = _normalizePath(current.path);
    final targetPath = _normalizePath(target.path);
    return targetPath.isNotEmpty &&
        (currentPath == targetPath || currentPath.startsWith('$targetPath/'));
  }

  Uri? _resolveWebsitePageUri(Uri current, String pageRule) {
    final value = pageRule.trim().replaceAll('{}', '');
    if (value.isEmpty) return null;
    final absolute = Uri.tryParse(value);
    if (absolute != null && absolute.hasScheme) return absolute;
    final origin = Uri(
      scheme: current.scheme,
      host: current.host,
      port: current.hasPort ? current.port : null,
      path: '/',
    );
    return origin.resolve(value);
  }

  /// 解析页面 URL，支持 {} 占位符替换为 userId
  String? _resolvePageUrl(String pageRule, String? userId) {
    AppLogger.info('Resolve page URL: $pageRule, userId: $userId');

    final rule = pageRule.trim();
    if (rule.isEmpty) return null;

    // 如果规则中包含 {}，则替换为 userId
    if (rule.contains('{}')) {
      if (userId == null || userId.isEmpty) return null;
      return rule.replaceAll('{}', userId);
    }

    // 否则直接返回规则
    return rule;
  }

  String? _uriHost(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return uri.host.toLowerCase();
  }

  String _normalizePath(String path) {
    final normalized = path.trim().isEmpty ? '/' : path.trim();
    if (normalized.length > 1 && normalized.endsWith('/')) {
      return normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  Future<void> _extractTorrentList(WebSite website) async {
    final controller = _controller;
    if (controller == null || _closing || !mounted) return;

    setState(() => _extractingTorrentList = true);
    try {
      final raw = await controller.evaluateJavascript(
        source: _buildTorrentExtractScript(website),
      );
      if (!mounted || _closing) return;
      final items = _parseExtractedTorrents(raw);
      if (items.isEmpty) {
        Toast.warning('未提取到种子列表');
        return;
      }
      await _showExtractedTorrentDialog(items);
      await _restoreBrowserAfterTorrentExtraction();
    } catch (e, st) {
      AppLogger.error('提取种子列表失败', e, st);
      if (mounted) Toast.error('提取种子列表失败');
    } finally {
      if (mounted) setState(() => _extractingTorrentList = false);
    }
  }

  Future<void> _extractSingleTorrentDetail(WebSite website) async {
    final controller = _controller;
    if (controller == null || _closing || !mounted) return;

    setState(() => _extractingTorrentList = true);
    try {
      final raw = await controller.evaluateJavascript(
        source: _buildTorrentDetailExtractScript(website),
      );
      if (!mounted || _closing) return;
      final item = _parseExtractedTorrentDetail(raw);
      if (item == null) {
        Toast.warning('未提取到种子详情');
        return;
      }
      await _showDownloaderSelectAndPush([item]);
      await _restoreBrowserAfterTorrentExtraction();
    } catch (e, st) {
      AppLogger.error('提取种子详情失败', e, st);
      if (mounted) Toast.error('提取种子详情失败');
    } finally {
      if (mounted) setState(() => _extractingTorrentList = false);
    }
  }

  Future<void> _restoreBrowserAfterTorrentExtraction() async {
    final controller = _controller;
    if (controller == null || _closing || !mounted) return;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (_closing || !mounted) return;
      await controller.reload();
    } catch (e, st) {
      AppLogger.warn('恢复内置浏览器页面交互失败: $e\n$st');
    }
  }

  Future<void> _extractUserProfile(WebSite website) async {
    final controller = _controller;
    if (controller == null || _closing || !mounted) return;

    setState(() => _extractingUserProfile = true);
    try {
      final raw = await controller.evaluateJavascript(
        source: _buildUserProfileExtractScript(website),
      );
      if (!mounted || _closing) return;
      final items = _parseExtractedUserProfile(raw);
      if (items.isEmpty) {
        Toast.warning('未提取到用户页信息');
        return;
      }

      // 从 WebView 中提取当前最新的 Cookie，确保使用的是有效的登录状态
      final cookie = await _cookieHeaderFor(_currentUrl);
      await _showUserProfileDialog(items, website, extractedCookie: cookie);
    } catch (e, st) {
      AppLogger.error('提取用户页信息失败', e, st);
      if (mounted) Toast.error('提取用户页信息失败');
    } finally {
      if (mounted) setState(() => _extractingUserProfile = false);
    }
  }

  String _buildUserProfileExtractScript(WebSite website) {
    final specs = _userProfileRuleSpecs(website)
        .where(
          (spec) =>
              spec.rule.trim().isNotEmpty ||
              (spec.key == 'uid' && website.pageUser.contains('{}')),
        )
        .map(
          (spec) => {
            'key': spec.key,
            'label': spec.label,
            'group': spec.group,
            'rule': spec.rule,
          },
        )
        .toList();
    return '''
(() => {
  const specs = ${jsonEncode(specs)};
  const pageUserRule = ${jsonEncode(website.pageUser)};

  const ruleVariants = (rule) => {
    const raw = (rule || '').trim();
    if (!raw) return [];
    const values = new Set();
    const push = (value) => {
      const text = (value || '').trim();
      if (text) values.add(text);
    };
    const removeTbody = (value) => value.replace(/\\/tbody(?=\\/|\$)/gi, '');
    const addTbody = (value) => value.replace(
      /(\\/table(?:\\[[^\\]]+\\])?)(?=\\/tr(?:\\[[^\\]]+\\])?(?:\\/|\$))/gi,
      '\$1/tbody',
    );
    push(raw);
    push(removeTbody(raw));
    push(addTbody(raw));
    push(addTbody(removeTbody(raw)));
    return Array.from(values);
  };

  const cleanText = (value) => (value || '')
    .replace(/\\u00a0/g, ' ')
    .replace(/\\s+/g, ' ')
    .trim();

  const escapeRegExp = (value) => {
    let escaped = value;
    for (const ch of ['\\\\', '^', '\$', '.', '|', '?', '*', '+', '(', ')', '[', ']', '{', '}']) {
      escaped = escaped.split(ch).join('\\\\' + ch);
    }
    return escaped;
  };

  const toAbsoluteUrl = (value) => {
    const text = cleanText(value);
    if (!text) return '';
    try {
      return new URL(text, window.location.origin + '/').href;
    } catch (_) {
      return '';
    }
  };

  const normalizePath = (value) => {
    const path = value || '/';
    return path.length > 1 && path.endsWith('/') ? path.slice(0, -1) : path;
  };

  const extractUserIdFromPageUser = (sourceValue) => {
    const rule = cleanText(pageUserRule);
    if (!rule.includes('{}')) return '';
    const source = cleanText(sourceValue);
    const candidates = [];
    const pushCandidate = (value) => {
      const text = cleanText(value);
      if (text && !candidates.includes(text)) candidates.push(text);
    };
    pushCandidate(source);
    pushCandidate(window.location.href);
    for (const anchor of Array.from(document.querySelectorAll('a[href]'))) {
      pushCandidate(anchor.getAttribute('href') || '');
      pushCandidate(anchor.href || '');
    }

    const marker = '__HARVEST_USER_ID__';
    const target = toAbsoluteUrl(rule.split('{}').join(marker));
    if (!target || !target.includes(marker)) return '';

    for (const candidate of candidates) {
      if (/^\\d+\$/.test(candidate)) return candidate;
      const current = toAbsoluteUrl(candidate);
      if (!current) continue;

      try {
        const targetUrl = new URL(target);
        const currentUrl = new URL(current);
        for (const [key, value] of targetUrl.searchParams.entries()) {
          if (value === marker) {
            if (targetUrl.origin !== currentUrl.origin ||
                normalizePath(targetUrl.pathname) !== normalizePath(currentUrl.pathname)) {
              continue;
            }
            const uid = cleanText(currentUrl.searchParams.get(key) || '');
            if (uid) return decodeURIComponent(uid);
          }
        }
      } catch (_) {}

      const pattern = new RegExp(
        '^' + escapeRegExp(target).replace(escapeRegExp(marker), '([^/?#&]+)') + '(?:[?#&].*)?\$',
      );
      const match = current.match(pattern);
      if (match && match[1]) return decodeURIComponent(match[1]);
    }
    return '';
  };

  const readNodeValue = (node, key) => {
    if (!node) return '';
    if (node.nodeType === Node.ATTRIBUTE_NODE || node.nodeType === Node.TEXT_NODE || node.nodeType === Node.CDATA_SECTION_NODE) {
      return cleanText(node.nodeValue || '');
    }
    if (node instanceof HTMLAnchorElement) {
      if (key === 'uid') {
        return cleanText(node.getAttribute('href') || node.href || node.textContent || '');
      }
      return cleanText(node.textContent || node.getAttribute('href') || node.href || '');
    }
    if (node instanceof HTMLImageElement) {
      return cleanText(node.getAttribute('alt') || node.getAttribute('title') || node.getAttribute('src') || node.src || '');
    }
    return cleanText(node.textContent || '');
  };

  const evaluateNodes = (contextNode, rule) => {
    if (!rule) return [];
    for (const candidate of ruleVariants(rule)) {
      try {
        const result = document.evaluate(candidate, contextNode, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
        const nodes = [];
        for (let i = 0; i < result.snapshotLength; i += 1) {
          nodes.push(result.snapshotItem(i));
        }
        if (nodes.length) return nodes;
      } catch (_) {}
    }
    return [];
  };

  const evaluateValue = (contextNode, rule, key) => {
    if (!rule) return '';
    for (const candidate of ruleVariants(rule)) {
      try {
        const result = document.evaluate(candidate, contextNode, null, XPathResult.ANY_TYPE, null);
        switch (result.resultType) {
          case XPathResult.STRING_TYPE: {
            const value = cleanText(result.stringValue || '');
            if (value) return value;
            break;
          }
          case XPathResult.NUMBER_TYPE:
            if (Number.isFinite(result.numberValue)) return String(result.numberValue);
            break;
          case XPathResult.BOOLEAN_TYPE:
            if (result.booleanValue) return 'true';
            break;
          default: {
            const node = result.singleNodeValue || result.iterateNext?.();
            const value = readNodeValue(node, key);
            if (value) return value;
            break;
          }
        }
      } catch (_) {}
    }
    const nodes = evaluateNodes(contextNode, rule);
    if (!nodes.length) return '';
    return nodes.map((node) => readNodeValue(node, key)).filter(Boolean).join(' ').replace(/\\s+/g, ' ').trim();
  };

  return specs
    .map((spec) => {
      const value = evaluateValue(document, spec.rule, spec.key);
      return {
        key: spec.key,
        label: spec.label,
        group: spec.group,
        value: spec.key === 'uid' ? extractUserIdFromPageUser(value) : value,
      };
    });
})()
''';
  }

  List<_BrowserUserProfileMetric> _parseExtractedUserProfile(dynamic raw) {
    dynamic data = raw;
    if (raw is String) {
      try {
        data = jsonDecode(raw);
      } catch (_) {
        data = const [];
      }
    }
    if (data is! List) return const [];
    return data
        .whereType<Object?>()
        .map((item) {
          if (item is! Map) return null;
          final map = Map<String, dynamic>.from(item);
          final key = map['key']?.toString() ?? '';
          final extractedValue = map['value']?.toString().trim() ?? '';
          return _BrowserUserProfileMetric(
            key: key,
            label: map['label']?.toString() ?? '',
            group: map['group']?.toString() ?? '',
            rawValue: extractedValue,
            value: _formatUserProfileValue(key, extractedValue),
          );
        })
        .whereType<_BrowserUserProfileMetric>()
        .where((item) => item.value != '-')
        .toList();
  }

  String _formatUserProfileValue(String key, String rawValue) {
    final value = rawValue
        .replaceAll('\u00a0', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (_isUserProfilePlaceholder(value)) return '-';
    if (key == 'uid') return value.isEmpty ? '-' : value;
    if (key == 'passkey') return maskKey(value);
    if (key == 'email') return _extractEmailFromText(value);

    if (key == 'time_join' || key == 'latest_active') {
      return formatFlexibleLocalDateTimeString(value);
    }
    if (key == 'level') return _formatUserProfileLevel(value);
    if (key == 'uploaded' || key == 'downloaded' || key == 'seed_volume') {
      return _formatUserProfileBytes(value);
    }
    if (key == 'bonus' || key == 'bonus_hour' || key == 'score') {
      return _formatUserProfileNumber(value);
    }
    if (key == 'publish') return _formatUserProfileInteger(value);
    if (key == 'invitation') return _formatUserProfileInvitation(value);
    return value;
  }

  bool _isUserProfilePlaceholder(String value) {
    final text = value.trim().toLowerCase();
    return text.isEmpty ||
        text == '-' ||
        text == '--' ||
        text == '---' ||
        text == '—' ||
        text == 'n/a' ||
        text == 'null' ||
        text == 'none' ||
        text == '暂无' ||
        text == '无';
  }

  String _formatUserProfileLevel(String value) {
    final text = value.trim();
    if (text.isEmpty) return '-';
    final level = text.replaceAll(RegExp(r'_Name\b'), '').trim();
    return _isUserProfilePlaceholder(level) ? '-' : level;
  }

  String? _normalizedUserProfileDateTime(String? value) {
    if (value == null || _isUserProfilePlaceholder(value)) return null;
    final normalized = formatFlexibleLocalDateTimeString(value, empty: '');
    return normalized.isEmpty ? null : normalized;
  }

  String _formatUserProfileBytes(String value) {
    final match = RegExp(
      r'(\d[\d,]*(?:\.\d+)?|\d+(?:[.,]\d+)?)\s*(B|KB|MB|GB|TB|PB)\b',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) return '-';
    final number = _normalizeUserProfileNumberText(match.group(1)!);
    final unit = match.group(2)!.toUpperCase();
    final bytes = parseSize('$number$unit');
    return fmtBytes(bytes);
  }

  String _formatUserProfileNumber(String value) {
    final match = RegExp(
      r'-?\d[\d,]*(?:\.\d+)?|-?\d+(?:[.,]\d+)?',
    ).firstMatch(value);
    if (match == null) return '-';
    final number = double.tryParse(
      _normalizeUserProfileNumberText(match.group(0) ?? ''),
    );
    if (number == null || !number.isFinite) return '-';
    return fmtCompact(number);
  }

  String _formatUserProfileInteger(String value) {
    final match = RegExp(
      r'-?\d[\d,]*(?:\.\d+)?|-?\d+(?:[.,]\d+)?',
    ).firstMatch(value);
    if (match == null) return '-';
    final number = double.tryParse(
      _normalizeUserProfileNumberText(match.group(0) ?? ''),
    );
    if (number == null || !number.isFinite || number < 0) return '-';
    final integer = number.roundToDouble();
    if (number != integer) return '-';
    return integer.toInt().toString();
  }

  String _normalizeUserProfileNumberText(String value) {
    final text = value.trim();
    if (text.contains(',') && text.contains('.')) {
      return text.replaceAll(',', '');
    }
    if (RegExp(r'^-?\d{1,3}(,\d{3})+$').hasMatch(text)) {
      return text.replaceAll(',', '');
    }
    return text.replaceAll(',', '.');
  }

  String _formatUserProfileInvitation(String value) {
    final match = RegExp(
      r'(\d+)\s*(?:[/（(]\s*(\d+)\s*[）)]?)?',
    ).firstMatch(value);
    if (match == null) return '-';
    final invitation = int.tryParse(match.group(1) ?? '') ?? 0;
    final temporary = int.tryParse(match.group(2) ?? '') ?? 0;
    return '邀请 $invitation 个，临时邀请 $temporary 个';
  }

  /// 从文本中提取邮箱地址，去除前后的提示文字
  String _extractEmailFromText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '-';

    // 使用正则表达式匹配邮箱地址
    // 支持常见的邮箱格式：user@domain.com, user.name+tag@sub.domain.co.uk 等
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );

    final match = emailRegex.firstMatch(trimmed);
    if (match != null) {
      final email = match.group(0)!;
      AppLogger.info('从文本中提取到邮箱: $email (原文本: $trimmed)');
      return email;
    }

    // 如果没有匹配到邮箱格式，返回原文本
    AppLogger.warn('未从文本中提取到邮箱地址: $trimmed');
    return trimmed;
  }

  Future<void> _showUserProfileDialog(
    List<_BrowserUserProfileMetric> items,
    WebSite website, {
    String? extractedCookie,
  }) async {
    if (!mounted || items.isEmpty) return;
    final cs = shadcn.Theme.of(context).colorScheme;
    final siteInfo = _currentSiteInfoForWebsite(website);
    final hasUid = items.any(
      (item) => item.key == 'uid' && !_isUserProfilePlaceholder(item.rawValue),
    );
    final grouped = <String, List<_BrowserUserProfileMetric>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.group, () => []).add(item);
    }

    Widget metricTile(BuildContext context, _BrowserUserProfileMetric item) {
      final display = _userProfileDisplay(item.key);
      final color = display.color;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(display.icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.foreground.withValues(alpha: 0.58),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget section(String title, List<_BrowserUserProfileMetric> metrics) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: cs.foreground.withValues(alpha: 0.62),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = metrics.length > 1 && constraints.maxWidth >= 520
                  ? 2
                  : 1;
              const spacing = 8.0;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var i = 0; i < metrics.length; i++)
                    SizedBox(
                      width:
                          columns == 2 &&
                              i == metrics.length - 1 &&
                              metrics.length.isOdd
                          ? constraints.maxWidth
                          : width,
                      child: metricTile(context, metrics[i]),
                    ),
                ],
              );
            },
          ),
        ],
      );
    }

    Widget content(BuildContext dialogContext) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: MediaQuery.of(dialogContext).size.height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasUid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: BoxDecoration(
                  color: cs.destructive.withValues(alpha: 0.10),
                  border: Border(
                    bottom: BorderSide(
                      color: cs.destructive.withValues(alpha: 0.22),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      shadcn.LucideIcons.triangleAlert,
                      size: 16,
                      color: cs.destructive,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '未抓取到 UID',
                        style: TextStyle(
                          color: cs.destructive,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      shadcn.LucideIcons.userRound,
                      size: 20,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '用户页信息',
                          style: TextStyle(
                            color: cs.foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${items.length} 项 · ${_displayUrl(_currentUrl)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.foreground.withValues(alpha: 0.52),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.border),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: [
                  for (final entry in grouped.entries) ...[
                    section(entry.key, entry.value),
                    if (entry.key != grouped.keys.last)
                      const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    var saving = false;
    await shadcn.showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final saveButton = shadcn.Button.primary(
            onPressed: saving || !hasUid
                ? null
                : () async {
                    setDialogState(() => saving = true);
                    final ok = await _saveUserProfileToSite(
                      website,
                      siteInfo,
                      items,
                      extractedCookie: extractedCookie,
                    );
                    if (!dialogContext.mounted) return;
                    setDialogState(() => saving = false);
                    if (ok) Navigator.of(dialogContext).pop();
                  },
            child: Text(
              saving ? '保存中...' : (siteInfo == null ? '添加站点' : '更新站点'),
            ),
          );
          return shadcn.AlertDialog(
            content: content(dialogContext),
            actions: [
              shadcn.Button.outline(
                onPressed: saving
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('关闭'),
              ),
              if (hasUid)
                saveButton
              else
                shadcn.Tooltip(
                  tooltip: (_) => const Text('未抓取到 UID'),
                  child: saveButton,
                ),
            ],
          );
        },
      ),
    );
  }

  SiteInfo? _currentSiteInfoForWebsite(WebSite website) {
    final sites =
        ProviderScope.containerOf(
          context,
          listen: false,
        ).read(siteInfoListProvider).value ??
        const <SiteInfo>[];
    final configName = website.name.trim().toLowerCase();
    final siteId = widget.siteId?.trim().toLowerCase() ?? '';
    final currentHost = _uriHost(_currentUrl);

    for (final site in sites) {
      final siteName = site.site.trim().toLowerCase();
      if (siteName.isNotEmpty &&
          (siteName == configName || siteName == siteId)) {
        return site;
      }
    }
    if (currentHost == null) return null;
    for (final site in sites) {
      if (_uriHost(site.mirror ?? '') == currentHost) return site;
    }
    return null;
  }

  Future<bool> _saveUserProfileToSite(
    WebSite website,
    SiteInfo? siteInfo,
    List<_BrowserUserProfileMetric> items, {
    String? extractedCookie,
  }) async {
    String? raw(String key) {
      for (final item in items) {
        if (item.key == key) {
          final value = item.rawValue.trim();
          return _isUserProfilePlaceholder(value) ? null : value;
        }
      }
      return null;
    }

    if (raw('uid') == null) {
      Toast.warning('未抓取到 UID');
      return false;
    }

    try {
      final notifier = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(siteInfoListProvider.notifier);

      // 优先使用提取的 Cookie，如果没有则从浏览器读取
      final cookie = extractedCookie?.trim().isNotEmpty == true
          ? extractedCookie!.trim()
          : await _cookieHeaderFor(_currentUrl);
      final localStorage = await _localStorageSnapshotFor(_currentUrl);
      AppLogger.info("当前站点Cookie: $cookie");
      final next =
          (siteInfo ??
                  SiteInfo(
                    id: 0,
                    site: website.name.trim().isNotEmpty
                        ? website.name.trim()
                        : (widget.siteId?.trim() ?? ''),
                    nickname: website.nickname.trim(),
                    sortId: 1,
                    tags: website.tagList,
                    mirror: _currentOriginOrFirstWebsiteUrl(website),
                    cookie: cookie,
                    localStorage: _optionalBrowserStorage(localStorage ?? ''),
                    available: true,
                    signIn: website.signIn,
                    getInfo: website.getInfo,
                    repeatTorrents: website.repeatTorrents,
                    brushFree: website.brushFree,
                    brushRss: website.brushRss,
                    hrDiscern: website.hrDiscern,
                    searchTorrents: website.searchTorrents,
                  ))
              .copyWith(
                userId: raw('uid') ?? siteInfo?.userId,
                username: raw('username') ?? siteInfo?.username,
                email: raw('email') ?? siteInfo?.email,
                passkey: raw('passkey') ?? siteInfo?.passkey,
                timeJoin:
                    _normalizedUserProfileDateTime(raw('time_join')) ??
                    siteInfo?.timeJoin,
                latestActive:
                    _normalizedUserProfileDateTime(raw('latest_active')) ??
                    siteInfo?.latestActive,
                cookie: cookie ?? siteInfo?.cookie,
                localStorage: localStorage == null
                    ? siteInfo?.localStorage
                    : _optionalBrowserStorage(localStorage),
              );

      if (siteInfo == null) {
        await notifier.create(next);
        Toast.success('站点已添加');
      } else {
        await notifier.updateSite(next);
        Toast.success('站点已更新');
      }
      return true;
    } catch (e, st) {
      AppLogger.error(siteInfo == null ? '添加站点失败' : '更新站点失败', e, st);
      Toast.error(siteInfo == null ? '添加站点失败' : '更新站点失败');
      return false;
    }
  }

  String? _currentOriginOrFirstWebsiteUrl(WebSite website) {
    final current = Uri.tryParse(_currentUrl.trim());
    if (current != null && current.hasScheme && current.host.isNotEmpty) {
      return Uri(
        scheme: current.scheme,
        host: current.host,
        port: current.hasPort ? current.port : null,
        path: '/',
      ).toString();
    }
    return website.url.isEmpty ? null : website.url.first;
  }

  String _buildTorrentExtractScript(WebSite website) {
    String encode(String value) => jsonEncode(value);
    return '''
(() => {
  const ruleVariants = (rule) => {
    const raw = (rule || '').trim();
    if (!raw) return [];
    const values = new Set();
    const push = (value) => {
      const text = (value || '').trim();
      if (text) values.add(text);
    };
    const removeTbody = (value) => value.replace(/\\/tbody(?=\\/|\$)/gi, '');
    const addTbody = (value) => value.replace(
      /(\\/table(?:\\[[^\\]]+\\])?)(?=\\/tr(?:\\[[^\\]]+\\])?(?:\\/|\$))/gi,
      '\$1/tbody',
    );
    push(raw);
    push(removeTbody(raw));
    push(addTbody(raw));
    push(addTbody(removeTbody(raw)));
    return Array.from(values);
  };

  const readNodeValue = (node) => {
    if (!node) return '';
    if (node.nodeType === Node.ATTRIBUTE_NODE || node.nodeType === Node.TEXT_NODE || node.nodeType === Node.CDATA_SECTION_NODE) {
      return (node.nodeValue || '').trim();
    }
    if (node instanceof HTMLAnchorElement) {
      return (node.getAttribute('href') || node.href || node.textContent || '').trim();
    }
    if (node instanceof HTMLImageElement) {
      return (node.getAttribute('src') || node.src || '').trim();
    }
    return (node.textContent || '').trim();
  };

  const absoluteUrl = (value) => {
    const text = (value || '').trim();
    if (!text) return '';
    try {
      return new URL(text, window.location.href).toString();
    } catch (_) {
      return text;
    }
  };

  const evaluateNodes = (contextNode, rule) => {
    if (!rule) return [];
    for (const candidate of ruleVariants(rule)) {
      try {
        const result = document.evaluate(candidate, contextNode, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
        const nodes = [];
        for (let i = 0; i < result.snapshotLength; i += 1) {
          nodes.push(result.snapshotItem(i));
        }
        if (nodes.length) return nodes;
      } catch (_) {}
    }
    return [];
  };

  const evaluateValue = (contextNode, rule) => {
    if (!rule) return '';
    for (const candidate of ruleVariants(rule)) {
      try {
        const result = document.evaluate(candidate, contextNode, null, XPathResult.ANY_TYPE, null);
        switch (result.resultType) {
          case XPathResult.STRING_TYPE: {
            const value = (result.stringValue || '').trim();
            if (value) return value;
            break;
          }
          case XPathResult.NUMBER_TYPE:
            if (Number.isFinite(result.numberValue)) {
              return String(result.numberValue);
            }
            break;
          case XPathResult.BOOLEAN_TYPE:
            if (result.booleanValue) return 'true';
            break;
          default: {
            const node = result.singleNodeValue || result.iterateNext?.();
            const value = readNodeValue(node);
            if (value) return value;
            break;
          }
        }
      } catch (_) {}
    }
    const nodes = evaluateNodes(contextNode, rule);
    return nodes.length ? readNodeValue(nodes[0]) : '';
  };

  const evaluateJoinedValue = (contextNode, rule) => {
    if (!rule) return '';
    const nodes = evaluateNodes(contextNode, rule);
    if (nodes.length > 1) {
      return nodes
        .map((node) => readNodeValue(node))
        .filter((value) => value)
        .join(' ')
        .replace(/\\s+/g, ' ')
        .trim();
    }
    return evaluateValue(contextNode, rule);
  };

  const rows = evaluateNodes(document, ${encode(website.torrentsRule)});
  return rows.map((row) => {
    const detailUrl = absoluteUrl(evaluateValue(row, ${encode(website.torrentDetailUrlRule)}));
    const magnetUrl = absoluteUrl(evaluateValue(row, ${encode(website.torrentMagnetUrlRule)}));
    const poster = absoluteUrl(evaluateValue(row, ${encode(website.torrentPosterRule)}));
    return {
      title: evaluateValue(row, ${encode(website.torrentTitleRule)}),
      subtitle: evaluateValue(row, ${encode(website.torrentSubtitleRule)}),
      detailUrl,
      magnetUrl,
      category: evaluateValue(row, ${encode(website.torrentCategoryRule)}),
      poster,
      size: evaluateJoinedValue(row, ${encode(website.torrentSizeRule)}),
      progress: evaluateValue(row, ${encode(website.torrentProgressRule)}),
      hr: evaluateValue(row, ${encode(website.torrentHrRule)}),
      sale: evaluateValue(row, ${encode(website.torrentSaleRule)}),
      saleExpire: evaluateValue(row, ${encode(website.torrentSaleExpireRule)}),
      release: evaluateValue(row, ${encode(website.torrentReleaseRule)}),
      seeders: evaluateValue(row, ${encode(website.torrentSeedersRule)}),
      leechers: evaluateValue(row, ${encode(website.torrentLeechersRule)}),
      completers: evaluateValue(row, ${encode(website.torrentCompletersRule)}),
      tags: evaluateNodes(row, ${encode(website.torrentTagsRule)}).map((node) => readNodeValue(node)).filter(Boolean),
    };
  }).filter((item) => item.title || item.detailUrl || item.magnetUrl);
})()
''';
  }

  String _buildTorrentDetailExtractScript(WebSite website) {
    String encode(String value) => jsonEncode(value);
    return '''
(() => {
  const ruleVariants = (rule) => {
    const raw = (rule || '').trim();
    if (!raw) return [];
    const values = new Set();
    const push = (value) => {
      const text = (value || '').trim();
      if (text) values.add(text);
    };
    push(raw);
    return Array.from(values);
  };

  const readNodeValue = (node) => {
    if (!node) return '';
    if (node.nodeType === Node.ATTRIBUTE_NODE || node.nodeType === Node.TEXT_NODE || node.nodeType === Node.CDATA_SECTION_NODE) {
      return (node.nodeValue || '').trim();
    }
    if (node instanceof HTMLAnchorElement) {
      return (node.getAttribute('href') || node.href || node.textContent || '').trim();
    }
    if (node instanceof HTMLImageElement) {
      return (node.getAttribute('src') || node.src || '').trim();
    }
    return (node.textContent || '').trim();
  };

  const absoluteUrl = (value) => {
    const text = (value || '').trim();
    if (!text) return '';
    try {
      return new URL(text, window.location.href).toString();
    } catch (_) {
      return text;
    }
  };

  const evaluateNodes = (contextNode, rule) => {
    if (!rule) return [];
    for (const candidate of ruleVariants(rule)) {
      try {
        const result = document.evaluate(candidate, contextNode, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
        const nodes = [];
        for (let i = 0; i < result.snapshotLength; i += 1) {
          nodes.push(result.snapshotItem(i));
        }
        if (nodes.length) return nodes;
      } catch (_) {}
    }
    return [];
  };

  const evaluateValue = (contextNode, rule) => {
    if (!rule) return '';
    for (const candidate of ruleVariants(rule)) {
      try {
        const result = document.evaluate(candidate, contextNode, null, XPathResult.ANY_TYPE, null);
        switch (result.resultType) {
          case XPathResult.STRING_TYPE: {
            const value = (result.stringValue || '').trim();
            if (value) return value;
            break;
          }
          case XPathResult.NUMBER_TYPE:
            if (Number.isFinite(result.numberValue)) return String(result.numberValue);
            break;
          case XPathResult.BOOLEAN_TYPE:
            if (result.booleanValue) return 'true';
            break;
          default: {
            const node = result.singleNodeValue || result.iterateNext?.();
            const value = readNodeValue(node);
            if (value) return value;
            break;
          }
        }
      } catch (_) {}
    }
    const nodes = evaluateNodes(contextNode, rule);
    return nodes.length ? readNodeValue(nodes[0]) : '';
  };

  return {
    title: evaluateValue(document, ${encode(website.detailTitleRule)}),
    subtitle: evaluateValue(document, ${encode(website.detailSubtitleRule)}),
    detailUrl: window.location.href,
    magnetUrl: absoluteUrl(evaluateValue(document, ${encode(website.detailDownloadUrlRule)})),
    category: evaluateValue(document, ${encode(website.detailCategoryRule)}),
    poster: absoluteUrl(evaluateValue(document, ${encode(website.detailPosterRule)})),
    size: evaluateValue(document, ${encode(website.detailSizeRule)}),
    progress: '',
    hr: evaluateValue(document, ${encode(website.detailHrRule)}),
    sale: evaluateValue(document, ${encode(website.detailFreeRule)}),
    saleExpire: evaluateValue(document, ${encode(website.detailFreeExpireRule)}),
    release: '',
    seeders: '',
    leechers: '',
    completers: '',
    tags: evaluateNodes(document, ${encode(website.detailTagsRule)}).map((node) => readNodeValue(node)).filter(Boolean),
  };
})()
''';
  }

  List<_BrowserExtractedTorrent> _parseExtractedTorrents(dynamic raw) {
    dynamic data = raw;
    if (raw is String) {
      try {
        data = jsonDecode(raw);
      } catch (_) {
        data = const [];
      }
    }
    if (data is! List) return const [];
    return data
        .whereType<Object?>()
        .map((item) {
          if (item is Map) {
            return _BrowserExtractedTorrent.fromMap(
              Map<String, dynamic>.from(item),
            );
          }
          return null;
        })
        .whereType<_BrowserExtractedTorrent>()
        .where(
          (item) =>
              item.title.isNotEmpty ||
              item.detailUrl.isNotEmpty ||
              item.magnetUrl.isNotEmpty,
        )
        .toList();
  }

  _BrowserExtractedTorrent? _parseExtractedTorrentDetail(dynamic raw) {
    dynamic data = raw;
    if (raw is String) {
      try {
        data = jsonDecode(raw);
      } catch (_) {
        data = null;
      }
    }
    if (data is! Map) return null;
    final item = _BrowserExtractedTorrent.fromMap(
      Map<String, dynamic>.from(data),
    );
    if (item.title.isEmpty &&
        item.detailUrl.isEmpty &&
        item.magnetUrl.isEmpty) {
      return null;
    }
    return item;
  }

  Future<void> _showExtractedTorrentDialog(
    List<_BrowserExtractedTorrent> items,
  ) async {
    final cs = shadcn.Theme.of(context).colorScheme;
    final selected = <int>{
      for (var i = 0; i < items.length; i += 1)
        if (items[i].hasPushableUrl) i,
    };
    String saleFilter = '';
    String categoryFilter = '';
    final tagFilters = <String>{};
    _BrowserTorrentSortKey sortKey = _BrowserTorrentSortKey.seeders;
    bool sortAscending = false;
    bool panelExpanded = !context.isMobile;

    final saleOptions =
        items
            .map((item) => item.sale.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final categoryOptions =
        items
            .map((item) => item.category.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final tagOptions =
        items
            .expand((item) => item.tags)
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    Widget content(BuildContext dialogContext, StateSetter setDialogState) {
      bool matchesCurrentFilters(_BrowserExtractedTorrent item) {
        final saleOk = saleFilter.isEmpty || item.sale.trim() == saleFilter;
        final categoryOk =
            categoryFilter.isEmpty || item.category.trim() == categoryFilter;
        final tagOk =
            tagFilters.isEmpty ||
            item.tags.any((tag) => tagFilters.contains(tag.trim()));
        return saleOk && categoryOk && tagOk;
      }

      Iterable<MapEntry<int, _BrowserExtractedTorrent>> matchingEntries() {
        return items.asMap().entries.where(
          (entry) => matchesCurrentFilters(entry.value),
        );
      }

      List<int> matchingPushableKeys() {
        return matchingEntries()
            .where((entry) => entry.value.hasPushableUrl)
            .map((entry) => entry.key)
            .toList();
      }

      final visibleEntries = matchingEntries().toList()
        ..sort((a, b) {
          final left = a.value;
          final right = b.value;
          final result = switch (sortKey) {
            _BrowserTorrentSortKey.name => left.titleSortValue.compareTo(
              right.titleSortValue,
            ),
            _BrowserTorrentSortKey.seeders => left.seedersValue.compareTo(
              right.seedersValue,
            ),
            _BrowserTorrentSortKey.size => left.sizeBytes.compareTo(
              right.sizeBytes,
            ),
          };
          if (result == 0) {
            return left.titleSortValue.compareTo(right.titleSortValue);
          }
          return sortAscending ? result : -result;
        });

      final allKeys = [
        for (var i = 0; i < items.length; i += 1)
          if (items[i].hasPushableUrl) i,
      ];
      final visibleKeys = matchingPushableKeys();
      final allVisibleSelected =
          visibleKeys.isNotEmpty &&
          visibleKeys.every((key) => selected.contains(key));
      final hasActiveFilter =
          saleFilter.isNotEmpty ||
          categoryFilter.isNotEmpty ||
          tagFilters.isNotEmpty;
      selected.removeWhere((index) => !allKeys.contains(index));

      void syncSelectionToCurrentFilter() {
        selected
          ..clear()
          ..addAll(matchingPushableKeys());
      }

      void selectAll() {
        selected
          ..clear()
          ..addAll(allKeys);
      }

      void invertVisible() {
        for (final key in visibleKeys) {
          if (selected.contains(key)) {
            selected.remove(key);
          } else {
            selected.add(key);
          }
        }
      }

      void selectVisible() {
        selected.addAll(visibleKeys);
      }

      void selectOnlyVisible() {
        selected
          ..clear()
          ..addAll(visibleKeys);
      }

      void unselectVisible() {
        for (final key in visibleKeys) {
          selected.remove(key);
        }
      }

      void clearFilters() {
        saleFilter = '';
        categoryFilter = '';
        tagFilters.clear();
        selected
          ..clear()
          ..addAll(allKeys);
      }

      void updateFilters(VoidCallback update) {
        update();
        syncSelectionToCurrentFilter();
      }

      Widget filterChip({
        required String label,
        required bool selectedValue,
        required VoidCallback onTap,
        Color? accent,
      }) {
        final activeColor = accent ?? cs.primary;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selectedValue
                  ? activeColor.withValues(alpha: 0.12)
                  : cs.muted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selectedValue
                    ? activeColor.withValues(alpha: 0.32)
                    : cs.border.withValues(alpha: 0.7),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selectedValue ? FontWeight.w700 : FontWeight.w500,
                color: selectedValue
                    ? activeColor
                    : cs.foreground.withValues(alpha: 0.72),
              ),
            ),
          ),
        );
      }

      Widget sectionTitle(String text) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.foreground.withValues(alpha: 0.56),
            ),
          ),
        );
      }

      Color saleColor(String sale) {
        final value = sale.toLowerCase();
        if (value.contains('免费') ||
            value.contains('free') ||
            value.contains('0')) {
          return const Color(0xFF10B981);
        }
        if (value.contains('2x') || value.contains('双倍')) {
          return const Color(0xFFF59E0B);
        }
        if (value.contains('30%') || value.contains('50%')) {
          return const Color(0xFF8B5CF6);
        }
        return cs.primary;
      }

      String sortLabel() {
        return switch (sortKey) {
          _BrowserTorrentSortKey.name => '名称',
          _BrowserTorrentSortKey.seeders => '做种人数',
          _BrowserTorrentSortKey.size => '大小',
        };
      }

      final filterSummary = [
        '排序: ${sortLabel()}${sortAscending ? '↑' : '↓'}',
        if (saleFilter.isNotEmpty) '优惠: $saleFilter',
        if (categoryFilter.isNotEmpty) '分类: $categoryFilter',
        if (tagFilters.isNotEmpty) '标签: ${tagFilters.join(', ')}',
      ].join('  ·  ');

      Future<void> pushPicked(List<_BrowserExtractedTorrent> picked) async {
        final pushable = picked.where((item) => item.hasPushableUrl).toList();
        if (pushable.isEmpty) {
          Toast.warning('所选种子缺少可用链接');
          return;
        }
        if (dialogContext.isMobile) {
          closeAppSheet(dialogContext);
        } else {
          Navigator.of(dialogContext).pop();
        }
        await _showDownloaderSelectAndPush(pushable);
      }

      Widget selectionActionButton() {
        return shadcn.OverlayManagerLayer(
          popoverHandler: const shadcn.PopoverOverlayHandler(),
          tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
          menuHandler: const shadcn.PopoverOverlayHandler(),
          child: Builder(
            builder: (menuContext) => shadcn.Button.ghost(
              onPressed: items.isEmpty
                  ? null
                  : () => shadcn.showDropdown<void>(
                      context: menuContext,
                      alignment: Alignment.topCenter,
                      offset: const Offset(0, 8),
                      widthConstraint: shadcn.PopoverConstraint.intrinsic,
                      heightConstraint: shadcn.PopoverConstraint.intrinsic,
                      consumeOutsideTaps: false,
                      builder: (_) => AppDropdownMenu(
                        children: [
                          const shadcn.MenuLabel(child: Text('批量选择')),
                          const shadcn.MenuDivider(),
                          shadcn.MenuButton(
                            enabled: allKeys.isNotEmpty,
                            onPressed: (_) {
                              setDialogState(() {
                                selectAll();
                              });
                            },
                            child: const Text('全选所有'),
                          ),
                          shadcn.MenuButton(
                            enabled: visibleKeys.isNotEmpty,
                            onPressed: (_) {
                              setDialogState(() {
                                invertVisible();
                              });
                            },
                            child: const Text('反选当前'),
                          ),
                          shadcn.MenuButton(
                            enabled: visibleKeys.isNotEmpty,
                            onPressed: (_) {
                              setDialogState(() {
                                selectVisible();
                              });
                            },
                            child: const Text('选择当前'),
                          ),
                          shadcn.MenuButton(
                            enabled: visibleKeys.isNotEmpty,
                            onPressed: (_) {
                              setDialogState(() {
                                selectOnlyVisible();
                              });
                            },
                            child: const Text('仅选当前'),
                          ),
                          shadcn.MenuButton(
                            enabled:
                                visibleKeys.isNotEmpty && allVisibleSelected,
                            onPressed: (_) {
                              setDialogState(() {
                                unselectVisible();
                              });
                            },
                            child: const Text('取消当前'),
                          ),
                          shadcn.MenuButton(
                            enabled: selected.isNotEmpty,
                            onPressed: (_) {
                              setDialogState(() {
                                selected.clear();
                              });
                            },
                            child: const Text('清空选择'),
                          ),
                        ],
                      ),
                    ),
              child: const Text('选择操作'),
            ),
          ),
        );
      }

      Widget pushSelectedButton() {
        return shadcn.Button.outline(
          onPressed: selected.isEmpty
              ? null
              : () async {
                  final picked = selected
                      .where((index) => index >= 0 && index < items.length)
                      .map((index) => items[index])
                      .toList();
                  await pushPicked(picked);
                },
          child: Text('推送已选(${selected.length})'),
        );
      }

      final dialogHeight =
          MediaQuery.of(dialogContext).size.height *
          (dialogContext.isMobile ? 0.86 : 0.78);
      return SizedBox(
        width: dialogContext.isMobile ? double.infinity : 720,
        height: dialogHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('种子列表'),
                            const SizedBox(height: 4),
                            Text(
                              '共 ${items.length} 条，当前 ${visibleEntries.length} 条，可推送 ${visibleKeys.length} 条，已选 ${selected.length} 条',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.foreground.withValues(alpha: 0.56),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.border),
            Expanded(
              child: visibleEntries.isEmpty
                  ? Center(
                      child: Text(
                        '没有符合当前筛选条件的种子',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.foreground.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: visibleEntries.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: cs.border),
                      itemBuilder: (itemContext, index) {
                        final entry = visibleEntries[index];
                        final item = entry.value;
                        final itemIndex = entry.key;
                        final isSelected = selected.contains(itemIndex);
                        final compact = dialogContext.isMobile;
                        Widget metricBadge({
                          required String text,
                          IconData? icon,
                          Color? color,
                          bool filled = false,
                        }) {
                          final accent =
                              color ?? cs.foreground.withValues(alpha: 0.72);
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 7 : 8,
                              vertical: compact ? 3 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: filled
                                  ? accent.withValues(alpha: 0.12)
                                  : cs.background.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: filled
                                    ? accent.withValues(alpha: 0.26)
                                    : cs.border.withValues(alpha: 0.7),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (icon != null) ...[
                                  Icon(
                                    icon,
                                    size: compact ? 10 : 11,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: compact ? 9.5 : 10,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final metricBadges = <Widget>[
                          if (item.formattedCategory.isNotEmpty)
                            metricBadge(
                              text: item.formattedCategory,
                              icon: shadcn.LucideIcons.folder,
                            ),
                          if (item.displaySize.isNotEmpty)
                            metricBadge(
                              text: item.displaySize,
                              icon: shadcn.LucideIcons.hardDrive,
                              color: const Color(0xFF2563EB),
                              filled: true,
                            ),
                          if (item.seeders.isNotEmpty)
                            metricBadge(
                              text: item.seeders,
                              icon: shadcn.LucideIcons.arrowUp,
                              color: const Color(0xFF10B981),
                              filled: true,
                            ),
                          if (item.leechers.isNotEmpty)
                            metricBadge(
                              text: item.leechers,
                              icon: shadcn.LucideIcons.arrowDown,
                              color: const Color(0xFFF59E0B),
                              filled: true,
                            ),
                          if (item.completers.isNotEmpty)
                            metricBadge(
                              text: item.completers,
                              icon: shadcn.LucideIcons.badgeCheck,
                              color: const Color(0xFF8B5CF6),
                              filled: true,
                            ),
                        ];

                        final saleBadge = item.sale.isEmpty
                            ? null
                            : metricBadge(
                                text: item.sale,
                                color: saleColor(item.sale),
                                filled: true,
                              );

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primary.withValues(alpha: 0.08)
                                : cs.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? cs.primary.withValues(alpha: 0.45)
                                  : cs.border.withValues(alpha: 0.75),
                              width: isSelected ? 1 : 0.8,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: 0.12),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: item.hasPushableUrl
                                  ? () {
                                      setDialogState(() {
                                        if (isSelected) {
                                          selected.remove(itemIndex);
                                        } else {
                                          selected.add(itemIndex);
                                        }
                                      });
                                    }
                                  : null,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  compact ? 8 : 10,
                                  compact ? 6 : 7,
                                  compact ? 12 : 14,
                                  compact ? 6 : 7,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title.isEmpty
                                                      ? item.primaryUrl
                                                      : item.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: compact
                                                        ? 12.5
                                                        : 13.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: cs.foreground,
                                                  ),
                                                ),
                                              ),
                                              if (saleBadge != null) ...[
                                                const SizedBox(width: 8),
                                                saleBadge,
                                              ],
                                            ],
                                          ),
                                          if (item.subtitle.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 2,
                                              ),
                                              child: Text(
                                                item.subtitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: compact
                                                      ? 10.5
                                                      : 11.5,
                                                  color: cs.foreground
                                                      .withValues(alpha: 0.68),
                                                ),
                                              ),
                                            ),
                                          if (metricBadges.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              child: Wrap(
                                                spacing: 6,
                                                runSpacing: 6,
                                                children: metricBadges,
                                              ),
                                            ),
                                          if (item.tags.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              child: Wrap(
                                                spacing: 6,
                                                runSpacing: 6,
                                                children: [
                                                  for (final tag
                                                      in item.tags.take(6))
                                                    metricBadge(
                                                      text: tag,
                                                      color: const Color(
                                                        0xFF8B5CF6,
                                                      ),
                                                      filled: true,
                                                    ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    shadcn.IconButton.ghost(
                                      onPressed: item.hasPushableUrl
                                          ? () => unawaited(pushPicked([item]))
                                          : null,
                                      icon: shadcn.Tooltip(
                                        tooltip: (_) => Text(
                                          item.hasPushableUrl
                                              ? '推送此种子'
                                              : '缺少可用链接',
                                        ),
                                        child: Icon(
                                          shadcn.LucideIcons.send,
                                          size: compact ? 16 : 17,
                                          color: item.hasPushableUrl
                                              ? cs.primary
                                              : cs.foreground.withValues(
                                                  alpha: 0.32,
                                                ),
                                        ),
                                      ),
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
            Divider(height: 1, color: cs.border),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                color: cs.muted.withValues(alpha: 0.22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(
                            () => panelExpanded = !panelExpanded,
                          ),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '筛选与排序',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: cs.foreground,
                                ),
                              ),
                              if (filterSummary.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    filterSummary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.foreground.withValues(
                                        alpha: 0.58,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      selectionActionButton(),
                      const SizedBox(width: 8),
                      pushSelectedButton(),
                      if (hasActiveFilter) ...[
                        const SizedBox(width: 8),
                        shadcn.Button.ghost(
                          onPressed: () => setDialogState(clearFilters),
                          child: const Text('重置'),
                        ),
                      ],
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setDialogState(
                          () => panelExpanded = !panelExpanded,
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          panelExpanded
                              ? shadcn.LucideIcons.chevronDown
                              : shadcn.LucideIcons.chevronUp,
                          size: 16,
                          color: cs.foreground.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                  if (panelExpanded)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            dialogHeight *
                            (dialogContext.isMobile ? 0.46 : 0.42),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle('排序'),
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      filterChip(
                                        label: '名称',
                                        selectedValue:
                                            sortKey ==
                                            _BrowserTorrentSortKey.name,
                                        onTap: () => setDialogState(() {
                                          sortKey = _BrowserTorrentSortKey.name;
                                          sortAscending = true;
                                        }),
                                      ),
                                      filterChip(
                                        label: '做种人数',
                                        selectedValue:
                                            sortKey ==
                                            _BrowserTorrentSortKey.seeders,
                                        onTap: () => setDialogState(() {
                                          sortKey =
                                              _BrowserTorrentSortKey.seeders;
                                          sortAscending = false;
                                        }),
                                      ),
                                      filterChip(
                                        label: '大小',
                                        selectedValue:
                                            sortKey ==
                                            _BrowserTorrentSortKey.size,
                                        onTap: () => setDialogState(() {
                                          sortKey = _BrowserTorrentSortKey.size;
                                          sortAscending = false;
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setDialogState(
                                    () => sortAscending = !sortAscending,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.background,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: cs.border.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          sortAscending
                                              ? shadcn
                                                    .LucideIcons
                                                    .arrowUpNarrowWide
                                              : shadcn
                                                    .LucideIcons
                                                    .arrowDownWideNarrow,
                                          size: 12,
                                          color: cs.foreground.withValues(
                                            alpha: 0.72,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          sortAscending ? '升序' : '降序',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: cs.foreground.withValues(
                                              alpha: 0.72,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            sectionTitle('优惠'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                filterChip(
                                  label: '全部',
                                  selectedValue: saleFilter.isEmpty,
                                  onTap: () => setDialogState(
                                    () => updateFilters(() => saleFilter = ''),
                                  ),
                                ),
                                for (final sale in saleOptions)
                                  filterChip(
                                    label: sale,
                                    selectedValue: saleFilter == sale,
                                    onTap: () => setDialogState(
                                      () => updateFilters(
                                        () => saleFilter = saleFilter == sale
                                            ? ''
                                            : sale,
                                      ),
                                    ),
                                    accent: saleColor(sale),
                                  ),
                              ],
                            ),
                            if (categoryOptions.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              sectionTitle('分类'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  filterChip(
                                    label: '全部',
                                    selectedValue: categoryFilter.isEmpty,
                                    onTap: () => setDialogState(
                                      () => updateFilters(
                                        () => categoryFilter = '',
                                      ),
                                    ),
                                  ),
                                  for (final category in categoryOptions)
                                    filterChip(
                                      label: category,
                                      selectedValue: categoryFilter == category,
                                      onTap: () => setDialogState(
                                        () => updateFilters(
                                          () => categoryFilter =
                                              categoryFilter == category
                                              ? ''
                                              : category,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            if (tagOptions.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              sectionTitle('标签'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  filterChip(
                                    label: '全部',
                                    selectedValue: tagFilters.isEmpty,
                                    onTap: () => setDialogState(
                                      () => updateFilters(tagFilters.clear),
                                    ),
                                  ),
                                  for (final tag in tagOptions)
                                    filterChip(
                                      label: tag,
                                      selectedValue: tagFilters.contains(tag),
                                      onTap: () => setDialogState(
                                        () => updateFilters(() {
                                          if (!tagFilters.remove(tag)) {
                                            tagFilters.add(tag);
                                          }
                                        }),
                                      ),
                                      accent: const Color(0xFF8B5CF6),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (context.isMobile) {
      await showAppSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: cs.background,
        builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, setDialogState) =>
              SafeArea(child: content(sheetContext, setDialogState)),
        ),
      );
      return;
    }

    await shadcn.showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) =>
            shadcn.AlertDialog(content: content(dialogContext, setDialogState)),
      ),
    );
  }

  Future<void> _showDownloaderSelectAndPush(
    List<_BrowserExtractedTorrent> torrents,
  ) async {
    if (!mounted || _closing || torrents.isEmpty) return;
    await showAppSheet<void>(
      context: context,
      title: '选择下载器',
      showDefaultHeader: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        maxWidth: DownloaderSelectSheet.desktopWidth,
      ),
      builder: (sheetContext) => DownloaderSelectSheet(
        useDefaultHeader: true,
        onSelected: (downloader) async {
          await closeAppSheet(sheetContext);
          await Future<void>.delayed(const Duration(milliseconds: 80));
          if (!mounted || _closing) return;
          final urls = torrents
              .map((item) {
                final primary = item.primaryUrl.trim();
                if (primary.isNotEmpty) return primary;
                return item.detailUrl.trim();
              })
              .where((url) => url.isNotEmpty)
              .toSet()
              .toList();
          if (urls.isEmpty) {
            Toast.warning('所选种子缺少可用链接');
            return;
          }
          final ids = <String>[];
          for (final torrent in torrents) {
            final id = _torrentIdForExtractedTorrent(torrent);
            if (id.isNotEmpty && !ids.contains(id)) ids.add(id);
          }
          final cookie = await _cookieHeaderFor(urls.first);
          if (!mounted || _closing) return;
          final singleTorrent = torrents.length == 1
              ? _toSearchTorrentInfo(torrents.first, cookie: cookie)
              : null;
          if (context.isMobile) {
            await showAppSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              constraints: const BoxConstraints(
                maxWidth: PushTorrentSheet.desktopWidth,
              ),
              builder: (_) => PushTorrentSheet(
                downloader: downloader,
                torrent: singleTorrent,
                initialUrl: urls.join('\n'),
                initialIds: ids,
                initialCookie: cookie,
                initialSiteId: widget.siteId,
              ),
            );
          } else {
            await shadcn.showDialog<void>(
              context: context,
              builder: (dialogContext) => shadcn.AlertDialog(
                content: SizedBox(
                  width: PushTorrentSheet.desktopWidth,
                  height: PushTorrentSheet.desktopHeight,
                  child: PushTorrentSheet(
                    downloader: downloader,
                    torrent: singleTorrent,
                    initialUrl: urls.join('\n'),
                    initialIds: ids,
                    initialCookie: cookie,
                    initialSiteId: widget.siteId,
                    embedded: true,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  SearchTorrentInfo _toSearchTorrentInfo(
    _BrowserExtractedTorrent item, {
    String? cookie,
    String? overrideUrl,
  }) {
    final primaryUrl = (overrideUrl?.trim().isNotEmpty == true
        ? overrideUrl!.trim()
        : item.primaryUrl.trim());
    final detailUrl = item.detailUrl.trim();
    final siteId = widget.siteId?.trim() ?? '';
    final torrentId = item.id.trim().isNotEmpty
        ? item.id.trim()
        : _extractTorrentIdFromBrowserUrl(
            primaryUrl.isNotEmpty ? primaryUrl : detailUrl,
          );
    return SearchTorrentInfo(
      siteId: siteId,
      tid: torrentId,
      poster: item.poster,
      category: item.formattedCategory.isNotEmpty
          ? item.formattedCategory
          : item.category,
      magnetUrl: primaryUrl,
      detailUrl: detailUrl,
      title: item.title.isNotEmpty ? item.title : primaryUrl,
      subtitle: item.subtitle,
      cookie: cookie?.trim().isNotEmpty == true
          ? cookie!.trim()
          : widget.cookie,
      saleStatus: item.sale.isNotEmpty ? item.sale : '无优惠',
      saleExpire: item.saleExpire.isEmpty ? null : item.saleExpire,
      tags: item.tags,
      hr: item.hr.trim().isNotEmpty,
      published: item.release,
      size: item.sizeBytes,
      seeders: item.seedersValue,
      leechers: _BrowserExtractedTorrent._parseCompactInt(item.leechers),
      completers: _BrowserExtractedTorrent._parseCompactInt(item.completers),
    );
  }

  String _torrentIdForExtractedTorrent(_BrowserExtractedTorrent item) {
    final direct = item.id.trim();
    if (direct.isNotEmpty) return direct;
    for (final value in [item.magnetUrl, item.detailUrl, item.primaryUrl]) {
      final id = _extractTorrentIdFromBrowserUrl(value);
      if (id.isNotEmpty) return id;
    }
    return '';
  }

  Future<SearchTorrentInfo?> _extractInterceptedTorrentInfo(
    String torrentUrl, {
    String? cookie,
  }) async {
    final controller = _controller;
    if (controller == null || _closing || !mounted) return null;

    final detailWebsite = _currentDetailWebsiteConfig();
    if (detailWebsite != null) {
      try {
        final raw = await controller.evaluateJavascript(
          source: _buildTorrentDetailExtractScript(detailWebsite),
        );
        final item = _parseExtractedTorrentDetail(raw);
        if (item != null) {
          return _toSearchTorrentInfo(
            item,
            cookie: cookie,
            overrideUrl: torrentUrl,
          );
        }
      } catch (e, st) {
        AppLogger.warn('拦截种子下载时解析详情页种子信息失败: $e\n$st');
      }
    }

    final listWebsite = _currentTorrentWebsiteConfig();
    if (listWebsite != null) {
      try {
        final raw = await controller.evaluateJavascript(
          source: _buildTorrentExtractScript(listWebsite),
        );
        final items = _parseExtractedTorrents(raw);
        final matched = _matchInterceptedTorrent(items, torrentUrl);
        if (matched != null) {
          return _toSearchTorrentInfo(
            matched,
            cookie: cookie,
            overrideUrl: torrentUrl,
          );
        }
      } catch (e, st) {
        AppLogger.warn('拦截种子下载时解析列表页种子信息失败: $e\n$st');
      }
    }

    return null;
  }

  _BrowserExtractedTorrent? _matchInterceptedTorrent(
    List<_BrowserExtractedTorrent> items,
    String torrentUrl,
  ) {
    final targetUrl = _normalizeTorrentCompareUrl(torrentUrl);
    final targetId = _extractTorrentIdFromBrowserUrl(torrentUrl);
    for (final item in items) {
      final candidates = <String>[
        item.magnetUrl,
        item.detailUrl,
        item.primaryUrl,
      ];
      for (final candidate in candidates) {
        final normalized = _normalizeTorrentCompareUrl(candidate);
        if (normalized.isNotEmpty && normalized == targetUrl) return item;
        final id = _extractTorrentIdFromBrowserUrl(candidate);
        if (targetId.isNotEmpty && id.isNotEmpty && id == targetId) return item;
      }
    }
    return null;
  }

  String _normalizeTorrentCompareUrl(String value) {
    final text = value.trim();
    if (text.isEmpty) return '';
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme) return text;
    final query = Map<String, String>.from(uri.queryParameters)
      ..removeWhere((key, _) {
        final normalized = key.toLowerCase();
        return normalized == 'passkey' ||
            normalized == 'sign' ||
            normalized == 'authkey' ||
            normalized == 'auth' ||
            normalized == 'token';
      });
    return uri
        .replace(queryParameters: query.isEmpty ? null : query)
        .toString();
  }

  String _extractTorrentIdFromBrowserUrl(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '';
    if (RegExp(r'^\d+$').hasMatch(raw)) return raw;

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      const queryKeys = <String>['tid', 'id', 'torrentid', 'topicid'];
      for (final key in queryKeys) {
        final v = uri.queryParameters[key]?.trim() ?? '';
        if (v.isNotEmpty) return v;
      }
      for (final segment in uri.pathSegments.reversed) {
        final text = segment.trim();
        if (text.isNotEmpty && RegExp(r'^\d+$').hasMatch(text)) {
          return text;
        }
      }
    }

    final match = RegExp(
      r'([?&](?:tid|id|torrentid|topicid)=)([^&#]+)',
      caseSensitive: false,
    ).firstMatch(raw);
    return match?.group(2)?.trim() ?? '';
  }

  bool _isTorrentUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    final lower = trimmed.toLowerCase();
    if (lower.startsWith('magnet:?')) return true;

    final uri = Uri.tryParse(trimmed);
    final path = uri?.path.toLowerCase() ?? lower;
    return path.endsWith('.torrent') || lower.contains('.torrent?');
  }

  bool _isLoadedPageUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        !_isTorrentUrl(url);
  }

  bool _isTorrentDownloadRequest({
    required String url,
    String? mimeType,
    String? contentDisposition,
    String? suggestedFilename,
  }) {
    if (_isTorrentUrl(url)) return true;

    final mime = mimeType?.toLowerCase().trim();
    if (mime == 'application/x-bittorrent' || mime == 'application/torrent') {
      return true;
    }

    final filename = suggestedFilename?.toLowerCase().trim();
    if (filename != null && filename.endsWith('.torrent')) return true;

    final disposition = contentDisposition?.toLowerCase() ?? '';
    return disposition.contains('.torrent');
  }

  void _showTorrentDownloadFlow(String url, {String? restoreUrl}) {
    final torrentUrl = url.trim();
    if (torrentUrl.isEmpty || !mounted || _closing) return;
    if (_torrentSheetOpen && _activeTorrentUrl == torrentUrl) return;

    _torrentSheetOpen = true;
    _activeTorrentUrl = torrentUrl;
    if (mounted) {
      final restoredUrl = (restoreUrl?.trim().isNotEmpty ?? false)
          ? restoreUrl!.trim()
          : _lastLoadedPageUrl.trim();
      setState(() {
        if (restoredUrl.isNotEmpty) {
          _currentUrl = restoredUrl;
        }
        _isLoading = false;
        _progress = 0;
      });
    }

    var selectedDownloader = false;
    showAppSheet<void>(
      context: context,
      title: '选择下载器',
      showDefaultHeader: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        maxWidth: DownloaderSelectSheet.desktopWidth,
      ),
      builder: (sheetContext) => DownloaderSelectSheet(
        useDefaultHeader: true,
        onSelected: (downloader) async {
          selectedDownloader = true;
          await closeAppSheet(sheetContext);
          await Future<void>.delayed(const Duration(milliseconds: 80));
          if (!mounted || _closing) return;
          final cookie = await _cookieHeaderFor(torrentUrl);
          if (!mounted || _closing) return;
          final torrent = await _extractInterceptedTorrentInfo(
            torrentUrl,
            cookie: cookie,
          );
          if (!mounted || _closing) return;
          final torrentId = torrent?.tid.trim().isNotEmpty == true
              ? torrent!.tid.trim()
              : _extractTorrentIdFromBrowserUrl(torrentUrl);

          await showAppSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            constraints: const BoxConstraints(
              maxWidth: PushTorrentSheet.desktopWidth,
            ),
            builder: (_) => PushTorrentSheet(
              downloader: downloader,
              torrent: torrent,
              initialUrl: torrentUrl,
              initialIds: torrentId.isEmpty
                  ? const <String>[]
                  : <String>[torrentId],
              initialCookie: cookie,
              initialSiteId: widget.siteId,
            ),
          ).whenComplete(() {
            _torrentSheetOpen = false;
            _activeTorrentUrl = null;
          });
        },
      ),
    ).whenComplete(() {
      if (!selectedDownloader) {
        _torrentSheetOpen = false;
        _activeTorrentUrl = null;
      }
    });
  }

  Future<String?> _localStorageSnapshotFor(String url) async {
    final controller = _controller;
    if (controller == null || _closing) return null;

    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      AppLogger.warn('无效的 URL，无法提取 localStorage: $url');
      return null;
    }

    try {
      final raw = await controller.evaluateJavascript(
        source: r'''
(() => {
  try {
    const keys = [];
    const shouldSkip = (key) => key === 'mySite' || key === 'myUid' || key === 'sysinfo.setNews';
    for (let i = 0; i < window.localStorage.length; i += 1) {
      const key = window.localStorage.key(i);
      if (key && !shouldSkip(key)) keys.push(key);
    }
    const pairs = keys.map((key) => {
      const value = window.localStorage.getItem(key);
      return `${key}=${value === undefined || value === null ? '' : String(value)}`;
    });
    return pairs.length === 0 ? '' : pairs.join('; ');
  } catch (_) {
    return null;
  }
})();
''',
      );
      if (raw == null) return null;
      final text = raw is String ? raw.trim() : jsonEncode(raw);
      AppLogger.info('从 WebView 提取 localStorage 长度: ${text.length} 字符');
      return text;
    } catch (e, st) {
      AppLogger.error('读取 localStorage 失败', e, st);
      return null;
    }
  }

  Future<String?> _localStorageRawSnapshotFor(String url) async {
    final controller = _controller;
    if (controller == null || _closing) return null;

    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      AppLogger.warn('无效的 URL，无法提取 localStorage: $url');
      return null;
    }

    try {
      final raw = await controller.evaluateJavascript(
        source: r'''
(() => {
  try {
    const keys = [];
    for (let i = 0; i < window.localStorage.length; i += 1) {
      const key = window.localStorage.key(i);
      if (key) keys.push(key);
    }
    const pairs = keys.sort().map((key) => {
      const value = window.localStorage.getItem(key);
      return `${key}=${value === undefined || value === null ? '' : String(value)}`;
    });
    return pairs.length === 0 ? '' : pairs.join('; ');
  } catch (_) {
    return null;
  }
})();
''',
      );
      if (raw == null) return null;
      final text = raw is String ? raw.trim() : jsonEncode(raw);
      AppLogger.info('从 WebView 提取未过滤 localStorage 长度: ${text.length} 字符');
      return text;
    } catch (e, st) {
      AppLogger.error('读取未过滤 localStorage 失败', e, st);
      return null;
    }
  }

  Future<String?> _cookieHeaderFor(String url) async {
    // 不再使用配置的 Cookie，总是从 WebView 中提取最新的 Cookie
    // 这样可以避免使用过期或无效的 Cookie

    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      AppLogger.warn('无效的 URL，无法提取 Cookie: $url');
      return null;
    }

    try {
      // 只使用 scheme + host 来获取该域名下的所有 Cookie，不包含 path
      final domainUrl = '${uri.scheme}://${uri.host}';
      AppLogger.info('从 WebView 提取最新 Cookie: $domainUrl');

      final cookies = await CookieManager.instance().getCookies(
        url: WebUri(domainUrl),
      );
      AppLogger.info('从 WebView 获取到 ${cookies.length} 个 Cookie');

      if (cookies.isEmpty) {
        AppLogger.warn('未获取到任何 Cookie，可能未登录或 Cookie 已过期');
        return null;
      }

      // 打印所有 Cookie 的详细信息用于调试
      for (var i = 0; i < cookies.length; i++) {
        final cookie = cookies[i];
        AppLogger.info(
          'Cookie[$i]: ${cookie.name}=${cookie.value.substring(0, cookie.value.length > 30 ? 30 : cookie.value.length)}... (domain: ${cookie.domain}, path: ${cookie.path})',
        );
      }

      final pairs = cookies
          .where((cookie) => cookie.name.isNotEmpty)
          .map((cookie) => '${cookie.name}=${cookie.value}')
          .toList();

      if (pairs.isEmpty) {
        AppLogger.warn('没有有效的 Cookie');
        return null;
      }

      final cookieString = pairs.join('; ');
      AppLogger.info('最终 Cookie 字符串长度: ${cookieString.length} 字符');
      AppLogger.info(
        'Cookie 预览: ${cookieString.substring(0, cookieString.length > 100 ? 100 : cookieString.length)}...',
      );

      return cookieString;
    } catch (e, st) {
      AppLogger.error('读取 Cookie 失败', e, st);
      return null;
    }
  }

  String _displayUrl(String url) {
    return _accessUrlText();
  }

  String _accessUrlText() {
    final current = _currentUrl.trim();
    if (current.isNotEmpty) return current;
    return widget.url.trim();
  }

  Future<void> _showSiteTimeline() async {
    if (!mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    final websites =
        container.read(websiteListProvider).value ?? const <WebSite>[];
    final mySites =
        container.read(siteInfoListProvider).value ?? const <SiteInfo>[];
    if (websites.isEmpty) {
      Toast.warning('暂无站点配置');
      return;
    }

    final byName = <String, SiteInfo>{};
    for (final site in mySites) {
      byName[site.site.trim().toLowerCase()] = site;
    }

    final entries = websites.map((website) {
      final owned = byName[website.name.trim().toLowerCase()];
      return _SiteTimelineEntry(website: website, mySite: owned);
    }).toList();

    var ownership = _TimelineOwnership.all;
    var inviteFilter = _TimelineInviteFilter.all;
    var ascending = true;
    final visibleFields = <String, bool>{
      'duration': true,
      'uploaded': true,
      'downloaded': true,
      'invitation': true,
      'username': true,
      'email': true,
      'uid': true,
    };

    await shadcn.showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final cs = shadcn.Theme.of(dialogContext).colorScheme;
          final ownedEntries = <_SiteTimelineEntry>[];
          final unownedEntries = <_SiteTimelineEntry>[];
          for (final entry in entries) {
            if (entry.isOwned) {
              ownedEntries.add(entry);
            } else {
              unownedEntries.add(entry);
            }
          }

          bool matches(_SiteTimelineEntry entry) {
            if (ownership == _TimelineOwnership.ownedOnly && !entry.isOwned) {
              return false;
            }
            if (ownership == _TimelineOwnership.unownedOnly && entry.isOwned) {
              return false;
            }
            final invites = entry.invitationCount;
            if (inviteFilter == _TimelineInviteFilter.has && invites <= 0) {
              return false;
            }
            if (inviteFilter == _TimelineInviteFilter.none && invites > 0) {
              return false;
            }
            return true;
          }

          final filteredOwned = ownedEntries.where(matches).toList()
            ..sort((a, b) {
              final at = a.registeredAt;
              final bt = b.registeredAt;
              if (at == null && bt == null) {
                return a.displayName.compareTo(b.displayName);
              }
              if (at == null) return 1;
              if (bt == null) return -1;
              final cmp = at.compareTo(bt);
              return ascending ? cmp : -cmp;
            });
          final filteredUnowned = unownedEntries.where(matches).toList()
            ..sort((a, b) => a.displayName.compareTo(b.displayName));
          final displayList = <_SiteTimelineEntry>[
            ...filteredOwned,
            ...filteredUnowned,
          ];

          Widget fieldLine(String label, String value) {
            return Row(
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: cs.mutedForeground),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 12, color: cs.foreground),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }

          Widget openUnownedAction(_SiteTimelineEntry entry) {
            return shadcn.Button.ghost(
              onPressed: () async {
                final urls = entry.website.url
                    .where((e) => e.trim().isNotEmpty)
                    .toList();
                if (urls.isEmpty) {
                  Toast.warning('该站点未配置可用 URL');
                  return;
                }
                if (urls.length == 1) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  BrowserPage.open(
                    context,
                    url: urls.first,
                    title: entry.displayName,
                    siteId: entry.website.name,
                    website: entry.website,
                  );
                  return;
                }
                final selected = await shadcn.showDialog<String>(
                  context: dialogContext,
                  builder: (ctx) => shadcn.AlertDialog(
                    title: const Text('选择站点地址'),
                    content: SizedBox(
                      width: 520,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final url in urls)
                              ListTile(
                                title: Text(
                                  url,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => Navigator.of(ctx).pop(url),
                              ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      shadcn.Button.outline(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('取消'),
                      ),
                    ],
                  ),
                );
                if (selected == null || selected.isEmpty) return;
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                BrowserPage.open(
                  context,
                  url: selected,
                  title: entry.displayName,
                  siteId: entry.website.name,
                  website: entry.website,
                );
              },
              child: const Text('打开'),
            );
          }

          return shadcn.AlertDialog(
            title: const Text('站点时间轴'),
            content: SizedBox(
              width: context.isMobile ? double.infinity : 860,
              height: MediaQuery.of(dialogContext).size.height * 0.78,
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      shadcn.Button.secondary(
                        onPressed: () => setState(() {
                          ownership = switch (ownership) {
                            _TimelineOwnership.all =>
                              _TimelineOwnership.ownedOnly,
                            _TimelineOwnership.ownedOnly =>
                              _TimelineOwnership.unownedOnly,
                            _TimelineOwnership.unownedOnly =>
                              _TimelineOwnership.all,
                          };
                        }),
                        child: Text(switch (ownership) {
                          _TimelineOwnership.all => '全部站点',
                          _TimelineOwnership.ownedOnly => '仅拥有站点',
                          _TimelineOwnership.unownedOnly => '未拥有站点',
                        }),
                      ),
                      shadcn.Button.secondary(
                        onPressed: () => setState(() {
                          inviteFilter = switch (inviteFilter) {
                            _TimelineInviteFilter.all =>
                              _TimelineInviteFilter.has,
                            _TimelineInviteFilter.has =>
                              _TimelineInviteFilter.none,
                            _TimelineInviteFilter.none =>
                              _TimelineInviteFilter.all,
                          };
                        }),
                        child: Text(switch (inviteFilter) {
                          _TimelineInviteFilter.all => '邀请：全部',
                          _TimelineInviteFilter.has => '邀请：有邀请',
                          _TimelineInviteFilter.none => '邀请：无邀请',
                        }),
                      ),
                      shadcn.Button.secondary(
                        onPressed: () => setState(() => ascending = !ascending),
                        child: Text(ascending ? '注册时间正序' : '注册时间倒序'),
                      ),
                      shadcn.OverlayManagerLayer(
                        popoverHandler: const shadcn.PopoverOverlayHandler(),
                        tooltipHandler:
                            const shadcn.FixedTooltipOverlayHandler(),
                        menuHandler: const shadcn.PopoverOverlayHandler(),
                        child: Builder(
                          builder: (menuContext) => shadcn.Button.ghost(
                            onPressed: () => shadcn.showDropdown<void>(
                              context: menuContext,
                              alignment: Alignment.topCenter,
                              offset: const Offset(0, 8),
                              consumeOutsideTaps: false,
                              builder: (_) => AppDropdownMenu(
                                children: [
                                  const shadcn.MenuLabel(child: Text('显示字段')),
                                  const shadcn.MenuDivider(),
                                  for (final item in const [
                                    ('duration', '注册时长'),
                                    ('uploaded', '上传量'),
                                    ('downloaded', '下载量'),
                                    ('invitation', '邀请数'),
                                    ('username', '用户名'),
                                    ('email', '邮箱'),
                                    ('uid', 'UID'),
                                  ])
                                    shadcn.MenuButton(
                                      onPressed: (_) => setState(() {
                                        visibleFields[item.$1] =
                                            !(visibleFields[item.$1] ?? true);
                                      }),
                                      child: Row(
                                        children: [
                                          Icon(
                                            (visibleFields[item.$1] ?? true)
                                                ? shadcn.LucideIcons.check
                                                : shadcn.LucideIcons.minus,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(item.$2),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            child: const Text('字段'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: displayList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final entry = displayList[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cs.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.displayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: cs.foreground,
                                      ),
                                    ),
                                  ),
                                  if (!entry.isOwned)
                                    shadcn.OutlineBadge(
                                      child: const Text('未添加'),
                                    ),
                                  if (!entry.isOwned) ...[
                                    const SizedBox(width: 8),
                                    openUnownedAction(entry),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (visibleFields['duration'] == true)
                                fieldLine('注册时长', entry.durationText),
                              if (visibleFields['uploaded'] == true)
                                fieldLine('上传量', entry.uploadedText),
                              if (visibleFields['downloaded'] == true)
                                fieldLine('下载量', entry.downloadedText),
                              if (visibleFields['invitation'] == true)
                                fieldLine('邀请数', '${entry.invitationCount}'),
                              if (visibleFields['username'] == true)
                                fieldLine('用户名', entry.usernameText),
                              if (visibleFields['email'] == true)
                                fieldLine('邮箱', entry.emailText),
                              if (visibleFields['uid'] == true)
                                fieldLine('UID', entry.uidText),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              shadcn.Button.outline(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('关闭'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showBonusExchangeSheet(WebSite website) async {
    if (!mounted || _closing) return;
    final controller = _controller;
    if (controller == null) return;
    try {
      final rawData = await controller.evaluateJavascript(source: _buildBonusPageExtractScript());
      if (!mounted || _closing) return;
      final parsed = _parseBonusPageData(rawData);
      if (parsed == null) { Toast.warning('无法识别魔力值兑换页面结构'); return; }
      final items = parsed.items;
      var currentBonus = parsed.currentBonus;
      if (website.myBonusRule.trim().isNotEmpty) {
        final ruleBonus = await _extractBonusByRule(website.myBonusRule.trim());
        if (ruleBonus > 0) currentBonus = ruleBonus;
      }
      _bonusCurrent = currentBonus;
      AppLogger.info('魔力值页面提取: bonus=$currentBonus, items=${items.length}');
      if (items.isEmpty) { Toast.warning('未找到可兑换项目'); return; }
      final cookie = await _cookieHeaderFor(_currentUrl);
      if (!mounted || _closing) return;
      final result = await showDialog<_BonusExchangeResult>(
        context: context,
        builder: (_) => _BonusExchangeDialog(items: items, currentBonus: currentBonus,
          onExchange: (item, quantity, delaySeconds) async {
            Navigator.pop(context);
            await _executeBonusExchange(website: website, item: item, quantity: quantity, cookie: cookie, delaySeconds: delaySeconds);
          },
        ),
      );
    } catch (e, st) { AppLogger.error('提取魔力值页面信息失败', e, st); if (mounted) Toast.error('提取魔力值页面信息失败'); }
  }

  String _buildBonusPageExtractScript() {
    return r'''
(() => {
  const cleanText = (v) => (v || '').replace(/\u00a0/g, ' ').replace(/\s+/g, ' ').trim();
  const parseNum = (t) => { const s = (t || '').replace(/,/g, '').replace(/[^0-9.]/g, ''); const m = s.match(/(\d+\.?\d*)/); return m ? parseFloat(m[1]) : 0; };
  let currentBonus = 0;
  const bodyText = document.body ? document.body.innerText : '';
  const bonusMatch = bodyText.match(/([\d,]+\.?\d*)\s*(魔力|bonus|karma|积分|爆米花)/i) || bodyText.match(/(魔力|bonus|karma|积分|爆米花)[：:\s]*([\d,]+\.?\d*)/i) || bodyText.match(/(当前|可用|余额|Your)[：:\s]*([\d,]+\.?\d*)/i);
  if (bonusMatch) currentBonus = parseNum(bonusMatch[1] || bonusMatch[2] || '');
  if (currentBonus <= 0) { const allNums = bodyText.match(/[\d,]+\.\d+/g) || []; for (const n of allNums) { const v = parseNum(n); if (v > 0 && v < 10000000) { currentBonus = v; break; } } }
  const items = []; const seen = new Set();
  const btnTexts = ['exchange','兑换','购买','buy','赠送','捐赠','慈善捐赠','交换'];
  const isExchangeForm = (form) => {
    const action = (form.getAttribute('action') || '').toLowerCase();
    const method = (form.getAttribute('method') || '').toLowerCase();
    if (method !== 'post') return false;
    if (action.includes('exchange') || action.includes('buy') || action.includes('bonus')) return true;
    const btn = form.querySelector('input[type="submit"], button[type="submit"]');
    if (btn) { const txt = cleanText(btn.value || btn.innerText).toLowerCase(); if (btnTexts.some(k => txt.includes(k))) return true; }
    return false;
  };
  const findOptionInTr = (tr) => {
    if (!tr) return '';
    const optInput = tr.querySelector('input[name="option"]');
    if (optInput && optInput.value) return optInput.value;
    const firstCell = tr.querySelector('td');
    if (firstCell) { const t = cleanText(firstCell.innerText); if (/^\d+$/.test(t)) return t; }
    return '';
  };
  const extractName = (el) => {
    if (!el) return '';
    const h = el.querySelector('h1, h2, h3'); if (h) return cleanText(h.innerText);
    const div = el.querySelector('.font-bold, [class*="title"], [class*="name"]'); if (div) { const t = cleanText(div.innerText); if (t.length > 1 && t.length <= 60) return t; }
    const b = el.querySelector('b, strong'); if (b) { const t = cleanText(b.innerText); if (t.length > 1 && t.length <= 60 && !t.includes('注意')) return t; }
    return '';
  };
  const extractCost = (el) => {
    if (!el) return 0;
    const pe = el.querySelector('.mybonus-exchange-card__points span, .mybonus-exchange-card__points strong');
    if (pe) { const v = parseNum(cleanText(pe.innerText)); if (v > 0) return v; }
    const spans = el.querySelectorAll('span.red, span[class*="price"], span[class*="cost"], .break-all');
    for (const s of spans) { const v = parseNum(cleanText(s.innerText)); if (v > 0 && v < 100000000) return v; }
    const elText = cleanText(el.innerText);
    const cm = elText.match(/([\d,]+\.?\d*)\s*(Points?|魔力|bonus|karma|爆米花|积分|憨豆)/i) || elText.match(/(魔力|bonus|karma|积分|爆米花|憨豆)[：:\s]*([\d,]+\.?\d*)/i);
    if (cm) { const v = parseNum(cm[1] || cm[2] || ''); if (v > 0) return v; }
    const nums = elText.match(/\d[\d,]+/g) || [];
    for (const n of nums) { const v = parseNum(n); if (v >= 25 && v < 100000000) return v; }
    return 0;
  };
    const extractItem = (form, ov, container) => {
      if (!ov || seen.has(ov)) return;
      let submit = form.querySelector('input[type="submit"], button[type="submit"]');
      let btnText = submit ? cleanText(submit.value || submit.innerText) : '';
      let isDisabled = submit ? submit.disabled : false;
      if (!submit && container) {
        submit = container.querySelector('input[type="submit"], button[type="submit"]');
        if (submit) { btnText = cleanText(submit.value || submit.innerText); isDisabled = submit.disabled; }
      }
      const itemName = extractName(container || form);
      if (itemName.includes('赠送') || itemName.includes('慈善') || itemName.includes('消除') || itemName.includes('头衔') || itemName.toLowerCase().includes('h&r')) return;
      const cost = extractCost(container || form);
    const hi = {}; form.querySelectorAll('input[type="hidden"]').forEach(h => { if (h.name) hi[h.name] = h.value; });
    if (!hi['option'] && ov) hi['option'] = ov;
    seen.add(ov);
    items.push({ name: itemName || 'Option ' + ov, cost, optionValue: ov, formAction: form.getAttribute('action') || '?action=exchange', disabled: isDisabled, buttonText: btnText, hiddenInputs: hi });
  };
  document.querySelectorAll('form.mybonus-exchange-card, form[class*="mybonus-exchange-card"]').forEach(form => {
    const optInput = form.querySelector('input[name="option"]'); if (!optInput) return;
    extractItem(form, optInput.value, form);
  });
  document.querySelectorAll('form').forEach(form => {
    if (!isExchangeForm(form)) return;
    const optInput = form.querySelector('input[name="option"]');
    if (!optInput || !optInput.value) return;
    if (form.closest('tr')) return;
    extractItem(form, optInput.value, form);
  });
  if (items.length === 0) {
    document.querySelectorAll('tr').forEach(tr => {
      const form = tr.querySelector('form');
      if (!form || !isExchangeForm(form)) return;
      const ov = findOptionInTr(tr);
      if (!ov || seen.has(ov)) return;
      extractItem(form, ov, tr);
    });
  }
  if (items.length === 0) {
    document.querySelectorAll('tr').forEach(tr => {
      const form = tr.querySelector('form');
      if (!form) return;
      const ov = findOptionInTr(tr);
      if (!ov || seen.has(ov)) return;
      extractItem(form, ov, tr);
    });
  }
  return JSON.stringify({ currentBonus, items });
})();
''';
  }

  _BonusPageData? _parseBonusPageData(Object? raw) {
    if (raw == null) return null;
    String jsonStr;
    if (raw is String) { jsonStr = raw; } else { jsonStr = raw.toString(); }
    if (jsonStr.startsWith('"') && jsonStr.endsWith('"')) { try { jsonStr = jsonDecode(jsonStr) as String; } catch (_) {} }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final itemsRaw = map['items'] as List<dynamic>? ?? [];
      final items = itemsRaw.map((e) {
        final m = e as Map<String, dynamic>;
        final hiddenRaw = m['hiddenInputs'] as Map<String, dynamic>? ?? {};
        return _BonusItem(name: m['name']?.toString() ?? '', cost: (m['cost'] as num?)?.toDouble() ?? 0, optionValue: m['optionValue']?.toString() ?? '', formAction: m['formAction']?.toString() ?? '', disabled: m['disabled'] == true, buttonText: m['buttonText']?.toString() ?? '', hiddenInputs: hiddenRaw.map((k, v) => MapEntry(k.toString(), v.toString())));
      }).where((i) => i.name.isNotEmpty).toList();
      return _BonusPageData(currentBonus: (map['currentBonus'] as num?)?.toDouble() ?? 0, items: items);
    } catch (e) { AppLogger.warn('解析魔力值页面数据失败: $e'); return null; }
  }

  Future<void> _executeBonusExchange({required WebSite website, required _BonusItem item, required int quantity, required String? cookie, required int delaySeconds}) async {
    final controller = _controller;
    if (controller == null || _closing || !mounted) return;
    setState(() { _bonusExchanging = true; _bonusPaused = false; _bonusCancelled = false; });
    try {
      setState(() { _bonusItemName = item.name; _bonusCurrentIdx = 1; _bonusTotal = quantity; _bonusRemaining = _bonusCurrent; _bonusCountdown = 0; _bonusDelaySeconds = delaySeconds; });
      for (var i = 0; i < quantity; i++) {
        if (!mounted || _closing || _bonusCancelled) break;
        while (_bonusPaused && mounted && !_closing && !_bonusCancelled) { await Future.delayed(const Duration(milliseconds: 300)); }
        if (_bonusCancelled) break;
        setState(() { _bonusCurrentIdx = i + 1; _bonusCountdown = 0; });
        final result = await controller.evaluateJavascript(source: _buildBonusSubmitScript(item, i + 1));
        final resultStr = result?.toString() ?? '';
        AppLogger.info('魔力值兑换 [$i/$quantity]: $resultStr');
        if (resultStr.contains('error') || resultStr.contains('fail')) { if (mounted) Toast.warning('第 ${i + 1} 次兑换可能失败'); break; }
        final afterBonus = _bonusCurrent - item.cost * (i + 1);
        setState(() => _bonusRemaining = afterBonus > 0 ? afterBonus : 0);
        if (afterBonus < item.cost) { if (mounted) Toast.info('魔力值不足，停止兑换'); break; }
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!mounted || _closing || _bonusCancelled) break;
        if (i < quantity - 1) {
          for (var d = delaySeconds; d > 0; d--) {
            if (!mounted || _closing || _bonusCancelled) break;
            while (_bonusPaused && mounted && !_closing && !_bonusCancelled) { setState(() => _bonusCountdown = d); await Future.delayed(const Duration(milliseconds: 300)); }
            if (_bonusCancelled) break;
            setState(() => _bonusCountdown = d);
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }
    } catch (e, st) { AppLogger.error('执行魔力值兑换失败', e, st); if (mounted) Toast.error('兑换失败'); }
    finally {
      if (mounted) {
        setState(() { _bonusExchanging = false; _bonusPaused = false; _bonusCancelled = false; _bonusCountdown = 0; });
        _controller?.reload().then((_) async {
          if (!mounted || _closing) return;
          final ws = _websiteConfigForCurrentSite();
          if (ws != null && ws.myBonusRule.trim().isNotEmpty) {
            final bonus = await _extractBonusByRule(ws.myBonusRule.trim());
            if (bonus > 0 && mounted) setState(() => _bonusCurrent = bonus);
          }
        });
      }
    }
  }

  String _buildBonusSubmitScript(_BonusItem item, int index) {
    final formAction = item.formAction.isNotEmpty ? item.formAction : '?action=exchange';
    final allInputs = <String, String>{}..addAll(item.hiddenInputs)..['option'] = item.optionValue;
    final inputsJson = jsonEncode(allInputs);
    return '''
(() => {
  try {
    const inputs = $inputsJson;
    const trs = document.querySelectorAll('tr');
    for (const tr of trs) {
      const cells = tr.querySelectorAll('td');
      if (cells.length < 1) continue;
      const firstCell = (cells[0].innerText || '').trim().split(/\\s/)[0];
      if (firstCell === '${item.optionValue}') {
        const btn = tr.querySelector('input[type="submit"], button[type="submit"]');
        if (btn && !btn.disabled) { btn.click(); return 'clicked_' + $index; }
      }
    }
    const forms = document.querySelectorAll('form');
    for (const form of forms) {
      const optIn = form.querySelector('input[name="option"]');
      if (optIn && optIn.value === '${item.optionValue}') {
        const btn = form.querySelector('input[type="submit"], button[type="submit"]');
        if (btn && !btn.disabled) { btn.click(); return 'form_click_' + $index; }
      }
    }
    const f = document.createElement('form');
    f.method = 'POST'; f.action = '$formAction';
    for (const [k, v] of Object.entries(inputs)) { const i = document.createElement('input'); i.type = 'hidden'; i.name = k; i.value = v; f.appendChild(i); }
    document.body.appendChild(f); f.submit();
    return 'fallback_' + $index;
  } catch (e) { return 'error: ' + e.message; }
})();
''';
  }

  Future<double> _extractBonusByRule(String rule) async {
    final controller = _controller;
    if (controller == null || rule.isEmpty) return 0;
    try {
      final escaped = jsonEncode(rule);
      final raw = await controller.evaluateJavascript(source: '''
(() => {
  try {
    const rule = $escaped;
    const result = document.evaluate(rule, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
    const el = result.singleNodeValue;
    if (!el) return '';
    const text = (el.innerText || el.textContent || '').trim();
    const cleaned = text.replace(/,/g, '').replace(/[^0-9.]/g, '');
    const m = cleaned.match(/(\\d+\\.?\\d*)/);
    return m ? m[1] : '';
  } catch (_) { return ''; }
})();
''');
      final str = raw?.toString().replaceAll('"', '').trim() ?? '';
      if (str.isNotEmpty) { final v = double.tryParse(str); if (v != null && v > 0) return v; }
    } catch (_) {}
    return 0;
  }

  Widget _buildBonusFlutterOverlay(shadcn.ColorScheme cs) {
    final progress = _bonusTotal > 0 ? (_bonusCurrentIdx / _bonusTotal * 100).toInt() : 0;
    return Container(
      width: 200, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.88), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12)]),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          shadcn.Icon(_bonusPaused ? shadcn.LucideIcons.pause : shadcn.LucideIcons.play, size: 14, color: _bonusPaused ? Colors.redAccent : const Color(0xFF10B981)),
          const SizedBox(width: 4),
          Expanded(child: Text(_bonusItemName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text('$_bonusCurrentIdx/$_bonusTotal', style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        shadcn.LinearProgressIndicator(value: progress / 100.0, minHeight: 4, backgroundColor: Colors.white.withOpacity(0.15), color: const Color(0xFFF59E0B)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('剩余魔力 ${_bonusRemaining.toStringAsFixed(1)}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 10)),
          if (_bonusCountdown > 0) Text('⏱ ${_bonusCountdown}s', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 10)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => setState(() => _bonusPaused = !_bonusPaused), child: Container(padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: _bonusPaused ? const Color(0xFF10B981) : const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(6)), child: Center(child: Text(_bonusPaused ? '▶ 继续' : '⏸ 暂停', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))))),
          const SizedBox(width: 6),
          Expanded(child: GestureDetector(onTap: () => setState(() => _bonusCancelled = true), child: Container(padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(6)), child: const Center(child: Text('⏹ 停止', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))))),
        ]),
      ]),
    );
  }
}

// ────────────────── 魔力值兑换数据类 ──────────────────

enum _TimelineOwnership { all, ownedOnly, unownedOnly }

enum _TimelineInviteFilter { all, has, none }

class _SiteTimelineEntry {
  final WebSite website;
  final SiteInfo? mySite;

  const _SiteTimelineEntry({required this.website, required this.mySite});

  bool get isOwned => mySite != null;

  String get displayName {
    final nick = mySite?.nickname.trim() ?? website.nickname.trim();
    if (nick.isNotEmpty) return nick;
    final site = mySite?.site.trim() ?? website.name.trim();
    if (site.isNotEmpty) return site;
    return '未命名站点';
  }

  DateTime? get registeredAt {
    final raw = mySite?.timeJoin?.trim() ?? '';
    if (raw.isEmpty) return null;
    return parseFlexibleLocalDateTime(raw);
  }

  String get durationText => mySite?.durationText ?? '-';

  int get uploadedBytes => mySite?.latestStatus?.uploaded ?? 0;

  int get downloadedBytes => mySite?.latestStatus?.downloaded ?? 0;

  int get invitationCount => mySite?.latestStatus?.invitation ?? 0;

  String get uploadedText =>
      uploadedBytes > 0 ? formatBytes(uploadedBytes) : '-';

  String get downloadedText =>
      downloadedBytes > 0 ? formatBytes(downloadedBytes) : '-';

  String get usernameText => mySite?.username?.trim().isNotEmpty == true
      ? mySite!.username!.trim()
      : '-';

  String get emailText =>
      mySite?.email?.trim().isNotEmpty == true ? mySite!.email!.trim() : '-';

  String get uidText =>
      mySite?.userId?.trim().isNotEmpty == true ? mySite!.userId!.trim() : '-';
}

class _UserAgentPreset {
  final String id;
  final String label;
  final String description;
  final String? userAgent;

  const _UserAgentPreset({
    required this.id,
    required this.label,
    required this.description,
    required this.userAgent,
  });
}

class _BrowserUserProfileRule {
  final String key;
  final String label;
  final String group;
  final String rule;

  const _BrowserUserProfileRule(this.key, this.label, this.group, this.rule);
}

class _BrowserUserProfileMetric {
  final String key;
  final String label;
  final String group;
  final String rawValue;
  final String value;

  const _BrowserUserProfileMetric({
    required this.key,
    required this.label,
    required this.group,
    required this.rawValue,
    required this.value,
  });
}

class _BrowserUserProfileDisplay {
  final IconData icon;
  final Color color;

  const _BrowserUserProfileDisplay(this.icon, this.color);
}

enum _BrowserTorrentSortKey { name, seeders, size }

class _BrowserScreenshotPiece {
  final ui.Image image;
  final double offset;

  const _BrowserScreenshotPiece({required this.image, required this.offset});
}

class _BrowserExtractedTorrent {
  final String id;
  final String title;
  final String subtitle;
  final String detailUrl;
  final String magnetUrl;
  final String category;
  final String poster;
  final String size;
  final String progress;
  final String hr;
  final String sale;
  final String saleExpire;
  final String release;
  final String seeders;
  final String leechers;
  final String completers;
  final List<String> tags;

  const _BrowserExtractedTorrent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.detailUrl,
    required this.magnetUrl,
    required this.category,
    required this.poster,
    required this.size,
    required this.progress,
    required this.hr,
    required this.sale,
    required this.saleExpire,
    required this.release,
    required this.seeders,
    required this.leechers,
    required this.completers,
    required this.tags,
  });

  String get primaryUrl => magnetUrl.isNotEmpty ? magnetUrl : detailUrl;

  bool get hasPushableUrl =>
      primaryUrl.trim().isNotEmpty || detailUrl.trim().isNotEmpty;

  String get titleSortValue =>
      (title.isNotEmpty ? title : primaryUrl).toLowerCase();

  int get seedersValue => _parseCompactInt(seeders);

  int get sizeBytes => _parseSizeToBytes(size);

  String get displaySize => _normalizeSizeText(size, sizeBytes);

  String get formattedCategory => _formatCategory(category);

  factory _BrowserExtractedTorrent.fromMap(Map<String, dynamic> map) {
    List<String> parseTags(dynamic value) {
      if (value is Iterable) {
        return value
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();
      }
      final text = value?.toString().trim() ?? '';
      return text.isEmpty ? const [] : <String>[text];
    }

    String text(dynamic value) => value?.toString().trim() ?? '';

    return _BrowserExtractedTorrent(
      id: text(
        map['id'] ?? map['tid'] ?? map['torrentId'] ?? map['torrent_id'],
      ),
      title: text(map['title']),
      subtitle: text(map['subtitle']),
      detailUrl: text(map['detailUrl']),
      magnetUrl: text(map['magnetUrl']),
      category: text(map['category']),
      poster: text(map['poster']),
      size: text(map['size']),
      progress: text(map['progress']),
      hr: text(map['hr']),
      sale: text(map['sale']),
      saleExpire: text(map['saleExpire']),
      release: text(map['release']),
      seeders: text(map['seeders']),
      leechers: text(map['leechers']),
      completers: text(map['completers']),
      tags: parseTags(map['tags']),
    );
  }

  static int _parseCompactInt(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  static String _formatCategory(String value) {
    var text = value.trim();
    if (text.isEmpty) return '';
    text = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*[/|>]+\s*'), ' · ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s*-\s*'), ' · ')
        .replaceAll(RegExp(r'\s*·\s*'), ' · ');
    return text.trim();
  }

  static int _parseSizeToBytes(String value) {
    final normalized = value.trim().replaceAll(',', '');
    final match = RegExp(
      r'([0-9]+(?:\.[0-9]+)?)\s*([kmgtpe]?i?b?|bytes?)',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (match == null) return 0;
    final number = double.tryParse(match.group(1) ?? '') ?? 0;
    var unit = (match.group(2) ?? '').toUpperCase();
    if (unit == 'BYTE' || unit == 'BYTES') unit = 'B';
    if (unit.length == 1 && unit != 'B') unit = '${unit}B';
    const powers = {
      'B': 0,
      'KB': 1,
      'KIB': 1,
      'MB': 2,
      'MIB': 2,
      'GB': 3,
      'GIB': 3,
      'TB': 4,
      'TIB': 4,
      'PB': 5,
      'PIB': 5,
      'EB': 6,
      'EIB': 6,
    };
    final power = powers[unit] ?? 0;
    var multiplier = 1.0;
    for (var i = 0; i < power; i += 1) {
      multiplier *= 1024;
    }
    return (number * multiplier).round();
  }

  static String _normalizeSizeText(String raw, int bytes) {
    final text = raw.trim();
    if (text.isEmpty) return bytes > 0 ? formatBytes(bytes) : '';
    if (RegExp(r'[a-zA-Z\u4e00-\u9fa5]').hasMatch(text)) {
      return text.replaceAll(RegExp(r'\s+'), ' ').replaceAllMapped(
        RegExp(
          r'([0-9]+(?:\.[0-9]+)?)\s*([kmgtpe]?i?b?|bytes?)',
          caseSensitive: false,
        ),
        (match) {
          final number = match.group(1) ?? '';
          var unit = (match.group(2) ?? '').toUpperCase();
          if (unit == 'BYTE' || unit == 'BYTES') unit = 'B';
          if (unit.length == 1 && unit != 'B') unit = '${unit}B';
          return '$number $unit';
        },
      );
    }
    return bytes > 0 ? formatBytes(bytes) : text;
  }
}

class _BonusItem {
  final String name;
  final double cost;
  final String optionValue;
  final String formAction;
  final bool disabled;
  final String buttonText;
  final Map<String, String> hiddenInputs;
  const _BonusItem({required this.name, required this.cost, required this.optionValue, required this.formAction, required this.disabled, required this.buttonText, required this.hiddenInputs});
}

class _BonusPageData {
  final double currentBonus;
  final List<_BonusItem> items;
  const _BonusPageData({required this.currentBonus, required this.items});
}

class _BonusExchangeResult {
  final _BonusItem item;
  final int quantity;
  final int delaySeconds;
  const _BonusExchangeResult({required this.item, required this.quantity, required this.delaySeconds});
}

class _BonusExchangeDialog extends StatefulWidget {
  final List<_BonusItem> items;
  final double currentBonus;
  final Future<void> Function(_BonusItem item, int quantity, int delaySeconds) onExchange;
  const _BonusExchangeDialog({required this.items, required this.currentBonus, required this.onExchange});
  @override
  State<_BonusExchangeDialog> createState() => _BonusExchangeDialogState();
}

class _BonusExchangeDialogState extends State<_BonusExchangeDialog> {
  int _selectedIndex = 0;
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _delayController = TextEditingController(text: '15');
  List<_BonusItem> get _exchangeable => widget.items.where((i) => !i.disabled).toList();

  @override
  void initState() { super.initState(); if (_exchangeable.isNotEmpty) _selectedIndex = 0; }
  @override
  void dispose() { _qtyController.dispose(); _delayController.dispose(); super.dispose(); }
  int _maxQty(_BonusItem item) => item.cost <= 0 ? 0 : (widget.currentBonus / item.cost).floor();
  int _parseQty() => int.tryParse(_qtyController.text.trim()) ?? 0;
  void _changeQty(int delta) { final cur = int.tryParse(_qtyController.text.trim()) ?? 0; final max = _exchangeable.isNotEmpty ? _maxQty(_exchangeable[_selectedIndex]) : 0; _qtyController.text = (cur + delta).clamp(1, max > 0 ? max : 1).toString(); setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final exchangeable = _exchangeable;
    if (exchangeable.isEmpty) {
      return Dialog(child: Container(width: 480, padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('没有可兑换的项目', style: TextStyle(color: cs.foreground)),
        const SizedBox(height: 16),
        shadcn.Button.secondary(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
      ])));
    }
    final si = _selectedIndex.clamp(0, exchangeable.length - 1);
    if (_selectedIndex != si) _selectedIndex = si;
    final item = exchangeable[_selectedIndex];
    final max = _maxQty(item);
    return Dialog(
      child: Container(
        width: 480,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              shadcn.Icon(shadcn.LucideIcons.gem, size: 18, color: const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text('魔力值兑换', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.foreground)),
              const Spacer(),
              Text('当前: ${widget.currentBonus.toStringAsFixed(1)}', style: TextStyle(fontSize: 12, color: cs.foreground.withValues(alpha: 0.5))),
            ]),
            const SizedBox(height: 12),
            Flexible(child: ListView.separated(
              shrinkWrap: true, itemCount: exchangeable.length, separatorBuilder: (_, _) => const SizedBox(height: 3),
              itemBuilder: (_, index) {
                final it = exchangeable[index]; final sel = index == _selectedIndex; final mq = _maxQty(it);
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? cs.primary.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sel ? cs.primary : cs.border, width: sel ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(it.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.foreground)),
                        const SizedBox(height: 2),
                        Text('魔力 ${it.cost.toStringAsFixed(1)} / 次', style: TextStyle(fontSize: 11, color: cs.foreground.withValues(alpha: 0.5))),
                      ])),
                      Text(mq > 0 ? 'x$mq' : '不足', style: TextStyle(fontSize: 11, color: mq > 0 ? const Color(0xFF10B981) : cs.foreground.withValues(alpha: 0.3))),
                    ]),
                  ),
                );
              },
            )),
            const SizedBox(height: 10),
            Row(children: [
              Text('数量:', style: TextStyle(fontSize: 12, color: cs.foreground.withValues(alpha: 0.6))),
              const SizedBox(width: 6),
              GestureDetector(onTap: () => _changeQty(-1), child: Container(width: 28, height: 28, decoration: BoxDecoration(border: Border.all(color: cs.border), borderRadius: BorderRadius.circular(4)), child: shadcn.Icon(shadcn.LucideIcons.minus, size: 14, color: cs.foreground.withValues(alpha: 0.6)))),
              const SizedBox(width: 4),
              SizedBox(width: 48, height: 28, child: TextField(controller: _qtyController, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: cs.foreground), decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: cs.border))), onChanged: (_) => setState(() {}))),
              const SizedBox(width: 4),
              GestureDetector(onTap: () => _changeQty(1), child: Container(width: 28, height: 28, decoration: BoxDecoration(border: Border.all(color: cs.border), borderRadius: BorderRadius.circular(4)), child: shadcn.Icon(shadcn.LucideIcons.plus, size: 14, color: cs.foreground.withValues(alpha: 0.6)))),
              const SizedBox(width: 6),
              GestureDetector(onTap: () { _qtyController.text = max.toString(); setState(() {}); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: cs.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: Text('MAX', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)))),
              const Spacer(),
              Text('间隔:', style: TextStyle(fontSize: 12, color: cs.foreground.withValues(alpha: 0.5))),
              const SizedBox(width: 4),
              SizedBox(width: 40, height: 28, child: TextField(controller: _delayController, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: cs.foreground), decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: cs.border))))),
              Text('s', style: TextStyle(fontSize: 11, color: cs.foreground.withValues(alpha: 0.4))),
            ]),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              shadcn.Button.secondary(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              const SizedBox(width: 8),
              shadcn.Button.primary(
                onPressed: max > 0 && _parseQty() > 0 ? () { final qty = _parseQty(); if (qty > 0) { final d = (int.tryParse(_delayController.text.trim()) ?? 15).clamp(12, 120); Navigator.pop(context, _BonusExchangeResult(item: item, quantity: qty, delaySeconds: d)); } } : null,
                child: const Text('兑换'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
