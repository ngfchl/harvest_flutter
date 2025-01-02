import 'package:get/get.dart';
import 'package:harvest/models/common_response.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../api/option.dart';
import '../../../../utils/storage.dart';
import '../../../routes/app_pages.dart';
import '../models/option.dart';

class SettingController extends GetxController {
  bool isLoaded = false;
  String configData = '';
  late PackageInfo packageInfo;
  String server = '';
  String applicationLegalese = 'Copyright 2022-2024 无始无终. All rights reserved.';
  List<Option> optionList = [];
  List<Map<String, String>> optionMapList = [
    {'name': '油猴Token', 'value': 'monkey_token'},
    // {'name': '辅种配置', 'value': 'repeat'},
    {'name': '通知详情', 'value': 'notice_content_item'},
    {'name': '通知开关', 'value': 'notice_category_enable'},
    {'name': '企业微信', 'value': 'wechat_work_push'},
    {'name': 'Wxpusher', 'value': 'wxpusher_push'},
    {'name': 'PushDeer', 'value': 'pushdeer_push'},
    {'name': 'Bark', 'value': 'bark_push'},
    {'name': '爱语飞飞', 'value': 'iyuu_push'},
    {'name': 'PushPlus', 'value': 'pushplus_push'},
    {'name': 'TeleGram', 'value': 'telegram_push'},
    {'name': '阿里云盘', 'value': 'aliyun_drive'},
    {'name': '百度OCR', 'value': 'baidu_ocr'},
    {'name': 'SSDForm', 'value': 'ssdforum'},
    {'name': 'CookieCloud', 'value': 'cookie_cloud'},
    {'name': 'FileList', 'value': 'FileList'},
    {'name': 'TMDB配置', 'value': 'tmdb_api_auth'},
  ];
  List<SelectOption> optionChoice = [];
  Map<String, String> optionMap = {};

  @override
  Future<void> onInit() async {
    optionChoice = optionMapList.map((e) => SelectOption.fromJson(e)).toList();
    optionMap = Map.fromEntries(
        optionMapList.map((item) => MapEntry(item['value']!, item['name']!)));

    packageInfo = await PackageInfo.fromPlatform();
    await getOptionList();
    server = SPUtil.getLocalStorage('server');

    update();
    super.onInit();
  }

  getOptionList() async {
    isLoaded = true;
    update();
    final res = await getOptionListApi();
    if (res.code == 0) {
      optionList = res.data;
      var filter = optionList.where((item) => item.name == 'tmdb_api_auth');
      if (filter.isNotEmpty) {
        SPUtil.setCache(
            '${server}_option_tmdb_api', filter.first.toJson(), 3600 * 24 * 30);
      }
    } else {
      Get.snackbar('获取配置列表出错', res.msg.toString());
    }
    isLoaded = false;
    update();
  }

  logout() {
    SPUtil.remove("userinfo");
    SPUtil.remove("isLogin");
    Get.offAllNamed(Routes.LOGIN);
  }

  getSystemConfigFromServer() {
    // getSystemConfig().then((value) {
    //   if (value.code == 0) {
    //     configData = value.data;
    //     isLoaded = true;
    //   } else {
    //     Get.snackbar('解析出错啦！', value.msg.toString());
    //   }
    // }).catchError((e) {
    //   Get.snackbar('网络访问出错啦', e.toString());
    // });
    update();
  }

  Future<CommonResponse> saveOption(Option option) async {
    CommonResponse res;
    if (option.id == 0) {
      res = await addOptionApi(option);
    } else {
      res = await editOptionApi(option);
    }
    if (res.code == 0) {
      await getOptionList();
    }
    return res;
  }
}
