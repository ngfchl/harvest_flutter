import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../api/mysite.dart';
import '../../../../common/form_widgets.dart';
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
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 25,
            child: Obx(() {
              return TextField(
                controller: controller.searchController.value,
                style: const TextStyle(fontSize: 10),
                textAlignVertical: TextAlignVertical.bottom,
                decoration: const InputDecoration(
                  // labelText: '搜索',
                  hintText: '输入关键词...',
                  labelStyle: TextStyle(fontSize: 10),
                  hintStyle: TextStyle(fontSize: 10),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3.0)),
                  ),
                ),
                onChanged: (value) {
                  // 在这里处理搜索框输入的内容变化

                  Logger.instance.i('搜索框内容变化：$value');
                  controller.searchKey.value = value;
                  controller.filterSiteStatusBySearchKey();
                },
              );
            }),
          ),
          Expanded(
            child: EasyRefresh(
              onRefresh: () async {
                controller.getSiteStatusFromServer();
                controller.update();
              },
              child: Obx(() {
                return controller.showStatusList.isEmpty
                    ? const GFLoader(
                        type: GFLoaderType.circle,
                      )
                    : ListView.builder(
                        itemCount: controller.showStatusList.length,
                        itemBuilder: (BuildContext context, int index) {
                          MySite mySite = controller.showStatusList[index];
                          return showSiteDataInfo(mySite);
                        },
                      );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              _showBottomSheet();
            },
            icon: const Icon(
              Icons.add_circle_outline,
              size: 36,
              color: Colors.blue,
            ),
          ),
          const SizedBox(
            height: 48,
          )
        ],
      ),
    );
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
      String statusLatestDate =
          mySite.statusInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      status = mySite.statusInfo[statusLatestDate];
    }
    if (status == null) {
      Logger.instance.w('${mySite.nickname} - ${mySite.statusInfo}');
    }
    return status == null
        ? Card(
            child: Column(
              children: [
                ListTile(
                  leading: Image.network(
                    website!.logo,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      // Placeholder widget when loading fails
                      return const Image(
                          image: AssetImage('assets/images/logo.png'));
                    },
                  ),
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
                    ],
                  ),
                  subtitle: Text(
                    calcWeeksDays(mySite.timeJoin),
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 10,
                    ),
                  ),
                ),
                siteOperateButtonBar(website, mySite)
              ],
            ),
          )
        : Card(
            child: Column(children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    '${mySite.mirror}/${website != null ? website.logo : ''}',
                    fit: BoxFit.fill,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      // Placeholder widget when loading fails
                      return const Image(
                          image: AssetImage('assets/images/logo.png'));
                    },
                    width: 32,
                    height: 32,
                  ),
                ),
                onTap: () async {
                  String path;
                  if (mySite.mail > 0 &&
                      !website!.pageMessage.contains('api')) {
                    path = website.pageMessage
                        .replaceFirst("{}", mySite.userId.toString());
                  } else {
                    path = website!.pageIndex;
                  }
                  String url = '${mySite.mirror}$path';
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
                      'info': null,
                      'mySite': mySite,
                      'website': website
                    });
                  }
                  // Uri uri = Uri.parse('${mySite.mirror}$url');
                  // if (!await launchUrl(uri)) {
                  //   Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？');
                  // }
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
                    if (mySite.mail > 0)
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
                    if (mySite.notice > 0)
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
                    Text(
                      status.myLevel,
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
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
                trailing: Text(calculateTimeElapsed(status.updatedAt),
                    style: TextStyle(color: Colors.grey.shade400)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                          '最近更新：${status.updatedAt.replaceAll('T', ' ')}',
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
              siteOperateButtonBar(website!, mySite)
            ]),
          );
  }

  ButtonBar siteOperateButtonBar(WebSite website, MySite mySite) {
    return ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      buttonPadding: const EdgeInsets.all(8),
      buttonAlignedDropdown: true,
      children: [
        if (website.signIn)
          SizedBox(
            width: 68,
            height: 26,
            child: GFButton(
              onPressed: () {
                signIn(mySite.id).then((res) {
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
              icon: const Icon(
                Icons.pan_tool_alt,
                size: 12,
                color: Colors.white,
              ),
              text: '签到',
              size: GFSize.SMALL,
              color: Colors.blue,
            ),
          ),
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
            onPressed: () {},
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
              _showBottomSheet(mySite: mySite);
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

  int _calculateItemCount(selectedSite) {
    int count = 2; // 前两个元素一定显示
    if (selectedSite.value!.searchTorrents) count++;
    if (selectedSite.value!.signIn) count++;
    if (selectedSite.value!.repeatTorrents) count++;
    return count;
  }

  void _showBottomSheet({MySite? mySite}) {
    List<String> siteList = controller.webSiteList.keys.toList();
    List<String> hasKeys =
        controller.mySiteList.map((element) => element.site).toList();
    if (mySite == null) {
      siteList = siteList.where((key) => !hasKeys.contains(key)).toList();
    }
    Logger.instance.i(siteList);
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
    // RxString site = siteList[0].obs;
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
      Container(
        padding: const EdgeInsets.all(20),
        color: Colors.blueGrey.shade300,
        width: 550,
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
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 1.0, // 每行垂直方向的间距
                          crossAxisSpacing: 0, // 每列水平方向的间距
                          childAspectRatio: 5.0, // 子元素的宽高比例
                        ),
                        itemCount: _calculateItemCount(selectedSite),
                        // 子元素数量
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return SwitchTile(
                                title: '站点可用',
                                value: available.value,
                                onChanged: (value) {
                                  available.value = value;
                                },
                              );
                            case 1:
                              return SwitchTile(
                                title: '数据',
                                value: getInfo.value,
                                onChanged: (value) {
                                  getInfo.value = value;
                                },
                              );
                            case 2:
                              if (selectedSite.value!.searchTorrents) {
                                return SwitchTile(
                                  title: '搜索',
                                  value: searchTorrents.value,
                                  onChanged: (value) {
                                    searchTorrents.value = value;
                                  },
                                );
                              }
                              break;
                            case 3:
                              if (selectedSite.value!.signIn) {
                                return SwitchTile(
                                  title: '签到',
                                  value: signIn.value,
                                  onChanged: (value) {
                                    signIn.value = value;
                                  },
                                );
                              }
                              break;
                            case 4:
                              if (selectedSite.value!.repeatTorrents) {
                                return SwitchTile(
                                  title: '辅种',
                                  value: repeatTorrents.value,
                                  onChanged: (value) {
                                    repeatTorrents.value = value;
                                  },
                                );
                              }
                              break;
                            default:
                              return const SizedBox.shrink();
                          }
                          return null;
                        },
                      ),

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
                                // 如果 mySite 不为空，表示是修改操作
                                mySite?.site = siteController.text;
                                mySite?.mirror = mirrorController.text;
                                mySite?.nickname = nicknameController.text;
                                mySite?.passkey = passkeyController.text;
                                mySite?.authKey = apiKeyController.text;
                                mySite?.userId = userIdController.text;
                                mySite?.userAgent = userAgentController.text;
                                mySite?.rss = rssController.text;
                                mySite?.proxy = proxyController.text;
                                mySite?.torrents = torrentsController.text;
                                mySite?.cookie = cookieController.text;
                                mySite?.getInfo = getInfo.value;
                                mySite?.signIn = signIn.value;
                                mySite?.available = available.value;
                                mySite?.brushRss = brushRss.value;
                                mySite?.brushFree = brushFree.value;
                                mySite?.packageFile = packageFile.value;
                                mySite?.repeatTorrents = repeatTorrents.value;
                                mySite?.hrDiscern = hrDiscern.value;
                                mySite?.searchTorrents = searchTorrents.value;
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
                                  updatedAt: '',
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
                                controller.update();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 当应用程序重新打开时，重新加载数据
      controller.initData();
    }
  }
}
