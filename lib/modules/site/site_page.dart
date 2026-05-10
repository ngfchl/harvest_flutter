import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../widgets/cache_status_banner.dart';
import '../shell/provider/screenshot_provider.dart';
import '../shell/widgets/shell_scaffold.dart';
import 'provider/site_card_style_provider.dart';
import 'provider/site_filtered_provider.dart';
import 'provider/site_provider.dart';
import 'widgets/site_config_generator_dialog.dart';
import 'widgets/site_error_view.dart';
import 'widgets/site_filter_panel.dart';
import 'widgets/site_form_sheet.dart';
import 'widgets/site_list_view.dart';
import 'widgets/site_theme.dart';

class SitePage extends ConsumerStatefulWidget {
  const SitePage({super.key});

  @override
  ConsumerState<SitePage> createState() => _SitePageState();
}

class _SitePageState extends ConsumerState<SitePage> {
  bool _showFilter = false;
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(activeScrollControllerProvider.notifier).state = _scrollController;
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchTextChanged);
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    ref.read(siteFilterStateProvider).setSiteNameQuery(_searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(siteInfoListProvider);
    final filteredSites = ref.watch(filteredSiteListProvider);
    final filter = ref.watch(siteFilterStateProvider);
    final hasFilters = filter.hasActiveFilters;
    final totalCount = sitesAsync.valueOrNull?.length ?? 0;
    final mobile = context.isMobile;
    final cacheInfo = ref.watch(siteInfoCacheInfoProvider);

    final cs = shadcn.Theme.of(context).colorScheme;

    return Material(
      color: cs.background,
      child: Column(
        children: [
          // 筛选面板（桌面端展开时显示）
          if (!mobile && _showFilter) SiteFilterPanel(onClose: () => setState(() => _showFilter = false)),
          // 工具栏统一放顶部
          _buildToolbar(context, filteredSites.length, totalCount, hasFilters, mobile),
          CacheStatusBanner(info: cacheInfo, margin: EdgeInsets.fromLTRB(mobile ? 12 : 16, 0, mobile ? 12 : 16, 6)),
          Expanded(
            child: EasyRefresh(
              onRefresh: _refresh,
              header: appRefreshHeader(context),
              child: sitesAsync.when(
                loading: () => _buildLoading(context),
                error: (e, _) => SiteErrorView(error: e, onRetry: _refresh),
                data: (_) {
                  if (filteredSites.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: ShellBottomSpacing.value(context)),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Text(
                            hasFilters ? '没有符合筛选条件的站点' : '暂无站点数据',
                            style: shadcn.Theme.of(
                              context,
                            ).typography.small.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
                          ),
                        ),
                      ],
                    );
                  }
                  return SiteListView(sites: filteredSites, controller: _scrollController);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    await ref.read(siteInfoListProvider.notifier).refresh();
  }

  Widget _buildLoading(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: ShellBottomSpacing.value(context)),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              shadcn.CircularProgressIndicator(strokeWidth: 2.4, color: cs.primary),
              const SizedBox(height: 16),
              Text('加载中...', style: TextStyle(color: cs.mutedForeground, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // ── 工具栏 ──

  Widget _buildToolbar(BuildContext context, int current, int total, bool hasFilters, bool mobile) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: mobile ? 8 : 5),
      margin: EdgeInsets.zero,
      height: mobile ? null : 48,
      decoration: BoxDecoration(
        color: mobile ? cs.background : null,
        border: mobile ? null : Border(bottom: BorderSide(color: cs.border.withValues(alpha: 0.4), width: 0.5)),
        boxShadow: mobile
            ? [BoxShadow(color: siteShadow(context, alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))]
            : null,
      ),
      child: Row(
        spacing: mobile ? 6 : 8,
        children: [
          _buildCounter(context, current, total, hasFilters),
          Expanded(child: _buildSearchField(context)),
          _filterButton(
            context,
            hasFilters,
            mobile ? () => _openFilterSheet(context) : () => setState(() => _showFilter = !_showFilter),
          ),
          _buildCardStyleMenu(context),
          _buildSiteCreateMenu(context),
        ],
      ),
    );
  }

  // ── 计数 ──

  Widget _buildCounter(BuildContext context, int current, int total, bool hasFilters) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$current',
            style: typo.small.copyWith(fontWeight: FontWeight.w700, color: hasFilters ? cs.primary : cs.foreground),
          ),
          TextSpan(
            text: ' / $total',
            style: typo.small.copyWith(color: cs.mutedForeground),
          ),
        ],
      ),
    );
  }

  // ── 搜索框 ──

  Widget _buildSearchField(BuildContext context, {double height = 38}) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: shadcn.TextField(
        controller: _searchCtrl,
        hintText: '搜索站点...',
        features: [
          shadcn.InputFeature.clear(
            visibility: shadcn.InputFeatureVisibility.textNotEmpty,
            icon: Icon(shadcn.LucideIcons.x, size: 12, color: cs.mutedForeground),
          ),
        ],
      ),
    );
  }

  // ── 筛选按钮 ──

  Widget _filterButton(BuildContext context, bool hasFilters, VoidCallback onTap) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 34,
        decoration: BoxDecoration(
          color: hasFilters ? cs.primary.withValues(alpha: 0.1) : cs.muted.withValues(alpha: 0.3),
          borderRadius: siteRadius(context, size: "xl"),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(shadcn.LucideIcons.slidersHorizontal, size: 14, color: hasFilters ? cs.primary : cs.mutedForeground),
            const SizedBox(width: 5),
            Text(
              '筛选',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: hasFilters ? cs.primary : cs.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStyleMenu(BuildContext context) {
    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: Builder(
        builder: (menuContext) => shadcn.IconButton.ghost(
          onPressed: () => shadcn.showDropdown<void>(
            context: menuContext,
            alignment: Alignment.topCenter,
            offset: const Offset(0, 8),
            widthConstraint: shadcn.PopoverConstraint.intrinsic,
            heightConstraint: shadcn.PopoverConstraint.intrinsic,
            consumeOutsideTaps: false,
            builder: (dropdownContext) => Consumer(
              builder: (context, ref, _) {
                final current = ref.watch(siteCardStyleProvider);
                return AppDropdownMenu(
                  children: [
                    shadcn.MenuLabel(child: const Text('卡片样式')),
                    const shadcn.MenuDivider(),
                    _cardStyleTile(dropdownContext, SiteCardStyle.style1, current, '样式 1'),
                    _cardStyleTile(dropdownContext, SiteCardStyle.style2, current, '样式 2'),
                    _cardStyleTile(dropdownContext, SiteCardStyle.style3, current, '样式 3'),
                  ],
                );
              },
            ),
          ),
          icon: shadcn.Tooltip(
            tooltip: (_) => const Text('卡片样式'),
            child: const Icon(Icons.dashboard_customize_outlined, size: 18),
          ),
        ),
      ),
    );
  }

  shadcn.MenuButton _cardStyleTile(BuildContext context, SiteCardStyle style, SiteCardStyle current, String title) {
    final selected = style == current;
    final cs = siteColors(context);
    return shadcn.MenuButton(
      onPressed: (_) => setSiteCardStyle(ref, style),
      autoClose: true,
      child: SizedBox(
        width: 232,
        height: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? cs.primary.withValues(alpha: 0.08) : siteTransparent(context),
            borderRadius: siteRadius(context, size: "md"),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _cardStylePreview(context, style),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? cs.foreground : cs.mutedForeground,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: selected ? 1 : 0,
                  child: Icon(shadcn.LucideIcons.check, size: 16, color: cs.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardStylePreview(BuildContext context, SiteCardStyle style) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SizedBox(
      width: 76,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.brightness == Brightness.dark
              ? Color.alphaBlend(cs.muted.withValues(alpha: 0.10), cs.background)
              : siteColors(context).background,
          borderRadius: siteRadius(context, size: "md"),
          border: Border.all(color: cs.border, width: 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: switch (style) {
            SiteCardStyle.style1 => _styleOnePreview(context),
            SiteCardStyle.style2 => _styleTwoPreview(context),
            SiteCardStyle.style3 => _styleThreePreview(context),
          },
        ),
      ),
    );
  }

  Widget _styleOnePreview(BuildContext context) {
    final cs = siteColors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _previewDot(siteSuccess(context)),
            const SizedBox(width: 4),
            _previewLine(width: 28, color: cs.foreground, height: 5),
            const Spacer(),
            _previewLine(width: 14, color: cs.primary.withValues(alpha: 0.18), height: 6),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: cs.muted.withValues(alpha: 0.65),
            borderRadius: siteRadius(context, size: "xs"),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _previewLine(width: 14, color: siteSuccess(context), height: 4),
              _previewLine(width: 14, color: siteDanger(context), height: 4),
              _previewLine(width: 14, color: cs.mutedForeground, height: 4),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
            (_) => _previewLine(width: 12, color: cs.mutedForeground.withValues(alpha: 0.62), height: 4),
          ),
        ),
      ],
    );
  }

  Widget _styleTwoPreview(BuildContext context) {
    final cs = siteColors(context);
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: cs.foreground, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Expanded(child: _previewLine(width: 30, color: cs.foreground, height: 5)),
            _previewLine(width: 13, color: cs.mutedForeground.withValues(alpha: 0.62), height: 4),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(child: _previewLine(width: 18, color: siteSuccess(context), height: 6)),
            Expanded(child: _previewLine(width: 18, color: siteDanger(context), height: 6)),
            Expanded(child: _previewLine(width: 18, color: siteInfo(context), height: 6)),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (_) => _previewLine(width: 15, color: cs.mutedForeground, height: 4)),
        ),
      ],
    );
  }

  Widget _styleThreePreview(BuildContext context) {
    final cs = siteColors(context);
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: siteSuccess(context),
                borderRadius: siteRadius(context, size: "xs"),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child: _previewLine(width: 26, color: cs.foreground, height: 5)),
            _previewLine(width: 18, color: siteWarning(context, alpha: 0.18), height: 8),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _previewBox(siteInfo(context, alpha: 0.16))),
            const SizedBox(width: 4),
            Expanded(child: _previewBox(siteSuccess(context, alpha: 0.14))),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 3 ? 0 : 3),
                child: _previewBox(
                  [
                    siteSuccess(context, alpha: 0.14),
                    siteWarning(context, alpha: 0.16),
                    siteDanger(context, alpha: 0.12),
                    siteInfo(context, alpha: 0.14),
                  ][i],
                  height: 8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewBox(Color color, {double height = 11}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: siteRadius(context, size: "xs"),
      ),
    );
  }

  Widget _previewDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _previewLine({required double width, required double height, required Color color}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: siteRadius(context, size: "xl"),
        ),
      ),
    );
  }

  // ── 添加按钮 ──

  Widget _buildSiteCreateMenu(BuildContext context) {
    final anchorContext = context;
    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: Builder(
        builder: (menuContext) => shadcn.IconButton.ghost(
          onPressed: () => shadcn.showDropdown<void>(
            context: menuContext,
            builder: (_) => AppDropdownMenu(
              children: [
                _menuAction(
                  icon: shadcn.LucideIcons.plus,
                  label: '添加站点',
                  onPressed: () {
                    if (!anchorContext.mounted) return;
                    _openAdd(anchorContext);
                  },
                ),
                _menuAction(
                  icon: shadcn.LucideIcons.fileUp,
                  label: '上传配置',
                  onPressed: () {
                    if (!anchorContext.mounted) return;
                    _openImportTomlDialog(anchorContext);
                  },
                ),
                _menuAction(
                  icon: shadcn.LucideIcons.fileCode,
                  label: '生成配置',
                  onPressed: () {
                    if (!anchorContext.mounted) return;
                    showSiteConfigGenerator(anchorContext);
                  },
                ),
              ],
            ),
          ),
          icon: shadcn.Tooltip(
            tooltip: (_) => const Text('站点操作'),
            child: const Icon(shadcn.LucideIcons.plus, size: 18),
          ),
        ),
      ),
    );
  }

  shadcn.MenuButton _menuAction({required IconData icon, required String label, required VoidCallback onPressed}) {
    return shadcn.MenuButton(leading: Icon(icon), onPressed: (_) => onPressed(), child: Text(label));
  }

  // ── 移动端筛选弹窗 ──

  void _openFilterSheet(BuildContext context) {
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (_) => _MobileFilterSheet(searchCtrl: _searchCtrl),
    );
  }

  // ── 添加站点 ──

  void _openAdd(BuildContext context) {
    showAddSiteSheet(context);
  }

  void _openImportTomlDialog(BuildContext context) {
    var files = <PlatformFile>[];
    var uploading = false;
    var overwrite = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = shadcn.Theme.of(ctx);
          final cs = theme.colorScheme;

          Future<void> selectFiles() async {
            FilePickerResult? result;
            try {
              result = await FilePicker.pickFiles(
                allowMultiple: true,
                type: FileType.custom,
                allowedExtensions: const ['toml'],
                withData: true,
              );
            } on PlatformException catch (e) {
              AppLogger.error('选择 TOML 配置文件失败', e);
              if (e.code == 'ENTITLEMENT_NOT_FOUND') {
                Toast.error('缺少文件读取权限，请重启应用后重试');
              } else {
                Toast.error('选择文件失败: ${e.message ?? e.code}');
              }
              return;
            } catch (e, st) {
              AppLogger.error('选择 TOML 配置文件失败', e, st);
              Toast.error('选择文件失败');
              return;
            }
            if (result == null) return;
            if (!ctx.mounted) return;

            final tomlFiles = result.files.where((file) => file.name.toLowerCase().endsWith('.toml')).toList();
            if (tomlFiles.length != result.files.length) {
              Toast.warning('仅支持 TOML 配置文件');
            }
            if (tomlFiles.isEmpty) return;

            AppLogger.info('已选择 TOML 配置文件: ${tomlFiles.map((file) => file.name).join(', ')}');
            setDialogState(() => files = tomlFiles);
          }

          Future<void> upload() async {
            if (files.isEmpty) {
              Toast.warning('请选择 TOML 配置文件');
              return;
            }
            if (files.any((file) => file.path == null && file.bytes == null)) {
              Toast.error('无法读取所选文件');
              return;
            }

            setDialogState(() => uploading = true);
            try {
              AppLogger.info('提交上传 TOML 配置文件: count=${files.length}, overwrite=$overwrite');
              await ref.read(siteInfoListProvider.notifier).importCustomSiteToml(files, overwrite: overwrite);
              if (ctx.mounted) closeAppSheet(ctx);
              Toast.success('站点配置已上传');
            } catch (e, st) {
              AppLogger.error('站点配置上传失败', e, st);
              if (ctx.mounted) setDialogState(() => uploading = false);
              Toast.error('站点配置上传失败');
            }
          }

          return shadcn.AlertDialog(
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ctx.isMobile ? MediaQuery.sizeOf(ctx).width - 40 : 460),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '上传站点配置',
                      style: theme.typography.large.copyWith(color: cs.foreground, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: shadcn.Button.outline(
                            onPressed: uploading ? null : selectFiles,
                            child: Text(files.isEmpty ? '选择 TOML 文件' : '重新选择 TOML 文件'),
                          ),
                        ),
                        if (files.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          shadcn.Button.ghost(
                            onPressed: uploading
                                ? null
                                : () {
                                    AppLogger.info('清除全部待上传 TOML 配置文件: count=${files.length}');
                                    setDialogState(() => files = []);
                                  },
                            child: const Text('一键清除'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (files.isEmpty)
                      const _TomlUploadEmptyState()
                    else
                      _TomlFileList(
                        files: files,
                        onRemove: (index) {
                          AppLogger.info('移除待上传 TOML 配置文件: ${files[index].name}');
                          setDialogState(() => files = [...files]..removeAt(index));
                        },
                      ),
                    const SizedBox(height: 12),
                    _OverwriteOption(
                      overwrite: overwrite,
                      enabled: !uploading,
                      onChanged: (value) => setDialogState(() => overwrite = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: shadcn.Button.ghost(
                            onPressed: uploading ? null : () => closeAppSheet(ctx),
                            child: const Text('取消'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: shadcn.Button.primary(
                            onPressed: uploading ? null : upload,
                            child: uploading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: shadcn.CircularProgressIndicator(strokeWidth: 2.2),
                                  )
                                : Text('上传${files.isEmpty ? '' : ' ${files.length} 个'}'),
                          ),
                        ),
                      ],
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
}

class _OverwriteOption extends StatelessWidget {
  final bool overwrite;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _OverwriteOption({required this.overwrite, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.28),
        borderRadius: siteRadius(context, size: "md"),
        border: Border.all(color: cs.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '覆盖同名配置',
                  style: theme.typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  overwrite ? '同名文件将被覆盖' : '同名文件保持原样',
                  style: theme.typography.xSmall.copyWith(color: cs.mutedForeground),
                ),
              ],
            ),
          ),
          shadcn.Switch(value: overwrite, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _TomlUploadEmptyState extends StatelessWidget {
  const _TomlUploadEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;

    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.35),
        borderRadius: siteRadius(context, size: "md"),
        border: Border.all(color: cs.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(shadcn.LucideIcons.fileUp, size: 24, color: cs.mutedForeground),
          const SizedBox(height: 8),
          Text('支持多选 .toml 配置文件', style: typo.small.copyWith(color: cs.mutedForeground)),
        ],
      ),
    );
  }
}

