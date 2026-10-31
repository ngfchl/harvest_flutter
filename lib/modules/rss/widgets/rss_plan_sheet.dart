import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/model/downloader_category.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';
import 'package:harvest/modules/download/service/downloader_service.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:harvest/widgets/shadcn_compat.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../model/rss_models.dart';
import '../provider/rss_provider.dart';
import 'rss_common.dart';

void showRssPlanSheet(BuildContext context, {RssPlan? plan}) {
  showRssSheet(
    context: context,
    title: plan == null ? '添加订阅方案' : '编辑订阅方案',
    isScrollControlled: true,
    desktopMaxWidth: 560,
    desktopMaxHeight: 820,
    builder: (_) => RssPlanSheet(plan: plan),
  );
}

class RssPlanSheet extends ConsumerStatefulWidget {
  final RssPlan? plan;

  const RssPlanSheet({super.key, this.plan});

  @override
  ConsumerState<RssPlanSheet> createState() => _RssPlanSheetState();
}

class _RssPlanSheetState extends ConsumerState<RssPlanSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _excludesCtrl;
  late final TextEditingController _savePathCtrl;

  int _minSizeMb = 1024;
  int _maxSizeMb = 20480;

  String _category = '';
  List<String> _discount = const [];
  List<String> _resolution = const [];
  List<String> _videoCodec = const [];
  List<String> _audioCodec = const [];
  List<String> _source = const [];
  List<String> _publisher = const [];
  List<String> _tagList = const [];

  bool _enabled = true;
  bool _startDownload = true;
  int _downloaderId = 0;
  String _dlCategory = '';
  List<DownloaderCategory> _categories = const [];
  bool _loadingCategories = false;
  Set<int> _feedIds = {};
  bool _saving = false;

  bool get _isEdit => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _excludesCtrl = TextEditingController(
      text: (p?.excludes ?? const []).join(', '),
    );
    _savePathCtrl = TextEditingController(text: p?.downloaderSavePath ?? '');
    _minSizeMb = p?.minSizeMb ?? 1024;
    _maxSizeMb = p?.maxSizeMb ?? 20480;
    _category = p?.category ?? '';
    _discount = List.from(p?.discount ?? const []);
    _resolution = List.from(p?.resolution ?? const []);
    _videoCodec = List.from(p?.videoCodec ?? const []);
    _audioCodec = List.from(p?.audioCodec ?? const []);
    _source = List.from(p?.source ?? const []);
    _publisher = List.from(p?.publisher ?? const []);
    _tagList = List.from(p?.tags ?? const []);
    _enabled = p?.enabled ?? true;
    _startDownload = p?.startDownload ?? true;
    _downloaderId = p?.downloaderId ?? 0;
    _dlCategory = p?.downloaderCategory ?? '';
    _feedIds = Set.from(p?.rssFeedIds ?? const <int>[]);
    if (_downloaderId != 0) _loadCategories(_downloaderId);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _excludesCtrl.dispose();
    _savePathCtrl.dispose();
    super.dispose();
  }

  // ─────────────────── 数据加载 ───────────────────

  Future<void> _loadCategories(int downloaderId) async {
    if (downloaderId == 0) return;
    setState(() => _loadingCategories = true);
    try {
      final cats = await DownloaderService.fetchCategories(downloaderId);
      if (mounted && _downloaderId == downloaderId) {
        setState(() => _categories = cats);
      }
    } catch (_) {
      if (mounted && _downloaderId == downloaderId) {
        setState(() => _categories = const []);
      }
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  void _onDownloaderChanged(int id) {
    setState(() {
      _downloaderId = id;
      _dlCategory = '';
      _categories = const [];
    });
    _loadCategories(id);
  }

  void _onCategoryChanged(String name) {
    DownloaderCategory? picked;
    for (final c in _categories) {
      if (c.name == name) {
        picked = c;
        break;
      }
    }
    setState(() {
      _dlCategory = name;
      final sp = picked?.savePath ?? '';
      if (sp.isNotEmpty) _savePathCtrl.text = sp;
    });
  }

  // ─────────────────── 保存 ───────────────────

  List<String> _splitExcludes() => _excludesCtrl.text
      .split(RegExp(r'[,，]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (_saving) return;
    if (_nameCtrl.text.trim().isEmpty) {
      Toast.error('请填写方案名称');
      return;
    }
    if (_downloaderId == 0) {
      Toast.error('请选择目标下载器');
      return;
    }
    setState(() => _saving = true);
    try {
      final plan = RssPlan(
        id: widget.plan?.id ?? 0,
        name: _nameCtrl.text.trim(),
        enabled: _enabled,
        startDownload: _startDownload,
        minSizeMb: _minSizeMb,
        maxSizeMb: _maxSizeMb,
        category: _category,
        discount: _discount,
        excludes: _splitExcludes(),
        resolution: _resolution,
        videoCodec: _videoCodec,
        audioCodec: _audioCodec,
        source: _source,
        publisher: _publisher,
        tags: _tagList,
        downloaderId: _downloaderId,
        downloaderCategory: _dlCategory,
        downloaderSavePath: _savePathCtrl.text.trim(),
        rssFeedIds: _feedIds.toList()..sort(),
      );
      await ref.read(rssPlansProvider.notifier).save(plan);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─────────────────── 工具 ───────────────────

  List<String> _tagOptions(List<RssTag> tags, String category) => tags
      .where((t) => t.category == category && t.enabled)
      .map((t) => t.name)
      .toList();

  String _fmtGb(int mb) {
    final gb = mb / 1024;
    return gb == gb.roundToDouble()
        ? gb.toStringAsFixed(0)
        : gb.toStringAsFixed(1);
  }

  String _downloaderLabel(List downloaders) {
    if (_downloaderId == 0) return '未选择';
    for (final d in downloaders) {
      if (d.id == _downloaderId) return '${d.name}（${d.category}）';
    }
    return '下载器 #$_downloaderId';
  }

  String _feedsLabel(List<RssFeed> feeds) {
    if (_feedIds.isEmpty) return '未选择';
    final names = <String>[];
    for (final f in feeds) {
      if (_feedIds.contains(f.id)) names.add(f.name);
    }
    return names.isEmpty ? '${_feedIds.length} 个源' : names.join('、');
  }

  // ─────────────────── 选择面板 ───────────────────

  void _pickFeedsSheet() {
    final feeds = ref.read(rssFeedsProvider).value ?? const <RssFeed>[];
    showRssSheet(
      context: context,
      title: '关联 RSS 源',
      desktopMaxWidth: 380,
      desktopMaxHeight: 460,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ListView(
          shrinkWrap: true,
          children: [
            for (final f in feeds)
              ListTile(
                title: Text(f.name),
                trailing: _feedIds.contains(f.id)
                    ? Icon(
                        LucideIcons.check,
                        size: 18,
                        color: Theme.of(ctx).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setDialogState(() {
                    final next = Set<int>.from(_feedIds);
                    if (!next.remove(f.id)) next.add(f.id);
                    _feedIds = next;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── UI 组件 ───────────────────

  Widget _fieldLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.foreground,
        ),
      ),
    );
  }

  Widget _sizeSlider() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('种子大小范围'),
        Text(
          '${_fmtGb(_minSizeMb)} GB  ~  ${_fmtGb(_maxSizeMb)} GB',
          style: TextStyle(
            fontSize: 13,
            color: cs.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: SliderValue.ranged(_minSizeMb / 1024, _maxSizeMb / 1024),
          min: 0,
          max: 100,
          divisions: 200,
          valueIndicatorBuilder: (_, v) => SliderValueIndicator(
            value: v,
            formatter: (x) => '${x.toStringAsFixed(1)}GB',
          ),
          onChanged: (v) {
            setState(() {
              _minSizeMb = (v.start * 1024).round();
              _maxSizeMb = (v.end * 1024).round();
            });
          },
        ),
      ],
    );
  }

  Widget _downloaderSelect(List downloaders) {
    final hasDownloader = _downloaderId != 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('目标下载器'),
        SizedBox(
          width: double.infinity,
          child: Select<int>(
            value: _downloaderId == 0 ? null : _downloaderId,
            placeholder: Text(_downloaderLabel(downloaders)),
            itemBuilder: (_, _) => Text(_downloaderLabel(downloaders)),
            popupConstraints: const BoxConstraints(maxHeight: 300),
            popup: SelectPopup<int>(
              items: SelectItemList(
                children: [
                  for (final d in downloaders)
                    SelectItemButton<int>(
                      value: d.id,
                      child: Text('${d.name}（${d.category}）'),
                    ),
                ],
              ),
            ).call,
            onChanged: (v) {
              if (v != null) _onDownloaderChanged(v);
            },
          ),
        ),
        if (hasDownloader) ...[
          const SizedBox(height: 12),
          _fieldLabel('下载器分类'),
          SizedBox(
            width: double.infinity,
            child: Select<String>(
              value: _dlCategory.isEmpty ? null : _dlCategory,
              placeholder: Text(
                _loadingCategories
                    ? '读取分类中...'
                    : _categories.isEmpty
                    ? '该下载器暂无分类'
                    : '请选择分类',
              ),
              itemBuilder: (_, _) => Text(_dlCategory),
              popupConstraints: const BoxConstraints(maxHeight: 300),
              popup: SelectPopup<String>(
                items: SelectItemList(
                  children: [
                    for (final c in _categories)
                      SelectItemButton<String>(
                        value: c.name,
                        child: Text(c.name),
                      ),
                  ],
                ),
              ).call,
              enabled: !_loadingCategories && _categories.isNotEmpty,
              onChanged: (v) {
                if (v != null) _onCategoryChanged(v);
              },
            ),
          ),
          if (_dlCategory.isNotEmpty) ...[
            const SizedBox(height: 12),
            ShadTextField(
              controller: _savePathCtrl,
              labelText: '保存路径',
              hintText: '选择分类后自动填充，可手动修改',
              helperText: '已根据所选分类自动填充',
            ),
          ],
        ],
      ],
    );
  }

  Widget _multiSelectField({
    required String label,
    required String tagCategory,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
    required List<RssTag> tags,
    required String hint,
  }) {
    final options = _tagOptions(tags, tagCategory);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel(label),
        if (options.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '暂无「$hint」标签，可到订阅标签页导入',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: MultiSelect<String>(
              value: selected,
              placeholder: Text(hint),
              itemBuilder: (_, v) =>
                  Text(v, style: const TextStyle(fontSize: 12)),
              popupConstraints: const BoxConstraints(maxHeight: 320),
              popup: SelectPopup<String>(
                items: SelectItemList(
                  children: [
                    for (final o in options)
                      SelectItemButton<String>(value: o, child: Text(o)),
                  ],
                ),
              ).call,
              onChanged: (v) => onChanged(v?.toList() ?? const []),
            ),
          ),
      ],
    );
  }

  Widget _categorySelect(List<RssTag> tags) {
    final options = _tagOptions(tags, 'category');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('分类'),
        if (options.isEmpty)
          ShadTextField(
            controller: TextEditingController(text: _category),
            labelText: '分类',
            hintText: '暂无标签，可到订阅标签页导入',
            onChanged: (_) {},
          )
        else
          SizedBox(
            width: double.infinity,
            child: Select<String>(
              value: _category.isEmpty ? null : _category,
              placeholder: const Text('请选择分类'),
              itemBuilder: (_, _) => Text(_category),
              popupConstraints: const BoxConstraints(maxHeight: 300),
              popup: SelectPopup<String>(
                items: SelectItemList(
                  children: [
                    for (final o in options)
                      SelectItemButton<String>(value: o, child: Text(o)),
                  ],
                ),
              ).call,
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
          ),
      ],
    );
  }

  // ─────────────────── 主体 ───────────────────

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final downloaders = ref.watch(downloaderListProvider).value ?? const [];
    final feeds = ref.watch(rssFeedsProvider).value ?? const <RssFeed>[];
    final tags = ref.watch(rssTagsProvider).value ?? const <RssTag>[];

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              _isEdit ? '编辑订阅方案' : '添加订阅方案',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShadTextField(
                    controller: _nameCtrl,
                    labelText: '方案名称',
                    hintText: '例如：默认订阅方案',
                  ),
                  const SizedBox(height: 16),
                  _sizeSlider(),
                  const SizedBox(height: 16),
                  _downloaderSelect(downloaders),
                  const SizedBox(height: 16),
                  _categorySelect(tags),
                  const SizedBox(height: 16),
                  _fieldLabel('关联 RSS 源'),
                  Builder(
                    builder: (ctx) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pickFeedsSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(ctx).colorScheme.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _feedsLabel(feeds),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _feedIds.isEmpty
                                      ? Theme.of(
                                          ctx,
                                        ).colorScheme.mutedForeground
                                      : Theme.of(ctx).colorScheme.foreground,
                                ),
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronDown,
                              size: 16,
                              color: Theme.of(ctx).colorScheme.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _multiSelectField(
                    label: '分辨率',
                    tagCategory: 'resolution',
                    selected: _resolution,
                    onChanged: (v) => setState(() => _resolution = v),
                    tags: tags,
                    hint: '选择分辨率',
                  ),
                  const SizedBox(height: 16),
                  _multiSelectField(
                    label: '视频编码',
                    tagCategory: 'video_codec',
                    selected: _videoCodec,
                    onChanged: (v) => setState(() => _videoCodec = v),
                    tags: tags,
                    hint: '选择视频编码',
                  ),
                  const SizedBox(height: 16),
                  _multiSelectField(
                    label: '音频编码',
                    tagCategory: 'audio_codec',
                    selected: _audioCodec,
                    onChanged: (v) => setState(() => _audioCodec = v),
                    tags: tags,
                    hint: '选择音频编码',
                  ),
                  const SizedBox(height: 16),
                  _multiSelectField(
                    label: '来源媒介',
                    tagCategory: 'source',
                    selected: _source,
                    onChanged: (v) => setState(() => _source = v),
                    tags: tags,
                    hint: '选择来源媒介',
                  ),
                  const SizedBox(height: 16),
                  _multiSelectField(
                    label: '制作组',
                    tagCategory: 'publisher',
                    selected: _publisher,
                    onChanged: (v) => setState(() => _publisher = v),
                    tags: tags,
                    hint: '选择制作组',
                  ),
                  const SizedBox(height: 16),
                  _multiSelectField(
                    label: '优惠关键字',
                    tagCategory: 'discount',
                    selected: _discount,
                    onChanged: (v) => setState(() => _discount = v),
                    tags: tags,
                    hint: '选择优惠关键字',
                  ),
                  const SizedBox(height: 16),
                  _multiSelectField(
                    label: '其他标签',
                    tagCategory: 'tags',
                    selected: _tagList,
                    onChanged: (v) => setState(() => _tagList = v),
                    tags: tags,
                    hint: '选择其他标签',
                  ),
                  const SizedBox(height: 16),
                  ShadTextField(
                    controller: _excludesCtrl,
                    labelText: '排除关键字',
                    hintText: '多个用逗号分隔，如：CAM, TS',
                    helperText: '排除关键字没有对应标签，手动填写',
                  ),
                  const SizedBox(height: 16),
                  RssSheetGroup(
                    children: [
                      RssSheetTile(
                        title: const Text('启用方案'),
                        trailing: Switch(
                          value: _enabled,
                          onChanged: (v) => setState(() => _enabled = v),
                        ),
                      ),
                      RssSheetTile(
                        title: const Text('推送后立即下载'),
                        trailing: Switch(
                          value: _startDownload,
                          onChanged: (v) => setState(() => _startDownload = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Button.outline(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Center(child: Text('取消')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button.primary(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Center(child: Text('保存')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
