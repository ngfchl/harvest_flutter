import 'dart:async';
import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/debug_theme_button.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'widgets/shell_scaffold.dart';

class LogCenterPage extends StatefulWidget {
  const LogCenterPage({super.key});

  @override
  State<LogCenterPage> createState() => _LogCenterPageState();
}

class _LogCenterPageState extends State<LogCenterPage> {
  static const int _pageSize = 100;
  static const int _serverPollSeconds = 3;
  static const double _minLogFontSize = 8;
  static const double _maxLogFontSize = 16;
  static const double _defaultLogFontSize = 12;
  static const List<LogLevel> _serverLevels = [
    LogLevel.debug,
    LogLevel.info,
    LogLevel.warn,
    LogLevel.error,
  ];

  final _scrollController = ScrollController();

  _LogPageSource _source = _LogPageSource.app;
  _FilterLevel _filter = _FilterLevel.all;
  bool _following = true;
  double _logFontSize = _defaultLogFontSize;

  bool _loadingInitial = true;
  bool _loadingOlder = false;
  bool _loadingLatest = false;
  String? _error;

  Timer? _appTailTimer;
  String? _appLogPath;
  List<String> _appAllLines = const [];
  List<String> _appVisibleLines = const [];
  int _appVisibleStart = 0;

  Timer? _serverPollTimer;
  LogLevel _serverLevel = LogLevel.info;
  List<String> _serverLines = const [];
  final Set<String> _serverSeenKeys = <String>{};
  int _serverLoadedCount = 0;
  int _serverTotal = 0;
  DateTime? _serverLastUpdatedAt;
  String? _serverNotice;

  List<String> get _activeLines =>
      _source == _LogPageSource.app ? _appVisibleLines : _serverLines;

