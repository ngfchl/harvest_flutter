import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:harvest/core/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ══════════════════════════════════════════════════════════
//  全局管理器
// ══════════════════════════════════════════════════════════

class LogOverlayManager {
  static OverlayEntry? _entry;
  static bool _visible = false;

  static bool get isVisible => _visible;

  static void show(BuildContext context) {
    if (_entry != null) return;
    _visible = true;
    _entry = OverlayEntry(builder: (_) => const _LogFloatingWidget());
    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
    _visible = false;
  }

  static void toggle(BuildContext context) {
    _visible ? hide() : show(context);
  }
}

// ══════════════════════════════════════════════════════════
//  日志级别过滤
// ══════════════════════════════════════════════════════════

enum _FilterLevel {
  all('ALL', Color(0xFFC9D1D9)),
  verbose('V', Color(0xFF8B949E)),
  debug('D', Color(0xFF7EE787)),
  info('I', Color(0xFF58A6FF)),
  warn('W', Color(0xFFD29922)),
  error('E', Color(0xFFF85149));

  final String label;
  final Color color;

  const _FilterLevel(this.label, this.color);
}

// ══════════════════════════════════════════════════════════
//  悬浮窗主体
// ══════════════════════════════════════════════════════════

class _LogFloatingWidget extends StatefulWidget {
  const _LogFloatingWidget();

  @override
  State<_LogFloatingWidget> createState() => _LogFloatingWidgetState();
}

class _LogFloatingWidgetState extends State<_LogFloatingWidget> with SingleTickerProviderStateMixin {
  // ── 位置 & 大小 ──
  Offset _position = const Offset(16, 200);
  Size _size = const Size(360, 360);
  late Offset _minimizedPosition;

  // ── 状态 ──
  bool _minimized = false;
  bool _following = true;
  bool _expanded = false;

  // ── 过滤 ──
  _FilterLevel _filter = _FilterLevel.all;

  // ── 日志数据 ──
  final List<String> _lines = [];
  Timer? _tailTimer;
  int _lastFileLength = 0;
  String? _currentLogPath;

  bool _showLevelPicker = false;

  // ── 滚动 ──
  final _scrollController = ScrollController();

