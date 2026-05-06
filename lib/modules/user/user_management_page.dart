import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/auth/auth_provider.dart';
import 'package:harvest/modules/auth/user_model.dart';
import 'package:harvest/widgets/escape_back_scope.dart';

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
    final authInfo = ref.watch(authInfoProvider);
    final users = ref.watch(managedUserListProvider);
    final currentUser = ref.watch(authNotifierProvider).user;

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: FScaffold(
        childPad: false,
        header: FHeader.nested(
          title: const Text('用户中心'),
          prefixes: [
            FHeaderAction(
              icon: const Icon(FIcons.chevronLeft),
              onPress: () => Navigator.of(context).pop(),
            ),
          ],
          suffixes: [
            FHeaderAction(
              icon: const Icon(FIcons.refreshCw),
              onPress: () {
                ref.invalidate(authInfoProvider);
                ref.read(managedUserListProvider.notifier).refresh();
              },
            ),
          ],
        ),
        child: EasyRefresh(
          onRefresh: _refresh,
          header: appRefreshHeader(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              authInfo.when(
                loading: () => const _LoadingBlock(label: '授权信息加载中...'),
                error: (error, _) => _ErrorBlock(
                  title: '授权信息加载失败',
                  error: error,
                  onRetry: () => ref.invalidate(authInfoProvider),
                ),
                data: (data) => _AuthInfoBlock(data: data),
              ),
              const SizedBox(height: 14),
              users.when(
                loading: () => const _LoadingBlock(label: '用户列表加载中...'),
                error: (error, _) => _ErrorBlock(
                  title: '用户列表加载失败',
                  error: error,
                  onRetry: () =>
                      ref.read(managedUserListProvider.notifier).refresh(),
                ),
                data: (items) => _buildUserManagement(items, currentUser),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await Future.wait<dynamic>([
      ref.refresh(authInfoProvider.future),
      ref.read(managedUserListProvider.notifier).refresh(),
    ]);
  }

  Widget _buildUserManagement(List<ManagedUser> users, User? currentUser) {
    final keyword = _keyword.trim().toLowerCase();
    final currentManagedUser = _findCurrentManagedUser(users, currentUser);
    final canManageStatus =
        currentManagedUser?.isStaff == true ||
        currentManagedUser?.isSuperuser == true ||
        currentUser?.isStaff == true ||
        currentUser?.isSuperuser == true;
    final filtered = keyword.isEmpty
        ? users
        : users.where((user) {
            return user.username.toLowerCase().contains(keyword) ||
                user.email.toLowerCase().contains(keyword) ||
                user.id.toString().contains(keyword);
          }).toList();

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
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          _EmptyBlock(text: keyword.isEmpty ? '暂无用户' : '没有匹配的用户')
        else
          _UserList(
            users: filtered,
            currentUserId: currentUser?.id,
            currentUsername: currentUser?.username,
            canManageStatus: canManageStatus,
            onEdit: (user) => _openUserDialog(user: user),
            onResetPassword: (user) =>
                _openUserDialog(user: user, resetPassword: true),
            onToggleStatus: _toggleUserStatus,
            onDelete: _confirmDelete,
          ),
      ],
    );
  }

  ManagedUser? _findCurrentManagedUser(
    List<ManagedUser> users,
    User? currentUser,
  ) {
    if (currentUser == null) return null;
    for (final user in users) {
      if (user.id == currentUser.id || user.username == currentUser.username) {
        return user;
      }
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

    showFDialog(
      context: context,
      builder: (ctx, style, animation) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> save() async {
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
              final credentials = UserCredentials(
                username: username,
                password: password,
              );
              if (isEdit) {
                await ref
                    .read(managedUserListProvider.notifier)
                    .updateUser(user.id, credentials);
              } else {
                await ref
                    .read(managedUserListProvider.notifier)
                    .createUser(credentials);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
              Toast.success(
                resetPassword ? '密码已重置' : (isEdit ? '用户已更新' : '用户已添加'),
              );
            } catch (e) {
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
            title: Text(title),
            body: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FTextField(
                    controller: usernameCtrl,
                    label: const Text('用户名'),
                    enabled: !resetPassword,
                    autofocus: !isEdit,
                  ),
                  const SizedBox(height: 12),
                  FTextField(
                    controller: passwordCtrl,
                    label: Text(resetPassword ? '新密码' : '密码'),
                    obscureText: true,
                    autofocus: resetPassword,
                  ),
                  const SizedBox(height: 12),
                  FTextField(
                    controller: confirmCtrl,
                    label: const Text('确认密码'),
                    obscureText: true,
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
                              : Text(isEdit ? '保存' : '添加'),
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

  void _confirmDelete(ManagedUser user) {
    showDialog(
      context: context,
      builder: (ctx) => FDialog(
        title: const Text('确认删除'),
        body: Text('确定要删除用户「${user.username}」吗？'),
        actions: [
          FButton(
            style: FButtonStyle.outline(),
            onPress: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(managedUserListProvider.notifier)
                    .deleteUser(user.id);
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
      await ref
          .read(managedUserListProvider.notifier)
          .updateUserStatus(user, nextActive);
      Toast.success(nextActive ? '用户已启用' : '用户已禁用');
    } catch (_) {}
  }
}

class _AuthInfoBlock extends StatelessWidget {
  final dynamic data;

  const _AuthInfoBlock({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = _authEntries(data);
    if (entries.isEmpty) {
      return const _EmptyBlock(text: '暂无授权信息');
    }

    return FTileGroup(
      style: fTileGroupStyle(context).call,
      label: const Text('授权信息'),
      divider: FItemDivider.full,
      children: entries
          .map(
            (entry) => FTile(
              prefix: const Icon(FIcons.shieldCheck, size: 18),
              title: Text(entry.key),
              subtitle: Text(entry.value),
            ),
          )
          .toList(),
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

  const _UserToolbar({
    required this.controller,
    required this.total,
    required this.current,
    required this.onSearch,
    required this.onClear,
    required this.onAdd,
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
                '用户管理',
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
              onPress: onAdd,
              child: const Icon(FIcons.userPlus, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FTextField(
          controller: controller,
          hint: '搜索用户名、邮箱或ID',
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

class _UserList extends StatelessWidget {
  final List<ManagedUser> users;
  final int? currentUserId;
  final String? currentUsername;
  final bool canManageStatus;
  final ValueChanged<ManagedUser> onEdit;
  final ValueChanged<ManagedUser> onResetPassword;
  final ValueChanged<ManagedUser> onToggleStatus;
  final ValueChanged<ManagedUser> onDelete;

  const _UserList({
    required this.users,
    required this.currentUserId,
    required this.currentUsername,
    required this.canManageStatus,
    required this.onEdit,
    required this.onResetPassword,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      style: fTileGroupStyle(context).call,
      divider: FItemDivider.none,
      children: users
          .map(
            (user) => _UserTile(
              user: user,
              isCurrentUser: _isCurrentUser(user),
              canManageStatus: canManageStatus,
              onEdit: onEdit,
              onResetPassword: onResetPassword,
              onToggleStatus: onToggleStatus,
              onDelete: onDelete,
            ),
          )
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
    final cs = context.theme.colors;
    final initial = user.username.isEmpty
        ? '?'
        : user.username.substring(0, 1).toUpperCase();
    return FAvatar.raw(
      size: 34,
      style: FAvatarStyle(
        backgroundColor: cs.primary,
        foregroundColor: cs.primaryForeground,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ).call,
      child: Text(initial),
    );
  }
}

class _UserSubtitle extends StatelessWidget {
  final ManagedUser user;
  final bool isCurrentUser;

  const _UserSubtitle({required this.user, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final typo = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                'ID ${user.id}',
                style: typo.xs.copyWith(color: cs.mutedForeground),
              ),
              if (user.email.isNotEmpty)
                Text(
                  user.email,
                  style: typo.xs.copyWith(color: cs.mutedForeground),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusPill(
                text: user.isActive ? '启用' : '停用',
                active: user.isActive,
              ),
              if (user.isStaff) const _StatusPill(text: '管理员', active: true),
              if (user.isSuperuser)
                const _StatusPill(text: '超级用户', active: true),
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
    final cs = context.theme.colors;
    final color = active ? cs.primary : cs.mutedForeground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          height: 1.2,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UserTile extends StatefulWidget with FTileMixin {
  final ManagedUser user;
  final bool isCurrentUser;
  final bool canManageStatus;
  final ValueChanged<ManagedUser> onEdit;
  final ValueChanged<ManagedUser> onResetPassword;
  final ValueChanged<ManagedUser> onToggleStatus;
  final ValueChanged<ManagedUser> onDelete;

  const _UserTile({
    required this.user,
    required this.isCurrentUser,
    required this.canManageStatus,
    required this.onEdit,
    required this.onResetPassword,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile>
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

    return FPopoverMenu.tiles(
      popoverController: _popoverCtrl,
      style: fPopoverMenuStyle(context).call,
      spacing: FPortalSpacing.zero,
      menu: [
        FTileGroup(
          children: [
            FTile(
              prefix: const Icon(FIcons.squarePen, size: 14),
              title: const Text('编辑'),
              onPress: () {
                _popoverCtrl.hide();
                widget.onEdit(widget.user);
              },
            ),
            FTile(
              prefix: const Icon(FIcons.keyRound, size: 14),
              title: const Text('重置密码'),
              onPress: () {
                _popoverCtrl.hide();
                widget.onResetPassword(widget.user);
              },
            ),
            if (widget.canManageStatus && !widget.isCurrentUser)
              FTile(
                prefix: Icon(
                  widget.user.isActive ? FIcons.pause : FIcons.play,
                  size: 14,
                ),
                title: Text(widget.user.isActive ? '禁用' : '启用'),
                onPress: () {
                  _popoverCtrl.hide();
                  widget.onToggleStatus(widget.user);
                },
              ),
            FTile(
              prefix: Icon(
                FIcons.trash2,
                size: 14,
                color: context.theme.colors.destructive,
              ),
              title: const Text('删除'),
              onPress: () {
                _popoverCtrl.hide();
                widget.onDelete(widget.user);
              },
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
        prefix: _UserAvatar(user: widget.user),
        title: Text(
          widget.user.username.isEmpty ? '未命名用户' : widget.user.username,
        ),
        subtitle: _UserSubtitle(
          user: widget.user,
          isCurrentUser: widget.isCurrentUser,
        ),
        onPress: () => _popoverCtrl.toggle(),
        onSecondaryPress: () => _popoverCtrl.toggle(),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  final String label;

  const _LoadingBlock({required this.label});

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

class _ErrorBlock extends StatelessWidget {
  final String title;
  final Object error;
  final VoidCallback onRetry;

  const _ErrorBlock({
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

class _EmptyBlock extends StatelessWidget {
  final String text;

  const _EmptyBlock({required this.text});

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

List<MapEntry<String, String>> _authEntries(dynamic data) {
  if (data == null) return const [];
  if (data is Map) {
    return data.entries
        .where((entry) => entry.value != null)
        .map(
          (entry) =>
              MapEntry(_label(entry.key.toString()), _formatValue(entry.value)),
        )
        .where((entry) => entry.value.isNotEmpty)
        .toList();
  }
  if (data is List) {
    return [
      MapEntry(
        '授权信息',
        data.map(_formatValue).where((v) => v.isNotEmpty).join('\n'),
      ),
    ];
  }
  return [MapEntry('授权信息', _formatValue(data))];
}

String _label(String key) {
  const labels = {
    'username': '用户名',
    'email': '邮箱',
    'expire': '到期时间',
    'expire_time': '到期时间',
    'expired_at': '到期时间',
    'pay': '授权额度',
    'invite': '邀请次数',
    'try_user': '试用用户',
    'marked': '备注',
    'token': '授权 Token',
    'active': '状态',
    'is_active': '状态',
  };
  return labels[key] ?? key;
}

String _formatValue(dynamic value) {
  if (value == null) return '';
  if (value is bool) return value ? '是' : '否';
  if (value is Map) {
    return value.entries
        .map(
          (entry) =>
              '${_label(entry.key.toString())}: ${_formatValue(entry.value)}',
        )
        .join('\n');
  }
  if (value is List)
    return value.map(_formatValue).where((v) => v.isNotEmpty).join(', ');
  return value.toString();
}