  bool get _hasOlder => _source == _LogPageSource.app
      ? _appVisibleStart > 0
      : _serverLoadedCount < _serverTotal;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_activateSource(_source, resetScroll: true));
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _appTailTimer?.cancel();
    _serverPollTimer?.cancel();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_isNearBottom()) {
      if (!_following && mounted) {
        setState(() => _following = true);
      }
      return;
    }
    if (_following && mounted) {
      setState(() => _following = false);
    }
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return false;
    return _scrollController.position.maxScrollExtent -
            _scrollController.offset <=
        72;
  }

  Future<void> _activateSource(
    _LogPageSource source, {
    bool resetScroll = false,
  }) async {
    _appTailTimer?.cancel();
    _serverPollTimer?.cancel();
    if (mounted) {
      setState(() {
        _source = source;
        _loadingInitial = true;
        _error = null;
      });
    }
    if (source == _LogPageSource.app) {
      await _loadInitialApp(resetScroll: resetScroll);
      _startAppPolling();
    } else {
      await _loadInitialServer(resetScroll: resetScroll);
      _startServerPolling();
    }
  }

  Future<void> _loadInitialApp({bool resetScroll = false}) async {
    try {
      final snapshot = await _readAppSnapshot();
      final start = snapshot.lines.length > _pageSize
          ? snapshot.lines.length - _pageSize
          : 0;
      if (!mounted) return;
      setState(() {
        _appLogPath = snapshot.logPath;
        _appAllLines = snapshot.lines;
        _appVisibleStart = start;
        _appVisibleLines = snapshot.lines.sublist(start);
        _loadingInitial = false;
        _error = null;
        _serverNotice = null;
      });
      if (resetScroll || _following) {
        _scrollToBottom(jump: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingInitial = false;
        _error = '读取 APP 日志失败: $e';
      });
    }
  }

  _AppSnapshot _buildAppSnapshotFromLines(
    List<String> lines, {
    required String logPath,
    required int fileLength,
  }) {
    return _AppSnapshot(lines: lines, logPath: logPath, fileLength: fileLength);
  }

  Future<_AppSnapshot> _readAppSnapshot() async {
    if (kIsWeb) {
      final lines = List<String>.from(AppLogger.memoryLogLines);
      return _buildAppSnapshotFromLines(
        lines,
        logPath: AppLogger.memoryLogPath,
        fileLength: lines.length,
      );
    }

    final file = await AppLogger.currentLogFile();
    if (file == null) {
      return _buildAppSnapshotFromLines(
        const [],
        logPath: 'APP日志',
        fileLength: 0,
      );
    }
    final exists = await file.exists();
    if (!exists) {
      return _buildAppSnapshotFromLines(
        const [],
        logPath: file.path,
        fileLength: 0,
      );
    }
    final bytes = await file.readAsBytes();
    final content = utf8.decode(bytes, allowMalformed: true);
    final lines = content.split('\n').where((line) => line.isNotEmpty).toList();
    return _buildAppSnapshotFromLines(
      lines,
      logPath: file.path,
      fileLength: bytes.length,
    );
  }

  void _startAppPolling() {
    _appTailTimer?.cancel();
    _appTailTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_syncLatestApp(silent: true));
    });
  }

  Future<void> _syncLatestApp({bool silent = false}) async {
    if (_loadingLatest || _source != _LogPageSource.app) return;
    _loadingLatest = true;
    try {
      final snapshot = await _readAppSnapshot();
      final previous = _appAllLines;
      final next = snapshot.lines;
      if (!_samePrefix(previous, next)) {
        final visibleCount = _appVisibleLines.length;
        final nextStart = next.length > visibleCount
            ? next.length - visibleCount
            : 0;
        if (!mounted) return;
        setState(() {
          _appLogPath = snapshot.logPath;
          _appAllLines = next;
          _appVisibleStart = nextStart;
          _appVisibleLines = next.sublist(nextStart);
          _error = null;
        });
        if (_following) _scrollToBottom();
        if (!silent) Toast.info('日志已重新同步');
        return;
      }

      if (next.length == previous.length) {
        if (!silent) Toast.info('暂无最新日志');
        return;
      }

      final appended = next.sublist(previous.length);
      if (!mounted) return;
      setState(() {
        _appLogPath = snapshot.logPath;
        _appAllLines = next;
        _appVisibleLines = [..._appVisibleLines, ...appended];
        _error = null;
      });
      if (_following) _scrollToBottom();
      if (!silent) Toast.success('新增 ${appended.length} 条日志');
    } catch (e) {
      if (!silent) Toast.error('获取最新日志失败');
      if (mounted) {
        setState(() => _error = '读取 APP 日志失败: $e');
      }
    } finally {
      _loadingLatest = false;
    }
  }

  bool _samePrefix(List<String> previous, List<String> next) {
    if (next.length < previous.length) return false;
    for (var i = 0; i < previous.length; i++) {
      if (previous[i] != next[i]) return false;
    }
    return true;
  }

  Future<void> _loadOlderApp() async {
    if (_loadingOlder || _appVisibleStart <= 0) return;
    final previousMaxExtent = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    final previousOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    _loadingOlder = true;
    try {
      final nextStart = (_appVisibleStart - _pageSize).clamp(
        0,
        _appVisibleStart,
      );
      final prepend = _appAllLines.sublist(nextStart, _appVisibleStart);
      if (!mounted) return;
      setState(() {
        _appVisibleStart = nextStart;
        _appVisibleLines = [...prepend, ..._appVisibleLines];
      });
      _restorePrependOffset(previousOffset, previousMaxExtent);
      Toast.success('加载了 ${prepend.length} 条更早日志');
    } finally {
      _loadingOlder = false;
    }
  }

  Future<void> _loadInitialServer({bool resetScroll = false}) async {
    try {
      final page = await _fetchServerPage(offset: 0);
      final normalized = _normalizeServerBatch(page.items);
      if (!mounted) return;
      setState(() {
        _serverLines = normalized.lines;
        _serverSeenKeys
          ..clear()
          ..addAll(normalized.keys);
        _serverLoadedCount = page.items.length;
        _serverTotal = page.total;
        _serverLastUpdatedAt = DateTime.now();
        _serverNotice = '服务端日志支持分页读取；页面会自动补最新日志';
        _loadingInitial = false;
        _error = null;
      });
      if (resetScroll || _following) {
        _scrollToBottom(jump: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingInitial = false;
        _error = '读取服务端日志失败: $e';
      });
    }
  }

  void _startServerPolling() {
    _serverPollTimer?.cancel();
    _serverPollTimer = Timer.periodic(
      const Duration(seconds: _serverPollSeconds),
      (_) => unawaited(_syncLatestServer(silent: true)),
    );
  }

  Future<void> _syncLatestServer({bool silent = false}) async {
    if (_loadingLatest || _source != _LogPageSource.server) return;
    _loadingLatest = true;
    try {
      final page = await _fetchServerPage(offset: 0);
      final normalized = _normalizeServerBatch(page.items);
      final overlap = _tailPrefixOverlap(
        _serverLines.map(_serverLineKey).toList(),
        normalized.keys,
      );
      final appendedLines = normalized.lines.sublist(overlap);
      final appendedKeys = normalized.keys.sublist(overlap);
      if (!mounted) return;
      setState(() {
        if (appendedLines.isNotEmpty) {
          _serverLines = [..._serverLines, ...appendedLines];
          _serverSeenKeys.addAll(appendedKeys);
          _serverLoadedCount += appendedLines.length;
        }
        _serverTotal = page.total;
        _serverLastUpdatedAt = DateTime.now();
        _error = null;
      });
      if (appendedLines.isNotEmpty) {
        if (_following) _scrollToBottom();
        if (!silent) Toast.success('新增 ${appendedLines.length} 条服务端日志');
      } else if (!silent) {
        Toast.info('暂无最新日志');
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() => _error = '读取服务端日志失败: $e');
      }
      if (!silent) Toast.error('获取最新日志失败');
    } finally {
      _loadingLatest = false;
    }
  }

  Future<void> _loadOlderServer() async {
    if (_loadingOlder || !_hasOlder) return;
    final previousMaxExtent = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    final previousOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    _loadingOlder = true;
    try {
      await _syncLatestServer(silent: true);
      final page = await _fetchServerPage(offset: _serverLoadedCount);
      final normalized = _normalizeServerBatch(page.items);
      if (!mounted) return;
      setState(() {
        _serverLines = [...normalized.lines, ..._serverLines];
        _serverSeenKeys.addAll(normalized.keys);
        _serverLoadedCount += page.items.length;
        _serverTotal = page.total;
        _serverLastUpdatedAt = DateTime.now();
        _error = null;
      });
      _restorePrependOffset(previousOffset, previousMaxExtent);
      Toast.success('加载了 ${normalized.lines.length} 条更早日志');
    } catch (e) {
      if (mounted) {
        setState(() => _error = '读取服务端历史日志失败: $e');
      }
      Toast.error('获取更早日志失败');
    } finally {
      _loadingOlder = false;
    }
  }

  Future<_ServerLogPage> _fetchServerPage({required int offset}) async {
    final data = await Http.get<Map<String, dynamic>>(
      '/api/auth/logs',
      queryParameters: {
        'limit': _pageSize.clamp(1, 500),
        'offset': offset,
        'level': _levelParam(_serverLevel),
      },
    );
    final rawItems = data['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : const <Map<String, dynamic>>[];
    return _ServerLogPage(
      items: items,
      total: parseInt(data['total']),
      limit: parseInt(data['limit'], fallback: _pageSize),
      offset: parseInt(data['offset'], fallback: offset),
      level: data['level']?.toString() ?? _levelParam(_serverLevel),
    );
  }

  _ServerBatch _normalizeServerBatch(List<Map<String, dynamic>> items) {
    final ordered = items.reversed.toList();
    final lines = <String>[];
    final keys = <String>[];
    for (final item in ordered) {
      final key = _entryKey(item);
      final line = _entryLine(item);
      if (key.isEmpty || line.isEmpty) continue;
      keys.add(key);
      lines.add(line);
    }
    return _ServerBatch(lines: lines, keys: keys);
  }

  int _tailPrefixOverlap(List<String> existingKeys, List<String> incomingKeys) {
    final max = existingKeys.length < incomingKeys.length
        ? existingKeys.length
        : incomingKeys.length;
    for (var length = max; length > 0; length--) {
      var matched = true;
      for (var i = 0; i < length; i++) {
        if (existingKeys[existingKeys.length - length + i] != incomingKeys[i]) {
          matched = false;
          break;
        }
      }
      if (matched) return length;
    }
    return 0;
  }

  void _restorePrependOffset(double previousOffset, double previousMaxExtent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final currentMaxExtent = _scrollController.position.maxScrollExtent;
      final delta = currentMaxExtent - previousMaxExtent;
      _scrollController.jumpTo(previousOffset + delta);
    });
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (jump) {
        _scrollController.jumpTo(target);
        return;
      }
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _loadOlder() async {
    if (_source == _LogPageSource.app) {
      await _loadOlderApp();
      return;
    }
    await _loadOlderServer();
  }

  Future<void> _loadLatest() async {
    if (_source == _LogPageSource.app) {
      await _syncLatestApp();
      return;
    }
    await _syncLatestServer();
  }

  void _toggleFollowing() {
    setState(() => _following = !_following);
    if (_following) _scrollToBottom();
  }

  void _switchSource(_LogPageSource source) {
    if (_source == source) return;
    unawaited(_activateSource(source, resetScroll: true));
  }

  void _selectLogLevel(LogLevel level) {
    if (_source == _LogPageSource.app) {
      AppLogger.reinit(level);
      setState(() {});
      Toast.success('APP 日志级别已切换为 ${level.name.toUpperCase()}');
      return;
    }
    if (_serverLevel == level) return;
    setState(() => _serverLevel = level);
    unawaited(_activateSource(_LogPageSource.server, resetScroll: true));
  }

  void _changeLogFontSize(double delta) {
    final next = (_logFontSize + delta)
        .clamp(_minLogFontSize, _maxLogFontSize)
        .toDouble();
    if (next == _logFontSize) return;
    setState(() => _logFontSize = next);
  }

  void _clearLogs() {
    setState(() {
      if (_source == _LogPageSource.app) {
        _appVisibleLines = const [];
        _appVisibleStart = _appAllLines.length;
      } else {
        _serverLines = const [];
        _serverSeenKeys.clear();
      }
    });
    Toast.success('当前视图已清空');
  }

  void _copyAll() {
    final lines = _activeLines;
    if (lines.isEmpty) {
      Toast.info('暂无日志可复制');
      return;
    }
    Clipboard.setData(ClipboardData(text: lines.join('\n')));
    Toast.success('已复制 ${lines.length} 条日志');
  }

  Future<void> _shareLogs() async {
    try {
      await AppLogger.shareLogs();
      Toast.success('日志已打包分享');
    } catch (_) {
      Toast.error('分享失败');
    }
  }

  Future<void> _refreshCurrentSource() async {
    await _activateSource(_source, resetScroll: true);
  }

  List<_IndexedLine> get _filteredLines {
    final lines = _activeLines;
    if (_filter == _FilterLevel.all) {
      return List.generate(
        lines.length,
        (index) => _IndexedLine(index, lines[index]),
      );
    }
    final result = <_IndexedLine>[];
    for (var i = 0; i < lines.length; i++) {
      if (_matchesFilter(lines[i])) {
        result.add(_IndexedLine(i, lines[i]));
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

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final pageBackground = appSurfaceColor(context, cs.background);

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
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
                  '日志中心',
                  style: theme.typography.large.copyWith(
                    color: cs.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: [
                  shadcn.IconButton.ghost(
                    icon: const Icon(shadcn.LucideIcons.arrowLeft, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
                trailing: const [DebugThemeButton.shadcn()],
              ),
            ],
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _loadingInitial
                      ? _buildLoading(context)
                      : EasyRefresh(
                          header: appRefreshHeader(context),
                          onRefresh: _hasOlder ? _loadOlder : null,
                          onLoad: _loadLatest,
                          child: _buildLogList(context),
                        ),
                ),
                _buildToolbar(context),
                _buildStatusBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = _LogPalette.of(context);
    final theme = shadcn.Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, colors.panel),
        border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSourceChip(context, _LogPageSource.app),
              const SizedBox(width: 8),
              _buildSourceChip(context, _LogPageSource.server),
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleFollowing,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _following
                        ? colors.success.withValues(alpha: 0.14)
                        : colors.subtle.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _following
                          ? colors.success.withValues(alpha: 0.24)
                          : colors.border,
                    ),
                  ),
                  child: Text(
                    _following ? '跟随最新' : '暂停跟随',
                    style: TextStyle(
                      color: _following ? colors.success : colors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (_loadingOlder || _loadingLatest)
                shadcn.CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _source == _LogPageSource.app
                      ? '默认显示最新一页，顶部下拉获取更早日志，底部上拉检查最新日志。'
                      : '默认拉取最新窗口，顶部下拉读取更早分页，底部上拉同步最新写入。',
                  style: theme.typography.small.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_serverNotice != null &&
                    _source == _LogPageSource.server) ...[
                  const SizedBox(height: 6),
                  Text(
                    _serverNotice!,
                    style: theme.typography.xSmall.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _error!,
                    style: theme.typography.xSmall.copyWith(
                      color: colors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildFilterBar(context),
        ],
      ),
    );
  }

  Widget _buildSourceChip(BuildContext context, _LogPageSource source) {
    final colors = _LogPalette.of(context);
    final selected = _source == source;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _switchSource(source),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.14)
              : colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: 0.28)
                : colors.border,
          ),
        ),
        child: Text(
          source.label,
          style: TextStyle(
            color: selected ? colors.primary : colors.foreground,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final colors = _LogPalette.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _FilterLevel.values.map((level) {
          final selected = level == _filter;
          final levelColor = _filterLevelColor(context, level);
          return GestureDetector(
            onTap: () {
              setState(() => _filter = level);
              if (_following) _scrollToBottom();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: selected
                    ? levelColor.withValues(alpha: 0.14)
                    : colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? levelColor.withValues(alpha: 0.32)
                      : colors.border,
                ),
              ),
              child: Text(
                level.label,
                style: TextStyle(
                  color: selected ? levelColor : colors.muted,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final colors = _LogPalette.of(context);
    return Center(
      child: shadcn.CircularProgressIndicator(
        strokeWidth: 2.2,
        color: colors.primary,
      ),
    );
  }

  Widget _buildLogList(BuildContext context) {
    final filtered = _filteredLines;
    final colors = _LogPalette.of(context);
    if (filtered.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
          Center(
            child: Text(
              '暂无日志',
              style: TextStyle(
                color: colors.subtle,
                fontSize: _logFontSize + 1,
              ),
            ),
          ),
        ],
      );
    }
    return SelectionArea(
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 8,
          bottom: ShellBottomSpacing.value(context) + 16,
        ),
        itemCount: filtered.length,
        itemBuilder: (_, index) => _buildLine(context, filtered[index]),
      ),
    );
  }

  Widget _buildLine(BuildContext context, _IndexedLine item) {
    final colors = _LogPalette.of(context);
    final color = _getLevelColor(context, item.line);
    final isLast = item.originalIndex == _activeLines.length - 1;
    final indexWidth = (_logFontSize * 3).clamp(28.0, 48.0).toDouble();
    final tagFontSize = (_logFontSize - 2).clamp(7.0, 12.0).toDouble();

    return Container(
      color: isLast ? color.withValues(alpha: 0.05) : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
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
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          SelectionContainer.disabled(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              margin: const EdgeInsets.only(right: 6, top: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
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
                color: color.withValues(alpha: 0.85),
                fontSize: _logFontSize,
                fontFamily: 'monospace',
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final colors = _LogPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _toolBtn(
                    context,
                    icon: shadcn.LucideIcons.minus,
                    label: '缩小',
                    onTap: () => _changeLogFontSize(-1),
                  ),
                  _toolBtn(
                    context,
                    icon: shadcn.LucideIcons.plus,
                    label: '放大',
                    onTap: () => _changeLogFontSize(1),
                  ),
                  _toolBtn(
                    context,
                    icon: Icons.copy_rounded,
                    label: '复制',
                    onTap: _copyAll,
                  ),
                  _toolBtn(
                    context,
                    icon: shadcn.LucideIcons.share2,
                    label: '分享',
                    onTap: _shareLogs,
                  ),
                  _toolBtn(
                    context,
                    icon: shadcn.LucideIcons.trash2,
                    label: '清空',
                    onTap: _clearLogs,
                  ),
                  _toolBtn(
                    context,
                    icon: shadcn.LucideIcons.refreshCw,
                    label: '重载',
                    onTap: _refreshCurrentSource,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = _LogPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colors.muted),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: colors.muted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final colors = _LogPalette.of(context);
    final filtered = _filteredLines;
    final filterColor = _filterLevelColor(context, _filter);
    final statusText = _source == _LogPageSource.app
        ? (_appLogPath == null ? 'APP日志' : p.basename(_appLogPath!))
        : '服务日志 $_serverLoadedCount/$_serverTotal'
              '${_serverLastUpdatedAt == null ? '' : ' · ${formatTime(_serverLastUpdatedAt!.toIso8601String())}'}';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: filterColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _filter == _FilterLevel.all
                  ? '${_activeLines.length} 行'
                  : '${filtered.length}/${_activeLines.length}',
              style: TextStyle(
                color: filterColor.withValues(alpha: 0.82),
                fontSize: 10,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _levelStrip(context),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.subtle, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelStrip(BuildContext context) {
    final levels = _source == _LogPageSource.app
        ? LogLevel.values
        : _serverLevels;
    final current = _source == _LogPageSource.app
        ? AppLogger.level
        : _serverLevel;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final level in levels)
          _levelChip(context, level, selected: current == level),
      ],
    );
  }

  Widget _levelChip(
    BuildContext context,
    LogLevel level, {
    required bool selected,
  }) {
    final colors = _LogPalette.of(context);
    final color = _levelColor(context, level);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectLogLevel(level),
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.32)
                : colors.border.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          level.name.toUpperCase(),
          style: TextStyle(
            color: selected ? color : colors.subtle,
            fontSize: 9,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _levelColor(BuildContext context, LogLevel level) {
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

  Color _filterLevelColor(BuildContext context, _FilterLevel level) {
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

  Color _getLevelColor(BuildContext context, String line) {
    final colors = _LogPalette.of(context);
    final level = _lineLevel(line);
    if (level == 'ERROR') return colors.error;
    if (level == 'WARN' || level == 'WARNING') return colors.warn;
    if (level == 'INFO') return colors.info;
    if (level == 'DEBUG') return colors.debug;
    if (level == 'VERBOSE' || level == 'TRACE') return colors.verbose;
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

  String _entryLine(Map<String, dynamic> entry) {
    final display = entry['display']?.toString();
    if (display != null && display.isNotEmpty) return display;
    final raw = entry['raw']?.toString();
    if (raw != null && raw.isNotEmpty) return raw;
    final timestamp =
        entry['timestamp']?.toString() ?? entry['logged_at']?.toString() ?? '';
    final level = entry['level']?.toString() ?? '';
    final message = entry['message']?.toString() ?? '';
    return [
      timestamp,
      level,
      message,
    ].where((value) => value.isNotEmpty).join(' | ');
  }

  String _entryKey(Map<String, dynamic> entry) {
    final id = entry['id']?.toString();
    if (id != null && id.isNotEmpty) return id;
    final timestamp =
        entry['timestamp']?.toString() ?? entry['logged_at']?.toString() ?? '';
    final level = entry['level']?.toString() ?? '';
    final message =
        entry['display']?.toString() ??
        entry['raw']?.toString() ??
        entry['message']?.toString() ??
        '';
    return '$timestamp|$level|$message';
  }

  String _serverLineKey(String line) => line;
}

class _IndexedLine {
  final int originalIndex;
  final String line;

  const _IndexedLine(this.originalIndex, this.line);
}

class _AppSnapshot {
  final List<String> lines;
  final String logPath;
  final int fileLength;

  const _AppSnapshot({
    required this.lines,
    required this.logPath,
    required this.fileLength,
  });
}

class _ServerLogPage {
  final List<Map<String, dynamic>> items;
  final int total;
  final int limit;
  final int offset;
  final String level;

  const _ServerLogPage({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
    required this.level,
  });
}

class _ServerBatch {
  final List<String> lines;
  final List<String> keys;

  const _ServerBatch({required this.lines, required this.keys});
}

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

enum _LogPageSource {
  app('APP'),
  server('服务端');

  final String label;

  const _LogPageSource(this.label);
}

class _LogPalette {
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

  const _LogPalette({
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
  });

  factory _LogPalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _LogPalette(
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
      );
    }
    return const _LogPalette(
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
    );
  }
}
