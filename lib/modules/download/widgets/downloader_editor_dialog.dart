import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';

import '../model/downloader.dart';
import '../provider/downloader_provider.dart';

class DownloaderEditorDialog extends ConsumerStatefulWidget {
  final Downloader? downloader;
  final void Function(Downloader) onSaved;

  const DownloaderEditorDialog({super.key, this.downloader, required this.onSaved});

  @override
  ConsumerState<DownloaderEditorDialog> createState() => _DownloaderEditorDialogState();
}

class _DownloaderEditorDialogState extends ConsumerState<DownloaderEditorDialog> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _hostCtrl;
  late final TextEditingController _portCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final FSelectController<String> _categoryCtrl;
  late final FSelectController<String> _protocolCtrl;
  FSelectController<String>? _pathCtrl;

  late bool _isActive;
  late bool _brush;

  bool get _isEdit => widget.downloader != null;

  @override
  void initState() {
    super.initState();
    final d = widget.downloader;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _hostCtrl = TextEditingController(text: d?.host ?? '');
    _portCtrl = TextEditingController(text: d?.port.toString() ?? '');
    _usernameCtrl = TextEditingController(text: d?.username ?? '');
    _passwordCtrl = TextEditingController(text: d?.password ?? '');
    _categoryCtrl = FSelectController<String>(vsync: this, value: d?.category ?? 'Qb');
    _protocolCtrl = FSelectController<String>(vsync: this, value: d?.protocol ?? 'http');
    _isActive = d?.isActive ?? true;
    _brush = d?.brush ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _categoryCtrl.dispose();
    _protocolCtrl.dispose();
    _pathCtrl?.dispose();
    super.dispose();
  }

  String? _validateRequired(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '请输入$label';
    return null;
  }

  String? _validatePort(String? v) {
    if (v == null || v.trim().isEmpty) return '请输入端口';
    final p = int.tryParse(v.trim());
    if (p == null || p <= 0 || p > 65535) return '无效端口';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final d = Downloader(
      id: widget.downloader?.id ?? 0,
      name: _nameCtrl.text.trim(),
      category: _categoryCtrl.value ?? 'Qb',
      protocol: _protocolCtrl.value ?? 'http',
      host: _hostCtrl.text.trim(),
      port: int.tryParse(_portCtrl.text.trim()) ?? 0,
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      torrentPath: _pathCtrl?.value ?? widget.downloader?.torrentPath ?? '',
      isActive: _isActive,
      brush: _brush,
      sortId: widget.downloader?.sortId ?? 0,
      externalHost: '${_protocolCtrl.value ?? 'http'}://${_hostCtrl.text.trim()}:${_portCtrl.text.trim()}',
    );

    widget.onSaved(d);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final pathsAsync = ref.watch(downloaderPathsProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ——— 标题 ———
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? '编辑下载器' : '添加下载器',
                      style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  FButton.icon(
                    style: FButtonStyle.ghost(),
                    onPress: () => Navigator.of(context).pop(),
                    child: const Icon(FIcons.x, size: 16),
                  ),
                ],
              ),
            ),

            // ——— 表单 ———
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      // 名称
                      FTextFormField(
                        controller: _nameCtrl,
                        label: const Text('名称'),
                        hint: '例如: QB8999',
                        validator: (v) => _validateRequired(v, '名称'),
                      ),

                      // 客户端类型
                      FSelect<String>(
                        controller: _categoryCtrl,
                        label: const Text('客户端类型'),
                        hint: '选择类型',
                        format: (v) => v == 'Qb' ? 'Qbittorrent' : 'Transmission',
                        onChange: (v) => setState(() {}),
                        children: [FSelectItem('Qbittorrent', 'Qb'), FSelectItem('Transmission', 'Tr')],
                      ),

                      // 协议
                      FSelect<String>(
                        controller: _protocolCtrl,
                        label: const Text('协议'),
                        hint: '选择协议',
                        format: (v) => v.toUpperCase(),
                        onChange: (v) => setState(() {}),
                        children: [FSelectItem('HTTP', 'http'), FSelectItem('HTTPS', 'https')],
                      ),

                      // 主机
                      FTextFormField(
                        controller: _hostCtrl,
                        label: const Text('主机'),
                        hint: '192.168.123.100',
                        validator: (v) => _validateRequired(v, '主机'),
                      ),

                      // 端口
                      FTextFormField(
                        controller: _portCtrl,
                        label: const Text('端口'),
                        hint: '8999',
                        keyboardType: TextInputType.number,
                        validator: _validatePort,
                      ),

                      // 用户名
                      FTextFormField(
                        controller: _usernameCtrl,
                        label: const Text('用户名'),
                        validator: (v) => _validateRequired(v, '用户名'),
                      ),

                      // 密码
                      FTextFormField(
                        controller: _passwordCtrl,
                        label: const Text('密码'),
                        obscureText: true,
                        validator: (v) => _validateRequired(v, '密码'),
                      ),

                      // 种子路径（从服务器获取）
                      pathsAsync.when(
                        loading: () => FTextFormField(
                          controller: TextEditingController(text: widget.downloader?.torrentPath ?? ''),
                          label: const Text('种子路径'),
                          hint: '加载中...',
                          enabled: false,
                        ),
                        error: (e, _) {
                          // 加载失败时回退到原数据
                          _pathCtrl ??= FSelectController<String>(vsync: this, value: widget.downloader?.torrentPath);
                          return FSelect<String>(
                            controller: _pathCtrl!,
                            label: const Text('种子路径'),
                            hint: '选择路径',
                            format: (v) => v,
                            validator: (v) => (v == null || v.isEmpty) ? '请选择路径' : null,
                            onChange: (v) => setState(() {}),
                            children: widget.downloader != null && widget.downloader!.torrentPath.isNotEmpty
                                ? [FSelectItem(widget.downloader!.torrentPath, widget.downloader!.torrentPath)]
                                : [],
                          );
                        },
                        data: (paths) {
                          // 确保原路径在列表中（编辑时）
                          if (widget.downloader != null &&
                              widget.downloader!.torrentPath.isNotEmpty &&
                              !paths.contains(widget.downloader!.torrentPath)) {
                            paths = [widget.downloader!.torrentPath, ...paths];
                          }
                          _pathCtrl ??= FSelectController<String>(
                            vsync: this,
                            value: paths.contains(widget.downloader?.torrentPath)
                                ? widget.downloader!.torrentPath
                                : (paths.isNotEmpty ? paths.first : null),
                          );
                          return FSelect<String>(
                            controller: _pathCtrl!,
                            label: const Text('种子路径'),
                            hint: '选择路径',
                            format: (v) => v,
                            validator: (v) => (v == null || v.isEmpty) ? '请选择路径' : null,
                            onChange: (v) => setState(() {}),
                            children: paths.map((p) => FSelectItem(p, p)).toList(),
                          );
                        },
                      ),
                      FTileGroup(
                        style: fTileGroupStyle(context, fontSize: 12).call,
                        children: [
                          // 启用
                          FTile(
                            prefix: Icon(FIcons.power, size: 14),
                            title: const Text('启用'),
                            subtitle: const Text('是否激活此下载器'),
                            suffix: FSwitch(
                              style: fSwitchStyle(context).call,
                              value: _isActive,
                              onChange: (v) => setState(() => _isActive = v),
                            ),
                          ),

                          // 辅种
                          FTile(
                            prefix: Icon(FIcons.zap, size: 14),
                            title: const Text('辅种'),
                            subtitle: const Text('是否启用辅种'),
                            suffix: FSwitch(
                              style: fSwitchStyle(context).call,
                              value: !_brush,
                              onChange: (v) => setState(() => _brush = !v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ——— 按钮 ———
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FButton(
                      style: FButtonStyle.outline(),
                      onPress: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FButton(onPress: _save, child: Text(_isEdit ? '保存' : '添加')),
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
