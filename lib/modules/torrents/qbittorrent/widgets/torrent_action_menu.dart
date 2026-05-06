import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/torrent_model.dart';

typedef OnTorrentAction =
    Future<bool> Function(String action, Map<String, dynamic> params);

enum DownloaderType { qbittorrent, transmission }

// ══════════════════════════════════════════════════════════
//  入口
// ══════════════════════════════════════════════════════════

class TorrentActionMenu {
  static void show(
    BuildContext context, {
    required Torrent torrent,
    required DownloaderType type,
    required List<String> categories,
    required List<String> tags,
    required OnTorrentAction onAction,
    required VoidCallback onShowDetail,
  }) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.82,
      builder: (ctx) => _MenuBody(
        torrent: torrent,
        type: type,
        categories: categories,
        tags: tags,
        onAction: onAction,
        onShowDetail: onShowDetail,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  菜单主体
// ══════════════════════════════════════════════════════════

class _MenuBody extends StatelessWidget {
  final Torrent torrent;
  final DownloaderType type;
  final List<String> categories;
  final List<String> tags;
  final OnTorrentAction onAction;
  final VoidCallback onShowDetail;

  const _MenuBody({
    required this.torrent,
    required this.type,
    required this.categories,
    required this.tags,
    required this.onAction,
    required this.onShowDetail,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;

    return SafeArea(
      child: ColoredBox(
        color: cs.background,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dragHandle(cs),
                if (type == DownloaderType.qbittorrent)
                  ..._buildQBMenu(context)
                else
                  ..._buildTRMenu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dragHandle(FColors cs) => Container(
    width: 36,
    height: 4,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: cs.foreground.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  // ────────────────── QB 菜单 ──────────────────

  List<Widget> _buildQBMenu(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final isPaused = torrent.torrentStatus == TorrentStatus.stopped;
    final hash = torrent.hashString;

    return [
      _section(context, [
        _tile(
          context,
          icon: Icons.info_outline_rounded,
          label: '种子详情',
          onTap: () {
            Navigator.pop(context);
            onShowDetail();
          },
        ),
      ]),

      // ── 播放控制 ──
      _section(context, [
        _tile(
          context,
          icon: isPaused ? Icons.play_arrow_rounded : Icons.stop_rounded,
          label: isPaused ? '继续' : '停止',
          onTap: () => _exec(context, isPaused ? 'resume' : 'pause', {
            'hashes': [hash],
          }),
        ),
        _tile(
          context,
          icon: Icons.double_arrow_rounded,
          label: '强制启动',
          color: torrent.forceStart ? cs.primary : null,
          onTap: () => _exec(context, 'set_force_start', {
            'hashes': [hash],
            'enable': !torrent.forceStart,
          }),
        ),
      ]),

      // ── 删除 ──
      _section(context, [
        _tile(
          context,
          icon: Icons.delete_outline_rounded,
          label: '删除',
          destructive: true,
          onTap: () {
            _showDeleteDialog(context, hash);
          },
        ),
      ]),

      // ── 位置/分类/标签 ──
      _section(context, [
        _tile(
          context,
          icon: Icons.edit_location_outlined,
          label: '更改保存位置',
          onTap: () {
            _showLocationDialog(context, hash, torrent.downloadDir);
          },
        ),
        if (categories.isNotEmpty)
          _tile(
            context,
            icon: Icons.category_outlined,
            label: '分类',
            trailing: _chevron(cs),
            onTap: () {
              _showCategoryMenu(context, hash);
            },
          ),
        if (tags.isNotEmpty)
          _tile(
            context,
            icon: Icons.label_outline_rounded,
            label: '标签',
            trailing: _chevron(cs),
            onTap: () {
              _showTagMenu(context, hash);
            },
          ),
      ]),

      // ── 复制 ──
      _section(context, [
        _tile(
          context,
          icon: Icons.copy_rounded,
          label: '复制',
          trailing: _chevron(cs),
          onTap: () {
            _showCopyMenu(context);
          },
        ),
      ]),

      // ── 高级设置 ──
      _section(context, [
        _tile(
          context,
          icon: Icons.auto_mode_outlined,
          label: '自动管理',
          color: torrent.autoTmm ? cs.primary : null,
          onTap: () => _exec(context, 'set_auto_management', {
            'hashes': [hash],
            'enable': !torrent.autoTmm,
          }),
        ),
        _tile(
          context,
          icon: Icons.upload_outlined,
          label: '限制上传速度',
          onTap: () {
            _showUploadLimitDialog(context, hash, torrent.uploadLimit);
          },
        ),
        _tile(
          context,
          icon: Icons.pie_chart_outline_rounded,
          label: '限制分享率',
          onTap: () {
            _showShareRatioDialog(context, hash);
          },
        ),
        _tile(
          context,
          icon: Icons.rocket_launch_outlined,
          label: '超级做种',
          color: torrent.superSeeding ? cs.primary : null,
          onTap: () => _exec(context, 'set_super_seeding', {
            'hashes': [hash],
            'enable': !torrent.superSeeding,
          }),
        ),
      ]),

      // ── 维护 ──
      _section(context, [
        _tile(
          context,
          icon: Icons.fact_check_outlined,
          label: '重新校验',
          onTap: () {
            _showConfirmDialog(context, '重新校验', '确定要重新校验种子吗？', () {
              _exec(context, 'recheck', {
                'hashes': [hash],
              });
            });
          },
        ),
        _tile(
          context,
          icon: Icons.campaign_outlined,
          label: '重新汇报',
          onTap: () => _exec(context, 'reannounce', {
            'hashes': [hash],
          }),
        ),
        _tile(
          context,
          icon: Icons.language_outlined,
          label: '修改 Tracker',
          onTap: () {
            _showTrackerDialog(context, hash);
          },
        ),
        _tile(
          context,
          icon: Icons.save_alt_outlined,
          label: '导出 .torrent',
          onTap: () => _exec(context, 'export', {
            'hashes': [hash],
            'name': torrent.name,
          }),
        ),
      ]),
    ];
  }

  // ────────────────── TR 菜单 ──────────────────

  List<Widget> _buildTRMenu(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final hash = torrent.hashString;

    return [
      _section(context, [
        _tile(
          context,
          icon: Icons.info_outline_rounded,
          label: '种子详情',
          onTap: () {
            Navigator.pop(context);
            onShowDetail();
          },
        ),
      ]),

      _section(context, [
        _tile(
          context,
          icon: Icons.double_arrow_rounded,
          label: '强制开始',
          onTap: () => _exec(context, 'start_torrent_now', {
            'ids': [hash],
          }),
        ),
        _tile(
          context,
          icon: Icons.play_arrow_rounded,
          label: '开始种子',
          onTap: () => _exec(context, 'start_torrent', {
            'ids': [hash],
          }),
        ),
        _tile(
          context,
          icon: Icons.pause_rounded,
          label: '暂停种子',
          onTap: () => _exec(context, 'stop_torrent', {
            'ids': [hash],
          }),
        ),
      ]),
      _section(context, [
        _tile(
          context,
          icon: Icons.delete_outline_rounded,
          label: '删除种子',
          destructive: true,
          onTap: () {
            _showDeleteDialog(context, hash);
          },
        ),
      ]),
      _section(context, [
        _tile(
          context,
          icon: Icons.fact_check_outlined,
          label: '重新校验',
          onTap: () {
            _showConfirmDialog(context, '重新校验', '确定要重新校验种子吗？', () {
              _exec(context, 'verify_torrent', {
                'ids': [hash],
              });
            });
          },
        ),
        _tile(
          context,
          icon: Icons.campaign_outlined,
          label: '重新汇报',
          onTap: () => _exec(context, 'reannounce_torrent', {
            'ids': [hash],
          }),
        ),
        _tile(
          context,
          icon: Icons.folder_outlined,
          label: '修改目录',
          onTap: () {
            _showLocationDialog(context, hash, torrent.downloadDir);
          },
        ),
      ]),
      _section(context, [
        _tile(
          context,
          icon: Icons.copy_rounded,
          label: '复制',
          trailing: _chevron(cs),
          onTap: () {
            _showCopyMenu(context);
          },
        ),
      ]),
      _section(context, [
        _tile(
          context,
          icon: Icons.reorder_rounded,
          label: '队列',
          trailing: _chevron(cs),
          onTap: () {
            _showQueueMenu(context, hash);
          },
        ),
        _tile(
          context,
          icon: Icons.label_outline_rounded,
          label: '标签',
          trailing: _chevron(cs),
          onTap: () {
            _showTagMenu(context, hash, isTR: true);
          },
        ),
        _tile(
          context,
          icon: Icons.language_outlined,
          label: '修改 Tracker',
          onTap: () {
            _showTrackerDialog(context, hash, isTR: true);
          },
        ),
      ]),
    ];
  }

  // ────────────────── 执行 ──────────────────

  Future<void> _exec(
    BuildContext context,
    String action,
    Map<String, dynamic> params,
  ) async {
    if (context.mounted) Navigator.pop(context);
    final success = await onAction(action, params);
    Toast.success(success ? '操作成功' : '操作失败');
  }

  // ══════════════════════════════════════════════════════════
  //  UI 工具
  // ══════════════════════════════════════════════════════════

  Widget _chevron(FColors cs) => Icon(
    Icons.chevron_right_rounded,
    size: 16,
    color: cs.foreground.withValues(alpha: 0.3),
  );

  Widget _section(BuildContext context, List<Widget> children) {
    final cs = FTheme.of(context).colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
    bool destructive = false,
  }) {
    final cs = FTheme.of(context).colors;
    final fg = destructive ? const Color(0xFFEF4444) : (color ?? cs.foreground);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: fg.withValues(alpha: 0.75)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: TextStyle(color: fg, fontSize: 13.5)),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  子菜单
  // ══════════════════════════════════════════════════════════

  void _showCopyMenu(BuildContext context) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.65,
      builder: (ctx) => _SubMenuBody(
        title: '复制',
        items: [
          _SubMenuItem(
            icon: Icons.text_fields_rounded,
            label: '名称',
            onTap: () => _copy(ctx, torrent.name, '种子名称'),
          ),
          _SubMenuItem(
            icon: Icons.tag_rounded,
            label: '哈希',
            onTap: () => _copy(ctx, torrent.hashString, '种子哈希'),
          ),
          _SubMenuItem(
            icon: FIcons.magnet,
            label: '磁力链接',
            onTap: () => _copy(ctx, torrent.magnetLink, '磁力链接'),
          ),
          _SubMenuItem(
            icon: Icons.link_rounded,
            label: 'Tracker 地址',
            onTap: () => _copy(ctx, torrent.trackerUrl, 'Tracker'),
          ),
          _SubMenuItem(
            icon: Icons.folder_outlined,
            label: '保存路径',
            onTap: () => _copy(ctx, torrent.downloadDir, '保存路径'),
          ),
        ],
      ),
    );
  }

  void _showCategoryMenu(BuildContext context, String hash) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.65,
      builder: (ctx) => _SubMenuBody(
        title: '分类',
        items: categories.map((cat) {
          final selected = cat == torrent.category;
          return _SubMenuItem(
            icon: selected
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            iconColor: selected ? FTheme.of(ctx).colors.primary : null,
            label: cat.isEmpty ? '未分类' : cat,
            onTap: () {
              Navigator.pop(ctx);
              onAction('set_category', {
                'hashes': [hash],
                'category': cat,
              });
            },
          );
        }).toList(),
      ),
    );
  }

  void _showTagMenu(BuildContext context, String hash, {bool isTR = false}) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.65,
      builder: (ctx) => _SubMenuBody(
        title: '标签',
        items: tags.map((tag) {
          final selected = torrent.labels.contains(tag);
          return _SubMenuItem(
            icon: selected
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            iconColor: selected ? FTheme.of(ctx).colors.primary : null,
            label: tag,
            onTap: () {
              Navigator.pop(ctx);
              final newTags = List<String>.from(torrent.labels);
              selected ? newTags.remove(tag) : newTags.add(tag);
              if (isTR) {
                onAction('change_torrent', {
                  'ids': [hash],
                  'labels': newTags,
                });
              } else {
                onAction('add_tags', {
                  'hashes': [hash],
                  'tags': newTags,
                });
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _showQueueMenu(BuildContext context, String hash) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.65,
      builder: (ctx) => _SubMenuBody(
        title: '队列',
        items: [
          _SubMenuItem(
            icon: Icons.vertical_align_top_rounded,
            label: '队列顶部',
            onTap: () => _exec(ctx, 'queue_top', {
              'ids': [hash],
            }),
          ),
          _SubMenuItem(
            icon: Icons.arrow_upward_rounded,
            label: '向上移动',
            onTap: () => _exec(ctx, 'queue_up', {
              'ids': [hash],
            }),
          ),
          _SubMenuItem(
            icon: Icons.arrow_downward_rounded,
            label: '向下移动',
            onTap: () => _exec(ctx, 'queue_down', {
              'ids': [hash],
            }),
          ),
          _SubMenuItem(
            icon: Icons.vertical_align_bottom_rounded,
            label: '队列底部',
            onTap: () => _exec(ctx, 'queue_bottom', {
              'ids': [hash],
            }),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  弹窗
  // ══════════════════════════════════════════════════════════

  void _showDeleteDialog(BuildContext context, String hash) {
    bool deleteFiles = false;
    final isTR = type == DownloaderType.transmission;

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = FTheme.of(ctx).colors;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => Dialog(
            backgroundColor: cs.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '确认删除',
                    style: TextStyle(
                      color: cs.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    torrent.name,
                    style: TextStyle(
                      color: cs.foreground.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '同时删除文件',
                          style: TextStyle(color: cs.foreground, fontSize: 13),
                        ),
                      ),
                      Switch(
                        value: deleteFiles,
                        onChanged: (v) => setDialogState(() => deleteFiles = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FButton(
                        style: FButtonStyle.ghost(),
                        onPress: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      FButton(
                        style: FButtonStyle.destructive(),
                        onPress: () {
                          Navigator.pop(ctx);
                          _exec(context, isTR ? 'remove_torrent' : 'delete', {
                            if (isTR) 'ids': [hash] else 'hashes': [hash],
                            'deleteFiles': deleteFiles,
                          });
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLocationDialog(
    BuildContext context,
    String hash,
    String currentPath,
  ) {
    final ctrl = TextEditingController(text: currentPath);
    final isTR = type == DownloaderType.transmission;

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = FTheme.of(ctx).colors;
        return Dialog(
          backgroundColor: cs.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '更改保存位置',
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  torrent.name,
                  style: TextStyle(
                    color: cs.foreground.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                FTextField(controller: ctrl, hint: '新目录路径'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      style: FButtonStyle.ghost(),
                      onPress: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FButton(
                      onPress: () {
                        Navigator.pop(ctx);
                        _exec(
                          context,
                          isTR ? 'move_torrent_data' : 'set_location',
                          {
                            if (isTR) 'ids': [hash] else 'hashes': [hash],
                            'savePath': ctrl.text,
                          },
                        );
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUploadLimitDialog(
    BuildContext context,
    String hash,
    int currentLimit,
  ) {
    final ctrl = TextEditingController(
      text: currentLimit > 0 ? (currentLimit / 1024).round().toString() : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = FTheme.of(ctx).colors;
        return Dialog(
          backgroundColor: cs.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '限制上传速度',
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  torrent.name,
                  style: TextStyle(
                    color: cs.foreground.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                FTextField(controller: ctrl, hint: '上传限制 (KiB/s)，0 为不限制'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      style: FButtonStyle.ghost(),
                      onPress: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FButton(
                      onPress: () {
                        Navigator.pop(ctx);
                        final limit = (int.tryParse(ctrl.text) ?? 0) * 1024;
                        _exec(context, 'set_upload_limit', {
                          'hashes': [hash],
                          'limit': limit,
                        });
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareRatioDialog(BuildContext context, String hash) {
    double ratioMode = torrent.seedRatioLimit == -2 ? -2 : 0;
    final ratioCtrl = TextEditingController(
      text: torrent.seedRatioLimit > 0
          ? torrent.seedRatioLimit.toString()
          : '2.0',
    );
    final timeCtrl = TextEditingController(
      text: torrent.secondsSeeding > 0
          ? (torrent.secondsSeeding / 3600).round().toString()
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = FTheme.of(ctx).colors;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => Dialog(
            backgroundColor: cs.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '限制分享率',
                      style: TextStyle(
                        color: cs.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _radioOption(ctx, '使用全局分享率限制', -2.0, ratioMode, (v) {
                      setDialogState(() => ratioMode = v);
                    }),
                    _radioOption(ctx, '无分享率限制', -1.0, ratioMode, (v) {
                      setDialogState(() => ratioMode = v);
                    }),
                    _radioOption(ctx, '自定义分享率限制', 0.0, ratioMode, (v) {
                      setDialogState(() => ratioMode = v);
                    }),
                    if (ratioMode == 0) ...[
                      const SizedBox(height: 12),
                      FTextField(controller: ratioCtrl, hint: '分享率 (如 2.0)'),
                      const SizedBox(height: 8),
                      FTextField(controller: timeCtrl, hint: '做种时间限制 (小时)'),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FButton(
                          style: FButtonStyle.ghost(),
                          onPress: () => Navigator.pop(ctx),
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 8),
                        FButton(
                          onPress: () {
                            Navigator.pop(ctx);
                            final rl = ratioMode < 0
                                ? ratioMode
                                : double.tryParse(ratioCtrl.text) ?? -2;
                            final st = ratioMode < 0
                                ? -1.0
                                : (double.tryParse(timeCtrl.text) ?? 0) * 3600;
                            _exec(context, 'set_share_limits', {
                              'hashes': [hash],
                              'ratioLimit': rl,
                              'seedingTimeLimit': st,
                            });
                          },
                          child: const Text('确认'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _radioOption(
    BuildContext ctx,
    String label,
    double value,
    double groupValue,
    ValueChanged<double> onChanged,
  ) {
    final cs = FTheme.of(ctx).colors;
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: selected
                  ? cs.primary
                  : cs.foreground.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: cs.foreground.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackerDialog(
    BuildContext context,
    String hash, {
    bool isTR = false,
  }) {
    final ctrl = TextEditingController(
      text: torrent.visibleTrackerStats
          .map((t) => t.announce)
          .where((a) => a.isNotEmpty)
          .join('\n'),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = FTheme.of(ctx).colors;
        return Dialog(
          backgroundColor: cs.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '修改 Tracker',
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  torrent.name,
                  style: TextStyle(
                    color: cs.foreground.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                FTextField(
                  controller: ctrl,
                  hint: '每行一个 Tracker 地址',
                  maxLines: 6,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      style: FButtonStyle.ghost(),
                      onPress: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FButton(
                      onPress: () {
                        Navigator.pop(ctx);
                        if (isTR) {
                          _exec(context, 'change_torrent', {
                            'ids': [hash],
                            'trackerList': ctrl.text.split('\n'),
                          });
                        } else {
                          _exec(context, 'set_tracker', {
                            'hashes': [hash],
                            'trackerList': ctrl.text,
                          });
                        }
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        final cs = FTheme.of(ctx).colors;
        return Dialog(
          backgroundColor: cs.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    color: cs.foreground.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      style: FButtonStyle.ghost(),
                      onPress: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FButton(
                      onPress: () {
                        Navigator.pop(ctx);
                        onConfirm();
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copy(BuildContext context, String text, String label) {
    Navigator.pop(context);
    Clipboard.setData(ClipboardData(text: text));
    Toast.success('$label已复制');
  }
}

// ══════════════════════════════════════════════════════════
//  子菜单组件
// ══════════════════════════════════════════════════════════

class _SubMenuBody extends StatelessWidget {
  final String title;
  final List<_SubMenuItem> items;

  const _SubMenuBody({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;

    return SafeArea(
      child: ColoredBox(
        color: cs.background,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: cs.foreground.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: cs.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 22,
                          color: cs.foreground.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          color: cs.foreground,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 0.5, color: cs.border),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: cs.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cs.border, width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: items
                          .map(
                            (item) => Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: item.onTap,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 18,
                                        color:
                                            item.iconColor ??
                                            cs.foreground.withValues(
                                              alpha: 0.6,
                                            ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: TextStyle(
                                            color: cs.foreground,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SubMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });
}
