import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/torrent_info.dart';
import 'package:harvest/app/home/pages/models/website.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/storage.dart';
import 'package:random_color/random_color.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../common/media_card.dart';
import '../../../../common/utils.dart';
import '../../../../utils/logger_helper.dart' as logger_helper;
import '../../../../utils/logger_helper.dart';
import '../../../../utils/string_utils.dart';
import '../../../routes/app_pages.dart';
import '../download/download_form.dart';
import '../models/douban.dart';
import '../models/my_site.dart';
import 'controller.dart';
import 'models.dart';

class AggSearchPage extends StatefulWidget {
  const AggSearchPage({super.key});

  @override
  State<AggSearchPage> createState() => _AggSearchPageState();
}

class _AggSearchPageState extends State<AggSearchPage> with AutomaticKeepAliveClientMixin {
  final controller = Get.put(AggSearchController());
  String cacheServer = 'https://images.weserv.nl/?url=';
  double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);

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
        succeedCount = controller.searchMsg.where((element) => element['success']).length;
        failedCount = controller.searchMsg.where((element) => !element['success']).length;
        var shadColorScheme = ShadTheme.of(context).colorScheme;
        RxBool showErrors = false.obs;
        return GetBuilder<AggSearchController>(builder: (controller) {
          return DefaultTabController(
            length: controller.tabs.length,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: controller.searchResults.isNotEmpty && controller.tabController.index == 1
                    ? _buildBottomButtonBar()
                    : null,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Material(
                    color: shadColorScheme.background.withOpacity(opacity),
                    // 背景色
                    child: TabBar(
                      controller: controller.tabController,
                      labelColor: shadColorScheme.foreground,
                      unselectedLabelColor: shadColorScheme.foreground.withOpacity(0.7),
                      onTap: (int index) => controller.changeTab(index),
                      tabs: controller.tabs,
                    ),
                  ),
                ),
                body: Column(
                  children: [
                    CustomCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              style: TextStyle(color: shadColorScheme.foreground),
                              controller: controller.searchKeyController,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '请输入搜索关键字',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: shadColorScheme.foreground,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                                fillColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  // 不绘制边框
                                  borderRadius: BorderRadius.circular(0.0),
                                  // 确保角落没有圆角
                                  gapPadding: 0.0, // 移除边框与hintText之间的间距
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1.0,
                                    color: shadColorScheme.foreground,
                                  ),
                                  // 仅在聚焦时绘制底部边框
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                              ),
                              onSubmitted: (value) => _doTmdbSearch(),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GetBuilder<AggSearchController>(builder: (controller) {
                            return CustomPopup(
                              showArrow: false,
                              backgroundColor: shadColorScheme.background,
                              barrierColor: Colors.transparent,
                              content: SizedBox(
                                width: 100,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // if (controller.tmdbClient != null)
                                    PopupMenuItem<String>(
                                      child: Text(
                                        'T M D B',
                                        style: TextStyle(
                                          color: shadColorScheme.foreground,
                                        ),
                                      ),
                                      onTap: () => _doTmdbSearch(),
                                    ),
                                    PopupMenuItem<String>(
                                      child: Text(
                                        '来自豆瓣',
                                        style: TextStyle(
                                          color: shadColorScheme.foreground,
                                        ),
                                      ),
                                      onTap: () async {
                                        await controller.doDouBanSearch();
                                      },
                                    ),
                                    PopupMenuItem<String>(
                                      child: Text(
                                        '清理tmdb',
                                        style: TextStyle(
                                          color: shadColorScheme.foreground,
                                        ),
                                      ),
                                      onTap: () async {
                                        controller.results.clear();
                                        controller.update();
                                      },
                                    ),
                                    PopupMenuItem<String>(
                                      child: Text(
                                        '清理豆瓣',
                                        style: TextStyle(
                                          color: shadColorScheme.foreground,
                                        ),
                                      ),
                                      onTap: () async {
                                        controller.showDouBanResults.clear();
                                        controller.update();
                                      },
                                    ),
                                    PopupMenuItem<String>(
                                      child: Text(
                                        '搜索资源',
                                        style: TextStyle(
                                          color: shadColorScheme.foreground,
                                        ),
                                      ),
                                      onTap: () async {
                                        // 在这里执行搜索操作
                                        if (controller.isLoading) {
                                          await controller.cancelSearch();
                                        } else {
                                          controller.doWebsocketSearch();
                                        }
                                      },
                                    ),
                                    PopupMenuItem<String>(
                                      child: Text(
                                        '站点[◉${controller.maxCount}]',
                                        style: TextStyle(
                                          color: shadColorScheme.foreground,
                                        ),
                                      ),
                                      onTap: () async {
                                        _openSiteSheet();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.transparent,
                                ),
                                child: controller.isLoading
                                    ? InkWell(
                                        onTap: () => controller.cancelSearch(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: CircularProgressIndicator(
                                            color: shadColorScheme.foreground,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.search,
                                        size: 22,
                                        color: shadColorScheme.foreground,
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(controller: controller.tabController, children: [
                        Column(
                          children: [
                            if (controller.results.isNotEmpty)
                              Expanded(
                                child: ListView.builder(
                                    itemCount: controller.results.length,
                                    itemBuilder: (context, int index) => MediaItemCard(
                                          media: controller.results[index],
                                          onDetail: (media) => _showTMDBDetail(media),
                                          onSearch: (media) => controller.doTMDBSearch(media),
                                        )),
                              ),
                            if (controller.showDouBanResults.isNotEmpty)
                              Expanded(
                                child: ListView.builder(
                                  itemCount: controller.showDouBanResults.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    DouBanSearchResult info = controller.showDouBanResults[index];
                                    return showDouBanSearchInfo(info);
                                  },
                                ),
                              ),
                          ],
                        ),
                        Column(
                          children: [
                            if (controller.searchMsg.isNotEmpty)
                              CustomCard(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Obx(() {
                                  return Column(
                                    children: [
                                      ListTile(
                                        dense: true,
                                        title: Center(
                                          child: Text(
                                              '失败$failedCount个站点，$succeedCount个站点共${controller.searchResults.length}个种子，筛选结果：${controller.showResults.length}个',
                                              style: TextStyle(fontSize: 12, color: shadColorScheme.primary)),
                                        ),
                                        trailing: ExpandIcon(
                                          isExpanded: showErrors.value,
                                          onPressed: (value) {
                                            showErrors.value = !showErrors.value;
                                          },
                                          color: shadColorScheme.foreground,
                                        ),
                                      ),
                                      if (showErrors.value)
                                        Container(
                                          height: 100,
                                          padding: const EdgeInsets.all(8),
                                          child: ListView.builder(
                                            itemCount: controller.searchMsg.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              String info = controller.searchMsg[index]['msg'];
                                              return Text(info,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: shadColorScheme.foreground,
                                                  ));
                                            },
                                          ),
                                        )
                                    ],
                                  );
                                }),
                              ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: controller.showResults.length,
                                itemBuilder: (BuildContext context, int index) {
                                  SearchTorrentInfo info = controller.showResults[index];
                                  return showTorrentInfo(info);
                                },
                              ),
                            ),
                          ],
                        ),
                        GetBuilder<AggSearchController>(
                            id: Key('agg_search_history'),
                            builder: (controller) {
                              return SingleChildScrollView(
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 8,
                                  children: [
                                    if (controller.searchHistory.isNotEmpty)
                                      FilterChip(
                                        backgroundColor: shadColorScheme.destructive,
                                        deleteIcon: Icon(
                                          Icons.clear,
                                          color: shadColorScheme.destructiveForeground,
                                        ),
                                        deleteButtonTooltipMessage: '确定要删除全部搜索记录吗？',
                                        label: Text('一键清理',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: shadColorScheme.destructiveForeground,
                                            )),
                                        onSelected: (bool value) {
                                          Get.defaultDialog(
                                            title: '提示',
                                            backgroundColor: shadColorScheme.background.withOpacity(opacity),
                                            titleStyle: TextStyle(
                                              fontSize: 16,
                                              color: shadColorScheme.foreground,
                                            ),
                                            middleText: '确定要删除全部搜索记录吗？',
                                            middleTextStyle: TextStyle(
                                              fontSize: 13,
                                              color: shadColorScheme.foreground,
                                            ),
                                            cancel: ShadButton.destructive(
                                              size: ShadButtonSize.sm,
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text('取消',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: shadColorScheme.destructiveForeground,
                                                  )),
                                            ),
                                            confirm: ShadButton(
                                              size: ShadButtonSize.sm,
                                              onPressed: () {
                                                controller.searchHistory.clear();
                                                SPUtil.setStringList('search_history', controller.searchHistory);
                                                controller.update();
                                              },
                                              child: Text('确定',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: shadColorScheme.primaryForeground,
                                                  )),
                                            ),
                                          );
                                        },
                                        // onDeleted: () {
                                        //   Get.defaultDialog(
                                        //     title: '提示',
                                        //     middleText: '确定要删除全部搜索记录吗？',
                                        //     cancel: TextButton(
                                        //       onPressed: () {
                                        //         Get.back();
                                        //       },
                                        //       child: Text('取消'),
                                        //     ),
                                        //     confirm: TextButton(
                                        //       onPressed: () {
                                        //         controller.searchHistory
                                        //             .clear();
                                        //         SPUtil.setStringList(
                                        //             'search_history',
                                        //             controller
                                        //                 .searchHistory);
                                        //         controller.update();
                                        //       },
                                        //       child: Text('确定'),
                                        //     ),
                                        //   );
                                        // },
                                      ),
                                    ...controller.searchHistory.map(
                                      (el) => FilterChip(
                                        backgroundColor: shadColorScheme.primary,
                                        deleteIcon: Icon(
                                          Icons.clear,
                                          color: shadColorScheme.destructive,
                                        ),
                                        deleteButtonTooltipMessage: '确定要删除记录吗？',
                                        label: Text(el,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: shadColorScheme.primaryForeground,
                                            )),
                                        onSelected: (bool value) {
                                          controller.searchKeyController.text = el;
                                          controller.doWebsocketSearch();
                                        },
                                        onDeleted: () {
                                          controller.searchHistory.remove(el);
                                          SPUtil.setStringList('search_history', controller.searchHistory);
                                          controller.update();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                      ]),
                    ),
                    if (!kIsWeb && Platform.isIOS) const SizedBox(height: 10),
                    // if (controller.tabController.index == 1)
                    //   const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildBottomButtonBar() {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 15,
      children: [
        ShadIconButton.ghost(
          onPressed: () {
            controller.initSearchResult();
          },
          icon: Icon(
            Icons.remove_circle_outline,
            size: 24,
            color: shadColorScheme.primary,
          ),
        ),
        CustomPopup(
          backgroundColor: shadColorScheme.background,
          barrierColor: Colors.transparent,
          content: SizedBox(
            width: 100,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...controller.sortKeyList.map(
                    (item) => PopupMenuItem(
                      height: 40,
                      onTap: () {
                        if (controller.sortKey == item.value) {
                          controller.sortReversed = !controller.sortReversed;
                        }
                        controller.sortKey = item.value;
                        controller.sortResults();
                      },
                      child: Text(item.name, style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          child: Icon(
            Icons.sort_by_alpha_outlined,
            size: 24,
            color: shadColorScheme.primary,
          ),
        ),
        CustomPopup(
          backgroundColor: shadColorScheme.background,
          barrierColor: Colors.transparent,
          content: SizedBox(
            width: 360,
            child: GetBuilder<AggSearchController>(builder: (controller) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '种子筛选',
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                            fontSize: ShadTheme.of(context).textTheme.h4.fontSize,
                          ),
                        )),
                    CustomCard(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                '大小【${FileSizeConvert.parseToFileSize(controller.minSize)}-${FileSizeConvert.parseToFileSize(controller.maxSize)}】',
                                style: TextStyle(color: shadColorScheme.foreground),
                              )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // TextButton(
                                  //     onPressed: () {
                                  //       // todo 先计算出初始值，
                                  //       controller.maxSize = controller.maxSize /
                                  //           controller.calcSize *
                                  //           1024;
                                  //       controller.minSize = controller.minSize /
                                  //           controller.calcSize *
                                  //           1024;
                                  //       controller.calcSize = 1024;
                                  //       controller.filterResults();
                                  //       controller.filterResults();
                                  //     },
                                  //     child: Text(
                                  //       'KB',
                                  //       style: TextStyle(
                                  //           fontSize: 12,
                                  //           color: controller.calcSize == 1024
                                  //               ? Colors.orange
                                  //               : ShadTheme.of(context)
                                  //                   .colorScheme
                                  //                   .foreground),
                                  //     )),
                                  TextButton(
                                    onPressed: () {
                                      controller.maxSize = controller.maxSize / controller.calcSize * 1024 * 1024;
                                      controller.minSize = controller.minSize / controller.calcSize * 1024 * 1024;
                                      controller.calcSize = 1024 * 1024;
                                      controller.filterResults();
                                    },
                                    child: Text(
                                      'MB',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: controller.calcSize == 1024 * 1024
                                              ? Colors.orange
                                              : shadColorScheme.foreground),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      controller.maxSize =
                                          controller.maxSize / controller.calcSize * 1024 * 1024 * 1024;
                                      controller.minSize =
                                          controller.minSize / controller.calcSize * 1024 * 1024 * 1024;
                                      controller.calcSize = 1024 * 1024 * 1024;
                                      controller.filterResults();
                                    },
                                    child: Text(
                                      'GB',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: controller.calcSize == 1024 * 1024 * 1024
                                              ? Colors.orange
                                              : shadColorScheme.foreground),
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        controller.maxSize =
                                            controller.maxSize / controller.calcSize * 1024 * 1024 * 1024 * 1024;
                                        controller.minSize =
                                            controller.minSize / controller.calcSize * 1024 * 1024 * 1024 * 1024;
                                        controller.calcSize = 1024 * 1024 * 1024 * 1024;
                                        controller.filterResults();
                                      },
                                      child: Text(
                                        'TB',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: controller.calcSize == 1024 * 1024 * 1024 * 1024
                                                ? Colors.orange
                                                : shadColorScheme.foreground),
                                      )),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '最小',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                              Expanded(
                                child: Slider(
                                    min: 0,
                                    max: 10,
                                    divisions: 20,
                                    value: controller.minSize / controller.calcSize,
                                    label: FileSizeConvert.parseToFileSize(controller.minSize),
                                    onChanged: (value) async {
                                      logger_helper.Logger.instance.d('minSize：$value');
                                      controller.minSize = value * controller.calcSize;
                                      // SPUtil.setDouble('searchFilterFileMinSize',
                                      //     controller.minSize);
                                      controller.filterResults();
                                      controller.update();
                                    }),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '最大',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                              Expanded(
                                child: Slider(
                                    min: 1,
                                    max: 100,
                                    divisions: 20,
                                    value: controller.maxSize / controller.calcSize,
                                    label: FileSizeConvert.parseToFileSize(controller.maxSize),
                                    onChanged: (value) async {
                                      logger_helper.Logger.instance.d('maxSize：$value');
                                      controller.maxSize = value * controller.calcSize;
                                      // SPUtil.setDouble('searchFilterFileMaxSize',
                                      //     controller.maxSize);
                                      controller.filterResults();
                                      controller.update();
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                    if (controller.succeedResolution.isNotEmpty)
                      FilterItem(
                          name: '分辨率',
                          value: controller.succeedResolution,
                          selected: controller.selectedResolution,
                          onUpdate: () {
                            controller.filterResults();
                            controller.update();
                          }),
                    if (controller.succeedTags.isNotEmpty)
                      FilterItem(
                          name: '标签',
                          value: controller.succeedTags,
                          selected: controller.selectedTags,
                          onUpdate: () {
                            controller.filterResults();
                            controller.update();
                          }),
                    FilterItem(
                        name: '第N季',
                        value: List.generate(20, (i) => 'S${(i + 1).toString().padLeft(2, '0')}'),
                        selected: controller.selectedSeason,
                        onUpdate: () {
                          controller.filterResults();
                          controller.update();
                        }),
                    FilterItem(
                        name: '第N集',
                        value: List.generate(20, (i) => 'E${(i + 1).toString().padLeft(2, '0')}'),
                        selected: controller.selectedEpisode,
                        onUpdate: () {
                          controller.filterResults();
                          controller.update();
                        }),
                    if (controller.hrResultList.isNotEmpty)
                      CustomCard(
                        child: SwitchListTile(
                          title: Text(
                            '排除 HR',
                            style: TextStyle(fontSize: 12, color: shadColorScheme.foreground),
                          ),
                          onChanged: (val) {
                            controller.hrKey = val;
                            controller.filterResults();
                            controller.update();
                          },
                          value: controller.hrKey,
                          activeColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          child: Icon(
            Icons.filter_tilt_shift,
            size: 24,
            color: shadColorScheme.primary,
          ),
        ),
      ],
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
      logger_helper.Logger.instance.e('显示出错啦: ${info.siteId} -  $mySite - $website');
      return const SizedBox.shrink();
    }
    String imgUrl = info.poster.isNotEmpty && !info.poster.endsWith('spinner.svg') && !info.poster.endsWith('trans.gif')
        ? info.poster.startsWith("http")
            ? info.poster
            : '${mySite.mirror}${info.poster}'
        : website.logo.startsWith("http")
            ? website.logo
            : '${mySite.mirror}${website.logo}';

    var shadColorScheme = ShadTheme.of(context).colorScheme;
    String iconUrl = '${controller.baseUrl}/local/icons/${website.name}.png';
    return InkWell(
      onLongPress: () async {
        String url = '${mySite.mirror}${website.pageDetail.replaceAll('{}', info.tid)}';

        if (kIsWeb || !Platform.isIOS && !Platform.isAndroid) {
          logger_helper.Logger.instance.d('外置浏览器打开');
          Uri uri = Uri.parse(url);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？', colorText: shadColorScheme.destructive);
          }
        } else {
          logger_helper.Logger.instance.d('内置浏览器打开');
          Get.toNamed(Routes.WEBVIEW, arguments: {'url': url, 'info': info, 'mySite': mySite, 'website': website});
        }
      },
      onTap: () async {
        if (controller.downloaderListLoading == true) {
          return;
        }
        controller.downloaderListLoading = true;

        if (mySite.mirror!.contains('m-team')) {
          final res = await controller.getMTeamDlLink(mySite, info);
          if (res.code == 0) {
            info = info.copyWith(magnetUrl: res.data);
          } else {
            Get.snackbar('下载链接', '${mySite.nickname} 获取种子下载链接失败！${res.msg}');
            return;
          }
        }
        info.siteId = mySite.id.toString();
        info.tags.addAll([
          mySite.nickname.isNotEmpty ? mySite.nickname : mySite.site,
          'harvest-app',
        ]);
        await openDownloaderListSheet(context, info);
        controller.downloaderListLoading = false;
      },
      child: CustomCard(
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              leading: InkWell(
                onTap: () {
                  Get.defaultDialog(
                      title: '海报预览',
                      content: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                            imageUrl: imgUrl,
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                              color: shadColorScheme.primary,
                            )),
                            errorWidget: (context, url, error) =>
                                const Image(image: AssetImage('assets/images/avatar.png')),
                            fit: BoxFit.fitWidth,
                            httpHeaders: {
                              "user-agent": mySite.userAgent.toString(),
                              "Cookie": mySite.cookie.toString(),
                            },
                          ),
                        ),
                      ));
                },
                child: SizedBox(
                  width: 55,
                  child: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: iconUrl,
                        cacheKey: iconUrl,
                        fit: BoxFit.fill,
                        errorWidget: (context, url, error) => CachedNetworkImage(
                          imageUrl: website.logo.startsWith('http') ? website.logo : '${mySite.mirror}${website.logo}',
                          fit: BoxFit.fill,
                          httpHeaders: {
                            "user-agent": mySite.userAgent.toString(),
                            "Cookie": mySite.cookie.toString(),
                          },
                          errorWidget: (context, url, error) =>
                              const Image(image: AssetImage('assets/images/avatar.png')),
                          width: 32,
                          height: 32,
                        ),
                        width: 32,
                        height: 32,
                      ),
                    ),
                    CustomTextTag(
                      labelText: website.name.toString(),
                      backgroundColor: shadColorScheme.primary.withOpacity(opacity * 0.8),
                      labelColor: shadColorScheme.primaryForeground,
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
                  color: shadColorScheme.foreground,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: EllipsisText(
                  text: info.subtitle.isNotEmpty ? info.subtitle : info.title,
                  ellipsis: "...",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    color: shadColorScheme.foreground.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: shadColorScheme.foreground,
                        size: 12,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        info.published is DateTime
                            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(info.published)
                            : info.published.toString(),
                        style: TextStyle(
                          color: shadColorScheme.foreground,
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
                              color: shadColorScheme.foreground.withOpacity(0.8),
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
                              color: shadColorScheme.foreground.withOpacity(0.8),
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
                              color: shadColorScheme.foreground.withOpacity(0.8),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (info.category.isNotEmpty) CustomTextTag(labelText: info.category, backgroundColor: Colors.blue),
                  CustomTextTag(labelText: FileSizeConvert.parseToFileSize(info.size), backgroundColor: Colors.indigo),
                  if (info.saleStatus.isNotEmpty) CustomTextTag(labelText: info.saleStatus),
                  if (info.saleExpire != null)
                    CustomTextTag(
                      labelText: DateFormat('yyyy-MM-dd HH:mm:ss').format(info.saleExpire!),
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * info.progress! / 100,
                  ),
                  child: ShadProgress(
                    value: info.progress! / 100,
                    semanticsLabel: '${(info.progress!).toStringAsFixed(2)}%',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openSiteSheet() {
    controller.mySiteController.mySiteList.sort((a, b) => a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase()));
    List<MySite> canSearchList =
        controller.mySiteController.mySiteList.where((element) => element.available && element.searchTorrents).toList();
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    TextEditingController searchKey = TextEditingController();
    Get.bottomSheet(
        backgroundColor: shadColorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        GetBuilder<AggSearchController>(builder: (controller) {
      return SizedBox(
          height: 500,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GetBuilder<AggSearchController>(builder: (controller) {
                      return ShadButton(
                          size: ShadButtonSize.sm,
                          onPressed: () {
                            if (controller.sites.isEmpty) {
                              controller.sites.addAll(canSearchList.map((e) => e.id).toList());
                            } else {
                              controller.sites.clear();
                            }
                            controller.update();
                          },
                          child: Text(
                            '${controller.sites.isEmpty ? '全选' : '清除'} ${canSearchList.length}',
                            style: TextStyle(color: shadColorScheme.foreground),
                          ));
                    }),
                    GetBuilder<AggSearchController>(builder: (controller) {
                      return ShadButton(
                          size: ShadButtonSize.sm,
                          onPressed: () {
                            _getRandomSites();
                          },
                          child: Text(
                            '随机',
                            style: TextStyle(color: shadColorScheme.foreground),
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
                          ShadButton(
                            onPressed: () => controller.saveDefaultSites(),
                            size: ShadButtonSize.sm,
                            child: Text(
                              '默认${controller.maxCount}',
                              style: TextStyle(color: shadColorScheme.foreground),
                            ),
                          ),
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
                              controller.sites.addAll(canSearchList.map((e) => e.id));
                              controller.update();
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              CustomTextField(
                controller: searchKey,
                labelText: '筛选',
                onChanged: (String value) {
                  // searchKey.text = value;
                  controller.update();
                },
              ),
              Expanded(
                child: GetBuilder<AggSearchController>(builder: (controller) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: canSearchList
                            .where((element) =>
                                element.nickname.toLowerCase().contains(searchKey.text.toLowerCase()) ||
                                element.site.toLowerCase().contains(searchKey.text.toLowerCase()) ||
                                element.mirror!.toLowerCase().contains(searchKey.text.toLowerCase()))
                            .map((MySite mySite) {
                          WebSite? webSite = controller.mySiteController.webSiteList[mySite.site];
                          if (webSite == null || !webSite.searchTorrents) {
                            return const SizedBox.shrink();
                          }
                          return FilterChip(
                            label: Text(
                              capitalize(mySite.nickname),
                              style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                            ),
                            selected: controller.sites.contains(mySite.id),
                            labelPadding: EdgeInsets.zero,
                            backgroundColor: shadColorScheme.primary.withOpacity(opacity),
                            labelStyle: TextStyle(fontSize: 12, color: shadColorScheme.primaryForeground),
                            selectedColor: Colors.green,
                            selectedShadowColor: Colors.blue,
                            pressElevation: 5,
                            elevation: 3,
                            onSelected: (value) {
                              if (value) {
                                controller.sites.add(mySite.id);
                              } else {
                                controller.sites.removeWhere((item) => item == mySite.id);
                              }
                              logger_helper.Logger.instance.d(controller.sites);
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
          ));
    }));
  }

  void _getRandomSites() {
    controller.sites.clear();
    // 创建一个随机数生成器
    var whereToSearch =
        controller.mySiteController.mySiteList.where((element) => element.available && element.searchTorrents).toList();
    List<int> selectedNumbers = getRandomIndices(whereToSearch.length, controller.maxCount);
    controller.sites.addAll(selectedNumbers.map((e) => whereToSearch[e].id));
    logger_helper.Logger.instance.d(controller.sites);
    controller.update();
  }

  void _openSortSheet() {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(SizedBox(
      width: double.infinity,
      child: CustomCard(
          child: ListView.builder(
        itemCount: controller.sortKeyList.length,
        itemBuilder: (context, index) {
          MetaDataItem item = controller.sortKeyList[index];
          return CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: ListTile(
              dense: true,
              title: Text(
                item.name,
                style: TextStyle(fontSize: 13, color: shadColorScheme.foreground),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              selectedColor: Colors.amber,
              selected: controller.sortKey == item.value,
              leading: Icon(
                controller.sortReversed ? Icons.trending_up : Icons.trending_down,
                color: shadColorScheme.foreground,
              ),
              trailing: Icon(
                controller.sortKey == item.value ? Icons.check_box_outlined : Icons.check_box_outline_blank_rounded,
                color: shadColorScheme.foreground,
              ),
              onTap: () {
                if (controller.sortKey == item.value) {
                  controller.sortReversed = !controller.sortReversed;
                }

                controller.sortKey = item.value;
                controller.sortResults();

                Navigator.of(context).pop();
              },
            ),
          );
        },
      )),
    ));
  }

  void _openFilterSheet() {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
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
                      style: TextStyle(
                        color: shadColorScheme.foreground,
                        fontSize: ShadTheme.of(context).textTheme.h3.fontSize,
                      ),
                    )),
                CustomCard(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                                  '大小【${FileSizeConvert.parseToFileSize(controller.minSize)}-${FileSizeConvert.parseToFileSize(controller.maxSize)}】')),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // TextButton(
                              //     onPressed: () {
                              //       // todo 先计算出初始值，
                              //       controller.maxSize = controller.maxSize /
                              //           controller.calcSize *
                              //           1024;
                              //       controller.minSize = controller.minSize /
                              //           controller.calcSize *
                              //           1024;
                              //       controller.calcSize = 1024;
                              //       controller.filterResults();
                              //       controller.filterResults();
                              //     },
                              //     child: Text(
                              //       'KB',
                              //       style: TextStyle(
                              //           fontSize: 12,
                              //           color: controller.calcSize == 1024
                              //               ? Colors.orange
                              //               : ShadTheme.of(context)
                              //                   .colorScheme
                              //                   .foreground),
                              //     )),
                              TextButton(
                                onPressed: () {
                                  controller.maxSize = controller.maxSize / controller.calcSize * 1024 * 1024;
                                  controller.minSize = controller.minSize / controller.calcSize * 1024 * 1024;
                                  controller.calcSize = 1024 * 1024;
                                  controller.filterResults();
                                },
                                child: Text(
                                  'MB',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: controller.calcSize == 1024 * 1024
                                          ? Colors.orange
                                          : shadColorScheme.foreground),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  controller.maxSize = controller.maxSize / controller.calcSize * 1024 * 1024 * 1024;
                                  controller.minSize = controller.minSize / controller.calcSize * 1024 * 1024 * 1024;
                                  controller.calcSize = 1024 * 1024 * 1024;
                                  controller.filterResults();
                                },
                                child: Text(
                                  'GB',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: controller.calcSize == 1024 * 1024 * 1024
                                          ? Colors.orange
                                          : shadColorScheme.foreground),
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    controller.maxSize =
                                        controller.maxSize / controller.calcSize * 1024 * 1024 * 1024 * 1024;
                                    controller.minSize =
                                        controller.minSize / controller.calcSize * 1024 * 1024 * 1024 * 1024;
                                    controller.calcSize = 1024 * 1024 * 1024 * 1024;
                                    controller.filterResults();
                                  },
                                  child: Text(
                                    'TB',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: controller.calcSize == 1024 * 1024 * 1024 * 1024
                                            ? Colors.orange
                                            : shadColorScheme.foreground),
                                  )),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('最小'),
                          Expanded(
                            child: Slider(
                                min: 0,
                                max: 10,
                                divisions: 20,
                                value: controller.minSize / controller.calcSize,
                                label: FileSizeConvert.parseToFileSize(controller.minSize),
                                onChanged: (value) async {
                                  logger_helper.Logger.instance.d('minSize：$value');
                                  controller.minSize = value * controller.calcSize;
                                  // SPUtil.setDouble('searchFilterFileMinSize',
                                  //     controller.minSize);
                                  controller.filterResults();
                                  controller.update();
                                }),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('最大'),
                          Expanded(
                            child: Slider(
                                min: 1,
                                max: 100,
                                divisions: 20,
                                value: controller.maxSize / controller.calcSize,
                                label: FileSizeConvert.parseToFileSize(controller.maxSize),
                                onChanged: (value) async {
                                  logger_helper.Logger.instance.d('maxSize：$value');
                                  controller.maxSize = value * controller.calcSize;
                                  // SPUtil.setDouble('searchFilterFileMaxSize',
                                  //     controller.maxSize);
                                  controller.filterResults();
                                  controller.update();
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                if (controller.succeedResolution.isNotEmpty)
                  FilterItem(
                      name: '分辨率',
                      value: controller.succeedResolution,
                      selected: controller.selectedResolution,
                      onUpdate: () {
                        controller.filterResults();
                        controller.update();
                      }),
                if (controller.succeedTags.isNotEmpty)
                  FilterItem(
                      name: '标签',
                      value: controller.succeedTags,
                      selected: controller.selectedTags,
                      onUpdate: () {
                        controller.filterResults();
                        controller.update();
                      }),
                if (controller.hrResultList.isNotEmpty)
                  CustomCard(
                    child: SwitchListTile(
                      title: Text(
                        '排除 HR',
                        style: TextStyle(fontSize: 12, color: shadColorScheme.foreground),
                      ),
                      onChanged: (val) {
                        controller.hrKey = val;
                        controller.filterResults();
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

  Future<dynamic> _buildOperateDialog(DouBanSearchResult mediaInfo) async {
    await controller.getSubjectInfo(mediaInfo.target.id);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
        ),
        isScrollControlled: true,
        enableDrag: true, GetBuilder<AggSearchController>(builder: (controller) {
      return CustomCard(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.defaultDialog(
                              title: '海报预览',
                              content: InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    imageUrl: '$cacheServer${mediaInfo.target.coverUrl}',
                                    errorWidget: (context, url, error) =>
                                        const Image(image: AssetImage('assets/images/avatar.png')),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: '$cacheServer${mediaInfo.target.coverUrl}',
                              placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                color: shadColorScheme.primary,
                              )),
                              errorWidget: (context, url, error) => Image.asset('assets/images/avatar.png'),
                              width: 120,
                              height: 180,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.selectVideoDetail.title}${controller.selectVideoDetail.year}',
                              style: TextStyle(
                                  color: shadColorScheme.foreground, fontSize: 20, fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${controller.selectVideoDetail.director.map((e) => e.name).join('/')}/${controller.selectVideoDetail.genres}/${controller.selectVideoDetail.releaseDate}/${controller.selectVideoDetail.duration}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            // Text(
                            //   controller.selectVideoDetail.writer.map((e) => e.name).join(' / '),
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                            // Text(
                            //   controller.selectVideoDetail.actors.map((e) => e.name).join(' / '),
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                            if (controller.selectVideoDetail.alias != null)
                              Text(
                                controller.selectVideoDetail.alias!.join(' / '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            Text(controller.selectVideoDetail.region.toString()),
                            // Text(controller.selectVideoDetail.language.toString()),
                            // Text(controller.selectVideoDetail.season.toString()),
                            // Text(controller.selectVideoDetail.episode.toString()),
                            controller.selectVideoDetail.rate != null && controller.selectVideoDetail.rate!.isNotEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RatingBar.readOnly(
                                        initialRating: double.parse(controller.selectVideoDetail.rate!) / 2,
                                        filledIcon: Icons.star,
                                        emptyIcon: Icons.star_border,
                                        emptyColor: Colors.redAccent,
                                        filledColor: shadColorScheme.foreground,
                                        halfFilledColor: Colors.amberAccent,
                                        halfFilledIcon: Icons.star_half,
                                        maxRating: 5,
                                        size: 14,
                                      ),
                                      Text(
                                        '${controller.selectVideoDetail.evaluate} 人评价',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    '暂无评分',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                            Text('iMdb: ${controller.selectVideoDetail.imdb}'),
                          ],
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 178,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: [
                          ...controller.selectVideoDetail.pictures!.map((imgUrl) => CustomCard(
                                child: InkWell(
                                  onTap: () {
                                    Get.defaultDialog(
                                        content: InkWell(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl: '$cacheServer$imgUrl',
                                          errorWidget: (context, url, error) =>
                                              const Image(image: AssetImage('assets/images/avatar.png')),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: CachedNetworkImage(
                                      imageUrl: '$cacheServer$imgUrl',
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                        color: shadColorScheme.primary,
                                      )),
                                      height: 160,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...controller.selectVideoDetail.celebrities.map((worker) => CustomCard(
                                width: 100,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          Get.defaultDialog(
                                              title: '海报预览',
                                              content: InkWell(
                                                onTap: () => Navigator.of(context).pop(),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(5),
                                                  child: CachedNetworkImage(
                                                    imageUrl: '$cacheServer${worker.imgUrl}',
                                                    errorWidget: (context, url, error) =>
                                                        const Image(image: AssetImage('assets/images/avatar.png')),
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              ));
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: CachedNetworkImage(
                                            imageUrl: '$cacheServer${worker.imgUrl}',
                                            placeholder: (context, url) => Center(
                                                child: CircularProgressIndicator(
                                              color: shadColorScheme.primary,
                                            )),
                                            width: 100,
                                            height: 150,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      worker.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      worker.role!,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        controller.selectVideoDetail.hadSeen,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        controller.selectVideoDetail.wantLook,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...controller.selectVideoDetail.summary.map((e) => Text(e)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ShadButton(
                  onPressed: () async {
                    Get.back();
                    controller.goSearchPage(mediaInfo.target.id);
                  },
                  leading: Icon(
                    Icons.search,
                    color: shadColorScheme.foreground,
                  ),
                  size: ShadButtonSize.sm,
                  child: const Text('搜索'),
                ),
                ShadButton(
                  size: ShadButtonSize.sm,
                  onPressed: () async {
                    await _openMediaInfoDetail(mediaInfo);
                  },
                  leading: Icon(
                    Icons.info_outline,
                    color: shadColorScheme.foreground,
                  ),
                  child: const Text('详情'),
                ),
              ],
            ),
          ],
        ),
      );
    }));
  }

  Future<void> _openMediaInfoDetail(DouBanSearchResult mediaInfo) async {
    String url = mediaInfo.target.uri;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    if (!Platform.isIOS && !Platform.isAndroid) {
      Logger.instance.i('Explorer');
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？', colorText: shadColorScheme.foreground);
      }
    } else {
      Logger.instance.i('WebView');
      Get.toNamed(Routes.WEBVIEW, arguments: {'url': url});
    }
  }

  Widget showDouBanSearchInfo(DouBanSearchResult info) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        await _buildOperateDialog(info);
      },
      onDoubleTap: () async {
        if (!await launchUrl(Uri.parse(info.target.uri))) {
          throw Exception('Could not launch');
        }
      },
      onLongPress: () async {
        await controller.getSubjectInfo(info.target.id);
      },
      child: CustomCard(
          child: Slidable(
        key: ValueKey('${info.target.title}_${info.target.id}'),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async {
                await _buildOperateDialog(info);
              },
              backgroundColor: const Color(0xFF0392CF),
              foregroundColor: Colors.white,
              // icon: Icons.edit,
              label: '详情',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async {
                await controller.goSearchPage(info.target.id);
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              // icon: Icons.delete,
              label: '搜索',
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
                contentPadding: EdgeInsets.zero,
                tileColor: Colors.transparent,
                leading: InkWell(
                  onTap: () {
                    Get.defaultDialog(
                        title: '海报预览',
                        content: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: "$cacheServer${info.target.coverUrl}",
                              placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                color: shadColorScheme.primary,
                              )),
                              errorWidget: (context, url, error) =>
                                  const Image(image: AssetImage('assets/images/avatar.png')),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ));
                  },
                  child: SizedBox(
                    width: 55,
                    child: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CachedNetworkImage(
                          imageUrl: "$cacheServer${info.target.coverUrl}",
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                            color: shadColorScheme.primary,
                          )),
                          errorWidget: (context, url, error) =>
                              const Image(image: AssetImage('assets/images/avatar.png'), fit: BoxFit.fitWidth),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      CustomTextTag(
                        labelText: info.typeName,
                        backgroundColor: shadColorScheme.primary.withOpacity(opacity),
                        labelColor: shadColorScheme.primaryForeground,
                      ),
                    ]),
                  ),
                ),
                title: EllipsisText(
                  text: "${info.target.title}[${info.target.year}]",
                  ellipsis: "...",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    color: shadColorScheme.foreground,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5.0, right: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      info.target.rating.count > 0
                          ? Row(
                              children: [
                                Text(
                                  '评分：${info.target.rating.value}',
                                  style: TextStyle(
                                    color: shadColorScheme.foreground.withOpacity(0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "(${info.target.rating.count.toString()}评分)",
                                  style: TextStyle(
                                    color: shadColorScheme.foreground.withOpacity(0.8),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "暂无评分",
                              style: TextStyle(
                                color: shadColorScheme.foreground.withOpacity(0.8),
                                fontSize: 10,
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          info.target.cardSubtitle,
                          maxLines: 3,
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      )),
    );
  }

  void _showTMDBDetail(info) async {
    var mediaInfo = await controller.getTMDBDetail(info);
    String urlPrefix = 'https://media.themoviedb.org/t/p/w300_and_h450_bestv2';
    String posterPath = '$urlPrefix${mediaInfo.posterPath}';
    logger_helper.Logger.instance.d(mediaInfo);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.5;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      GetBuilder<AggSearchController>(builder: (controller) {
        return CustomCard(
            height: height,
            width: width,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Get.defaultDialog(
                                  title: '海报预览',
                                  content: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        imageUrl: posterPath,
                                        errorWidget: (context, url, error) =>
                                            const Image(image: AssetImage('assets/images/avatar.png')),
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: posterPath,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                    color: shadColorScheme.primary,
                                  )),
                                  errorWidget: (context, url, error) => Image.asset('assets/images/avatar.png'),
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${mediaInfo.title}${mediaInfo.releaseDate}',
                                  style: TextStyle(
                                      color: shadColorScheme.foreground, fontSize: 20, fontWeight: FontWeight.w700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Text(
                                //   '${mediaInfo.director.map((e) => e.name).join('/')}/${mediaInfo.genres}/${mediaInfo.releaseDate}/${mediaInfo.duration}',
                                //   overflow: TextOverflow.ellipsis,
                                //   maxLines: 2,
                                // ),
                                // Text(
                                //   mediaInfo.writer.map((e) => e.name).join(' / '),
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                                // Text(
                                //   mediaInfo.actors.map((e) => e.name).join(' / '),
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                                if (mediaInfo.genres.isNotEmpty)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Wrap(
                                      children: [
                                        ...mediaInfo.genres.map<CustomTextTag>((Genre item) => CustomTextTag(
                                              labelText: item.name,
                                            )),
                                      ],
                                    ),
                                  ),

                                // Text(mediaInfo.region.toString()),
                                // Text(mediaInfo.language.toString()),
                                // Text(mediaInfo.season.toString()),
                                // Text(mediaInfo.episode.toString()),
                                mediaInfo.voteCount > 0
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          RatingBar.readOnly(
                                            initialRating: mediaInfo.voteAverage / 2,
                                            filledIcon: Icons.star,
                                            emptyIcon: Icons.star_border,
                                            emptyColor: Colors.redAccent,
                                            filledColor: shadColorScheme.foreground,
                                            halfFilledColor: Colors.amberAccent,
                                            halfFilledIcon: Icons.star_half,
                                            maxRating: 5,
                                            size: 14,
                                          ),
                                          Text(
                                            '${mediaInfo.voteCount} 人评价',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        '暂无评分',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                        ),
                                      ),
                                if (mediaInfo.imdbId != null) Text('iMdb: ${mediaInfo.imdbId}'),
                              ],
                            ),
                          ))
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(mediaInfo.overview),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ShadButton(
                      size: ShadButtonSize.sm,
                      onPressed: () async {
                        Get.back();
                        controller.doTMDBSearch(mediaInfo);
                      },
                      leading: Icon(
                        Icons.search,
                        color: shadColorScheme.foreground,
                      ),
                      child: const Text('搜索'),
                    ),
                    ShadButton(
                      size: ShadButtonSize.sm,
                      onPressed: () async {
                        await _openMediaInfoDetail(mediaInfo);
                      },
                      leading: Icon(
                        Icons.info_outline,
                        color: shadColorScheme.foreground,
                      ),
                      child: const Text('详情'),
                    ),
                  ],
                ),
              ],
            ));
      }),
    );
  }

  Future<void> _doTmdbSearch() async {
    if (controller.tabController.index == 0) {
      if (controller.searchKeyController.text.isEmpty) {
        Get.snackbar("提示", "搜索关键字不能为空！");
        return;
      }
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      CommonResponse response = await controller.searchTMDB();
      if (response.succeed != true) {
        Get.snackbar(
          '警告',
          '${response.msg}，从豆瓣获取信息...',
          colorText: shadColorScheme.destructive,
        );
        await controller.doDouBanSearch();
      }
    } else {
      await controller.doWebsocketSearch();
      // await controller.doSearch();
    }
  }
}
