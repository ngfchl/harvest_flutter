import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';
import 'package:harvest/core/utils/utils.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(activeScrollControllerProvider.notifier).state =
          _scrollController;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
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

    return FScaffold(
      childPad: false,
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          // 筛选面板（桌面端展开时显示）
          if (!mobile && _showFilter) const SiteFilterPanel(),
          // 工具栏统一放顶部
          _buildToolbar(
            context,
            filteredSites.length,
            totalCount,
            hasFilters,
            mobile,
          ),
          CacheStatusBanner(
            info: cacheInfo,
            margin: EdgeInsets.fromLTRB(
              mobile ? 12 : 16,
              0,
              mobile ? 12 : 16,
              6,
            ),
          ),
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
                      padding: EdgeInsets.only(
                        bottom: ShellBottomSpacing.value(context),
                      ),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Center(
                          child: Text(
                            hasFilters ? '没有符合筛选条件的站点' : '暂无站点数据',
                            style: context.theme.typography.sm.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return SiteListView(
                    sites: filteredSites,
                    controller: _scrollController,
                  );
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
    final cs = context.theme.colors;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: ShellBottomSpacing.value(context)),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FProgress.circularIcon(),
              const SizedBox(height: 16),
              Text(
                '加载中...',
                style: TextStyle(color: cs.mutedForeground, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 工具栏 ──

  Widget _buildToolbar(
    BuildContext context,
    int current,
    int total,
    bool hasFilters,
    bool mobile,
  ) {
    final cs = context.theme.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      margin: EdgeInsets.zero,
      height: mobile ? null : 44,
      decoration: BoxDecoration(
        color: mobile ? cs.background : null,
        border: mobile
            ? null
            : Border(
                bottom: BorderSide(
                  color: cs.border.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
        boxShadow: mobile
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ]
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
            mobile
                ? () => _openFilterSheet(context)
                : () => setState(() => _showFilter = !_showFilter),
          ),
          _buildCardStyleMenu(context),
          _buildSiteCreateMenu(context),
        ],
      ),
    );
  }

  // ── 计数 ──

  Widget _buildCounter(
    BuildContext context,
    int current,
    int total,
    bool hasFilters,
  ) {
    final cs = context.theme.colors;
    final typo = context.theme.typography;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$current',
            style: typo.sm.copyWith(
              fontWeight: FontWeight.w700,
              color: hasFilters ? cs.primary : cs.foreground,
            ),
          ),
          TextSpan(
            text: ' / $total',
            style: typo.sm.copyWith(color: cs.mutedForeground),
          ),
        ],
      ),
    );
  }

  // ── 搜索框 ──

  Widget _buildSearchField(BuildContext context, {double height = 38}) {
    final cs = context.theme.colors;
    return SizedBox(
      height: height,
      child: FTextField(
        controller: _searchCtrl,
        hint: '搜索站点...',
        onChange: (v) => ref.read(siteFilterStateProvider).setSiteNameQuery(v),
        prefixBuilder: (ctx, styles, child) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(FIcons.search, size: 14, color: cs.mutedForeground),
        ),
        suffixBuilder: _searchCtrl.text.isNotEmpty
            ? (ctx, styles, child) => GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  ref.read(siteFilterStateProvider).commitSiteNameQuery('');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(FIcons.x, size: 12, color: cs.mutedForeground),
                ),
              )
            : null,
      ),
    );
  }

  // ── 筛选按钮 ──

  Widget _filterButton(
    BuildContext context,
    bool hasFilters,
    VoidCallback onTap,
  ) {
    final cs = context.theme.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 34,
        decoration: BoxDecoration(
          color: hasFilters
              ? cs.primary.withValues(alpha: 0.1)
              : cs.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FIcons.slidersHorizontal,
              size: 14,
              color: hasFilters ? cs.primary : cs.mutedForeground,
            ),
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
    final current = ref.watch(siteCardStyleProvider);
    return FPopoverMenu.tiles(
      style: fPopoverMenuStyle(context, maxWidth: 240).call,
      spacing: FPortalSpacing.zero,
      menuBuilder: (_, controller, _) => [
        FTileGroup(
          children: [
            _cardStyleTile(
              context,
              controller,
              SiteCardStyle.style1,
              current,
              '样式 1',
            ),
            _cardStyleTile(
              context,
              controller,
              SiteCardStyle.style2,
              current,
              '样式 2',
            ),
            _cardStyleTile(
              context,
              controller,
              SiteCardStyle.style3,
              current,
              '样式 3',
            ),
          ],
        ),
      ],
      builder: (_, controller, child) => FButton.icon(
        style: FButtonStyle.ghost(),
        onPress: () => controller.toggle(),
        child: FTooltip(
          longPress: false,
          tipBuilder: (_, __) => const Text('卡片样式'),
          child: const Icon(Icons.dashboard_customize_outlined, size: 18),
        ),
      ),
      child: const SizedBox.shrink(),
    );
  }

  FTile _cardStyleTile(
    BuildContext context,
    FPopoverController controller,
    SiteCardStyle style,
    SiteCardStyle current,
    String title,
  ) {
    final selected = style == current;
    return FTile(
      selected: selected,
      prefix: _cardStylePreview(context, style),
      title: Text(title),
      suffix: selected ? const Icon(FIcons.check, size: 14) : null,
      onPress: () async {
        setSiteCardStyle(ref, style);
        await controller.hide();
      },
    );
  }

  Widget _cardStylePreview(BuildContext context, SiteCardStyle style) {
    final cs = context.theme.colors;
    return SizedBox(
      width: 76,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.brightness == Brightness.dark
              ? cs.muted.withValues(alpha: 0.55)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.border, width: 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: switch (style) {
            SiteCardStyle.style1 => _styleOnePreview(),
            SiteCardStyle.style2 => _styleTwoPreview(),
            SiteCardStyle.style3 => _styleThreePreview(),
          },
        ),
      ),
    );
  }

  Widget _styleOnePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _previewDot(const Color(0xFF22C55E)),
            const SizedBox(width: 4),
            _previewLine(width: 28, color: const Color(0xFF111827), height: 5),
            const Spacer(),
            _previewLine(width: 14, color: const Color(0xFFE8D8FF), height: 6),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _previewLine(width: 14, color: const Color(0xFF16A34A), height: 4),
              _previewLine(width: 14, color: const Color(0xFFEF4444), height: 4),
              _previewLine(width: 14, color: const Color(0xFF64748B), height: 4),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
            (_) => _previewLine(width: 12, color: const Color(0xFF94A3B8), height: 4),
          ),
        ),
      ],
    );
  }

  Widget _styleTwoPreview() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFF17233F),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child: _previewLine(width: 30, color: const Color(0xFF111827), height: 5)),
            _previewLine(width: 13, color: const Color(0xFF94A3B8), height: 4),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(child: _previewLine(width: 18, color: const Color(0xFF16A34A), height: 6)),
            Expanded(child: _previewLine(width: 18, color: const Color(0xFFEF4444), height: 6)),
            Expanded(child: _previewLine(width: 18, color: const Color(0xFF1D6BFF), height: 6)),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            3,
            (_) => _previewLine(width: 15, color: const Color(0xFF64748B), height: 4),
          ),
        ),
      ],
    );
  }

  Widget _styleThreePreview() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF22D983),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child: _previewLine(width: 26, color: const Color(0xFF050914), height: 5)),
            _previewLine(width: 18, color: const Color(0xFFFFF0E1), height: 8),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _previewBox(const Color(0xFFEAF3FF))),
            const SizedBox(width: 4),
            Expanded(child: _previewBox(const Color(0xFFE9F8EF))),
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
                    const Color(0xFFE9F8F1),
                    const Color(0xFFFFF5E4),
                    const Color(0xFFFFEEF7),
                    const Color(0xFFF2ECFF),
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
        borderRadius: BorderRadius.circular(4),
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

  Widget _previewLine({
    required double width,
    required double height,
    required Color color,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }

  // ── 添加按钮 ──

  Widget _buildSiteCreateMenu(BuildContext context) {
    final anchorContext = context;
    return FPopoverMenu.tiles(
      style: fPopoverMenuStyle(context).call,
      spacing: FPortalSpacing.zero,
      menuBuilder: (_, controller, _) => [
        FTileGroup(
          children: [
            FTile(
              prefix: const Icon(FIcons.plus, size: 14),
              title: const Text('添加站点'),
              onPress: () async {
                await controller.hide();
                if (!anchorContext.mounted) return;
                _openAdd(anchorContext);
              },
            ),
            FTile(
              prefix: const Icon(FIcons.fileUp, size: 14),
              title: const Text('上传配置'),
              onPress: () async {
                await controller.hide();
                if (!anchorContext.mounted) return;
                _openImportTomlDialog(anchorContext);
              },
            ),
            FTile(
              prefix: const Icon(FIcons.fileCode, size: 14),
              title: const Text('生成配置'),
              onPress: () async {
                await controller.hide();
                if (!anchorContext.mounted) return;
                showSiteConfigGenerator(anchorContext);
              },
            ),
          ],
        ),
      ],
      builder: (_, controller, child) => FButton.icon(
        style: FButtonStyle.ghost(),
        onPress: () => controller.toggle(),
        child: FTooltip(
          longPress: false,
          tipBuilder: (_, __) => const Text('站点操作'),
          child: const Icon(FIcons.plus, size: 18),
        ),
      ),
      child: const SizedBox.shrink(),
    );
  }

  // ── 移动端筛选弹窗 ──

  void _openFilterSheet(BuildContext context) {
    showFSheet(
      context: context,
      side: FLayout.btt,
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

    showFDialog(
      context: context,
      builder: (ctx, style, animation) => StatefulBuilder(
        builder: (ctx, setDialogState) {
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

            final tomlFiles = result.files
                .where((file) => file.name.toLowerCase().endsWith('.toml'))
                .toList();
            if (tomlFiles.length != result.files.length) {
              Toast.warning('仅支持 TOML 配置文件');
            }
            if (tomlFiles.isEmpty) return;

            AppLogger.info(
              '已选择 TOML 配置文件: ${tomlFiles.map((file) => file.name).join(', ')}',
            );
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
              AppLogger.info(
                '提交上传 TOML 配置文件: count=${files.length}, overwrite=$overwrite',
              );
              await ref
                  .read(siteInfoListProvider.notifier)
                  .importCustomSiteToml(files, overwrite: overwrite);
              if (ctx.mounted) Navigator.of(ctx).pop();
              Toast.success('站点配置已上传');
            } catch (e, st) {
              AppLogger.error('站点配置上传失败', e, st);
              if (ctx.mounted) setDialogState(() => uploading = false);
              Toast.error('站点配置上传失败');
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
            title: const Text('上传站点配置'),
            body: SizedBox(
              width: ctx.isMobile ? MediaQuery.sizeOf(ctx).width - 40 : 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          style: FButtonStyle.outline(),
                          onPress: uploading ? null : selectFiles,
                          child: Text(
                            files.isEmpty ? '选择 TOML 文件' : '重新选择 TOML 文件',
                          ),
                        ),
                      ),
                      if (files.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        FButton(
                          style: FButtonStyle.ghost(),
                          onPress: uploading
                              ? null
                              : () {
                                  AppLogger.info(
                                    '清除全部待上传 TOML 配置文件: count=${files.length}',
                                  );
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
                        setDialogState(
                          () => files = [...files]..removeAt(index),
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  FTileGroup(
                    style: fTileGroupStyle(ctx).call,
                    children: [
                      FTile(
                        title: const Text('覆盖同名配置'),
                        subtitle: Text(overwrite ? '同名文件将被覆盖' : '同名文件保持原样'),
                        suffix: FSwitch(
                          value: overwrite,
                          onChange: uploading
                              ? null
                              : (value) =>
                                    setDialogState(() => overwrite = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          style: FButtonStyle.ghost(),
                          onPress: uploading
                              ? null
                              : () => Navigator.of(ctx).pop(),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FButton(
                          onPress: uploading ? null : upload,
                          child: uploading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: FProgress.circularIcon(),
                                )
                              : Text(
                                  '上传${files.isEmpty ? '' : ' ${files.length} 个'}',
                                ),
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
}

class _TomlUploadEmptyState extends StatelessWidget {
  const _TomlUploadEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final typo = context.theme.typography;

    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FIcons.fileUp, size: 24, color: cs.mutedForeground),
          const SizedBox(height: 8),
          Text(
            '支持多选 .toml 配置文件',
            style: typo.sm.copyWith(color: cs.mutedForeground),
          ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: SingleChildScrollView(
        child: FTileGroup(
          style: fTileGroupStyle(context).call,
          children: [
            for (var i = 0; i < files.length; i++)
              FTile(
                prefix: const Icon(FIcons.fileCode, size: 18),
                title: Text(
                  files[i].name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(formatBytes(files[i].size)),
                suffix: FButton.icon(
                  style: FButtonStyle.ghost(),
                  onPress: () => onRemove(i),
                  child: const Icon(FIcons.x, size: 16),
                ),
              ),
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
    final cs = context.theme.colors;
    final typo = context.theme.typography;

    return Container(
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽条
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.mutedForeground.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

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
                        style: typo.sm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: hasFilters ? cs.primary : cs.foreground,
                        ),
                      ),
                      TextSpan(
                        text: ' / $totalCount',
                        style: typo.sm.copyWith(color: cs.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: FTextField(
                      controller: searchCtrl,
                      // 共用
                      hint: '搜索站点...',
                      onChange: (v) =>
                          ref.read(siteFilterStateProvider).setSiteNameQuery(v),
                      prefixBuilder: (ctx, styles, child) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          FIcons.search,
                          size: 14,
                          color: cs.mutedForeground,
                        ),
                      ),
                      suffixBuilder: searchCtrl.text.isNotEmpty
                          ? (ctx, styles, child) => GestureDetector(
                              onTap: () {
                                searchCtrl.clear();
                                ref
                                    .read(siteFilterStateProvider)
                                    .commitSiteNameQuery('');
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  FIcons.x,
                                  size: 12,
                                  color: cs.mutedForeground,
                                ),
                              ),
                            )
                          : null,
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
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: const SiteFilterPanel(),
            ),
          ),
        ],
      ),
    );
  }
}
