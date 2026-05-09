import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:harvest/widgets/browser_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:url_launcher/url_launcher.dart';

import '../model/site_info.dart';
import '../provider/site_provider.dart';
import 'site_detail_sheet.dart';
import 'site_form_sheet.dart';
import 'site_theme.dart';

class SiteActionMenu extends ConsumerWidget {
  final SiteInfo site;
  final Widget child;

  const SiteActionMenu({super.key, required this.site, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshing = ref.watch(
      siteRefreshingIdsProvider.select((ids) => ids.contains(site.id)),
    );
    final content = Stack(
      children: [child, if (refreshing) const _SiteCardLoadingOverlay()],
    );

    return AppContextMenu(
      enabled: !refreshing,
      behavior: HitTestBehavior.opaque,
      openOnTap: context.isMobile,
      items: _buildActionItems(context, ref, site),
      child: content,
    );
  }
}

class _SiteCardLoadingOverlay extends StatelessWidget {
  const _SiteCardLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: siteRadius(context, size: "xl"),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.background.withValues(alpha: 0.72),
          ),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: shadcn.CircularProgressIndicator(
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

List<shadcn.MenuItem> _buildActionItems(
  BuildContext context,
  WidgetRef ref,
  SiteInfo site,
) {
  final cs = shadcn.Theme.of(context).colorScheme;
  final disabled = !site.available;
  final alreadySigned = site.signInText == '已签到';
  final hasMirror = site.mirror != null && site.mirror!.isNotEmpty;

  // 已禁用站点：只显示查看详情、浏览器、编辑、删除
  if (disabled) {
    return [
      _menuItem(
        icon: shadcn.LucideIcons.eye,
        label: '查看详情',
        onPressed: () {
          if (!context.mounted) return;
          openDetail(context, site);
        },
      ),
      _menuItem(
        icon: shadcn.LucideIcons.pencil,
        label: '编辑',
        onPressed: () {
          if (!context.mounted) return;
          showSiteForm(context, site: site);
        },
      ),
      if (hasMirror)
        _menuItem(
          icon: shadcn.LucideIcons.globe,
          label: '浏览',
          onPressed: () {
            if (!context.mounted) return;
            openSiteBrowser(context, site);
          },
        ),
      const shadcn.MenuDivider(),
      _menuItem(
        icon: shadcn.LucideIcons.trash2,
        label: '删除',
        color: cs.destructive,
        onPressed: () {
          if (!context.mounted) return;
          _confirmDelete(context, ref, site);
        },
      ),
    ];
  }

  // 正常站点
  return [
    _menuItem(
      icon: shadcn.LucideIcons.eye,
      label: '详情',
      onPressed: () {
        if (!context.mounted) return;
        openDetail(context, site);
      },
    ),
    _menuItem(
      icon: shadcn.LucideIcons.pencil,
      label: '编辑',
      onPressed: () {
        if (!context.mounted) return;
        showSiteForm(context, site: site);
      },
    ),
    const shadcn.MenuDivider(),
    _menuItem(
      icon: shadcn.LucideIcons.refreshCw,
      label: '刷新',
      onPressed: () async {
        final notifier = ref.read(siteInfoListProvider.notifier);
        final message = await notifier.refreshStatus(site.id);
        Toast.success(message);
      },
    ),
    // 未签到才显示签到按钮
    if (!alreadySigned)
      _menuItem(
        icon: shadcn.LucideIcons.check,
        label: '签到',
        onPressed: () async {
          final notifier = ref.read(siteInfoListProvider.notifier);
          final message = await notifier.signIn(site.id);
          Toast.success(message);
        },
      ),
    _menuItem(
      icon: shadcn.LucideIcons.copy,
      label: '辅种',
      onPressed: () async {
        final notifier = ref.read(siteInfoListProvider.notifier);
        await notifier.repeat(site.id);
      },
    ),
    if (hasMirror)
      _menuItem(
        icon: shadcn.LucideIcons.globe,
        label: '浏览',
        onPressed: () {
          if (!context.mounted) return;
          openSiteBrowser(context, site);
        },
      ),
    const shadcn.MenuDivider(),
    _menuItem(
      icon: shadcn.LucideIcons.trash2,
      label: '删除',
      color: cs.destructive,
      onPressed: () {
        if (!context.mounted) return;
        _confirmDelete(context, ref, site);
      },
    ),
  ];
}

Future<void> showSiteActionMenu({
  required BuildContext context,
  required WidgetRef ref,
  required SiteInfo site,
  required Offset position,
}) {
  return appShowContextMenu(
    context: context,
    position: position,
    items: _buildActionItems(context, ref, site),
  );
}

bool _isKiswebSite(SiteInfo site) {
  final name = site.site.toLowerCase();
  final nickname = site.nickname.toLowerCase();
  final mirror = (site.mirror ?? '').toLowerCase();
  return name.contains('kisweb') ||
      nickname.contains('kisweb') ||
      mirror.contains('kisweb');
}

Future<void> openSiteBrowser(BuildContext context, SiteInfo site) async {
  final url = site.mirror?.trim() ?? '';
  if (url.isEmpty) return;

  if (_isKiswebSite(site)) {
    await openSiteExternalBrowser(site);
    return;
  }

  BrowserPage.open(
    context,
    url: url,
    title: site.nickname.isNotEmpty ? site.nickname : site.site,
    cookie: site.cookie,
    userAgent: site.userAgent,
  );
}

Future<void> openSiteExternalBrowser(SiteInfo site) async {
  final url = site.mirror?.trim() ?? '';
  if (url.isEmpty) return;

  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) {
    Toast.warning('站点地址无效');
    return;
  }
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened) Toast.error('外部浏览器打开失败');
}

shadcn.MenuButton _menuItem({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
  Color? color,
}) {
  final style = color == null ? null : TextStyle(color: color);
  return shadcn.MenuButton(
    leading: Icon(icon, color: color),
    onPressed: (_) => onPressed(),
    child: Text(label, style: style),
  );
}

// ═══════════════════════════════════════════════════
//  删除确认
// ═══════════════════════════════════════════════════

void _confirmDelete(BuildContext context, WidgetRef ref, SiteInfo site) {
  final notifier = ref.read(siteInfoListProvider.notifier);

  shadcn.showDialog(
    context: context,
    builder: (ctx) => shadcn.AlertDialog(
      title: const Text('确认删除'),
      content: Text('确定要删除站点「${site.site}」吗？'),
      actions: [
        shadcn.Button.outline(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        shadcn.Button.destructive(
          onPressed: () async {
            Navigator.pop(ctx);
            await notifier.delete(site.id);
          },
          child: const Text('删除'),
        ),
      ],
    ),
  );
}
