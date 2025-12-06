import 'package:get/get.dart';

import '../utils/storage.dart';

class BackgroundService extends GetxService {
  final useBackground = false.obs;
  final useImageProxy = false.obs;
  final useLocalBackground = false.obs;
  final backgroundImage = ''.obs;
  final blur = 0.0.obs; // 0 = no blur
  final opacity = 0.7.obs;
  RxBool useImageCache = true.obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<BackgroundService> init() async {
    useBackground.value = SPUtil.getBool('useBackground');
    useImageProxy.value = SPUtil.getBool('useImageProxy');
    useLocalBackground.value = SPUtil.getBool('useLocalBackground');
    blur.value = SPUtil.getDouble('backgroundBlur', defaultValue: 0);
    opacity.value = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    useImageCache.value = SPUtil.getBool('useImageCache', defaultValue: true);
    backgroundImage.value = SPUtil.getString(
      'backgroundImage',
      defaultValue: 'https://cci1.yiimii.com/uploads/2023/11/20231114005921427.jpg',
    );

    return this;
  }

  Future<void> save() async {
    await SPUtil.setBool('useBackground', useBackground.value);
    await SPUtil.setBool('useLocalBackground', useLocalBackground.value);
    await SPUtil.setBool('useImageProxy', useImageProxy.value);
    await SPUtil.setBool('useImageCache', useImageCache.value);

    await SPUtil.setString('backgroundImage', backgroundImage.value);

    await SPUtil.setDouble('cardOpacity', opacity.value);
    await SPUtil.setDouble('backgroundBlur', blur.value);
  }
}
