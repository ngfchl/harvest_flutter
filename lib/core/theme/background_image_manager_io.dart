import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'background_image_models.dart';

class BackgroundImageManager {
  static const folderName = 'theme_backgrounds';
  static const defaultAsset = 'assets/images/background.png';

  static Future<io.Directory> _directory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = io.Directory(p.join(docs.path, folderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<List<ManagedBackgroundImage>> listImages() async {
    final dir = await _directory();
    final files = await dir
        .list()
        .where((entity) => entity is io.File && _isImagePath(entity.path))
        .cast<io.File>()
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return [
      const ManagedBackgroundImage(
        path: defaultAsset,
        label: '默认背景',
        mode: 'asset',
      ),
      for (final file in files)
        ManagedBackgroundImage(
          path: file.path,
          label: p.basename(file.path),
          mode: 'file',
        ),
    ];
  }

  static Future<ManagedBackgroundImage?> importLocal(String sourcePath) async {
    if (sourcePath.trim().isEmpty) return null;
    final source = io.File(sourcePath);
    if (!await source.exists()) return null;
    final dir = await _directory();
    final extension = _normalizedExtension(source.path);
    final name = 'background_${DateTime.now().millisecondsSinceEpoch}$extension';
    final target = io.File(p.join(dir.path, name));
    await source.copy(target.path);
    return ManagedBackgroundImage(path: target.path, label: name, mode: 'file');
  }

  static Future<ManagedBackgroundImage?> downloadNetwork(String url) async {
    final raw = url.trim();
    if (!raw.startsWith('http')) return null;
    final dir = await _directory();
    final extension = _extensionFromUrl(raw);
    final name = 'background_${DateTime.now().millisecondsSinceEpoch}$extension';
    final target = p.join(dir.path, name);
    await Dio().download(raw, target);
    return ManagedBackgroundImage(path: target, label: name, mode: 'file');
  }

  static bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  static String _normalizedExtension(String path) {
    final ext = p.extension(path).toLowerCase();
    return _isImagePath('x$ext') ? ext : '.jpg';
  }

  static String _extensionFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final ext = uri == null ? '' : p.extension(uri.path).toLowerCase();
    return _isImagePath('x$ext') ? ext : '.jpg';
  }
}
