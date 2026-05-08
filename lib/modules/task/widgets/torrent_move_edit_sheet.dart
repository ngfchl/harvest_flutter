import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../download/model/downloader.dart';
import '../../download/provider/downloader_provider.dart';
import '../model/crontab.dart';
import '../model/schedule.dart';
import '../provider/schedule_provider.dart';

class TorrentMoveEditSheet extends ConsumerStatefulWidget {
  final Schedule? task;

  const TorrentMoveEditSheet({super.key, this.task});

  @override
  ConsumerState<TorrentMoveEditSheet> createState() => _TorrentMoveEditSheetState();
}

class _TorrentMoveEditSheetState extends ConsumerState<TorrentMoveEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _folderMapCtrl;
  late final TextEditingController _minuteCtrl;
  late final TextEditingController _hourCtrl;
  late final TextEditingController _dayOfWeekCtrl;
  late final TextEditingController _dayOfMonthCtrl;
  late final TextEditingController _monthOfYearCtrl;

  Downloader? _sourceDownloader;
  Downloader? _distDownloader;
  bool _enabled = true;
  bool _skipChecking = false;
  bool _removeSourceTorrents = false;
  bool _advance = false;
  bool _saving = false;
  bool _downloadersInited = false;

  late Map<String, dynamic> _kwargs;

  bool get _isEdit => widget.task != null;

  /// 兼容不同下载器类型获取保存路径
  String _getSavePath(Downloader d) {
    return d.isQb ? (d.qbPrefs?.savePath ?? '') : (d.trPrefs?.downloadDir ?? '');
  }

  @override
  void initState() {
    super.initState();
    final task = widget.task;

    _nameCtrl = TextEditingController(text: task?.name ?? '');
    _minuteCtrl = TextEditingController(text: task?.crontab?.minute ?? '1');
    _hourCtrl = TextEditingController(text: task?.crontab?.hour ?? '*');
    _dayOfWeekCtrl = TextEditingController(text: task?.crontab?.dayOfWeek ?? '*');
    _dayOfMonthCtrl = TextEditingController(text: task?.crontab?.dayOfMonth ?? '*');
    _monthOfYearCtrl = TextEditingController(text: task?.crontab?.monthOfYear ?? '*');
    _enabled = task?.enabled ?? true;

    try {
      _kwargs = jsonDecode(task?.kwargs ?? '{}') as Map<String, dynamic>;
    } catch (_) {
      _kwargs = {};
    }

    _skipChecking = _kwargs['skip_checking'] as bool? ?? false;
    _removeSourceTorrents = _kwargs['remove_source_torrents'] as bool? ?? false;
    _folderMapCtrl = TextEditingController(text: (List<String>.from(_kwargs['folder_map'] ?? [])).join('\n'));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _folderMapCtrl.dispose();
    _minuteCtrl.dispose();
    _hourCtrl.dispose();
    _dayOfWeekCtrl.dispose();
    _dayOfMonthCtrl.dispose();
    _monthOfYearCtrl.dispose();
    super.dispose();
  }

  void _initDownloaders(List<Downloader> downloaders) {
    if (_downloadersInited) return;
    _downloadersInited = true;
    _sourceDownloader = downloaders.firstWhereOrNull((d) => d.id == _kwargs['source_downloader_id']);
    _distDownloader = downloaders.firstWhereOrNull((d) => d.id == _kwargs['dist_downloader_id']);
  }

  void _onSourceChanged(List<Downloader> all, Downloader? item) {
    setState(() {
      _sourceDownloader = item;
      if (_distDownloader == null || _distDownloader?.host != item?.host) {
        _distDownloader = all.firstWhereOrNull((d) => d.id != item?.id && d.host == item?.host);
      }
      final savePath = item != null ? _getSavePath(item) : '';
      if (_folderMapCtrl.text.isEmpty) {
        _folderMapCtrl.text = '$savePath->';
      } else {
        final parts = _folderMapCtrl.text.split('->');
        parts.removeAt(0);
        parts.insert(0, savePath);
        _folderMapCtrl.text = parts.join('->');
      }
    });
  }

  void _onDistChanged(Downloader? item) {
    setState(() {
      _distDownloader = item;
      final savePath = item != null ? _getSavePath(item) : '';
      if (_folderMapCtrl.text.endsWith('->')) {
        _folderMapCtrl.text = '${_folderMapCtrl.text}$savePath';
      } else {
        final parts = _folderMapCtrl.text.split('->');
        parts.removeLast();
        parts.add(savePath);
        _folderMapCtrl.text = parts.join('->');
      }
    });
  }

  bool _validate() {
    if (_nameCtrl.text.trim().isEmpty) return _err('请填写任务名称');
    if (_minuteCtrl.text.trim().isEmpty) return _err('请填写分钟');
    if (_hourCtrl.text.trim().isEmpty) return _err('请填写小时');
    return true;
  }

  bool _err(String msg) {
    Toast.error(msg);
    return false;
  }

  Future<void> _save() async {
    if (_saving || !_validate()) return;
    setState(() => _saving = true);

    try {
      _kwargs
        ..['source_downloader_id'] = _sourceDownloader?.id
        ..['dist_downloader_id'] = _distDownloader?.id
        ..['folder_map'] = _folderMapCtrl.text.split('\n').where((s) => s.trim().isNotEmpty).toList()
        ..['remove_source_torrents'] = _removeSourceTorrents
        ..['skip_checking'] = _skipChecking;

      final schedule = Schedule(
        id: widget.task?.id ?? 0,
        name: _nameCtrl.text.trim(),
        task: '种子迁移任务',
        description: widget.task?.description ?? '',
        crontab: CrontabItem(
          id: widget.task?.crontabId ?? 0,
          express: '',
          minute: _minuteCtrl.text.trim(),
          hour: _hourCtrl.text.trim(),
          dayOfWeek: _dayOfWeekCtrl.text.trim(),
          dayOfMonth: _dayOfMonthCtrl.text.trim(),
          monthOfYear: _monthOfYearCtrl.text.trim(),
        ),
        args: widget.task?.args ?? '[]',
        kwargs: jsonEncode(_kwargs),
        enabled: _enabled,
      );

      await ref.read(scheduleProvider.notifier).save(schedule);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // if (mounted) _err('保存失败: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSelectSheet<T>({
    required String title,
    required List<T> options,
    required T? selected,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: shadcn.Theme.of(context).colorScheme.border, borderRadius: BorderRadius.circular(99)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: options
                      .map(
                        (t) => _SheetTile(
                          title: Text(labelBuilder(t)),
                          onTap: () {
                            onSelected(t);
                            Navigator.pop(ctx);
                          },
                          trailing: t == selected
                              ? Icon(shadcn.LucideIcons.check, size: 18, color: shadcn.Theme.of(context).colorScheme.primary)
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final downloadersAsync = ref.watch(downloaderListProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(child: _buildForm(downloadersAsync)),
          const Divider(height: 1),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_isEdit ? '编辑任务' : '添加任务', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Row(
            children: [
              const Text('高级', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Switch(value: _advance, onChanged: (v) => setState(() => _advance = v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AsyncValue<List<Downloader>> downloadersAsync) {
    return downloadersAsync.when(
      loading: () => const Center(child: shadcn.CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载下载器失败: $e')),
      data: (downloaders) {
        _initDownloaders(downloaders);

        final distOptions = _sourceDownloader != null
            ? downloaders.where((d) => d.id != _sourceDownloader?.id && d.host == _sourceDownloader?.host).toList()
            : <Downloader>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              shadcn.TextField(controller: _nameCtrl, hintText: '任务名称'),
              const SizedBox(height: 12),

              Column(
                children: [
                  _SheetTile(
                    title: const Text('选择源下载器'),
                    subtitle: Text(_sourceDownloader?.name ?? '请选择'),
                    trailing: const Icon(shadcn.LucideIcons.chevronRight, size: 18),
                    onTap: () => _showSelectSheet<Downloader>(
                      title: '选择源下载器',
                      options: downloaders,
                      selected: _sourceDownloader,
                      labelBuilder: (d) => d.name,
                      onSelected: (v) => _onSourceChanged(downloaders, v),
                    ),
                  ),
                  _SheetTile(
                    title: const Text('选择目标下载器'),
                    subtitle: Text(_distDownloader?.name ?? '请选择'),
                    trailing: const Icon(shadcn.LucideIcons.chevronRight, size: 18),
                    onTap: () => _showSelectSheet<Downloader>(
                      title: '选择目标下载器',
                      options: distOptions,
                      selected: _distDownloader,
                      labelBuilder: (d) => d.name,
                      onSelected: _onDistChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              shadcn.TextField(
                controller: _folderMapCtrl,
                hintText: '文件夹映射',
                maxLines: 3,
              ),
              const SizedBox(height: 8),

              Column(
                children: [
                  _SheetTile(
                    title: const Text('开启任务'),
                    trailing: Switch(value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
                  ),
                  _SheetTile(
                    title: const Text('跳过校验'),
                    subtitle: const Text('仅目标为qBittorrent下载器时生效'),
                    trailing: Switch(value: _skipChecking, onChanged: (v) => setState(() => _skipChecking = v)),
                  ),
                  _SheetTile(
                    title: const Text('删除源种子'),
                    subtitle: const Text('种子迁移任务完成是否删除源种子'),
                    trailing: Switch(
                      value: _removeSourceTorrents,
                      onChanged: (v) => setState(() => _removeSourceTorrents = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              shadcn.TextField(controller: _minuteCtrl, hintText: '分钟'),
              const SizedBox(height: 12),
              shadcn.TextField(controller: _hourCtrl, hintText: '小时'),

              if (_advance) ...[
                const SizedBox(height: 12),
                shadcn.TextField(controller: _dayOfWeekCtrl, hintText: '周几'),
                const SizedBox(height: 12),
                shadcn.TextField(controller: _dayOfMonthCtrl, hintText: '几号'),
                const SizedBox(height: 12),
                shadcn.TextField(controller: _monthOfYearCtrl, hintText: '几月'),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: shadcn.Button.outline(
              onPressed: () => Navigator.pop(context),
              child: Center(child: const Text('取消')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: shadcn.Button.primary(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 16, height: 16, child: shadcn.CircularProgressIndicator(strokeWidth: 2))
                  : Center(child: const Text('保存')),
            ),
          ),
        ],
      ),
    );
  }
}


class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int? maxLines;
  final String? helperText;

  const _SheetTextField({
    required this.controller,
    required this.label,
    this.maxLines,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return shadcn.TextField(
      controller: controller,
      maxLines: maxLines,
      hintText: label,
    );
  }
}

class _SheetGroup extends StatelessWidget {
  final List<Widget> children;

  const _SheetGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SheetTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(style: const TextStyle(fontSize: 14), child: title),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 12, color: cs.mutedForeground),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