  // ── 动画 ──
  late AnimationController _animCtrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _minimizedPosition = Offset(MediaQueryData.fromView(WidgetsBinding.instance.window).size.width - 60, 200);
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _opacity = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _startTailing();
  }

  @override
  void dispose() {
    _tailTimer?.cancel();
    _scrollController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ────────────────── 日志追踪 ──────────────────

  Future<void> _startTailing() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final date = DateTime.now().toString().split(' ')[0];
      final logPath = p.join(dir.path, 'logs', 'app_$date.log');
      final file = File(logPath);

      if (!await file.exists()) {
        _tailTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
          if (await File(logPath).exists()) {
            _tailTimer?.cancel();
            _currentLogPath = logPath;
            await _loadInitial(file);
            _startPeriodic();
          }
        });
        return;
      }

      _currentLogPath = logPath;
      await _loadInitial(file);
      _startPeriodic();
    } catch (e) {
      _addLine('[SYSTEM] 日志追踪失败: $e');
    }
  }

  Future<void> _loadInitial(File file) async {
    try {
      final content = await file.readAsString();
      _lastFileLength = content.length;
      final lines = content.split('\n').where((l) => l.isNotEmpty).toList();
      final tail = lines.length > 200 ? lines.sublist(lines.length - 200) : lines;
      setState(() => _lines.addAll(tail));
      _scrollToBottom();
    } catch (_) {}
  }

  void _startPeriodic() {
    _tailTimer?.cancel();
    _tailTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tailUpdate());
  }

  Future<void> _tailUpdate() async {
    if (_currentLogPath == null) return;
    try {
      final file = File(_currentLogPath!);
      if (!await file.exists()) return;

      final stat = await file.stat();
      final currentLength = stat.size;
      if (currentLength <= _lastFileLength) return;

      final raf = file.openSync(mode: FileMode.read);
      raf.setPositionSync(_lastFileLength);
      final newBytes = raf.readSync(currentLength - _lastFileLength);
      raf.closeSync();
      _lastFileLength = currentLength;

      final newContent = String.fromCharCodes(newBytes);
      final newLines = newContent.split('\n').where((l) => l.isNotEmpty).toList();
      if (newLines.isEmpty) return;

      setState(() => _lines.addAll(newLines));

      if (_lines.length > 2000) {
        setState(() => _lines.removeRange(0, _lines.length - 1500));
      }

      if (_following) _scrollToBottom();
    } catch (_) {}
  }

  void _addLine(String line) {
    setState(() => _lines.add(line));
    if (_following) _scrollToBottom();
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
    switch (_filter) {
      case _FilterLevel.all:
        return true;
      case _FilterLevel.verbose:
        return line.contains('[VERBOSE]');
      case _FilterLevel.debug:
        return line.contains('[DEBUG]');
      case _FilterLevel.info:
        return line.contains('[INFO]');
      case _FilterLevel.warn:
        return line.contains('[WARN]');
      case _FilterLevel.error:
        return line.contains('[ERROR]');
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

  // ── 操作 ──

  Future<void> _deleteAllFiles() async {
    try {
      await AppLogger.deleteAllLogFiles();
      setState(() {
        _lines.clear();
        _lastFileLength = 0;
      });
      Toast.success('已删除所有日志文件');
    } catch (e) {
      Toast.error('删除失败');
    }
  }

  // ────────────────── 构建 ──────────────────

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _minimized ? _minimizedPosition.dx : _position.dx,
      top: _minimized ? _minimizedPosition.dy : _position.dy,
      child: FadeTransition(opacity: _opacity, child: _minimized ? _buildMinimized() : _buildPanel()),
    );
  }

  // ────────────────── 最小化浮球 ──────────────────

  Widget _buildMinimized() {
    return GestureDetector(
      onTap: () => setState(() => _minimized = false),
      onPanUpdate: (d) => setState(() => _minimizedPosition += d.delta),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF30363D)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(shadcn.LucideIcons.terminal, size: 18, color: Color(0xFF58A6FF)),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF3FB950), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────── 完整面板 ──────────────────

  Widget _buildPanel() {
    final panelHeight = _expanded ? _size.height + 200.0 : _size.height;

    return GestureDetector(
      onPanUpdate: (d) => setState(() => _position += d.delta),
      child: Container(
        width: _size.width,
        height: panelHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF30363D)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            Expanded(child: _buildLogList()),
            _buildToolbar(),
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  // ── 标题栏 ──

  Widget _buildHeader() {
    return GestureDetector(
      onPanUpdate: (d) => setState(() => _position += d.delta),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          color: Color(0xFF161B22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Row(
          children: [
            const Icon(shadcn.LucideIcons.terminal, size: 14, color: Color(0xFF58A6FF)),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                '日志',
                style: TextStyle(color: Color(0xFFE6EDF3), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            // LIVE / PAUSE
            GestureDetector(
              onTap: () => setState(() => _following = !_following),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _following
                      ? const Color(0xFF238636).withOpacity(0.2)
                      : const Color(0xFF484F58).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _following ? 'LIVE' : 'PAUSE',
                  style: TextStyle(
                    color: _following ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _headerBtn(
              icon: _expanded ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
              onTap: () => setState(() => _expanded = !_expanded),
            ),
            _headerBtn(icon: Icons.minimize_rounded, onTap: () => setState(() => _minimized = true)),
            _headerBtn(icon: Icons.close_rounded, onTap: () => LogOverlayManager.hide()),
          ],
        ),
      ),
    );
  }

  Widget _headerBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 14, color: const Color(0xFF8B949E)),
      ),
    );
  }

  // ── 级别过滤栏 ──

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
      ),
      child: Row(
        children: _FilterLevel.values.map((level) {
          final selected = level == _filter;
          return GestureDetector(
            onTap: () {
              setState(() => _filter = level);
              if (_following) _scrollToBottom();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: selected ? level.color.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: selected ? level.color.withOpacity(0.4) : Colors.transparent),
              ),
              child: Text(
                level.label,
                style: TextStyle(
                  color: selected ? level.color : const Color(0xFF484F58),
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

    if (filtered.isEmpty) {
      return const Center(
        child: Text('暂无日志', style: TextStyle(color: Color(0xFF484F58), fontSize: 11)),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _buildLine(filtered[i]),
    );
  }

  Widget _buildLine(_IndexedLine item) {
    final color = _getLevelColor(item.line);
    final isLast = item.originalIndex == _lines.length - 1;

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: item.line));
        Toast.success('已复制');
      },
      child: Container(
        color: isLast ? color.withOpacity(0.06) : null,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${item.originalIndex + 1}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF30363D),
                  fontSize: 9,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Container(
              width: 2,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
            ),
            // 级别标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              margin: const EdgeInsets.only(right: 4, top: 1),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(2)),
              child: Text(
                _getLevelTag(item.line),
                style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Text(
                _stripLevelTag(item.line),
                style: TextStyle(color: color.withOpacity(0.8), fontSize: 10, fontFamily: 'monospace', height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 工具栏 ──
  Widget _buildToolbar() {
    final currentLevel = AppLogger.level;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            border: Border(top: BorderSide(color: Color(0xFF21262D))),
          ),
          child: Row(
            children: [
              // ── 日志级别 ──
              GestureDetector(
                onTap: () => setState(() => _showLevelPicker = !_showLevelPicker),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF58A6FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF58A6FF).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded, size: 11, color: Color(0xFF58A6FF)),
                      const SizedBox(width: 3),
                      Text(
                        currentLevel.name.toUpperCase(),
                        style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 2),
                      AnimatedRotation(
                        turns: _showLevelPicker ? 0.5 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: const Icon(Icons.keyboard_arrow_down, size: 12, color: Color(0xFF58A6FF)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(width: 0.5, height: 14, color: const Color(0xFF21262D)),
              const SizedBox(width: 6),
              _toolBtn(icon: Icons.copy_rounded, label: '复制', onTap: _copyAll),
              _toolBtn(icon: shadcn.LucideIcons.share2, label: '分享', onTap: _shareLogs),
              _toolBtn(icon: shadcn.LucideIcons.trash2, label: '清空', onTap: _clearLogs),
              _toolBtn(icon: shadcn.LucideIcons.x, label: '删除文件', onTap: _confirmDeleteFiles, destructive: true),
            ],
          ),
        ),
        // ── 级别下拉面板 ──
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _showLevelPicker ? _buildLevelDropdown() : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildLevelDropdown() {
    final current = AppLogger.level;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(
          top: BorderSide(color: Color(0xFF21262D)),
          bottom: BorderSide(color: Color(0xFF21262D)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Text('日志级别 · 仅影响控制台输出', style: TextStyle(color: Color(0xFF484F58), fontSize: 9)),
          ),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: LogLevel.values.map((level) {
              final selected = level == current;
              final color = _levelColor(level);
              return GestureDetector(
                onTap: () {
                  AppLogger.reinit(level);
                  setState(() => _showLevelPicker = false);
                  Toast.success('已切换为 ${level.name}');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.15) : const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: selected ? color.withOpacity(0.4) : const Color(0xFF21262D)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        level.name[0].toUpperCase() + level.name.substring(1),
                        style: TextStyle(
                          color: selected ? color : const Color(0xFF8B949E),
                          fontSize: 8,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return const Color(0xFF8B949E);
      case LogLevel.debug:
        return const Color(0xFF7EE787);
      case LogLevel.info:
        return const Color(0xFF58A6FF);
      case LogLevel.warn:
        return const Color(0xFFD29922);
      case LogLevel.error:
        return const Color(0xFFF85149);
      case LogLevel.off:
        return const Color(0xFF484F58);
    }
  }

  void _confirmDeleteFiles() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF30363D)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '删除所有日志文件',
                  style: TextStyle(color: Color(0xFFE6EDF3), fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  '将删除所有 .log 和 .zip 文件\n此操作不可撤销',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text('取消', style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _deleteAllFiles();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF85149).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF85149).withOpacity(0.3)),
                        ),
                        child: const Text(
                          '确认删除',
                          style: TextStyle(color: Color(0xFFF85149), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _toolBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color = destructive ? const Color(0xFFF85149) : const Color(0xFF8B949E);

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
    final filtered = _filteredLines;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(color: _filter.color.withOpacity(0.12), borderRadius: BorderRadius.circular(3)),
            child: Text(
              _filter == _FilterLevel.all ? '${_lines.length} 行' : '${filtered.length}/${_lines.length}',
              style: TextStyle(
                color: _filter.color.withOpacity(0.7),
                fontSize: 9,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const Spacer(),
          if (_currentLogPath != null)
            Text(p.basename(_currentLogPath!), style: const TextStyle(color: Color(0xFF30363D), fontSize: 9)),
        ],
      ),
    );
  }

  // ────────────────── 工具 ──────────────────

  Color _getLevelColor(String line) {
    if (line.contains('[ERROR]') || line.contains('❌')) {
      return const Color(0xFFF85149);
    }
    if (line.contains('[WARN]') || line.contains('⚠')) {
      return const Color(0xFFD29922);
    }
    if (line.contains('[INFO]') || line.contains('✅')) {
      return const Color(0xFF58A6FF);
    }
    if (line.contains('[DEBUG]')) {
      return const Color(0xFF7EE787);
    }
    if (line.contains('[VERBOSE]')) {
      return const Color(0xFF8B949E);
    }
    return const Color(0xFFC9D1D9);
  }

  String _getLevelTag(String line) {
    if (line.contains('[ERROR]')) return 'E';
    if (line.contains('[WARN]')) return 'W';
    if (line.contains('[INFO]')) return 'I';
    if (line.contains('[DEBUG]')) return 'D';
    if (line.contains('[VERBOSE]')) return 'V';
    return '-';
  }

  String _stripLevelTag(String line) {
    // 去掉 [2025-05-01T10:00:00.000] [LEVEL] 前缀，只保留内容
    final match = RegExp(r'^$$.*?$$\s*$$.*?$$\s*').matchAsPrefix(line);
    if (match != null) {
      return line.substring(match.end);
    }
    return line;
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
