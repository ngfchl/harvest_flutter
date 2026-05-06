import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/escape_back_scope.dart';

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
      await ref.read(authNotifierProvider.notifier).login(record.server, record.username, record.password);
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
      child: FScaffold(
        childPad: false,
        header: FHeader.nested(
          title: const Text('登录历史'),
          prefixes: [FHeaderAction.back(onPress: () => context.go('/login'))],
        ),
        child: history.isEmpty
            ? const _EmptyHistory()
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                    itemCount: groups.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _HistoryOverview(serverCount: groups.length, accountCount: history.length);
                      }
                      final entry = groups.entries.elementAt(index - 1);
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

class _HistoryOverview extends StatelessWidget {
  final int serverCount;
  final int accountCount;

  const _HistoryOverview({required this.serverCount, required this.accountCount});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(FIcons.users, size: 16, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择一个账号登录',
                  style: TextStyle(color: cs.foreground, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '$serverCount 台服务器 · $accountCount 个账号',
                  style: TextStyle(color: cs.foreground.withValues(alpha: 0.55), fontSize: 11),
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

  const _ServerGroup({required this.server, required this.records, required this.loggingIn, required this.onLogin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = FTheme.of(context).colors;

    return Container(
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18), width: 0.5),
        boxShadow: [
          BoxShadow(color: cs.foreground.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildServerHeader(cs), _buildAccountSection(context, ref, cs)],
        ),
      ),
    );
  }

  Widget _buildServerHeader(FColors cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.075),
        border: Border(bottom: BorderSide(color: cs.primary.withValues(alpha: 0.16), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: cs.primary.withValues(alpha: 0.18), width: 0.5),
            ),
            child: Icon(FIcons.server, size: 14, color: cs.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _serverTitle(server),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: cs.foreground, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _SectionBadge(label: '服务器', color: cs.primary),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        server,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: cs.foreground.withValues(alpha: 0.48), fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _CountPill(count: records.length, label: '账号'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref, FColors cs) {
    const accountColor = Color(0xFF14B8A6);

    return Container(
      width: double.infinity,
      color: accountColor.withValues(alpha: 0.035),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accountColor.withValues(alpha: 0.42), width: 1.5)),
            ),
            padding: const EdgeInsets.only(left: 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accountColor.withValues(alpha: 0.16), width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < records.length; i++) ...[
                      _buildRecordTile(context, ref, records[i]),
                      if (i != records.length - 1) Container(height: 0.5, color: accountColor.withValues(alpha: 0.12)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _sameRecord(LoginRecord? a, LoginRecord b) {
    return a?.server == b.server && a?.username == b.username;
  }

  Widget _buildRecordTile(BuildContext context, WidgetRef ref, LoginRecord record) {
    final cs = FTheme.of(context).colors;
    final busy = loggingIn != null;
    final recordLoggingIn = _sameRecord(loggingIn, record);
    final enabled = !busy;
    final iconColor = recordLoggingIn
        ? cs.primary
        : enabled
        ? const Color(0xFF14B8A6)
        : cs.mutedForeground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onLogin(record) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.58,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: recordLoggingIn
                      ? cs.primary.withValues(alpha: 0.12)
                      : const Color(0xFF14B8A6).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: recordLoggingIn
                        ? cs.primary.withValues(alpha: 0.18)
                        : const Color(0xFF14B8A6).withValues(alpha: 0.16),
                    width: 0.5,
                  ),
                ),
                child: Icon(FIcons.user, size: 13, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: cs.foreground, fontSize: 13, fontWeight: FontWeight.w600, height: 1.1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '上次登录 ${_formatTime(record.timestamp)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: cs.foreground.withValues(alpha: 0.46), fontSize: 10, height: 1.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 22,
                height: 22,
                child: Center(
                  child: recordLoggingIn
                      ? const SizedBox(width: 14, height: 14, child: FProgress.circularIcon())
                      : Icon(FIcons.logIn, size: 14, color: iconColor),
                ),
              ),
              FTooltip(
                tipBuilder: (_, __) => const Text('删除记录'),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: busy ? null : () => ref.read(loginHistoryProvider.notifier).remove(record),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(FIcons.trash2, size: 14, color: cs.destructive),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatDateTimeMinute(time);
  }
}

class _SectionBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, height: 1),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  final String label;

  const _CountPill({required this.count, this.label = '账号'});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cs.foreground.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.border.withValues(alpha: 0.75), width: 0.5),
      ),
      child: Text('$count 个$label', style: TextStyle(color: cs.foreground.withValues(alpha: 0.58), fontSize: 10)),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FIcons.history, size: 32, color: cs.mutedForeground),
          const SizedBox(height: 10),
          Text('暂无登录历史', style: TextStyle(color: cs.mutedForeground, fontSize: 14)),
          const SizedBox(height: 14),
          FButton(style: FButtonStyle.outline(), onPress: () => context.go('/login'), child: const Text('返回登录')),
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
