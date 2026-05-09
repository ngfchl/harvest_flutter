import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/auth/auth_provider.dart';
import 'package:harvest/modules/auth/user_model.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'model/user_management_model.dart';
import 'provider/user_management_provider.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  final _searchCtrl = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(managedUserListProvider);
    final currentUser = ref.watch(authNotifierProvider).user;
    final tokens = _UserManagementThemeTokens.of(context);
    final cs = tokens.cs;

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: ColoredBox(
        color: cs.background,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: _Header(
                title: '用户中心',
                onBack: () => Navigator.of(context).pop(),
                onRefresh: () => ref.read(managedUserListProvider.notifier).refresh(),
              ),
            ),
            Expanded(
              child: EasyRefresh(
                onRefresh: _refresh,
                header: appRefreshHeader(context),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: tokens.edgeFromLTRB(12, 12, 12, 24),
                  children: [
                    users.when(
                      loading: () => const _LoadingBlock(label: '用户列表加载中...'),
                      error: (error, _) => _ErrorBlock(title: '用户列表加载失败', error: error, onRetry: () => ref.read(managedUserListProvider.notifier).refresh()),
                      data: (items) => _buildUserManagement(items, currentUser),
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

  Future<void> _refresh() async {
    await ref.read(managedUserListProvider.notifier).refresh();
  }

  Widget _buildUserManagement(List<ManagedUser> users, User? currentUser) {
    final tokens = _UserManagementThemeTokens.of(context);
    final keyword = _keyword.trim().toLowerCase();
    final currentManagedUser = _findCurrentManagedUser(users, currentUser);
    final canManageStatus = currentManagedUser?.isStaff == true || currentManagedUser?.isSuperuser == true || currentUser?.isStaff == true || currentUser?.isSuperuser == true;
    final filtered = keyword.isEmpty
        ? users
        : users.where((user) => user.username.toLowerCase().contains(keyword) || user.email.toLowerCase().contains(keyword) || user.id.toString().contains(keyword)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _UserToolbar(
          controller: _searchCtrl,
          total: users.length,
          current: filtered.length,
          onSearch: (value) => setState(() => _keyword = value),
          onClear: () {
            _searchCtrl.clear();
            setState(() => _keyword = '');
          },
          onAdd: () => _openUserDialog(),
        ),
        tokens.vGap(10),
        if (filtered.isEmpty)
          _EmptyBlock(text: keyword.isEmpty ? '暂无用户' : '没有匹配的用户')
        else
          _UserList(
            users: filtered,
            currentUserId: currentUser?.id,
            currentUsername: currentUser?.username,
            canManageStatus: canManageStatus,
            onEdit: (user) => _openUserDialog(user: user),
            onResetPassword: (user) => _openUserDialog(user: user, resetPassword: true),
            onToggleStatus: _toggleUserStatus,
            onDelete: _confirmDelete,
          ),
      ],
    );
  }

  ManagedUser? _findCurrentManagedUser(List<ManagedUser> users, User? currentUser) {
    if (currentUser == null) return null;
    for (final user in users) {
      if (user.id == currentUser.id || user.username == currentUser.username) return user;
    }
    return null;
  }

  void _openUserDialog({ManagedUser? user, bool resetPassword = false}) {
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    var saving = false;
    final isEdit = user != null;
    final title = !isEdit ? '新增用户' : (resetPassword ? '重置密码' : '编辑用户');

    shadcn.showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final tokens = _UserManagementThemeTokens.of(ctx);
          return shadcn.AlertDialog(
            title: Text(title),
            content: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SizedBox(
                width: tokens.dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    shadcn.TextField(
                      controller: usernameCtrl,
                      enabled: !resetPassword,
                      autofocus: !isEdit,
                      placeholder: const Text('用户名'),
                      onSubmitted: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    tokens.vGap(12),
                    shadcn.TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      autofocus: resetPassword,
                      placeholder: Text(resetPassword ? '新密码' : '密码'),
                      onSubmitted: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    tokens.vGap(12),
                    shadcn.TextField(
                      controller: confirmCtrl,
                      obscureText: true,
                      placeholder: const Text('确认密码'),
                      onSubmitted: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              shadcn.Button.outline(onPressed: saving ? null : () => Navigator.of(ctx).pop(), child: const Text('取消')),
              shadcn.Button.primary(
                onPressed: saving
                    ? null
                    : () async {
                        final username = usernameCtrl.text.trim();
                        final password = passwordCtrl.text.trim();
                        final confirm = confirmCtrl.text.trim();
                        if (username.isEmpty) {
                          Toast.warning('用户名不能为空');
                          return;
                        }
                        if (password.isEmpty) {
                          Toast.warning(resetPassword ? '新密码不能为空' : '密码不能为空');
                          return;
                        }
                        if (password != confirm) {
                          Toast.warning('两次输入的密码不一致');
                          return;
                        }
                        setDialogState(() => saving = true);
                        try {
                          final credentials = UserCredentials(username: username, password: password);
                          if (isEdit) {
                            await ref.read(managedUserListProvider.notifier).updateUser(user.id, credentials);
                          } else {
                            await ref.read(managedUserListProvider.notifier).createUser(credentials);
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          Toast.success(resetPassword ? '密码已重置' : (isEdit ? '用户已更新' : '用户已添加'));
                        } catch (_) {
                          if (ctx.mounted) setDialogState(() => saving = false);
                        }
                      },
                child: saving ? SizedBox(width: tokens.iconMd, height: tokens.iconMd, child: shadcn.CircularProgressIndicator(strokeWidth: tokens.size(2))) : Text(isEdit ? '保存' : '添加'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(ManagedUser user) {
    shadcn.showDialog(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除用户「${user.username}」吗？'),
        actions: [
          shadcn.Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          shadcn.Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(managedUserListProvider.notifier).deleteUser(user.id);
                Toast.success('用户已删除');
              } catch (_) {}
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(ManagedUser user) async {
    final nextActive = !user.isActive;
    try {
      await ref.read(managedUserListProvider.notifier).updateUserStatus(user, nextActive);
      Toast.success(nextActive ? '用户已启用' : '用户已禁用');
    } catch (_) {}
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const _Header({required this.title, required this.onBack, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final tokens = _UserManagementThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;

    return Padding(
      padding: tokens.edgeFromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          shadcn.IconButton.ghost(icon: Icon(shadcn.LucideIcons.chevronLeft, size: tokens.iconLg), onPressed: onBack),
          Expanded(
            child: Text(
              title,
              style: theme.typography.large.copyWith(color: cs.foreground, fontWeight: FontWeight.w700),
            ),
          ),
          shadcn.IconButton.ghost(icon: Icon(shadcn.LucideIcons.refreshCw, size: tokens.iconMd), onPressed: onRefresh),
        ],
      ),
    );
  }
}

class _UserToolbar extends StatelessWidget {
  final TextEditingController controller;
  final int total;
  final int current;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final VoidCallback onAdd;

  const _UserToolbar({required this.controller, required this.total, required this.current, required this.onSearch, required this.onClear, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final tokens = _UserManagementThemeTokens.of(context);
    return Row(
      children: [
        Expanded(child: shadcn.TextField(
          controller: controller,
          onChanged: onSearch,
          placeholder: const Text('搜索用户名、邮箱或 ID'),
          features: [
            shadcn.InputFeature.leading(Icon(shadcn.LucideIcons.search, size: tokens.iconSm, color: cs.mutedForeground)),
            if (controller.text.isNotEmpty)
              shadcn.InputFeature.trailing(
                shadcn.IconButton.ghost(onPressed: onClear, icon: Icon(shadcn.LucideIcons.x, size: tokens.iconSm)),
              ),
          ],
        ),),
        tokens.hGap(8),
        Text('$current / $total', style: typo.small.copyWith(color: cs.mutedForeground)),
        tokens.hGap(8),
        shadcn.IconButton.primary(onPressed: onAdd, icon: Icon(shadcn.LucideIcons.userPlus, size: tokens.iconMd)),
      ],
    );
  }
}

class _UserList extends StatelessWidget {
  final List<ManagedUser> users;
  final int? currentUserId;
  final String? currentUsername;
  final bool canManageStatus;
  final ValueChanged<ManagedUser> onEdit;
  final ValueChanged<ManagedUser> onResetPassword;
  final ValueChanged<ManagedUser> onToggleStatus;
  final ValueChanged<ManagedUser> onDelete;

  const _UserList({required this.users, required this.currentUserId, required this.currentUsername, required this.canManageStatus, required this.onEdit, required this.onResetPassword, required this.onToggleStatus, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final tokens = _UserManagementThemeTokens.of(context);
    return Column(
      children: users
          .map((user) => Padding(
                padding: tokens.edgeOnly(bottom: 10),
                child: _UserTile(
                  user: user,
                  isCurrentUser: _isCurrentUser(user),
                  canManageStatus: canManageStatus,
                  onEdit: onEdit,
                  onResetPassword: onResetPassword,
                  onToggleStatus: onToggleStatus,
                  onDelete: onDelete,
                ),
              ))
          .toList(),
    );
  }

  bool _isCurrentUser(ManagedUser user) {
    if (currentUserId != null && currentUserId == user.id) return true;
    return currentUsername != null && currentUsername == user.username;
  }
}

class _UserAvatar extends StatelessWidget {
  final ManagedUser user;

  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final tokens = _UserManagementThemeTokens.of(context);
    final cs = tokens.cs;
    final initial = user.username.isEmpty ? '?' : user.username.substring(0, 1).toUpperCase();
    return shadcn.Avatar(
      initials: initial,
      size: tokens.avatarSize,
      backgroundColor: cs.primary,
    );
  }
}

class _UserSubtitle extends StatelessWidget {
  final ManagedUser user;
  final bool isCurrentUser;

  const _UserSubtitle({required this.user, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final tokens = _UserManagementThemeTokens.of(context);
    return Padding(
      padding: tokens.edgeOnly(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: tokens.size(6),
            runSpacing: tokens.size(4),
            children: [
              Text('ID ${user.id}', style: typo.xSmall.copyWith(color: cs.mutedForeground)),
              if (user.email.isNotEmpty) Text(user.email, style: typo.xSmall.copyWith(color: cs.mutedForeground)),
            ],
          ),
          tokens.vGap(6),
          Wrap(
            spacing: tokens.size(6),
            runSpacing: tokens.size(6),
            children: [
              _StatusPill(text: user.isActive ? '启用' : '停用', active: user.isActive),
              if (user.isStaff) const _StatusPill(text: '管理员', active: true),
              if (user.isSuperuser) const _StatusPill(text: '超级用户', active: true),
              if (isCurrentUser) const _StatusPill(text: '当前用户', active: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final bool active;

  const _StatusPill({required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    if (active) return shadcn.SecondaryBadge(child: Text(text));
    return shadcn.OutlineBadge(child: Text(text));
  }
}

class _UserTile extends StatelessWidget {
  final ManagedUser user;
  final bool isCurrentUser;
  final bool canManageStatus;
  final ValueChanged<ManagedUser> onEdit;
  final ValueChanged<ManagedUser> onResetPassword;
  final ValueChanged<ManagedUser> onToggleStatus;
  final ValueChanged<ManagedUser> onDelete;

  const _UserTile({required this.user, required this.isCurrentUser, required this.canManageStatus, required this.onEdit, required this.onResetPassword, required this.onToggleStatus, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      onLongPress: () => _showMenu(context),
      onSecondaryTap: () => _showMenu(context),
      child: shadcn.Card(
        padding: _UserManagementThemeTokens.of(context).edgeFromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            _UserAvatar(user: user),
            _UserManagementThemeTokens.of(context).hGap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.username.isEmpty ? '未命名用户' : user.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: shadcn.Theme.of(context).typography.small.copyWith(
                          color: shadcn.Theme.of(context).colorScheme.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  _UserSubtitle(user: user, isCurrentUser: isCurrentUser),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    shadcn.showDialog<void>(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        title: Text(user.username.isEmpty ? '用户操作' : user.username),
        content: SizedBox(
          width: _UserManagementThemeTokens.of(ctx).dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionTile(icon: shadcn.LucideIcons.squarePen, title: '编辑', onTap: () { Navigator.pop(ctx); onEdit(user); }),
              _ActionTile(icon: shadcn.LucideIcons.keyRound, title: '重置密码', onTap: () { Navigator.pop(ctx); onResetPassword(user); }),
              if (canManageStatus && !isCurrentUser)
                _ActionTile(icon: user.isActive ? shadcn.LucideIcons.pause : shadcn.LucideIcons.play, title: user.isActive ? '禁用' : '启用', onTap: () { Navigator.pop(ctx); onToggleStatus(user); }),
              _ActionTile(icon: shadcn.LucideIcons.trash2, title: '删除', destructive: true, onTap: () { Navigator.pop(ctx); onDelete(user); }),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  final String label;

  const _LoadingBlock({required this.label});

  @override
  Widget build(BuildContext context) {
    final tokens = _UserManagementThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return shadcn.Card(
      padding: tokens.edgeAll(18),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [shadcn.CircularProgressIndicator(strokeWidth: tokens.size(2)), tokens.vGap(10), Text(label, style: theme.typography.small.copyWith(color: cs.mutedForeground))]),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String title;
  final Object error;
  final VoidCallback onRetry;

  const _ErrorBlock({required this.title, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return _PanelTile(
      leading: Icon(shadcn.LucideIcons.circleAlert, color: cs.destructive),
      title: Text(title),
      subtitle: Text('$error'),
      trailing: shadcn.Button.outline(onPressed: onRetry, child: const Text('重试')),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String text;

  const _EmptyBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final tokens = _UserManagementThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return shadcn.Card(
      padding: tokens.edgeAll(18),
      child: Center(child: Text(text, style: theme.typography.small.copyWith(color: cs.mutedForeground))),
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
    final tokens = _UserManagementThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return Padding(
      padding: tokens.edgeSymmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[leading!, tokens.hGap(10)],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [DefaultTextStyle.merge(style: theme.typography.small.copyWith(color: cs.foreground), child: title), if (subtitle != null) ...[tokens.vGap(2), DefaultTextStyle.merge(style: theme.typography.xSmall.copyWith(color: cs.mutedForeground), child: subtitle!)]]),
          ),
          if (trailing != null) ...[tokens.hGap(12), trailing!],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionTile({required this.icon, required this.title, required this.onTap, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    final tokens = _UserManagementThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final color = destructive ? cs.destructive : null;
    return shadcn.Button.ghost(
      alignment: Alignment.centerLeft,
      onPressed: onTap,
      leading: Icon(icon, size: tokens.iconMd, color: color),
      child: Text(title, style: theme.typography.small.copyWith(color: color ?? cs.foreground)),
    );
  }
}

class _UserManagementThemeTokens {
  final shadcn.ThemeData theme;
  final shadcn.ColorScheme cs;
  final double densityScale;
  final double textScale;

  _UserManagementThemeTokens._({
    required this.theme,
    required this.cs,
    required this.densityScale,
    required this.textScale,
  });

  factory _UserManagementThemeTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityScale = ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(0.55, 1.45);
    final textScale = theme.scaling.clamp(0.86, 1.30);
    return _UserManagementThemeTokens._(
      theme: theme,
      cs: theme.colorScheme,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  double get iconSm => font(14);

  double get iconMd => font(18);

  double get iconLg => font(20);

  double get avatarSize => size(34);

  double get dialogWidth => size(360).clamp(300.0, 420.0);

  EdgeInsets edgeAll(num value) => EdgeInsets.all(size(value));

  EdgeInsets edgeSymmetric({num horizontal = 0, num vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: size(horizontal), vertical: size(vertical));

  EdgeInsets edgeFromLTRB(num left, num top, num right, num bottom) =>
      EdgeInsets.fromLTRB(size(left), size(top), size(right), size(bottom));

  EdgeInsets edgeOnly({num left = 0, num top = 0, num right = 0, num bottom = 0}) => EdgeInsets.only(
        left: size(left),
        top: size(top),
        right: size(right),
        bottom: size(bottom),
      );

  SizedBox hGap(num value) => SizedBox(width: size(value));

  SizedBox vGap(num value) => SizedBox(height: size(value));
}
