import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';
import 'package:harvest/widgets/app_dialog.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:harvest/modules/rss/widgets/rss_common.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'model/ai_models.dart';
import 'model/ai_presets.dart';
import 'model/ai_quick_commands.dart';
import 'provider/ai_provider.dart';
import 'service/ai_service.dart';

/// AI 管理页：助手 / 配置 / 诊断 / 用量。
class AiPage extends ConsumerStatefulWidget {
  const AiPage({super.key});

  @override
  ConsumerState<AiPage> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage> {
  int _tabIndex = 0;

  static const _tabs = ['AI 助手', 'AI 配置', '状态诊断', '调用用量'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: GlobalDrawerSwipeArea(
        child: AppBackground(
          child: ColoredBox(
            color: appSurfaceColor(context, cs.background),
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: _AiHeader(onBack: () => Navigator.of(context).pop()),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  decoration: BoxDecoration(
                    color: appSurfaceColor(context, cs.background),
                    border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Tabs(
                      index: _tabIndex,
                      onChanged: (i) => setState(() => _tabIndex = i),
                      children: [for (final t in _tabs) TabItem(child: Text(t))],
                    ),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: const [
                      _AssistantTab(),
                      _ConfigTab(),
                      _DiagnosticsTab(),
                      _UsageTab(),
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
}

// ─────────────────── 头部 ───────────────────

class _AiHeader extends ConsumerWidget {
  final VoidCallback onBack;

  const _AiHeader({required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final config = ref.watch(aiConfigProvider).value;
    final enabled = config?.enabled ?? false;
    return Container(
      padding: appHeaderPadding(context, left: 12, right: 8),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton.ghost(
            onPressed: onBack,
            icon: const Icon(LucideIcons.arrowLeft, size: 18),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI 管理',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  enabled ? '已启用' : '未启用',
                  style: TextStyle(
                    fontSize: 11,
                    color: enabled ? cs.primary : cs.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          IconButton.ghost(
            onPressed: () => ref.read(aiConfigProvider.notifier).refresh(),
            icon: const Icon(LucideIcons.refreshCw, size: 16),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── AI 助手 ───────────────────

class _ChatBubble {
  final String role;
  final String content;
  final String status;
  final AiContextSnapshot? context;
  final DateTime createdAt;

  const _ChatBubble({
    required this.role,
    required this.content,
    this.status = 'done',
    this.context,
    required this.createdAt,
  });
}

class _AssistantTab extends ConsumerStatefulWidget {
  const _AssistantTab();

  @override
  ConsumerState<_AssistantTab> createState() => _AssistantTabState();
}

class _AssistantTabState extends ConsumerState<_AssistantTab> {
  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();
  final _scrollCtrl = ScrollController();
  final List<_ChatBubble> _messages = [];
  bool _sending = false;
  AiContextSnapshot? _lastContext;

  // ───────── 聊天历史 ─────────
  final List<String> _historyDates = [];
  String? _selectedDate; // null = 最新（当天）
  String _cursorDate = '';
  int _cursor = 0;
  bool _hasMore = false;
  bool _loadingDates = false;
  bool _loadingHistory = false;
  bool _loadingMore = false;
  String? _historyError;

  static const _maxInput = 4000;
  static const _pageSize = 20;

  /// 桌面端右侧状态栏固定宽度（原先 flex 2 约占 40%，过宽）。
  static const double _kStatusPanelWidth = 300;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapHistory());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _inputFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _prevDay(String date) {
    final d = DateTime.parse(date).subtract(const Duration(days: 1));
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// 首次加载：日期列表 + 当天记录。
  Future<void> _bootstrapHistory() async {
    setState(() => _loadingDates = true);
    try {
      final dates = await AiService.fetchHistoryDates();
      if (!mounted) return;
      setState(() {
        _historyDates
          ..clear()
          ..addAll(dates);
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingDates = false);
    }
    await _loadFirstPage(date: null);
  }

  /// 加载某天最新一页；date 为 null 表示当天。
  Future<void> _loadFirstPage({String? date}) async {
    setState(() {
      _loadingHistory = true;
      _historyError = null;
    });
    try {
      final page = await AiService.fetchHistory(date: date, cursor: 0, limit: _pageSize);
      if (!mounted) return;
      final bubbles = page.items.reversed.map(_bubbleFromHistory).toList();
      setState(() {
        _messages
          ..clear()
          ..addAll(bubbles);
        _selectedDate = page.date.isEmpty ? date : page.date;
        _cursorDate = _selectedDate ?? '';
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
        _lastContext = bubbles.isNotEmpty ? bubbles.last.context : _lastContext;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _historyError = _errText(e));
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  /// 加载更早记录；当前日期取尽则回退到前一天。
  Future<void> _loadMoreHistory() async {
    if (_loadingMore || _cursorDate.isEmpty) return;
    setState(() => _loadingMore = true);
    try {
      var date = _cursorDate;
      var cursor = _cursor;
      AiChatHistoryPage? page;
      // 当前日期还有更多 → 直接翻页；否则回退一天重新取最新一页。
      page = await AiService.fetchHistory(date: date, cursor: cursor, limit: _pageSize);
      var older = page.items.reversed.map(_bubbleFromHistory).toList();
      if (older.isEmpty && !page.hasMore) {
        // 该日期已取尽，回退到上一个有记录的日期。
        var prev = _prevDay(date);
        var guard = 0;
        while (guard < 366) {
          final p = await AiService.fetchHistory(date: prev, cursor: 0, limit: _pageSize);
          if (p.items.isNotEmpty) {
            page = p;
            older = p.items.reversed.map(_bubbleFromHistory).toList();
            date = prev;
            break;
          }
          if (!_historyDates.contains(prev)) break;
          prev = _prevDay(prev);
          guard++;
        }
      }
      if (!mounted) return;
      if (older.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }
      setState(() {
        _messages.insertAll(0, older);
        _cursorDate = page!.date.isEmpty ? date : page.date;
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _historyError = _errText(e));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  /// 回到最新（当天）记录。
  Future<void> _backToLatest() => _loadFirstPage(date: null);

  _ChatBubble _bubbleFromHistory(AiChatHistoryItem item) => _ChatBubble(
        role: item.role,
        content: item.content,
        status: item.status.isEmpty ? 'done' : item.status,
        context: item.context.sitesTotal > 0 ||
                item.context.downloadersTotal > 0 ||
                item.context.rssFeeds > 0 ||
                item.context.scheduleTasks > 0 ||
                item.context.recentResults > 0
            ? item.context
            : null,
        createdAt: DateTime.tryParse(item.createdAt.replaceAll(' ', 'T')) ?? DateTime.now(),
      );

  /// 选中快速指令：把完整提问填入输入框。
  void _applyCommand(AiQuickCommand cmd) {
    _inputCtrl.text = cmd.prompt;
    _inputCtrl.selection = TextSelection.collapsed(offset: _inputCtrl.text.length);
    if (!_inputFocus.hasFocus) _inputFocus.requestFocus();
    setState(() {});
  }

  /// 输入框当前匹配到的快速指令。
  List<AiQuickCommand> get _commandMatches => matchQuickCommands(_inputCtrl.text);

  /// 把异常转成干净可读的错误文案，去掉重复前缀。
  static String _errText(Object e) {
    var t = e.toString().replaceFirst('Exception: ', '').replaceFirst('Error: ', '').trim();
    // 折叠 "X失败：AI 请求失败" 这类重复前缀。
    t = t.replaceFirst(RegExp(r'^[^：]*失败：(?=AI 请求失败)'), '');
    if (t.isEmpty) t = '请求失败，请稍后重试';
    return t;
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  /// 直接发送一条快速指令（点击 chips 时调用）。
  void _sendCommand(AiQuickCommand cmd) {
    _sendMessage(cmd.prompt);
  }

  Future<void> _send() => _sendMessage(_inputCtrl.text);

  Future<void> _sendMessage(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _sending) return;
    if (text.length > _maxInput) {
      Toast.error('输入不能超过 $_maxInput 字符');
      return;
    }
    final usage = ref.read(aiUsageProvider).value;
    if (usage != null && usage.dailyLimit > 0 && usage.totalTokens >= usage.dailyLimit) {
      Toast.error('今日 Token 额度已用尽，请明日再试');
      return;
    }
    setState(() {
      _sending = true;
      _messages.add(_ChatBubble(role: 'user', content: text, createdAt: DateTime.now()));
      _inputCtrl.clear();
    });
    _scrollToEnd();
    try {
      final result = await AiService.chat(text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatBubble(
            role: 'assistant',
            content: result.text,
            context: result.context,
            createdAt: DateTime.now(),
          ),
        );
        _lastContext = result.context;
      });
      unawaited(ref.read(aiUsageProvider.notifier).refresh());
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatBubble(
            role: 'assistant',
            content: _errText(e),
            status: 'error',
            createdAt: DateTime.now(),
          ),
        );
      });
      _scrollToEnd();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _clear() {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定要清空当前对话记录吗？'),
        actions: [
          Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          Button.destructive(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _messages.clear());
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mobile = context.isMobile;
    final config = ref.watch(aiConfigProvider).value;
    final usage = ref.watch(aiUsageProvider).value;
    final quotaExhausted = usage != null && usage.dailyLimit > 0 && usage.totalTokens >= usage.dailyLimit;

    final chat = Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _loadingHistory
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.bot, size: 40, color: cs.mutedForeground.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text('AI 管理助手', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          '可以询问站点签到、下载器状态、RSS 订阅等问题',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: cs.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: _messages.length + (_sending ? 1 : 0) + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) return _buildHistoryHeader();
                    final idx = i - 1;
                    if (idx >= _messages.length) return const _TypingBubble();
                    final last = idx == _messages.length - 1;
                    final canRegenerate =
                        last && _messages[idx].role == 'assistant' && _messages[idx].status == 'done';
                    return _Bubble(
                      bubble: _messages[idx],
                      onRegenerate: canRegenerate ? _regenerate : null,
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.viewPaddingOf(context).bottom),
          decoration: BoxDecoration(
            color: appSurfaceColor(context, cs.background),
            border: Border(top: BorderSide(color: cs.border, width: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (quotaExhausted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(LucideIcons.circleAlert, size: 13, color: cs.destructive),
                      const SizedBox(width: 6),
                      Text(
                        '今日 Token 额度已用尽，助手已禁用',
                        style: TextStyle(fontSize: 11.5, color: cs.destructive),
                      ),
                    ],
                  ),
                ),
              _QuickCommandChips(onPick: _sendCommand, enabled: !_sending && !quotaExhausted),
              if (_commandMatches.isNotEmpty && _inputCtrl.text.trimLeft().startsWith('/'))
                _CommandSuggestionPanel(matches: _commandMatches, onPick: _applyCommand),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ShadTextField(
                      controller: _inputCtrl,
                      focusNode: _inputFocus,
                      hintText: '问问 AI，或输入 / 使用快速指令...',
                      maxLines: 4,
                      minLines: 1,
                      enabled: !_sending && !quotaExhausted,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) {
                        final m = _commandMatches;
                        if (m.isNotEmpty && _inputCtrl.text.trimLeft().startsWith('/')) {
                          _applyCommand(m.first);
                        } else {
                          _send();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (mobile)
                    IconButton.ghost(
                      onPressed: () => _openMobileStatusSheet(context, usage, config?.enabled ?? false),
                      icon: const Icon(LucideIcons.panelRightOpen, size: 16),
                    ),
                  IconButton.ghost(
                    onPressed: _sending ? null : _clear,
                    icon: const Icon(LucideIcons.eraser, size: 16),
                  ),
                  const SizedBox(width: 4),
                  Button.primary(
                    onPressed: _sending || quotaExhausted ? null : _send,
                    child: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : const Text('发送'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (mobile) return chat;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: chat),
        Container(width: 1, color: cs.border.withValues(alpha: 0.6)),
        SizedBox(
          width: _kStatusPanelWidth,
          child: _StatusPanel(
            context: _lastContext,
            usage: usage,
            enabled: config?.enabled ?? false,
            dates: _historyDates,
            selectedDate: _selectedDate,
            loadingDates: _loadingDates,
            onSelectDate: (d) => _loadFirstPage(date: d),
            onBackToLatest: _backToLatest,
          ),
        ),
      ],
    );
  }

  /// 历史列表顶部：加载更早 / 回到最新。
  Widget _buildHistoryHeader() {
    final cs = Theme.of(context).colorScheme;
    if (_historyError != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(LucideIcons.circleAlert, size: 14, color: cs.destructive),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_historyError!, style: TextStyle(fontSize: 12, color: cs.destructive)),
            ),
            IconButton.ghost(
              size: ButtonSize.small,
              density: ButtonDensity.iconDense,
              onPressed: _loadMoreHistory,
              icon: const Icon(LucideIcons.refreshCw, size: 14),
            ),
          ],
        ),
      );
    }
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (!_hasMore && _selectedDate == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: _hasMore
            ? Button.ghost(
                onPressed: _loadMoreHistory,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.chevronsUp, size: 14),
                    SizedBox(width: 6),
                    Text('加载更早消息'),
                  ],
                ),
              )
            : Button.ghost(
                onPressed: _backToLatest,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.refreshCw, size: 14),
                    const SizedBox(width: 6),
                    Text('回到最新（${_selectedDate ?? ''}）'),
                  ],
                ),
              ),
      ),
    );
  }

  /// 移动端：把状态面板放进底部弹层（移动端无右侧栏）。
  void _openMobileStatusSheet(BuildContext context, AiUsage? usage, bool enabled) {
    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      title: 'AI 状态',
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        child: _StatusPanel(
          context: _lastContext,
          usage: usage,
          enabled: enabled,
          dates: _historyDates,
          selectedDate: _selectedDate,
          loadingDates: _loadingDates,
          onSelectDate: (d) {
            _loadFirstPage(date: d);
            Navigator.of(context).pop();
          },
          onBackToLatest: () {
            _backToLatest();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _regenerate() {
    if (_sending) return;
    String lastUser = '';
    for (var i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].role == 'user') {
        lastUser = _messages[i].content;
        break;
      }
    }
    if (lastUser.isEmpty) return;
    setState(() {
      if (_messages.isNotEmpty && _messages.last.role == 'assistant') _messages.removeLast();
      _inputCtrl.text = lastUser;
    });
    _send();
  }
}

/// AI 正在输入的加载气泡（三个点动画）。
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.bot, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cs.muted.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.border.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  _TypingDot(controller: _controller, index: i),
                ],
                const SizedBox(width: 10),
                Text(
                  'AI 正在思考...',
                  style: TextStyle(fontSize: 12, color: cs.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const _TypingDot({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.25, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(index * 0.2, 0.6 + index * 0.2, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _ChatBubble bubble;
  final VoidCallback? onRegenerate;

  const _Bubble({required this.bubble, this.onRegenerate});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUser = bubble.role == 'user';
    final isError = bubble.status == 'error';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Icon(LucideIcons.bot, size: 18, color: isError ? cs.destructive : cs.primary),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? cs.primary.withValues(alpha: 0.12)
                    : isError
                        ? cs.destructive.withValues(alpha: 0.08)
                        : cs.muted.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isError ? cs.destructive.withValues(alpha: 0.3) : cs.border.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BubbleContent(
                    text: bubble.content,
                    isError: isError,
                  ),
                  if (bubble.context != null) ...[
                    const SizedBox(height: 8),
                    _ContextChips(context: bubble.context!),
                  ],
                  if (!isUser && bubble.status == 'done')
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.ghost(
                            size: ButtonSize.small,
                            density: ButtonDensity.iconDense,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: bubble.content));
                              Toast.success('已复制');
                            },
                            icon: const Icon(LucideIcons.copy, size: 13),
                          ),
                          if (onRegenerate != null)
                            IconButton.ghost(
                              size: ButtonSize.small,
                              density: ButtonDensity.iconDense,
                              onPressed: onRegenerate,
                              icon: const Icon(LucideIcons.refreshCw, size: 13),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Icon(LucideIcons.user, size: 18, color: cs.mutedForeground),
          ],
        ],
      ),
    );
  }
}

/// 检测文本是否为 Markdown 格式。
bool _looksLikeMarkdown(String text) {
  final t = text.trim();
  if (t.isEmpty) return false;
  // 代码块
  if (RegExp(r'```').hasMatch(t)) return true;
  // 标题
  if (RegExp(r'^#{1,6}\s', multiLine: true).hasMatch(t)) return true;
  // 无序/有序列表
  if (RegExp(r'^\s*[-*+]\s+', multiLine: true).hasMatch(t)) return true;
  if (RegExp(r'^\s*\d+\.\s+', multiLine: true).hasMatch(t)) return true;
  // 引用
  if (RegExp(r'^\s*>\s?', multiLine: true).hasMatch(t)) return true;
  // 粗体/斜体
  if (RegExp(r'\*\*[^*]+\*\*').hasMatch(t)) return true;
  if (RegExp(r'\*[^*]+\*').hasMatch(t)) return true;
  if (RegExp(r'__[^_]+__').hasMatch(t)) return true;
  // 行内代码
  if (RegExp(r'`[^`\n]+`').hasMatch(t)) return true;
  // 链接/图片
  if (RegExp(r'!?\[[^\]]*\]\([^\)]+\)').hasMatch(t)) return true;
  // 表格
  if (RegExp(r'^\s*\|.*\|\s*$', multiLine: true).hasMatch(t) &&
      RegExp(r'^\s*\|?[\s:|-]+\|\s*$', multiLine: true).hasMatch(t)) {
    return true;
  }
  // 分隔线
  if (RegExp(r'^\s*([-*_])\s*(\1\s*){2,}$', multiLine: true).hasMatch(t)) return true;
  return false;
}

MarkdownStyleSheet _aiMarkdownStyleSheet(BuildContext context, {Color? textColor}) {
  final cs = Theme.of(context).colorScheme;
  final typo = Theme.of(context).typography;
  final base = textColor ?? cs.foreground;
  final body = typo.small.copyWith(color: base, height: 1.55);

  return MarkdownStyleSheet(
    a: body.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
    p: body,
    pPadding: const EdgeInsets.only(bottom: 8),
    h1: typo.large.copyWith(color: base, fontWeight: FontWeight.w700, height: 1.35),
    h1Padding: const EdgeInsets.only(bottom: 8),
    h2: typo.base.copyWith(color: base, fontWeight: FontWeight.w700, height: 1.35),
    h2Padding: const EdgeInsets.only(bottom: 6),
    h3: typo.small.copyWith(color: base, fontWeight: FontWeight.w700, height: 1.35),
    h3Padding: const EdgeInsets.only(bottom: 6),
    h4: body.copyWith(fontWeight: FontWeight.w700),
    h5: body.copyWith(fontWeight: FontWeight.w700),
    h6: body.copyWith(fontWeight: FontWeight.w700),
    strong: const TextStyle(fontWeight: FontWeight.w700),
    em: const TextStyle(fontStyle: FontStyle.italic),
    del: const TextStyle(decoration: TextDecoration.lineThrough),
    blockSpacing: 8,
    listIndent: 22,
    listBullet: body.copyWith(color: cs.mutedForeground),
    code: typo.xSmall.copyWith(
      color: base,
      fontFamily: 'monospace',
      backgroundColor: cs.muted.withValues(alpha: 0.3),
    ),
    codeblockPadding: const EdgeInsets.all(10),
    codeblockDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.3),
      border: Border.all(color: cs.border.withValues(alpha: 0.6), width: 0.7),
      borderRadius: BorderRadius.circular(6),
    ),
    blockquote: body.copyWith(color: cs.mutedForeground),
    blockquotePadding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
    blockquoteDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.18),
      border: Border(left: BorderSide(color: cs.primary.withValues(alpha: 0.55), width: 3)),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: cs.border, width: 1)),
    ),
    tableBorder: TableBorder.all(color: cs.border, width: 0.7),
    tableHead: body.copyWith(fontWeight: FontWeight.w700),
    tableBody: body,
    tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  );
}

