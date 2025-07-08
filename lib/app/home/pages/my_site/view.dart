import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/app/home/pages/dash_board/controller.dart';
import 'package:harvest/models/common_response.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../api/mysite.dart';
import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../common/meta_item.dart';
import '../../../../common/utils.dart';
import '../../../../utils/calc_weeks.dart';
import '../../../../utils/format_number.dart';
import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';
import '../../../../utils/string_utils.dart';
import '../../../routes/app_pages.dart';
import '../models/my_site.dart';
import '../models/website.dart';
import 'controller.dart';

class MySitePage extends StatefulWidget {
  const MySitePage({super.key});

  @override
  State<MySitePage> createState() => _MySitePagePageState();
}

class _MySitePagePageState extends State<MySitePage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final controller = Get.put(MySiteController());
  FocusNode blankNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<MySiteController>(builder: (controller) {
      return SafeArea(
        child: Scaffold(
          body: EasyRefresh(
            onRefresh: () async {
              controller.initFlag = false;
              controller.getSiteStatusFromServer();
            },
            child: Column(
              children: [
                if (controller.loadingFromServer)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                          child: GFLoader(size: 8, loaderstrokeWidth: 2)),
                      const SizedBox(width: 5),
                      Text(
                        '当前为缓存数据，正在从服务器加载',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: Row(
                    children: [
                      GFToggle(
                          enabledText: '内置',
                          disabledText: '浏览器',
                          enabledTextStyle: TextStyle(
                              fontSize: 8,
                              color: Theme.of(context).colorScheme.onPrimary),
                          disabledTextStyle: TextStyle(
                              fontSize: 5,
                              color: Theme.of(context).colorScheme.onPrimary),
                          type: GFToggleType.square,
                          value: controller.openByInnerExplorer,
                          onChanged: (bool? value) {
                            controller.openByInnerExplorer = value!;
                            SPUtil.setBool('openByInnerExplorer', value);
                            controller.update();
                          }),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            FocusScope.of(context).requestFocus(blankNode);
                          },
                          child: SizedBox(
                            height: 32,
                            child: TextField(
                              focusNode: blankNode,
                              controller: controller.searchController,
                              style: const TextStyle(fontSize: 12),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                // labelText: '搜索',
                                isDense: true,
                                hintText: '输入关键词...',
                                labelStyle: const TextStyle(fontSize: 12),
                                hintStyle: const TextStyle(fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 5),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 14,
                                ),
                                // suffix: ,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          '计数：${controller.showStatusList.length}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange)),
                                    ],
                                  ),
                                ),
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
                              onChanged: (value) {
                                Logger.instance.d('搜索框内容变化：$value');
                                controller.searchKey = value;
                                controller.filterByKey();
                              },
                            ),
                          ),
                        ),
                      ),
                      if (controller.searchKey.isNotEmpty)
                        IconButton(
                            onPressed: () {
                              controller.searchController.text =
                                  controller.searchController.text.substring(
                                      0,
                                      controller.searchController.text.length -
                                          1);
                              controller.searchKey =
                                  controller.searchController.text;
                              controller.filterByKey();
                              controller.update();
                            },
                            icon: const Icon(
                              Icons.backspace_outlined,
                              size: 18,
                            ))
                    ],
                  ),
                ),
                Expanded(
                  child: controller.isLoaded
                      ? Center(
                          child: GFLoader(
                            type: GFLoaderType.custom,
                            loaderIconOne: Icon(
                              Icons.circle_outlined,
                              size: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8),
                            ),
                          ),
                        )
                      : controller.showStatusList.isEmpty
                          ? ListView(
                              children: const [
                                Center(child: Text('没有符合条件的数据！'))
                              ],
                            )
                          : GetBuilder<MySiteController>(builder: (controller) {
                              return ReorderableListView.builder(
                                onReorder: (int oldIndex, int newIndex) async {
                                  final item = controller.showStatusList
                                      .removeAt(oldIndex);
                                  Logger.instance.d('本站排序 ID：${item.sortId}');
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1; // 移动时修正索引，因为item已被移除
                                  }

                                  final nextItem =
                                      controller.showStatusList[newIndex];
                                  MySite newItem;
                                  if (controller.sortReversed) {
                                    newItem = item.copyWith(
                                        sortId: nextItem.sortId - 1 > 0
                                            ? nextItem.sortId - 1
                                            : 0);
                                  } else {
                                    newItem = item.copyWith(
                                        sortId: nextItem.sortId + 1);
                                  }
                                  controller.showStatusList
                                      .insert(newIndex, item);
                                  controller.update();
                                  if (await controller
                                      .saveMySiteToServer(newItem)) {
                                    await controller.getSiteStatusFromServer();
                                  }
                                },
                                itemCount: controller.showStatusList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  MySite mySite =
                                      controller.showStatusList[index];
                                  return showSiteDataInfo(mySite);
                                },
                              );
                            }),
                ),
                if (!kIsWeb && Platform.isIOS) const SizedBox(height: 10),
                const SizedBox(height: 50),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: _buildBottomButtonBar(),
        ),
      );
    });
  }

  _buildBottomButtonBar() {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              Future.microtask(() async {
                Logger.instance.i('开始从数据库加载数据...');
                controller.loadingFromServer = true;
                controller.update(); // UI 更新
                // 模拟后台获取数据
                await controller.getWebSiteListFromServer();
                await controller.getSiteStatusFromServer();
                controller.loadingFromServer = false;
                Logger.instance.i('从数据库加载数据完成！');
                controller.update(); // UI 更新
              });
            },
            icon: const Icon(
              Icons.cloud_download_outlined,
              size: 20,
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 5)),
              side: WidgetStateProperty.all(BorderSide.none),
            ),
            label: const Text('加载'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showFilterBottomSheet();
            },
            icon: const Icon(
              Icons.filter_tilt_shift,
              size: 20,
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 5)),
              side: WidgetStateProperty.all(BorderSide.none),
            ),
            label: const Text('筛选'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showSortBottomSheet();
            },
            icon: const Icon(
              Icons.swap_vert_circle_outlined,
              size: 20,
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 5)),
              side: WidgetStateProperty.all(BorderSide.none),
            ),
            label: const Text('排序'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await _showEditBottomSheet();
            },
            icon: const Icon(
              Icons.add_circle_outline,
              size: 20,
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 5)),
              side: WidgetStateProperty.all(BorderSide.none),
            ),
            label: const Text('添加'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<MySiteController>();
    super.dispose();
  }

  _openSitePage(MySite mySite, WebSite website) async {
    String path;
    if (mySite.mail! > 0 && !website.pageMessage.contains('api')) {
      path = website.pageMessage.replaceFirst("{}", mySite.userId.toString());
    } else {
      path = website.pageIndex;
    }
    String url =
        '${mySite.mirror!.endsWith('/') ? mySite.mirror : '${mySite.mirror}/'}$path';
    if (mySite.mirror!.contains('m-team')) {
      url = url.replaceFirst("api", "xp");
    }
    if (kIsWeb || !controller.openByInnerExplorer) {
      Logger.instance.d('使用外部浏览器打开');
      Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？',
            colorText: Theme.of(context).colorScheme.primary);
      }
    } else {
      Logger.instance.d('使用内置浏览器打开');
      Get.toNamed(Routes.WEBVIEW, arguments: {
        'url': url,
        'info': null,
        'mySite': mySite,
        'website': website
      });
    }
  }

  Widget showSiteDataInfo(MySite mySite) {
    StatusInfo? status;
    WebSite? website = controller.webSiteList[mySite.site];

    // Logger.instance.d('${mySite.nickname} - ${website?.name}');
    if (website == null) {
      return CustomCard(
        key: Key("${mySite.id}-${mySite.site}"),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: const Image(
            image: AssetImage('assets/images/avatar.png'),
            width: 32,
            height: 32,
          ),
          title: Text(
            mySite.nickname,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
          subtitle: Text(
            '没有找到这个站点的配置文件，请清理站点配置缓存后重新加载数据！',
            style: TextStyle(
              color: Colors.red.shade200,
              fontSize: 10,
            ),
          ),
          trailing: IconButton(
              onPressed: () async {
                await _showEditBottomSheet(mySite: mySite);
              },
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
              )),
        ),
      );
    }
    if (mySite.statusInfo.isNotEmpty) {
      status = mySite.latestStatusInfo;
    }
    if (status == null) {
      Logger.instance.d('${mySite.nickname} - ${mySite.statusInfo}');
    }
    LevelInfo? level = website.level?[status?.myLevel];
    List<LevelInfo> rights = [];
    LevelInfo? nextLevel;
    if (level?.levelId == 0) {
      rights = [...?website.level?.values];
    } else if (level == null) {
    } else {
      rights = [
        ...?website.level?.values
            .where((item) => item.levelId > 0 && item.levelId <= level.levelId)
      ];
      rights.sort((a, b) => b.levelId.compareTo(a.levelId));
      nextLevel = website.level?.values
          .firstWhereOrNull((item) => item.levelId == level.levelId + 1);
    }

    int nextLevelToDownloadedByte =
        FileSizeConvert.parseToByte(nextLevel?.downloaded ?? "0");
    int nextLevelToUploadedByte =
        FileSizeConvert.parseToByte(nextLevel?.uploaded ?? "0");
    int calcToUploaded =
        (max(nextLevelToDownloadedByte, status?.downloaded ?? 0) *
                (nextLevel?.ratio ?? 0))
            .toInt();
    nextLevelToUploadedByte = max(nextLevelToUploadedByte, calcToUploaded);
    // Logger.instance.d(
    //     '${FileSizeConvert.parseToFileSize(status?.uploaded)}(${status?.uploaded})/${FileSizeConvert.parseToFileSize(nextLevelToUploadedByte)}($nextLevelToUploadedByte)');
    var toUpgradeTime = DateTime.parse(mySite.timeJoin)
        .add(Duration(days: (nextLevel?.days ?? 0) * 7));
    return CustomCard(
      key: Key("${mySite.id}-${mySite.site}"),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(children: [
        ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: InkWell(
            onTap: () => _openSitePage(mySite, website),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: website.logo.startsWith('http')
                    ? website.logo
                    : '${mySite.mirror}${website.logo}',
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
            ),
          ),
          onLongPress: () => _openSitePage(mySite, website),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              mySite.latestActive != null
                  ? Tooltip(
                      message:
                          '最后访问时间：${calculateTimeElapsed(mySite.latestActive.toString())}',
                      child: Text(
                        mySite.nickname,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    )
                  : Text(
                      mySite.nickname,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
              if (mySite.mail! > 0)
                Row(
                  children: [
                    const Icon(
                      Icons.mail,
                      size: 12,
                    ),
                    Text(
                      '${mySite.mail}',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              if (mySite.notice! > 0)
                Row(
                  children: [
                    const Icon(
                      Icons.notifications,
                      size: 12,
                    ),
                    Text(
                      '${mySite.notice}',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              if (status != null && level == null)
                Text(
                  website.level?[status.myLevel]?.level ?? status.myLevel,
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              if (status != null && level != null)
                CustomPopup(
                  showArrow: true,
                  barrierColor: Colors.transparent,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  content: SingleChildScrollView(
                    child: SizedBox(
                        width: 200,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (nextLevel != null) ...[
                              PopupMenuItem<String>(
                                height: 13,
                                child: Text("下一等级：${nextLevel.level}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                              ),
                              // if (status.uploaded < nextLevelToUploadedByte)
                              PopupMenuItem<String>(
                                height: 13,
                                child: Text(
                                    '上传量：${FileSizeConvert.parseToFileSize(status.uploaded)}/${FileSizeConvert.parseToFileSize(nextLevelToUploadedByte)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: status.uploaded <
                                              max(nextLevelToUploadedByte,
                                                  calcToUploaded)
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                    )),
                              ),
                              // if (status.downloaded < nextLevelToDownloadedByte)
                              PopupMenuItem<String>(
                                height: 13,
                                child: Text(
                                    '下载量：${FileSizeConvert.parseToFileSize(status.downloaded)}/${FileSizeConvert.parseToFileSize(nextLevelToDownloadedByte)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: status.downloaded <
                                              nextLevelToDownloadedByte
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                    )),
                              ),
                              // if (status.uploaded / status.downloaded <
                              //     nextLevel.ratio)
                              //   PopupMenuItem<String>(
                              //     height: 13,
                              //     child: Text(
                              //         '分享率：${(status.uploaded / status.downloaded).toStringAsFixed(2)}/${nextLevel.ratio}',
                              //         style: TextStyle(
                              //           fontSize: 10,
                              //           color:
                              //               Theme.of(context).colorScheme.error,
                              //         )),
                              //   ),
                              if (nextLevel.torrents > 0)
                                PopupMenuItem<String>(
                                  height: 13,
                                  child: Text(
                                      '需发种数量：${status.published}/${nextLevel.torrents}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: status.published <
                                                nextLevel.torrents
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      )),
                                ),
                              if (nextLevel.score > 0)
                                PopupMenuItem<String>(
                                  height: 13,
                                  child: Text(
                                      '做种积分：${formatNumber(status.myScore)}/${formatNumber(nextLevel.score)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: status.myScore < nextLevel.score
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      )),
                                ),
                              if (nextLevel.bonus > 0)
                                PopupMenuItem<String>(
                                  height: 13,
                                  child: Text(
                                      '魔力值：${status.myBonus}/${nextLevel.bonus}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: status.myBonus < nextLevel.bonus
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      )),
                                ),
                              if (nextLevel.days > 0)
                                PopupMenuItem<String>(
                                  height: 13,
                                  child: Text(
                                      '升级日期：${DateFormat('yyyy-MM-dd').format(DateTime.now())}/${DateFormat('yyyy-MM-dd').format(toUpgradeTime)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: DateTime.now()
                                                .isBefore(toUpgradeTime)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      )),
                                ),
                              if (level.keepAccount != true &&
                                  nextLevel.keepAccount)
                                PopupMenuItem<String>(
                                  height: 13,
                                  child: Text('保留账号：${nextLevel.keepAccount}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      )),
                                ),
                              if (level.graduation != true &&
                                  nextLevel.graduation)
                                PopupMenuItem<String>(
                                  height: 13,
                                  child: Text('毕业：${nextLevel.graduation}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      )),
                                ),
                              PopupMenuItem<String>(
                                height: 13,
                                child: Text('即将获得：${nextLevel.rights}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    )),
                              ),
                            ],
                            ...rights
                                .where((el) =>
                                    el.rights.trim() != '无' &&
                                    !el.rights.trim().startsWith('同') &&
                                    !el.rights.trim().contains('同上'))
                                .map((LevelInfo item) => PopupMenuItem<String>(
                                      height: 13,
                                      child: Text(item.rights,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: item.graduation
                                                ? Colors.orange
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                          )),
                                    ))
                          ],
                        )),
                  ),
                  child: Text(
                    website.level?[status.myLevel]?.level ?? status.myLevel,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: status == null
              ? Text(
                  '新站点，还没有数据哦',
                  style: TextStyle(
                    color: Colors.red.shade200,
                    fontSize: 10,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DateTime.parse(mySite.timeJoin) != DateTime(2024, 2, 1)
                        ? Text(
                            '⌚️${calcWeeksDays(mySite.timeJoin)}',
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          )
                        : const Text(
                            '⌚️获取失败！',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                            ),
                          ),
                    if (level?.keepAccount == true)
                      const Text(
                        '🔥保号',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                        ),
                      ),
                    if (level?.graduation == true)
                      const Text(
                        '🎓毕业',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber,
                        ),
                      ),
                    if (status.invitation > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.person_add_alt_outlined,
                            size: 12,
                          ),
                          Text(
                            '${status.invitation}',
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
          trailing: _buildMySiteOperate(website, mySite),
        ),
        if (status != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            textBaseline: TextBaseline.ideographic,
                            children: [
                              const Icon(
                                Icons.upload_outlined,
                                color: Colors.green,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${FileSizeConvert.parseToFileSize(status.uploaded)} (${status.seed})',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.download_outlined,
                                color: Colors.red,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${FileSizeConvert.parseToFileSize(status.downloaded)} (${status.leech})',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.ios_share,
                                color:
                                    status.ratio > 1 ? null : Colors.deepOrange,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${status.published}(${formatNumber(status.ratio)})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: status.ratio > 1
                                      ? null
                                      : Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                FileSizeConvert.parseToFileSize(
                                    status.seedVolume),
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            textBaseline: TextBaseline.ideographic,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                formatNumber(status.bonusHour),
                                // '(${  status.siteSpFull != null && status.siteSpFull! > 0 ? ((status.statusBonusHour! / status.siteSpFull!) * 100).toStringAsFixed(2) : '0'}%)',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              if (website.spFull > 0 && status.bonusHour > 0)
                                Text(
                                  // formatNumber(status.bonusHour),
                                  '(${((status.bonusHour / website.spFull) * 100).toStringAsFixed((status.bonusHour / website.spFull) * 100 > 1 ? 0 : 2)}%)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            textBaseline: TextBaseline.ideographic,
                            children: [
                              const Icon(
                                Icons.score,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${formatNumber(status.myBonus, fixed: 0)}(${formatNumber(status.myScore, fixed: 0)})',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '最近更新：${calculateTimeElapsed(status.updatedAt.toString())}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 10.5,
                      ),
                    ),
                    if (status.myHr != '' && status.myHr != "0")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'HR: ${status.myHr.replaceAll('区', '').replaceAll('专', '').replaceAll('H&R', '').trim()}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.red,
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
      ]),
    );
  }

  Widget _buildMySiteOperate(WebSite website, MySite mySite) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool signed = mySite.getSignMaxKey() == today || mySite.signIn == false;
    RxBool siteRefreshing = false.obs;
    return CustomPopup(
      showArrow: true,
      // contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      barrierColor: Colors.transparent,
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
          width: 100,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (website.signIn && mySite.signIn && !signed)
              PopupMenuItem<String>(
                child: const Text('我要签到'),
                onTap: () async {
                  siteRefreshing.value = true;
                  CommonResponse res = await signIn(mySite.id);
                  if (res.succeed) {
                    Get.snackbar('签到成功', '${mySite.nickname} 签到信息：${res.msg}',
                        colorText: Theme.of(context).colorScheme.primary);
                    controller.initFlag = false;
                    controller.getSiteStatusFromServer();
                  } else {
                    Get.snackbar(
                        '签到失败', '${mySite.nickname} 签到任务执行出错啦：${res.msg}',
                        colorText: Theme.of(context).colorScheme.error);
                  }
                  siteRefreshing.value = false;
                },
              ),
            if (website.signIn && mySite.signIn)
              PopupMenuItem<String>(
                child: const Text('签到历史'),
                onTap: () async {
                  _showSignHistory(mySite);
                },
              ),
            PopupMenuItem<String>(
              child: const Text('更新数据'),
              onTap: () async {
                siteRefreshing.value = true;
                CommonResponse res = await getNewestStatus(mySite.id);
                if (res.succeed) {
                  Get.snackbar('站点数据刷新成功', '${mySite.nickname} 数据刷新：${res.msg}',
                      colorText: Theme.of(context).colorScheme.primary);
                  controller.initFlag = false;
                  await controller.getSiteStatusFromServer();
                  Future.delayed(Duration(seconds: 2), () async {
                    DashBoardController dController = Get.find();
                    dController.initChartData();
                    dController.update();
                  });
                } else {
                  Get.snackbar(
                      '站点数据刷新失败', '${mySite.nickname} 数据刷新出错啦：${res.msg}',
                      colorText: Theme.of(context).colorScheme.error);
                }
                siteRefreshing.value = false;
              },
            ),
            if (website.repeatTorrents && mySite.repeatTorrents)
              PopupMenuItem<String>(
                child: const Text('本站辅种'),
                onTap: () async {
                  CommonResponse res = await repeatSite(mySite.id);

                  if (res.succeed) {
                    Get.snackbar('辅种任务发送成功', '${mySite.nickname} ${res.msg}',
                        colorText: Theme.of(context).colorScheme.primary);
                  } else {
                    Get.snackbar(
                        '辅种任务发送失败', '${mySite.nickname} 辅种出错啦：${res.msg}',
                        colorText: Theme.of(context).colorScheme.error);
                  }
                },
              ),
            PopupMenuItem<String>(
              child: const Text('历史数据'),
              onTap: () async {
                _showStatusHistory(mySite);
              },
            ),
            PopupMenuItem<String>(
              child: const Text('编辑站点'),
              onTap: () async {
                await _showEditBottomSheet(mySite: mySite);
              },
            ),
          ])),
      child: Obx(
        () => siteRefreshing.value
            ? SizedBox(
                width: 36,
                child: Center(
                  child: GFLoader(
                    size: 28,
                    loaderColorOne: Theme.of(context).colorScheme.primary,
                  ),
                ))
            : Icon(
                Icons.widgets_outlined,
                size: 36,
                color: signed == true ? Colors.green : Colors.amber,
              ),
      ),
    );
  }

  Future<void> _showEditBottomSheet({MySite? mySite}) async {
    if (mySite != null) {
      CommonResponse res = await getMySiteByIdApi(mySite.id);
      if (!res.succeed) {
        Get.snackbar('获取站点信息失败', "获取站点信息失败，请更新站点列表后重试！${res.msg}",
            colorText: Theme.of(context).colorScheme.error);
        return;
      }
      mySite = res.data;
    }

    // 获取已添加的站点名称
    List<String> hasKeys =
        controller.mySiteList.map((element) => element.site).toList();
    // 筛选活着的和未添加过的站点
    List<WebSite> webSiteList =
        controller.webSiteList.values.where((item) => item.alive).toList();
    // 如果是编辑模式，
    if (mySite == null) {
      webSiteList.removeWhere((item) => hasKeys.contains(item.name));
    }
    webSiteList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final siteController = TextEditingController(text: mySite?.site ?? '');
    final apiKeyController = TextEditingController(text: mySite?.authKey ?? '');
    final sortIdController =
        TextEditingController(text: mySite?.sortId.toString() ?? '1');
    RxBool isLoading = false.obs;
    final nicknameController =
        TextEditingController(text: mySite?.nickname ?? '');
    final passkeyController =
        TextEditingController(text: mySite?.passkey ?? '');
    final userIdController = TextEditingController(text: mySite?.userId ?? '');
    final usernameController =
        TextEditingController(text: mySite?.username ?? '');
    final emailController = TextEditingController(text: mySite?.email ?? '');
    final userAgentController = TextEditingController(
        text: mySite?.userAgent ??
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0');
    final rssController = TextEditingController(text: mySite?.rss ?? '');
    final proxyController = TextEditingController(text: mySite?.proxy ?? '');
    final torrentsController =
        TextEditingController(text: mySite?.torrents ?? '');
    final cookieController = TextEditingController(text: mySite?.cookie ?? '');
    final mirrorController = TextEditingController(text: mySite?.mirror ?? '');
    Rx<WebSite?> selectedSite = (mySite != null
            ? controller.webSiteList[mySite.site]
            : (webSiteList.isNotEmpty ? webSiteList.first : null))
        .obs;
    RxList<String>? urlList = selectedSite.value != null
        ? selectedSite.value?.url.obs
        : <String>[].obs;
    RxBool getInfo = mySite != null ? mySite.getInfo.obs : true.obs;
    RxBool available = mySite != null
        ? mySite.available.obs
        : (selectedSite.value?.alive ?? false).obs;
    RxBool signIn = mySite != null ? mySite.signIn.obs : true.obs;
    RxBool brushRss = mySite != null ? mySite.brushRss.obs : false.obs;
    RxBool brushFree = mySite != null ? mySite.brushFree.obs : false.obs;
    RxBool packageFile = mySite != null ? mySite.packageFile.obs : false.obs;
    RxBool repeatTorrents =
        mySite != null ? mySite.repeatTorrents.obs : true.obs;
    RxBool hrDiscern = mySite != null ? mySite.hrDiscern.obs : false.obs;
    RxBool showInDash = mySite != null ? mySite.showInDash.obs : true.obs;
    RxBool searchTorrents =
        mySite != null ? mySite.searchTorrents.obs : true.obs;
    RxBool manualInput = false.obs;
    RxBool doSaveLoading = false.obs;
    Get.bottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      isScrollControlled: true,
      CustomCard(
        padding: const EdgeInsets.all(20),
        height: selectedSite.value != null ? 500 : 120,
        child: Column(
          children: [
            ListTile(
              title: Text(
                mySite != null ? '编辑站点：${mySite.nickname}' : '添加站点',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              trailing: Obx(() {
                return isLoading.value
                    ? const Align(
                        alignment: Alignment.centerRight,
                        child: GFLoader(
                          size: 18,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () async {
                          isLoading.value = true;
                          await controller.getWebSiteListFromServer();
                          controller.update();
                          isLoading.value = false;
                        },
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 5)),
                          side: WidgetStateProperty.all(BorderSide.none),
                        ),
                        icon: Icon(
                          Icons.cloud_download_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          '刷新站点列表',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
              }),
            ),
            if (selectedSite.value != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8),
                          child: DropdownSearch<WebSite>(
                            items: (String filter, _) => webSiteList,
                            selectedItem: selectedSite.value,
                            compareFn: (item, sItem) => item.name == sItem.name,
                            itemAsString: (WebSite? item) => item!.name,
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: '选择站点',
                                filled: true,
                                fillColor: Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor,
                              ),
                            ),
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                              itemBuilder: (ctx, item, isSelected, _) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      item.name[0],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                  selected: isSelected,
                                  title: Text(
                                    item.name,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                            onChanged: (WebSite? item) async {
                              siteController.text = item!.name;
                              selectedSite.value = item;
                              urlList?.value = selectedSite.value!.url;
                              mirrorController.text = urlList![0];
                              nicknameController.text =
                                  selectedSite.value!.name;
                              signIn.value = selectedSite.value!.signIn;
                              getInfo.value = selectedSite.value!.getInfo;
                              repeatTorrents.value =
                                  selectedSite.value!.repeatTorrents;
                              searchTorrents.value =
                                  selectedSite.value!.searchTorrents;
                              available.value = selectedSite.value!.alive;
                              controller.update();
                            },
                          ),
                        ),
                        if (urlList!.isNotEmpty)
                          Obx(() {
                            return Row(
                              children: [
                                Expanded(
                                  child: CustomPickerField(
                                    controller: mirrorController,
                                    labelText: '选择网址',
                                    data: urlList,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    manualInput.value = !manualInput.value;
                                    controller.update();
                                  },
                                  icon: Icon(
                                    manualInput.value
                                        ? Icons.back_hand_outlined
                                        : Icons.front_hand,
                                  ),
                                )
                              ],
                            );
                          }),
                        Obx(() => manualInput.value
                            ? CustomTextField(
                                controller: mirrorController,
                                labelText: '手动输入 - 注意：浏览器插件自动导入可能无法识别',
                              )
                            : SizedBox.shrink()),
                        CustomTextField(
                          controller: nicknameController,
                          labelText: '站点昵称',
                        ),
                        CustomTextField(
                          controller: usernameController,
                          maxLength: 128,
                          labelText: '用户名称',
                        ),
                        CustomTextField(
                          controller: userIdController,
                          maxLength: 128,
                          labelText: 'User ID',
                        ),
                        CustomTextField(
                          controller: emailController,
                          maxLength: 128,
                          labelText: '邮箱地址',
                        ),
                        CustomTextField(
                          controller: sortIdController,
                          labelText: '排序 ID',
                        ),
                        CustomTextField(
                          controller: passkeyController,
                          maxLength: 128,
                          labelText: 'Passkey',
                        ),
                        CustomTextField(
                          controller: apiKeyController,
                          maxLength: 128,
                          labelText: 'AuthKey',
                        ),
                        CustomTextField(
                          controller: userAgentController,
                          labelText: 'User Agent',
                        ),
                        // CustomTextField(
                        //   controller: rssController,
                        //   labelText: 'RSS',
                        // ),
                        // CustomTextField(
                        //   controller: torrentsController,
                        //   labelText: 'Torrents',
                        // ),
                        CustomTextField(
                          controller: cookieController,
                          labelText: 'Cookie',
                        ),
                        CustomTextField(
                          controller: proxyController,
                          labelText: 'HTTP代理',
                        ),
                        const SizedBox(height: 15),
                        Wrap(spacing: 12, runSpacing: 8, children: [
                          selectedSite.value!.alive
                              ? ChoiceChip(
                                  label: const Text('可用'),
                                  selected: selectedSite.value!.alive
                                      ? available.value
                                      : false,
                                  onSelected: (value) {
                                    selectedSite.value!.alive
                                        ? available.value = value
                                        : available.value = false;
                                  },
                                )
                              : ChoiceChip(
                                  label: const Text('可用'),
                                  selected: false,
                                  onSelected: (value) {
                                    Logger.instance.d(
                                        "站点可用性：${selectedSite.value!.alive}");
                                    available.value = selectedSite.value!.alive;
                                  },
                                ),
                          ChoiceChip(
                            label: const Text('Dash'),
                            selected: showInDash.value,
                            onSelected: (value) {
                              showInDash.value = value;
                            },
                          ),
                          ChoiceChip(
                            label: const Text('数据'),
                            selected: getInfo.value,
                            onSelected: (value) {
                              getInfo.value = value;
                            },
                          ),
                          if (selectedSite.value!.searchTorrents)
                            ChoiceChip(
                              label: const Text('搜索'),
                              selected: searchTorrents.value,
                              onSelected: (value) {
                                searchTorrents.value = value;
                              },
                            ),
                          if (selectedSite.value!.signIn)
                            ChoiceChip(
                              label: const Text('签到'),
                              selected: signIn.value,
                              onSelected: (value) {
                                signIn.value = value;
                              },
                            ),
                          if (selectedSite.value!.repeatTorrents)
                            ChoiceChip(
                              label: const Text('辅种'),
                              selected: repeatTorrents.value,
                              onSelected: (value) {
                                repeatTorrents.value = value;
                              },
                            ),
                        ]),
                      ],
                    );
                  }),
                ),
              ),
            const SizedBox(height: 5),
            OverflowBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.cancel,
                      color: Theme.of(context).colorScheme.onPrimary),
                  label: Text(
                    '取消',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                if (mySite != null)
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.error),
                    ),
                    onPressed: () async {
                      Get.defaultDialog(
                          title: '删除站点：${mySite?.nickname}',
                          radius: 5,
                          titleStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900),
                          middleText: '确定要删除吗？',
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Get.back(result: false);
                              },
                              child: const Text('取消'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Get.back(result: true);
                                Navigator.of(context).pop();
                                await controller.removeSiteFromServer(mySite!);
                              },
                              child: const Text('确认'),
                            ),
                          ]);
                    },
                    child: Text(
                      '删除',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ),
                if (selectedSite.value != null)
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.tertiary),
                    ),
                    icon: Obx(() {
                      return doSaveLoading.value
                          ? GFLoader(
                              size: 20,
                              loaderColorOne:
                                  Theme.of(context).colorScheme.tertiary,
                            )
                          : Icon(Icons.save,
                              color: Theme.of(context).colorScheme.onTertiary);
                    }),
                    label: Text(
                      '保存',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                    onPressed: () async {
                      doSaveLoading.value = true;
                      if (mySite != null) {
                        mySite = mySite?.copyWith(
                          site: siteController.text.trim(),
                          mirror: mirrorController.text.trim(),
                          nickname: nicknameController.text.trim(),
                          passkey: passkeyController.text.trim(),
                          authKey: apiKeyController.text.trim(),
                          userId: userIdController.text.trim(),
                          username: usernameController.text.trim(),
                          email: emailController.text.trim(),
                          sortId: int.parse(sortIdController.text.trim()),
                          userAgent: userAgentController.text.trim(),
                          proxy: proxyController.text.trim(),
                          rss: rssController.text.trim(),
                          torrents: torrentsController.text.trim(),
                          cookie: cookieController.text.trim(),
                          getInfo: getInfo.value,
                          signIn: signIn.value,
                          brushRss: brushRss.value,
                          brushFree: brushFree.value,
                          packageFile: packageFile.value,
                          repeatTorrents: repeatTorrents.value,
                          hrDiscern: hrDiscern.value,
                          showInDash: showInDash.value,
                          searchTorrents: searchTorrents.value,
                          available: available.value,
                        );
                      } else {
                        // 如果 mySite 为空，表示是添加操作
                        mySite = MySite(
                          site: siteController.text.trim(),
                          mirror: mirrorController.text.trim(),
                          nickname: nicknameController.text.trim(),
                          passkey: passkeyController.text.trim(),
                          authKey: apiKeyController.text.trim(),
                          userId: userIdController.text.trim(),
                          username: usernameController.text.trim(),
                          email: emailController.text.trim(),
                          sortId: int.parse(sortIdController.text.trim()),
                          userAgent: userAgentController.text.trim(),
                          proxy: proxyController.text.trim(),
                          rss: rssController.text.trim(),
                          torrents: torrentsController.text.trim(),
                          cookie: cookieController.text.trim(),
                          getInfo: getInfo.value,
                          signIn: signIn.value,
                          brushRss: brushRss.value,
                          brushFree: brushFree.value,
                          packageFile: packageFile.value,
                          repeatTorrents: repeatTorrents.value,
                          hrDiscern: hrDiscern.value,
                          showInDash: showInDash.value,
                          searchTorrents: searchTorrents.value,
                          available: available.value,
                          id: 0,
                          removeTorrentRules: {},
                          timeJoin: '',
                          mail: 0,
                          notice: 0,
                          signInInfo: {},
                          statusInfo: {},
                        );
                      }
                      Logger.instance.d(mySite?.toJson());
                      if (await controller.saveMySiteToServer(mySite!)) {
                        Navigator.of(context).pop();
                        controller.initFlag = false;
                        controller.getSiteStatusFromServer();
                        Future.delayed(Duration(seconds: 2), () async {
                          DashBoardController dController = Get.find();
                          dController.initChartData();
                          dController.update();
                        });
                      }
                      doSaveLoading.value = false;
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    Get.bottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        CustomCard(
          width: 550,
          child: Column(children: [
            Expanded(
              child: GetBuilder<MySiteController>(builder: (controller) {
                return ListView.builder(
                  itemCount: controller.siteSortOptions.length,
                  itemBuilder: (context, index) {
                    MetaDataItem item = controller.siteSortOptions[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ListTile(
                        title: Text(item.name),
                        dense: true,
                        selectedColor: Colors.amber,
                        selected: controller.sortKey == item.value,
                        leading: controller.sortReversed
                            ? const Icon(Icons.trending_up)
                            : const Icon(Icons.trending_down),
                        trailing: controller.sortKey == item.value
                            ? const Icon(Icons.check_box_outlined)
                            : const Icon(Icons.check_box_outline_blank_rounded),
                        onTap: () {
                          if (controller.sortKey == item.value!) {
                            controller.sortReversed = !controller.sortReversed;
                          }
                          controller.sortKey = item.value!;
                          controller.sortStatusList();

                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ]),
        ));
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        CustomCard(
          width: 550,
          child: Column(children: [
            Expanded(child: GetBuilder<MySiteController>(builder: (controller) {
              return ListView.builder(
                  itemCount: controller.filterOptions.length,
                  itemBuilder: (context, index) {
                    MetaDataItem item = controller.filterOptions[index];
                    return ListTile(
                        title: Text(item.name),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        dense: true,
                        trailing: controller.filterKey == item.value
                            ? const Icon(Icons.check_box_outlined)
                            : const Icon(Icons.check_box_outline_blank_rounded),
                        selectedColor: Colors.amber,
                        selected: controller.filterKey == item.value,
                        onTap: () {
                          controller.filterKey = item.value!;
                          controller.filterByKey();

                          Navigator.of(context).pop();
                        });
                  });
            }))
          ]),
        ));
  }

  void _showSignHistory(MySite mySite) {
    List<String> signKeys = mySite.signInInfo.keys.toList();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    signKeys.sort((a, b) => b.compareTo(a));
    Get.bottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        isScrollControlled: true,
        CustomCard(
            width: double.infinity,
            child: Column(children: [
              Text(
                "${mySite.nickname} [累计自动签到${mySite.signInInfo.length}天]",
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: signKeys.length,
                      itemBuilder: (context, index) {
                        String signKey = signKeys[index];
                        SignInInfo? item = mySite.signInInfo[signKey];
                        return CustomCard(
                          child: ListTile(
                              title: Text(
                                item!.info,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: signKey == today
                                        ? Colors.amber
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                              subtitle: Text(
                                item.updatedAt,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: signKey == today
                                        ? Colors.amber
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                              selected: signKey == today,
                              selectedColor: Colors.amber,
                              onTap: () {}),
                        );
                      }))
            ])));
  }

  void _showStatusHistory(MySite mySite) {
    List<StatusInfo> transformedData = mySite.statusInfo.values.toList();
    Logger.instance.d(transformedData);
    Rx<RangeValues> rangeValues = RangeValues(
            transformedData.length > 7 ? transformedData.length - 7 : 0,
            transformedData.length.toDouble() - 1)
        .obs;
    Logger.instance.d(rangeValues.value);
    RxList<StatusInfo> showData = transformedData
        .sublist(
            rangeValues.value.start.toInt(), rangeValues.value.end.toInt() + 1)
        .obs;
    Logger.instance.d(showData);
    Get.bottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      isScrollControlled: true,
      Obx(() {
        return SafeArea(
          child: CustomCard(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(children: [
                Text(
                  "${mySite.nickname} [站点数据累计${mySite.statusInfo.length}天]",
                ),
                SfCartesianChart(
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      animationDuration: 100,
                      shouldAlwaysShow: false,
                      tooltipPosition: TooltipPosition.pointer,
                      builder: (dynamic data, dynamic point, dynamic series,
                          int pointIndex, int seriesIndex) {
                        StatusInfo? lastData = pointIndex > 0
                            ? series.dataSource[pointIndex - 1]
                            : null;
                        return Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(8),
                            width: 200,
                            child: SingleChildScrollView(
                                child: StatusToolTip(
                                    data: data, lastData: lastData)));
                      },
                    ),
                    zoomPanBehavior: ZoomPanBehavior(
                      /// To enable the pinch zooming as true.
                      enablePinching: true,
                      zoomMode: ZoomMode.x,
                      enablePanning: true,
                      enableMouseWheelZooming: true,
                    ),
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                    ),
                    primaryXAxis: const CategoryAxis(
                      majorGridLines: MajorGridLines(width: 0),
                    ),
                    primaryYAxis: const NumericAxis(
                      isVisible: false,
                    ),
                    axes: <ChartAxis>[
                      NumericAxis(
                        name: 'PrimaryYAxis',
                        labelPosition: ChartDataLabelPosition.inside,
                        numberFormat: NumberFormat.compact(),
                        majorTickLines: const MajorTickLines(width: 0),
                        minorTickLines: const MinorTickLines(width: 0),
                      ),
                      const NumericAxis(
                        name: 'SecondaryYAxis',
                        isVisible: false,
                        tickPosition: TickPosition.inside,
                        majorTickLines: MajorTickLines(width: 0),
                        minorTickLines: MinorTickLines(width: 0),
                      ),
                      const NumericAxis(
                        name: 'ThirdYAxis',
                        isVisible: false,
                        tickPosition: TickPosition.inside,
                        majorTickLines: MajorTickLines(width: 0),
                        minorTickLines: MinorTickLines(width: 0),
                      ),
                    ],
                    series: <CartesianSeries>[
                      LineSeries<StatusInfo, String>(
                          name: '做种体积',
                          yAxisName: 'PrimaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) =>
                              formatUpdatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) =>
                              item.seedVolume),
                      LineSeries<StatusInfo, String>(
                          name: '上传量',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) =>
                              formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.uploaded),
                      ColumnSeries<StatusInfo, String>(
                        name: '上传增量',
                        dataSource: showData,
                        yAxisName: 'ThirdYAxis',
                        xValueMapper: (StatusInfo item, _) =>
                            formatCreatedTimeToDateString(item),
                        yValueMapper: (StatusInfo item, index) => index > 0 &&
                                item.uploaded > showData[index - 1].uploaded
                            ? item.uploaded - showData[index - 1].uploaded
                            : 0,
                        dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            textStyle: const TextStyle(fontSize: 10),
                            builder: (dynamic data,
                                dynamic point,
                                dynamic series,
                                int pointIndex,
                                int seriesIndex) {
                              return point.y > 0
                                  ? Text(FileSizeConvert.parseToFileSize(
                                      (point.y).toInt()))
                                  : const SizedBox.shrink();
                            }),
                      ),
                      LineSeries<StatusInfo, String>(
                          name: '下载量',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) =>
                              formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) =>
                              item.downloaded),
                      LineSeries<StatusInfo, String>(
                          name: '时魔',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) =>
                              formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.bonusHour),
                      LineSeries<StatusInfo, String>(
                          name: '做种积分',
                          yAxisName: 'PrimaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) =>
                              formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.myScore),
                      LineSeries<StatusInfo, String>(
                          name: '魔力值',
                          yAxisName: 'PrimaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) =>
                              formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.myBonus),
                      LineSeries<StatusInfo, String>(
                          name: '做种数量',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) =>
                              formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.seed),
                      LineSeries<StatusInfo, String>(
                          name: '吸血数量',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) =>
                              formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.leech),
                      LineSeries<StatusInfo, String>(
                          name: '邀请',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) =>
                              formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) =>
                              item.invitation),
                    ]),
                Text(
                  "${rangeValues.value.end.toInt() - rangeValues.value.start.toInt() + 1}日数据",
                ),
                RangeSlider(
                  min: 0,
                  max: transformedData.length * 1.0 - 1,
                  divisions: transformedData.length - 1,
                  labels: RangeLabels(
                    formatUpdatedTimeToDateString(
                        transformedData[rangeValues.value.start.toInt()]),
                    formatUpdatedTimeToDateString(
                        transformedData[rangeValues.value.end.toInt()]),
                  ),
                  onChanged: (value) {
                    rangeValues.value = value;
                    showData.value = transformedData.sublist(
                        rangeValues.value.start.toInt(),
                        rangeValues.value.end.toInt() + 1);
                  },
                  values: rangeValues.value,
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 当应用程序重新打开时，重新加载数据
      controller.initData();
    }
  }
}

