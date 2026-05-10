import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/downloader.dart';
import '../provider/downloader_provider.dart';

class DownloaderEditorDialog extends ConsumerStatefulWidget {
  final Downloader? downloader;
  final void Function(Downloader) onSaved;

  const DownloaderEditorDialog({super.key, this.downloader, required this.onSaved});

  @override
  ConsumerState<DownloaderEditorDialog> createState() => _DownloaderEditorDialogState();
}

class _DownloaderEditorDialogState extends ConsumerState<DownloaderEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _hostCtrl;
  late final TextEditingController _portCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _externalHostCtrl;

  late String _category;
  late String _protocol;
  String? _path;
  bool _pathTouched = false;
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
    _externalHostCtrl = TextEditingController(
      text: d?.externalHost ?? '',
    );
    _category = d?.category ?? 'Qb';
    _protocol = d?.protocol ?? 'http';
    _path = d?.torrentPath;
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
    _externalHostCtrl.dispose();
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
    final valid = _formKey.currentState!.validate();
    setState(() => _pathTouched = true);
    if (!valid || _path == null || _path!.isEmpty) return;

    final d = Downloader(
      id: widget.downloader?.id ?? 0,
      name: _nameCtrl.text.trim(),
      category: _category,
      protocol: _protocol,
      host: _hostCtrl.text.trim(),
      port: int.tryParse(_portCtrl.text.trim()) ?? 0,
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      torrentPath: _path ?? widget.downloader?.torrentPath ?? '',
      isActive: _isActive,
      brush: _brush,
      sortId: widget.downloader?.sortId ?? 0,
      externalHost: _externalHostCtrl.text.trim().isNotEmpty
          ? _externalHostCtrl.text.trim()
          : '$_protocol://${_hostCtrl.text.trim()}:${_portCtrl.text.trim()}',
    );

    widget.onSaved(d);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final pathsAsync = ref.watch(downloaderPathsProvider);

    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? '编辑下载器' : '添加下载器',
                      style: theme.typography.large.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  shadcn.IconButton.ghost(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(shadcn.LucideIcons.x, size: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _textField(
                        controller: _nameCtrl,
                        label: '名称',
                        hintText: '例如: QB8999',
                        validator: (v) => _validateRequired(v, '名称'),
                      ),
                      const SizedBox(height: 8),
                      _dropdown(
                        label: '客户端类型',
                        value: _category,
                        items: const {'Qb': 'Qbittorrent', 'Tr': 'Transmission'},
                        onChanged: (v) => setState(() => _category = v ?? 'Qb'),
                      ),
                      const SizedBox(height: 8),
                      _dropdown(
                        label: '协议',
                        value: _protocol,
                        items: const {'http': 'HTTP', 'https': 'HTTPS'},
                        onChanged: (v) => setState(() => _protocol = v ?? 'http'),
                      ),
                      const SizedBox(height: 8),
                      _textField(
                        controller: _hostCtrl,
                        label: '主机',
                        hintText: '192.168.123.100',
                        validator: (v) => _validateRequired(v, '主机'),
                      ),
                      const SizedBox(height: 8),
                      _textField(
                        controller: _portCtrl,
                        label: '端口',
                        hintText: '8999',
                        keyboardType: TextInputType.number,
                        validator: _validatePort,
                      ),
                      const SizedBox(height: 8),
                      _textField(
                        controller: _usernameCtrl,
                        label: '用户名',
                        validator: (v) => _validateRequired(v, '用户名'),
                      ),
                      const SizedBox(height: 8),
                      _textField(
                        controller: _passwordCtrl,
                        label: '密码',
                        obscureText: true,
                        validator: (v) => _validateRequired(v, '密码'),
                      ),
                      const SizedBox(height: 8),
                      _textField(
                        controller: _externalHostCtrl,
                        label: 'External Host',
                        hintText: 'http://127.0.0.1:8999',
                      ),
                      const SizedBox(height: 8),
                      pathsAsync.when(
                        loading: () => _textField(
                          controller: TextEditingController(text: widget.downloader?.torrentPath ?? ''),
                          label: '种子路径',
                          hintText: '加载中...',
                          enabled: false,
                        ),
                        error: (e, _) {
                          _path ??= widget.downloader?.torrentPath;
                          final items = widget.downloader != null && widget.downloader!.torrentPath.isNotEmpty
                              ? <String>[widget.downloader!.torrentPath]
                              : <String>[];
                          return _pathDropdown(items);
                        },
                        data: (paths) {
                          if (widget.downloader != null &&
                              widget.downloader!.torrentPath.isNotEmpty &&
                              !paths.contains(widget.downloader!.torrentPath)) {
                            paths = [widget.downloader!.torrentPath, ...paths];
                          }
                          _path ??= paths.contains(widget.downloader?.torrentPath)
                              ? widget.downloader!.torrentPath
                              : (paths.isNotEmpty ? paths.first : null);
                          return _pathDropdown(paths);
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: cs.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _switchRow(
                                icon: shadcn.LucideIcons.power,
                                title: '启用',
                                value: _isActive,
                                onChanged: (v) => setState(() => _isActive = v),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 56,
                              color: cs.border,
                            ),
                            Expanded(
                              child: _switchRow(
                                icon: shadcn.LucideIcons.zap,
                                title: '辅种',
                                value: !_brush,
                                onChanged: (v) => setState(() => _brush = !v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: shadcn.Button.outline(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Center(child: Text('取消')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: shadcn.Button.primary(
                      onPressed: _save,
                      child: Center(child: Text(_isEdit ? '保存' : '添加')),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      onFieldSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.small.copyWith(
            color: cs.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: shadcn.Select<String>(
            value: items.containsKey(value) ? value : null,
            placeholder: Text(label),
            itemBuilder: (_, selected) => Text(items[selected] ?? selected),
            popupConstraints: const BoxConstraints(maxHeight: 260),
            popup: shadcn.SelectPopup<String>(
              items: shadcn.SelectItemList(
                children: [
                  for (final entry in items.entries)
                    shadcn.SelectItemButton<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
              ),
            ).call,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _pathDropdown(List<String> paths) {
    final selected = _path != null && paths.contains(_path) ? _path : null;
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '种子路径',
          style: theme.typography.small.copyWith(
            color: cs.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: shadcn.Select<String>(
            value: selected,
            placeholder: const Text('选择路径'),
            itemBuilder: (_, value) => Text(value),
            popupConstraints: const BoxConstraints(maxHeight: 300),
            popup: shadcn.SelectPopup<String>(
              items: shadcn.SelectItemList(
                children: [
                  for (final path in paths)
                    shadcn.SelectItemButton<String>(
                      value: path,
                      child: Text(path),
                    ),
                ],
              ),
            ).call,
            onChanged: (value) {
              setState(() {
                _path = value;
                _pathTouched = true;
              });
            },
          ),
        ),
        if (_pathTouched && selected == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '请选择路径',
              style: theme.typography.xSmall.copyWith(color: cs.destructive),
            ),
          ),
      ],
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
