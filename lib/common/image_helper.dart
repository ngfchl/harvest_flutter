import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 一行两个按钮：拍照 / 选图
/// 回调返回保存到沙盒的绝对路径
class ImagePickerRow extends StatelessWidget {
  final ValueChanged<String?> onImagePicked;

  const ImagePickerRow({super.key, required this.onImagePicked});

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return ListTile(
      title: Text(
        '选择图片',
        style: TextStyle(
          fontSize: 12,
          color: shadColorScheme.foreground,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          // 拍照按钮：移动端才显示
          if (isMobile)
            ShadButton.ghost(
              size: ShadButtonSize.sm,
              leading: Icon(
                Icons.camera_alt,
                size: 13,
                color: shadColorScheme.foreground,
              ),
              child: Text(
                '拍照',
                style: TextStyle(
                  fontSize: 12,
                  color: shadColorScheme.foreground,
                ),
              ),
              onPressed: () => _pick(ImageSource.camera),
            ),
          // 相册按钮：所有平台都显示
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            leading: Icon(
              Icons.photo_library,
              size: 13,
              color: shadColorScheme.foreground,
            ),
            child: Text(
              '相册',
              style: TextStyle(
                fontSize: 12,
                color: shadColorScheme.foreground,
              ),
            ),
            onPressed: () => _pick(ImageSource.gallery),
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
    final newName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(xFile.path)}';
    final saved = await File(xFile.path).copy('${dir.path}/$newName');

    onImagePicked(saved.path);
  }
}
