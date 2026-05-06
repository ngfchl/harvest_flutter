import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/site_config.dart';
import '../model/site_info.dart';
import '../provider/site_provider.dart';

// ═══════════════════════════════════════════════════
//  公共入口
// ═══════════════════════════════════════════════════

void showAddSiteSheet(BuildContext context) {
  const sheet = AddSiteSheet();
  if (context.isMobile) {
    showFSheet(context: context, side: FLayout.btt, builder: (_) => sheet);
  } else {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600), child: sheet),
      ),
    );
  }
}

class _SiteSwitchOption {
  final String title;
  final bool value;
  final ValueChanged<bool> onChange;

  const _SiteSwitchOption(this.title, this.value, this.onChange);
}

class _SwitchCard extends StatelessWidget {
  final _SiteSwitchOption option;

  const _SwitchCard({required this.option});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final active = option.value;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: active ? cs.primary.withValues(alpha: 0.08) : cs.muted.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? cs.primary.withValues(alpha: 0.28) : cs.border.withValues(alpha: 0.55),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? cs.foreground : cs.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 6),
          FSwitch(value: active, onChange: option.onChange),
        ],
      ),
    );
  }
}

void showSiteForm(
  BuildContext context, {
  SiteInfo? site,
  String? siteName,
  WebSite? config,
  bool showBackToList = false,
}) {
  if (context.isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollCtrl) =>
            SiteFormSheet(site: site, siteName: siteName, scrollController: scrollCtrl, showBackToList: showBackToList),
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
          child: SiteFormSheet(site: site, siteName: siteName, showBackToList: showBackToList),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  添加站点选择列表
// ═══════════════════════════════════════════════════

class AddSiteSheet extends ConsumerWidget {
  const AddSiteSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unaddedAsync = ref.watch(unaddedSitesProvider);
    final mobile = context.isMobile;
    final cs = context.theme.colors;

    final content = unaddedAsync.when(
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载失败: $e'),
            const SizedBox(height: 16),
            FButton(onPress: () => ref.invalidate(unaddedSitesProvider), child: const Text('重试')),
          ],
        ),
      ),
      data: (names) {
        if (names.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FIcons.check, size: 48, color: context.theme.colors.mutedForeground),
                const SizedBox(height: 16),
                Text('所有站点已添加', style: context.theme.typography.lg),
              ],
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mobile) ...[const SizedBox(height: 12), buildHandle(context), const SizedBox(height: 12)],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('选择站点 (${names.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                itemCount: names.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.muted.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.border.withValues(alpha: 0.45), width: 0.5),
                  ),
                  child: FTile(
                    title: Text(names[i]),
                    suffix: Icon(FIcons.chevronRight, size: 16, color: context.theme.colors.mutedForeground),
                    onPress: () => _openAddForm(context, ref, names[i]),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    final sheet = Container(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, mobile ? 0 : 16, mobile ? 12 : 16, mobile ? 12 : 16),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: mobile ? const BorderRadius.vertical(top: Radius.circular(16)) : BorderRadius.circular(16),
      ),
      child: content,
    );

    if (mobile) return SafeArea(child: sheet);
    return sheet;
  }

  void _openAddForm(BuildContext context, WidgetRef ref, String siteName) {
    final configs = ref.read(websiteListProvider).valueOrNull ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == siteName);
    final rootContext = navigatorKey.currentContext ?? Navigator.of(context).context;
    Navigator.pop(context);
    Future<void>.delayed(
      const Duration(milliseconds: 180),
      () => showSiteForm(rootContext, siteName: siteName, config: config, showBackToList: true),
    );
  }
}

// ═══════════════════════════════════════════════════
//  站点表单
// ═══════════════════════════════════════════════════

class SiteFormSheet extends ConsumerStatefulWidget {
  final SiteInfo? site;
  final String? siteName;
  final ScrollController? scrollController;
  final bool showBackToList;

  const SiteFormSheet({super.key, this.site, this.siteName, this.scrollController, this.showBackToList = false});

  @override
  ConsumerState<SiteFormSheet> createState() => _SiteFormSheetState();
}

class _SiteFormSheetState extends ConsumerState<SiteFormSheet> {
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _sortIdCtrl;
  late final TextEditingController _userIdCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passkeyCtrl;
  late final TextEditingController _authkeyCtrl;
  late final TextEditingController _cookieCtrl;
  late final TextEditingController _uaCtrl;
  late final TextEditingController _proxyCtrl;
  late final TextEditingController _mirrorCtrl;
  final _tagInputCtrl = TextEditingController();