/// 气泡正文：Markdown 内容用富文本渲染，纯文本保持可选中。
class _BubbleContent extends StatelessWidget {
  final String text;
  final bool isError;

  const _BubbleContent({required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMd = !isError && _looksLikeMarkdown(text);
    if (isMd) {
      return MarkdownBody(
        data: text,
        selectable: true,
        fitContent: false,
        softLineBreak: true,
        styleSheet: _aiMarkdownStyleSheet(context, textColor: cs.foreground),
      );
    }
    return SelectableText(
      text,
      style: TextStyle(
        fontSize: 13.5,
        height: 1.5,
        color: isError ? cs.destructive : cs.foreground,
      ),
    );
  }
}

class _ContextChips extends StatelessWidget {
  final AiContextSnapshot context;

  const _ContextChips({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    Widget chip(String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: cs.muted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(text, style: TextStyle(fontSize: 10.5, color: cs.mutedForeground)),
        );
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        chip('站点 ${context.sitesEnabled}/${context.sitesTotal}'),
        chip('下载器 ${context.downloadersActive}/${context.downloadersTotal}'),
        chip('任务 ${context.scheduleTasks}'),
        chip('RSS ${context.rssFeeds}'),
        chip('订阅 ${context.rssSubscriptions}'),
      ],
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final AiContextSnapshot? context;
  final AiUsage? usage;
  final bool enabled;
  final List<String> dates;
  final String? selectedDate;
  final bool loadingDates;
  final ValueChanged<String> onSelectDate;
  final VoidCallback onBackToLatest;

  const _StatusPanel({
    required this.context,
    required this.usage,
    required this.enabled,
    required this.dates,
    required this.selectedDate,
    required this.loadingDates,
    required this.onSelectDate,
    required this.onBackToLatest,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final snap = this.context;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PanelCard(
          title: '聊天历史',
          icon: LucideIcons.history,
          child: _HistoryDates(
            dates: dates,
            selectedDate: selectedDate,
            loading: loadingDates,
            onSelect: onSelectDate,
            onBackToLatest: onBackToLatest,
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: '运行状态',
          icon: LucideIcons.activity,
          child: snap == null
              ? Text('发送消息后展示项目状态', style: TextStyle(fontSize: 12.5, color: cs.mutedForeground))
              : _StatusRows(snap: snap),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: '今日 Token 用量',
          icon: LucideIcons.gauge,
          child: usage == null
              ? Text('暂无数据', style: TextStyle(fontSize: 12.5, color: cs.mutedForeground))
              : _UsageMini(usage: usage!),
        ),
      ],
    );
  }
}

/// 聊天历史日期列表。
class _HistoryDates extends StatelessWidget {
  final List<String> dates;
  final String? selectedDate;
  final bool loading;
  final ValueChanged<String> onSelect;
  final VoidCallback onBackToLatest;

