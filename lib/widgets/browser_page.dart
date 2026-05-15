import 'dart:async';
import 'dart:convert';

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
import 'package:harvest/widgets/app_menu.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:share_plus/share_plus.dart';

// ══════════════════════════════════════════════════════════
//  内置浏览器
// ══════════════════════════════════════════════════════════

const _safariIphoneUserAgent =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1';
const _safariMacosUserAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15';

class BrowserPage extends StatefulWidget {
  final String url;
  final String? title;
  final String? cookie;
  final String? userAgent;
  final String? siteId;
  final WebSite? website;

  const BrowserPage({
    super.key,
    required this.url,
    this.title,
    this.cookie,
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
    final effectiveBadge = badge ?? _defaultCookieBadge(targets.isNotEmpty);

    if (targets.isEmpty) return effectiveBadge;

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
  String? _activeUserAgent = _safariIphoneUserAgent;
  String _activeUserAgentId = 'safari_iphone';
  String? _defaultUserAgent;
  double _progress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isLoading = true;
  bool _cookiesReady = false;
  bool _hasReadableCookie = false;
  bool _closing = false;
  bool _torrentSheetOpen = false;
  String? _activeTorrentUrl;
  String? _error;
  bool _extractingTorrentList = false;
  bool _extractingUserProfile = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _lastLoadedPageUrl = widget.url;
    _currentTitle = widget.title ?? '';
    _hasReadableCookie = widget.cookie?.trim().isNotEmpty == true;
    _prepareCookies();
    _loadDefaultUserAgent();
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

  Future<void> _refreshReadableCookieState([String? url]) async {
    if (_closing || !mounted) return;
    final configuredCookie = widget.cookie?.trim();
    if (configuredCookie != null && configuredCookie.isNotEmpty) {
      if (!_hasReadableCookie) setState(() => _hasReadableCookie = true);
      return;
    }

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
                                : () => _extractUserProfile(userWebsite!),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    final sites =
        ProviderScope.containerOf(
          context,
          listen: false,
        ).read(siteInfoListProvider).valueOrNull ??
        const <SiteInfo>[];
    if (sites.isEmpty) return null;

    final siteId = widget.siteId?.trim().toLowerCase() ?? '';
    final currentHost = _uriHost(_currentUrl);
    final websiteName = website?.name.trim().toLowerCase() ?? '';
    final websiteNickname = website?.nickname.trim().toLowerCase() ?? '';

    for (final site in sites) {
      final siteName = site.site.trim().toLowerCase();
      final nickname = site.nickname.trim().toLowerCase();
      if (siteId.isNotEmpty && (siteName == siteId || nickname == siteId))
        return site;
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
    final controller = _controller;
    if (controller == null || _closing) return;
    try {
      await controller.loadUrl(urlRequest: URLRequest(url: WebUri(target.url)));
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
          _bottomBtn(cs, shadcn.LucideIcons.copy, '复制', true, () {
            Clipboard.setData(ClipboardData(text: _currentUrl));
            Toast.success('链接已复制');
          }),
          _bottomBtn(
            cs,
            shadcn.LucideIcons.globe,
            'UA',
            true,
            _showUserAgentPicker,
          ),
          _bottomBtn(cs, shadcn.LucideIcons.share2, '分享', true, () {
            SharePlus.instance.share(
              ShareParams(text: _currentUrl, subject: _currentTitle),
            );
          }),
        ],
      ),
    );
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
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
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
      const _UserAgentPreset(
        id: 'safari_iphone',
        label: 'Safari iPhone',
        description: 'iOS Safari Mobile',
        userAgent: _safariIphoneUserAgent,
      ),
      const _UserAgentPreset(
        id: 'safari_macos',
        label: 'Safari macOS',
        description: 'macOS Safari Desktop',
        userAgent: _safariMacosUserAgent,
      ),
      if (configuredUserAgent != null && configuredUserAgent.isNotEmpty)
        _UserAgentPreset(
          id: 'site',
          label: '站点配置',
          description: configuredUserAgent,
          userAgent: configuredUserAgent,
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

    final container = ProviderScope.containerOf(context, listen: false);
    final configs =
        container.read(websiteListProvider).valueOrNull ?? const <WebSite>[];
    final siteKey = siteId?.toLowerCase() ?? '';
    final currentHost = _uriHost(currentUrl);

    for (final config in configs) {
      if (config.name.toLowerCase() == siteKey ||
          config.nickname.toLowerCase() == siteKey) {
        return config;
      }
    }

    if (currentHost == null) return null;
    for (final config in configs) {
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
      await _showUserProfileDialog(items, website);
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
    if (text.contains(',') && text.contains('.'))
      return text.replaceAll(',', '');
    if (RegExp(r'^-?\d{1,3}(,\d{3})+$').hasMatch(text))
      return text.replaceAll(',', '');
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

  Future<void> _showUserProfileDialog(
    List<_BrowserUserProfileMetric> items,
    WebSite website,
  ) async {
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
        ).read(siteInfoListProvider).valueOrNull ??
        const <SiteInfo>[];
    final configName = website.name.trim().toLowerCase();
    final siteId = widget.siteId?.trim().toLowerCase() ?? '';
    final currentHost = _uriHost(_currentUrl);

    for (final site in sites) {
      final siteName = site.site.trim().toLowerCase();
      if (siteName.isNotEmpty && (siteName == configName || siteName == siteId))
        return site;
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
    List<_BrowserUserProfileMetric> items,
  ) async {
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
                    cookie: await _cookieHeaderFor(_currentUrl),
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
              Map<String, dynamic>.from(item as Map),
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
    String tagFilter = '';
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
            tagFilter.isEmpty ||
            item.tags.any((tag) => tag.trim() == tagFilter);
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
          tagFilter.isNotEmpty;
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
        tagFilter = '';
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
        if (tagFilter.isNotEmpty) '标签: $tagFilter',
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
                                    selectedValue: tagFilter.isEmpty,
                                    onTap: () => setDialogState(
                                      () => updateFilters(() => tagFilter = ''),
                                    ),
                                  ),
                                  for (final tag in tagOptions)
                                    filterChip(
                                      label: tag,
                                      selectedValue: tagFilter == tag,
                                      onTap: () => setDialogState(
                                        () => updateFilters(
                                          () => tagFilter = tagFilter == tag
                                              ? ''
                                              : tag,
                                        ),
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
    return SearchTorrentInfo(
      siteId: siteId,
      tid: _extractTorrentIdFromBrowserUrl(
        primaryUrl.isNotEmpty ? primaryUrl : detailUrl,
      ),
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

  Future<String?> _cookieHeaderFor(String url) async {
    final configuredCookie = widget.cookie?.trim();
    if (configuredCookie != null && configuredCookie.isNotEmpty) {
      return configuredCookie;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }

    try {
      final cookies = await CookieManager.instance().getCookies(
        url: WebUri(url),
      );
      final pairs = cookies
          .where((cookie) => cookie.name.isNotEmpty)
          .map((cookie) => '${cookie.name}=${cookie.value}')
          .toList();
      if (pairs.isEmpty) return null;
      return pairs.join('; ');
    } catch (e, st) {
      AppLogger.warn('读取种子下载 Cookie 失败: $e\n$st');
      return null;
    }
  }

  String _displayUrl(String url) {
    return _browserDisplayUrl(url);
  }

  Future<void> _showSiteTimeline() async {
    if (!mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    final websites =
        container.read(websiteListProvider).valueOrNull ?? const <WebSite>[];
    final mySites =
        container.read(siteInfoListProvider).valueOrNull ?? const <SiteInfo>[];
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
              if (at == null && bt == null)
                return a.displayName.compareTo(b.displayName);
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
}

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

class _BrowserExtractedTorrent {
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
