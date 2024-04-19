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

import '../../../../common/card_view.dart';
import '../../../../common/utils.dart';
import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../../routes/app_pages.dart';
import '../models/my_site.dart';
import 'controller.dart';
import 'download_form.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchKeyController,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: '请输入搜索关键字',
                      ),
                      onSubmitted: (value) {
                        controller.searchKey = value;
                        controller.doSearch();
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _openSiteSheet();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // 圆角半径
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    icon: const Icon(
                      Icons.language,
                      size: 14,
                      color: Colors.white,
                    ),
                    label: Text(
                      '站点 ${controller.maxCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
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
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // 圆角半径
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                        ),
                        autofocus: true,
                        icon: controller.isLoading
                            ? const GFLoader(
                                size: 14,
                              )
                            : const Icon(
                                Icons.search,
                                size: 14,
                                color: Colors.white,
                              ),
                        label: Text(controller.isLoading ? '取消' : '搜索',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)));
                  }),
                ],
              ),
            ),
            if (controller.searchMsg.isNotEmpty)
              GFAccordion(
                titleChild: Text(
                    '失败$failedCount个站点，$succeedCount个站点共${controller.searchResults.length}个种子，筛选结果：${controller.showResults.length}个',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black87)),
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
                            return Text(info,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black87));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (controller.searchResults.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionChip(
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.only(left: 0, right: 12),
                      onPressed: () {
                        controller.initSearchResult();
                      },
                      avatar: const Icon(
                        Icons.remove_circle_outline,
                        size: 12,
                      ),
                      label: const Text(
                        '清除',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                    ActionChip(
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.only(left: 0, right: 12),
                      onPressed: () {
                        _openSortSheet();
                      },
                      avatar: const Icon(
                        Icons.sort_by_alpha_sharp,
                        size: 18,
                      ),
                      label: const Text(
                        '排序',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                    ActionChip(
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.only(left: 0, right: 12),
                      onPressed: () {
                        _openFilterSheet();
                      },
                      avatar: const Icon(
                        Icons.filter_tilt_shift,
                        size: 18,
                      ),
                      label: const Text(
                        '筛选',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            GetBuilder<AggSearchController>(builder: (controller) {
              return Expanded(
                child: ListView.builder(
                  itemCount: controller.showResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    SearchTorrentInfo info = controller.showResults[index];
                    return showTorrentInfo(info);
                  },
                ),
              );
            }),
          ],
        ));
      },
    );
  }

  @override
  void dispose() {
    Get.delete<AggSearchController>();
    super.dispose();
  }

  Widget showTorrentInfo(SearchTorrentInfo info) {
    WebSite? website = controller.mySiteController.webSiteList[info.siteId];
    MySite? mySite = controller.mySiteMap[info.siteId];
    if (website == null || mySite == null) {
      LoggerHelper.Logger.instance
          .w('显示出错啦: ${info.siteId} -  $mySite - $website');
      return const SizedBox.shrink();
    }
    return CustomCard(
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
            icon: InkWell(
              onLongPress: () async =>
                  await launchUrl(Uri.parse(info.magnetUrl)),
              onTap: () => openDownloaderListSheet(context, info),
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Icon(Icons.file_download_outlined)),
            ),
            onTap: () async {
              String url =
                  '${mySite.mirror}${website.pageDetail.replaceAll('{}', info.tid)}';

              if (!Platform.isIOS && !Platform.isAndroid) {
                LoggerHelper.Logger.instance.i('Explorer');
                Uri uri = Uri.parse(url);
                if (!await launchUrl(uri,
                    mode: LaunchMode.externalApplication)) {
                  Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？');
                }
              } else {
                LoggerHelper.Logger.instance.i('WebView');
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
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (info.category.isNotEmpty)
                  CustomTextTag(
                      labelText: info.category, backgroundColor: Colors.blue),
                CustomTextTag(
                    labelText: filesize(info.size),
                    backgroundColor: Colors.indigo),
                if (info.saleStatus.isNotEmpty)
                  CustomTextTag(labelText: info.saleStatus),
                if (info.saleExpire != null)
                  CustomTextTag(
                    labelText: DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(info.saleExpire!),
                    icon: const Icon(
                      Icons.sell_outlined,
                      color: Colors.black38,
                      size: 11,
                    ),
                    backgroundColor: Colors.teal,
                  ),
                if (!info.hr)
                  const CustomTextTag(
                    labelText: 'HR',
                    backgroundColor: Colors.red,
                    icon: Icon(
                      Icons.directions_run,
                      color: Colors.black38,
                      size: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _openSiteSheet() {
    controller.mySiteController.mySiteList.shuffle();
    Get.bottomSheet(SizedBox(
      width: double.infinity,
      child: CustomCard(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          controller.sites.clear();
                          controller.sites.addAll(controller
                              .mySiteController.mySiteList
                              .where((element) => element.searchTorrents)
                              .map((e) => e.id)
                              .toList());

                          controller.update();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // 圆角半径
                          ),
                        ),
                        child: const Text(
                          '全选',
                          style: TextStyle(color: Colors.white),
                        )),
                    GetBuilder<AggSearchController>(builder: (controller) {
                      return Row(
                        children: [
                          InkWell(
                            child: const Icon(Icons.remove),
                            onTap: () {
                              if (controller.maxCount > 1) {
                                controller.maxCount--;
                                _getRandomSites();
                              }
                              controller.update();
                            },
                            onLongPress: () {
                              controller.maxCount = 0;
                              controller.sites.clear();
                              controller.update();
                            },
                          ),
                          GetBuilder<AggSearchController>(
                              builder: (controller) {
                            return ElevatedButton(
                                onPressed: () {
                                  _getRandomSites();
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8.0), // 圆角半径
                                  ),
                                ),
                                child: Text(
                                  '随机 ${controller.maxCount}',
                                  style: const TextStyle(color: Colors.white),
                                ));
                          }),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              controller.maxCount++;
                              _getRandomSites();
                              controller.update();
                            },
                          ),
                        ],
                      );
                    }),
                    ElevatedButton(
                        onPressed: () {
                          controller.sites.clear();
                          controller.update();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // 圆角半径
                          ),
                        ),
                        child: const Text('清除')),
                  ],
                ),
                const SizedBox(height: 12),
                GetBuilder<AggSearchController>(builder: (controller) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.mySiteController.mySiteList
                        .where((element) => element.searchTorrents)
                        .map((MySite mySite) {
                      WebSite? webSite =
                          controller.mySiteController.webSiteList[mySite.site];
                      if (webSite == null || !webSite.searchTorrents) {
                        return const SizedBox.shrink();
                      }
                      return FilterChip(
                        label: Text(mySite.nickname),
                        selected: controller.sites.contains(mySite.id),
                        backgroundColor: Colors.blue.shade500,
                        labelStyle:
                            const TextStyle(fontSize: 12, color: Colors.white),
                        selectedColor: Colors.green,
                        selectedShadowColor: Colors.blue,
                        pressElevation: 5,
                        elevation: 3,
                        onSelected: (value) {
                          if (value) {
                            controller.sites.add(mySite.id);
                          } else {
                            controller.sites
                                .removeWhere((item) => item == mySite.id);
                          }
                          LoggerHelper.Logger.instance.i(controller.sites);
                          controller.update();
                        },
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          )),
    ));
  }

  void _getRandomSites() {
    controller.sites.clear();
    // 创建一个随机数生成器
    var whereToSearch = controller.mySiteController.mySiteList
        .where((element) => element.searchTorrents)
        .toList();
    List<int> selectedNumbers =
        getRandomIndices(whereToSearch.length, controller.maxCount);
    LoggerHelper.Logger.instance.i(selectedNumbers);
    controller.sites.addAll(selectedNumbers.map((e) => whereToSearch[e].id));
    controller.update();
  }

  _openSortSheet() {
    Get.bottomSheet(SizedBox(
      width: double.infinity,
      child: CustomCard(
          child: ListView.builder(
        itemCount: controller.sortKeyList.length,
        itemBuilder: (context, index) {
          Map<String, String> item = controller.sortKeyList[index];
          return CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: ListTile(
              dense: true,
              title: Text(
                item['name']!,
                style: const TextStyle(fontSize: 13),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              selectedColor: Colors.amber,
              selected: controller.sortKey == item['value'],
              leading: controller.sortReversed
                  ? const Icon(Icons.trending_up)
                  : const Icon(Icons.trending_down),
              trailing: controller.sortKey == item['value']
                  ? const Icon(Icons.check_box_outlined)
                  : const Icon(Icons.check_box_outline_blank_rounded),
              onTap: () {
                if (controller.sortKey == item['value']!) {
                  controller.sortReversed = !controller.sortReversed;
                }

                controller.sortKey = item['value']!;
                controller.sortResults();

                Navigator.of(context).pop();
              },
            ),
          );
        },
      )),
    ));
  }

  _openFilterSheet() {
    Get.bottomSheet(Container(
      margin: const EdgeInsets.all(8),
      width: double.infinity,
      child: SingleChildScrollView(
        child: CustomCard(
          child: GetBuilder<AggSearchController>(builder: (controller) {
            return Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '种子筛选',
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
                if (controller.succeedSiteList.isNotEmpty)
                  FilterItem(
                      name: '站点',
                      value: controller.succeedSiteList,
                      selected: controller.selectedSiteList,
                      onUpdate: () {
                        controller.filterResults();
                        controller.update();
                      }),
                if (controller.saleStatusList.isNotEmpty)
                  FilterItem(
                      name: '免费',
                      value: controller.saleStatusList,
                      selected: controller.selectedSaleStatusList,
                      onUpdate: () {
                        controller.filterResults();
                        controller.update();
                      }),
                if (controller.succeedCategories.isNotEmpty)
                  FilterItem(
                      name: '分类',
                      value: controller.succeedCategories,
                      selected: controller.selectedCategories,
                      onUpdate: () {
                        controller.filterResults();
                        controller.update();
                      }),
                if (controller.hrResultList.isNotEmpty)
                  CustomCard(
                    child: SwitchListTile(
                      title: const Text(
                        '排除 HR',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
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
  }
}
