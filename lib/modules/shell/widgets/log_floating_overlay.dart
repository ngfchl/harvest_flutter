import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/desktop_window_controls.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

// ══════════════════════════════════════════════════════════
//  全局管理器
// ══════════════════════════════════════════════════════════

class LogOverlayManager {
  static OverlayEntry? _entry;
  static bool _visible = false;

  static bool get isVisible => _visible;

  static void show(BuildContext context) {
    if (_entry != null) return;
    final overlay =
        navigatorKey.currentState?.overlay ??
        Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      AppLogger.warn('日志浮窗打开失败：未找到可用的 Overlay');
      _entry = null;
      _visible = false;
      return;
    }

    final entry = OverlayEntry(builder: (_) => const _LogWindowWorkspace());
    overlay.insert(entry);
    _entry = entry;
    _visible = true;
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
    _visible = false;
  }

  static void toggle(BuildContext context) {
    if (_entry != null) {
      hide();
      return;
    }
    _visible = false;
    show(context);
  }
}

class _LogWindowWorkspace extends StatefulWidget {
  const _LogWindowWorkspace();

  @override
  State<_LogWindowWorkspace> createState() => _LogWindowWorkspaceState();
}

class _LogWindowWorkspaceState extends State<_LogWindowWorkspace> {
  static const double _titleBarHeight = 32;
  static const Size _minWindowSize = Size(280, 260);
  static const Size _maxWindowSize = Size(1280, 960);

