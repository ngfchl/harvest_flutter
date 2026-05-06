import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:share_plus/share_plus.dart';

// ══════════════════════════════════════════════════════════
//  内置浏览器
// ══════════════════════════════════════════════════════════

class BrowserPage extends StatefulWidget {
  final String url;
  final String? title;
  final String? cookie;
  final String? userAgent;

  const BrowserPage({super.key, required this.url, this.title, this.cookie, this.userAgent});

  /// 快捷打开
  static void open(BuildContext context, {required String url, String? title, String? cookie, String? userAgent}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrowserPage(url: url, title: title, cookie: cookie, userAgent: userAgent),
      ),
    );
  }

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? _controller;
  String _currentUrl = '';
  String _currentTitle = '';
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

  // ────────────────── 构建 ──────────────────

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
              Expanded(child: _cookiesReady ? _buildWebView() : const Center(child: CircularProgressIndicator())),
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
                    style: TextStyle(color: cs.foreground, fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  _displayUrl(_currentUrl),
                  style: TextStyle(color: cs.foreground.withOpacity(0.4), fontSize: 10),
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
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Cookie',
                    style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          // 加载状态
          if (_isLoading) ...[
            const SizedBox(width: 8),
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary)),
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
          _bottomBtn(cs, FIcons.arrowRight, '前进', _canGoForward, () => _controller?.goForward()),
          _bottomBtn(cs, FIcons.refreshCw, '刷新', true, () => _controller?.reload()),
          _bottomBtn(cs, FIcons.copy, '复制', true, () {
            Clipboard.setData(ClipboardData(text: _currentUrl));
            Toast.success('链接已复制');
          }),
          _bottomBtn(cs, FIcons.share2, '分享', true, () {
            SharePlus.instance.share(ShareParams(text: _currentUrl, subject: _currentTitle));
          }),
        ],
      ),
    );
  }

  Widget _bottomBtn(FColors cs, IconData icon, String label, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: enabled ? cs.foreground.withOpacity(0.7) : cs.foreground.withOpacity(0.15)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: enabled ? cs.foreground.withOpacity(0.5) : cs.foreground.withOpacity(0.15),
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
        userAgent: widget.userAgent,
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

  // ────────────────── 工具栏 ──────────────────
  String _displayUrl(String url) {
    if (url.startsWith('about:')) return url;
    try {
      final uri = Uri.parse(url);
      final display = uri.host + uri.path;
      return display.endsWith('/') ? display.substring(0, display.length - 1) : display;
    } catch (_) {
      return url;
    }
  }
}
