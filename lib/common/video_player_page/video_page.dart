import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:harvest/utils/platform.dart';
import 'package:harvest/utils/storage.dart';
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
    double opacity = SPUtil.getDouble("cardOpacity", defaultValue: 0.7);
    return GetBuilder<VideoPlayerControllerX>(builder: (controller) {
      return Obx(() {
        final isFullscreen = controller.isFullscreen.value;

        var shadColorScheme = ShadTheme.of(context).colorScheme;
        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                // ESC 按下处理逻辑
                Navigator.of(context).maybePop();
              }
            }
          },
          child: Scaffold(
            appBar: isFullscreen || PlatformTool.isHorizontalScreen() ? null : AppBar(title: const Text("正在播放")),
            backgroundColor: shadColorScheme.background.withOpacity(opacity * 1.2),
            body: Center(
              child: SafeArea(
                child: AspectRatio(
                  aspectRatio: controller.videoController.player.state.height != null
                      ? (controller.videoController.player.state.width! /
                          controller.videoController.player.state.height!)
                      : 16 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Center(
                          child: Video(
                            controller: controller.videoController,
                            fit: BoxFit.contain,
                            controls: (videoState) {
                              return Stack(
                                children: [
                                  AdaptiveVideoControls(videoState),
                                  Positioned(
                                    right: 16,
                                    top: 16,
                                    child: ShadIconButton.ghost(
                                      icon: Icon(
                                        Icons.exit_to_app_outlined,
                                      ),
                                      onPressed: () => Get.back(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      if (controller.isLoading.value)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    });
  }
}
