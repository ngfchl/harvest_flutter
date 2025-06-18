import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotSaver {
  /// 当前可视区域截图并保存或分享
  static Future<void> captureAndSave(GlobalKey key) async {
    try {
      // 等待当前帧结束，确保布局完成
      await Future.delayed(Duration(milliseconds: 20)); // 可选延时，视实际情况添加
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception("找不到 RepaintBoundary");

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      if (Platform.isAndroid || Platform.isIOS) {
        await _saveToGallery(pngBytes);
      }
      await _shareImageBytes(pngBytes);
    } catch (e, stack) {
      debugPrint("截图保存失败: $e\n$stack");
    }
  }

  /// 手机保存到相册
  static Future<void> _saveToGallery(Uint8List bytes) async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) throw Exception("未获得存储权限");
    }

    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: "Harvest_Screenshot_${DateTime.now().millisecondsSinceEpoch}",
    );

    debugPrint("保存到相册结果: $result");
  }

  /// 分享图片字节
  static Future<void> _shareImageBytes(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = p.join(
        tempDir.path, 'share_${DateTime.now().millisecondsSinceEpoch}.png');

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '分享截图',
      ),
    );

    debugPrint("分享成功: $filePath");
  }
}
