import 'background_image_models.dart';

class BackgroundImageManager {
  static const defaultAsset = 'assets/images/background.png';

  static Future<List<ManagedBackgroundImage>> listImages() async {
    return const [
      ManagedBackgroundImage(
        path: defaultAsset,
        label: '默认背景',
        mode: 'asset',
      ),
    ];
  }

  static Future<ManagedBackgroundImage?> importLocal(String sourcePath) async {
    return null;
  }

  static Future<ManagedBackgroundImage?> downloadNetwork(String url) async {
    final raw = url.trim();
    if (!raw.startsWith('http')) return null;
    return ManagedBackgroundImage(path: raw, label: raw, mode: 'network');
  }
}
