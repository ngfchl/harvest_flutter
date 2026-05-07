import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';
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

  const BrowserPage({
    super.key,
    required this.url,
    this.title,
    this.cookie,
    this.userAgent,
  });

  /// 快捷打开
  static void open(
    BuildContext context, {
    required String url,
    String? title,
    String? cookie,
    String? userAgent,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrowserPage(
          url: url,
          title: title,
          cookie: cookie,
          userAgent: userAgent,
        ),
      ),
    );
  }

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? _controller;
  final ChromeSafariBrowser _chromeSafariBrowser = ChromeSafariBrowser();
  String _currentUrl = '';
  String _currentTitle = '';
  String? _activeUserAgent = _safariIphoneUserAgent;
  String _activeUserAgentId = 'safari_iphone';
  String? _defaultUserAgent;
  double _progress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isLoading = true;
  bool _cookiesReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _currentTitle = widget.title ?? '';
    _prepareCookies();
    _loadDefaultUserAgent();
  }

  // ────────────────── Cookie 注入 ──────────────────

  Future<void> _prepareCookies() async {
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

    if (mounted) setState(() => _cookiesReady = true);
  }

  // ────────────────── 导航状态 ──────────────────

  Future<void> _updateNavState() async {
    if (_controller == null || !mounted) return;
    final back = await _controller!.canGoBack();
    final forward = await _controller!.canGoForward();
    if (mounted) {
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
  void dispose() {
    if (_chromeSafariBrowser.isOpened()) {
      _chromeSafariBrowser.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_canGoBack) {
          _controller?.goBack();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: cs.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── 顶部：标题 + 进度条 ──
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
              // ── WebView ──
              Expanded(
                child: _cookiesReady
                    ? _buildWebView()
                    : const Center(child: CircularProgressIndicator()),
              ),
              // ── 底部工具栏 ──
              _buildBottomBar(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(FColors cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(FIcons.x, size: 18, color: cs.foreground),
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
          if (widget.cookie != null && widget.cookie!.isNotEmpty)
            Container(
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
                ],
              ),
            ),
          // 加载状态
          if (_isLoading) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(width: 8),
            Icon(FIcons.circleAlert, size: 14, color: const Color(0xFFF85149)),
          ],
        ],
      ),
    );
  }

  // ── 底部工具栏 ──

  Widget _buildBottomBar(FColors cs) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(top: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomBtn(cs, FIcons.arrowLeft, '后退', _canGoBack, () {
            if (_canGoBack) {
              _controller?.goBack();
            } else {
              Navigator.of(context).pop();
            }
          }),
          _bottomBtn(
            cs,
            FIcons.arrowRight,
            '前进',
            _canGoForward,
            () => _controller?.goForward(),
          ),
          _bottomBtn(
            cs,
            FIcons.refreshCw,
            '刷新',
            true,
            () => _controller?.reload(),
          ),
          _bottomBtn(cs, FIcons.copy, '复制', true, () {
            Clipboard.setData(ClipboardData(text: _currentUrl));
            Toast.success('链接已复制');
          }),
          _bottomBtn(cs, FIcons.globe, 'UA', true, _showUserAgentPicker),
          _bottomBtn(
            cs,
            FIcons.externalLink,
            'CF浏览',
            true,
            _openChromeSafariBrowser,
          ),
          _bottomBtn(cs, FIcons.share2, '分享', true, () {
            SharePlus.instance.share(
              ShareParams(text: _currentUrl, subject: _currentTitle),
            );
          }),
        ],
      ),
    );
  }

  Widget _bottomBtn(
    FColors cs,
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
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,
        transparentBackground: true,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
      },
      onLoadStart: (controller, url) {
        if (!mounted) return;
        setState(() {
          _currentUrl = url?.toString() ?? '';
          _isLoading = true;
          _error = null;
        });
      },
      onLoadStop: (controller, url) async {
        if (!mounted) return;
        setState(() {
          _currentUrl = url?.toString() ?? '';
          _isLoading = false;
        });
        _updateNavState();
        final title = await controller.getTitle();
        if (title != null && title.isNotEmpty && mounted) {
          setState(() => _currentTitle = title);
        }
      },
      onProgressChanged: (controller, progress) {
        if (!mounted) return;
        setState(() => _progress = progress / 100.0);
      },
      onReceivedError: (controller, request, error) {
        if (!mounted) return;
        setState(() {
          _error = '${error.type}: ${error.description}';
          _isLoading = false;
        });
      },
      shouldOverrideUrlLoading: (controller, action) async {
        final url = action.request.url?.toString() ?? '';
        if (url.startsWith('http://') || url.startsWith('https://')) {
          return NavigationActionPolicy.ALLOW;
        }
        return NavigationActionPolicy.CANCEL;
      },
    );
  }

  Future<void> _openChromeSafariBrowser() async {
    final url = _currentUrl.trim().isNotEmpty ? _currentUrl.trim() : widget.url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      Toast.warning('当前链接无法用浏览器打开');
      return;
    }

    final cookie = widget.cookie?.trim();
    if (cookie != null && cookie.isNotEmpty) {
      Toast.info('系统浏览器不共享站点 Cookie，可能需要在此窗口重新登录一次');
    }

    try {
      await _chromeSafariBrowser.open(
        url: WebUri(url),
        settings: ChromeSafariBrowserSettings(
          shareState: CustomTabsShareState.SHARE_STATE_ON,
          showTitle: true,
          keepAliveEnabled: true,
          enableUrlBarHiding: true,
          instantAppsEnabled: true,
          dismissButtonStyle: DismissButtonStyle.CLOSE,
          presentationStyle: ModalPresentationStyle.FULL_SCREEN,
        ),
      );
    } catch (e, st) {
      AppLogger.error('打开系统内置浏览器失败', e, st);
      Toast.error('打开系统内置浏览器失败');
    }
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

    final cs = FTheme.of(context).colors;
    await showModalBottomSheet<void>(
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
                  selected ? FIcons.check : FIcons.globe,
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
                  Navigator.of(context).pop();
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
                          ? FIcons.chevronDown
                          : FIcons.chevronRight,
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
  String _displayUrl(String url) {
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
