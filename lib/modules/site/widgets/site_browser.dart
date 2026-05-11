import 'package:flutter/material.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/browser_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:url_launcher/url_launcher.dart';

import '../model/site_config.dart';
import '../model/site_info.dart';

class SiteBrowseTarget {
  final String label;
  final String url;
  final IconData icon;

  const SiteBrowseTarget({required this.label, required this.url, required this.icon});
}

List<SiteBrowseTarget> buildSiteBrowseTargets(SiteInfo site, WebSite? website) {
  final baseUrl = site.mirror?.trim() ?? '';
  if (baseUrl.isEmpty) return const [];

  final candidates = <SiteBrowseTarget?>[
    _createBrowseTarget(
      site: site,
      baseUrl: baseUrl,
      label: '首页',
      icon: shadcn.LucideIcons.house,
      rawPath: website?.pageIndex ?? '',
      fallbackToBase: true,
    ),
    _createBrowseTarget(
      site: site,
      baseUrl: baseUrl,
      label: '签到页',
      icon: shadcn.LucideIcons.badgeCheck,
      rawPath: website?.pageSignIn ?? '',
      hideApi: true,
    ),
    _createBrowseTarget(
      site: site,
      baseUrl: baseUrl,
      label: '个人中心',
      icon: shadcn.LucideIcons.userRound,
      rawPath: website?.pageUser ?? '',
      hideApi: true,
      replaceUserId: true,
    ),
    _createBrowseTarget(
      site: site,
      baseUrl: baseUrl,
      label: '消息中心',
      icon: shadcn.LucideIcons.mail,
      rawPath: website?.pageMessage ?? '',
    ),
    _createBrowseTarget(
      site: site,
      baseUrl: baseUrl,
      label: '魔力页面',
      icon: shadcn.LucideIcons.gem,
      rawPath: website?.pageMybonus ?? '',
    ),
  ];

  final used = <String>{};
  final targets = <SiteBrowseTarget>[];
  for (final target in candidates.whereType<SiteBrowseTarget>()) {
    final key = '${target.label}|${target.url}';
    if (used.add(key)) targets.add(target);
  }
  return targets;
}

Future<void> openSiteBrowser(BuildContext context, SiteInfo site) async {
  final url = site.mirror?.trim() ?? '';
  if (url.isEmpty) return;

  if (_isKiswebSite(site)) {
    await openSiteExternalBrowser(site);
    return;
  }

  await openSiteInternalBrowser(context, site);
}

Future<void> openSiteInternalBrowser(BuildContext context, SiteInfo site, {String? url, String? title}) async {
  final targetUrl = (url ?? site.mirror)?.trim() ?? '';
  if (targetUrl.isEmpty) return;

  BrowserPage.open(
    context,
    url: targetUrl,
    title: title ?? (site.nickname.isNotEmpty ? site.nickname : site.site),
    cookie: site.cookie,
    userAgent: site.userAgent,
    siteId: site.site,
  );
}

Future<void> openSiteExternalBrowser(SiteInfo site, {String? url}) async {
  final targetUrl = (url ?? site.mirror)?.trim() ?? '';
  if (targetUrl.isEmpty) return;

  final uri = Uri.tryParse(targetUrl);
  if (uri == null || !uri.hasScheme) {
    Toast.warning('站点地址无效');
    return;
  }
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened) Toast.error('外部浏览器打开失败');
}

SiteBrowseTarget? _createBrowseTarget({
  required SiteInfo site,
  required String baseUrl,
  required String label,
  required IconData icon,
  required String rawPath,
  bool fallbackToBase = false,
  bool hideApi = false,
  bool replaceUserId = false,
}) {
  final url = _resolveBrowseUrl(
    baseUrl: baseUrl,
    rawPath: rawPath,
    userId: replaceUserId ? site.userId?.trim() : null,
    fallbackToBase: fallbackToBase,
    hideApi: hideApi,
  );
  if (url == null) return null;
  return SiteBrowseTarget(label: label, url: url, icon: icon);
}

String? _resolveBrowseUrl({
  required String baseUrl,
  required String rawPath,
  String? userId,
  bool fallbackToBase = false,
  bool hideApi = false,
}) {
  var value = rawPath.trim();
  if (value.isEmpty) return fallbackToBase ? baseUrl : null;
  if (hideApi && value.toLowerCase().contains('api/')) return null;
  if (value.contains('{}')) {
    final id = userId?.trim() ?? '';
    if (id.isEmpty) return null;
    value = value.replaceAll('{}', id);
  }

  final absolute = Uri.tryParse(value);
  if (absolute != null && absolute.hasScheme) return absolute.toString();

  final base = Uri.tryParse(baseUrl);
  if (base == null || !base.hasScheme) return null;
  return base.resolve(value).toString();
}

bool _isKiswebSite(SiteInfo site) {
  final name = site.site.toLowerCase();
  final nickname = site.nickname.toLowerCase();
  final mirror = (site.mirror ?? '').toLowerCase();
  return name.contains('kisweb') || nickname.contains('kisweb') || mirror.contains('kisweb');
}
