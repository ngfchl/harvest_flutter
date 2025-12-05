import 'package:get/get.dart';

import '../utils/storage.dart';

class BackgroundService extends GetxService {
  final useBackground = false.obs;
  final useImageProxy = false.obs;
  final useLocalBackground = false.obs;
  final backgroundImage = ''.obs;
  final blur = 0.0.obs; // 0 = no blur
  final opacity = 0.7.obs;

  Future<BackgroundService> init() async {
    useBackground.value = SPUtil.getBool('useBackground');
    useImageProxy.value = SPUtil.getBool('useImageProxy');
    useLocalBackground.value = SPUtil.getBool('useLocalBackground');
    blur.value = SPUtil.getDouble('backgroundBlur', defaultValue: 0);
    opacity.value = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);

    backgroundImage.value = SPUtil.getString(
      'backgroundImage',
      defaultValue: 'https://cci1.yiimii.com/uploads/2023/11/20231114005921427.jpg',
    );

    return this;
  }

  /// 修改并立即生效
  void setBackgroundImage(String path, {bool local = true}) {
    SPUtil.setBool('useLocalBackground', local);
    SPUtil.setString('backgroundImage', path);

    useLocalBackground.value = local;
    backgroundImage.value = path; // 自动触发 UI 刷新
  }

  void setBlur(double value) {
    SPUtil.setDouble('backgroundBlur', value);
    blur.value = value;
  }

  void setOpacity(double value) {
    SPUtil.setDouble('cardOpacity', value);
    opacity.value = value;
  }
}
