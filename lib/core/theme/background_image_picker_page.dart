import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/dio_client.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/theme/app_theme.dart';
import 'package:harvest/core/theme/background_image_models.dart';
import 'package:harvest/core/theme/background_preview.dart';
import 'package:harvest/core/theme/theme_provider.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/debug_theme_button.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void showBackgroundImageDialog(BuildContext context) {
  shadcn.showDialog(
    context: context,
    builder: (_) => const BackgroundImagePickerPage(dialog: true),
  );
}

class BackgroundImagePickerPage extends ConsumerStatefulWidget {
  final bool dialog;

  const BackgroundImagePickerPage({super.key, this.dialog = false});

  @override
  ConsumerState<BackgroundImagePickerPage> createState() =>
      _BackgroundImagePickerPageState();
}

class _BackgroundImagePickerPageState
    extends ConsumerState<BackgroundImagePickerPage> {
  final _urlController = TextEditingController();
  Future<List<ManagedBackgroundImage>>? _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(themeNotifierProvider);
    if (current.backgroundMode == 'network' &&
        current.backgroundImage.startsWith('http')) {
      _urlController.text = current.backgroundImage;
    }
    _future = _loadImages();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _select(ManagedBackgroundImage image) async {
    final notifier = ref.read(themeNotifierProvider.notifier);
    notifier.setUseBackground(true);
    notifier.setBackgroundMode(image.mode);
    notifier.setBackgroundImage(image.path);
    Toast.success('背景图已应用');
  }

  Future<void> _selectDefault() async {
    await _select(
      const ManagedBackgroundImage(
        path: 'assets/images/background.png',
        label: '默认背景',
        mode: 'asset',
      ),
    );
  }

  Future<List<ManagedBackgroundImage>> _loadImages() async {
    final images = <ManagedBackgroundImage>[
      const ManagedBackgroundImage(
        path: 'assets/images/background.png',
        label: '默认背景',
        mode: 'asset',
      ),
    ];
    final response = await DioClient.dio.get(
      API.IMAGEBED_IMAGES,
      options: Options(extra: const {'allowAnySucceed': true}),
    );
    final urls = _extractImageUrls(response.data);
    final seen = images.map((image) => image.path).toSet();
    for (final url in urls) {
      if (seen.add(url)) {
        images.add(
          ManagedBackgroundImage(path: url, label: url, mode: 'network'),
        );
      }
    }
    return images;
  }

  Future<void> _reload() async {
    await DioClient.dio.put(
      API.IMAGEBED_IMAGES,
      options: Options(extra: const {'allowAnySucceed': true}),
    );
    final future = _loadImages();
    setState(() {
      _future = future;
    });
    await future;
  }

  Future<void> _deleteImage(ManagedBackgroundImage image) async {
    if (!image.isNetwork) return;
    setState(() => _busy = true);
    try {
      final path = _imageRequestPath(image.path);
      await DioClient.dio.delete(
        API.IMAGEBED_IMAGES,
        queryParameters: {'url': image.path, 'path': path},
        data: {'url': image.path, 'path': path},
        options: Options(extra: const {'allowAnySucceed': true}),
      );
      final current = ref.read(themeNotifierProvider);
      if (current.backgroundMode == image.mode &&
          current.backgroundImage == image.path) {
        final notifier = ref.read(themeNotifierProvider.notifier);
        notifier.setUseBackground(true);
        notifier.setBackgroundMode('asset');
        notifier.setBackgroundImage('assets/images/background.png');
      }
      Toast.success('背景图已删除');
    } catch (_) {
      Toast.error('背景图删除失败');
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    try {
      await _load();
    } catch (_) {
      Toast.warning('背景图已删除，列表刷新失败');
    }
  }

  Future<void> _load() async {
    final future = _loadImages();
    setState(() {
      _future = future;
    });
    await future;
  }

  Future<void> _downloadNetwork() async {
    final urls = _urlController.text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (urls.isEmpty || urls.any((url) => !url.startsWith('http'))) {
      Toast.warning('请输入网络图片地址，每行一个');
      return;
    }
    setState(() => _busy = true);
    try {
      await DioClient.dio.post(
        API.IMAGEBED_REMOTE,
        data: {'urls': urls.join('\n')},
        options: Options(extra: const {'allowAnySucceed': true}),
      );
      Toast.success('远程背景图已添加');
      await _load();
    } catch (_) {
      Toast.error('远程背景图下载失败');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importLocal() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    final files = result?.files ?? const <PlatformFile>[];
    if (files.isEmpty) return;
    setState(() => _busy = true);
    try {
      final formData = FormData();
      for (final file in files) {
        if (file.path == null && file.bytes == null) {
          throw StateError('无法读取文件: ${file.name}');
        }
        final multipart = file.bytes != null
            ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
            : await MultipartFile.fromFile(file.path!, filename: file.name);
        formData.files.add(MapEntry('file', multipart));
      }
      await DioClient.dio.post(
        API.IMAGEBED_UPLOAD,
        data: formData,
        options: Options(extra: const {'allowAnySucceed': true}),
      );
      Toast.success('背景图上传成功');
      await _load();
    } catch (_) {
      Toast.error('背景图上传失败');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final pageBackground = appSurfaceColor(context, cs.background);
    final current = ref.watch(themeNotifierProvider);
    final content = _buildContent(context, current);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth < 752 ? screenWidth - 32 : 720.0;

    if (widget.dialog) {
      return shadcn.AlertDialog(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        content: SizedBox(
          width: dialogWidth,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.78,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '背景图管理',
                        style: theme.typography.large.copyWith(
                          color: cs.foreground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    shadcn.IconButton.ghost(
                      icon: const Icon(shadcn.LucideIcons.x, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(child: content),
              ],
            ),
          ),
        ),
      );
    }

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: AppBackground(
        child: shadcn.Scaffold(
          backgroundColor: pageBackground,
          headers: [
            shadcn.AppBar(
              backgroundColor: pageBackground,
              leading: [
                shadcn.IconButton.ghost(
                  icon: const Icon(shadcn.LucideIcons.arrowLeft, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              title: Text(
                '背景图管理',
                style: theme.typography.large.copyWith(
                  color: cs.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const [DebugThemeButton.shadcn()],
            ),
          ],
          child: content,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeState current) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return FutureBuilder<List<ManagedBackgroundImage>>(
      future: _future,
      builder: (context, snapshot) {
        final images = snapshot.data ?? const <ManagedBackgroundImage>[];
        return EasyRefresh(
          onRefresh: _reload,
          header: appRefreshHeader(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              widget.dialog ? 0 : 14,
              widget.dialog ? 0 : 12,
              widget.dialog ? 0 : 14,
              widget.dialog ? 0 : MediaQuery.paddingOf(context).bottom + 24,
            ),
            children: [
              _NetworkImportCard(
                controller: _urlController,
                busy: _busy,
                onSubmit: _downloadNetwork,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  shadcn.Button.outline(
                    onPressed: _busy ? null : _selectDefault,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(shadcn.LucideIcons.rotateCcw, size: 16),
                        SizedBox(width: 8),
                        Text('默认背景'),
                      ],
                    ),
                  ),
                  shadcn.Button.outline(
                    onPressed: _busy ? null : _importLocal,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(shadcn.LucideIcons.upload, size: 16),
                        SizedBox(width: 8),
                        Text('上传本地图片'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '选择背景',
                style: theme.typography.small.copyWith(
                  color: cs.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: shadcn.CircularProgressIndicator(strokeWidth: 2),
                )
              else if (images.isEmpty)
                _EmptyBlock(color: cs.mutedForeground)
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final count = width >= 720
                        ? 3
                        : width >= 460
                        ? 2
                        : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.48,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final image = images[index];
                        return _BackgroundTile(
                          image: image,
                          selected: current.backgroundImage == image.path,
                          onTap: () => _select(image),
                          onDelete: _busy || !image.isNetwork
                              ? null
                              : () => _deleteImage(image),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NetworkImportCard extends StatelessWidget {
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;

  const _NetworkImportCard({
    required this.controller,
    required this.busy,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return AppSurfaceContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '远程下载背景图',
            style: theme.typography.small.copyWith(
              color: cs.foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ShadTextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 5,
            placeholder: const Text('https://...\n多个图片链接一行一个'),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: shadcn.Button.primary(
              onPressed: busy ? null : onSubmit,
              child: busy
                  ? const shadcn.CircularProgressIndicator(strokeWidth: 2)
                  : const Text('下载'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundTile extends StatelessWidget {
  final ManagedBackgroundImage image;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _BackgroundTile({
    required this.image,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(theme.radiusMd);
    final borderWidth = selected ? 3.0 : 1.0;
    final shadowColor = cs.primary.withValues(alpha: 0.24);
    final title = image.isAsset ? image.label : '在线背景';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: cs.background,
        border: Border.all(
          color: selected ? cs.primary : cs.border,
          width: borderWidth,
        ),
        borderRadius: radius,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 22,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusMd - borderWidth / 2),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BackgroundPreview(image: image),
                    if (selected)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              shadcn.LucideIcons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              height: 38,
              padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
              decoration: BoxDecoration(
                color: cs.background,
                border: Border(top: BorderSide(color: cs.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selected ? '当前背景' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.xSmall.copyWith(
                        color: selected ? cs.primary : cs.foreground,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (image.isNetwork)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        shadcn.Tooltip(
                          tooltip: (_) => const Text('复制链接'),
                          child: shadcn.IconButton.ghost(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: image.path),
                              );
                              Toast.success('链接已复制');
                            },
                            icon: Icon(
                              shadcn.LucideIcons.copy,
                              size: 15,
                              color: cs.foreground,
                            ),
                          ),
                        ),
                        shadcn.Tooltip(
                          tooltip: (_) => const Text('删除背景图'),
                          child: shadcn.IconButton.ghost(
                            onPressed: onDelete,
                            icon: Icon(
                              shadcn.LucideIcons.trash2,
                              size: 15,
                              color: onDelete == null
                                  ? cs.mutedForeground
                                  : cs.destructive,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final Color color;

  const _EmptyBlock({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text('暂无背景图', style: TextStyle(color: color)),
      ),
    );
  }
}

List<String> _extractImageUrls(dynamic value) {
  final result = <String>[];

  void visit(dynamic item) {
    if (item == null) return;
    if (item is String) {
      final trimmed = item.trim();
      final url = _normalizeImageUrl(trimmed);
      if (url != null) result.add(url);
      return;
    }
    if (item is Map) {
      for (final key in const [
        'url',
        'urls',
        'path',
        'src',
        'link',
        'file',
        'files',
        'data',
        'result',
        'items',
        'list',
      ]) {
        if (item.containsKey(key)) visit(item[key]);
      }
      return;
    }
    if (item is Iterable) {
      for (final child in item) {
        visit(child);
      }
    }
  }

  visit(value);
  return result.toSet().toList();
}

String? _normalizeImageUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  if (!_isRelativeImagePath(trimmed)) return null;

  final base = AppConfig.baseUrl;
  final baseUri = Uri.tryParse(base);
  if (baseUri != null && baseUri.hasScheme && baseUri.host.isNotEmpty) {
    return baseUri
        .resolve(trimmed.startsWith('/') ? trimmed : '/$trimmed')
        .toString();
  }
  final separator = trimmed.startsWith('/') ? '' : '/';
  return '$base$separator$trimmed';
}

String _imageRequestPath(String value) {
  final trimmed = value.trim();
  final uri = Uri.tryParse(trimmed);
  final baseUri = Uri.tryParse(AppConfig.baseUrl);
  if (uri != null &&
      baseUri != null &&
      uri.hasScheme &&
      uri.host == baseUri.host &&
      uri.port == baseUri.port) {
    final query = uri.hasQuery ? '?${uri.query}' : '';
    return '${uri.path}$query';
  }
  return trimmed;
}

bool _isRelativeImagePath(String value) {
  final lower = value.toLowerCase();
  return lower.startsWith('/media/') ||
      lower.startsWith('media/') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif') ||
      lower.endsWith('.bmp') ||
      lower.endsWith('.avif');
}
