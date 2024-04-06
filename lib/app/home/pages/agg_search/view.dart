import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/app/home/pages/agg_search/models/torrent_info.dart';
import 'package:harvest/app/home/pages/models/website.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/logger_helper.dart';
import '../../../routes/app_pages.dart';
import '../models/my_site.dart';
import 'controller.dart';

class AggSearchPage extends StatefulWidget {
  const AggSearchPage({super.key});

  @override
  State<AggSearchPage> createState() => _AggSearchPageState();
}

class _AggSearchPageState extends State<AggSearchPage>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.put(AggSearchController());

  TextEditingController searchKeyController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<AggSearchController>(
      assignId: true,
      builder: (controller) {
        int succeedCount = 0;
        int failedCount = 0;
        succeedCount =
            controller.searchMsg.where((element) => element['success']).length;
        failedCount =
            controller.searchMsg.where((element) => !element['success']).length;
        // controller.update();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchKeyController,
                      decoration: const InputDecoration(
                        hintText: '请输入搜索关键字',
                      ),
                      onSubmitted: (value) {
                        controller.searchKey.value = value;
                        controller.doSearch();
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // 在这里执行搜索操作
                      if (controller.isLoading.value) {
                        await controller.cancelSearch();
                      } else {
                        controller.searchKey.value = searchKeyController.text;
                        controller.doSearch();
                      }
                    },
                    autofocus: true,
                    icon: controller.isLoading.value
                        ? const GFLoader()
                        : const Icon(Icons.search),
                    label: controller.isLoading.value
                        ? const Text('取消')
                        : const Text('搜索'),
                  ),
                ],
              ),
            ),
            if (controller.searchMsg.isNotEmpty)
              GFAccordion(
                titleChild: Text(
                  '搜索结果：$succeedCount个站点共${controller.searchResults.length}个种子，失败$failedCount个站点',
                ),
                titlePadding: EdgeInsets.zero,
                contentChild: SizedBox(
                  height: 100,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.searchMsg.length,
                          itemBuilder: (BuildContext context, int index) {
                            String info = controller.searchMsg[index]['msg'];
                            return Text(info);
                          },
                        ),
                      ),
                      // if (controller.errSearchResults.isNotEmpty)
                      //   Expanded(
                      //     child: ListView.builder(
                      //       itemCount: controller.errSearchResults.length,
                      //       itemBuilder: (BuildContext context, int index) {
                      //         String info = controller.errSearchResults[index];
                      //         return Text(info);
                      //       },
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  TorrentInfo info = controller.searchResults[index];
                  return showTorrentInfo(info);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    Get.delete<AggSearchController>();
    super.dispose();
  }

  Widget showTorrentInfo(TorrentInfo info) {
    WebSite? website = controller.mySiteController.webSiteList[info.siteId];
    MySite? mySite = controller.mySiteMap[info.siteId];
    if (website == null || mySite == null) {
      Logger.instance.w('显示出错啦: ${info.siteId} -  $mySite - $website');
      return const SizedBox.shrink();
    }
    return Card(
      child: Column(
        children: [
          GFListTile(
            padding: EdgeInsets.zero,
            avatar: GFAvatar(
              backgroundImage: Image.network(
                website.logo.startsWith("http")
                    ? website.logo
                    : '${mySite.mirror}${website.logo}',
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  // Placeholder widget when loading fails
                  return const Image(
                      image: AssetImage('assets/images/logo.png'));
                },
                fit: BoxFit.fitHeight,
              ).image,
              shape: GFAvatarShape.standard,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: SizedBox(),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: Colors.teal.withOpacity(0.7),
                        margin: null,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3.0, bottom: 0),
                            child: Text(website.name.toString(),
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis)),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
            // icon: GFAvatar(
            //   shape: GFAvatarShape.square,
            //   child: Image.network(
            //       website!.logo.startsWith("http")
            //           ? website.logo
            //           : '${mySite!.mirror}${website.logo}',
            //       errorBuilder: (BuildContext context, Object exception,
            //           StackTrace? stackTrace) {
            //     // Placeholder widget when loading fails
            //     return const Image(image: AssetImage('assets/images/logo.png'));
            //   }, fit: BoxFit.fitHeight),
            // ),
            onTap: () async {
              String url =
                  '${mySite.mirror}${website.pageDetail.replaceAll('{}', info.tid)}';

              if (!Platform.isIOS && !Platform.isAndroid) {
                Logger.instance.i('Explorer');
                Uri uri = Uri.parse(url);
                if (!await launchUrl(uri)) {
                  Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？');
                }
              } else {
                Logger.instance.i('WebView');
                Get.toNamed(Routes.WEBVIEW, arguments: {
                  'url': url,
                  'info': info,
                  'mySite': mySite,
                  'website': website
                });
              }
            },
            title: EllipsisText(
              text: info.title,
              ellipsis: "...",
              maxLines: 1,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            subTitle: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: EllipsisText(
                text: info.subtitle,
                ellipsis: "...",
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black38,
                ),
              ),
            ),
            description: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.black38,
                        size: 12,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(info.published),
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            color: Colors.green,
                            size: 11,
                          ),
                          Text(
                            info.seeders.toString(),
                            style: const TextStyle(
                              color: Colors.black38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward,
                            color: Colors.red,
                            size: 11,
                          ),
                          Text(
                            info.leechers.toString(),
                            style: const TextStyle(
                              color: Colors.black38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.done,
                            color: Colors.orange,
                            size: 11,
                          ),
                          Text(
                            info.completers.toString(),
                            style: const TextStyle(
                              color: Colors.black38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                if (info.category.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.category,
                            color: Colors.black38,
                            size: 11,
                          ),
                          Text(
                            info.category,
                            style: const TextStyle(
                              color: Colors.black38,
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.format_size,
                        color: Colors.black38,
                        size: 11,
                      ),
                      Text(
                        filesize(info.size),
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                ),
                if (info.saleStatus.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          color: Colors.black38,
                          size: 11,
                        ),
                        Text(
                          info.saleStatus,
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 10,
                          ),
                        )
                      ],
                    ),
                  ),
                if (info.saleExpire != null)
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          color: Colors.black38,
                          size: 11,
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(info.saleExpire!),
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 10,
                          ),
                        )
                      ],
                    ),
                  ),
                if (!info.hr)
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.directions_run,
                          color: Colors.black38,
                          size: 11,
                        ),
                        Text(
                          'HR',
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 10,
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
          GFButtonBar(runAlignment: WrapAlignment.end, children: [
            SizedBox(
              width: 68,
              child: GFButton(
                text: '下载种子',
                onPressed: () async {
                  Uri uri = Uri.parse(info.magnetUrl);
                  if (!await launchUrl(uri)) {
                    Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？');
                  }
                },
                color: GFColors.SECONDARY,
                size: GFSize.SMALL,
              ),
            ),
            SizedBox(
              width: 68,
              child: GFButton(
                text: '推送种子',
                color: GFColors.PRIMARY,
                size: GFSize.SMALL,
                onPressed: () {},
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