  const _HistoryDates({
    required this.dates,
    required this.selectedDate,
    required this.loading,
    required this.onSelect,
    required this.onBackToLatest,
  });

  String _formatDate(String date) {
    final d = DateTime.tryParse(date);
    if (d == null) return date;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    final label = switch (diff) {
      0 => '今天',
      1 => '昨天',
      2 => '前天',
      _ => '${d.month}月${d.day}日',
    };
    final weekday = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][d.weekday - 1];
    return '$label（$weekday）';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (dates.isEmpty) {
      return Text('暂无历史记录', style: TextStyle(fontSize: 12.5, color: cs.mutedForeground));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 回到最新
        _DateRow(
          label: '最新（今天）',
          selected: selectedDate == null,
          onTap: onBackToLatest,
        ),
        const SizedBox(height: 4),
        for (final date in dates) ...[
          _DateRow(
            label: _formatDate(date),
            date: date,
            selected: selectedDate == date,
            onTap: () => onSelect(date),
          ),
          const SizedBox(height: 2),
        ],
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String? date;
  final bool selected;
  final VoidCallback onTap;

  const _DateRow({required this.label, this.date, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? cs.primary.withValues(alpha: 0.3) : cs.border.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.calendarDays,
              size: 13,
              color: selected ? cs.primary : cs.mutedForeground,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? cs.primary : cs.foreground,
                ),
              ),
            ),
            if (date != null)
              Text(
                date!,
                style: TextStyle(fontSize: 10.5, color: cs.mutedForeground),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusRows extends StatelessWidget {
  final AiContextSnapshot snap;

  const _StatusRows({required this.snap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget row(String label, String value, {bool warn = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(fontSize: 12.5, color: cs.mutedForeground))),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: warn ? cs.destructive : cs.foreground,
                ),
              ),
            ],
          ),
        );
    return Column(
      children: [
        row('站点', '${snap.sitesEnabled}/${snap.sitesTotal} 启用', warn: snap.sitesEnabled == 0),
        row('下载器', '${snap.downloadersActive}/${snap.downloadersTotal} 活跃', warn: snap.downloadersActive == 0),
        row('计划任务', '${snap.scheduleTasks} 个'),
        row('RSS 源', '${snap.rssFeeds} 个'),
        row('RSS 订阅', '${snap.rssSubscriptions} 个'),
        row('最近任务结果', '${snap.recentResults} 条'),
      ],
    );
  }
}

