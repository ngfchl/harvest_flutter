import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/modules/dashboard/provider/server_resource_provider.dart';

import 'dashboard_chart_config.dart';

class ChartSettingsDialog extends StatefulWidget {
  final List<String> order;
  final Map<String, bool> visibility;
  final double chartHeight;
  final int treemapCount;
  final bool allowReorder;
  final bool showSizingControls;
  final String title;

  final void Function(
    List<String> order,
    Map<String, bool> visibility,
    double height,
    int treemapCount,
  )
  onSaved;

  const ChartSettingsDialog({
    super.key,
    required this.order,
    required this.visibility,
    required this.chartHeight,
    required this.onSaved,
    required this.treemapCount,
    this.allowReorder = true,
    this.showSizingControls = true,
    this.title = '仪表盘卡片设置',
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

  late FContinuousSliderController _treemapSliderController;

  static const _tMin = DashboardChartConfig.minTreemapCount;
  static const _tMax = DashboardChartConfig.maxTreemapCount;
  static const _tRange = _tMax - _tMin;

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

    _treemapSliderController = FContinuousSliderController(
      selection: FSliderSelection(max: _toTPercent(_treemapCount)),
    );
  }

  @override
  void dispose() {
    _treemapSliderController.dispose();

    super.dispose();
  }

  double _toTPercent(int count) => ((count - _tMin) / _tRange).clamp(0.0, 1.0);

  int _fromTPercent(double p) => (p * _tRange + _tMin).round();

  Widget _serverResourceSettingRow(
    FThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colors.mutedForeground),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          FButton.icon(
            style: FButtonStyle.ghost(),
            onPress: onMinus,
            child: const Icon(FIcons.minus, size: 14),
          ),
          Container(
            width: 74,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: theme.typography.xs.copyWith(
                color: theme.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FButton.icon(
            style: FButtonStyle.ghost(),
            onPress: onPlus,
            child: const Icon(FIcons.plus, size: 14),
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
      DashboardChartConfig.saveTreemapCount(_treemapCount);
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

    widget.onSaved(_order, _visibility, _chartHeight, _treemapCount);
    Navigator.of(context).pop();
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
      if (widget.showSizingControls) {
        _chartHeight = defaultHeight;
        _treemapCount = DashboardChartConfig.defaultTreemapCount;
        _treemapSliderController.selection = FSliderSelection(
          max: _toTPercent(_treemapCount),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: 420,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ——— 标题栏 ———
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FButton.icon(
                    style: FButtonStyle.ghost(),
                    onPress: _reset,
                    child: const Icon(FIcons.rotateCcw, size: 16),
                  ),
                  FButton.icon(
                    style: FButtonStyle.ghost(),
                    onPress: () => Navigator.of(context).pop(),
                    child: const Icon(FIcons.x, size: 16),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ——— 站点数量 ———
                    if (widget.showSizingControls)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  FIcons.globe,
                                  size: 14,
                                  color: theme.colors.mutedForeground,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '站点状态显示数量',
                                  style: theme.typography.sm.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '$_treemapCount 个',
                                    style: theme.typography.xs.copyWith(
                                      color: theme.colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            FSlider(
                              controller: _treemapSliderController,
                              onChange: (selection) {
                                setState(
                                  () => _treemapCount = _fromTPercent(
                                    selection.offset.max,
                                  ),
                                );
                              },
                              tooltipBuilder: (ctrl, value) =>
                                  Text('${_fromTPercent(value)} 个'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${DashboardChartConfig.minTreemapCount}',
                                  style: theme.typography.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                                Text(
                                  '${DashboardChartConfig.maxTreemapCount}',
                                  style: theme.typography.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
                      child: FTile(
                        prefix: const Icon(FIcons.activity, size: 14),
                        title: const Text('自动刷新状态监控'),
                        subtitle: const Text('开启后持续刷新服务器与服务状态，关闭时仅获取一次'),
                        suffix: FSwitch(
                          value: _serverResourceAutoStart,
                          onChange: (value) =>
                              setState(() => _serverResourceAutoStart = value),
                        ),
                        enabled: true,
                      ),
                    ),
                    _serverResourceSettingRow(
                      theme,
                      icon: FIcons.clock,
                      title: '状态刷新间隔',
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
                    _serverResourceSettingRow(
                      theme,
                      icon: FIcons.timer,
                      title: '状态刷新时长',
                      value: '${_serverResourceDuration}min',
                      onMinus: () => setState(
                        () => _serverResourceDuration =
                            (_serverResourceDuration - 1)
                                .clamp(
                                  kMinServerResourceDuration,
                                  kMaxServerResourceDuration,
                                )
                                .toInt(),
                      ),
                      onPlus: () => setState(
                        () => _serverResourceDuration =
                            (_serverResourceDuration + 1)
                                .clamp(
                                  kMinServerResourceDuration,
                                  kMaxServerResourceDuration,
                                )
                                .toInt(),
                      ),
                    ),

                    // ——— 卡片排序 + 显隐 ———
                    if (widget.allowReorder)
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 8,
                        ),
                        buildDefaultDragHandles: false,
                        // ← 禁用默认拖动手柄
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
                          final name = DashboardChartConfig.names[id] ?? id;
                          final visible = _visibility[id] ?? true;

                          return Container(
                            key: ValueKey(id),
                            margin: const EdgeInsets.only(bottom: 4),
                            child: FTile(
                              prefix: ReorderableDragStartListener(
                                // ← 前缀图标作为拖动手柄
                                index: index,
                                child: Icon(FIcons.gripVertical, size: 14),
                              ),
                              title: Text(name),
                              subtitle: visible ? null : Text('已隐藏'),
                              suffix: FSwitch(
                                value: visible,
                                onChange: (value) =>
                                    setState(() => _visibility[id] = value),
                              ),
                              enabled: true,
                            ),
                          );
                        },
                      ),
                    if (!widget.allowReorder)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            for (final id in _order)
                              Container(
                                key: ValueKey(id),
                                margin: const EdgeInsets.only(bottom: 4),
                                child: FTile(
                                  prefix: const Icon(FIcons.eye, size: 14),
                                  title: Text(
                                    DashboardChartConfig.names[id] ?? id,
                                  ),
                                  subtitle: (_visibility[id] ?? true)
                                      ? null
                                      : const Text('已隐藏'),
                                  suffix: FSwitch(
                                    value: _visibility[id] ?? true,
                                    onChange: (value) =>
                                        setState(() => _visibility[id] = value),
                                  ),
                                  enabled: true,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ——— 底部按钮 ———
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FButton(
                      style: FButtonStyle.outline(),
                      onPress: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FButton(onPress: _save, child: const Text('保存')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
