import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/app/home/pages/agg_search/models/torrent_info.dart';
import 'package:harvest/app/home/pages/models/website.dart';
import 'package:intl/intl.dart';
import 'package:random_color/random_color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../common/utils.dart';
import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../../../utils/string_utils.dart';
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
        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.searchKeyController,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '请输入搜索关键字',
                            hintStyle: const TextStyle(fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 5),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              // 不绘制边框
                              borderRadius: BorderRadius.circular(0.0),
                              // 确保角落没有圆角
                              gapPadding: 0.0, // 移除边框与hintText之间的间距
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1.0, color: Colors.black),
                              // 仅在聚焦时绘制底部边框
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                          ),
                          onSubmitted: (value) {
                            controller.doWebsocketSearch();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 5,
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
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
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
                                controller.doWebsocketSearch();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8.0), // 圆角半径
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
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87)),
                    titlePadding: EdgeInsets.zero,
                    contentChild: SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.searchMsg.length,
                              itemBuilder: (BuildContext context, int index) {
                                String info =
                                    controller.searchMsg[index]['msg'];
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
                if (!kIsWeb && Platform.isIOS) const SizedBox(height: 10),
                const SizedBox(height: 50),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: controller.searchResults.isNotEmpty
                ? _buildBottomButtonBar()
                : null,
          ),
        );
      },
    );
  }

  _buildBottomButtonBar() {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              controller.initSearchResult();
            },
            icon: const Icon(
              Icons.remove_circle_outline,
              size: 16,
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 8)),
              side: WidgetStateProperty.all(BorderSide.none),
            ),
            label: const Text('清除'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _openSortSheet();
            },
            icon: const Icon(
              Icons.sort_by_alpha_sharp,
              size: 16,
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 8)),
              side: WidgetStateProperty.all(BorderSide.none),
            ),
            label: const Text('排序'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _openFilterSheet();
            },
            icon: const Icon(
              Icons.filter_tilt_shift,
              size: 16,
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 8)),
              side: WidgetStateProperty.all(BorderSide.none),
            ),
            label: const Text('筛选'),
          ),
        ],
      ),
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
          .d('显示出错啦: ${info.siteId} -  $mySite - $website');
      return const SizedBox.shrink();
    }
    String imgUrl = info.poster.isNotEmpty &&
            !info.poster.endsWith('spinner.svg') &&
            !info.poster.endsWith('trans.gif')
        ? info.poster.startsWith("http")
            ? info.poster
            : '${mySite.mirror}${info.poster}'
        : website.logo.startsWith("http")
            ? website.logo
            : '${mySite.mirror}${website.logo}';

    return InkWell(
      onLongPress: () async {
        String url =
            '${mySite.mirror}${website.pageDetail.replaceAll('{}', info.tid)}';

        if (kIsWeb || !Platform.isIOS && !Platform.isAndroid) {
          LoggerHelper.Logger.instance.i('Explorer');
          Uri uri = Uri.parse(url);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？',
                colorText: Theme.of(context).colorScheme.error);
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
      onTap: () async {
        if (mySite.mirror!.contains('m-team')) {
          final res = await controller.getMTeamDlLink(mySite, info);
          if (res.code == 0) {
            info = info.copyWith(magnetUrl: res.data);
          } else {
            Get.snackbar('下载链接', '${mySite.nickname} 获取种子下载链接失败！${res.msg}');
            return;
          }
        }
        openDownloaderListSheet(context, info);
      },
      child: CustomCard(
        child: Column(
          children: [
            GFListTile(
              padding: EdgeInsets.zero,
              avatar: InkWell(
                onTap: () {
                  Get.defaultDialog(
                      title: '海报预览',
                      content: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          errorWidget: (context, url, error) => const Image(
                              image: AssetImage('assets/images/logo.png')),
                          fit: BoxFit.fitWidth,
                        ),
                      ));
                },
                child: SizedBox(
                  width: 55,
                  child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        CachedNetworkImage(
                          imageUrl: imgUrl,
                          errorWidget: (context, url, error) => const Image(
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.fitWidth),
                          fit: BoxFit.fitWidth,
                        ),
                        CustomTextTag(
                          labelText: website.name.toString(),
                          backgroundColor:
                              Colors.teal.shade500.withOpacity(0.7),
                        ),
                      ]),
                ),
              ),
              title: EllipsisText(
                text: info.title.isNotEmpty ? info.title : info.subtitle,
                ellipsis: "...",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              subTitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: EllipsisText(
                  text: info.subtitle.isNotEmpty ? info.subtitle : info.title,
                  ellipsis: "...",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.secondary,
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
                        Icon(
                          Icons.timer,
                          color: Theme.of(context).colorScheme.primary,
                          size: 12,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          info.published is DateTime
                              ? DateFormat('yyyy-MM-dd HH:mm:ss')
                                  .format(info.published)
                              : info.published.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
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
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
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
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
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
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
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
            if (info.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...info.tags.map((e) => CustomTextTag(
                          labelText: e,
                          backgroundColor: RandomColor().randomColor(
                              colorHue: ColorHue.multiple(colorHues: [
                                ColorHue.purple,
                                ColorHue.orange,
                                ColorHue.blue,
                              ]),
                              colorBrightness: ColorBrightness.dark,
                              colorSaturation: ColorSaturation.highSaturation),
                        ))
                  ],
                ),
              ),
            if (info.progress != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GFProgressBar(
                    percentage: info.progress! / 100,
                    progressHeadType: GFProgressHeadType.square,
                    trailing: Text(
                      '${(info.progress!).toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    alignment: MainAxisAlignment.center,
                    progressBarColor: Colors.green),
              ),
          ],
        ),
      ),
    );
  }

  _openSiteSheet() {
    controller.mySiteController.mySiteList.sort(
        (a, b) => a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase()));
    List<MySite> canSearchList = controller.mySiteController.mySiteList
        .where((element) => element.available && element.searchTorrents)
        .toList();
    TextEditingController searchKey = TextEditingController();
    Get.bottomSheet(SizedBox(
      width: double.infinity,
      child: CustomCard(
          padding: const EdgeInsets.all(12),
          height: 500,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GetBuilder<AggSearchController>(builder: (controller) {
                    return ElevatedButton(
                        onPressed: () {
                          if (controller.sites.isEmpty) {
                            controller.sites.addAll(
                                canSearchList.map((e) => e.id).toList());
                          } else {
                            controller.sites.clear();
                          }
                          controller.update();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // 圆角半径
                          ),
                        ),
                        child: Text(
                          '${controller.sites.isEmpty ? '全选' : '清除'} ${canSearchList.length}',
                          style: const TextStyle(color: Colors.white),
                        ));
                  }),
                  GetBuilder<AggSearchController>(builder: (controller) {
                    return ElevatedButton(
                        onPressed: () {
                          _getRandomSites();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // 圆角半径
                          ),
                        ),
                        child: const Text(
                          '随机',
                          style: TextStyle(color: Colors.white),
                        ));
                  }),
                  GetBuilder<AggSearchController>(builder: (controller) {
                    return Row(
                      children: [
                        InkWell(
                          child: const Icon(Icons.remove),
                          onTap: () {
                            if (controller.maxCount > 0) {
                              controller.maxCount--;
                            }
                            controller.update();
                          },
                          onLongPress: () {
                            controller.maxCount = 0;
                            controller.sites.clear();
                            controller.update();
                          },
                        ),
                        ElevatedButton(
                            onPressed: () => controller.saveDefaultSites(),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8.0), // 圆角半径
                              ),
                            ),
                            child: Text('默认${controller.maxCount}')),
                        InkWell(
                          child: const Icon(Icons.add),
                          onTap: () {
                            if (controller.maxCount < canSearchList.length) {
                              controller.maxCount++;
                              controller.update();
                            }
                          },
                          onLongPress: () {
                            controller.maxCount = canSearchList.length;
                            controller.sites
                                .addAll(canSearchList.map((e) => e.id));
                            controller.update();
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: searchKey,
                labelText: '筛选',
                onChanged: (String value) {
                  searchKey.text = value;
                  controller.update();
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GetBuilder<AggSearchController>(builder: (controller) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: canSearchList
                            .where((element) =>
                                element.nickname
                                    .toLowerCase()
                                    .contains(searchKey.text.toLowerCase()) ||
                                element.site
                                    .toLowerCase()
                                    .contains(searchKey.text.toLowerCase()) ||
                                element.mirror!
                                    .toLowerCase()
                                    .contains(searchKey.text.toLowerCase()))
                            .map((MySite mySite) {
                          WebSite? webSite = controller
                              .mySiteController.webSiteList[mySite.site];
                          if (webSite == null || !webSite.searchTorrents) {
                            return const SizedBox.shrink();
                          }
                          return FilterChip(
                            label: Text(capitalize(mySite.nickname)),
                            selected: controller.sites.contains(mySite.id),
                            backgroundColor: Colors.blue.shade500,
                            labelStyle: const TextStyle(
                                fontSize: 12, color: Colors.white),
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
                      ),
                    ),
                  );
                }),
              ),
            ],
          )),
    ));
  }

  void _getRandomSites() {
    controller.sites.clear();
    // 创建一个随机数生成器
    var whereToSearch = controller.mySiteController.mySiteList
        .where((element) => element.available && element.searchTorrents)
        .toList();
    List<int> selectedNumbers =
        getRandomIndices(whereToSearch.length, controller.maxCount);
    controller.sites.addAll(selectedNumbers.map((e) => whereToSearch[e].id));
    LoggerHelper.Logger.instance.i(controller.sites);
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
