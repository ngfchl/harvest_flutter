import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../model/rss_models.dart';
import '../provider/rss_provider.dart';
import 'rss_common.dart';
import 'package:harvest/core/utils/utils.dart';

void showRssSubscriptionSheet(BuildContext context, {RssSubscription? subscription}) {
  showRssSheet(
    context: context,
    title: subscription == null ? '添加 RSS 订阅' : '编辑 RSS 订阅',
    isScrollControlled: true,
    builder: (_) => RssSubscriptionSheet(subscription: subscription),
  );
}

String _join(List<String> list) => list.join(', ');

List<String> _split(String text) => text
    .split(RegExp(r'[,，]'))
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();

class RssSubscriptionSheet extends ConsumerStatefulWidget {
  final RssSubscription? subscription;

  const RssSubscriptionSheet({super.key, this.subscription});

  @override
  ConsumerState<RssSubscriptionSheet> createState() => _RssSubscriptionSheetState();
}

class _RssSubscriptionSheetState extends ConsumerState<RssSubscriptionSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _keywordCtrl;
  late final TextEditingController _excludesCtrl;
  late final TextEditingController _seasonCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _doubanCtrl;
  late final TextEditingController _imdbCtrl;
  late final TextEditingController _tmdbCtrl;

  bool _enabled = true;
  int _planId = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.subscription;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _keywordCtrl = TextEditingController(text: s?.keyword ?? '');
    _excludesCtrl = TextEditingController(text: _join(s?.excludes ?? []));
    _seasonCtrl = TextEditingController(text: s?.season ?? '');
    _yearCtrl = TextEditingController(text: _join(s?.publishYear ?? []));
    _doubanCtrl = TextEditingController(text: s?.doubanId ?? '');
    _imdbCtrl = TextEditingController(text: s?.imdbId ?? '');
    _tmdbCtrl = TextEditingController(text: s?.tmdbId ?? '');
    _enabled = s?.enabled ?? true;
    _planId = s?.planId ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keywordCtrl.dispose();
    _excludesCtrl.dispose();
    _seasonCtrl.dispose();
    _yearCtrl.dispose();
    _doubanCtrl.dispose();
    _imdbCtrl.dispose();
    _tmdbCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_nameCtrl.text.trim().isEmpty) {
      Toast.error('请填写订阅名称');
      return;
    }
    if (_planId == 0) {
      Toast.error('请选择订阅方案');
      return;
    }
    setState(() => _saving = true);
    try {
      final sub = RssSubscription(
        id: widget.subscription?.id ?? 0,
        name: _nameCtrl.text.trim(),
        enabled: _enabled,
        keyword: _keywordCtrl.text.trim(),
        excludes: _split(_excludesCtrl.text),
        season: _seasonCtrl.text.trim(),
        publishYear: _split(_yearCtrl.text),
        doubanId: _doubanCtrl.text.trim(),
        imdbId: _imdbCtrl.text.trim(),
        tmdbId: _tmdbCtrl.text.trim(),
        planId: _planId,
      );
      await ref.read(rssSubscriptionsProvider.notifier).save(sub);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _planLabel(List<RssPlan> plans) {
    if (_planId == 0) return '未选择';
    for (final p in plans) {
      if (p.id == _planId) return p.name;
    }
    return '方案 #$_planId';
  }

  Widget _fieldLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.foreground),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final plansAsync = ref.watch(rssPlansProvider);
    final plans = plansAsync.value ?? const [];

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              widget.subscription == null ? '添加 RSS 订阅' : '编辑 RSS 订阅',
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
                    labelText: '订阅名称',
                    hintText: '例如：某部电视剧',
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel('订阅方案'),
                  Select<int>(
                    value: _planId == 0 ? null : _planId,
                    placeholder: Text(_planLabel(plans)),
                    itemBuilder: (_, _) => Text(_planLabel(plans)),
                    popupConstraints: const BoxConstraints(maxHeight: 300),
                    popup: SelectPopup<int>(
                      items: SelectItemList(
                        children: [
                          for (final plan in plans)
                            SelectItemButton<int>(value: plan.id, child: Text(plan.name)),
                        ],
                      ),
                    ).call,
                    onChanged: (v) {
                      if (v != null) setState(() => _planId = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  ShadTextField(
                    controller: _keywordCtrl,
                    labelText: '订阅关键字',
                    hintText: '标题必须包含的关键字',
                    helperText: '留空表示匹配该源全部条目',
                  ),
                  const SizedBox(height: 12),
                  ShadTextField(
                    controller: _excludesCtrl,
                    labelText: '排除关键字',
                    hintText: '多个用逗号分隔，如：预告, 花絮',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ShadTextField(
                          controller: _seasonCtrl,
                          labelText: '季数',
                          hintText: 'S01',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadTextField(
                          controller: _yearCtrl,
                          labelText: '发布年份',
                          hintText: '2024, 2025',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ShadTextField(
                    controller: _doubanCtrl,
                    labelText: '豆瓣 ID',
                    hintText: '可选，检查 RSS 描述中的豆瓣链接',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ShadTextField(
                          controller: _imdbCtrl,
                          labelText: 'IMDb ID',
                          hintText: 'tt1234567',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadTextField(
                          controller: _tmdbCtrl,
                          labelText: 'TMDB ID',
                          hintText: '12345',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RssSheetGroup(
                    children: [
                      RssSheetTile(
                        title: const Text('启用订阅'),
                        trailing: Switch(
                          value: _enabled,
                          onChanged: (v) => setState(() => _enabled = v),
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
