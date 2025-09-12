import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'video_controller.dart';

class VideoPlayerPage extends StatelessWidget {
  final String? initialUrl;

  const VideoPlayerPage({super.key, this.initialUrl});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoPlayerControllerX(initialUrl: initialUrl));

    return Obx(() {
      final isFullscreen = controller.isFullscreen.value;

      return Scaffold(
        appBar: isFullscreen ? null : AppBar(title: const Text("正在播放")),
        body: SafeArea(
          child: Column(
            children: [
              // 视频区域
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Video(
                      controller: controller.videoController,
                    ),
                    if (controller.isLoading.value)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),

              // 控制栏
              Row(
                children: [
                  IconButton(
                    icon: Icon(controller.isPlaying.value
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: controller.togglePlay,
                  ),
                  Text(
                    "${_formatDuration(controller.position.value)} / ${_formatDuration(controller.duration.value)}",
                  ),
                  Expanded(
                    child: Slider(
                      value: controller.position.value.inSeconds.toDouble(),
                      max: controller.duration.value.inSeconds
                          .toDouble()
                          .clamp(1, double.infinity),
                      onChanged: (value) {
                        controller.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(isFullscreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen),
                    onPressed: controller.toggleFullscreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
