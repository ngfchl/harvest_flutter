import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'model/admin_user_model.dart';
import 'provider/admin_user_provider.dart';

shadcn.ColorScheme _adminColors(BuildContext context) => shadcn.Theme.of(context).colorScheme;

BorderRadius _adminRadius(BuildContext context, {String size = 'md'}) {
  final theme = shadcn.Theme.of(context);
  return switch (size) {
    'xs' => theme.borderRadiusXs,
    'sm' => theme.borderRadiusSm,
    'lg' => theme.borderRadiusLg,
    'xl' => theme.borderRadiusXl,
    _ => theme.borderRadiusMd,
  };
}

Color _adminTone(
  Color color, {
  double hueShift = 0,
  double saturationScale = 1,
  double lightnessDelta = 0,
  double alpha = 1,
}) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withHue((hsl.hue + hueShift) % 360)
      .withSaturation((hsl.saturation * saturationScale).clamp(0.14, 0.9))
      .withLightness((hsl.lightness + lightnessDelta).clamp(0.22, 0.78))
      .toColor()
      .withValues(alpha: alpha);
}

Color _adminInfo(BuildContext context, {double alpha = 1}) => _adminColors(context).primary.withValues(alpha: alpha);

Color _adminSuccess(BuildContext context, {double alpha = 1}) =>
    _adminTone(_adminColors(context).primary, hueShift: 86, saturationScale: 0.82, alpha: alpha);

Color _adminWarning(BuildContext context, {double alpha = 1}) =>
    _adminTone(_adminColors(context).primary, hueShift: 42, lightnessDelta: 0.04, alpha: alpha);

Color _adminDanger(BuildContext context, {double alpha = 1}) =>
    _adminColors(context).destructive.withValues(alpha: alpha);

Color _adminAccent(BuildContext context, int index, {double alpha = 1}) {
  final cs = _adminColors(context);
  final palette = <Color>[
    cs.primary,
    _adminTone(cs.primary, hueShift: -34, saturationScale: 0.9),
    _adminSuccess(context),
    _adminWarning(context),
    cs.destructive,
    Color.lerp(cs.primary, cs.destructive, 0.45) ?? cs.primary,
    _adminTone(cs.mutedForeground, saturationScale: 1.25),
  ];
  return palette[index % palette.length].withValues(alpha: alpha);
}

Color _adminShadow(BuildContext context, {double alpha = 0.08}) =>
    _adminColors(context).foreground.withValues(alpha: alpha);

class AdminUserPage extends ConsumerStatefulWidget {
  const AdminUserPage({super.key});

