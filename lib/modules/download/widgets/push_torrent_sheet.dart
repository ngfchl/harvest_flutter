import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/site/model/site_info.dart';
import 'package:harvest/modules/site/provider/site_provider.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../search/model/search_torrent_info.dart';
import '../model/downloader.dart';
import '../model/downloader_category.dart';
import '../service/downloader_service.dart';

// ═══════════════════════════════════════════════════════════════
// 推送种子 Bottom Sheet
// ═══════════════════════════════════════════════════════════════

class PushTorrentSheet extends ConsumerStatefulWidget {
  final SearchTorrentInfo? torrent;
  final Downloader downloader;
  final String? initialUrl;
  final String? initialCookie;
  final String? initialSiteId;
  final VoidCallback? onSuccess;

  const PushTorrentSheet({
    super.key,
    this.torrent,
    required this.downloader,
    this.initialUrl,
    this.initialCookie,
    this.initialSiteId,
    this.onSuccess,
  });

  @override
  ConsumerState<PushTorrentSheet> createState() => _PushTorrentSheetState();
}

class _PushTorrentSheetState extends ConsumerState<PushTorrentSheet> {
  // ── Controllers ──
  final _savePathCtrl = TextEditingController();
  final _manualUrlCtrl = TextEditingController();
  final _renameCtrl = TextEditingController();
  final _siteIdCtrl = TextEditingController();
  final _cookieCtrl = TextEditingController();
  final _uploadLimitCtrl = TextEditingController();
  final _downloadLimitCtrl = TextEditingController();
  final _ratioLimitCtrl = TextEditingController();
  final _seedingTimeLimitCtrl = TextEditingController();
  final _customTagCtrl = TextEditingController();

  // ── Form state ──
  String? _selectedCategory;
  final Set<String> _selectedTags = {};
  String _contentLayout = 'Original';
  String _defaultSavePath = '/downloads';
  String? _stopCondition;
  String? _shareLimitAction;

  // toggles
  bool _skipChecking = false;
  bool _isPaused = false;
  bool _autoManagement = false;
  bool _createSubfolder = false;
  bool _firstLastPiecePriority = false;
  bool _sequentialDownload = false;
  bool _addToTopOfQueue = false;
  bool _forced = false;
  bool _genTorrentUrl = false;

  // 高级选项展开
  bool _advancedExpanded = false;

  bool _submitting = false;
  bool _loadingData = true;

  // ── Fetched data ──
  List<String> _tags = [];
  List<DownloaderCategory> _categories = [];

  bool get _isQb => widget.downloader.isQb;

  bool get _hasTorrent => widget.torrent != null;

  SiteInfo? _siteFor(String siteId) {
    final sites = ref.read(siteInfoListProvider).valueOrNull ?? [];
    for (final site in sites) {
      if (site.id.toString() == siteId || site.site == siteId) return site;
    }
    return null;
  }

  String _resolvedSiteId(SearchTorrentInfo torrent) {
    final site = _siteFor(torrent.siteId);
    return (site?.site ?? torrent.siteId).trim();
  }

  String _defaultSiteId() {
    if (_hasTorrent) {
      return _resolvedSiteId(widget.torrent!);
    }
    return widget.initialSiteId?.trim() ?? '';
  }

  void _setGenTorrentUrl(bool value) {
    setState(() {
      _genTorrentUrl = value;
      _siteIdCtrl.text = value ? _defaultSiteId() : '';
    });
  }

  @override
  void initState() {
    super.initState();
    if (_hasTorrent) {
      final t = widget.torrent!;
      final site = _siteFor(t.siteId);
      _selectedTags.addAll(t.tags);
      _genTorrentUrl = !t.magnetUrl.contains('passkey') && !t.magnetUrl.contains('sign');
      _siteIdCtrl.text = _genTorrentUrl ? _resolvedSiteId(t) : '';
      _cookieCtrl.text = (site?.cookie ?? t.cookie ?? '').trim();
    } else {
      _manualUrlCtrl.text = widget.initialUrl?.trim() ?? '';
      _siteIdCtrl.text = widget.initialSiteId?.trim() ?? '';
      _cookieCtrl.text = widget.initialCookie?.trim() ?? '';
      _genTorrentUrl = false;
    }
    _fetchData();
  }

