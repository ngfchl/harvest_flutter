import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/agg_search/view.dart';
import 'package:harvest/app/home/pages/dash_board/controller.dart';
import 'package:harvest/app/home/pages/dash_board/view.dart';
import 'package:harvest/app/home/pages/dou_ban/view.dart';
import 'package:harvest/app/home/pages/download/download.dart';
import 'package:harvest/app/home/pages/my_rss/view.dart';
import 'package:harvest/app/home/pages/my_site/view.dart';
import 'package:harvest/app/home/pages/subscribe/view.dart';
import 'package:harvest/app/home/pages/subscribe_history/view.dart';
import 'package:harvest/app/home/pages/subscribe_tag/view.dart';
import 'package:harvest/app/home/pages/task/view.dart';
import 'package:harvest/models/common_response.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../api/api.dart';
import '../../../common/app_lifecycle_server.dart';
import '../../../models/authinfo.dart';
import '../../../utils/dio_util.dart';
import '../../../utils/logger_helper.dart';
import '../../../utils/platform.dart';
import '../../../utils/storage.dart';
import '../../routes/app_pages.dart';
import '../pages/app_publish/view.dart';
import '../pages/download/download_controller.dart';
import '../pages/file_manage/view.dart';
import '../pages/models/AuthPeriod.dart';
import '../pages/my_site/controller.dart';
import '../pages/setting/setting.dart';
import '../pages/ssh/view.dart';
import '../pages/user/view.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  int initPage = 0;

  AuthInfo? userinfo;
  TextEditingController searchController = TextEditingController();
  DioUtil dioUtil = DioUtil();
  bool isDarkMode = false;
  bool isPortrait = false; // 是否是竖屏
  bool isSmallHorizontalScreen = false; // 是否是竖屏
  UpdateLogState? updateLogState;
  UpdateLogState? updateSitesState;
  AuthPeriod? authInfo;
  String backgroundImage = '';
  bool useLocalBackground = false;
  bool useImageCache = false;
  bool useBackground = false;
  bool useImageProxy = false;
  bool authPrivateMode = false;

  // final mySiteController = Get.put(MySiteController());

  final PageController pageController = PageController(initialPage: 0);
  final popoverController = ShadPopoverController();
  final appLifecycle = Get.find<AppLifecycleService>();

  @override
  void onClose() {
    searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  List<Widget> pages = [
    const DashBoardPage(),
    const AggSearchPage(),
    const DownloadPage(),
    TaskPage(),
    const SubscribePage(),
    const SubscribeHistoryPage(),
    const DouBanPage(),
  ];
  List<NavigationRailDestination> destinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.home, size: 18),
      label: Text('仪表盘'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.search, size: 18),
      label: Text('聚合搜索'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.cloud_download, size: 18),
      label: Text('下载管理'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.subscriptions_outlined, size: 18),
      label: Text('订阅管理'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.history, size: 18),
      label: Text('订阅历史'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.theaters, size: 18),
      label: Text('豆瓣影视'),
    ),
  ];

  @override
  void onReady() async {
    Logger.instance.d('HomeController onReady');
  }

  void initData() {
    try {
      Logger.instance.d('初始化主题模式');
      isDarkMode = Get.isDarkMode;
      useBackground = SPUtil.getBool('useBackground');
      authPrivateMode = SPUtil.getBool('authPrivateMode', defaultValue: false);
      if (useBackground) {
        Logger.instance.d('初始化主题壁纸');
        useImageProxy = SPUtil.getBool('useImageProxy');
        useImageCache = SPUtil.getBool('useImageCache');
        useLocalBackground = SPUtil.getBool('useLocalBackground');

        backgroundImage = SPUtil.getString(
          'backgroundImage',
          defaultValue: 'https://pic4.zhimg.com/v2-12ed225c3144a726284fe048870f72d1_r.jpg',
        );
        Logger.instance.d('背景图：$backgroundImage');
      }
      initDio();
      initMenus();
      update();
      Logger.instance.d('初始化用户信息');
      userinfo = AuthInfo.fromJson(SPUtil.getLocalStorage('userinfo') ?? {});
      getAuthInfo();
      Logger.instance.d('是否后台管理员：${authInfo?.username} ${authInfo?.username == 'ngfchl@126.com'}');
    } catch (e, trace) {
      Logger.instance.e('初始化失败 $e');
      Logger.instance.e(trace);
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void checkUpdate() {
    try {
      Logger.instance.d('开始检测Docker更新');
      initUpdateLogState();
    } catch (e, trace) {
      Logger.instance.e('检测 Docker 更新失败');
      Logger.instance.e(trace);
    }

    try {
      Logger.instance.d('开始检测站点配置文件更新');
      initUpdateSitesState();
    } catch (e, trace) {
      Logger.instance.e('检测站点配置文件更新失败');
      Logger.instance.e(trace);
    }
  }

  @override
  void onInit() async {
    Logger.instance.d('HomeController onInit');
    initData();
    checkUpdate();
    super.onInit();

    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb) {
      interval(
        appLifecycle.lifecycle,
        (state) {
          if (state == null) return;
          Logger.instance.d("HomeController 收到生命周期变化 ====== 当前状态$state");
          if (state == AppLifecycleState.resumed) {
            Logger.instance.d("回到前台");
            initData();
            Get.find<DashBoardController>().initData();
            Get.find<MySiteController>().initData();
          } else if (state == AppLifecycleState.paused) {
            Logger.instance.d("进入后台");
          }
        },
        time: const Duration(minutes: 10),
      );
    }
    _updateOrientation();
  }

  //** 屏幕旋转监听 **//
  void _updateOrientation() {
    isPortrait = PlatformTool.isPortrait();
    isSmallHorizontalScreen = PlatformTool.isSmallHorizontalScreen();
    final size = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).size;
    Logger.instance.i('ScreenSize: width=${size.width}, height=${size.height}');
    SPUtil.setDouble('ScreenSizeHeight', size.height);
    SPUtil.setDouble('ScreenSizeWidth', size.width);
  }

  @override
  void didChangeMetrics() {
    _updateOrientation();
  }

  void initDio() async {
    Logger.instance.d('初始化Dio');
    String? baseUrl = SPUtil.getLocalStorage('server');
    if (baseUrl == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      // 初始化dio
      await dioUtil.initialize(baseUrl);
    }
  }

  Future<void> getAuthInfo() async {
    Logger.instance.d('检测授权信息');
    final response = await DioUtil().get(Api.AUTH_INFO);
    if (response.statusCode == 200) {
      // Logger.instance.d(response.data['data']);
      final data = response.data;
      String msg = '成功获取到授权信息：$data';
      Logger.instance.i(msg);
      if (data['code'] == 0) {
        authInfo = AuthPeriod.fromJson(data['data']);
      }
    } else {
      String msg = '获取数据列表失败: ${response.statusCode}';
      Logger.instance.e(msg);
    }
    initMenus();
    update();
  }

  void initMenus() {
    Logger.instance.d('初始化菜单');
    pages = [
      const DashBoardPage(),
      const AggSearchPage(),
      if (userinfo?.isStaff == true) ...[
        const MySitePage(),
        FileManagePage(),
      ],
      const DownloadPage(),
      if (userinfo?.isStaff == true) TaskPage(),
      if (userinfo?.isStaff == true) SettingPage(),
      UserWidget(),
      const SubscribePage(),
      if (userinfo?.isStaff == true) const MyRssPage(),
      const SubscribeHistoryPage(),
      if (userinfo?.isStaff == true) const SubscribeTagPage(),
      const DouBanPage(),
      if (userinfo?.isStaff == true) SshWidget(),
      if (authInfo?.username == 'ngfchl@126.com') AppPublishPage(),
    ];
    destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined, size: 18),
        label: Text('仪表盘'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.search_outlined, size: 18),
        label: Text('聚合搜索'),
      ),
      if (userinfo?.isStaff == true) ...[
        const NavigationRailDestination(
          icon: Icon(Icons.language_outlined, size: 18),
          label: Text('站点数据'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.folder_outlined, size: 18),
          label: Text('资源管理'),
        ),
      ],
      const NavigationRailDestination(
        icon: Icon(Icons.cloud_download_outlined, size: 18),
        label: Text('下载管理'),
      ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.task, size: 18),
          label: Text('计划任务'),
        ),
      if (userinfo?.isStaff == true) ...[
        const NavigationRailDestination(
          icon: Icon(Icons.settings_outlined, size: 18),
          label: Text('系统设置'),
        ),
      ],
      const NavigationRailDestination(
        icon: Icon(Icons.man_2_outlined, size: 18),
        label: Text('用户管理'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.subscriptions_outlined, size: 18),
        label: Text('订阅管理'),
      ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.rss_feed_outlined, size: 18),
          label: Text('站点RSS'),
        ),
      const NavigationRailDestination(
        icon: Icon(Icons.history_outlined, size: 18),
        label: Text('订阅历史'),
      ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.tag_outlined, size: 18),
          label: Text('订阅标签'),
        ),
      const NavigationRailDestination(
        icon: Icon(Icons.theaters_outlined, size: 18),
        label: Text('豆瓣影视'),
      ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.description, size: 18),
          label: Text('SSH终端'),
        ),
      if (authInfo?.username == 'ngfchl@126.com')
        const NavigationRailDestination(
          icon: Icon(Icons.cloud_upload, size: 18),
          label: Text('后台管理'),
        ),
    ];
  }

  void logout() {
    SPUtil.remove("userinfo");
    SPUtil.remove("isLogin");
    dioUtil.dio.close();
    Get.delete<DownloadController>();
    Get.delete<HomeController>();
    Get.delete<MySiteController>();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> initUpdateLogState() async {
    final res = await getGitUpdateLog();
    if (res.code == 0) {
      updateLogState = res.data;
    } else {
      Logger.instance.e(res.msg);
      Get.snackbar('更新日志', '获取更新日志失败！${res.msg}', colorText: Colors.red);
    }
    Logger.instance.d(updateLogState?.localLogs);
    update();
  }

  Future<void> initUpdateSitesState() async {
    final res = await getGitUpdateSites();
    if (res.code == 0) {
      updateSitesState = res.data;
    } else {
      Logger.instance.e(res.msg);
      Get.snackbar('更新站点', '获取更新站点失败！${res.msg}', colorText: Colors.red);
    }
    Logger.instance.d(updateSitesState?.localLogs);
    update();
  }

  Future<CommonResponse> doDockerUpdate() async {
    return await doDockerUpdateApi();
  }

  Future<CommonResponse> doWebUIUpdate() async {
    return await doDockerUpdateApi(upgradeTag: "upgrade_webui");
  }

  Future<CommonResponse> doSitesUpdate() async {
    return await doDockerUpdateApi(upgradeTag: "upgrade_sites");
  }

  Future<CommonResponse> doDjangoUpdate() async {
    return await doDockerUpdateApi(upgradeTag: "upgrade_django");
  }

  Future<void> changePage(int index) async {
    Get.back();

    pageController.jumpToPage(index);
    initPage = index;

    update();
  }

  Future<CommonResponse> getGitUpdateLog() async {
    final response = await DioUtil().get(Api.UPDATE_LOG);
    if (response.statusCode == 200) {
      Logger.instance.d(response.data);
      return CommonResponse.fromJson(response.data, (p0) {
        if (p0 == null) {
          return null;
        }
        return UpdateLogState.fromJson(p0);
      });
    } else {
      String msg = '获取Docker更新日志失败: ${response.statusCode}';
      // GFToast.showToast(msg, context);
      return CommonResponse.error(msg: msg);
    }
  }

  Future<CommonResponse> getGitUpdateSites() async {
    final response = await DioUtil().get(Api.UPDATE_SITES);
    if (response.statusCode == 200) {
      Logger.instance.d(response.data);
      return CommonResponse.fromJson(response.data, (p0) {
        if (p0 == null) {
          return null;
        }
        return UpdateLogState.fromJson(p0);
      });
    } else {
      String msg = '获取Docker更新日志失败: ${response.statusCode}';
      // GFToast.showToast(msg, context);
      return CommonResponse.error(msg: msg);
    }
  }

  Future<CommonResponse> doDockerUpdateApi({String upgradeTag = "upgrade_all"}) async {
    final response = await DioUtil().get("${Api.DOCKER_UPDATE}?upgrade_tag=$upgradeTag");
    if (response.statusCode == 200) {
      return CommonResponse.fromJson(response.data, (p0) => null);
    } else {
      String msg = '获取Docker更新日志失败: ${response.statusCode}';
      // GFToast.showToast(msg, context);
      return CommonResponse.error(msg: msg);
    }
  }
}
