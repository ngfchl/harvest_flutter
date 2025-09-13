import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/utils/platform.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'video_controller.dart';

class VideoPlayerPage extends StatelessWidget {
  final String? initialUrl;

  const VideoPlayerPage({super.key, this.initialUrl});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoPlayerControllerX(initialUrl: initialUrl));

    return GetBuilder<VideoPlayerControllerX>(builder: (controller) {
      return Obx(() {
        final isFullscreen = controller.isFullscreen.value;

        return Scaffold(
          appBar: isFullscreen || PlatformTool.isHorizontalScreen()
              ? null
              : AppBar(title: const Text("正在播放")),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 视频区域
                  AspectRatio(
                    aspectRatio:
                        controller.videoController.player.state.height != null
                            ? (controller.videoController.player.state.width! /
                                controller.videoController.player.state.height!)
                            : 16 / 9,
                    child: Stack(
                      children: [
                        Video(
                          controller: controller.videoController,
                          fit: BoxFit.fitWidth,
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
                      ShadIconButton.ghost(
                        icon: Icon(
                          controller.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: ShadTheme.of(context)
                              .colorScheme
                              .primaryForeground,
                        ),
                        onPressed: controller.togglePlay,
                      ),
                      Text(
                        "${_formatDuration(controller.position.value)} / ${_formatDuration(controller.duration.value)}",
                        style: TextStyle(
                          color: ShadTheme.of(context)
                              .colorScheme
                              .primaryForeground,
                        ),
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
                      ShadIconButton.ghost(
                        icon: Icon(
                          isFullscreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: ShadTheme.of(context)
                              .colorScheme
                              .primaryForeground,
                        ),
                        onPressed: controller.toggleFullscreen,
                      ),
                      ShadIconButton.ghost(
                        icon: Icon(
                          Icons.exit_to_app_outlined,
                          color: ShadTheme.of(context)
                              .colorScheme
                              .primaryForeground,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
    });
  }
}
