import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/types/gf_typography_type.dart';
import 'package:harvest/app/home/pages/models/website.dart';
import 'package:harvest/app/home/pages/my_site/controller.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/utils/calc_weeks.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/home/pages/models/my_site.dart';
import '../app/routes/app_pages.dart';
import '../utils/country.dart';
import '../utils/logger_helper.dart';
import '../utils/string_utils.dart';

class SiteMap extends StatelessWidget {
  final Widget child;

  const SiteMap({super.key, this.child = const Icon(Icons.map, size: 20)});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MySiteController>(builder: (controller) {
      return InkWell(
        child: child,
        onTap: () {
          RxString sortKey = RxString('mySiteJoined');
          // controller.mySiteList
          //     .sort((a, b) => a.timeJoin.compareTo(b.timeJoin));
          Map<String, MySite> mySiteMap = controller.mySiteList.asMap().map(
                (index, mySite) => MapEntry(mySite.site, mySite),
              );
          // 获取已存在的站点名称列表
          // List<String> hasKeys = controller.mySiteList.map((element) => element.site).toList();
          // 筛选活着的且未添加过的站点，并进行排序
          RxList<WebSite> webSiteList = controller.webSiteList.values
              .where((item) => item.alive && item.type.toLowerCase() == 'pt')
              .toList()
              .obs
            ..sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          Get.bottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              isScrollControlled: true,
              enableDrag: true,
              CustomCard(
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: GFTypography(
                              text: '站点图谱',
                              type: GFTypographyType.typo3,
                              textColor: Theme.of(context).colorScheme.primary,
                              dividerColor:
                                  Theme.of(context).colorScheme.primary,
                              dividerWidth: 75,
                            ),
                          ),
                          // Obx(() {
                          //   return DropdownButton(
                          //     isDense: true,
                          //     value: sortKey.value,
                          //     items: [
                          //       {'name': '站点名称', 'value': 'siteName'},
                          //       {'name': '注册时间', 'value': 'mySiteJoined'},
                          //       {'name': '做种体积', 'value': 'statusSeedVolume'}
                          //     ]
                          //         .map((item) => MetaDataItem.fromJson(item))
                          //         .map((el) => DropdownMenuItem(
                          //             value: el.value,
                          //             child: Text(
                          //                 style: const TextStyle(
                          //                   fontSize: 14,
                          //                 ),
                          //                 el.name)))
                          //         .toList(),
                          //     onChanged: (Object? value) {
                          //       webSiteList.sort((a, b) => a.name
                          //           .toLowerCase()
                          //           .compareTo(b.name.toLowerCase()));
                          //     },
                          //   );
                          // })
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        return Timeline.tileBuilder(
                          builder: TimelineTileBuilder.fromStyle(
                            itemCount: webSiteList.length,
                            contentsAlign: ContentsAlign.alternating,
                            contentsBuilder: (context, int index) {
                              WebSite webSite = webSiteList[index];
                              MySite? mySite = mySiteMap[webSite.name];
                              StatusInfo? status;
                              if (mySite?.statusInfo.isNotEmpty == true) {
                                status = mySite?.latestStatusInfo;
                              }
                              bool flag = index % 2 != 0;
                              String country =
                                  getFlagEmojiFromCountryName(webSite.nation);
                              return TimelineNode(
                                indicator: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ListTile(
                                      dense: true,
                                      title: Row(
                                        mainAxisAlignment: flag
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            country,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                          Text(
                                            mySite?.nickname ?? webSite.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Align(
                                        alignment: flag
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          '[${webSite.tags}]',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        Get.defaultDialog(
                                            title: '请选择网址',
                                            radius: 5,
                                            content: SingleChildScrollView(
                                                child: Column(
                                              children: webSite.url
                                                  .map((u) => ListTile(
                                                        dense: true,
                                                        title: Text(u),
                                                        onTap: () async {
                                                          Get.back();
                                                          if (u.contains(
                                                              'm-team')) {
                                                            u = u.replaceFirst(
                                                                "api", "xp");
                                                          }
                                                          if (kIsWeb ||
                                                              !controller
                                                                  .openByInnerExplorer) {
                                                            Logger.instance
                                                                .d('使用外部浏览器打开');
                                                            Uri uri =
                                                                Uri.parse(u);
                                                            if (!await launchUrl(
                                                                uri,
                                                                mode: LaunchMode
                                                                    .externalApplication)) {
                                                              Get.snackbar(
                                                                  '打开网页出错',
                                                                  '打开网页出错，不支持的客户端？',
                                                                  colorText: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary);
                                                            }
                                                          } else {
                                                            Logger.instance
                                                                .d('使用内置浏览器打开');
                                                            Get.toNamed(
                                                                Routes.WEBVIEW,
                                                                arguments: {
                                                                  'url': u,
                                                                  'info': null,
                                                                  'mySite':
                                                                      mySite,
                                                                  'website':
                                                                      webSite
                                                                });
                                                          }
                                                        },
                                                      ))
                                                  .toList(),
                                            )));
                                      },
                                      trailing: !flag
                                          ? null
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl: webSite.logo
                                                        .startsWith('http')
                                                    ? webSite.logo
                                                    : '${mySite?.mirror}${webSite.logo}',
                                                fit: BoxFit.fill,
                                                httpHeaders: {
                                                  "user-agent":
                                                      mySite?.userAgent ?? '',
                                                  "Cookie":
                                                      mySite?.cookie ?? '',
                                                },
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const Image(
                                                        image: AssetImage(
                                                            'assets/images/avatar.png')),
                                                width: 32,
                                                height: 32,
                                              ),
                                            ),
                                      leading: flag
                                          ? null
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl: webSite.logo
                                                        .startsWith('http')
                                                    ? webSite.logo
                                                    : '${mySite?.mirror}${webSite.logo}',
                                                fit: BoxFit.fill,
                                                httpHeaders: {
                                                  "user-agent":
                                                      mySite?.userAgent ?? '',
                                                  "Cookie":
                                                      mySite?.cookie ?? '',
                                                },
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const Image(
                                                        image: AssetImage(
                                                            'assets/images/avatar.png')),
                                                width: 32,
                                                height: 32,
                                              ),
                                            ),
                                    ),
                                    if (mySite != null)
                                      Column(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            calcWeeksDays(mySite.timeJoin),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                          Text(
                                            '[${status?.myLevel}]',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          Text(
                                            '↑${FileSizeConvert.parseToFileSize(status?.uploaded ?? 0)} (${status?.seed ?? 0})',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          Text(
                                            '↓${FileSizeConvert.parseToFileSize(status?.downloaded ?? 0)} (${status?.leech ?? 0})',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          Text(
                                            '☁︎${FileSizeConvert.parseToFileSize(status?.seedVolume ?? 0)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ));
        },
      );
    });
  }
}