  @override
  ConsumerState<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends ConsumerState<AdminUserPage> {
  static const int _defaultPay = 168;
  static const int _defaultExpire = 366 * 100;
  static const List<double> _discounts = [5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5];

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
    final cs = _adminColors(context);
    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: Material(
        color: cs.background,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: _Header(
                onBack: () => Navigator.of(context).pop(),
                onRefresh: () => ref.read(adminUserListProvider.notifier).refresh(),
              ),
            ),
            Expanded(
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
                        onRetry: () => ref.read(adminUserListProvider.notifier).refresh(),
                      ),
                      data: _buildContent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<AdminUser> users) {
    final sorted = [...users]
      ..sort((a, b) => parseDateTimeOrEpoch(b.updatedAt).compareTo(parseDateTimeOrEpoch(a.updatedAt)));
    final keyword = _keyword.trim().toLowerCase();
    final filtered = keyword.isEmpty
        ? sorted
        : sorted.where((user) {
            return user.email.toLowerCase().contains(keyword) ||
                (user.username ?? '').toLowerCase().contains(keyword) ||
                user.timeExpire.toLowerCase().contains(keyword) ||
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
    shadcn.showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => shadcn.AlertDialog(
          title: const Text('添加授权用户'),
          content: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  shadcn.TextField(
                    controller: emailCtrl,
                    autofocus: true,
                    hintText: '邮箱',
                    onSubmitted: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  _DialogActions(
                    saving: saving,
                    cancelLabel: '取消',
                    submitLabel: '添加',
                    onCancel: () => Navigator.of(ctx).pop(),
                    onSubmit: () async {
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
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openRenewDialog(AdminUser user) {
    final payCtrl = TextEditingController(text: (user.pay == 0 ? _defaultPay : user.pay).toString());
    final expireCtrl = TextEditingController(text: (user.expire == 0 ? _defaultExpire : user.expire).toString());
    var saving = false;
    var tryUser = false;
    shadcn.showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
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
                  .resetToken(user.id, AdminUserResetTokenPayload(expire: expire, pay: pay, tryUser: tryUser));
              if (ctx.mounted) Navigator.of(ctx).pop();
              Toast.success('授权已重置');
            } catch (_) {
              if (ctx.mounted) setDialogState(() => saving = false);
            }
          }

          return shadcn.AlertDialog(
            title: const Text('重新授权'),
            content: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ReadOnlyField(label: '邮箱', value: user.email),
                    const SizedBox(height: 10),
                    shadcn.TextField(
                      controller: payCtrl,
                      hintText: '支付金额',
                      onSubmitted: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _discounts
                          .map(
                            (discount) => _DiscountButton(
                              label: _discountLabel(discount),
                              onPressed: saving
                                  ? null
                                  : () {
                                      payCtrl.text = (_defaultPay * discount / 10).round().toString();
                                      setDialogState(() {});
                                    },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    shadcn.TextField(
                      controller: expireCtrl,
                      hintText: '过期时间',
                      onSubmitted: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const SizedBox(height: 10),
                    _PanelTile(
                      title: const Text('试用授权'),
                      trailing: shadcn.Switch(
                        value: tryUser,
                        onChanged: saving ? null : (value) => setDialogState(() => tryUser = value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DialogActions(
                      saving: saving,
                      cancelLabel: '取消',
                      submitLabel: '重新授权',
                      onCancel: () => Navigator.of(ctx).pop(),
                      onSubmit: save,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openResetAllInviteDialog() {
    final countCtrl = TextEditingController(text: '3');
    var saving = false;
    shadcn.showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => shadcn.AlertDialog(
          title: const Text('重置全部邀请'),
          content: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  shadcn.TextField(
                    controller: countCtrl,
                    autofocus: true,
                    hintText: '邀请数量',
                    onSubmitted: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  _DialogActions(
                    saving: saving,
                    cancelLabel: '取消',
                    submitLabel: '重置',
                    onCancel: () => Navigator.of(ctx).pop(),
                    onSubmit: () async {
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
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
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
    shadcn.showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => shadcn.AlertDialog(
          title: const Text('删除授权用户'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('确定删除 ${user.email}？'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: shadcn.Button.outline(
                        onPressed: saving ? null : () => Navigator.of(ctx).pop(),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: shadcn.Button.destructive(
                        onPressed: saving
                            ? null
                            : () async {
                                setDialogState(() => saving = true);
                                try {
                                  await ref.read(adminUserListProvider.notifier).deleteUser(user.id);
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                  Toast.success('授权用户已删除');
                                } catch (_) {
                                  if (ctx.mounted) setDialogState(() => saving = false);
                                }
                              },
                        child: saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: shadcn.CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('删除'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _discountLabel(double value) => value % 1 == 0 ? '${value.toInt()}折' : '$value折';
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const _Header({required this.onBack, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          shadcn.IconButton.ghost(icon: const Icon(shadcn.LucideIcons.chevronLeft), onPressed: onBack),
          Expanded(
            child: Text(
              '授权管理',
              style: shadcn.Theme.of(
                context,
              ).typography.large.copyWith(fontWeight: FontWeight.w700, color: _adminColors(context).foreground),
            ),
          ),
          shadcn.IconButton.ghost(icon: const Icon(shadcn.LucideIcons.refreshCw), onPressed: onRefresh),
        ],
      ),
    );
  }
}

class _AdminUserAnalytics extends StatelessWidget {
  final List<AdminUser> users;

  const _AdminUserAnalytics({required this.users});

  @override
  Widget build(BuildContext context) {
    final expired = users.where(_isExpired).length;
    final active = users.length - expired;
    final validTryUsers = users.where((user) => user.tryUser && !_isExpired(user)).length;
    final recent = users
        .where((user) => DateTime.now().difference(parseDateTimeOrEpoch(user.updatedAt)).inDays <= 7)
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
                icon: shadcn.LucideIcons.shieldCheck,
                color: _adminInfo(context),
              ),
              _StatCard(
                label: '试用有效',
                value: validTryUsers.toString(),
                icon: shadcn.LucideIcons.userCheck,
                color: _adminAccent(context, 1),
              ),
              _StatCard(
                label: '有效授权',
                value: active.toString(),
                icon: shadcn.LucideIcons.calendarCheck,
                color: _adminSuccess(context),
              ),
              _StatCard(
                label: '已过期',
                value: expired.toString(),
                icon: shadcn.LucideIcons.calendarOff,
                color: _adminDanger(context),
              ),
            ];
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cards.map((card) {
                final width = isMobile ? (constraints.maxWidth - 8) / 2 : (constraints.maxWidth - 24) / 4;
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
              _DonutChartBlock(
                title: '授权状态',
                items: [
                  _ChartItem('有效', active, _adminSuccess(context)),
                  _ChartItem('过期', expired, _adminDanger(context)),
                ],
              ),
              const SizedBox(height: 8),
              _DonutChartBlock(
                title: '更新活跃',
                items: [
                  _ChartItem('7日内', recent, _adminInfo(context)),
                  _ChartItem(
                    '更早',
                    users.length - recent,
                    _adminColors(context).mutedForeground.withValues(alpha: 0.72),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _DonutChartBlock(
                  title: '授权状态',
                  items: [
                    _ChartItem('有效', active, _adminSuccess(context)),
                    _ChartItem('过期', expired, _adminDanger(context)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DonutChartBlock(
                  title: '更新活跃',
                  items: [
                    _ChartItem('7日内', recent, _adminInfo(context)),
                    _ChartItem(
                      '更早',
                      users.length - recent,
                      _adminColors(context).mutedForeground.withValues(alpha: 0.72),
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
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: shadcn.TextField(controller: controller, onChanged: onSearch, hintText: '搜索邮箱、用户名或授权状态'),
            ),
            if (controller.text.isNotEmpty) ...[
              const SizedBox(width: 6),
              shadcn.IconButton.ghost(onPressed: onClear, icon: const Icon(shadcn.LucideIcons.x, size: 14)),
            ],
            const SizedBox(width: 6),
            Text('$current / $total', style: typo.small.copyWith(color: cs.mutedForeground)),
            const SizedBox(width: 8),
            shadcn.IconButton.primary(
              onPressed: onResetAllInvite,
              icon: const Icon(shadcn.LucideIcons.rotateCcw, size: 18),
            ),
            const SizedBox(width: 6),
            shadcn.IconButton.primary(onPressed: onAdd, icon: const Icon(shadcn.LucideIcons.userPlus, size: 18)),
          ],
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

  const _AdminUserList({required this.users, required this.onRenew, required this.onSendEmail, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final columns = constraints.maxWidth < kMobileBreakpoint
            ? 1
            : _adaptiveColumns(constraints.maxWidth, minWidth: 300, maxColumns: 6);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 10,
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

int _adaptiveColumns(double width, {required double minWidth, required int maxColumns}) {
  final columns = (width / minWidth).floor();
  if (columns < 2) return 2;
  if (columns > maxColumns) return maxColumns;
  return columns;
}

class _AdminUserTile extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onRenew;
  final VoidCallback onSendEmail;
  final VoidCallback onDelete;

  const _AdminUserTile({required this.user, required this.onRenew, required this.onSendEmail, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = _adminColors(context);
    final expired = _isExpired(user);
    final tile = Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: _adminRadius(context),
        border: Border.all(color: cs.border.withValues(alpha: 0.8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: _adminShadow(context, alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          _StatusDot(expired: expired),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _AdminUserTitle(user: user),
                _AdminUserSubtitle(user: user, expired: expired),
              ],
            ),
          ),
        ],
      ),
    );

    return shadcn.ContextMenu(
      behavior: HitTestBehavior.opaque,
      items: _menuItems(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _showMenu(context, details.globalPosition),
        onLongPressStart: (details) => _showMenu(context, details.globalPosition),
        child: tile,
      ),
    );
  }

  List<shadcn.MenuItem> _menuItems(BuildContext context) {
    final cs = _adminColors(context);
    return [
      _menuItem(context: context, icon: shadcn.LucideIcons.refreshCw, title: '重新授权', onPressed: onRenew),
      _menuItem(context: context, icon: shadcn.LucideIcons.send, title: '发送邮件', onPressed: onSendEmail),
      const shadcn.MenuDivider(),
      _menuItem(
        context: context,
        icon: shadcn.LucideIcons.trash2,
        title: '删除',
        onPressed: onDelete,
        color: cs.destructive,
      ),
    ];
  }

  shadcn.MenuButton _menuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final style = color == null ? null : shadcn.Theme.of(context).typography.small.copyWith(color: color);
    return shadcn.MenuButton(
      leading: Icon(icon, size: 16, color: color),
      onPressed: (_) => onPressed(),
      child: Text(title, style: style),
    );
  }

  void _showMenu(BuildContext context, Offset position) {
    shadcn.showPopover<void>(
      context: context,
      position: position,
      alignment: Alignment.topLeft,
      offset: const Offset(0, 8),
      widthConstraint: shadcn.PopoverConstraint.intrinsic,
      heightConstraint: shadcn.PopoverConstraint.intrinsic,
      consumeOutsideTaps: false,
      builder: (_) => shadcn.DropdownMenu(children: _menuItems(context)),
    );
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
        Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
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
    final cs = _adminColors(context);
    final updateText = Text(
      '更新于${_displayTime(user.updatedAt)}',
      textAlign: TextAlign.right,
      style: shadcn.Theme.of(context).typography.xSmall.copyWith(color: cs.mutedForeground, fontSize: 9),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (expired)
                  const _AdminPill(text: '过期', destructive: true, dense: true)
                else ...[
                  if (user.timeExpire.isNotEmpty) _AdminPill(text: _displayDate(user.timeExpire), dense: true),
                  if (user.tryUser) const _AdminPill(text: '试用', dense: true),
                ],
              ],
            ),
          ),
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
    final cs = _adminColors(context);
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: expired ? cs.destructive : cs.primary, shape: BoxShape.circle),
    );
  }
}

class _AdminInfoText extends StatelessWidget {
  final String label;
  final String value;

  const _AdminInfoText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = _adminColors(context);
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: shadcn.Theme.of(context).typography.xSmall.copyWith(color: cs.mutedForeground),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: shadcn.Theme.of(
              context,
            ).typography.xSmall.copyWith(color: cs.foreground, fontWeight: FontWeight.w600),
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

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: _adminRadius(context),
        border: Border.all(color: cs.border.withValues(alpha: 0.8), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: _adminRadius(context)),
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
                  style: typo.large.copyWith(fontWeight: FontWeight.w700, color: cs.foreground),
                ),
                Text(label, style: typo.xSmall.copyWith(color: cs.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartBlock extends StatelessWidget {
  final String title;
  final List<_ChartItem> items;

  const _DonutChartBlock({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final total = items.fold<int>(0, (sum, item) => sum + item.value);
    return Container(
      height: 128,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: _adminRadius(context),
        border: Border.all(color: cs.border.withValues(alpha: 0.8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: typo.small.copyWith(fontWeight: FontWeight.w600, color: cs.foreground),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size.square(72),
                        painter: _DonutChartPainter(items: items, backgroundColor: cs.secondary),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            total.toString(),
                            style: typo.small.copyWith(fontWeight: FontWeight.w700, color: cs.foreground, height: 1),
                          ),
                          const SizedBox(height: 2),
                          Text('总计', style: typo.xSmall.copyWith(color: cs.mutedForeground, height: 1)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: items.map((item) {
                      final percent = total > 0 ? item.value / total * 100 : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typo.xSmall.copyWith(color: cs.mutedForeground),
                              ),
                            ),
                            Text(
                              item.value.toString(),
                              style: typo.xSmall.copyWith(fontWeight: FontWeight.w700, color: cs.foreground),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 42,
                              child: Text(
                                '${percent.toStringAsFixed(0)}%',
                                textAlign: TextAlign.right,
                                style: typo.xSmall.copyWith(color: cs.mutedForeground),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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

class _DonutChartPainter extends CustomPainter {
  final List<_ChartItem> items;
  final Color backgroundColor;

  const _DonutChartPainter({required this.items, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = items.fold<int>(0, (sum, item) => sum + item.value);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor;

    canvas.drawCircle(center, radius, basePaint);
    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final item in items.where((item) => item.value > 0)) {
      final sweepAngle = item.value / total * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = item.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.backgroundColor != backgroundColor;
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
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.secondary.withValues(alpha: 0.55),
        borderRadius: _adminRadius(context),
        border: Border.all(color: cs.border.withValues(alpha: 0.7), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.typography.xSmall.copyWith(color: cs.mutedForeground)),
          const SizedBox(height: 2),
          Text(value.isEmpty ? '-' : value, style: theme.typography.small.copyWith(color: cs.foreground)),
        ],
      ),
    );
  }
}

class _DiscountButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _DiscountButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 28,
      child: shadcn.Button.outline(
        onPressed: onPressed,
        child: Text(label, maxLines: 1, style: shadcn.Theme.of(context).typography.xSmall.copyWith(height: 1)),
      ),
    );
  }
}

class _AdminPill extends StatelessWidget {
  final String text;
  final bool destructive;
  final bool dense;

  const _AdminPill({required this.text, this.destructive = false, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final cs = _adminColors(context);
    final color = destructive ? cs.destructive : cs.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 6 : 7, vertical: dense ? 1 : 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: _adminRadius(context, size: 'xs'),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        text,
        style: shadcn.Theme.of(
          context,
        ).typography.xSmall.copyWith(height: 1.2, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AdminLoadingBlock extends StatelessWidget {
  final String label;

  const _AdminLoadingBlock({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = _adminColors(context);
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: cs.border.withValues(alpha: 0.5), width: 0.5),
        borderRadius: _adminRadius(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const shadcn.CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 10),
          Text(label, style: shadcn.Theme.of(context).typography.small.copyWith(color: cs.mutedForeground)),
        ],
      ),
    );
  }
}

class _AdminErrorBlock extends StatelessWidget {
  final String title;
  final Object error;
  final VoidCallback onRetry;

  const _AdminErrorBlock({required this.title, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = _adminColors(context);
    return _PanelTile(
      leading: Icon(shadcn.LucideIcons.circleAlert, color: cs.destructive),
      title: Text(title),
      subtitle: Text('$error'),
      trailing: shadcn.Button.outline(onPressed: onRetry, child: const Text('重试')),
    );
  }
}

class _AdminEmptyBlock extends StatelessWidget {
  final String text;

  const _AdminEmptyBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = _adminColors(context);
    return Container(
      height: 104,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: cs.border.withValues(alpha: 0.5), width: 0.5),
        borderRadius: _adminRadius(context),
      ),
      child: Text(text, style: shadcn.Theme.of(context).typography.small.copyWith(color: cs.mutedForeground)),
    );
  }
}

class _PanelTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  const _PanelTile({this.leading, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = _adminColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: cs.border),
        borderRadius: _adminRadius(context),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(
                    style: shadcn.Theme.of(context).typography.small.copyWith(color: cs.mutedForeground),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final bool saving;
  final String cancelLabel;
  final String submitLabel;
  final VoidCallback onCancel;
  final Future<void> Function() onSubmit;

  const _DialogActions({
    required this.saving,
    required this.cancelLabel,
    required this.submitLabel,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: shadcn.Button.outline(onPressed: saving ? null : onCancel, child: Text(cancelLabel)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: shadcn.Button.primary(
            onPressed: saving ? null : onSubmit,
            child: saving
                ? const SizedBox(width: 16, height: 16, child: shadcn.CircularProgressIndicator(strokeWidth: 2))
                : Text(submitLabel),
          ),
        ),
      ],
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
