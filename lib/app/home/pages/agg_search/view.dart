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
        return Scaffold(
            body: Column(
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
                            controller.searchKey = value;
                            controller.doSearch();
                          },
                        ),
                      ),
                      GetBuilder<AggSearchController>(builder: (controller) {
                        return ElevatedButton.icon(
                          onPressed: () async {
                            // 在这里执行搜索操作
                            if (controller.isLoading) {
                              await controller.cancelSearch();
                            } else {
                              controller.searchKey = searchKeyController.text;
                              controller.doSearch();
                            }
                          },
                          autofocus: true,
                          icon: controller.isLoading
                              ? const GFLoader(
                                  size: 18,
                                )
                              : const Icon(
                                  Icons.search,
                                  size: 18,
                                ),
                          label: controller.isLoading
                              ? const Text('取消')
                              : const Text('搜索'),
                        );
                      }),
                    ],
                  ),
                ),
                if (controller.searchMsg.isNotEmpty)
                  GFAccordion(
                    titleChild: Text(
                        '搜索结果：$succeedCount个站点共${controller.searchResults.length}个种子，筛选结果：${controller.showResults.length}个'),
                    titlePadding: EdgeInsets.zero,
                    contentChild: SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          Text(
                              '搜索结果：$succeedCount个站点共${controller.searchResults.length}个种子，失败$failedCount个站点'),
                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.searchMsg.length,
                              itemBuilder: (BuildContext context, int index) {
                                String info =
                                    controller.searchMsg[index]['msg'];
                                return Text(info);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                GetBuilder<AggSearchController>(builder: (controller) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: controller.showResults.length,
                      itemBuilder: (BuildContext context, int index) {
                        TorrentInfo info = controller.showResults[index];
                        return showTorrentInfo(info);
                      },
                    ),
                  );
                }),
              ],
            ),
            floatingActionButton: controller.searchResults.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GFIconButton(
                        onPressed: () {
                          Get.bottomSheet(SizedBox(
                            // height: 500,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Card(
                                child: GetBuilder<AggSearchController>(
                                    builder: (controller) {
                                  return Column(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '种子筛选',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          )),
                                      if (controller.succeedSiteList.isNotEmpty)
                                        FilterItem(
                                            name: '站点',
                                            value: controller.succeedSiteList,
                                            selected:
                                                controller.selectedSiteList,
                                            onUpdate: () {
                                              controller.filterResults();
                                              controller.update();
                                            }),
                                      if (controller.saleStatusList.isNotEmpty)
                                        FilterItem(
                                            name: '免费',
                                            value: controller.saleStatusList,
                                            selected: controller
                                                .selectedSaleStatusList,
                                            onUpdate: () {
                                              controller.filterResults();
                                              controller.update();
                                            }),
                                      if (controller
                                          .succeedCategories.isNotEmpty)
                                        FilterItem(
                                            name: '分类',
                                            value: controller.succeedCategories,
                                            selected:
                                                controller.selectedCategories,
                                            onUpdate: () {
                                              controller.filterResults();
                                              controller.update();
                                            }),
                                      if (controller.hrResultList.isNotEmpty)
                                        Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: const BorderSide(
                                                color: Colors.grey, width: 1.0),
                                          ),
                                          child: SwitchListTile(
                                            title: const Text('排除 HR'),
                                            onChanged: (val) {
                                              controller.hrKey = val;
                                              controller.update();
                                            },
                                            value: controller.hrKey,
                                            activeColor: Colors.green,
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ));
                        },
                        icon: const Icon(
                          Icons.filter_tilt_shift,
                          // size: 32,
                          // color: Colors.blue,
                        ),
                        // text: '筛选',
                        // type: GFButtonType.outline2x,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GFIconButton(
                        onPressed: () {
                          Get.bottomSheet(SizedBox(
                            width: double.infinity,
                            child: Card(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                itemCount: controller.sortKeyList.length,
                                itemBuilder: (context, index) {
                                  Map<String, String> item =
                                      controller.sortKeyList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                    child: ListTile(
                                      title: Text(
                                        item['name']!,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                            color: Colors.grey, width: 1.0),
                                      ),
                                      selectedColor: Colors.amber,
                                      selected:
                                          controller.sortKey == item['value'],
                                      leading: controller.sortReversed
                                          ? const Icon(Icons.trending_up)
                                          : const Icon(Icons.trending_down),
                                      trailing: controller.sortKey ==
                                              item['value']
                                          ? const Icon(Icons.check_box_outlined)
                                          : const Icon(Icons
                                              .check_box_outline_blank_rounded),
                                      onTap: () {
                                        if (controller.sortKey ==
                                            item['value']!) {
                                          controller.sortReversed =
                                              !controller.sortReversed;
                                        }

                                        controller.sortKey = item['value']!;
                                        controller.sortResults();

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  );
                                },
                              ),
                            )),
                          ));
                        },
                        icon: const Icon(
                          Icons.swap_vert_circle_outlined,
                          // size: 32,
                          // color: Colors.blue,
                        ),
                        // text: '排序',
                        // type: GFButtonType.outline2x,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )
                : null);
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
                if (!await launchUrl(uri,
                    mode: LaunchMode.externalApplication)) {
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

class FilterItem extends StatelessWidget {
  final String name;
  final List<String> value;
  final List<String> selected;
  final Function() onUpdate;

  const FilterItem({
    super.key,
    required this.name,
    required this.value,
    required this.selected,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(name),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: value
                  .map(
                    (e) => ChoiceChip(
                      label: e.toString().isNotEmpty
                          ? Text(e.toString())
                          : const Text('无'),
                      selected: selected.contains(e.toString()),
                      onSelected: (value) {
                        if (value) {
                          selected.add(e.toString());
                        } else {
                          selected.remove(e.toString());
                        }
                        onUpdate();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
