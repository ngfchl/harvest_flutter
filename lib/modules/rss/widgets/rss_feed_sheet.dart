import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/site/model/site_info.dart';
import 'package:harvest/modules/site/provider/site_provider.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/rss_models.dart';
import '../provider/rss_provider.dart';
import '../service/rss_service.dart';
import 'rss_common.dart';

/// 打开 RSS 源新增/编辑表单。
void showRssFeedSheet(BuildContext context, {RssFeed? feed}) {
  showRssSheet(
    context: context,
    title: feed == null ? '添加 RSS 源' : '编辑 RSS 源',
    isScrollControlled: true,
    builder: (_) => RssFeedSheet(feed: feed),
  );
}

class RssFeedSheet extends ConsumerStatefulWidget {
  final RssFeed? feed;

  const RssFeedSheet({super.key, this.feed});

  @override
  ConsumerState<RssFeedSheet> createState() => _RssFeedSheetState();
}

class _RssFeedSheetState extends ConsumerState<RssFeedSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _rssCtrl;
  late final TextEditingController _sortCtrl;

  bool _available = true;
  int _siteId = 0;
  bool _saving = false;
  bool _previewing = false;
  int _previewCount = -1;

  bool get _isEdit => widget.feed != null;

  @override
  void initState() {
    super.initState();
    final f = widget.feed;
    _nameCtrl = TextEditingController(text: f?.name ?? '');
    _rssCtrl = TextEditingController(text: f?.rss ?? '');
    _sortCtrl = TextEditingController(text: '${f?.sort ?? 1}');
    _available = f?.available ?? true;
    _siteId = f?.siteId ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rssCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_nameCtrl.text.trim().isEmpty) {
      Toast.error('请填写 RSS 源名称');
      return false;
    }
    final rss = _rssCtrl.text.trim();
    if (rss.isEmpty) {
      Toast.error('请填写 RSS 地址');
      return false;
    }
    if (!rss.startsWith('http://') && !rss.startsWith('https://')) {
      Toast.error('RSS 地址必须为 http/https');
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (_saving || !_validate()) return;
    setState(() => _saving = true);
    try {
      final feed = RssFeed(
        id: widget.feed?.id ?? 0,
        name: _nameCtrl.text.trim(),
        rss: _rssCtrl.text.trim(),
        sort: int.tryParse(_sortCtrl.text.trim()) ?? 1,
        available: _available,
        siteId: _siteId,
      );
      await ref.read(rssFeedsProvider.notifier).save(feed);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _preview() async {
    if (_previewing || widget.feed == null) return;
    setState(() => _previewing = true);
    try {
      final items = await RssService.previewFeed(widget.feed!.id);
      if (mounted) setState(() => _previewCount = items.length);
    } catch (_) {
      if (mounted) setState(() => _previewCount = -1);
    } finally {
      if (mounted) setState(() => _previewing = false);
    }
  }

  String _siteLabel(List<SiteInfo> sites) {
    if (_siteId == 0) return '不关联站点';
    SiteInfo? site;
    for (final s in sites) {
      if (s.id == _siteId) {
        site = s;
        break;
      }
    }
    if (site == null) return '站点 #$_siteId';
    final nick = site.nickname.trim();
    return nick.isEmpty ? site.site : '${site.site} · $nick';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final sites = ref.watch(siteInfoListProvider).value ?? const <SiteInfo>[];

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: shadcn.Text(
              _isEdit ? '编辑 RSS 源' : '添加 RSS 源',
              style: const shadcn.TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                    labelText: 'RSS 源名称',
                    hintText: '例如：华语电影',
                    helperText: '名称必须唯一',
                  ),
                  const SizedBox(height: 12),
                  ShadTextField(
                    controller: _rssCtrl,
                    labelText: 'RSS 地址',
                    hintText: 'https://example.com/rss.xml',
                    helperText: '必须为 http 或 https 地址',
                  ),
                  const SizedBox(height: 12),
                  ShadTextField(
                    controller: _sortCtrl,
                    labelText: '优先级',
                    hintText: '1',
                    keyboardType: TextInputType.number,
                    helperText: '数值越大越优先',
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel('关联站点'),
                  shadcn.Select<int>(
                    value: _siteId,
                    placeholder: shadcn.Text(_siteLabel(sites)),
                    itemBuilder: (_, _) => shadcn.Text(_siteLabel(sites)),
                    popupConstraints: const BoxConstraints(maxHeight: 300),
                    popup: shadcn.SelectPopup<int>(
                      items: shadcn.SelectItemList(
                        children: [
                          shadcn.SelectItemButton<int>(
                            value: 0,
                            child: const shadcn.Text('不关联站点'),
                          ),
                          for (final site in sites)
                            shadcn.SelectItemButton<int>(
                              value: site.id,
                              child: shadcn.Text(
                                site.nickname.trim().isEmpty
                                    ? site.site
                                    : '${site.site} · ${site.nickname}',
                              ),
                            ),
                        ],
                      ),
                    ).call,
                    onChanged: (v) {
                      if (v != null) setState(() => _siteId = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  RssSheetGroup(
                    children: [
                      RssSheetTile(
                        title: const shadcn.Text('启用'),
                        helper: const shadcn.Text('关闭后订阅不会拉取该源'),
                        trailing: shadcn.Switch(
                          value: _available,
                          onChanged: (v) => setState(() => _available = v),
                        ),
                      ),
                    ],
                  ),
                  if (_isEdit) ...[
                    const SizedBox(height: 12),
                    shadcn.Button.outline(
                      onPressed: _previewing ? null : _preview,
                      child: shadcn.Center(
                        child: shadcn.Text(
                          _previewing
                              ? '解析中...'
                              : _previewCount >= 0
                                  ? '解析成功，共 $_previewCount 条'
                                  : '解析预览',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const shadcn.Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: shadcn.Button.outline(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const shadcn.Center(child: shadcn.Text('取消')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: shadcn.Button.primary(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const shadcn.SizedBox(
                            width: 16,
                            height: 16,
                            child: shadcn.Center(
                              child: shadcn.CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const shadcn.Center(child: shadcn.Text('保存')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: shadcn.Text(
        text,
        style: shadcn.TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.foreground,
        ),
      ),
    );
  }
}