class _TomlFileList extends StatelessWidget {
  final List<PlatformFile> files;
  final ValueChanged<int> onRemove;

  const _TomlFileList({required this.files, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < files.length; i++) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.muted.withValues(alpha: 0.24),
                  borderRadius: siteRadius(context, size: "md"),
                  border: Border.all(color: cs.border.withValues(alpha: 0.65)),
                ),
                child: Row(
                  children: [
                    Icon(shadcn.LucideIcons.fileCode, size: 18, color: cs.mutedForeground),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            files[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatBytes(files[i].size),
                            style: theme.typography.xSmall.copyWith(color: cs.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    shadcn.IconButton.ghost(
                      onPressed: () => onRemove(i),
                      icon: const Icon(shadcn.LucideIcons.x, size: 16),
                    ),
                  ],
                ),
              ),
              if (i != files.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _MobileFilterSheet extends ConsumerWidget {
  final TextEditingController searchCtrl;

  const _MobileFilterSheet({required this.searchCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsync = ref.watch(siteInfoListProvider);
    final filteredSites = ref.watch(filteredSiteListProvider);
    final filter = ref.watch(siteFilterStateProvider);
    final hasFilters = filter.hasActiveFilters;
    final totalCount = sitesAsync.valueOrNull?.length ?? 0;
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final media = MediaQuery.of(context);
    final maxSheetHeight = (media.size.height - media.padding.top - media.viewInsets.bottom) * 0.72;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: Container(
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xl").topLeft),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 搜索 + 计数
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${filteredSites.length}',
                          style: typo.small.copyWith(
                            fontWeight: FontWeight.w700,
                            color: hasFilters ? cs.primary : cs.foreground,
                          ),
                        ),
                        TextSpan(
                          text: ' / $totalCount',
                          style: typo.small.copyWith(color: cs.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: shadcn.TextField(
                        controller: searchCtrl,
                        // 共用
                        hintText: '搜索站点...',
                        features: [
                          shadcn.InputFeature.clear(
                            visibility: shadcn.InputFeatureVisibility.textNotEmpty,
                            icon: Icon(shadcn.LucideIcons.x, size: 12, color: cs.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 筛选面板（可滚动）
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: media.padding.bottom + 16),
                child: const SiteFilterPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
