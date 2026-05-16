import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/browser_page.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'model/notice_history.dart';
import 'provider/notice_provider.dart';

class NoticeHistoryPage extends ConsumerWidget {
  const NoticeHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticeHistoryProvider);

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              _NoticePageHeader(
                title: '通知历史',
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: noticesAsync.when(
                  loading: () =>
                      const Center(child: shadcn.CircularProgressIndicator()),
                  error: (error, _) => _NoticeErrorView(
                    error: error,
                    onRetry: () =>
                        ref.read(noticeHistoryProvider.notifier).refresh(),
                  ),
                  data: (notices) => _NoticeHistoryBody(notices: notices),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticePageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _NoticePageHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final top = MediaQuery.paddingOf(context).top;
    final leadingInset = appHeaderLeadingInset(context);
    final trailingInset = appHeaderTrailingInset(context);

    return AppSurfaceContainer(
      height: top + kAppHeaderHeight,
      padding: EdgeInsets.fromLTRB(
        8 + leadingInset,
        top + 6,
        16 + trailingInset,
        6,
      ),
      borderRadius: BorderRadius.zero,
      color: appSurfaceColor(context, cs.background),
      borderColor: cs.border.withValues(alpha: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          shadcn.IconButton.ghost(
            icon: const Icon(shadcn.LucideIcons.chevronLeft),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.large.copyWith(
                color: cs.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeHistoryBody extends ConsumerWidget {
  final List<NoticeHistory> notices;

  const _NoticeHistoryBody({required this.notices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = notices.where((notice) => !notice.isRead).length;

    return Column(
      children: [
        _NoticeToolbar(totalCount: notices.length, unreadCount: unreadCount),
        Expanded(
          child: EasyRefresh(
            onRefresh: () => ref.read(noticeHistoryProvider.notifier).refresh(),
            header: appRefreshHeader(context),
            child: notices.isEmpty
                ? const _EmptyNoticeView()
                : _NoticeList(notices: notices),
          ),
        ),
      ],
    );
  }
}

class _NoticeToolbar extends ConsumerWidget {
  final int totalCount;
  final int unreadCount;

  const _NoticeToolbar({required this.totalCount, required this.unreadCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return AppSurfaceContainer(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: BorderRadius.zero,
      color: appSurfaceColor(context, cs.background),
      borderColor: cs.border.withValues(alpha: 0.5),
      child: Row(
        children: [
          Icon(
            unreadCount > 0
                ? shadcn.LucideIcons.bellRing
                : shadcn.LucideIcons.bell,
            size: 16,
            color: cs.mutedForeground,
          ),
          const SizedBox(width: 8),
          Text(
            totalCount == 0
                ? '暂无通知'
                : unreadCount > 0
                ? '$unreadCount 条未读通知'
                : '$totalCount 条通知均已读',
            style: typo.small.copyWith(
              color: unreadCount > 0 ? cs.foreground : cs.mutedForeground,
            ),
          ),
          const Spacer(),
          if (totalCount > 0) ...[
            _NoticeToolbarAction(
              tooltip: '删除全部',
              icon: shadcn.LucideIcons.trash2,
              color: cs.destructive,
              onPress: () async {
                final confirmed = await _confirmNoticeAction(
                  context,
                  title: '删除全部',
                  message: '确定要删除全部通知历史吗？此操作不可撤销。',
                  confirmText: '删除全部',
                  destructive: true,
                );
                if (!confirmed) return;
                if (!context.mounted) return;
                try {
                  await ref.read(noticeHistoryProvider.notifier).deleteAll();
                  if (context.mounted) Toast.success('通知历史已删除');
                } catch (e) {
                  Toast.error('删除通知失败');
                }
              },
            ),
          ],
          if (unreadCount > 0) ...[
            const SizedBox(width: 4),
            _NoticeToolbarAction(
              tooltip: '全部已读',
              icon: shadcn.LucideIcons.checkCheck,
              color: cs.foreground,
              onPress: () async {
                final confirmed = await _confirmNoticeAction(
                  context,
                  title: '全部已读',
                  message: '确定要将全部未读通知标记为已读吗？',
                  confirmText: '全部已读',
                );
                if (!confirmed) return;
                if (!context.mounted) return;
                try {
                  await ref.read(noticeHistoryProvider.notifier).markAllRead();
                  if (context.mounted) Toast.success('已全部标记为已读');
                } catch (e) {
                  Toast.error('标记已读失败');
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _NoticeToolbarAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPress;

  const _NoticeToolbarAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return shadcn.Tooltip(
      tooltip: (_) => Text(tooltip),
      child: shadcn.IconButton.ghost(
        icon: Icon(icon, size: 16, color: color),
        onPressed: onPress,
      ),
    );
  }
}

class _NoticeList extends StatelessWidget {
  final List<NoticeHistory> notices;

  const _NoticeList({required this.notices});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: notices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _NoticeTile(notice: notices[index]),
    );
  }
}

Future<bool> _confirmNoticeAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        shadcn.Button.ghost(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('取消'),
        ),
        if (destructive)
          shadcn.Button.destructive(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          )
        else
          shadcn.Button.primary(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
      ],
    ),
  );
  return result ?? false;
}

class _NoticeTile extends ConsumerWidget {
  final NoticeHistory notice;

  const _NoticeTile({required this.notice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    final unread = !notice.isRead;
    final title = _cleanTitle(notice.title);
    final summary = _summary(notice.content);
    final time = _displayTime(notice);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => NoticeDetailPage(notice: notice),
          ),
        ),
        child: AppSurfaceContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          borderRadius: BorderRadius.circular(8),
          color: appSurfaceColor(context, cs.card),
          borderColor: cs.border.withValues(alpha: 0.6),
          child: Row(
            children: [
              SizedBox(
                width: 8,
                height: 8,
                child: unread
                    ? const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.small.copyWith(
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.xSmall.copyWith(color: cs.mutedForeground),
                      ),
                    ],
                  ],
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text(
                  time,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  style: typo.xSmall.copyWith(color: cs.mutedForeground),
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                shadcn.LucideIcons.chevronRight,
                size: 14,
                color: cs.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoticeDetailPage extends ConsumerWidget {
  final NoticeHistory notice;

  const NoticeDetailPage({super.key, required this.notice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final current = _latestNotice(
      ref.watch(noticeHistoryProvider).valueOrNull,
      notice,
    );
    final title = _cleanTitle(current.title);
    final time = _displayTime(current);
    final hasUrl = current.url != null && current.url!.trim().isNotEmpty;

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              _NoticePageHeader(
                title: '通知详情',
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    Text(
                      title,
                      style: shadcn.Theme.of(
                        context,
                      ).typography.xLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: time.isEmpty
                              ? const SizedBox.shrink()
                              : Text(
                                  time,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: shadcn.Theme.of(context)
                                      .typography
                                      .xSmall
                                      .copyWith(color: cs.mutedForeground),
                                ),
                        ),
                        _NoticeToolbarAction(
                          tooltip: '删除通知',
                          icon: shadcn.LucideIcons.trash2,
                          color: cs.destructive,
                          onPress: () async {
                            final confirmed = await _confirmNoticeAction(
                              context,
                              title: '删除通知',
                              message: '确定要删除这条通知吗？此操作不可撤销。',
                              confirmText: '删除通知',
                              destructive: true,
                            );
                            if (!confirmed) return;
                            if (!context.mounted) return;
                            try {
                              await ref
                                  .read(noticeHistoryProvider.notifier)
                                  .deleteNotice(current);
                              Toast.success('通知已删除');
                              if (context.mounted) Navigator.of(context).pop();
                            } catch (_) {
                              Toast.error('删除失败');
                            }
                          },
                        ),
                        if (!current.isRead) ...[
                          const SizedBox(width: 4),
                          _NoticeToolbarAction(
                            tooltip: '标记已读',
                            icon: shadcn.LucideIcons.check,
                            color: cs.foreground,
                            onPress: () async {
                              try {
                                await ref
                                    .read(noticeHistoryProvider.notifier)
                                    .markRead(current);
                              } catch (_) {
                                Toast.error('标记已读失败');
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    MarkdownBody(
                      data: current.content.trim().isEmpty
                          ? '暂无内容'
                          : current.content.trim(),
                      selectable: true,
                      fitContent: false,
                      softLineBreak: true,
                      extensionSet: null,
                      styleSheet: _markdownStyleSheet(context),
                      onTapLink: (text, href, title) {
                        final url = href?.trim();
                        if (url == null || url.isEmpty) return;
                        BrowserPage.open(
                          context,
                          url: url,
                          title: text.trim().isEmpty ? null : text.trim(),
                        );
                      },
                    ),
                    if (hasUrl) ...[
                      const SizedBox(height: 20),
                      shadcn.Button.outline(
                        onPressed: () => BrowserPage.open(
                          context,
                          url: current.url!.trim(),
                          title: title,
                        ),
                        child: const Text('打开链接'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

NoticeHistory _latestNotice(
  List<NoticeHistory>? notices,
  NoticeHistory fallback,
) {
  if (notices == null) return fallback;
  for (final notice in notices) {
    if (notice.id == fallback.id) return notice;
  }
  return fallback;
}

String _displayTime(NoticeHistory notice) {
  final raw = notice.createdAt ?? notice.updatedAt;
  if (raw == null || raw.isEmpty || raw.startsWith('0001')) return '';
  final date = DateTime.tryParse(raw);
  if (date == null) return raw.trim();

  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

MarkdownStyleSheet _markdownStyleSheet(BuildContext context) {
  final cs = shadcn.Theme.of(context).colorScheme;
  final typo = shadcn.Theme.of(context).typography;
  final body = typo.small.copyWith(color: cs.foreground, height: 1.55);

  return MarkdownStyleSheet(
    a: body.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
    p: body,
    pPadding: const EdgeInsets.only(bottom: 10),
    h1: typo.xLarge.copyWith(
      color: cs.foreground,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    h1Padding: const EdgeInsets.only(bottom: 10),
    h2: typo.large.copyWith(
      color: cs.foreground,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    h2Padding: const EdgeInsets.only(bottom: 8),
    h3: typo.base.copyWith(
      color: cs.foreground,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    h3Padding: const EdgeInsets.only(bottom: 8),
    h4: body.copyWith(fontWeight: FontWeight.w700),
    h5: body.copyWith(fontWeight: FontWeight.w700),
    h6: body.copyWith(fontWeight: FontWeight.w700),
    strong: const TextStyle(fontWeight: FontWeight.w700),
    em: const TextStyle(fontStyle: FontStyle.italic),
    del: const TextStyle(decoration: TextDecoration.lineThrough),
    blockSpacing: 8,
    listIndent: 24,
    listBullet: body.copyWith(color: cs.mutedForeground),
    code: typo.xSmall.copyWith(
      color: cs.foreground,
      fontFamily: 'monospace',
      backgroundColor: cs.muted.withValues(alpha: 0.28),
    ),
    codeblockPadding: const EdgeInsets.all(12),
    codeblockDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.28),
      border: Border.all(color: cs.border.withValues(alpha: 0.6), width: 0.7),
      borderRadius: BorderRadius.circular(6),
    ),
    blockquote: body.copyWith(color: cs.mutedForeground),
    blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    blockquoteDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.18),
      border: Border(
        left: BorderSide(color: cs.primary.withValues(alpha: 0.55), width: 3),
      ),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: cs.border, width: 1)),
    ),
    tableBorder: TableBorder.all(color: cs.border, width: 0.7),
    tableHead: body.copyWith(fontWeight: FontWeight.w700),
    tableBody: body,
    tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  );
}

String _cleanTitle(String title) {
  final cleaned = _stripInlineMarkdown(title.trim()).trim();
  return cleaned.isEmpty ? '未命名通知' : cleaned;
}

String _summary(String content) {
  final trimmed = content.trim();
  if (trimmed.isEmpty) return '';

  final withoutCode = trimmed.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
  final withoutMarkdown = _stripInlineMarkdown(withoutCode)
      .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
      .replaceAll(RegExp(r'^>\s?', multiLine: true), '')
      .replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '')
      .replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return withoutMarkdown;
}

String _stripInlineMarkdown(String value) {
  return value
      .replaceAllMapped(
        RegExp(r'!\[([^\]]*)\]\([^\)]*\)'),
        (match) => match.group(1) ?? '',
      )
      .replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\([^\)]*\)'),
        (match) => match.group(1) ?? '',
      )
      .replaceAllMapped(RegExp(r'`([^`]*)`'), (match) => match.group(1) ?? '')
      .replaceAllMapped(
        RegExp(r'(\*\*|__)(.*?)(\*\*|__)'),
        (match) => match.group(2) ?? '',
      )
      .replaceAllMapped(
        RegExp(r'(\*|_)(.*?)(\*|_)'),
        (match) => match.group(2) ?? '',
      )
      .replaceAllMapped(RegExp(r'~~(.*?)~~'), (match) => match.group(1) ?? '')
      .trim();
}

class _EmptyNoticeView extends StatelessWidget {
  const _EmptyNoticeView();

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.28),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                shadcn.LucideIcons.inbox,
                size: 44,
                color: cs.mutedForeground.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 14),
              Text(
                '暂无通知',
                style: shadcn.Theme.of(
                  context,
                ).typography.small.copyWith(color: cs.mutedForeground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoticeErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _NoticeErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            shadcn.LucideIcons.triangleAlert,
            size: 44,
            color: cs.destructive,
          ),
          const SizedBox(height: 16),
          Text('通知加载失败', style: shadcn.Theme.of(context).typography.large),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '$error',
              textAlign: TextAlign.center,
              style: shadcn.Theme.of(
                context,
              ).typography.small.copyWith(color: cs.mutedForeground),
            ),
          ),
          const SizedBox(height: 22),
          shadcn.Button.primary(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
