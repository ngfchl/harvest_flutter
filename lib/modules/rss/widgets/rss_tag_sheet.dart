import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../model/rss_models.dart';
import '../provider/rss_provider.dart';
import 'rss_common.dart';
import 'package:harvest/core/utils/utils.dart';

void showRssTagSheet(BuildContext context, {RssTag? tag}) {
  showRssSheet(
    context: context,
    title: tag == null ? '添加订阅标签' : '编辑订阅标签',
    desktopMaxWidth: 420,
    desktopMaxHeight: 420,
    builder: (_) => RssTagSheet(tag: tag),
  );
}

class RssTagSheet extends ConsumerStatefulWidget {
  final RssTag? tag;

  const RssTagSheet({super.key, this.tag});

  @override
  ConsumerState<RssTagSheet> createState() => _RssTagSheetState();
}

class _RssTagSheetState extends ConsumerState<RssTagSheet> {
  late final TextEditingController _nameCtrl;
  String _category = '';
  bool _enabled = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.tag?.name ?? '');
    _category = widget.tag?.category ?? '';
    _enabled = widget.tag?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_nameCtrl.text.trim().isEmpty) {
      Toast.error('请填写标签名称');
      return;
    }
    setState(() => _saving = true);
    try {
      final tag = RssTag(
        id: widget.tag?.id ?? 0,
        name: _nameCtrl.text.trim(),
        category: _category.trim(),
        enabled: _enabled,
      );
      await ref.read(rssTagsProvider.notifier).save(tag);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              widget.tag == null ? '添加订阅标签' : '编辑订阅标签',
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
                    labelText: '标签名称',
                    hintText: '例如：1080p',
                    helperText: '标签按「名称 + 分类」唯一',
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel('分类'),
                  Select<String>(
                    value: _category.isEmpty ? null : _category,
                    placeholder: const Text('请选择分类'),
                    itemBuilder: (_, _) => Text(rssTagCategoryLabel(_category)),
                    popupConstraints: const BoxConstraints(maxHeight: 320),
                    popup: SelectPopup<String>(
                      items: SelectItemList(
                        children: [
                          for (final key in kRssTagCategoryKeys)
                            SelectItemButton<String>(
                              value: key,
                              child: Text(
                                '${rssTagCategoryLabel(key)}  ·  $key',
                              ),
                            ),
                        ],
                      ),
                    ).call,
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  RssSheetGroup(
                    children: [
                      RssSheetTile(
                        title: const Text('启用'),
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