  final _logKey = GlobalKey<_LogFloatingWidgetState>();
  Rect? _bounds;
  _LogSource _source = _LogSource.app;
  bool _following = true;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final bounds = _resolveBounds(size);
          return _PassThroughHitTest(
            activeRects: [bounds.inflate(14)],
            child: Material(
              color: Colors.transparent,
              child: Stack(children: [_buildWindow(bounds, size)]),
            ),
          );
        },
      ),
    );
  }

  Rect _resolveBounds(Size viewport) {
    final current = _bounds;
    if (current != null) {
      final width = current.width
          .clamp(_minWindowSize.width, _maxWidth(viewport))
          .toDouble();
      final height = current.height
          .clamp(_minWindowSize.height, _maxHeight(viewport))
          .toDouble();
      final left = current.left
          .clamp(0.0, (viewport.width - width).clamp(0.0, viewport.width))
          .toDouble();
      final top = current.top
          .clamp(0.0, (viewport.height - height).clamp(0.0, viewport.height))
          .toDouble();
      _bounds = Rect.fromLTWH(left, top, width, height);
      return _bounds!;
    }

    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final viewSize = view.physicalSize / view.devicePixelRatio;
    final compact = viewSize.width < 700 || viewport.width < 700;
    final width = compact
        ? (viewport.width - 24).clamp(280.0, 560.0).toDouble()
        : 560.0.clamp(_minWindowSize.width, _maxWidth(viewport)).toDouble();
    final height = compact
        ? (viewport.height - 118).clamp(300.0, 620.0).toDouble()
        : 430.0.clamp(_minWindowSize.height, _maxHeight(viewport)).toDouble();
    final left = compact ? 12.0 : 24.0;
    final top = compact ? 70.0 : 72.0;
    _bounds = Rect.fromLTWH(
      left
          .clamp(0.0, (viewport.width - width).clamp(0.0, viewport.width))
          .toDouble(),
      top
          .clamp(0.0, (viewport.height - height).clamp(0.0, viewport.height))
          .toDouble(),
      width,
      height,
    );
    return _bounds!;
  }

  double _maxWidth(Size viewport) {
    return viewport.width
        .clamp(_minWindowSize.width, _maxWindowSize.width)
        .toDouble();
  }

  double _maxHeight(Size viewport) {
    return viewport.height
        .clamp(_minWindowSize.height, _maxWindowSize.height)
        .toDouble();
  }

  Widget _buildWindow(Rect bounds, Size viewport) {
    final colors = _LogPalette.of(context);
    final theme = shadcn.Theme.of(context);
    return Positioned.fromRect(
      rect: bounds,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              Container(
                height: _titleBarHeight,
                decoration: BoxDecoration(
                  color: colors.panel,
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (details) =>
                            _moveWindow(details.delta, viewport),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(
                                shadcn.LucideIcons.terminal,
                                size: 14,
                                color: colors.foreground,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '日志浮窗',
                                style: theme.typography.small.copyWith(
                                  color: colors.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _titleSourceChip(_LogSource.app),
                    _titleSourceChip(_LogSource.server),
                    const SizedBox(width: 6),
                    _titleLiveChip(),
                    const SizedBox(width: 4),
                    const _LogWindowActions(),
                  ],
                ),
              ),
              Expanded(
                child: _LogFloatingWidget(
                  key: _logKey,
                  statusTrailing: _buildResizeHandle(viewport),
                  onSourceChanged: (source) {
                    if (mounted) setState(() => _source = source);
                  },
                  onFollowingChanged: (following) {
                    if (mounted) setState(() => _following = following);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleSourceChip(_LogSource source) {
    final colors = _LogPalette.of(context);
    final selected = _source == source;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _logKey.currentState?._switchSource(source),
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: 0.32)
                : colors.border,
          ),
        ),
        child: Text(
          source.label,
          style: TextStyle(
            color: selected ? colors.primary : colors.muted,
            fontSize: 9,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _titleLiveChip() {
    final colors = _LogPalette.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _logKey.currentState?._toggleFollowing(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _following
              ? colors.success.withValues(alpha: 0.16)
              : colors.subtle.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _following ? 'LIVE' : 'PAUSE',
          style: TextStyle(
            color: _following ? colors.success : colors.muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildResizeHandle(Size viewport) {
    final colors = _LogPalette.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => _resizeWindow(details.delta, viewport),
      child: SizedBox(
        width: 24,
        height: 22,
        child: Icon(shadcn.LucideIcons.grip, size: 12, color: colors.subtle),
      ),
    );
  }

  void _moveWindow(Offset delta, Size viewport) {
    final current = _bounds;
    if (current == null) return;
    setState(() {
      final left = (current.left + delta.dx)
          .clamp(
            0.0,
            (viewport.width - current.width).clamp(0.0, viewport.width),
          )
          .toDouble();
      final top = (current.top + delta.dy)
          .clamp(
            0.0,
            (viewport.height - current.height).clamp(0.0, viewport.height),
          )
          .toDouble();
      _bounds = Rect.fromLTWH(left, top, current.width, current.height);
    });
  }

  void _resizeWindow(Offset delta, Size viewport) {
    final current = _bounds;
    if (current == null) return;
    setState(() {
      final width = (current.width + delta.dx)
          .clamp(_minWindowSize.width, _maxWidth(viewport))
          .toDouble();
      final height = (current.height + delta.dy)
          .clamp(_minWindowSize.height, _maxHeight(viewport))
          .toDouble();
      _bounds = Rect.fromLTWH(
        current.left,
        current.top,
        width
            .clamp(_minWindowSize.width, viewport.width - current.left)
            .toDouble(),
        height
            .clamp(_minWindowSize.height, viewport.height - current.top)
            .toDouble(),
      );
    });
  }
}

class _LogWindowActions extends StatelessWidget {
  const _LogWindowActions();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 4),
      child: DesktopTrafficLightButton(
        color: Color(0xFFFF5F57),
        icon: shadcn.LucideIcons.x,
        tooltip: '关闭',
        onPressed: LogOverlayManager.hide,
      ),
    );
  }
}

class _PassThroughHitTest extends SingleChildRenderObjectWidget {
  final List<Rect> activeRects;

  const _PassThroughHitTest({required this.activeRects, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPassThroughHitTest(activeRects);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPassThroughHitTest renderObject,
  ) {
    renderObject.activeRects = activeRects;
  }
}

class _RenderPassThroughHitTest extends RenderProxyBox {
  List<Rect> _activeRects;

  _RenderPassThroughHitTest(this._activeRects);

  set activeRects(List<Rect> value) {
    _activeRects = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    for (final rect in _activeRects) {
      if (rect.contains(position)) {
        return super.hitTest(result, position: position);
      }
    }
    return false;
  }
}

// ══════════════════════════════════════════════════════════
//  日志级别过滤
// ══════════════════════════════════════════════════════════

enum _FilterLevel {
  all('ALL'),
  verbose('V'),
  debug('D'),
  info('I'),
  warn('W'),
  error('E');

  final String label;

  const _FilterLevel(this.label);
}

enum _LogSource {
  app('APP'),
  server('服务');

  final String label;

  const _LogSource(this.label);
}

class _LogPalette {
  final bool isDark;
  final Color surface;
  final Color panel;
  final Color border;
  final Color foreground;
  final Color muted;
  final Color subtle;
  final Color primary;
  final Color success;
  final Color verbose;
  final Color debug;
  final Color info;
  final Color warn;
  final Color error;
  final Color lineDefault;
  final Color shadow;

  const _LogPalette({
    required this.isDark,
    required this.surface,
    required this.panel,
    required this.border,
    required this.foreground,
    required this.muted,
    required this.subtle,
    required this.primary,
    required this.success,
    required this.verbose,
    required this.debug,
    required this.info,
    required this.warn,
    required this.error,
    required this.lineDefault,
    required this.shadow,
  });

  factory _LogPalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _LogPalette(
        isDark: true,
        surface: Color(0xFF0D1117),
        panel: Color(0xFF161B22),
        border: Color(0xFF30363D),
        foreground: Color(0xFFE6EDF3),
        muted: Color(0xFF8B949E),
        subtle: Color(0xFF484F58),
        primary: Color(0xFF58A6FF),
        success: Color(0xFF3FB950),
        verbose: Color(0xFF8B949E),
        debug: Color(0xFF7EE787),
        info: Color(0xFF58A6FF),
        warn: Color(0xFFD29922),
        error: Color(0xFFF85149),
        lineDefault: Color(0xFFC9D1D9),
        shadow: Color(0x66000000),
      );
    }
    return const _LogPalette(
      isDark: false,
      surface: Color(0xFFFFFFFF),
      panel: Color(0xFFF8FAFC),
      border: Color(0xFFD8DEE8),
      foreground: Color(0xFF0F172A),
      muted: Color(0xFF64748B),
      subtle: Color(0xFF94A3B8),
      primary: Color(0xFF2563EB),
      success: Color(0xFF16A34A),
      verbose: Color(0xFF64748B),
      debug: Color(0xFF15803D),
      info: Color(0xFF2563EB),
      warn: Color(0xFFB45309),
      error: Color(0xFFDC2626),
      lineDefault: Color(0xFF334155),
      shadow: Color(0x22000000),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  悬浮窗主体
// ══════════════════════════════════════════════════════════

class _LogFloatingWidget extends StatefulWidget {
  final Widget? statusTrailing;
  final ValueChanged<_LogSource>? onSourceChanged;
  final ValueChanged<bool>? onFollowingChanged;

  const _LogFloatingWidget({
    super.key,
    this.statusTrailing,
    this.onSourceChanged,
    this.onFollowingChanged,
  });

  @override
  State<_LogFloatingWidget> createState() => _LogFloatingWidgetState();
}

class _LogFloatingWidgetState extends State<_LogFloatingWidget> {
  // ── 状态 ──
  bool _following = true;
  _LogSource _source = _LogSource.app;

  // ── 过滤 ──
  _FilterLevel _filter = _FilterLevel.all;
  LogLevel _streamLevel = LogLevel.info;
  static const int _streamLimit = 200;
  static const int _maxLogLines = 800;
  static const int _trimmedLogLines = 600;
  static const int _initialTailBytes = 256 * 1024;
  static const double _minLogFontSize = 8;
  static const double _maxLogFontSize = 16;
  static const double _defaultLogFontSize = 12;
  static const List<LogLevel> _streamLevels = [
    LogLevel.debug,
    LogLevel.info,
    LogLevel.warn,
    LogLevel.error,
  ];
  double _logFontSize = _defaultLogFontSize;

  // ── 日志数据 ──
  final List<String> _appLines = [];
  final List<String> _serverLines = [];
  Timer? _appTailTimer;
  int _appLastFileLength = 0;
  String? _appLogPath;
  CancelToken? _streamCancelToken;
  String? _connectionId;
  String? _streamError;
  bool _connected = false;
  DateTime? _lastHeartbeatAt;

  // ── 滚动 ──
  final _scrollController = ScrollController();

  List<String> get _lines =>
      _source == _LogSource.app ? _appLines : _serverLines;

  @override
  void initState() {
    super.initState();
    _startAppTailing();
  }

  @override
  void dispose() {
    _appTailTimer?.cancel();
    _cancelStream('日志浮窗关闭');
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshCurrentSource() {
    if (_source == _LogSource.app) {
      _startAppTailing(reset: true);
    } else {
      _connectStream();
    }
  }

  void _toggleFollowing() {
    setState(() => _following = !_following);
    widget.onFollowingChanged?.call(_following);
  }

  void _selectLogLevel(LogLevel level) {
    if (_source == _LogSource.app) {
      AppLogger.reinit(level);
      setState(() {});
      Toast.success('已切换为 ${level.name}');
      return;
    }

    if (_streamLevel == level) return;
    setState(() => _streamLevel = level);
    _connectStream(resetLines: true);
    Toast.success('已切换为 ${_levelParam(level)}');
  }

  void _switchSource(_LogSource source) {
    if (_source == source) return;
    _appTailTimer?.cancel();
    _cancelStream('切换日志源');
    setState(() => _source = source);
    widget.onSourceChanged?.call(source);
    if (source == _LogSource.app) {
      _startAppTailing();
    } else {
      _connectStream();
    }
    if (_following) _scrollToBottom();
  }

  // ────────────────── APP 文件日志 ──────────────────

  Future<void> _startAppTailing({bool reset = false}) async {
    _appTailTimer?.cancel();
    if (reset) {
      setState(() {
        _appLines.clear();
        _appLastFileLength = 0;
        _appLogPath = null;
      });
    }
    try {
      if (kIsWeb) {
        _loadAppMemoryInitial();
        _startAppPeriodic();
        return;
      }

      final logFile = await AppLogger.currentLogFile();
      if (logFile == null) {
        _addAppLine('[INFO] 当前平台不支持本地 APP 文件日志');
        return;
      }

      final logPath = logFile.path;
      final file = File(logPath);

      if (!await file.exists()) {
        setState(() => _appLogPath = logPath);
        _appTailTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
          if (await File(logPath).exists()) {
            _appTailTimer?.cancel();
            await _loadAppInitial(File(logPath));
            _startAppPeriodic();
          }
        });
        return;
      }

      await _loadAppInitial(file);
      _startAppPeriodic();
    } catch (e) {
      _addAppLine('[ERROR] APP日志追踪失败: $e');
    }
  }

  void _loadAppMemoryInitial() {
    final lines = AppLogger.memoryLogLines;
    final tail = lines.length > _streamLimit
        ? lines.sublist(lines.length - _streamLimit)
        : lines;
    setState(() {
      _appLogPath = AppLogger.memoryLogPath;
      _appLastFileLength = lines.length;
      _appLines
        ..clear()
        ..addAll(tail);
    });
    if (_following) _scrollToBottom();
  }

  Future<void> _loadAppInitial(File file) async {
    try {
      final stat = await file.stat();
      final start = stat.size > _initialTailBytes
          ? stat.size - _initialTailBytes
          : 0;
      final raf = await file.open(mode: FileMode.read);
      await raf.setPosition(start);
      final bytes = await raf.read(stat.size - start);
      await raf.close();
      final content = utf8.decode(bytes, allowMalformed: true);
      final lines = content
          .split('\n')
          .where((line) => line.isNotEmpty)
          .toList();
      final tail = lines.length > _streamLimit
          ? lines.sublist(lines.length - _streamLimit)
          : lines;
      setState(() {
        _appLogPath = file.path;
        _appLastFileLength = stat.size;
        _appLines
          ..clear()
          ..addAll(tail);
      });
      if (_following) _scrollToBottom();
    } catch (e) {
      _addAppLine('[ERROR] APP日志读取失败: $e');
    }
  }

  void _startAppPeriodic() {
    _appTailTimer?.cancel();
    _appTailTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tailAppUpdate(),
    );
  }

  Future<void> _tailAppUpdate() async {
    final logPath = _appLogPath;
    if (logPath == null) return;
    try {
      if (logPath == AppLogger.memoryLogPath) {
        final lines = AppLogger.memoryLogLines;
        if (lines.length == _appLastFileLength) return;

        final newLines = lines.skip(_appLastFileLength).toList();
        _appLastFileLength = lines.length;
        if (newLines.isEmpty) return;

        setState(() {
          _appLines.addAll(newLines);
          _trimLogLines(_appLines);
        });
        if (_following) _scrollToBottom();
        return;
      }

      final file = File(logPath);
      if (!await file.exists()) return;

      final stat = await file.stat();
      final currentLength = stat.size;
      if (currentLength == _appLastFileLength) return;

      if (currentLength < _appLastFileLength) {
        await _loadAppInitial(file);
        return;
      }

      final raf = await file.open(mode: FileMode.read);
      await raf.setPosition(_appLastFileLength);
      final newBytes = await raf.read(currentLength - _appLastFileLength);
      await raf.close();
      _appLastFileLength = currentLength;

      final newContent = utf8.decode(newBytes, allowMalformed: true);
      final newLines = newContent
          .split('\n')
          .where((line) => line.isNotEmpty)
          .toList();
      if (newLines.isEmpty) return;

      setState(() {
        _appLines.addAll(newLines);
        _trimLogLines(_appLines);
        if (newLines.length > 120) {
          _following = false;
        }
      });
      if (_source == _LogSource.app && _following) _scrollToBottom();
    } catch (_) {}
  }

  void _addAppLine(String line) {
    setState(() {
      _appLines.add(line);
      _trimLogLines(_appLines);
    });
    if (_source == _LogSource.app && _following) _scrollToBottom();
  }

  // ────────────────── 后端日志 SSE ──────────────────

  Future<void> _connectStream({bool resetLines = false}) async {
    _cancelStream('重新连接日志流');
    final cancelToken = CancelToken();
    _streamCancelToken = cancelToken;
    if (mounted) {
      setState(() {
        if (resetLines) _serverLines.clear();
        _connected = false;
        _streamError = null;
        _connectionId = null;
        _lastHeartbeatAt = null;
      });
    }
    try {
      final responseBody = await Http.get<ResponseBody>(
        '/api/auth/logs/stream',
        queryParameters: {
          'level': _levelParam(_streamLevel),
          'limit': _streamLimit,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream', 'Cache-Control': 'no-cache'},
        ),
        cancelToken: cancelToken,
      );

      var buffer = '';
      await for (final chunk in responseBody.stream) {
        if (cancelToken.isCancelled) break;
        buffer += utf8
            .decode(chunk, allowMalformed: true)
            .replaceAll('\r\n', '\n')
            .replaceAll('\r', '\n');

        while (buffer.contains('\n\n')) {
          final index = buffer.indexOf('\n\n');
          final event = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 2);
          _processStreamEvent(event);
        }
      }

      final remaining = buffer.trim();
      if (remaining.isNotEmpty) _processStreamEvent(remaining);
    } on DioException catch (e) {
      if (!cancelToken.isCancelled) _markStreamError(e.message ?? e.toString());
    } catch (e) {
      if (!cancelToken.isCancelled) _markStreamError(e.toString());
    } finally {
      if (identical(_streamCancelToken, cancelToken)) {
        _streamCancelToken = null;
      }
    }
  }

  void _cancelStream(String reason) {
    final token = _streamCancelToken;
    _streamCancelToken = null;
    if (token != null && !token.isCancelled) {
      token.cancel(reason);
    }
  }

  void _processStreamEvent(String event) {
    if (!mounted || event.trim().isEmpty) return;
    final jsonText = _eventData(event);
    if (jsonText.isEmpty) return;

    try {
      final payload = jsonDecode(jsonText) as Map<String, dynamic>;
      if (payload['code'] != 0 || payload['data'] is! Map) {
        final msg = payload['msg']?.toString();
        if (msg != null && msg.isNotEmpty) _markStreamError(msg);
        return;
      }

      final data = Map<String, dynamic>.from(payload['data'] as Map);
      final type = data['type']?.toString();
      final connectionId = data['connectionId']?.toString();

      if (type == 'connected') {
        setState(() {
          _connected = true;
          _streamError = null;
          _connectionId = connectionId;
        });
        return;
      }

      if (type == 'heartbeat') {
        setState(() {
          _connected = true;
          _streamError = null;
          _connectionId = connectionId ?? _connectionId;
          _lastHeartbeatAt = DateTime.now();
        });
        return;
      }

      final entries = data['entries'];
      if (entries is! List) return;
      final lines = entries
          .whereType<Map>()
          .map((entry) => _entryLine(Map<String, dynamic>.from(entry)))
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isEmpty && type != 'snapshot') return;

      setState(() {
        _connected = true;
        _streamError = null;
        _connectionId = connectionId ?? _connectionId;
        if (type == 'snapshot') {
          _serverLines
            ..clear()
            ..addAll(lines);
        } else {
          _serverLines.addAll(lines);
          _trimLogLines(_serverLines);
        }
      });
      if (_source == _LogSource.server && _following) _scrollToBottom();
    } catch (e) {
      _markStreamError('日志流解析失败: $e');
    }
  }

  String _eventData(String event) {
    final dataLines = <String>[];
    for (final line in event.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('data:')) {
        dataLines.add(trimmed.substring(5).trim());
      } else if (trimmed.startsWith('{')) {
        dataLines.add(trimmed);
      }
    }
    return dataLines.join('\n').trim();
  }

  String _entryLine(Map<String, dynamic> entry) {
    final display = entry['display']?.toString();
    if (display != null && display.isNotEmpty) return display;
    final raw = entry['raw']?.toString();
    if (raw != null && raw.isNotEmpty) return raw;
    final timestamp =
        entry['timestamp']?.toString() ?? entry['logged_at']?.toString() ?? '';
    final level = entry['level']?.toString() ?? '';
    final message = entry['message']?.toString() ?? '';
    return [timestamp, level, message].where((v) => v.isNotEmpty).join(' | ');
  }

  void _markStreamError(String message) {
    if (!mounted) return;
    setState(() {
      _connected = false;
      _streamError = message;
      _serverLines.add('[ERROR] $message');
      _trimLogLines(_serverLines);
    });
    if (_source == _LogSource.server && _following) _scrollToBottom();
  }

  void _trimLogLines(List<String> lines) {
    if (lines.length > _maxLogLines) {
      lines.removeRange(0, lines.length - _trimmedLogLines);
    }
  }

  String _levelParam(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.off:
        return 'OFF';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // ────────────────── 过滤后的行 ──────────────────

  List<_IndexedLine> get _filteredLines {
    if (_filter == _FilterLevel.all) {
      return List.generate(_lines.length, (i) => _IndexedLine(i, _lines[i]));
    }
    final result = <_IndexedLine>[];
    for (var i = 0; i < _lines.length; i++) {
      if (_matchesFilter(_lines[i])) {
        result.add(_IndexedLine(i, _lines[i]));
      }
    }
    return result;
  }

  bool _matchesFilter(String line) {
    final level = _lineLevel(line);
    switch (_filter) {
      case _FilterLevel.all:
        return true;
      case _FilterLevel.verbose:
        return level == 'VERBOSE' || level == 'TRACE';
      case _FilterLevel.debug:
        return level == 'DEBUG';
      case _FilterLevel.info:
        return level == 'INFO';
      case _FilterLevel.warn:
        return level == 'WARN' || level == 'WARNING';
      case _FilterLevel.error:
        return level == 'ERROR';
    }
  }

  // ────────────────── 操作 ──────────────────

  void _clearLogs() {
    setState(() => _lines.clear());
    Toast.success('已清空');
  }

  Future<void> _shareLogs() async {
    try {
      await AppLogger.shareLogs();
      Toast.success('日志已打包分享');
    } catch (e) {
      Toast.error('分享失败');
    }
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _lines.join('\n')));
    Toast.success('已复制全部');
  }

  void _changeLogFontSize(double delta) {
    final next = (_logFontSize + delta)
        .clamp(_minLogFontSize, _maxLogFontSize)
        .toDouble();
    if (next == _logFontSize) return;
    setState(() => _logFontSize = next);
    if (_following) _scrollToBottom();
  }

  // ────────────────── 构建 ──────────────────

  @override
  Widget build(BuildContext context) {
    final colors = _LogPalette.of(context);
    return Container(
      color: colors.surface,
      child: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildLogList()),
          _buildToolbar(),
          _buildStatusBar(),
        ],
      ),
    );
  }

  // ── 级别过滤栏 ──

  Widget _buildFilterBar() {
    final colors = _LogPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: _FilterLevel.values.map((level) {
          final selected = level == _filter;
          final levelColor = _filterLevelColor(level);
          return GestureDetector(
            onTap: () {
              setState(() => _filter = level);
              if (_following) _scrollToBottom();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: selected
                    ? levelColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected
                      ? levelColor.withValues(alpha: 0.4)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                level.label,
                style: TextStyle(
                  color: selected ? levelColor : colors.subtle,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 日志列表 ──

  Widget _buildLogList() {
    final filtered = _filteredLines;
    final colors = _LogPalette.of(context);

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          '暂无日志',
          style: TextStyle(color: colors.subtle, fontSize: _logFontSize + 1),
        ),
      );
    }

    return SelectionArea(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => _buildLine(filtered[i]),
      ),
    );
  }

  Widget _buildLine(_IndexedLine item) {
    final colors = _LogPalette.of(context);
    final color = _getLevelColor(item.line);
    final isLast = item.originalIndex == _lines.length - 1;
    final indexWidth = (_logFontSize * 2.8).clamp(28.0, 46.0).toDouble();
    final tagFontSize = (_logFontSize - 2).clamp(7.0, 12.0).toDouble();

    return Container(
      color: isLast ? color.withValues(alpha: 0.06) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionContainer.disabled(
            child: SizedBox(
              width: indexWidth,
              child: Text(
                '${item.originalIndex + 1}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colors.subtle,
                  fontSize: (_logFontSize - 1).clamp(7.0, 14.0).toDouble(),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          SelectionContainer.disabled(
            child: Container(
              width: 2,
              height: (_logFontSize * 1.2).clamp(10.0, 18.0).toDouble(),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          // 级别标签
          SelectionContainer.disabled(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              margin: const EdgeInsets.only(right: 4, top: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                _getLevelTag(item.line),
                style: TextStyle(
                  color: color,
                  fontSize: tagFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              _stripLevelTag(item.line),
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: _logFontSize,
                fontFamily: 'monospace',
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── 工具栏 ──
  Widget _buildToolbar() {
    final colors = _LogPalette.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.panel,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _toolBtn(
                        icon: shadcn.LucideIcons.minus,
                        label: '缩小',
                        onTap: () => _changeLogFontSize(-1),
                      ),
                      _toolBtn(
                        icon: shadcn.LucideIcons.plus,
                        label: '放大',
                        onTap: () => _changeLogFontSize(1),
                      ),
                      Container(width: 0.5, height: 14, color: colors.border),
                      const SizedBox(width: 6),
                      _toolBtn(
                        icon: Icons.copy_rounded,
                        label: '复制',
                        onTap: _copyAll,
                      ),
                      _toolBtn(
                        icon: shadcn.LucideIcons.share2,
                        label: '分享',
                        onTap: _shareLogs,
                      ),
                      _toolBtn(
                        icon: shadcn.LucideIcons.trash2,
                        label: '清空',
                        onTap: _clearLogs,
                      ),
                      _toolBtn(
                        icon: shadcn.LucideIcons.refreshCw,
                        label: _source == _LogSource.app ? '刷新' : '重连',
                        onTap: _refreshCurrentSource,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _levelColor(LogLevel level) {
    final colors = _LogPalette.of(context);
    switch (level) {
      case LogLevel.verbose:
        return colors.verbose;
      case LogLevel.debug:
        return colors.debug;
      case LogLevel.info:
        return colors.info;
      case LogLevel.warn:
        return colors.warn;
      case LogLevel.error:
        return colors.error;
      case LogLevel.off:
        return colors.subtle;
    }
  }

  Color _filterLevelColor(_FilterLevel level) {
    final colors = _LogPalette.of(context);
    switch (level) {
      case _FilterLevel.all:
        return colors.lineDefault;
      case _FilterLevel.verbose:
        return colors.verbose;
      case _FilterLevel.debug:
        return colors.debug;
      case _FilterLevel.info:
        return colors.info;
      case _FilterLevel.warn:
        return colors.warn;
      case _FilterLevel.error:
        return colors.error;
    }
  }

  Widget _toolBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final colors = _LogPalette.of(context);
    final color = destructive ? colors.error : colors.muted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ── 状态栏 ──

  Widget _buildStatusBar() {
    final colors = _LogPalette.of(context);
    final filtered = _filteredLines;
    final filterColor = _filterLevelColor(_filter);
    final statusText = _source == _LogSource.app
        ? (_appLogPath == null ? 'APP日志' : p.basename(_appLogPath!))
        : _streamError ??
              (_connected
                  ? 'SSE ${_levelParam(_streamLevel)} ${_connectionId ?? ''}${_heartbeatText()}'
                  : '连接中...');
    final statusColor = _streamError != null && _source == _LogSource.server
        ? colors.error
        : colors.subtle;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: filterColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              _filter == _FilterLevel.all
                  ? '${_lines.length} 行'
                  : '${filtered.length}/${_lines.length}',
              style: TextStyle(
                color: filterColor.withValues(alpha: 0.7),
                fontSize: 9,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _levelStrip(),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                statusText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: statusColor, fontSize: 9),
              ),
            ),
          ),
          if (widget.statusTrailing != null) ...[
            const SizedBox(width: 4),
            widget.statusTrailing!,
          ],
        ],
      ),
    );
  }

  Widget _levelStrip() {
    final levels = _source == _LogSource.app ? LogLevel.values : _streamLevels;
    final current = _source == _LogSource.app ? AppLogger.level : _streamLevel;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final level in levels)
          _levelChip(level, selected: level == current),
      ],
    );
  }

  Widget _levelChip(LogLevel level, {required bool selected}) {
    final colors = _LogPalette.of(context);
    final color = _levelColor(level);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectLogLevel(level),
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.34)
                : colors.border.withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          level.name.toUpperCase(),
          style: TextStyle(
            color: selected ? color : colors.subtle,
            fontSize: 8,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ────────────────── 工具 ──────────────────

  Color _getLevelColor(String line) {
    final colors = _LogPalette.of(context);
    final level = _lineLevel(line);
    if (level == 'ERROR') {
      return colors.error;
    }
    if (level == 'WARN' || level == 'WARNING') {
      return colors.warn;
    }
    if (level == 'INFO') {
      return colors.info;
    }
    if (level == 'DEBUG') {
      return colors.debug;
    }
    if (level == 'VERBOSE' || level == 'TRACE') {
      return colors.verbose;
    }
    return colors.lineDefault;
  }

  String _getLevelTag(String line) {
    final level = _lineLevel(line);
    if (level.isEmpty) return '-';
    return level.substring(0, 1);
  }

  String _stripLevelTag(String line) {
    final bracketMatch = RegExp(r'^\[.*?\]\s*\[.*?\]\s*').matchAsPrefix(line);
    if (bracketMatch != null) {
      return line.substring(bracketMatch.end);
    }
    final pipeMatch = RegExp(
      r'^\s*\d{4}-\d{2}-\d{2}[^|]*\|\s*[A-Z]+\s*\|\s*',
    ).matchAsPrefix(line);
    if (pipeMatch != null) {
      return line.substring(pipeMatch.end);
    }
    return line;
  }

  String _lineLevel(String line) {
    final bracket = RegExp(
      r'\[(VERBOSE|TRACE|DEBUG|INFO|WARN|WARNING|ERROR)\]',
    ).firstMatch(line);
    if (bracket != null) return bracket.group(1)!;
    final pipe = RegExp(
      r'\|\s*(VERBOSE|TRACE|DEBUG|INFO|WARN|WARNING|ERROR)\s*\|',
    ).firstMatch(line);
    if (pipe != null) return pipe.group(1)!;
    final plain = RegExp(
      r'\b(VERBOSE|TRACE|DEBUG|INFO|WARN|WARNING|ERROR)\b',
    ).firstMatch(line);
    if (plain != null) return plain.group(1)!;
    return '';
  }

  String _heartbeatText() {
    final heartbeat = _lastHeartbeatAt;
    if (heartbeat == null) return '';
    final now = DateTime.now();
    final seconds = now.difference(heartbeat).inSeconds;
    if (seconds < 60) return ' · ${seconds}s';
    return ' · ${heartbeat.hour.toString().padLeft(2, '0')}:${heartbeat.minute.toString().padLeft(2, '0')}';
  }
}

// ══════════════════════════════════════════════════════════
//  辅助
// ══════════════════════════════════════════════════════════

class _IndexedLine {
  final int originalIndex;
  final String line;

  const _IndexedLine(this.originalIndex, this.line);
}
