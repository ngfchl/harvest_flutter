import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerControllerX extends GetxController {
  late final Player player;
  late final VideoController videoController;

  var isPlaying = false.obs;
  var isFullscreen = false.obs;
  var position = Duration.zero.obs;
  var duration = Duration.zero.obs;
  var isLoading = true.obs;

  final url = ''.obs; // 当前播放的地址

  VideoPlayerControllerX({String? initialUrl}) {
    if (initialUrl != null && initialUrl.isNotEmpty) {
      url.value = initialUrl;
    }
  }

  @override
  void onInit() {
    super.onInit();
    player = Player();
    videoController = VideoController(player);

    // 监听状态
    player.stream.position.listen((pos) => position.value = pos);
    player.stream.duration.listen((dur) {
      duration.value = dur;
      if (dur > Duration.zero) {
        isLoading.value = false;
      }
    });
    player.stream.playing.listen((playing) => isPlaying.value = playing);

    // 如果有初始 URL，则自动播放
    if (url.value.isNotEmpty) {
      playUrl(url.value);
    }
  }

  Future<void> playUrl(String newUrl) async {
    if (newUrl.trim().isEmpty) return;
    url.value = newUrl;
    isLoading.value = true;
    await player.open(Media(newUrl));
    isPlaying.value = true;
  }

  void togglePlay() {
    isPlaying.value ? player.pause() : player.play();
  }

  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;
  }

  void seek(Duration d) {
    player.seek(d);
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