  List<String> _selectedTags = [];
  bool _signIn = true, _getInfo = true, _repeatTorrents = true;
  bool _brushFree = true, _brushRss = false;
  bool _hrDiscern = false, _searchTorrents = true;
  bool _showInDash = true, _packageFile = false;
  bool _saving = false;
  bool _available = false;
  bool _configApplied = false;

  bool get _isEdit => widget.site != null;

  String get _siteName => widget.site?.site ?? widget.siteName!;

  @override
  void initState() {
    super.initState();
    final s = widget.site;
    _nicknameCtrl = TextEditingController(text: s?.nickname ?? '');
    _sortIdCtrl = TextEditingController(text: '${s?.sortId ?? 1}');
    _userIdCtrl = TextEditingController(text: s?.userId ?? '');
    _usernameCtrl = TextEditingController(text: s?.username ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _passkeyCtrl = TextEditingController(text: s?.passkey ?? '');
    _authkeyCtrl = TextEditingController(text: s?.authkey ?? '');
    _cookieCtrl = TextEditingController(text: s?.cookie ?? '');
    _uaCtrl = TextEditingController(text: s?.userAgent ?? '');
    _proxyCtrl = TextEditingController(text: s?.proxy ?? '');
    _mirrorCtrl = TextEditingController(text: s?.mirror ?? '');
    _selectedTags = List.from(s?.tags ?? []);
    _signIn = s?.signIn ?? true;
    _getInfo = s?.getInfo ?? true;
    _repeatTorrents = s?.repeatTorrents ?? true;
    _brushFree = s?.brushFree ?? true;
    _brushRss = s?.brushRss ?? false;
    _hrDiscern = s?.hrDiscern ?? false;
    _searchTorrents = s?.searchTorrents ?? true;
    _showInDash = s?.showInDash ?? true;
    _packageFile = s?.packageFile ?? false;
    _available = s?.available ?? true;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _sortIdCtrl.dispose();
    _userIdCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passkeyCtrl.dispose();
    _authkeyCtrl.dispose();
    _cookieCtrl.dispose();
    _uaCtrl.dispose();
    _proxyCtrl.dispose();
    _mirrorCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  void _applyConfigDefaults(WebSite? c) {
    if (c == null || _configApplied) return;
    _configApplied = true;
    if (_mirrorCtrl.text.isEmpty) _mirrorCtrl.text = c.url.firstOrNull ?? '';
    if (!_isEdit) {
      _signIn = c.signIn ?? true;
      _getInfo = c.getInfo ?? true;
      _repeatTorrents = c.repeatTorrents ?? true;
      _brushFree = c.brushFree ?? true;
      _brushRss = c.brushRss ?? false;
      _hrDiscern = c.hrDiscern ?? false;
      _searchTorrents = c.searchTorrents ?? true;
    }
  }

  void _backToAddList() {
    final rootContext = navigatorKey.currentContext ?? Navigator.of(context).context;
    Navigator.of(context).pop();
    Future<void>.delayed(const Duration(milliseconds: 180), () => showAddSiteSheet(rootContext));
  }

  Widget _buildHeader(BuildContext context) {
    final cs = context.theme.colors;
    final showBack = widget.showBackToList && !_isEdit;

    return Row(
      children: [
        if (showBack)
          FButton.icon(
            style: FButtonStyle.ghost(),
            onPress: _backToAddList,
            child: const Icon(FIcons.chevronLeft, size: 18),
          )
        else
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(FIcons.globe, size: 18, color: cs.primary),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _isEdit ? '编辑站点' : '添加站点',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.isMobile ? 150 : 220),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2), width: 0.5),
            ),
            child: Text(
              _siteName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary),
            ),
          ),
        ),
      ],
    );
  }

  void _addCustomTag() {
    final tag = _tagInputCtrl.text.trim();
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
        _tagInputCtrl.clear();
      });
    }
  }

  // ────────────── build ──────────────

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(websiteListProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(48),
            child: Center(child: Text('加载站点配置失败: $e')),
          ),
          data: (list) {
            final config = list.where((s) => s.name == _siteName).firstOrNull;
            if (config == null && !_isEdit) {
              return Padding(
                padding: const EdgeInsets.all(48),
                child: Center(child: Text('未找到站点 "$_siteName" 的配置')),
              );
            }
            _applyConfigDefaults(config);
            return _buildForm(context, config);
          },
        );
  }

  Widget _buildForm(BuildContext context, WebSite? config) {
    final mobile = context.isMobile;
    final configUrls = config?.url ?? [];
    final configTags = config?.tagList ?? [];

    final form = Padding(
      padding: EdgeInsets.fromLTRB(16, mobile ? 0 : 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        children: [
          if (mobile) ...[const SizedBox(height: 12), buildHandle(context), const SizedBox(height: 16)],

          // 头部
          _buildHeader(context),
          const FDivider(),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                // 启用
                FTileGroup(
                  divider: FItemDivider.full,
                  children: [
                    FTile(
                      title: const Text('启用站点'),
                      subtitle: Text(
                        _available ? '站点正常运行中' : '站点已停用',
                        style: TextStyle(
                          fontSize: 12,
                          color: _available ? context.theme.colors.primary : context.theme.colors.mutedForeground,
                        ),
                      ),
                      suffix: FSwitch(value: _available, onChange: (v) => setState(() => _available = v)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 基本信息
                FTileGroup(
                  divider: FItemDivider.full,
                  label: const Text('基本信息'),
                  children: [
                    FTile(
                      title: const Text('昵称'),
                      subtitle: FTextField(controller: _nicknameCtrl),
                    ),
                    FTile(
                      title: const Text('排序'),
                      subtitle: FTextField(controller: _sortIdCtrl),
                    ),
                    FTile(
                      title: const Text('标签'),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (configTags.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: configTags.map((tag) {
                                  final sel = _selectedTags.contains(tag);
                                  return FilterChip(
                                    label: Text(tag, style: TextStyle(fontSize: 12, color: sel ? Colors.white : null)),
                                    selected: sel,
                                    selectedColor: context.theme.colors.primary,
                                    onSelected: (v) =>
                                        setState(() => v ? _selectedTags.add(tag) : _selectedTags.remove(tag)),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: FTextField(controller: _tagInputCtrl, hint: '自定义标签'),
                                ),
                                const SizedBox(width: 8),
                                FButton(style: FButtonStyle.outline(), onPress: _addCustomTag, child: const Text('添加')),
                              ],
                            ),
                            if (_selectedTags.where((t) => !configTags.contains(t)).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _selectedTags
                                    .where((t) => !configTags.contains(t))
                                    .map(
                                      (tag) => Chip(
                                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                                        deleteIcon: const Icon(Icons.close, size: 16),
                                        onDeleted: () => setState(() => _selectedTags.remove(tag)),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 用户信息
                FTileGroup(
                  divider: FItemDivider.full,
                  label: const Text('用户信息'),
                  children: [
                    FTile(
                      title: const Text('用户ID'),
                      subtitle: FTextField(controller: _userIdCtrl),
                    ),
                    FTile(
                      title: const Text('用户名'),
                      subtitle: FTextField(controller: _usernameCtrl),
                    ),
                    FTile(
                      title: const Text('邮箱'),
                      subtitle: FTextField(controller: _emailCtrl),
                    ),
                    FTile(
                      title: const Text('Passkey'),
                      subtitle: FTextField(controller: _passkeyCtrl),
                    ),
                    FTile(
                      title: const Text('Authkey'),
                      subtitle: FTextField(controller: _authkeyCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 账号信息
                FTileGroup(
                  divider: FItemDivider.full,
                  label: const Text('账号信息'),
                  children: [
                    FTile(
                      title: const Text('Cookie'),
                      subtitle: FTextField(controller: _cookieCtrl, maxLines: 3),
                    ),
                    FTile(
                      title: const Text('User Agent'),
                      subtitle: FTextField(controller: _uaCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 连接设置
                FTileGroup(
                  divider: FItemDivider.full,
                  label: const Text('连接设置'),
                  children: [
                    FTile(
                      title: const Text('代理'),
                      subtitle: FTextField(controller: _proxyCtrl, hint: 'http://ip:port'),
                    ),
                    FTile(
                      title: const Text('镜像'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (configUrls.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            FSelect<String>(
                              format: (v) => v,
                              initialValue: configUrls.contains(_mirrorCtrl.text) ? _mirrorCtrl.text : null,
                              onChange: (value) {
                                if (value != null) setState(() => _mirrorCtrl.text = value);
                              },
                              hint: '选择镜像地址',
                              children: configUrls.map((url) => FSelectItem(url, url)).toList(),
                            ),
                            const SizedBox(height: 8),
                          ],
                          FTextField(controller: _mirrorCtrl, hint: 'https://mirror.example.com'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 功能开关
                _buildSwitchGrid(context),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // 按钮
          Row(
            children: [
              Expanded(
                child: FButton(
                  style: FButtonStyle.outline(),
                  onPress: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FButton(
                  onPress: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 16, height: 16, child: FProgress.circularIcon())
                      : const Text('保存'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (mobile) return SafeArea(child: form);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: form);
  }

  // ────────────── 辅助 ──────────────

  Widget _buildSwitchGrid(BuildContext context) {
    final options = [
      _SiteSwitchOption('自动签到', _signIn, (v) => setState(() => _signIn = v)),
      _SiteSwitchOption('获取信息', _getInfo, (v) => setState(() => _getInfo = v)),
      _SiteSwitchOption('辅种任务', _repeatTorrents, (v) => setState(() => _repeatTorrents = v)),
      _SiteSwitchOption('Free 刷流', _brushFree, (v) => setState(() => _brushFree = v)),
      _SiteSwitchOption('RSS 刷流', _brushRss, (v) => setState(() => _brushRss = v)),
      _SiteSwitchOption('HR 识别', _hrDiscern, (v) => setState(() => _hrDiscern = v)),
      _SiteSwitchOption('搜索种子', _searchTorrents, (v) => setState(() => _searchTorrents = v)),
      _SiteSwitchOption('首页展示', _showInDash, (v) => setState(() => _showInDash = v)),
      _SiteSwitchOption('拆包刷流', _packageFile, (v) => setState(() => _packageFile = v)),
    ];

    return FTileGroup(
      label: const Text('功能开关'),
      children: [
        FTile(
          title: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final columns = constraints.maxWidth >= 520 ? 3 : (constraints.maxWidth >= 300 ? 2 : 1);
              final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final option in options)
                    SizedBox(
                      width: itemWidth,
                      child: _SwitchCard(option: option),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String? _opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final sortId = int.tryParse(_sortIdCtrl.text.trim()) ?? 1;
      if (_isEdit) {
        await ref
            .read(siteInfoListProvider.notifier)
            .updateSite(
              widget.site!.copyWith(
                nickname: _nicknameCtrl.text.trim(),
                available: _available,
                sortId: sortId,
                tags: _selectedTags,
                userId: _opt(_userIdCtrl),
                username: _opt(_usernameCtrl),
                email: _opt(_emailCtrl),
                passkey: _opt(_passkeyCtrl),
                authkey: _opt(_authkeyCtrl),
                cookie: _cookieCtrl.text.trim(),
                userAgent: _uaCtrl.text.trim(),
                proxy: _opt(_proxyCtrl),
                mirror: _opt(_mirrorCtrl),
                signIn: _signIn,
                getInfo: _getInfo,
                repeatTorrents: _repeatTorrents,
                brushFree: _brushFree,
                brushRss: _brushRss,
                hrDiscern: _hrDiscern,
                searchTorrents: _searchTorrents,
                showInDash: _showInDash,
                packageFile: _packageFile,
              ),
            );
      } else {
        await ref
            .read(siteInfoListProvider.notifier)
            .create(
              SiteInfo(
                id: 0,
                site: _siteName,
                available: _available,
                nickname: _nicknameCtrl.text.trim(),
                sortId: sortId,
                tags: _selectedTags,
                userId: _opt(_userIdCtrl),
                username: _opt(_usernameCtrl),
                email: _opt(_emailCtrl),
                passkey: _opt(_passkeyCtrl),
                authkey: _opt(_authkeyCtrl),
                cookie: _cookieCtrl.text.trim(),
                userAgent: _uaCtrl.text.trim(),
                proxy: _opt(_proxyCtrl),
                mirror: _opt(_mirrorCtrl),
                signIn: _signIn,
                getInfo: _getInfo,
                repeatTorrents: _repeatTorrents,
                brushFree: _brushFree,
                brushRss: _brushRss,
                hrDiscern: _hrDiscern,
                searchTorrents: _searchTorrents,
                showInDash: _showInDash,
                packageFile: _packageFile,
              ),
            );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      // TODO: 错误提示
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
