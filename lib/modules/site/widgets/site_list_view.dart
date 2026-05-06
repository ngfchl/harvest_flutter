import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/shell/widgets/shell_scaffold.dart';

import '../model/site_info.dart';
import '../provider/site_card_style_provider.dart';
import '../provider/site_provider.dart';
import 'site_card.dart';

class SiteListView extends ConsumerWidget {
  final List<SiteInfo> sites;
  final ScrollController? controller;

  const SiteListView({super.key, required this.sites, this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobile = context.isMobile;
    final cardStyle = ref.watch(siteCardStyleProvider);

    return EasyRefresh(
      onRefresh: () => ref.read(siteInfoListProvider.notifier).refresh(),
      header: appRefreshHeader(context),
      child: mobile
          ? _buildList(context, sites)
          : _buildGrid(context, sites, cardStyle),
    );
  }

  Widget _buildList(BuildContext context, List<SiteInfo> sites) =>
      ListView.separated(
        controller: controller,
        padding: EdgeInsets.fromLTRB(
          8,
          4,
          8,
          16 + ShellBottomSpacing.value(context),
        ),
        itemCount: sites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => SiteCard(site: sites[i]),
      );

  Widget _buildGrid(
    BuildContext context,
    List<SiteInfo> sites,
    SiteCardStyle cardStyle,
  ) =>
      LayoutBuilder(
        builder: (context, c) {
          final cols = (c.maxWidth / 360).floor().clamp(2, 5);
          return GridView.builder(
            controller: controller,
            padding: EdgeInsets.fromLTRB(
              8,
              8,
              8,
              16 + ShellBottomSpacing.value(context),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: switch (cardStyle) {
                SiteCardStyle.style1 => 160,
                SiteCardStyle.style2 => 214,
                SiteCardStyle.style3 => 374,
              },
            ),
            itemCount: sites.length,
            itemBuilder: (_, i) => SiteCard(site: sites[i]),
          );
        },
      );
}