class _UsageMini extends StatelessWidget {
  final AiUsage usage;

  const _UsageMini({required this.usage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = (usage.ratio * 100).clamp(0, 100).toDouble();
    final warn = pct >= 80;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_fmt(usage.totalTokens)} / ${_fmt(usage.dailyLimit)}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: warn ? cs.destructive : cs.foreground),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: usage.dailyLimit <= 0 ? 0 : usage.ratio.clamp(0, 1),
            minHeight: 6,
            backgroundColor: cs.muted.withValues(alpha: 0.4),
            color: warn ? cs.destructive : cs.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text('${pct.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: cs.mutedForeground)),
      ],
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _PanelCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppSurfaceContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: cs.primary),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// 输入框上方的快速指令 chips（横向滚动）。
class _QuickCommandChips extends StatelessWidget {
  final ValueChanged<AiQuickCommand> onPick;
  final bool enabled;

  const _QuickCommandChips({required this.onPick, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.zap, size: 12, color: cs.mutedForeground),
              const SizedBox(width: 4),
              Text('快速指令', style: TextStyle(fontSize: 11, color: cs.mutedForeground)),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kAiQuickCommands.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final cmd = kAiQuickCommands[i];
                return Tooltip(
                  tooltip: (_) => TooltipContainer(child: Text(cmd.description, style: const TextStyle(fontSize: 12))),
                  child: GestureDetector(
                    onTap: enabled ? () => onPick(cmd) : null,
                    child: Opacity(
                      opacity: enabled ? 1 : 0.5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: cs.muted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: cs.border.withValues(alpha: 0.6), width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.command, size: 11, color: cs.primary),
                            const SizedBox(width: 5),
                            Text(
                              cmd.label,
                              style: TextStyle(fontSize: 12, color: cs.foreground),
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
        ],
      ),
    );
  }
}