  @override
  void dispose() {
    _savePathCtrl.dispose();
    _manualUrlCtrl.dispose();
    _renameCtrl.dispose();
    _siteIdCtrl.dispose();
    _cookieCtrl.dispose();
    _uploadLimitCtrl.dispose();
    _downloadLimitCtrl.dispose();
    _ratioLimitCtrl.dispose();
    _seedingTimeLimitCtrl.dispose();
    _customTagCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    List<String> tags = [];
    List<DownloaderCategory> categories = [];
    String defaultSavePath = '/downloads';

    try {
      final prefs = await DownloaderService.fetchPrefs(widget.downloader.id);
      if (prefs != null) {
        final sp = prefs['save_path']?.toString();
        if (sp != null && sp.isNotEmpty) {
          defaultSavePath = sp;
        }
      }
    } catch (_) {}

    try {
      tags = await DownloaderService.fetchTags(widget.downloader.id);
    } catch (_) {}

    try {
      categories = await DownloaderService.fetchCategories(widget.downloader.id);
    } catch (_) {}

    // 去重
    final uniqueTags = tags.toSet().toList();

    if (mounted) {
      setState(() {
        _tags = uniqueTags;
        _categories = categories;
        _defaultSavePath = defaultSavePath;
        _savePathCtrl.text = defaultSavePath;
        _loadingData = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.68),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: 12),
      child: _loadingData
          ? Center(child: shadcn.CircularProgressIndicator(strokeWidth: 2))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 链接 ──
                        _buildLinkSection(),
                        const SizedBox(height: 20),

                        // ── 路径（分类选择 + 输入框）──
                        _buildPathSection(),
                        const SizedBox(height: 20),

                        // ── 标签 ──
                        _buildTagsSection(),
                        const SizedBox(height: 20),

                        // ── 暂停下载 ──
                        _buildPauseToggle(),
                        const SizedBox(height: 16),

                        // ── 高级选项 ──
                        _buildAdvancedOptions(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // ── 按钮 ──
                _buildButtons(),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Header
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Text('添加种子', style: typo.large.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isQb ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _isQb ? 'qBittorrent' : 'Transmission',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _isQb ? Colors.blue : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 0.5, color: cs.border.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 链接
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLinkSection() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('链接', style: typo.small.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_hasTorrent) ...[
          // 种子信息预览
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.mutedForeground.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.border.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(shadcn.LucideIcons.file, size: 16, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.torrent!.title,
                        style: typo.small.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.torrent!.siteId}  ·  ${formatBytes(widget.torrent!.size)}',
                        style: typo.xSmall.copyWith(color: cs.mutedForeground, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          shadcn.TextField(
            controller: _manualUrlCtrl,
            hintText: '输入 magnet 或种子链接（支持多条，换行/空格/逗号分隔）',
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('自动生成下载链接', style: typo.small),
                    Text(
                      '通过站点重新生成种子下载链接',
                      style: typo.xSmall.copyWith(
                        color: cs.mutedForeground.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: _genTorrentUrl, onChanged: _setGenTorrentUrl),
            ],
          ),
          if (_genTorrentUrl) ...[
            const SizedBox(height: 8),
            _buildInlineField('站点', _siteIdCtrl, hint: '站点标识'),
          ],
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 路径（分类 + 输入框）
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPathSection() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('路径', style: typo.small.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        // 分类列表
        if (_categories.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: _categories.map((cat) {
              final selected = _selectedCategory == cat.name;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedCategory = null;
                      _savePathCtrl.text = _defaultSavePath;
                    } else {
                      _selectedCategory = cat.name;
                      _savePathCtrl.text = cat.savePath;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : cs.mutedForeground.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: selected ? cs.primary : cs.border.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    cat.name,
                    style: typo.xSmall.copyWith(
                      color: selected ? Colors.white : cs.foreground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],

        // 保存路径
        shadcn.TextField(controller: _savePathCtrl, hintText: _defaultSavePath),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 标签
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTagsSection() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('标签', style: typo.small.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(
              onTap: _showTagSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.border.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shadcn.LucideIcons.plus, size: 13, color: cs.mutedForeground),
                    const SizedBox(width: 4),
                    Text('选择', style: typo.xSmall.copyWith(color: cs.mutedForeground)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedTags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedTags.map((tag) {
              return GestureDetector(
                onTap: () => setState(() => _selectedTags.remove(tag)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: typo.xSmall.copyWith(color: cs.primary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      Icon(shadcn.LucideIcons.x, size: 11, color: cs.primary.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        else
          GestureDetector(
            onTap: _showTagSheet,
            child: Text('点击选择标签', style: typo.xSmall.copyWith(color: cs.mutedForeground.withValues(alpha: 0.4))),
          ),
      ],
    );
  }

  void _showTagSheet() {
    final tempSelected = Set<String>.from(_selectedTags);
    final customCtrl = TextEditingController();
    final allTags = List<String>.from(_tags);

    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final cs = shadcn.Theme.of(ctx).colorScheme;
            final typo = shadcn.Theme.of(ctx).typography;

            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.55),
              decoration: BoxDecoration(
                color: cs.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: cs.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text('选择标签', style: typo.normal.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('${tempSelected.length} 项', style: typo.xSmall.copyWith(color: cs.mutedForeground)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(
                            () => _selectedTags
                              ..clear()
                              ..addAll(tempSelected),
                          );
                          closeAppSheet(ctx);
                        },
                        child: Text(
                          '确定',
                          style: typo.small.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  shadcn.TextField(
                    controller: customCtrl,
                    hintText: '自定义标签，多个用逗号分隔',
                    onSubmitted: (v) {
                      final tags = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
                      if (tags.isNotEmpty) {
                        setSheet(() {
                          for (final t in tags) {
                            if (!allTags.contains(t)) allTags.add(t);
                            tempSelected.add(t);
                          }
                        });
                        customCtrl.clear();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: allTags.isEmpty
                        ? Center(
                            child: Text('暂无标签', style: typo.small.copyWith(color: cs.mutedForeground)),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allTags.map((tag) {
                              final sel = tempSelected.contains(tag);
                              return GestureDetector(
                                onTap: () {
                                  setSheet(() {
                                    sel ? tempSelected.remove(tag) : tempSelected.add(tag);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? cs.primary.withValues(alpha: 0.1)
                                        : cs.mutedForeground.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: sel ? cs.primary.withValues(alpha: 0.3) : cs.border.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        tag,
                                        style: typo.xSmall.copyWith(
                                          color: sel ? cs.primary : cs.foreground,
                                          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                      if (sel) ...[
                                        const SizedBox(width: 4),
                                        Icon(shadcn.LucideIcons.check, size: 12, color: cs.primary),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => customCtrl.dispose());
  }

  // ═══════════════════════════════════════════════════════════════
  // 暂停下载
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPauseToggle() {
    final typo = shadcn.Theme.of(context).typography;

    return Row(
      children: [
        Expanded(child: Text('暂停下载', style: typo.small)),
        Switch(value: _isPaused, onChanged: (v) => setState(() => _isPaused = v)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 高级选项
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAdvancedOptions() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _advancedExpanded = !_advancedExpanded),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                '高级选项',
                style: typo.small.copyWith(fontWeight: FontWeight.w600, color: cs.mutedForeground),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _advancedExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(shadcn.LucideIcons.chevronDown, size: 16, color: cs.mutedForeground),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 基础
                _buildOptionGroup('基础', [
                  _optionTile('跳过哈希检查', _skipChecking, (v) => setState(() => _skipChecking = v)),
                  if (_isQb) _optionTile('强制下载', _forced, (v) => setState(() => _forced = v)),
                ]),

                const SizedBox(height: 12),

                if (_hasTorrent) ...[
                  _buildOptionGroup('下载链接', [
                    _optionTile('自动生成下载链接', _genTorrentUrl, _setGenTorrentUrl),
                    if (_genTorrentUrl) ...[
                      _buildInlineField('站点', _siteIdCtrl, hint: '站点标识'),
                      const SizedBox(height: 8),
                    ],
                    _buildInlineField('Cookie', _cookieCtrl, hint: '站点 Cookie'),
                  ]),
                  const SizedBox(height: 12),
                ] else ...[
                  _buildOptionGroup('下载链接', [
                    _buildInlineField('Cookie', _cookieCtrl, hint: '站点 Cookie'),
                  ]),
                  const SizedBox(height: 12),
                ],

                // 重命名
                _buildOptionGroup('重命名', [_buildInlineField('任务名称', _renameCtrl, hint: '留空使用原始名称')]),

                const SizedBox(height: 12),

                // 限速
                _buildOptionGroup('速度限制', [
                  _buildInlineField('上传限制 (KB/s)', _uploadLimitCtrl, hint: '不限'),
                  const SizedBox(height: 8),
                  _buildInlineField('下载限制 (KB/s)', _downloadLimitCtrl, hint: '不限'),
                  const SizedBox(height: 8),
                  _buildInlineField('分享比率', _ratioLimitCtrl, hint: '默认'),
                  if (_isQb) ...[
                    const SizedBox(height: 8),
                    _buildInlineField('做种时间 (分钟)', _seedingTimeLimitCtrl, hint: '不限'),
                  ],
                ]),

                // QB 专属
                if (_isQb) ...[
                  const SizedBox(height: 12),
                  _buildOptionGroup('qBittorrent', [
                    _optionTile('自动管理', _autoManagement, (v) => setState(() => _autoManagement = v)),
                    _optionTile('创建子文件夹', _createSubfolder, (v) => setState(() => _createSubfolder = v)),
                    _optionTile('顺序下载', _sequentialDownload, (v) => setState(() => _sequentialDownload = v)),
                    _optionTile('优先首尾文件', _firstLastPiecePriority, (v) => setState(() => _firstLastPiecePriority = v)),
                    _optionTile('添加到队列顶部', _addToTopOfQueue, (v) => setState(() => _addToTopOfQueue = v)),
                    const SizedBox(height: 8),
                    _buildContentLayoutPicker(),
                    const SizedBox(height: 8),
                    _buildStopConditionPicker(),
                    _buildShareLimitPicker(),
                  ]),
                ],
              ],
            ),
          ),
          crossFadeState: _advancedExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  // ── 选项分组 ──

  Widget _buildOptionGroup(String title, List<Widget> children) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: cs.border.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Text(
              title,
              style: typo.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _optionTile(String label, bool value, ValueChanged<bool> onChanged) {
    final typo = shadcn.Theme.of(context).typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: typo.small)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildInlineField(String label, TextEditingController ctrl, {String? hint}) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(label, style: typo.xSmall.copyWith(color: cs.mutedForeground)),
          const SizedBox(width: 8),
          Expanded(
            child: shadcn.TextField(controller: ctrl, hintText: hint ?? ''),
          ),
        ],
      ),
    );
  }

  // ── 内容布局 ──

  Widget _buildContentLayoutPicker() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    const options = [('Original', '原始'), ('Subfolder', '子文件夹'), ('NoSubfolder', '无子文件夹')];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('内容布局', style: typo.xSmall.copyWith(color: cs.mutedForeground)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: options.map((opt) {
              final selected = _contentLayout == opt.$1;
              return GestureDetector(
                onTap: () => setState(() => _contentLayout = opt.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: selected ? cs.primary : cs.border.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    opt.$2,
                    style: typo.xSmall.copyWith(
                      color: selected ? Colors.white : cs.mutedForeground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── 停止条件 ──

  Widget _buildStopConditionPicker() {
    String label;
    switch (_stopCondition) {
      case 'MetadataReceived':
        label = '收到元数据后';
        break;
      case 'FilesChecked':
        label = '文件校验后';
        break;
      default:
        label = '不自动停止';
    }

    return _buildPickerRow(
      label: '停止条件',
      value: label,
      onTap: _showStopConditionSheet,
      onClear: _stopCondition != null ? () => setState(() => _stopCondition = null) : null,
    );
  }

  // ── 分享限制 ──

  Widget _buildShareLimitPicker() {
    String label;
    switch (_shareLimitAction) {
      case 'Stop':
        label = '停止';
        break;
      case 'Remove':
        label = '移除';
        break;
      case 'RemoveWithContent':
        label = '移除并删除';
        break;
      case 'EnableSuperSeeding':
        label = '超级做种';
        break;
      default:
        label = '使用默认';
    }

    return _buildPickerRow(
      label: '分享限制',
      value: label,
      onTap: _showShareLimitSheet,
      onClear: _shareLimitAction != null ? () => setState(() => _shareLimitAction = null) : null,
    );
  }

  Widget _buildPickerRow({
    required String label,
    required String value,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Text(label, style: typo.xSmall.copyWith(color: cs.mutedForeground)),
            const Spacer(),
            Text(value, style: typo.xSmall.copyWith(color: cs.foreground, fontSize: 12)),
            if (onClear != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: Icon(shadcn.LucideIcons.x, size: 13, color: cs.mutedForeground.withValues(alpha: 0.4)),
              ),
            ],
            const SizedBox(width: 4),
            Icon(shadcn.LucideIcons.chevronRight, size: 14, color: cs.mutedForeground.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 按钮
  // ═══════════════════════════════════════════════════════════════

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: shadcn.Button.outline(
              onPressed: () => closeAppSheet(context),
              child: Center(child: const Text('取消')),
            ),
          ),
          Expanded(
            child: shadcn.Button.primary(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(child: shadcn.CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : Center(child: const Text('下载')),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Sheets
  // ═══════════════════════════════════════════════════════════════

  void _showStopConditionSheet() {
    const options = [(null, '不自动停止'), ('MetadataReceived', '收到元数据后停止'), ('FilesChecked', '文件校验后停止')];

    _showPickerSheet(
      title: '停止条件',
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (_, i) {
          final opt = options[i];
          return _buildPickerTile(
            title: opt.$2,
            selected: _stopCondition == opt.$1,
            onTap: () {
              setState(() => _stopCondition = opt.$1);
              closeAppSheet(context);
            },
          );
        },
      ),
    );
  }

  void _showShareLimitSheet() {
    const actions = [
      (null, '使用默认'),
      ('Stop', '停止做种'),
      ('Remove', '移除任务'),
      ('RemoveWithContent', '移除并删除内容'),
      ('EnableSuperSeeding', '启用超级做种'),
    ];

    _showPickerSheet(
      title: '分享限制',
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: actions.length,
        itemBuilder: (_, i) {
          final a = actions[i];
          return _buildPickerTile(
            title: a.$2,
            selected: _shareLimitAction == a.$1,
            onTap: () {
              setState(() => _shareLimitAction = a.$1);
              closeAppSheet(context);
            },
          );
        },
      ),
    );
  }

  void _showPickerSheet({required String title, required Widget child}) {
    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = shadcn.Theme.of(ctx).colorScheme;

        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.5),
          decoration: BoxDecoration(
            color: cs.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: cs.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: shadcn.Theme.of(ctx).typography.normal.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(child: child),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerTile({
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: typo.small.copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                  if (subtitle != null)
                    Text(subtitle, style: typo.xSmall.copyWith(color: cs.mutedForeground, fontSize: 11)),
                ],
              ),
            ),
            if (selected) Icon(shadcn.LucideIcons.check, size: 16, color: cs.primary),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Submit
  // ═══════════════════════════════════════════════════════════════

  List<String> _parseUrlInputs(String raw) {
    return raw
        .split(RegExp(r'[\s,;，；]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  String _extractTorrentIdFromInput(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '';
    if (RegExp(r'^\d+$').hasMatch(raw)) return raw;

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      const queryKeys = <String>['tid', 'id', 'torrentid', 'topicid'];
      for (final key in queryKeys) {
        final v = uri.queryParameters[key]?.trim() ?? '';
        if (v.isNotEmpty) return v;
      }
      for (final segment in uri.pathSegments.reversed) {
        final text = segment.trim();
        if (text.isNotEmpty && RegExp(r'^\d+$').hasMatch(text)) {
          return text;
        }
      }
    }

    final match = RegExp(
      r'([?&](?:tid|id|torrentid|topicid)=)([^&#]+)',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match != null) {
      return (match.group(2) ?? '').trim();
    }
    return '';
  }

  Future<void> _submit() async {
    final manualUrls = _hasTorrent
        ? const <String>[]
        : _parseUrlInputs(_manualUrlCtrl.text);
    if (!_hasTorrent && manualUrls.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入种子链接'), behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => _submitting = true);

    try {
      final params = <String, dynamic>{};

      // 种子来源
      // 种子来源
      if (_hasTorrent) {
        final t = widget.torrent!;
        params['urls'] = t.magnetUrl;
        params['tid'] = t.tid;
        if (_genTorrentUrl) {
          final siteId = _siteIdCtrl.text.trim();
          if (siteId.isNotEmpty) {
            params['site_id'] = siteId;
          }
        }
        final cookie = _cookieCtrl.text.trim();
        if (cookie != null && cookie.isNotEmpty) {
          params['cookie'] = cookie;
        }
      } else {
        params['urls'] = manualUrls.length == 1 ? manualUrls.first : manualUrls;
        final siteId = _siteIdCtrl.text.trim();
        if (_genTorrentUrl && siteId.isNotEmpty) {
          params['site_id'] = siteId;
        }
        final cookie = _cookieCtrl.text.trim();
        if (cookie.isNotEmpty) {
          params['cookie'] = cookie;
        }
      }

      // 保存路径
      if (_savePathCtrl.text.trim().isNotEmpty) {
        params['save_path'] = _savePathCtrl.text.trim();
      }

      // 分类（QB + TR 都传，TR 后端用 save_path 或 category 做 download_dir）
      if (_selectedCategory != null) {
        params['category'] = _selectedCategory;
      }

      // 标签
      if (_selectedTags.isNotEmpty) {
        params['tags'] = _selectedTags.toList();
      }

      // 暂停
      params['is_paused'] = _isPaused;

      // 高级选项
      params['is_skip_checking'] = _skipChecking;

      if (_renameCtrl.text.trim().isNotEmpty) {
        params['rename'] = _renameCtrl.text.trim();
      }

      if (_uploadLimitCtrl.text.trim().isNotEmpty) {
        final v = int.tryParse(_uploadLimitCtrl.text.trim());
        if (v != null && v > 0) params['upload_limit'] = v;
      }
      if (_downloadLimitCtrl.text.trim().isNotEmpty) {
        final v = int.tryParse(_downloadLimitCtrl.text.trim());
        if (v != null && v > 0) params['download_limit'] = v;
      }
      if (_ratioLimitCtrl.text.trim().isNotEmpty) {
        final v = double.tryParse(_ratioLimitCtrl.text.trim());
        if (v != null) params['ratio_limit'] = v;
      }
      if (_seedingTimeLimitCtrl.text.trim().isNotEmpty) {
        final v = int.tryParse(_seedingTimeLimitCtrl.text.trim());
        if (v != null) params['seeding_time_limit'] = v;
      }

      // QB 专属
      if (_isQb) {
        params['use_auto_torrent_management'] = _autoManagement;
        params['is_root_folder'] = _createSubfolder;
        params['is_sequential_download'] = _sequentialDownload;
        params['is_first_last_piece_priority'] = _firstLastPiecePriority;
        params['add_to_top_of_queue'] = _addToTopOfQueue;
        params['content_layout'] = _contentLayout;
        params['forced'] = _forced;
        if (_stopCondition != null) params['stop_condition'] = _stopCondition;
        if (_shareLimitAction != null) {
          params['share_limit_action'] = _shareLimitAction;
        }
      }

      final isBatchManualPush = !_hasTorrent && manualUrls.length > 1;
      if (isBatchManualPush) {
        final siteRaw = _siteIdCtrl.text.trim();
        final site = siteRaw.isEmpty ? null : _siteFor(siteRaw);
        final mySiteId = site?.id ?? int.tryParse(siteRaw);
        if (mySiteId == null || mySiteId <= 0) {
          throw Exception('批量推送需要可识别的站点 ID（my_site_id）');
        }

        final monkeyParams = Map<String, dynamic>.from(params);
        final torrentIds = manualUrls
            .map(_extractTorrentIdFromInput)
            .where((id) => id.isNotEmpty)
            .toList();
        if (torrentIds.isEmpty) {
          throw Exception('批量推送未解析到种子 ID，请输入 tid/id 或详情链接');
        }
        monkeyParams['urls'] = torrentIds.length == 1
            ? torrentIds.first
            : torrentIds;
        monkeyParams['tags'] = jsonEncode(_selectedTags.toList());
        await DownloaderService.pushTorrentFromMonkey(
          widget.downloader.id,
          mySiteId,
          monkeyParams,
        );
      } else {
        await DownloaderService.pushTorrent(widget.downloader.id, params);
      }

      if (mounted) {
        closeAppSheet(context);
        widget.onSuccess?.call();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已推送到 ${widget.downloader.name}'), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('推送失败: $e'),
            backgroundColor: shadcn.Theme.of(context).colorScheme.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 工具
  // ═══════════════════════════════════════════════════════════════
}
