import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/browser_page.dart';

import '../model/site_info.dart';
import '../provider/site_provider.dart';
import 'site_detail_sheet.dart';
import 'site_form_sheet.dart';

class SiteActionMenu extends ConsumerWidget {
  final SiteInfo site;
  final Widget child;

  const SiteActionMenu({super.key, required this.site, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchorContext = context;
    final refreshing = ref.watch(
      siteRefreshingIdsProvider.select((ids) => ids.contains(site.id)),
    );

    return FPopoverMenu.tiles(
      style: fPopoverMenuStyle(context).call,
      spacing: FPortalSpacing.zero,
      menuBuilder: (_, controller, _) =>
          _buildActionGroups(anchorContext, site, controller),
      builder: (_, controller, menuChild) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: refreshing ? null : () => controller.toggle(),
        onSecondaryTap: refreshing ? null : () => controller.toggle(),
        child: menuChild!,
      ),
      child: Stack(
        children: [
          child,
          if (refreshing) const _SiteCardLoadingOverlay(),
        ],
      ),
    );
  }
}

class _SiteCardLoadingOverlay extends StatelessWidget {
  const _SiteCardLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.background.withValues(alpha: 0.72),
          ),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: cs.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  操作列表
// ═══════════════════════════════════════════════════

List<FTileGroupMixin> _buildActionGroups(
  BuildContext context,
  SiteInfo site,
  FPopoverController controller,
) {
  final disabled = !site.available;
  final alreadySigned = site.signInText == '已签到';
  final hasMirror = site.mirror != null && site.mirror!.isNotEmpty;

  // 已禁用站点：只显示查看详情、浏览器、编辑、删除
  if (disabled) {
    return [
      FTileGroup(
        children: [
          FTile(
            prefix: const Icon(FIcons.eye, size: 14),
            title: const Text('查看详情'),
            onPress: () async {
              await controller.hide();
              if (!context.mounted) return;
              openDetail(context, site);
            },
          ),

          FTile(
            prefix: const Icon(FIcons.pencil, size: 14),
            title: const Text('编辑'),
            onPress: () async {
              await controller.hide();
              if (!context.mounted) return;
              showSiteForm(context, site: site);
            },
          ),
          if (hasMirror)
            FTile(
              prefix: const Icon(FIcons.globe, size: 14),
              title: const Text('浏览'),
              onPress: () async {
                await controller.hide();
                if (!context.mounted) return;
                BrowserPage.open(
                  context,
                  url: site.mirror!,
                  title: site.nickname,
                  cookie: site.cookie,
                  userAgent: site.userAgent,
                );
              },
            ),
          FTile(
            prefix: Icon(
              FIcons.trash2,
              size: 14,
              color: context.theme.colors.destructive,
            ),
            title: Text(
              '删除',
              style: TextStyle(color: context.theme.colors.destructive),
            ),
            onPress: () async {
              await controller.hide();
              if (!context.mounted) return;
              _confirmDelete(context, site);
            },
          ),
        ],
      ),
    ];
  }

  // 正常站点
  return [
    FTileGroup(
      children: [
        FTile(
          prefix: const Icon(FIcons.eye, size: 14),
          title: const Text('详情'),
          onPress: () async {
            await controller.hide();
            if (!context.mounted) return;
            openDetail(context, site);
          },
        ),

        FTile(
          prefix: const Icon(FIcons.pencil, size: 14),
          title: const Text('编辑'),
          onPress: () async {
            await controller.hide();
            if (!context.mounted) return;
            showSiteForm(context, site: site);
          },
        ),
        FTile(
          prefix: const Icon(FIcons.refreshCw, size: 14),
          title: const Text('刷新'),
          onPress: () async {
            final notifier = ProviderScope.containerOf(
              context,
            ).read(siteInfoListProvider.notifier);
            await controller.hide();
            final message = await notifier.refreshStatus(site.id);
            Toast.success(message);
          },
        ),
        // 未签到才显示签到按钮
        if (!alreadySigned)
          FTile(
            prefix: const Icon(FIcons.check, size: 14),
            title: const Text('签到'),
            onPress: () async {
              final notifier = ProviderScope.containerOf(
                context,
              ).read(siteInfoListProvider.notifier);
              await controller.hide();
              final message = await notifier.signIn(site.id);
              Toast.success(message);
            },
          ),
        FTile(
          prefix: const Icon(FIcons.copy, size: 14),
          title: const Text('辅种'),
          onPress: () async {
            final notifier = ProviderScope.containerOf(
              context,
            ).read(siteInfoListProvider.notifier);
            await controller.hide();
            await notifier.repeat(site.id);
          },
        ),
        if (hasMirror)
          FTile(
            prefix: const Icon(FIcons.globe, size: 14),
            title: const Text('浏览'),
            onPress: () async {
              await controller.hide();
              if (!context.mounted) return;
              BrowserPage.open(
                context,
                url: site.mirror!,
                title: site.nickname,
                cookie: site.cookie,
                userAgent: site.userAgent,
              );
            },
          ),
        FTile(
          prefix: Icon(
            FIcons.trash2,
            size: 14,
            color: context.theme.colors.destructive,
          ),
          title: Text(
            '删除',
            style: TextStyle(color: context.theme.colors.destructive),
          ),
          onPress: () async {
            await controller.hide();
            if (!context.mounted) return;
            _confirmDelete(context, site);
          },
        ),
      ],
    ),
  ];
}

// ═══════════════════════════════════════════════════
//  删除确认
// ═══════════════════════════════════════════════════

void _confirmDelete(BuildContext context, SiteInfo site) {
  final notifier = ProviderScope.containerOf(
    context,
  ).read(siteInfoListProvider.notifier);

  showDialog(
    context: context,
    builder: (ctx) => FDialog(
      title: const Text('确认删除'),
      body: Text('确定要删除站点「${site.site}」吗？'),
      actions: [
        FButton(
          style: FButtonStyle.outline(),
          onPress: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        FButton(
          style: FButtonStyle.destructive(),
          onPress: () async {
            Navigator.pop(ctx);
            await notifier.delete(site.id);
          },
          child: const Text('删除'),
        ),
      ],
    ),
  );
}