/// 输入 `/` 时展示的自动补全建议面板。
class _CommandSuggestionPanel extends StatelessWidget {
  final List<AiQuickCommand> matches;
  final ValueChanged<AiQuickCommand> onPick;

  const _CommandSuggestionPanel({required this.matches, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      constraints: const BoxConstraints(maxHeight: 190),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.border.withValues(alpha: 0.7), width: 0.6),
        boxShadow: [
          BoxShadow(color: cs.foreground.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: matches.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: cs.border.withValues(alpha: 0.4)),
        itemBuilder: (_, i) {
          final cmd = matches[i];
          return _CommandTile(cmd: cmd, onTap: () => onPick(cmd));
        },
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  final AiQuickCommand cmd;
  final VoidCallback onTap;

  const _CommandTile({required this.cmd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(LucideIcons.command, size: 14, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cmd.command,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cmd.description,
                    style: TextStyle(fontSize: 11.5, color: cs.mutedForeground),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.cornerDownLeft, size: 13, color: cs.mutedForeground),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── AI 配置 ───────────────────

class _ConfigTab extends ConsumerStatefulWidget {
  const _ConfigTab();

  @override
  ConsumerState<_ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends ConsumerState<_ConfigTab> {
  final _baseUrlCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _temperatureCtrl = TextEditingController();
  final _maxTokensCtrl = TextEditingController();
  final _timeoutCtrl = TextEditingController();
  final _dailyLimitCtrl = TextEditingController();
  final _concurrencyCtrl = TextEditingController();

  bool _enabled = false;
  bool _allowWrite = false;
  String _provider = 'openai';
  bool _saving = false;
  bool _testing = false;
  bool _loaded = false;

  String? _presetName;

  void _applyPreset(AiPresetService preset) {
    setState(() {
      _presetName = preset.name;
      _provider = preset.provider;
      if (preset.baseUrl.isNotEmpty) _baseUrlCtrl.text = preset.baseUrl;
      if (preset.models.isNotEmpty) _modelCtrl.text = preset.models.first;
    });
    if (preset.baseUrl.isNotEmpty) {
      Toast.success('已应用预设：${preset.name}');
    }
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _modelCtrl.dispose();
    _temperatureCtrl.dispose();
    _maxTokensCtrl.dispose();
    _timeoutCtrl.dispose();
    _dailyLimitCtrl.dispose();
    _concurrencyCtrl.dispose();
    super.dispose();
  }

  void _applyConfig(AiConfig c) {
    _baseUrlCtrl.text = c.baseUrl;
    _apiKeyCtrl.text = '';
    _modelCtrl.text = c.model;
    _temperatureCtrl.text = '${c.temperature}';
    _maxTokensCtrl.text = '${c.maxTokens}';
    _timeoutCtrl.text = '${c.timeoutSeconds}';
    _dailyLimitCtrl.text = '${c.dailyTokenLimit}';
    _concurrencyCtrl.text = '${c.concurrency}';
    _enabled = c.enabled;
    _allowWrite = c.allowWriteActions;
    _provider = c.provider;
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(aiConfigProvider);
    final cs = Theme.of(context).colorScheme;

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleAlert, size: 32, color: cs.destructive),
            const SizedBox(height: 8),
            Text('$e', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            Button.primary(
              onPressed: () => ref.read(aiConfigProvider.notifier).refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (config) {
        if (!_loaded) {
          _applyConfig(config);
          _loaded = true;
        }
        return _buildForm(context, config);
      },
    );
  }

  Widget _buildForm(BuildContext context, AiConfig config) {
    final cs = Theme.of(context).colorScheme;
    final mobile = context.isMobile;

    return ListView(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 12, mobile ? 12 : 16, 24),
      children: [
        AppSurfaceContainer(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.settings2, size: 15, color: cs.primary),
                  const SizedBox(width: 6),
                  const Text('Provider 配置', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              _label('服务预设'),
              SizedBox(
                width: double.infinity,
                child: Select<String>(
                  value: _presetName,
                  placeholder: const Text('选择常用服务，自动填充地址与模型'),
                  itemBuilder: (_, _) => Text(_presetName ?? ''),
                  popupConstraints: const BoxConstraints(maxHeight: 360),
                  popup: SelectPopup<String>.builder(
                    searchPlaceholder: const Text('搜索服务商或域名...'),
                    emptyBuilder: (ctx) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '没有匹配的服务商',
                        style: TextStyle(fontSize: 13, color: Theme.of(ctx).colorScheme.mutedForeground),
                      ),
                    ),
                    builder: (ctx, query) {
                      final q = (query ?? '').trim().toLowerCase();
                      bool match(AiPresetService p) =>
                          q.isEmpty ||
                          p.name.toLowerCase().contains(q) ||
                          p.domain.toLowerCase().contains(q) ||
                          p.baseUrl.toLowerCase().contains(q);
                      final matched = kAiPresetServices.where(match).toList();
                      return SelectItemList(
                        children: [
                          for (final category in kAiPresetCategories) ...[
                            if (matched.any((p) => p.category == category))
                              SelectGroup(
                                headers: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(ctx).colorScheme.mutedForeground,
                                      ),
                                    ),
                                  ),
                                ],
                                children: [
                                  for (final preset in matched.where((p) => p.category == category))
                                    SelectItemButton<String>(
                                      value: preset.name,
                                      child: Text(preset.domain.isEmpty ? preset.name : '${preset.name}  ·  ${preset.domain}'),
                                    ),
                                ],
                              ),
                          ],
                        ],
                      );
                    },
                  ).call,
                  onChanged: (v) {
                    if (v == null) return;
                    for (final preset in kAiPresetServices) {
                      if (preset.name == v) {
                        _applyPreset(preset);
                        return;
                      }
                    }
                  },
                ),
              ),
              if (_presetName != null) ...[
                const SizedBox(height: 8),
                _PresetModelChips(
                  preset: kAiPresetServices.firstWhere((p) => p.name == _presetName, orElse: () => kAiPresetServices.last),
                  selected: _modelCtrl.text,
                  onPick: (m) => setState(() => _modelCtrl.text = m),
                ),
              ],
              const SizedBox(height: 12),
              _label('Provider 类型'),
              SizedBox(
                width: double.infinity,
                child: Select<String>(
                  value: _provider,
                  placeholder: const Text('openai'),
                  itemBuilder: (_, _) => Text(_provider),
                  popupConstraints: const BoxConstraints(maxHeight: 240),
                  popup: SelectPopup<String>(
                    items: SelectItemList(
                      children: [
                        SelectItemButton<String>(value: 'openai', child: const Text('openai（OpenAI 兼容）')),
                        SelectItemButton<String>(value: 'ollama', child: const Text('ollama')),
                      ],
                    ),
                  ).call,
                  onChanged: (v) {
                    if (v != null) setState(() => _provider = v);
                  },
                ),
              ),
              const SizedBox(height: 12),
              ShadTextField(
                controller: _baseUrlCtrl,
                labelText: 'Base URL',
                hintText: 'https://api.example.com/v1',
                helperText: '必须以 http:// 或 https:// 开头',
              ),
              const SizedBox(height: 12),
              ShadTextField(
                controller: _apiKeyCtrl,
                labelText: 'API Key',
                hintText: config.apiKey.isNotEmpty ? '已配置（${config.apiKey}）' : '留空则不修改已有密钥',
                obscureText: true,
                helperText: '密钥仅保存到后端，前端不做存储',
              ),
              const SizedBox(height: 12),
              ShadTextField(
                controller: _modelCtrl,
                labelText: '模型名称',
                hintText: '例如：gpt-4o-mini',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ShadTextField(
                      controller: _temperatureCtrl,
                      labelText: '温度',
                      hintText: '0.2',
                      keyboardType: TextInputType.number,
                      helperText: '0 ~ 2',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShadTextField(
                      controller: _maxTokensCtrl,
                      labelText: '最大 Token',
                      hintText: '2048',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ShadTextField(
                      controller: _timeoutCtrl,
                      labelText: '超时(秒)',
                      hintText: '60',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShadTextField(
                      controller: _dailyLimitCtrl,
                      labelText: '每日额度',
                      hintText: '100000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ShadTextField(
                controller: _concurrencyCtrl,
                labelText: '并发数',
                hintText: '3',
                keyboardType: TextInputType.number,
                helperText: '建议 1 ~ 16',
              ),
              const SizedBox(height: 12),
              RssSheetGroup(
                children: [
                  RssSheetTile(
                    title: const Text('启用 AI'),
                    helper: const Text('关闭后 AI 助手不可用'),
                    trailing: Switch(value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
                  ),
                  RssSheetTile(
                    title: const Text('允许写操作'),
                    helper: const Text('当前建议保持关闭，AI 默认只读'),
                    trailing: Switch(value: _allowWrite, onChanged: (v) => setState(() => _allowWrite = v)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Button.outline(
                onPressed: _saving || _testing ? null : _save,
                child: _saving
                    ? const SizedBox(width: 16, height: 16, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                    : const Text('保存配置'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Button.outline(
                onPressed: _saving || _testing ? null : _test,
                child: _testing
                    ? const SizedBox(width: 16, height: 16, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                    : const Text('测试连接'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Button.destructive(
                onPressed: _saving || _testing ? null : _restoreDefaults,
                child: const Text('恢复默认'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _label(String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.foreground)),
    );
  }

  bool _validate() {
    final url = _baseUrlCtrl.text.trim();
    if (url.isNotEmpty && !url.startsWith('http://') && !url.startsWith('https://')) {
      Toast.error('Base URL 必须以 http:// 或 https:// 开头');
      return false;
    }
    final temp = double.tryParse(_temperatureCtrl.text.trim());
    if (temp != null && (temp < 0 || temp > 2)) {
      Toast.error('温度必须在 0 ~ 2 之间');
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (_saving || !_validate()) return;
    setState(() => _saving = true);
    try {
      final newConfig = AiConfig(
        enabled: _enabled,
        provider: _provider,
        baseUrl: _baseUrlCtrl.text.trim(),
        apiKey: _apiKeyCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        temperature: double.tryParse(_temperatureCtrl.text.trim()) ?? 0.2,
        maxTokens: int.tryParse(_maxTokensCtrl.text.trim()) ?? 2048,
        timeoutSeconds: int.tryParse(_timeoutCtrl.text.trim()) ?? 60,
        dailyTokenLimit: int.tryParse(_dailyLimitCtrl.text.trim()) ?? 100000,
        concurrency: int.tryParse(_concurrencyCtrl.text.trim()) ?? 3,
        allowWriteActions: _allowWrite,
      );
      final saved = await ref.read(aiConfigProvider.notifier).save(newConfig);
      if (!mounted) return;
      setState(() {
        _apiKeyCtrl.text = '';
        _applyConfig(saved);
      });
      Toast.success('配置已保存');
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _test() async {
    if (_testing) return;
    setState(() => _testing = true);
    try {
      final r = await AiService.testProvider();
      if (!mounted) return;
      appShowDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('测试成功'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('模型：${r.model}'),
                const SizedBox(height: 8),
                Text('回复：${r.text}'),
                const SizedBox(height: 8),
                Text(
                  'Token：输入 ${r.promptTokens} / 输出 ${r.completionTokens}',
                  style: TextStyle(fontSize: 12, color: Theme.of(ctx).colorScheme.mutedForeground),
                ),
              ],
            ),
          ),
          actions: [Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('关闭'))],
        ),
      );
    } catch (_) {
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  void _restoreDefaults() {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复默认'),
        content: const Text('将恢复为内置默认配置（含默认 API Key），确定继续吗？'),
        actions: [
          Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await AiService.saveConfig(const AiConfig());
                await ref.read(aiConfigProvider.notifier).refresh();
                if (mounted) setState(() => _loaded = false);
                Toast.success('已恢复默认配置');
              } catch (_) {}
            },
            child: const Text('恢复'),
          ),
        ],
      ),
    );
  }
}

/// 预设常用模型快捷选择
class _PresetModelChips extends StatelessWidget {
  final AiPresetService preset;
  final String selected;
  final ValueChanged<String> onPick;

  const _PresetModelChips({required this.preset, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    if (preset.models.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('常用模型', style: TextStyle(fontSize: 11.5, color: cs.mutedForeground)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final m in preset.models)
              GestureDetector(
                onTap: () => onPick(m),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected == m ? cs.primary.withValues(alpha: 0.14) : cs.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selected == m ? cs.primary.withValues(alpha: 0.35) : cs.border.withValues(alpha: 0.6),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    m,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: selected == m ? FontWeight.w600 : FontWeight.w400,
                      color: selected == m ? cs.primary : cs.mutedForeground,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────── 状态诊断 ───────────────────

class _DiagnosticsTab extends ConsumerStatefulWidget {
  const _DiagnosticsTab();

  @override
  ConsumerState<_DiagnosticsTab> createState() => _DiagnosticsTabState();
}

class _DiagnosticsTabState extends ConsumerState<_DiagnosticsTab> {
  AiDiagnosisReport? _report;
  bool _running = false;

  Future<void> _run() async {
    if (_running) return;
    setState(() => _running = true);
    try {
      final report = await AiService.runDiagnostics();
      if (mounted) setState(() => _report = report);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mobile = context.isMobile;
    final report = _report;
    final findings = report?.findings ?? const <AiFinding>[];
    final errors = findings.where((f) => f.isError).toList();
    final warnings = findings.where((f) => f.isWarning).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 12, mobile ? 12 : 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                report == null ? '尚未运行诊断' : '诊断完成 · ${findings.length} 条发现',
                style: TextStyle(fontSize: 12, color: cs.mutedForeground),
              ),
            ),
            Button.primary(
              onPressed: _running ? null : _run,
              child: _running
                  ? const SizedBox(width: 16, height: 16, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                  : const Text('运行诊断'),
            ),
            const SizedBox(width: 8),
            if (findings.isNotEmpty)
              Button.outline(
                onPressed: () {
                  final buf = StringBuffer('AI 状态诊断\n');
                  if (report != null) {
                    buf.writeln('站点 ${report.context.sitesEnabled}/${report.context.sitesTotal}，下载器 ${report.context.downloadersActive}/${report.context.downloadersTotal}，RSS 订阅 ${report.context.rssSubscriptions}');
                  }
                  for (final f in findings) {
                    buf.writeln('[${f.level.toUpperCase()}] ${f.code}: ${f.message}');
                  }
                  Clipboard.setData(ClipboardData(text: buf.toString()));
                  Toast.success('诊断摘要已复制');
                },
                child: const Text('复制摘要'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (report != null) ...[
          _PanelCard(
            title: '项目状态',
            icon: LucideIcons.layoutDashboard,
            child: _StatusRows(snap: report.context),
          ),
          const SizedBox(height: 12),
        ],
        if (errors.isNotEmpty) ...[
          _FindingGroup(title: '错误', icon: LucideIcons.circleX, color: cs.destructive, findings: errors),
          const SizedBox(height: 12),
        ],
        if (warnings.isNotEmpty) ...[
          _FindingGroup(title: '警告', icon: LucideIcons.triangleAlert, color: const Color(0xFFF59E0B), findings: warnings),
          const SizedBox(height: 12),
        ],
        if (report != null && findings.isEmpty)
          AppSurfaceContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(LucideIcons.circleCheck, size: 36, color: cs.primary),
                const SizedBox(height: 10),
                const Text('一切正常', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('未发现异常项', style: TextStyle(fontSize: 12.5, color: cs.mutedForeground)),
              ],
            ),
          ),
        if (report == null && !_running)
          AppSurfaceContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(LucideIcons.stethoscope, size: 36, color: cs.mutedForeground.withValues(alpha: 0.5)),
                const SizedBox(height: 10),
                Text('点击「运行诊断」检查站点、下载器、RSS 与任务状态', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: cs.mutedForeground)),
              ],
            ),
          ),
      ],
    );
  }
}

class _FindingGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<AiFinding> findings;

  const _FindingGroup({required this.title, required this.icon, required this.color, required this.findings});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppSurfaceContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text('$title（${findings.length}）', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          for (final f in findings)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.message, style: const TextStyle(fontSize: 13, height: 1.4)),
                        if (f.code.isNotEmpty)
                          Text(f.code, style: TextStyle(fontSize: 10.5, color: cs.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────── 调用用量 ───────────────────

class _UsageTab extends ConsumerWidget {
  const _UsageTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final mobile = context.isMobile;
    final usageAsync = ref.watch(aiUsageProvider);

    return EasyRefresh(
      onRefresh: () => ref.read(aiUsageProvider.notifier).refresh(),
      header: appRefreshHeader(context),
      child: usageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.circleAlert, size: 32, color: cs.destructive),
                const SizedBox(height: 8),
                Text('$e', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                Button.primary(
                  onPressed: () => ref.read(aiUsageProvider.notifier).refresh(),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
        data: (usage) => _UsageBody(usage: usage, mobile: mobile),
      ),
    );
  }
}

class _UsageBody extends StatelessWidget {
  final AiUsage usage;
  final bool mobile;

  const _UsageBody({required this.usage, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = (usage.ratio * 100).clamp(0, 100).toDouble();
    final warn = pct >= 80;

    return ListView(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 12, mobile ? 12 : 16, 24),
      children: [
        AppSurfaceContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.gauge, size: 16, color: warn ? cs.destructive : cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    '今日 Token 用量${usage.day.isEmpty ? '' : ' · ${usage.day}'}',
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _metric(context, '输入 Token', _fmt(usage.promptTokens), cs.foreground),
              _metric(context, '输出 Token', _fmt(usage.completionTokens), cs.foreground),
              _metric(context, '总 Token', _fmt(usage.totalTokens), warn ? cs.destructive : cs.primary),
              _metric(context, '每日额度', _fmt(usage.dailyLimit), cs.foreground),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: usage.dailyLimit <= 0 ? 0 : usage.ratio.clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: cs.muted.withValues(alpha: 0.4),
                  color: warn ? cs.destructive : cs.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('已使用 ${pct.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: warn ? cs.destructive : cs.foreground)),
                  const Spacer(),
                  if (warn)
                    Row(
                      children: [
                        Icon(LucideIcons.triangleAlert, size: 13, color: cs.destructive),
                        const SizedBox(width: 4),
                        Text('接近额度上限', style: TextStyle(fontSize: 11.5, color: cs.destructive)),
                      ],
                    ),
                ],
              ),
              if (usage.totalTokens >= usage.dailyLimit && usage.dailyLimit > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.destructive.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.destructive.withValues(alpha: 0.25), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.circleAlert, size: 15, color: cs.destructive),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '额度已耗尽，AI 助手发送已禁用，次日自动恢复',
                          style: TextStyle(fontSize: 12.5, color: cs.destructive),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _metric(BuildContext context, String label, String value, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: cs.mutedForeground))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
