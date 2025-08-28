import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 一行两个按钮：拍照 / 选图
/// 回调返回保存到沙盒的绝对路径
class ImagePickerRow extends StatelessWidget {
  final ValueChanged<String?> onImagePicked;

  const ImagePickerRow({super.key, required this.onImagePicked});

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return ListTile(
      title: Text(
        '选择图片',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拍照按钮：移动端才显示
          if (isMobile)
            ElevatedButton.icon(
              icon: Icon(
                Icons.camera_alt,
                size: 18,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              label: Text(
                '拍照',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              onPressed: () => _pick(ImageSource.camera),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // 圆角半径
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                textStyle: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          const SizedBox(width: 12),
          // 相册按钮：所有平台都显示
          ElevatedButton.icon(
            icon: Icon(
              Icons.photo_library,
              size: 18,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(
              '相册',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            onPressed: () => _pick(ImageSource.gallery),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // 圆角半径
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              textStyle: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  /* ========== 内部方法 ========== */

  Future<void> _pick(ImageSource source) async {
    final xFile = await ImagePicker().pickImage(source: source);
    if (xFile == null) {
      onImagePicked(null);
      return;
    }

    // 复制到沙盒并重命名
    final dir = await getApplicationDocumentsDirectory();
    final newName =
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(xFile.path)}';
    final saved = await File(xFile.path).copy('${dir.path}/$newName');

    onImagePicked(saved.path);
  }
}
