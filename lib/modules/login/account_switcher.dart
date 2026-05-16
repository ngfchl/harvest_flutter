import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../auth/auth_provider.dart';
import 'login_history_provider.dart';
import 'login_record.dart';

class AccountSwitcher extends ConsumerStatefulWidget {
  const AccountSwitcher({super.key});

  @override
  ConsumerState<AccountSwitcher> createState() => _AccountSwitcherState();
}

class _AccountSwitcherState extends ConsumerState<AccountSwitcher> {
  LoginRecord? _loggingIn;

  Future<void> _login(LoginRecord record) async {
    if (_loggingIn != null) return;

    setState(() => _loggingIn = record);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .login(record.server, record.username, record.password);
    } catch (error, trace) {
      AppLogger.error(error);
      AppLogger.error(trace);
      if (mounted) Toast.error('登录失败');
    } finally {
      if (mounted) setState(() => _loggingIn = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(loginHistoryProvider);
    final groups = _groupByServer(history);

    return EscapeBackScope(
      onBack: () => context.go('/login'),
      child: Builder(
        builder: (context) {
          final tokens = _AccountSwitcherThemeTokens.of(context);
          final cs = tokens.cs;
          return ColoredBox(
            key: const ValueKey('account-switcher-surface'),
            color: cs.background,
            child: Column(
              children: [
                _HistoryHeader(onBack: () => context.go('/login')),
                Expanded(
                  child: history.isEmpty
                      ? const _EmptyHistory()
                      : Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: tokens.contentWidth,
                            ),
                            child: ListView.separated(
                              padding: tokens.edgeFromLTRB(16, 16, 16, 24),
                              itemCount: groups.length + 1,
                              separatorBuilder: (_, __) => tokens.vGap(12),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _HistoryOverview(
                                    serverCount: groups.length,
                                    accountCount: history.length,
                                  );
                                }
                                final entry = groups.entries.elementAt(
                                  index - 1,
                                );
                                return _ServerGroup(
                                  server: entry.key,
                                  records: entry.value,
                                  loggingIn: _loggingIn,
                                  onLogin: _login,
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, List<LoginRecord>> _groupByServer(List<LoginRecord> history) {
    final groups = <String, List<LoginRecord>>{};
    for (final record in history) {
      groups.putIfAbsent(record.server, () => []).add(record);
    }
    return groups;
  }
}

class _HistoryHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _HistoryHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final tokens = _AccountSwitcherThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(
          bottom: BorderSide(color: cs.border, width: tokens.hairline),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: tokens.headerHeight,
          child: Padding(
            padding: appHeaderPadding(context, top: 0, bottom: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                shadcn.IconButton.ghost(
                  onPressed: onBack,
                  icon: Icon(shadcn.LucideIcons.arrowLeft, size: tokens.iconLg),
                ),
                tokens.hGap(6),
                Expanded(
                  child: Text(
                    '登录历史',
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
          ),
        ),
      ),
    );
  }
}

class _HistoryOverview extends StatelessWidget {
  final int serverCount;
  final int accountCount;

  const _HistoryOverview({
    required this.serverCount,
    required this.accountCount,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = _AccountSwitcherThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;

    return shadcn.Card(
      padding: tokens.edgeAll(14),
      child: Row(
        children: [
          shadcn.SecondaryBadge(
            leading: Icon(shadcn.LucideIcons.users, size: tokens.iconSm),
            child: Text('$accountCount'),
          ),
          tokens.hGap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择一个账号登录',
                  style: theme.typography.small.copyWith(
                    color: cs.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                tokens.vGap(2),
                Text(
                  '$serverCount 台服务器，$accountCount 个账号',
                  style: theme.typography.xSmall.copyWith(
                    color: cs.mutedForeground,
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

class _ServerGroup extends ConsumerWidget {
  final String server;
  final List<LoginRecord> records;
  final LoginRecord? loggingIn;
  final ValueChanged<LoginRecord> onLogin;

  const _ServerGroup({
    required this.server,
    required this.records,
    required this.loggingIn,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = _AccountSwitcherThemeTokens.of(context);
    final cs = tokens.cs;

    return shadcn.Card(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildServerHeader(context),
          Divider(
            height: tokens.hairline,
            thickness: tokens.hairline,
            color: cs.border,
          ),
          _buildAccountSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildServerHeader(BuildContext context) {
    final tokens = _AccountSwitcherThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;

    return Padding(
      padding: tokens.edgeFromLTRB(14, 12, 14, 10),
      child: Row(
        children: [
          Icon(
            shadcn.LucideIcons.server,
            size: tokens.iconMd,
            color: cs.mutedForeground,
          ),
          tokens.hGap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _serverTitle(server),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.small.copyWith(
                    color: cs.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                tokens.vGap(2),
                Text(
                  server,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    color: cs.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          tokens.hGap(10),
          shadcn.OutlineBadge(child: Text('${records.length} 个账号')),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    final tokens = _AccountSwitcherThemeTokens.of(context);
    final cs = tokens.cs;

    return Padding(
      padding: tokens.edgeFromLTRB(6, 6, 6, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < records.length; i++) ...[
            _buildRecordTile(context, ref, records[i]),
            if (i != records.length - 1)
              Padding(
                padding: tokens.edgeSymmetric(horizontal: 8),
                child: Divider(
                  height: tokens.size(6),
                  thickness: tokens.hairline,
                  color: cs.border,
                ),
              ),
          ],
        ],
      ),
    );
  }

  bool _sameRecord(LoginRecord? a, LoginRecord b) {
    return a?.server == b.server && a?.username == b.username;
  }

  Widget _buildRecordTile(
    BuildContext context,
    WidgetRef ref,
    LoginRecord record,
  ) {
    final tokens = _AccountSwitcherThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final busy = loggingIn != null;
    final recordLoggingIn = _sameRecord(loggingIn, record);
    final enabled = !busy;

    return Opacity(
      opacity: enabled ? 1 : 0.58,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: shadcn.Button.ghost(
              onPressed: enabled ? () => onLogin(record) : null,
              alignment: Alignment.centerLeft,
              leading: Icon(
                recordLoggingIn
                    ? shadcn.LucideIcons.loaderCircle
                    : shadcn.LucideIcons.user,
                size: tokens.iconMd,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    tokens.vGap(4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: shadcn.OutlineBadge(
                        leading: Icon(
                          shadcn.LucideIcons.clock,
                          size: tokens.iconSm,
                        ),
                        child: Text('最后登录时间 ${_formatTime(record.timestamp)}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          tokens.hGap(6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              shadcn.IconButton.ghost(
                onPressed: enabled ? () => onLogin(record) : null,
                icon: shadcn.Tooltip(
                  tooltip: (_) => const Text('登录'),
                  child: recordLoggingIn
                      ? SizedBox(
                          width: tokens.iconSm,
                          height: tokens.iconSm,
                          child: shadcn.CircularProgressIndicator(
                            strokeWidth: tokens.size(2),
                            color: cs.primary,
                          ),
                        )
                      : Icon(
                          shadcn.LucideIcons.logIn,
                          size: tokens.iconSm,
                          color: cs.mutedForeground,
                        ),
                ),
              ),
              shadcn.IconButton.ghost(
                onPressed: busy
                    ? null
                    : () => ref
                          .read(loginHistoryProvider.notifier)
                          .remove(record),
                icon: shadcn.Tooltip(
                  tooltip: (_) => const Text('删除记录'),
                  child: Icon(
                    shadcn.LucideIcons.trash2,
                    size: tokens.iconSm,
                    color: cs.destructive,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatDateTimeMinute(time);
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final tokens = _AccountSwitcherThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            shadcn.LucideIcons.history,
            size: tokens.emptyIconSize,
            color: cs.mutedForeground,
          ),
          tokens.vGap(10),
          Text(
            '暂无登录历史',
            style: theme.typography.small.copyWith(color: cs.mutedForeground),
          ),
          tokens.vGap(14),
          shadcn.Button.outline(
            onPressed: () => context.go('/login'),
            child: const Text('返回登录'),
          ),
        ],
      ),
    );
  }
}

String _serverTitle(String server) {
  final uri = Uri.tryParse(server);
  if (uri == null || uri.host.isEmpty) return server;
  return uri.host;
}

class _AccountSwitcherThemeTokens {
  final shadcn.ThemeData theme;
  final shadcn.ColorScheme cs;
  final double densityScale;
  final double textScale;

  _AccountSwitcherThemeTokens._({
    required this.theme,
    required this.cs,
    required this.densityScale,
    required this.textScale,
  });

  factory _AccountSwitcherThemeTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final densityScale =
        ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(
          0.55,
          1.45,
        );
    final textScale = theme.scaling.clamp(0.86, 1.30);
    return _AccountSwitcherThemeTokens._(
      theme: theme,
      cs: cs,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  double get hairline => size(0.5).clamp(0.5, 1.0);

  double get contentWidth => size(560);

  double get iconSm => font(14);

  double get iconMd => font(16);

  double get headerHeight => size(52);

  double get iconLg => font(20);

  double get emptyIconSize => size(32);

  EdgeInsets edgeAll(num value) => EdgeInsets.all(size(value));

  EdgeInsets edgeSymmetric({num horizontal = 0, num vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: size(horizontal),
        vertical: size(vertical),
      );

  EdgeInsets edgeFromLTRB(num left, num top, num right, num bottom) =>
      EdgeInsets.fromLTRB(size(left), size(top), size(right), size(bottom));

  SizedBox hGap(num value) => SizedBox(width: size(value));

  SizedBox vGap(num value) => SizedBox(height: size(value));
}