class StatusToolTip extends StatelessWidget {
  final StatusInfo data;
  final StatusInfo? lastData;

  const StatusToolTip({super.key, required this.data, required this.lastData});

  @override
  Widget build(BuildContext context) {
    int difference = (lastData == null || lastData!.uploaded > data.uploaded)
        ? 0
        : data.uploaded - lastData!.uploaded;
    return Column(
      children: [
        _buildDataRow(
            '更新时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(data.updatedAt)),
        _buildDataRow('做种量', FileSizeConvert.parseToFileSize(data.seedVolume)),
        _buildDataRow('等级', data.myLevel),
        _buildDataRow('上传量', FileSizeConvert.parseToFileSize(data.uploaded)),
        _buildDataRow('上传增量', FileSizeConvert.parseToFileSize(difference)),
        _buildDataRow('下载量', FileSizeConvert.parseToFileSize(data.downloaded)),
        _buildDataRow('分享率', data.ratio.toStringAsFixed(3)),
        _buildDataRow('魔力', formatNumber(data.myBonus)),
        if (data.myScore > 0) _buildDataRow('积分', formatNumber(data.myScore)),
        if (data.bonusHour > 0)
          _buildDataRow('时魔', formatNumber(data.bonusHour)),
        _buildDataRow('做种中', data.seed),
        _buildDataRow('吸血中', data.leech),
        if (data.invitation > 0) _buildDataRow('邀请', data.invitation),
        if (data.seedDays > 0) _buildDataRow('做种时间', data.seedDays),
        _buildDataRow('HR', data.myHr),
        if (data.published > 0) _buildDataRow('已发布', data.published),
      ],
    );
  }

  Widget _buildDataRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
