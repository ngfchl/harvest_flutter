import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/models/common_response.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../api/mysite.dart';
import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../common/utils.dart';
import '../../../../utils/calc_weeks.dart';
import '../../../../utils/format_number.dart';
import '../../../../utils/logger_helper.dart';
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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<MySiteController>(builder: (controller) {
      return Scaffold(
        body: EasyRefresh(
          onRefresh: () async {
            controller.getSiteStatusFromServer();
          },
          child: Column(
            children: [
              if (controller.mySiteList.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 25,
                        child: TextField(
                          controller: controller.searchController,
                          style: const TextStyle(fontSize: 10),
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            // labelText: '搜索',
                            hintText: '输入关键词...',
                            labelStyle: const TextStyle(fontSize: 10),
                            hintStyle: const TextStyle(fontSize: 10),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 10,
                            ),
                            // suffix: ,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                  '计数：${controller.showStatusList.length}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.orange)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                            ),
                          ),
                          onChanged: (value) {
                            Logger.instance.i('搜索框内容变化：$value');
                            controller.searchKey = value;
                            controller.filterByKey();
                          },
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
              Expanded(
                child: controller.isLoaded
                    ? const GFLoader()
                    : controller.showStatusList.isEmpty
                        ? const Text('没有符合条件的数据！')
                        : GetBuilder<MySiteController>(builder: (controller) {
                            return ListView.builder(
                              itemCount: controller.showStatusList.length,
                              itemBuilder: (BuildContext context, int index) {
                                MySite mySite =
                                    controller.showStatusList[index];
                                return showSiteDataInfo(mySite);
                              },
                            );
                          }),
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GFIconButton(
              onPressed: () {
                _showFilterBottomSheet();
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
                _showSortBottomSheet();
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
            GFIconButton(
              onPressed: () {
                _showEditBottomSheet();
              },
              icon: const Icon(
                Icons.add_circle_outline,
                // size: 32,
                // color: Colors.blue,
              ),
              // text: '添加',
              // type: GFButtonType.outline2x,
            ),
            const SizedBox(
              height: 48,
            )
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    Get.delete<MySiteController>();
    super.dispose();
  }

  Widget showSiteDataInfo(MySite mySite) {
    StatusInfo? status;
    WebSite? website = controller.webSiteList[mySite.site];
    if (mySite.statusInfo.isNotEmpty) {
      status = mySite.statusInfo[mySite.getStatusMaxKey()];
    }
    if (status == null) {
      Logger.instance.w('${mySite.nickname} - ${mySite.statusInfo}');
    }
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(children: [
        ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              website!.logo.startsWith('http')
                  ? website.logo
                  : '${mySite.mirror}${website.logo}',
              fit: BoxFit.fill,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return const Image(image: AssetImage('assets/images/logo.png'));
              },
              width: 32,
              height: 32,
            ),
          ),
          onTap: () async {
            String path;
            if (mySite.mail! > 0 && !website.pageMessage.contains('api')) {
              path = website.pageMessage
                  .replaceFirst("{}", mySite.userId.toString());
            } else {
              path = website.pageIndex;
            }
            String url = '${mySite.mirror}$path';
            if (!Platform.isIOS && !Platform.isAndroid) {
              Logger.instance.i('Explorer');
              Uri uri = Uri.parse(url);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？');
              }
            } else {
              Logger.instance.i('WebView');
              Get.toNamed(Routes.WEBVIEW, arguments: {
                'url': url,
                'info': null,
                'mySite': mySite,
                'website': website
              });
            }
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mySite.nickname,
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 13,
                ),
              ),
              if (mySite.mail! > 0)
                Row(
                  children: [
                    const Icon(
                      Icons.mail,
                      size: 12,
                      color: Colors.black38,
                    ),
                    Text(
                      '${mySite.mail}',
                      style: const TextStyle(
                        color: Colors.black38,
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
                      color: Colors.black38,
                    ),
                    Text(
                      '${mySite.notice}',
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              if (status != null)
                Text(
                  status.myLevel,
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          subtitle: status == null
              ? Text(
                  '站点失联啦？',
                  style: TextStyle(
                    color: Colors.red.shade200,
                    fontSize: 10,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      calcWeeksDays(mySite.timeJoin),
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 10,
                      ),
                    ),
                    if (status.invitation > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.insert_invitation,
                            size: 12,
                            color: Colors.black38,
                          ),
                          Text(
                            '${status.invitation}',
                            style: const TextStyle(
                              color: Colors.black38,
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
                    Column(
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
                              '${filesize(status.uploaded)} (${status.seed})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
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
                              '${filesize(status.downloaded)} (${status.leech})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.ios_share,
                              color: status.ratio > 1
                                  ? Colors.black38
                                  : Colors.deepOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              formatNumber(status.ratio),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.cloud_upload_outlined,
                              color: Colors.black38,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              filesize(status.seedVolume),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          textBaseline: TextBaseline.ideographic,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: Colors.black38,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              formatNumber(status.bonusHour),
                              // '(${  status.siteSpFull != null && status.siteSpFull! > 0 ? ((status.statusBonusHour! / status.siteSpFull!) * 100).toStringAsFixed(2) : '0'}%)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
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
                              color: Colors.black38,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${formatNumber(status.myBonus)}(${formatNumber(status.myScore)})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                        color: Colors.black38,
                        fontSize: 10.5,
                      ),
                    ),
                    if (status.myHr != '' && status.myHr != "0")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'HR: ${status.myHr.replaceAll('区', '').replaceAll('专', '')}',
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
        // siteOperateButtonBar(website, mySite)
      ]),
    );
  }

  Widget _buildMySiteOperate(WebSite website, MySite mySite) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool signed = mySite.getSignMaxKey() == today;
    return CustomPopup(
      showArrow: true,
      // contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      barrierColor: Colors.transparent,
      backgroundColor: Colors.white70,
      content: SizedBox(
          width: 100,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (website.signIn && mySite.signIn && !signed)
              PopupMenuItem<String>(
                child: const Text('我要签到'),
                onTap: () async {
                  CommonResponse res = await signIn(mySite.id);
                  Get.back();
                  if (res.code == 0) {
                    Get.snackbar(
                      '签到成功',
                      '${mySite.nickname} 签到信息：${res.msg}',
                      colorText: Colors.white,
                      backgroundColor: Colors.green.shade300,
                    );
                    controller.getSiteStatusFromServer();
                  } else {
                    Get.snackbar(
                      '签到失败',
                      '${mySite.nickname} 签到任务执行出错啦：${res.msg}',
                      colorText: Colors.white,
                      backgroundColor: Colors.red.shade300,
                    );
                  }
                },
              ),
            if (website.signIn && mySite.signIn && signed)
              PopupMenuItem<String>(
                child: const Text('签到历史'),
                onTap: () async {
                  _showSignHistory(mySite);
                },
              ),
            PopupMenuItem<String>(
              child: const Text('更新数据'),
              onTap: () async {
                CommonResponse res = await getNewestStatus(mySite.id);
                Get.back();
                if (res.code == 0) {
                  Get.snackbar(
                    '站点数据刷新成功',
                    '${mySite.nickname} 数据刷新：${res.msg}',
                    colorText: Colors.white,
                    backgroundColor: Colors.green.shade300,
                  );
                  controller.getSiteStatusFromServer();
                } else {
                  Get.snackbar(
                    '站点数据刷新失败',
                    '${mySite.nickname} 数据刷新出错啦：${res.msg}',
                    colorText: Colors.white,
                    backgroundColor: Colors.red.shade300,
                  );
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
                _showEditBottomSheet(mySite: mySite);
              },
            ),
          ])),
      child: const Icon(
        Icons.widgets_outlined,
        size: 24,
        color: Colors.black45,
      ),
    );
  }

  ButtonBar siteOperateButtonBar(WebSite website, MySite mySite) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool signed = mySite.getSignMaxKey() == today;

    return ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      buttonPadding: const EdgeInsets.all(8),
      buttonAlignedDropdown: true,
      children: [
        if (website.signIn && mySite.signIn)
          SizedBox(
              width: 68,
              height: 26,
              child: GFButton(
                onPressed: () {
                  signed
                      ? _showSignHistory(mySite)
                      : signIn(mySite.id).then((res) {
                          Get.back();
                          if (res.code == 0) {
                            Get.snackbar(
                              '签到成功',
                              '${mySite.nickname} 签到信息：${res.msg}',
                              colorText: Colors.white,
                              backgroundColor: Colors.green.shade300,
                            );
                            controller.getSiteStatusFromServer();
                          } else {
                            Get.snackbar(
                              '签到失败',
                              '${mySite.nickname} 签到任务执行出错啦：${res.msg}',
                              colorText: Colors.white,
                              backgroundColor: Colors.red.shade300,
                            );
                          }
                        });
                },
                icon: Icon(
                  signed ? Icons.check : Icons.pan_tool_alt,
                  size: 12,
                  color: Colors.white,
                ),
                text: '签到',
                size: GFSize.SMALL,
                color: signed ? Colors.teal : Colors.blue,
              )),
        SizedBox(
          width: 68,
          height: 26,
          child: GFButton(
            onPressed: () {
              getNewestStatus(mySite.id).then((res) {
                Get.back();
                if (res.code == 0) {
                  Get.snackbar(
                    '站点数据刷新成功',
                    '${mySite.nickname} 数据刷新：${res.msg}',
                    colorText: Colors.white,
                    backgroundColor: Colors.green.shade300,
                  );
                  controller.getSiteStatusFromServer();
                } else {
                  Get.snackbar(
                    '站点数据刷新失败',
                    '${mySite.nickname} 数据刷新出错啦：${res.msg}',
                    colorText: Colors.white,
                    backgroundColor: Colors.red.shade300,
                  );
                }
              });
            },
            icon: const Icon(
              Icons.update,
              size: 12,
              color: Colors.white,
            ),
            text: '更新',
            size: GFSize.SMALL,
            color: GFColors.PRIMARY,
          ),
        ),
        SizedBox(
          width: 68,
          height: 26,
          child: GFButton(
            onPressed: () {
              _showStatusHistory(mySite);
            },
            icon: const Icon(
              Icons.bar_chart,
              size: 12,
              color: Colors.white,
            ),
            text: '历史',
            size: GFSize.SMALL,
            color: Colors.orange,
          ),
        ),
        SizedBox(
          width: 68,
          height: 26,
          child: GFButton(
            onPressed: () {
              _showEditBottomSheet(mySite: mySite);
            },
            icon: const Icon(
              Icons.edit,
              size: 12,
              color: Colors.white,
            ),
            text: '修改',
            size: GFSize.SMALL,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  void _showEditBottomSheet({MySite? mySite}) {
    // List<String> siteList = controller.webSiteList.keys.toList();
    List<String> siteList = controller.webSiteList.entries
        .where((entry) => entry.value.alive)
        .map((entry) => entry.key)
        .toList();
    List<String> hasKeys =
        controller.mySiteList.map((element) => element.site).toList();
    if (mySite == null) {
      siteList.removeWhere((key) => hasKeys.contains(key));
    }
    final siteController = TextEditingController(text: mySite?.site ?? '');
    final apiKeyController = TextEditingController(text: mySite?.authKey ?? '');
    final nicknameController =
        TextEditingController(text: mySite?.nickname ?? '');
    final passkeyController =
        TextEditingController(text: mySite?.passkey ?? '');
    final userIdController = TextEditingController(text: mySite?.userId ?? '');
    final userAgentController = TextEditingController(
        text: mySite?.userAgent ??
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0');
    final rssController = TextEditingController(text: mySite?.rss ?? '');
    final proxyController = TextEditingController(text: mySite?.proxy ?? '');
    final torrentsController =
        TextEditingController(text: mySite?.torrents ?? '');
    final cookieController = TextEditingController(text: mySite?.cookie ?? '');
    final mirrorController = TextEditingController(text: mySite?.mirror ?? '');
    Rx<WebSite?> selectedSite = mySite != null
        ? controller.webSiteList[mySite.site]!.obs
        : controller.webSiteList.values.toList()[0].obs;
    RxList<String>? urlList = mySite != null
        ? controller.webSiteList[mySite.site]?.url.obs
        : <String>[].obs;
    RxBool getInfo = mySite != null ? mySite.getInfo.obs : true.obs;
    RxBool available = mySite != null ? mySite.available.obs : true.obs;
    RxBool signIn = mySite != null ? mySite.signIn.obs : true.obs;
    RxBool brushRss = mySite != null ? mySite.brushRss.obs : false.obs;
    RxBool brushFree = mySite != null ? mySite.brushFree.obs : false.obs;
    RxBool packageFile = mySite != null ? mySite.packageFile.obs : false.obs;
    RxBool repeatTorrents =
        mySite != null ? mySite.repeatTorrents.obs : true.obs;
    RxBool hrDiscern = mySite != null ? mySite.hrDiscern.obs : false.obs;
    RxBool searchTorrents =
        mySite != null ? mySite.searchTorrents.obs : true.obs;

    Get.bottomSheet(
      CustomCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              mySite != null ? '编辑站点：${mySite.nickname}' : '添加站点',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() {
                  return Column(
                    children: [
                      CustomPickerField(
                        controller: siteController,
                        labelText: '选择站点',
                        data: siteList,
                        onChanged: (p, position) {
                          siteController.text = p;
                          selectedSite.value = controller.webSiteList[p];
                          urlList?.value = selectedSite.value!.url;
                          mirrorController.text = urlList![0];
                          nicknameController.text = selectedSite.value!.name;
                          signIn.value = selectedSite.value!.signIn;
                          getInfo.value = selectedSite.value!.getInfo;
                          repeatTorrents.value =
                              selectedSite.value!.repeatTorrents;
                          searchTorrents.value =
                              selectedSite.value!.searchTorrents;
                          available.value = selectedSite.value!.alive;
                        },
                        onConfirm: (p, position) {
                          siteController.text = p;
                          selectedSite.value = controller.webSiteList[p];
                          urlList?.value = selectedSite.value!.url;
                          mirrorController.text = urlList![0];
                          nicknameController.text = selectedSite.value!.name;
                          signIn.value = selectedSite.value!.signIn;
                          getInfo.value = selectedSite.value!.getInfo;
                          repeatTorrents.value =
                              selectedSite.value!.repeatTorrents;
                          searchTorrents.value =
                              selectedSite.value!.searchTorrents;
                          available.value = selectedSite.value!.alive;
                        },
                      ),
                      if (urlList!.isNotEmpty)
                        CustomPickerField(
                          controller: mirrorController,
                          labelText: '选择网址',
                          data: urlList,
                        ),
                      CustomTextField(
                        controller: nicknameController,
                        labelText: '站点昵称',
                      ),
                      CustomTextField(
                        controller: userIdController,
                        labelText: 'User ID',
                      ),

                      CustomTextField(
                        controller: passkeyController,
                        labelText: 'Passkey',
                      ),
                      CustomTextField(
                        controller: apiKeyController,
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
                      const SizedBox(height: 5),
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        if (selectedSite.value!.alive)
                          ChoiceChip(
                            label: const Text('可用'),
                            selected: available.value,
                            onSelected: (value) {
                              available.value = value;
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

                      ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.error),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                            ),
                            child: const Text(
                              '保存',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              if (mySite != null) {
                                mySite = mySite?.copyWith(
                                  site: siteController.text,
                                  mirror: mirrorController.text,
                                  nickname: nicknameController.text,
                                  passkey: passkeyController.text,
                                  authKey: apiKeyController.text,
                                  userId: userIdController.text,
                                  userAgent: userAgentController.text,
                                  proxy: proxyController.text,
                                  rss: rssController.text,
                                  torrents: torrentsController.text,
                                  cookie: cookieController.text,
                                  getInfo: getInfo.value,
                                  signIn: signIn.value,
                                  brushRss: brushRss.value,
                                  brushFree: brushFree.value,
                                  packageFile: packageFile.value,
                                  repeatTorrents: repeatTorrents.value,
                                  hrDiscern: hrDiscern.value,
                                  searchTorrents: searchTorrents.value,
                                  available: available.value,
                                  id: 0,
                                  sortId: 0,
                                  removeTorrentRules: {},
                                  timeJoin: '',
                                  mail: 0,
                                  notice: 0,
                                  signInInfo: {},
                                  statusInfo: {},
                                );
                              } else {
                                // 如果 mySite 为空，表示是添加操作
                                mySite = MySite(
                                  site: siteController.text,
                                  mirror: mirrorController.text,
                                  nickname: nicknameController.text,
                                  passkey: passkeyController.text,
                                  authKey: apiKeyController.text,
                                  userId: userIdController.text,
                                  userAgent: userAgentController.text,
                                  proxy: proxyController.text,
                                  rss: rssController.text,
                                  torrents: torrentsController.text,
                                  cookie: cookieController.text,
                                  getInfo: getInfo.value,
                                  signIn: signIn.value,
                                  brushRss: brushRss.value,
                                  brushFree: brushFree.value,
                                  packageFile: packageFile.value,
                                  repeatTorrents: repeatTorrents.value,
                                  hrDiscern: hrDiscern.value,
                                  searchTorrents: searchTorrents.value,
                                  available: available.value,
                                  id: 0,
                                  sortId: 0,
                                  removeTorrentRules: {},
                                  timeJoin: '',
                                  mail: 0,
                                  notice: 0,
                                  signInInfo: {},
                                  statusInfo: {},
                                );
                              }
                              Logger.instance.i(mySite?.toJson());
                              if (await controller
                                  .saveMySiteToServer(mySite!)) {
                                Navigator.of(context).pop();
                                controller.getSiteStatusFromServer();
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blueGrey.shade300,
      width: 550,
      child: Column(children: [
        Expanded(
          child: GetBuilder<MySiteController>(builder: (controller) {
            return ListView.builder(
              itemCount: controller.siteSortOptions.length,
              itemBuilder: (context, index) {
                Map<String, String> item = controller.siteSortOptions[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    child: ListTile(
                      title: Text(item['name']!),
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
                          controller.sortReversed = true;
                        } else {
                          controller.sortReversed = false;
                        }
                        controller.sortKey = item['value']!;
                        controller.sortStatusList();

                        Navigator.of(context).pop();
                      },
                    ),
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
    Get.bottomSheet(Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blueGrey.shade300,
        width: 550,
        child: Column(children: [
          Expanded(child: GetBuilder<MySiteController>(builder: (controller) {
            return ListView.builder(
                itemCount: controller.filterOptions.length,
                itemBuilder: (context, index) {
                  Map<String, String> item = controller.filterOptions[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      child: ListTile(
                          title: Text(item['name']!),
                          trailing: controller.filterKey == item['value']
                              ? const Icon(Icons.check_box_outlined)
                              : const Icon(
                                  Icons.check_box_outline_blank_rounded),
                          selectedColor: Colors.amber,
                          selected: controller.filterKey == item['value'],
                          onTap: () {
                            controller.filterKey = item['value']!;
                            controller.filterByKey();

                            Navigator.of(context).pop();
                          }),
                    ),
                  );
                });
          }))
        ])));
  }

  void _showSignHistory(MySite mySite) {
    List<String> signKeys = mySite.signInInfo.keys.toList();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    signKeys.sort((a, b) => b.compareTo(a));
    Get.bottomSheet(Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blueGrey.shade300,
        width: 550,
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
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        child: ListTile(
                            title: Text(
                              item!.info,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: signKey == today
                                      ? Colors.amber
                                      : Colors.black45),
                            ),
                            subtitle: Text(
                              item.updatedAt,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: signKey == today
                                      ? Colors.amber
                                      : Colors.black26),
                            ),
                            selected: signKey == today,
                            selectedColor: Colors.amber,
                            onTap: () {}),
                      ),
                    );
                  }))
        ])));
  }

  void _showStatusHistory(MySite mySite) {
    List<StatusInfo> transformedData = mySite.statusInfo.values.toList();
    Rx<RangeValues> rangeValues = RangeValues(
            transformedData.length > 7 ? transformedData.length - 7 : 0,
            transformedData.length.toDouble() - 1)
        .obs;
    RxList<StatusInfo> showData = transformedData
        .sublist(rangeValues.value.start.toInt(), rangeValues.value.end.toInt())
        .obs;
    Get.bottomSheet(
      Obx(() {
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white70,
          width: 550,
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
                            formatCreatedTimeToDateString(item),
                        yValueMapper: (StatusInfo item, _) => item.seedVolume),
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
                          builder: (dynamic data, dynamic point, dynamic series,
                              int pointIndex, int seriesIndex) {
                            return point.y > 0
                                ? Text(filesize((point.y).toInt()))
                                : const SizedBox.shrink();
                          }),
                    ),
                    LineSeries<StatusInfo, String>(
                        name: '下载量',
                        yAxisName: 'SecondaryYAxis',
                        dataSource: showData,
                        xValueMapper: (StatusInfo item, _) =>
                            formatCreatedTimeToDateString(item),
                        yValueMapper: (StatusInfo item, _) => item.downloaded),
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
                        yValueMapper: (StatusInfo item, _) => item.invitation),
                  ]),
              Text(
                "${rangeValues.value.end.toInt() - rangeValues.value.start.toInt() + 1}日数据",
              ),
              RangeSlider(
                min: 0,
                max: transformedData.length * 1.0 - 1,
                divisions: transformedData.length - 1,
                labels: RangeLabels(
                  formatCreatedTimeToDateString(
                      transformedData[rangeValues.value.start.toInt()]),
                  formatCreatedTimeToDateString(
                      transformedData[rangeValues.value.end.toInt()]),
                ),
                onChanged: (value) {
                  rangeValues.value = value;
                  showData.value = transformedData.sublist(
                      rangeValues.value.start.toInt(),
                      rangeValues.value.end.toInt());
                },
                values: rangeValues.value,
              ),
            ]),
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
        _buildDataRow('做种量', filesize(data.seedVolume)),
        _buildDataRow('等级', data.myLevel),
        _buildDataRow('上传量', filesize(data.uploaded)),
        _buildDataRow('上传增量', filesize(difference)),
        _buildDataRow('下载量', filesize(data.downloaded)),
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
        if (data.publish > 0) _buildDataRow('已发布', data.publish),
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
