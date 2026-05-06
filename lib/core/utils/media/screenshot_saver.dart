import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotSaver {
  /// 可视区域截图
  static Future<Uint8List?> capture(GlobalKey key) async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// 长截图：自动滚动 + 拼接
  static Future<Uint8List?> captureLong({
    required GlobalKey scrollKey,
    required ScrollController scrollController,
  }) async {
    final boundary = scrollKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final viewportHeight = boundary.size.height;
    final pixelRatio = 3.0;

    // ── 0. 跳到顶部 ──
    scrollController.jumpTo(0);
    await Future.delayed(const Duration(milliseconds: 500));
    await WidgetsBinding.instance.endOfFrame;

    // ── 1. 滚到底，让懒加载内容全部构建 ──
    for (int i = 0; i < 3; i++) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      await Future.delayed(const Duration(milliseconds: 500));
      await WidgetsBinding.instance.endOfFrame;
    }

    final realMaxScroll = scrollController.position.maxScrollExtent;
    final totalContentHeight = viewportHeight + realMaxScroll;
    debugPrint('[Screenshot] viewport=$viewportHeight, maxScroll=$realMaxScroll, total=$totalContentHeight');

    // ── 2. 回到顶部 ──
    scrollController.jumpTo(0);
    await Future.delayed(const Duration(milliseconds: 600));
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 200));
    await WidgetsBinding.instance.endOfFrame;

    // ── 3. 逐屏截图，记录每张图的滚动偏移 ──
    final screenshots = <_ScreenshotPiece>[];
    double step = viewportHeight * 0.8; // 每次滚动 80% 视口高度，确保不跳过内容
    double currentOffset = 0;

    while (true) {
      // 等待渲染
      final distance = step;
      final waitMs = (distance / 1000 * 200).clamp(400, 1000).toInt();
      await Future.delayed(Duration(milliseconds: waitMs));
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 150));
      await WidgetsBinding.instance.endOfFrame;

      final img = await boundary.toImage(pixelRatio: pixelRatio);
      screenshots.add(_ScreenshotPiece(image: img, scrollOffset: currentOffset));
      debugPrint('[Screenshot] captured at $currentOffset, imgH=${img.height}');

      currentOffset += step;

      if (currentOffset >= realMaxScroll) break;

      scrollController.jumpTo(currentOffset.clamp(0, realMaxScroll));
    }

    // ── 4. 补截底部 ──
    if ((scrollController.offset - realMaxScroll).abs() > 1) {
      final distance = (realMaxScroll - scrollController.offset).abs();
      final waitMs = (distance / 1000 * 200).clamp(500, 1500).toInt();

      scrollController.jumpTo(realMaxScroll);
      await Future.delayed(Duration(milliseconds: waitMs));
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 200));
      await WidgetsBinding.instance.endOfFrame;

      final img = await boundary.toImage(pixelRatio: pixelRatio);
      screenshots.add(_ScreenshotPiece(image: img, scrollOffset: realMaxScroll));
      debugPrint('[Screenshot] captured final at $realMaxScroll');
    }

    // ── 5. 恢复 ──
    scrollController.jumpTo(0);

    if (screenshots.isEmpty) return null;

    // ── 6. 拼接 ──
    return _stitchByOffset(screenshots, viewportHeight, totalContentHeight, pixelRatio);
  }

  /// 按滚动偏移量精确拼接
  static Future<Uint8List?> _stitchByOffset(
    List<_ScreenshotPiece> screenshots,
    double viewportHeight,
    double totalContentHeight,
    double pixelRatio,
  ) async {
    final totalPx = (totalContentHeight * pixelRatio).toInt();
    final width = screenshots[0].image.width;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (final piece in screenshots) {
      final img = piece.image;
      final offsetPx = (piece.scrollOffset * pixelRatio).toInt();

      // 这张图在总图中的起始 y 坐标
      final dstY = offsetPx;
      // 这张图能覆盖的范围
      final remaining = totalPx - dstY;
      if (remaining <= 0) continue;

      // 裁剪：如果超出总高度，只取需要的部分
      final srcHeight = remaining < img.height ? remaining : img.height;

      final src = Rect.fromLTWH(0, 0, width.toDouble(), srcHeight.toDouble());
      final dst = Rect.fromLTWH(0, dstY.toDouble(), width.toDouble(), srcHeight.toDouble());

      canvas.drawImageRect(img, src, dst, Paint());
    }

    final picture = recorder.endRecording();
    final result = await picture.toImage(width, totalPx);
    final byteData = await result.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// 保存并分享
  static Future<void> saveAndShare(Uint8List bytes) async {
    // 先写入临时文件
    final tempDir = await getTemporaryDirectory();
    final filePath = p.join(tempDir.path, 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png');
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // 保存到相册
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        if (Platform.isAndroid) {
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) return;
        }
        await ImageGallerySaverPlus.saveImage(
          bytes,
          quality: 100,
          name: 'Harvest_${DateTime.now().millisecondsSinceEpoch}',
        );
      } catch (e) {
        debugPrint('保存到相册失败: $e');
      }
    } else {
      // 桌面端复制到剪贴板
      try {
        await Pasteboard.writeImage(bytes);
      } catch (e) {
        debugPrint('复制到剪贴板失败: $e');
      }
    }

    // 分享
    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(filePath)], text: '来自 PT 收割机'));
    } catch (e) {
      debugPrint('分享失败: $e');
    }
  }
}

class _ScreenshotPiece {
  final ui.Image image;
  final double scrollOffset;

  _ScreenshotPiece({required this.image, required this.scrollOffset});
}
