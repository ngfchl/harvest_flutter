import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/modules/dashboard/provider/server_resource_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'desktop_chart_config.dart';

class ChartSettingsDialog extends StatefulWidget {
  final List<String> order;
  final Map<String, bool> visibility;
  final double chartHeight;
  final int treemapCount;
  final int defaultTreemapCount;
  final bool allowReorder;
  final bool showSizingControls;
  final bool showTreemapCountControl;
  final String title;
  final void Function(int count)? onTreemapCountSaved;

  final void Function(
    List<String> order,
    Map<String, bool> visibility,
    double height,
    int treemapCount,
    int phoneTrendDays,
  )
  onSaved;

  const ChartSettingsDialog({
    super.key,
    required this.order,
    required this.visibility,
    required this.chartHeight,
    required this.onSaved,
    required this.treemapCount,
    this.defaultTreemapCount = DashboardChartConfig.defaultTreemapCount,
    this.allowReorder = true,
    this.showSizingControls = true,
    this.showTreemapCountControl = false,
    this.title = '仪表盘卡片设置',
    this.onTreemapCountSaved,
  });

  @override
  State<ChartSettingsDialog> createState() => _ChartSettingsDialogState();
}

class _ChartSettingsDialogState extends State<ChartSettingsDialog> {
  late List<String> _order;
  late Map<String, bool> _visibility;
  late double _chartHeight;
  late int _treemapCount;
  late int _serverResourceInterval;
  late int _serverResourceDuration;
  late bool _serverResourceAutoStart;
  late int _phoneTrendDays;

  static const _tMin = DashboardChartConfig.minTreemapCount;
  static const _tMax = DashboardChartConfig.maxTreemapCount;
  static const _tRange = _tMax - _tMin;

  bool get _showPhoneTrendDefaultControl =>
      widget.order.contains('phoneTrend') ||
      widget.order.contains('phoneToday');

  bool get _showTreemapCountControl =>
      widget.showSizingControls || widget.showTreemapCountControl;

