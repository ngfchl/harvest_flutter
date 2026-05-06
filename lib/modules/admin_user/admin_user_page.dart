import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/escape_back_scope.dart';

import 'model/admin_user_model.dart';
import 'provider/admin_user_provider.dart';

class AdminUserPage extends ConsumerStatefulWidget {
  const AdminUserPage({super.key});

  @override
  ConsumerState<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends ConsumerState<AdminUserPage> {
  static const int _defaultPay = 168;
  static const int _defaultExpire = 366 * 100;
  static const List<double> _discounts = [
    5,
    5.5,
    6,
    6.5,
    7,
    7.5,
    8,
    8.5,
    9,
    9.5,
  ];

  final _searchCtrl = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUserListProvider);

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: FScaffold(
        childPad: false,
        header: FHeader.nested(
          title: const Text('授权管理'),
          prefixes: [
            FHeaderAction(
              icon: const Icon(FIcons.chevronLeft),
              onPress: () => Navigator.of(context).pop(),
            ),
          ],
          suffixes: [
            FHeaderAction(
              icon: const Icon(FIcons.refreshCw),
              onPress: () => ref.read(adminUserListProvider.notifier).refresh(),
            ),
          ],
        ),
        child: EasyRefresh(
          onRefresh: () => ref.read(adminUserListProvider.notifier).refresh(),
          header: appRefreshHeader(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              usersAsync.when(
                loading: () => const _AdminLoadingBlock(label: '授权用户加载中...'),
                error: (error, _) => _AdminErrorBlock(
                  title: '授权用户加载失败',
                  error: error,
                  onRetry: () =>
                      ref.read(adminUserListProvider.notifier).refresh(),
                ),
                data: _buildContent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<AdminUser> users) {
    final sorted = [...users]
      ..sort(
        (a, b) => parseDateTimeOrEpoch(
          b.updatedAt,
        ).compareTo(parseDateTimeOrEpoch(a.updatedAt)),
      );
    final keyword = _keyword.trim().toLowerCase();
    final filtered = keyword.isEmpty
        ? sorted
        : sorted.where((user) {
            final timeExpire = user.timeExpire.toLowerCase();
            return user.email.toLowerCase().contains(keyword) ||
                (user.username ?? '').toLowerCase().contains(keyword) ||
                timeExpire.contains(keyword) ||
                _displayDate(user.timeExpire).toLowerCase().contains(keyword);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AdminUserAnalytics(users: users),
        const SizedBox(height: 12),
        _AdminUserToolbar(
          controller: _searchCtrl,
          total: users.length,
          current: filtered.length,
          onSearch: (value) => setState(() => _keyword = value),
          onClear: () {
            _searchCtrl.clear();
            setState(() => _keyword = '');
          },
          onAdd: _openCreateDialog,
          onResetAllInvite: _openResetAllInviteDialog,
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          _AdminEmptyBlock(text: keyword.isEmpty ? '暂无授权用户' : '没有匹配的授权用户')
        else
          _AdminUserList(
            users: filtered,
            onRenew: _openRenewDialog,
            onSendEmail: _sendTokenEmail,
            onDelete: _confirmDelete,
          ),
      ],
    );
  }

  void _openCreateDialog() {
    final emailCtrl = TextEditingController();
    var saving = false;

    showFDialog(
      context: context,
      builder: (ctx, style, animation) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> save() async {
            final email = emailCtrl.text.trim();
            if (email.isEmpty) {
              Toast.warning('邮箱不能为空');
              return;
            }
            setDialogState(() => saving = true);
            try {
              await ref.read(adminUserListProvider.notifier).createUser(email);
              if (ctx.mounted) Navigator.of(ctx).pop();
              Toast.success('授权用户已添加');
            } catch (_) {
              if (ctx.mounted) setDialogState(() => saving = false);
            }
          }

          return FDialog(
            style: style
                .copyWith(
                  verticalStyle: (s) => s.copyWith(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  ),
                )
                .call,
            title: const Text('添加授权用户'),
            body: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FTextField(
                    controller: emailCtrl,
                    label: const Text('邮箱'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          style: FButtonStyle.outline(),
                          onPress: saving
                              ? null
                              : () => Navigator.of(ctx).pop(),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FButton(
                          onPress: saving ? null : save,
                          child: saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: FProgress.circularIcon(),
                                )
                              : const Text('添加'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: const [],
          );
        },
      ),
    );
  }

  void _openRenewDialog(AdminUser user) {
    final payCtrl = TextEditingController(
      text: (user.pay == 0 ? _defaultPay : user.pay).toString(),
    );
    final expireCtrl = TextEditingController(
      text: (user.expire == 0 ? _defaultExpire : user.expire).toString(),
    );
    var saving = false;
    var tryUser = false;

    showFDialog(
      context: context,
      builder: (ctx, style, animation) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          void applyDiscount(double discount) {
            payCtrl.text = (_defaultPay * discount / 10).round().toString();
            setDialogState(() {});
          }

          Future<void> save() async {
            final pay = int.tryParse(payCtrl.text.trim());
            final expire = int.tryParse(expireCtrl.text.trim());
            if (pay == null || pay <= 0) {
              Toast.warning('付费金额无效');
              return;
            }
            if (expire == null || expire <= 0) {
              Toast.warning('授权天数无效');
              return;
            }
            setDialogState(() => saving = true);
            try {
              await ref
                  .read(adminUserListProvider.notifier)
                  .resetToken(
                    user.id,
                    AdminUserResetTokenPayload(
                      expire: expire,
                      pay: pay,
                      tryUser: tryUser,
                    ),
                  );
              if (ctx.mounted) Navigator.of(ctx).pop();
              Toast.success('授权已重置');
            } catch (_) {
              if (ctx.mounted) setDialogState(() => saving = false);
            }
          }

          return FDialog(
            style: style
                .copyWith(
                  verticalStyle: (s) => s.copyWith(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  ),
                )
                .call,
            title: const Text('重新授权'),
            body: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReadOnlyField(label: '邮箱', value: user.email),
                  const SizedBox(height: 10),
                  FTextField(controller: payCtrl, label: const Text('付费金额')),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runAlignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      runSpacing: 6,
                      children: _discounts
                          .map(
                            (discount) => _DiscountButton(
                              label: _discountLabel(discount),
                              onPress: saving
                                  ? null
                                  : () => applyDiscount(discount),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FTextField(controller: expireCtrl, label: const Text('授权天数')),
                  const SizedBox(height: 10),
                  FTileGroup(
                    style: fTileGroupStyle(ctx).call,
                    children: [
                      FTile(
                        title: const Text('试用授权'),
                        suffix: FSwitch(
                          value: tryUser,
                          onChange: (value) {
                            if (!saving) setDialogState(() => tryUser = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          style: FButtonStyle.outline(),
                          onPress: saving
                              ? null
                              : () => Navigator.of(ctx).pop(),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FButton(
                          onPress: saving ? null : save,
                          child: saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: FProgress.circularIcon(),
                                )
                              : const Text('重新授权'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: const [],
          );
        },
      ),
    );
  }

  void _openResetAllInviteDialog() {
    final countCtrl = TextEditingController(text: '3');
    var saving = false;

    showFDialog(
      context: context,
      builder: (ctx, style, animation) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> save() async {
            final count = int.tryParse(countCtrl.text.trim());
            if (count == null || count < 0) {
              Toast.warning('邀请数无效');
              return;
            }
            setDialogState(() => saving = true);
            try {
              await ref.read(adminUserListProvider.notifier).resetInvite(count);
              if (ctx.mounted) Navigator.of(ctx).pop();
              Toast.success('全部用户邀请数已重置');
            } catch (_) {
              if (ctx.mounted) setDialogState(() => saving = false);
            }
          }

          return FDialog(
            style: style
                .copyWith(
                  verticalStyle: (s) => s.copyWith(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  ),
                )
                .call,
            title: const Text('重置全部邀请'),
            body: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FTextField(
                    controller: countCtrl,
                    label: const Text('邀请数'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          style: FButtonStyle.outline(),
                          onPress: saving
                              ? null
                              : () => Navigator.of(ctx).pop(),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FButton(
                          onPress: saving ? null : save,
                          child: saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: FProgress.circularIcon(),
                                )
                              : const Text('重置'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: const [],
          );
        },
      ),
    );
  }

  Future<void> _sendTokenEmail(AdminUser user) async {
    try {
      Toast.info('正在发送授权邮件...');
      await ref.read(adminUserListProvider.notifier).sendTokenEmail(user.id);
      Toast.success('授权邮件已发送');
    } catch (_) {
      Toast.error('授权邮件发送失败');
    }
  }

  void _confirmDelete(AdminUser user) {
    var saving = false;
    showFDialog(
      context: context,
      builder: (ctx, style, animation) => StatefulBuilder(
        builder: (ctx, setDialogState) => FDialog(
          style: style
              .copyWith(
                verticalStyle: (s) => s.copyWith(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                ),
              )
              .call,
          title: const Text('删除授权用户'),
          body: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '确定删除 ${user.email}？',
                  style: ctx.theme.typography.sm.copyWith(
                    color: ctx.theme.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FButton(
                        style: FButtonStyle.outline(),
                        onPress: saving ? null : () => Navigator.of(ctx).pop(),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FButton(
                        style: FButtonStyle.destructive(),
                        onPress: saving
                            ? null
                            : () async {
                                setDialogState(() => saving = true);
                                try {
                                  await ref
                                      .read(adminUserListProvider.notifier)
                                      .deleteUser(user.id);
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                  Toast.success('授权用户已删除');
                                } catch (_) {
                                  if (ctx.mounted)
                                    setDialogState(() => saving = false);
                                }
                              },
                        child: saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: FProgress.circularIcon(),
                              )
                            : const Text('删除'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: const [],
        ),
      ),
    );
  }

  String _discountLabel(double value) =>
      value % 1 == 0 ? '${value.toInt()}折' : '$value折';
}

class _AdminUserAnalytics extends StatelessWidget {
  final List<AdminUser> users;

  const _AdminUserAnalytics({required this.users});

  @override
  Widget build(BuildContext context) {
    final expired = users.where(_isExpired).length;
    final active = users.length - expired;
    final validTryUsers = users
        .where((user) => user.tryUser && !_isExpired(user))
        .length;
    final recent = users
        .where(
          (user) =>
              DateTime.now()
                  .difference(parseDateTimeOrEpoch(user.updatedAt))
                  .inDays <=
              7,
        )
        .length;
    final isMobile = context.isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _StatCard(
                label: '授权用户',
                value: users.length.toString(),
                icon: FIcons.shieldCheck,
                color: const Color(0xFF2563EB),
              ),
              _StatCard(
                label: '试用有效',
                value: validTryUsers.toString(),
                icon: FIcons.userCheck,
                color: const Color(0xFF7C3AED),
              ),
              _StatCard(
                label: '有效授权',
                value: active.toString(),
                icon: FIcons.calendarCheck,
                color: const Color(0xFF059669),
              ),
              _StatCard(
                label: '已过期',
                value: expired.toString(),
                icon: FIcons.calendarOff,
                color: const Color(0xFFDC2626),
              ),
            ];
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cards.map((card) {
                final width = isMobile
                    ? (constraints.maxWidth - 8) / 2
                    : (constraints.maxWidth - 24) / 4;
                return SizedBox(width: width, height: 76, child: card);
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 10),
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BarChartBlock(
                title: '授权状态',
                items: [
                  _ChartItem('有效', active, const Color(0xFF059669)),
                  _ChartItem('过期', expired, const Color(0xFFDC2626)),
                ],
              ),
              const SizedBox(height: 8),
              _BarChartBlock(
                title: '更新活跃',
                items: [
                  _ChartItem('7日内', recent, const Color(0xFF2563EB)),
                  _ChartItem(
                    '更早',
                    users.length - recent,
                    const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _BarChartBlock(
                  title: '授权状态',
                  items: [
                    _ChartItem('有效', active, const Color(0xFF059669)),
                    _ChartItem('过期', expired, const Color(0xFFDC2626)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BarChartBlock(
                  title: '更新活跃',
                  items: [
                    _ChartItem('7日内', recent, const Color(0xFF2563EB)),
                    _ChartItem(
                      '更早',
                      users.length - recent,
                      const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _AdminUserToolbar extends StatelessWidget {
  final TextEditingController controller;
  final int total;
  final int current;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final VoidCallback onAdd;
  final VoidCallback onResetAllInvite;

  const _AdminUserToolbar({
    required this.controller,
    required this.total,
    required this.current,
    required this.onSearch,
    required this.onClear,
    required this.onAdd,
    required this.onResetAllInvite,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final typo = context.theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '授权用户',
                style: typo.lg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.foreground,
                ),
              ),
            ),
            Text(
              '$current / $total',
              style: typo.sm.copyWith(color: cs.mutedForeground),
            ),
            const SizedBox(width: 8),
            FButton.icon(
              onPress: onResetAllInvite,
              child: const Icon(FIcons.rotateCcw, size: 18),
            ),
            const SizedBox(width: 6),
            FButton.icon(
              onPress: onAdd,
              child: const Icon(FIcons.userPlus, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FTextField(
          controller: controller,
          hint: '搜索邮箱、用户名或授权状态',
          onChange: onSearch,
          prefixBuilder: (ctx, styles, child) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(FIcons.search, size: 14, color: cs.mutedForeground),
          ),
          suffixBuilder: controller.text.isEmpty
              ? null
              : (ctx, styles, child) => GestureDetector(
                  onTap: onClear,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(FIcons.x, size: 14, color: cs.mutedForeground),
                  ),
                ),
        ),
      ],
    );
  }
}

class _AdminUserList extends StatelessWidget {
  final List<AdminUser> users;
  final ValueChanged<AdminUser> onRenew;
  final ValueChanged<AdminUser> onSendEmail;
  final ValueChanged<AdminUser> onDelete;

  const _AdminUserList({
    required this.users,
    required this.onRenew,
    required this.onSendEmail,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final columns = constraints.maxWidth < kMobileBreakpoint
            ? 1
            : _adaptiveColumns(
                constraints.maxWidth,
                minWidth: 300,
                maxColumns: 6,
              );
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 0,
          children: users
              .map(
                (user) => SizedBox(
                  width: width,
                  child: _AdminUserTile(
                    user: user,
                    onRenew: () => onRenew(user),
                    onSendEmail: () => onSendEmail(user),
                    onDelete: () => onDelete(user),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

int _adaptiveColumns(
  double width, {
  required double minWidth,
  required int maxColumns,
}) {
  final columns = (width / minWidth).floor();
  if (columns < 2) return 2;
  if (columns > maxColumns) return maxColumns;
  return columns;
}

class _AdminUserTile extends StatefulWidget with FTileMixin {
  final AdminUser user;
  final VoidCallback onRenew;
  final VoidCallback onSendEmail;
  final VoidCallback onDelete;

  const _AdminUserTile({
    required this.user,
    required this.onRenew,
    required this.onSendEmail,
    required this.onDelete,
  });

  @override
  State<_AdminUserTile> createState() => _AdminUserTileState();
}

class _AdminUserTileState extends State<_AdminUserTile>
    with SingleTickerProviderStateMixin {
  late final FPopoverController _popoverCtrl;

  @override
  void initState() {
    super.initState();
    _popoverCtrl = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    _popoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final expired = _isExpired(widget.user);
    return FPopoverMenu.tiles(
      popoverController: _popoverCtrl,
      style: fPopoverMenuStyle(context).call,
      spacing: FPortalSpacing.zero,
      menu: [
        FTileGroup(
          children: [
            FTile(
              prefix: const Icon(FIcons.refreshCw, size: 14),
              title: const Text('重新授权'),
              onPress: () => _run(widget.onRenew),
            ),
            FTile(
              prefix: const Icon(FIcons.send, size: 14),
              title: const Text('发送邮件'),
              onPress: () => _run(widget.onSendEmail),
            ),
            FTile(
              prefix: Icon(FIcons.trash2, size: 14, color: cs.destructive),
              title: const Text('删除'),
              onPress: () => _run(widget.onDelete),
            ),
          ],
        ),
      ],
      child: FTile(
        style: (style) => style.copyWith(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: FWidgetStateMap({
            WidgetState.hovered | WidgetState.pressed: BoxDecoration(
              color: cs.secondary.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.border, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                  spreadRadius: -3,
                ),
              ],
            ),
            WidgetState.any: BoxDecoration(
              color: cs.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: cs.border.withValues(alpha: 0.8),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                  spreadRadius: -4,
                ),
              ],
            ),
          }),
        ),
        prefix: _StatusDot(expired: expired),
        title: _AdminUserTitle(user: widget.user),
        subtitle: _AdminUserSubtitle(user: widget.user, expired: expired),
        onPress: () => _popoverCtrl.toggle(),
        onSecondaryPress: () => _popoverCtrl.toggle(),
      ),
    );
  }

  void _run(VoidCallback action) {
    _popoverCtrl.hide();
    action();
  }
}

class _AdminUserTitle extends StatelessWidget {
  final AdminUser user;

  const _AdminUserTitle({required this.user});

  @override
  Widget build(BuildContext context) {
    final title = user.email.isEmpty ? (user.username ?? '未命名授权') : user.email;
    return Row(
      children: [
        Expanded(
          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 10),
        _AdminInfoText(label: '邀请', value: user.invite.toString()),
      ],
    );
  }
}

class _AdminUserSubtitle extends StatelessWidget {
  final AdminUser user;
  final bool expired;

  const _AdminUserSubtitle({required this.user, required this.expired});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final tagWrap = Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (expired)
          const _AdminPill(text: '过期', destructive: true, dense: true)
        else ...[
          if (user.timeExpire.isNotEmpty)
            _AdminPill(text: _displayDate(user.timeExpire), dense: true),
          if (user.tryUser) const _AdminPill(text: '试用', dense: true),
        ],
      ],
    );
    final updateText = Text(
      '更新于${_displayTime(user.updatedAt)}',
      textAlign: TextAlign.right,
      style: context.theme.typography.xs.copyWith(
        color: cs.mutedForeground,
        fontSize: 9,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: tagWrap),
          const SizedBox(width: 12),
          updateText,
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool expired;

  const _StatusDot({required this.expired});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: expired ? cs.destructive : cs.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AdminInfoText extends StatelessWidget {
  final String label;
  final String value;

  const _AdminInfoText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: context.theme.typography.xs.copyWith(color: cs.mutedForeground),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: TextStyle(color: cs.foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final typo = context.theme.typography;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border.withValues(alpha: 0.8), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: typo.lg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.foreground,
                  ),
                ),
                Text(label, style: typo.xs.copyWith(color: cs.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartBlock extends StatelessWidget {
  final String title;
  final List<_ChartItem> items;

  const _BarChartBlock({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final typo = context.theme.typography;
    final maxValue = items.fold<int>(
      1,
      (max, item) => item.value > max ? item.value : max,
    );
    return Container(
      height: 108,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border.withValues(alpha: 0.8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: typo.sm.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.foreground,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((item) {
            final widthFactor = item.value / maxValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      item.label,
                      style: typo.xs.copyWith(color: cs.mutedForeground),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: widthFactor.clamp(0, 1).toDouble(),
                        minHeight: 8,
                        backgroundColor: cs.secondary,
                        valueColor: AlwaysStoppedAnimation(item.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text(
                      item.value.toString(),
                      textAlign: TextAlign.right,
                      style: typo.xs.copyWith(color: cs.foreground),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChartItem {
  final String label;
  final int value;
  final Color color;

  const _ChartItem(this.label, this.value, this.color);
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.secondary.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border.withValues(alpha: 0.7), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.theme.typography.xs.copyWith(
              color: cs.mutedForeground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '-' : value,
            style: context.theme.typography.sm.copyWith(color: cs.foreground),
          ),
        ],
      ),
    );
  }
}

class _DiscountButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPress;

  const _DiscountButton({required this.label, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 28,
      child: FButton(
        style: FButtonStyle.outline(
          (style) => style.copyWith(
            contentStyle: (content) => content.copyWith(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            ),
          ),
        ),
        onPress: onPress,
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(fontSize: 11, height: 1),
        ),
      ),
    );
  }
}

class _AdminPill extends StatelessWidget {
  final String text;
  final bool destructive;
  final bool dense;

  const _AdminPill({
    required this.text,
    this.destructive = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final color = destructive ? cs.destructive : cs.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 7,
        vertical: dense ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: dense ? 10 : 11,
          height: 1.2,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminLoadingBlock extends StatelessWidget {
  final String label;

  const _AdminLoadingBlock({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: cs.border.withValues(alpha: 0.5), width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FProgress.circularIcon(),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(color: cs.mutedForeground, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _AdminErrorBlock extends StatelessWidget {
  final String title;
  final Object error;
  final VoidCallback onRetry;

  const _AdminErrorBlock({
    required this.title,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    return FTileGroup(
      style: fTileGroupStyle(context).call,
      children: [
        FTile(
          prefix: Icon(FIcons.circleAlert, color: cs.destructive),
          title: Text(title),
          subtitle: Text('$error'),
          suffix: FButton(
            style: FButtonStyle.outline(),
            onPress: onRetry,
            child: const Text('重试'),
          ),
        ),
      ],
    );
  }
}

class _AdminEmptyBlock extends StatelessWidget {
  final String text;

  const _AdminEmptyBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    return Container(
      height: 104,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: cs.border.withValues(alpha: 0.5), width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: cs.mutedForeground, fontSize: 13),
      ),
    );
  }
}

String _displayTime(String raw) => raw.isEmpty ? '-' : formatRawDateTime(raw);

String _displayDate(String raw) => formatDateStringToDate(raw);

bool _isExpired(AdminUser user) {
  if (user.timeExpire.contains('已过期')) return true;
  final expireAt = parseDateTimeOrEpoch(user.timeExpire);
  if (expireAt.millisecondsSinceEpoch == 0) return false;
  return expireAt.isBefore(DateTime.now());
}
