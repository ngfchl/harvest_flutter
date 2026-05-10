import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/site_config.dart';
import '../model/site_info.dart';
import '../provider/site_provider.dart';
import 'site_theme.dart';

// ═══════════════════════════════════════════════════
//  公共入口
// ═══════════════════════════════════════════════════

void showAddSiteSheet(BuildContext context) {
  const sheet = AddSiteSheet();
  if (context.isMobile) {
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final maxHeight = (media.size.height - media.padding.top - media.viewInsets.bottom) * 0.66;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: sheet,
          ),
        );
      },
    );
  } else {
    shadcn.showDialog(
      context: context,
      builder: (_) => shadcn.AlertDialog(
        content: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600), child: sheet),
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
    final cs = shadcn.Theme.of(context).colorScheme;
    final active = option.value;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: active ? cs.primary.withValues(alpha: 0.08) : cs.muted.withValues(alpha: 0.25),
        borderRadius: siteRadius(context, size: "md"),
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
          shadcn.Switch(value: active, onChanged: option.onChange),
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
    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollCtrl) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SiteFormSheet(
            site: site,
            siteName: siteName,
            scrollController: scrollCtrl,
            showBackToList: showBackToList,
          ),
        ),
      ),
    );
  } else {
    shadcn.showDialog(
      context: context,
      builder: (_) => shadcn.AlertDialog(
        content: ConstrainedBox(
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
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    final content = unaddedAsync.when(
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(32), child: shadcn.CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载失败: $e'),
            const SizedBox(height: 16),
            shadcn.Button.primary(onPressed: () => ref.invalidate(unaddedSitesProvider), child: const Text('重试')),
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
                Icon(shadcn.LucideIcons.check, size: 48, color: cs.mutedForeground),
                const SizedBox(height: 16),
                Text('所有站点已添加', style: theme.typography.large),
              ],
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    borderRadius: siteRadius(context, size: "md"),
                    border: Border.all(color: cs.border.withValues(alpha: 0.45), width: 0.5),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(names[i]),
                    trailing: Icon(shadcn.LucideIcons.chevronRight, size: 16, color: cs.mutedForeground),
                    onTap: () => _openAddForm(context, ref, names[i]),
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
        borderRadius: mobile
            ? BorderRadius.vertical(top: siteRadius(context, size: "xl").topLeft)
            : siteRadius(context, size: "xl"),
      ),
      child: content,
    );

    return sheet;
  }

  void _openAddForm(BuildContext context, WidgetRef ref, String siteName) {
    final configs = ref.read(websiteListProvider).valueOrNull ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == siteName);
    final rootContext = navigatorKey.currentContext ?? Navigator.of(context).context;
    closeAppSheet(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!rootContext.mounted) return;
      showSiteForm(rootContext, siteName: siteName, config: config, showBackToList: true);
    });
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
  bool _mirrorOptionsExpanded = false;

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
      _signIn = c.signIn;
      _getInfo = c.getInfo;
      _repeatTorrents = c.repeatTorrents;
      _brushFree = c.brushFree;
      _brushRss = c.brushRss;
      _hrDiscern = c.hrDiscern;
      _searchTorrents = c.searchTorrents;
    }
  }

  void _backToAddList() {
    final rootContext = navigatorKey.currentContext ?? Navigator.of(context).context;
    closeAppSheet(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!rootContext.mounted) return;
      showAddSiteSheet(rootContext);
    });
  }

  Widget _buildHeader(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final showBack = widget.showBackToList && !_isEdit;

    return Row(
      children: [
        if (showBack)
          shadcn.IconButton.ghost(onPressed: _backToAddList, icon: const Icon(shadcn.LucideIcons.chevronLeft, size: 18))
        else
          Container(
            width: 32,
            height: 2,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: siteRadius(context, size: "md"),
            ),
            child: Icon(shadcn.LucideIcons.globe, size: 18, color: cs.primary),
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
              borderRadius: siteRadius(context, size: "md"),
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
            child: Center(child: shadcn.CircularProgressIndicator()),
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
    final cs = shadcn.Theme.of(context).colorScheme;

    final form = Padding(
      padding: EdgeInsets.fromLTRB(16, mobile ? 0 : 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        children: [
          _buildHeader(context),
          Divider(height: 2, thickness: 0.6, color: cs.border),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                _availabilitySection(context),
                const SizedBox(height: 16),
                _formSection(context, '基本信息', [
                  _formField('昵称', _nicknameCtrl),
                  _formField('排序', _sortIdCtrl),
                  _tagEditor(context, configTags),
                ]),
                const SizedBox(height: 16),
                _formSection(context, '用户信息', [
                  _formField('用户ID', _userIdCtrl),
                  _formField('用户名', _usernameCtrl),
                  _formField('邮箱', _emailCtrl),
                  _formField('Passkey', _passkeyCtrl),
                  _formField('Authkey', _authkeyCtrl),
                ]),
                const SizedBox(height: 16),
                _formSection(context, '账号信息', [
                  _formField('Cookie', _cookieCtrl, maxLines: 3),
                  _formField('User Agent', _uaCtrl),
                ]),
                const SizedBox(height: 16),
                _formSection(context, '连接设置', [
                  _formField('代理', _proxyCtrl, hint: 'http://ip:port'),
                  _mirrorEditor(context, configUrls),
                ]),
                const SizedBox(height: 16),
                _buildSwitchGrid(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: shadcn.Button.outline(
                  onPressed: () => closeAppSheet(context),
                  child: Center(child: const Text('取消')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: shadcn.Button.primary(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: Center(child: shadcn.CircularProgressIndicator(strokeWidth: 2.2)),
                        )
                      : Center(child: const Text('保存')),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final wrapped = Material(
      color: cs.background,
      borderRadius: mobile
          ? BorderRadius.vertical(top: siteRadius(context, size: "xl").topLeft)
          : siteRadius(context, size: "xl"),
      clipBehavior: Clip.antiAlias,
      child: form,
    );

    final layered = shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: wrapped,
    );

    return Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: layered);
  }

  // ────────────── 辅助 ──────────────

  Widget _availabilitySection(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return _formSection(context, null, [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('启用站点'),
                const SizedBox(height: 3),
                Text(
                  _available ? '站点正常运行中' : '站点已停用',
                  style: theme.typography.xSmall.copyWith(color: _available ? cs.primary : cs.mutedForeground),
                ),
              ],
            ),
          ),
          shadcn.Switch(value: _available, onChanged: (v) => setState(() => _available = v)),
        ],
      ),
    ]);
  }

  Widget _formSection(BuildContext context, String? title, List<Widget> children) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: theme.typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.background,
            borderRadius: siteRadius(context, size: "md"),
            border: Border.all(color: cs.border, width: 0.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: cs.border),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _formField(String label, TextEditingController controller, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        shadcn.TextField(controller: controller, hintText: hint, maxLines: maxLines),
      ],
    );
  }

  Widget _tagEditor(BuildContext context, List<String> configTags) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final customTags = _selectedTags.where((t) => !configTags.contains(t));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('标签', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (configTags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: configTags.map((tag) {
              final selected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(
                  tag,
                  style: TextStyle(fontSize: 12, color: selected ? siteColors(context).background : null),
                ),
                selected: selected,
                selectedColor: cs.primary,
                onSelected: (value) => setState(() => value ? _selectedTags.add(tag) : _selectedTags.remove(tag)),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: shadcn.TextField(controller: _tagInputCtrl, hintText: '自定义标签'),
            ),
            const SizedBox(width: 8),
            shadcn.Button.outline(onPressed: _addCustomTag, child: const Text('添加')),
          ],
        ),
        if (customTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: customTags
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
    );
  }

  Widget _mirrorEditor(BuildContext context, List<String> configUrls) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final selected = configUrls.contains(_mirrorCtrl.text) ? _mirrorCtrl.text : null;
    final displayText = selected ?? '选择镜像地址';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '镜像',
          style: theme.typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (configUrls.isNotEmpty) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _mirrorOptionsExpanded = !_mirrorOptionsExpanded),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: cs.background,
                borderRadius: siteRadius(context, size: "md"),
                border: Border.all(color: cs.border.withValues(alpha: 0.72), width: 0.6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.small.copyWith(
                        color: selected == null ? cs.mutedForeground : cs.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _mirrorOptionsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(shadcn.LucideIcons.chevronDown, size: 16, color: cs.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
          if (_mirrorOptionsExpanded) ...[
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: cs.background,
                borderRadius: siteRadius(context, size: "md"),
                border: Border.all(color: cs.border.withValues(alpha: 0.62), width: 0.6),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: configUrls.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: cs.border.withValues(alpha: 0.32)),
                itemBuilder: (context, index) {
                  final url = configUrls[index];
                  final active = url == selected;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _mirrorCtrl.text = url;
                      _mirrorOptionsExpanded = false;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      color: active ? cs.primary.withValues(alpha: 0.08) : cs.background,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.small.copyWith(
                                color: active ? cs.primary : cs.foreground,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (active) ...[
                            const SizedBox(width: 8),
                            Icon(shadcn.LucideIcons.check, size: 15, color: cs.primary),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
        shadcn.TextField(controller: _mirrorCtrl, hintText: 'https://mirror.example.com'),
      ],
    );
  }

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

    return _formSection(context, '功能开关', [
      LayoutBuilder(
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
    ]);
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
      if (mounted) closeAppSheet(context);
    } catch (_) {
      // TODO: 错误提示
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