  @override
  void initState() {
    super.initState();
    _order = List.from(widget.order);
    _visibility = Map.from(widget.visibility);
    _chartHeight = widget.chartHeight;
    _treemapCount = widget.treemapCount;
    _serverResourceInterval =
        HiveManager.get<int>(StorageKeys.serverResourceInterval) ??
        kDefaultServerResourceInterval;
    _serverResourceDuration =
        HiveManager.get<int>(StorageKeys.serverResourceDuration) ??
        kDefaultServerResourceDuration;
    _serverResourceAutoStart =
        HiveManager.get<bool>(StorageKeys.serverResourceAutoStart) ??
        kDefaultServerResourceAutoStart;
    _phoneTrendDays = DashboardChartConfig.getPhoneTrendDays();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double _toTPercent(int count) => ((count - _tMin) / _tRange).clamp(0.0, 1.0);

  int _fromTPercent(double p) => (p * _tRange + _tMin).round();

  Widget _serverResourceSettingRow(
    _SettingsThemeTokens tokens, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    final theme = tokens.theme;
    final cs = theme.colorScheme;
    return shadcn.Card(
      filled: true,
      fillColor: cs.muted.withValues(alpha: 0.20),
      borderColor: cs.border.withValues(alpha: 0.44),
      padding: tokens.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: tokens.iconSm, color: cs.mutedForeground),
          tokens.hGap(10),
          Expanded(
            child: Text(
              title,
              style: theme.typography.small.copyWith(
                color: cs.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          tokens.hGap(10),
          shadcn.IconButton.ghost(
            onPressed: onMinus,
            icon: Icon(shadcn.LucideIcons.minus, size: tokens.iconSm),
          ),
          SizedBox(
            width: tokens.size(74),
            child: Center(
              child: shadcn.SecondaryBadge(
                child: Text(
                  value,
                  style: theme.typography.xSmall.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          shadcn.IconButton.ghost(
            onPressed: onPlus,
            icon: Icon(shadcn.LucideIcons.plus, size: tokens.iconSm),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (widget.allowReorder) {
      DashboardChartConfig.saveOrder(_order);
    }
    for (final entry in _visibility.entries) {
      DashboardChartConfig.setVisibility(entry.key, entry.value);
    }
    if (widget.showSizingControls) {
      DashboardChartConfig.saveChartHeight(_chartHeight);
    }
    if (_showTreemapCountControl) {
      final saver = widget.onTreemapCountSaved;
      if (saver == null) {
        DashboardChartConfig.saveTreemapCount(_treemapCount);
      } else {
        saver(_treemapCount);
      }
    }
    if (_showPhoneTrendDefaultControl) {
      DashboardChartConfig.savePhoneTrendDays(_phoneTrendDays);
    }
    HiveManager.set(
      StorageKeys.serverResourceInterval,
      _serverResourceInterval,
    );
    HiveManager.set(
      StorageKeys.serverResourceDuration,
      _serverResourceDuration,
    );
    HiveManager.set(
      StorageKeys.serverResourceAutoStart,
      _serverResourceAutoStart,
    );

    widget.onSaved(
      _order,
      _visibility,
      _chartHeight,
      _treemapCount,
      _phoneTrendDays,
    );
    shadcn.closeOverlay(context);
  }

  void _reset() {
    final defaultHeight = DashboardChartConfig.defaultChartHeight;
    setState(() {
      if (widget.allowReorder) {
        _order = List.from(DashboardChartConfig.defaultOrder);
      }
      _visibility = {for (final id in _order) id: true};
      _serverResourceInterval = kDefaultServerResourceInterval;
      _serverResourceDuration = kDefaultServerResourceDuration;
      _serverResourceAutoStart = kDefaultServerResourceAutoStart;
      _phoneTrendDays = DashboardChartConfig.defaultPhoneTrendDays;
      if (_showTreemapCountControl) {
        _treemapCount = widget.defaultTreemapCount;
      }
      if (widget.showSizingControls) {
        _chartHeight = defaultHeight;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _SettingsThemeTokens.of(context);
    final theme = tokens.theme;
    final mediaSize = MediaQuery.sizeOf(context);
    final popoverWidth = math
        .min(mediaSize.width - tokens.size(32), tokens.size(460))
        .clamp(tokens.size(320), tokens.size(520));
    final maxHeight = (mediaSize.height * 0.76)
        .clamp(tokens.size(400), tokens.size(680))
        .toDouble();

    return shadcn.ModalContainer(
      padding: tokens.all(16),
      child: SizedBox(
        width: popoverWidth.toDouble(),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.typography.large.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  shadcn.IconButton.ghost(
                    onPressed: _reset,
                    icon: Icon(
                      shadcn.LucideIcons.rotateCcw,
                      size: tokens.iconMd,
                    ),
                  ),
                  shadcn.IconButton.ghost(
                    onPressed: () => shadcn.closeOverlay(context),
                    icon: Icon(shadcn.LucideIcons.x, size: tokens.iconMd),
                  ),
                ],
              ),
              tokens.vGap(18),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_showTreemapCountControl) ...[
                        _SettingsSection(
                          icon: shadcn.LucideIcons.globe,
                          title: '站点状态显示',
                          description: '控制站点矩形图显示数量，数量越少每个站点块越宽松。',
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '显示站点数量',
                                    style: theme.typography.small.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                shadcn.SecondaryBadge(
                                  child: Text(
                                    '$_treemapCount 个',
                                    style: theme.typography.xSmall.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            tokens.vGap(14),
                            shadcn.Slider(
                              value: shadcn.SliderValue.single(
                                _toTPercent(_treemapCount),
                              ),
                              onChanged: (value) {
                                setState(
                                  () => _treemapCount = _fromTPercent(
                                    value.value,
                                  ),
                                );
                              },
                            ),
                            tokens.vGap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${DashboardChartConfig.minTreemapCount}',
                                  style: theme.typography.xSmall.copyWith(
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                                Text(
                                  '${DashboardChartConfig.maxTreemapCount}',
                                  style: theme.typography.xSmall.copyWith(
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        tokens.vGap(16),
                      ],
                      _SettingsSection(
                        icon: shadcn.LucideIcons.refreshCw,
                        title: '刷新状态',
                        description: '统一管理服务器状态与后台服务状态的刷新行为。',
                        children: [
                          _SettingsTile(
                            leading: Icon(
                              shadcn.LucideIcons.activity,
                              size: tokens.iconSm,
                            ),
                            title: '自动刷新',
                            subtitle: '开启后持续刷新服务器与服务状态，关闭时仅获取一次',
                            trailing: shadcn.Switch(
                              value: _serverResourceAutoStart,
                              onChanged: (value) => setState(
                                () => _serverResourceAutoStart = value,
                              ),
                            ),
                          ),
                          tokens.vGap(12),
                          _serverResourceSettingRow(
                            tokens,
                            icon: shadcn.LucideIcons.clock,
                            title: '刷新间隔',
                            value: '${_serverResourceInterval}s',
                            onMinus: () => setState(
                              () => _serverResourceInterval =
                                  (_serverResourceInterval - 1)
                                      .clamp(
                                        kMinServerResourceInterval,
                                        kMaxServerResourceInterval,
                                      )
                                      .toInt(),
                            ),
                            onPlus: () => setState(
                              () => _serverResourceInterval =
                                  (_serverResourceInterval + 1)
                                      .clamp(
                                        kMinServerResourceInterval,
                                        kMaxServerResourceInterval,
                                      )
                                      .toInt(),
                            ),
                          ),
                        ],
                      ),
                      tokens.vGap(16),
                      _SettingsSection(
                        icon: shadcn.LucideIcons.layoutGrid,
                        title: '看板开关列表',
                        description: widget.allowReorder
                            ? '拖动左侧手柄调整顺序，开关控制模块显示。'
                            : '控制桌面看板模块是否显示。',
                        children: [
                          if (_showPhoneTrendDefaultControl) ...[
                            _SettingsTile(
                              leading: Icon(
                                shadcn.LucideIcons.calendarRange,
                                size: tokens.iconSm,
                              ),
                              title: '增量趋势默认间隔',
                              subtitle: '进入仪表盘时默认显示的时间范围',
                              trailing: _RangeSegmentedControl(
                                value: _phoneTrendDays,
                                onChanged: (value) =>
                                    setState(() => _phoneTrendDays = value),
                              ),
                            ),
                            tokens.vGap(12),
                          ],
                          if (widget.allowReorder)
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              buildDefaultDragHandles: false,
                              itemCount: _order.length,
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) newIndex--;
                                  final item = _order.removeAt(oldIndex);
                                  _order.insert(newIndex, item);
                                });
                              },
                              itemBuilder: (context, index) {
                                final id = _order[index];
                                final name =
                                    DashboardChartConfig.names[id] ?? id;
                                final visible = _visibility[id] ?? true;

                                return Padding(
                                  key: ValueKey(id),
                                  padding: tokens.only(bottom: 10),
                                  child: _SettingsTile(
                                    leading: ReorderableDragStartListener(
                                      index: index,
                                      child: Icon(
                                        shadcn.LucideIcons.gripVertical,
                                        size: tokens.iconSm,
                                      ),
                                    ),
                                    title: name,
                                    subtitle: visible ? null : '已隐藏',
                                    trailing: shadcn.Switch(
                                      value: visible,
                                      onChanged: (value) => setState(
                                        () => _visibility[id] = value,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (!widget.allowReorder)
                            Column(
                              children: [
                                for (final id in _order)
                                  Padding(
                                    key: ValueKey(id),
                                    padding: tokens.only(bottom: 10),
                                    child: _SettingsTile(
                                      leading: Icon(
                                        shadcn.LucideIcons.eye,
                                        size: tokens.iconSm,
                                      ),
                                      title:
                                          DashboardChartConfig.names[id] ?? id,
                                      subtitle: (_visibility[id] ?? true)
                                          ? null
                                          : '已隐藏',
                                      trailing: shadcn.Switch(
                                        value: _visibility[id] ?? true,
                                        onChanged: (value) => setState(
                                          () => _visibility[id] = value,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              tokens.vGap(14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: shadcn.Button.outline(
                      onPressed: () => shadcn.closeOverlay(context),
                      child: Center(child: const Text('取消')),
                    ),
                  ),
                  tokens.hGap(10),
                  Expanded(
                    child: shadcn.Button.primary(
                      onPressed: _save,
                      child: Center(child: const Text('保存')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Widget> children;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = _SettingsThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = theme.colorScheme;

    return shadcn.Card(
      filled: true,
      fillColor: cs.card,
      borderColor: cs.border.withValues(alpha: 0.72),
      padding: tokens.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: tokens.size(30),
                height: tokens.size(30),
                child: shadcn.Card(
                  filled: true,
                  fillColor: cs.primary.withValues(alpha: 0.10),
                  borderColor: cs.primary.withValues(alpha: 0.16),
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Icon(icon, size: tokens.iconSm, color: cs.primary),
                  ),
                ),
              ),
              tokens.hGap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.typography.small.copyWith(
                        color: cs.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    tokens.vGap(3),
                    Text(
                      description,
                      style: theme.typography.xSmall.copyWith(
                        color: cs.mutedForeground,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          tokens.vGap(16),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.leading,
    required this.title,
    required this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = _SettingsThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = theme.colorScheme;

    return shadcn.Card(
      filled: true,
      fillColor: cs.muted.withValues(alpha: 0.20),
      borderColor: cs.border.withValues(alpha: 0.44),
      padding: tokens.symmetric(horizontal: 14, vertical: 13),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final label = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTheme(
                data: IconThemeData(
                  color: cs.mutedForeground,
                  size: tokens.iconSm,
                ),
                child: leading,
              ),
              tokens.hGap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.typography.small.copyWith(
                        color: cs.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: tokens.only(top: 4),
                        child: Text(
                          subtitle!,
                          style: theme.typography.xSmall.copyWith(
                            color: cs.mutedForeground,
                            height: 1.35,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );

          // if (compact) {
          //   return Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       label,
          //       tokens.vGap(10),
          //       Align(alignment: Alignment.centerRight, child: trailing),
          //     ],
          //   );
          // }

          return Row(
            children: [
              Expanded(child: label),
              tokens.hGap(10),
              trailing,
            ],
          );
        },
      ),
    );
  }
}

class _RangeSegmentedControl extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _RangeSegmentedControl({required this.value, required this.onChanged});

  static const _items = [
    MapEntry(1, '今日'),
    MapEntry(7, '本周'),
    MapEntry(30, '本月'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final tokens = _SettingsThemeTokens.of(context);
    final cs = theme.colorScheme;
    return shadcn.Card(
      padding: tokens.all(3),
      filled: true,
      fillColor: cs.background.withValues(alpha: 0.72),
      borderColor: cs.border.withValues(alpha: 0.68),
      child: shadcn.Row(
        mainAxisSize: shadcn.MainAxisSize.max,
        mainAxisAlignment: shadcn.MainAxisAlignment.spaceAround,
        children: [
          for (final item in _items)
            value == item.key
                ? shadcn.Button.primary(
                    onPressed: () => onChanged(item.key),
                    child: Text(
                      item.value,
                      style: theme.typography.xSmall.copyWith(
                        color: cs.primaryForeground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : shadcn.Button.ghost(
                    onPressed: () => onChanged(item.key),
                    child: Text(
                      item.value,
                      style: theme.typography.xSmall.copyWith(
                        color: cs.mutedForeground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}

class _SettingsThemeTokens {
  final shadcn.ThemeData theme;
  final double densityScale;
  final double textScale;

  _SettingsThemeTokens._({
    required this.theme,
    required this.densityScale,
    required this.textScale,
  });

  factory _SettingsThemeTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityScale =
        ((theme.density.baseContainerPadding / 16.0) * theme.scaling).clamp(
          0.90,
          1.72,
        );
    final textScale = theme.scaling.clamp(0.92, 1.34);
    return _SettingsThemeTokens._(
      theme: theme,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  double get iconSm => size(15);

  double get iconMd => size(18);

  EdgeInsets all(num value) => EdgeInsets.all(size(value));

  EdgeInsets symmetric({num horizontal = 0, num vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: size(horizontal),
        vertical: size(vertical),
      );

  EdgeInsets fromLTRB(num left, num top, num right, num bottom) =>
      EdgeInsets.fromLTRB(size(left), size(top), size(right), size(bottom));

  EdgeInsets only({num left = 0, num top = 0, num right = 0, num bottom = 0}) =>
      EdgeInsets.only(
        left: size(left),
        top: size(top),
        right: size(right),
        bottom: size(bottom),
      );

  SizedBox hGap(num value) => SizedBox(width: size(value));

  SizedBox vGap(num value) => SizedBox(height: size(value));
}
