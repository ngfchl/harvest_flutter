import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

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
              decoration: BoxDecoration(color: context.theme.colors.border, borderRadius: BorderRadius.circular(99)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: FTileGroup(
                  children: options
                      .map(
                        (t) => FTile(
                          title: Text(labelBuilder(t)),
                          onPress: () {
                            onSelected(t);
                            Navigator.pop(ctx);
                          },
                          suffix: t == selected
                              ? Icon(FIcons.check, size: 18, color: context.theme.colors.primary)
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
          const FDivider(),
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
              FSwitch(value: _advance, onChange: (v) => setState(() => _advance = v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AsyncValue<List<Downloader>> downloadersAsync) {
    return downloadersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
              FTextField(controller: _nameCtrl, label: const Text('任务名称')),
              const SizedBox(height: 12),

              FTileGroup(
                children: [
                  FTile(
                    title: const Text('选择源下载器'),
                    subtitle: Text(_sourceDownloader?.name ?? '请选择'),
                    suffix: const Icon(FIcons.chevronRight, size: 18),
                    onPress: () => _showSelectSheet<Downloader>(
                      title: '选择源下载器',
                      options: downloaders,
                      selected: _sourceDownloader,
                      labelBuilder: (d) => d.name,
                      onSelected: (v) => _onSourceChanged(downloaders, v),
                    ),
                  ),
                  FTile(
                    title: const Text('选择目标下载器'),
                    subtitle: Text(_distDownloader?.name ?? '请选择'),
                    suffix: const Icon(FIcons.chevronRight, size: 18),
                    onPress: () => _showSelectSheet<Downloader>(
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

              FTextField(
                controller: _folderMapCtrl,
                label: const Text('文件夹映射'),
                maxLines: 3,
                description: const Text(
                  '1. 格式：源文件夹->目标文件夹，多个映射请换行。\n'
                  '2. 只有匹配上箭头前面的源文件夹才会被转移到目标文件夹。\n'
                  '   留空表示转移全部种子。\n'
                  '3. 未完成的种子会被忽略',
                ),
              ),
              const SizedBox(height: 8),

              FTileGroup(
                children: [
                  FTile(
                    title: const Text('开启任务'),
                    suffix: FSwitch(value: _enabled, onChange: (v) => setState(() => _enabled = v)),
                  ),
                  FTile(
                    title: const Text('跳过校验'),
                    subtitle: const Text('仅目标为qBittorrent下载器时生效'),
                    suffix: FSwitch(value: _skipChecking, onChange: (v) => setState(() => _skipChecking = v)),
                  ),
                  FTile(
                    title: const Text('删除源种子'),
                    subtitle: const Text('种子迁移任务完成是否删除源种子'),
                    suffix: FSwitch(
                      value: _removeSourceTorrents,
                      onChange: (v) => setState(() => _removeSourceTorrents = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              FTextField(controller: _minuteCtrl, label: const Text('分钟')),
              const SizedBox(height: 12),
              FTextField(controller: _hourCtrl, label: const Text('小时')),

              if (_advance) ...[
                const SizedBox(height: 12),
                FTextField(controller: _dayOfWeekCtrl, label: const Text('周几')),
                const SizedBox(height: 12),
                FTextField(controller: _dayOfMonthCtrl, label: const Text('几号')),
                const SizedBox(height: 12),
                FTextField(controller: _monthOfYearCtrl, label: const Text('几月')),
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
            child: FButton(
              style: FButtonStyle.outline(),
              onPress: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FButton(
              onPress: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }
}
