import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../utils/storage.dart';
import '../../../routes/app_pages.dart';

class SettingController extends GetxController {
  bool isLoaded = false;
  String configData = '';
  GetStorage box = GetStorage();
  final server = RxString('');

  @override
  void onInit() {
    getSystemConfigFromServer();
    // server.value = box.read('server');
    super.onInit();
  }

  logout() {
    SPUtil.remove("userinfo");
    SPUtil.remove("isLogin");
    box.remove("userinfo");
    box.remove("isLogin");
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
}
