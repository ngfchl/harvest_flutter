import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/utils/platform/platform_tool.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:window_manager/window_manager.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_presets.dart';
import '../../../core/theme/theme_provider.dart';

void showThemeDialog(BuildContext context) {
  shadcn.showDialog(context: context, builder: (_) => const ThemeDialog());
}

class ThemeDialog extends ConsumerStatefulWidget {
  const ThemeDialog({super.key});

  @override
  ConsumerState<ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends ConsumerState<ThemeDialog> {
  static const _windowPresets = <_WindowPreset>[
    _WindowPreset('800 × 600', 800, 600),
    _WindowPreset('1024 × 768', 1024, 768),
    _WindowPreset('1200 × 800', 1200, 800),
    _WindowPreset('1440 × 900', 1440, 900),
    _WindowPreset('1600 × 900', 1660, 900),
    _WindowPreset('1680 × 945', 1680, 945),
    _WindowPreset('1920 × 1080', 1920, 1080),
    _WindowPreset('2560 × 1440', 2560, 1440),
  ];

  Future<void> _applyWindowSize(double width, double height) async {
    await windowManager.setSize(Size(width, height));
    await windowManager.focus();
    HiveManager.set('ScreenSizeWidth', width.toInt());
    HiveManager.set('ScreenSizeHeight', height.toInt());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final tokens = _ThemeDialogTokens.of(context);
    final currentWidth = HiveManager.get('ScreenSizeWidth')?.toDouble() ?? 1440;
    final currentHeight = HiveManager.get('ScreenSizeHeight')?.toDouble() ?? 900;

    return shadcn.AlertDialog(
      padding: EdgeInsets.symmetric(horizontal: tokens.panelHorizontalPadding, vertical: tokens.panelVerticalPadding),
      content: SizedBox(
        width: tokens.dialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: tokens.dialogHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dialogHeader(context),
              tokens.vGap(12),
              _themePreview(context, current),
              tokens.vGap(12),
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : tokens.dialogWidth;
                      final gap = tokens.sectionGap;
                      final useColumns = maxWidth >= 520;
                      final columnWidth = useColumns ? (maxWidth - gap) / 2 : maxWidth;
                      final sectionWidth = columnWidth.clamp(0.0, maxWidth).toDouble();

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          SizedBox(
                            width: sectionWidth,
                            child: _section(
                              context,
                              icon: shadcn.LucideIcons.contrast,
                              title: '明暗模式',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _modeButton(
                                          context,
                                          ref,
                                          shadcn.ThemeMode.light,
                                          shadcn.LucideIcons.sun,
                                          '亮色',
                                        ),
                                      ),
                                      tokens.hGap(6),
                                      Expanded(
                                        child: _modeButton(
                                          context,
                                          ref,
                                          shadcn.ThemeMode.dark,
                                          shadcn.LucideIcons.moon,
                                          '暗色',
                                        ),
                                      ),
                                      tokens.hGap(6),
                                      Expanded(
                                        child: _modeButton(
                                          context,
                                          ref,
                                          shadcn.ThemeMode.system,
                                          shadcn.LucideIcons.monitorCog,
                                          '自动',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            width: maxWidth,
                            child: _section(
                              context,
                              icon: shadcn.LucideIcons.swatchBook,
                              title: '颜色',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _fieldLabel(context, '基础色'),
                                  tokens.vGap(6),
                                  _baseOptions(
                                    context,
                                    selected: current.baseScheme,
                                    onSelected: notifier.setBaseScheme,
                                  ),
                                  tokens.vGap(12),
                                  _fieldLabel(context, '强调色'),
                                  tokens.vGap(8),
                                  Wrap(
                                    spacing: tokens.size(7),
                                    runSpacing: tokens.size(8),
                                    children: [
                                      for (final option in AppThemeOptions.accents)
                                        _accentSwatch(
                                          context,
                                          label: _accentLabel(option.id),
                                          color:
                                              option.value ??
                                              AppThemeOptions.colorScheme(
                                                current.baseScheme,
                                                'base',
                                                tokens.isDark,
                                              ).primary,
                                          selected: current.accent == option.id,
                                          onTap: () => notifier.setAccent(option.id),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: sectionWidth,
                            child: _section(
                              context,
                              icon: shadcn.LucideIcons.slidersHorizontal,
                              title: '形态',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _fieldLabel(context, '密度'),
                                  tokens.vGap(6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _densityButton(
                                          context,
                                          selected: current.density == 'reduced',
                                          label: _densityLabel('reduced'),
                                          onTap: () => notifier.setDensity('reduced'),
                                        ),
                                      ),
                                      tokens.hGap(6),
                                      Expanded(
                                        child: _densityButton(
                                          context,
                                          selected: current.density == 'default',
                                          label: _densityLabel('default'),
                                          onTap: () => notifier.setDensity('default'),
                                        ),
                                      ),
                                      tokens.hGap(6),
                                      Expanded(
                                        child: _densityButton(
                                          context,
                                          selected: current.density == 'spacious',
                                          label: _densityLabel('spacious'),
                                          onTap: () => notifier.setDensity('spacious'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  tokens.vGap(10),
                                  _fieldLabel(context, '缩放'),
                                  tokens.vGap(6),
                                  _themeSlider(
                                    context,
                                    value: current.scaling,
                                    min: 0.85,
                                    max: 1.15,
                                    display: current.scaling.toStringAsFixed(2),
                                    onChanged: notifier.setScaling,
                                  ),
                                  tokens.vGap(10),
                                  _fieldLabel(context, '圆角'),
                                  tokens.vGap(6),
                                  _themeSlider(
                                    context,
                                    value: current.radius,
                                    min: 0,
                                    max: 1.5,
                                    display: current.radius.toStringAsFixed(2),
                                    onChanged: notifier.setRadius,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (PlatformTool.isDesktopOS())
                            SizedBox(
                              width: sectionWidth,
                              child: _section(
                                context,
                                icon: shadcn.LucideIcons.monitor,
                                title: '窗口尺寸',
                                child: _windowSizeGrid(
                                  context,
                                  currentWidth: currentWidth.toDouble(),
                                  currentHeight: currentHeight.toDouble(),
                                  tokens: tokens,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              tokens.vGap(12),
              _dialogFooter(context, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _windowSizeGrid(
    BuildContext context, {
    required double currentWidth,
    required double currentHeight,
    required _ThemeDialogTokens tokens,
  }) {
    final gap = tokens.size(6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth < 320 ? 2 : 3;
        final rows = <List<_WindowPreset>>[];
        for (var i = 0; i < _windowPresets.length; i += columns) {
          rows.add(_windowPresets.sublist(i, (i + columns).clamp(0, _windowPresets.length)));
        }

        return Column(
          spacing: gap,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              Row(
                children: [
                  for (var c = 0; c < rows[r].length; c++) ...[
                    Expanded(
                      child: _windowSizeButton(
                        context,
                        preset: rows[r][c],
                        selected: currentWidth == rows[r][c].width && currentHeight == rows[r][c].height,
                      ),
                    ),
                    if (c != rows[r].length - 1) SizedBox(width: gap),
                  ],
                ],
              ),
              if (r != rows.length - 1) SizedBox(height: gap),
            ],
          ],
        );
      },
    );
  }

  Widget _windowSizeButton(BuildContext context, {required _WindowPreset preset, required bool selected}) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _applyWindowSize(preset.width, preset.height),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: tokens.size(30),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: tokens.size(6)),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.secondary,
          borderRadius: BorderRadius.circular(tokens.sectionRadius),
          border: Border.all(color: selected ? cs.primary : cs.border, width: tokens.hairline),
        ),
        child: Text(
          preset.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.xSmall.copyWith(
            color: selected ? cs.primaryForeground : cs.foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _dialogHeader(BuildContext context) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return SizedBox(
      height: tokens.headerHeight,
      child: Row(
        children: [
          Container(
            width: tokens.size(34),
            height: tokens.size(34),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(tokens.sectionRadius)),
            child: Icon(shadcn.LucideIcons.palette, size: tokens.iconMd, color: cs.primaryForeground),
          ),
          tokens.hGap(10),
          Expanded(
            child: Text(
              '主题设置',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.large.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
            ),
          ),
          shadcn.IconButton.ghost(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(shadcn.LucideIcons.x, size: tokens.iconMd),
          ),
        ],
      ),
    );
  }

  Widget _themePreview(BuildContext context, ThemeState current) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final previewScheme = AppThemeOptions.colorScheme(current.baseScheme, current.accent, tokens.isDark);
    final baseScheme = AppThemeOptions.colorScheme(current.baseScheme, 'base', tokens.isDark);

    return Container(
      padding: EdgeInsets.all(tokens.size(12)),
      decoration: BoxDecoration(
        color: cs.card,
        borderRadius: BorderRadius.circular(tokens.sectionRadius),
        border: Border.all(color: cs.border, width: tokens.hairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_baseLabel(current.baseScheme)} / ${_accentLabel(current.accent)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
                ),
                tokens.vGap(3),
                Text(
                  '${_modeLabel(current.mode)} · ${_densityLabel(current.density)} · ${current.scaling.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          tokens.hGap(12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _previewSwatch(context, baseScheme.primary, label: '基础'),
              tokens.hGap(8),
              _previewSwatch(context, previewScheme.primary, label: '强调'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewSwatch(BuildContext context, Color color, {required String label}) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return SizedBox(
      width: tokens.size(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: tokens.size(26),
            height: tokens.size(26),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(tokens.size(7)),
              border: Border.all(color: cs.border, width: tokens.hairline),
            ),
          ),
          tokens.vGap(3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _dialogFooter(BuildContext context, ThemeNotifier notifier) {
    final tokens = _ThemeDialogTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: shadcn.Button.outline(
            onPressed: notifier.reset,
            leading: Icon(shadcn.LucideIcons.rotateCcw, size: tokens.iconSm),
            child: const Center(child: Text('恢复默认')),
          ),
        ),
        tokens.hGap(8),
        Expanded(
          child: shadcn.Button.primary(
            onPressed: () => Navigator.of(context).pop(),
            child: const Center(child: Text('关闭')),
          ),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, {required IconData icon, required String title, required Widget child}) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return Container(
      padding: EdgeInsets.all(tokens.sectionPadding),
      decoration: BoxDecoration(
        color: cs.card,
        borderRadius: BorderRadius.circular(tokens.sectionRadius),
        border: Border.all(color: cs.border, width: tokens.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: tokens.size(24),
                height: tokens.size(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: cs.secondary, borderRadius: BorderRadius.circular(tokens.size(6))),
                child: Icon(icon, size: tokens.iconSm, color: cs.primary),
              ),
              tokens.hGap(8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          tokens.vGap(10),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String label) {
    final tokens = _ThemeDialogTokens.of(context);
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: tokens.theme.typography.xSmall.copyWith(color: tokens.cs.mutedForeground, fontWeight: FontWeight.w800),
    );
  }

  Widget _baseOptions(BuildContext context, {required String selected, required ValueChanged<String> onSelected}) {
    final tokens = _ThemeDialogTokens.of(context);
    final options = AppThemeOptions.baseSchemes;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tokens.baseOptionsWidth),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : tokens.baseOptionsWidth;
          final gap = tokens.size(6);
          final columns = ((maxWidth + gap) / (tokens.baseButtonMinWidth + gap))
              .floor()
              .clamp(1, options.length)
              .toInt();
          final rows = <List<AppThemeOption<String>>>[];
          for (var index = 0; index < options.length; index += columns) {
            final end = (index + columns).clamp(0, options.length).toInt();
            rows.add(options.sublist(index, end));
          }

          return Column(
            children: [
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
                Row(
                  children: [
                    for (var itemIndex = 0; itemIndex < rows[rowIndex].length; itemIndex++) ...[
                      Expanded(
                        child: _baseSchemeButton(
                          context,
                          option: rows[rowIndex][itemIndex],
                          selected: selected == rows[rowIndex][itemIndex].id,
                          onTap: () => onSelected(rows[rowIndex][itemIndex].id),
                        ),
                      ),
                      if (itemIndex != rows[rowIndex].length - 1) tokens.hGap(6),
                    ],
                  ],
                ),
                if (rowIndex != rows.length - 1) tokens.vGap(8),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _baseSchemeButton(
    BuildContext context, {
    required AppThemeOption<String> option,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final tokens = _ThemeDialogTokens.of(context);
    final cs = tokens.cs;
    final theme = tokens.theme;
    final color = AppThemeOptions.colorScheme(option.id, 'base', cs.brightness == Brightness.dark).primary;
    final background = selected ? color : cs.secondary;
    final foreground = selected
        ? ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : Colors.black
        : color;
    final subtleBackground = Color.alphaBlend(color.withValues(alpha: tokens.isDark ? 0.18 : 0.10), cs.secondary);
    return shadcn.Tooltip(
      tooltip: (_) => Text(_baseLabel(option.id)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: tokens.size(36),
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: tokens.size(8)),
          decoration: BoxDecoration(
            color: selected ? background : subtleBackground,
            borderRadius: BorderRadius.circular(tokens.sectionRadius),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.55),
              width: selected ? tokens.size(1.4) : tokens.hairline,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: tokens.isDark ? 0.28 : 0.22),
                      blurRadius: tokens.size(12),
                      offset: Offset(0, tokens.size(4)),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: tokens.size(18),
                height: tokens.size(18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? foreground.withValues(alpha: 0.18) : color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? foreground : color, width: tokens.size(1.2)),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: selected ? tokens.size(6) : tokens.size(8),
                  height: selected ? tokens.size(6) : tokens.size(8),
                  decoration: BoxDecoration(color: selected ? foreground : color, shape: BoxShape.circle),
                ),
              ),
              tokens.hGap(7),
              Flexible(
                child: Text(
                  _baseLabel(option.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(color: foreground, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeSlider(
    BuildContext context, {
    required double value,
    required double min,
    required double max,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tokens.sliderWidth),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.sliderThumbPadding),
              child: shadcn.Slider(
                value: shadcn.SliderValue.single(_sliderPosition(value, min, max)),
                onChanged: (sliderValue) => onChanged(_sliderValue(sliderValue.value, min, max)),
              ),
            ),
          ),
          tokens.hGap(10),
          Container(
            width: tokens.size(52),
            height: tokens.size(28),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: tokens.size(6)),
            decoration: BoxDecoration(
              color: cs.secondary,
              borderRadius: BorderRadius.circular(tokens.sectionRadius),
              border: Border.all(color: cs.border, width: tokens.hairline),
            ),
            child: Text(
              display,
              maxLines: 1,
              style: theme.typography.xSmall.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _densityButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: tokens.size(30),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: tokens.size(11)),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.secondary,
          borderRadius: BorderRadius.circular(tokens.sectionRadius),
          border: Border.all(color: selected ? cs.primary : cs.border, width: tokens.hairline),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: theme.typography.xSmall.copyWith(
            color: selected ? cs.primaryForeground : cs.foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _accentSwatch(
    BuildContext context, {
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final tokens = _ThemeDialogTokens.of(context);
    final cs = tokens.cs;
    final checkColor = ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black;
    return shadcn.Tooltip(
      tooltip: (_) => Text(label),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: tokens.accentSwatchSize,
          height: tokens.accentSwatchSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? cs.primary : cs.border,
              width: selected ? tokens.size(2) : tokens.hairline,
            ),
            color: cs.card,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: tokens.accentDotSize,
                height: tokens.accentDotSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (selected) Icon(shadcn.LucideIcons.check, size: tokens.size(13), color: checkColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(BuildContext context, WidgetRef ref, shadcn.ThemeMode mode, IconData icon, String label) {
    final tokens = _ThemeDialogTokens.of(context);
    final current = ref.watch(themeNotifierProvider);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final selected = current.mode == mode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(themeNotifierProvider.notifier).setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: tokens.modeButtonWidth,
        height: tokens.size(34),
        padding: EdgeInsets.symmetric(horizontal: tokens.size(8)),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.secondary,
          borderRadius: BorderRadius.circular(tokens.sectionRadius),
          border: Border.all(color: selected ? cs.primary : cs.border, width: tokens.hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: tokens.iconSm, color: selected ? cs.primaryForeground : cs.primary),
            tokens.hGap(5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(
                  color: selected ? cs.primaryForeground : cs.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowPreset {
  final String label;
  final double width;
  final double height;

  const _WindowPreset(this.label, this.width, this.height);
}

class _ThemeDialogTokens {
  final shadcn.ThemeData theme;
  final shadcn.ColorScheme cs;
  final double densityScale;
  final double textScale;
  final Size mediaSize;

  _ThemeDialogTokens._({
    required this.theme,
    required this.cs,
    required this.densityScale,
    required this.textScale,
    required this.mediaSize,
  });

  factory _ThemeDialogTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final mediaSize = MediaQuery.sizeOf(context);
    final densityScale = ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(0.55, 1.45);
    final textScale = theme.scaling.clamp(0.86, 1.30);
    return _ThemeDialogTokens._(
      theme: theme,
      cs: theme.colorScheme,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
      mediaSize: mediaSize,
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  double get hairline => size(0.5).clamp(0.5, 1.0).toDouble();

  bool get isDark => cs.brightness == Brightness.dark;

  double get iconMd => font(16);

  double get iconSm => font(13);

  double get headerHeight => size(38).clamp(34.0, 46.0).toDouble();

  double get panelHorizontalPadding => 16.0;

  double get panelVerticalPadding => mediaSize.width < 420 ? 10.0 : 16.0;

  double get sectionRadius => size(8).clamp(6.0, 10.0).toDouble();

  double get sectionPadding => size(12).clamp(10.0, 16.0).toDouble();

  double get sectionGap => size(10).clamp(8.0, 14.0).toDouble();

  double get dialogWidth {
    final maxWidth = (mediaSize.width - 16).clamp(280.0, 640.0).toDouble();
    return 600.0.clamp(280.0, maxWidth).toDouble();
  }

  double get dialogHeight {
    final maxHeight = (mediaSize.height - 96).clamp(360.0, 760.0).toDouble();
    return 680.0.clamp(360.0, maxHeight).toDouble();
  }

  double get baseOptionsWidth => dialogWidth;

  double get baseButtonMinWidth => size(78).clamp(68.0, 92.0).toDouble();

  double get sliderWidth => dialogWidth;

  double get sliderThumbPadding => size(8).clamp(6.0, 10.0).toDouble();

  double get modeButtonWidth => size(72).clamp(62.0, 88.0).toDouble();

  double get accentSwatchSize => size(30).clamp(28.0, 34.0).toDouble();

  double get accentDotSize => size(20).clamp(18.0, 24.0).toDouble();

  EdgeInsets edgeOnly({num left = 0, num top = 0, num right = 0, num bottom = 0}) =>
      EdgeInsets.only(left: size(left), top: size(top), right: size(right), bottom: size(bottom));

  SizedBox vGap(num value) => SizedBox(height: size(value));

  SizedBox hGap(num value) => SizedBox(width: size(value));
}

double _sliderPosition(double value, double min, double max) {
  if (max <= min) return 0;
  return ((value - min) / (max - min)).clamp(0.0, 1.0);
}

double _sliderValue(double position, double min, double max) {
  final raw = min + position.clamp(0.0, 1.0) * (max - min);
  return double.parse(raw.clamp(min, max).toStringAsFixed(3));
}

String _baseLabel(String id) => switch (id) {
  'slate' => '石板',
  'zinc' => '锌灰',
  'gray' => '灰色',
  'neutral' => '中性',
  'stone' => '石色',
  _ => id,
};

String _accentLabel(String id) => switch (id) {
  'base' => '默认',
  'slate' => '石板',
  'gray' => '灰色',
  'zinc' => '锌灰',
  'neutral' => '中性',
  'stone' => '石色',
  'red' => '红色',
  'orange' => '橙色',
  'amber' => '琥珀',
  'yellow' => '黄色',
  'lime' => '青柠',
  'green' => '绿色',
  'emerald' => '翠绿',
  'teal' => '蓝绿',
  'cyan' => '青色',
  'sky' => '天蓝',
  'blue' => '蓝色',
  'indigo' => '靛蓝',
  'violet' => '紫罗兰',
  'purple' => '紫色',
  'fuchsia' => '品红',
  'pink' => '粉色',
  'rose' => '玫瑰',
  _ => id,
};

String _densityLabel(String id) => switch (id) {
  'reduced' => '收紧',
  'default' => '默认',
  'spacious' => '宽松',
  _ => id,
};

String _modeLabel(shadcn.ThemeMode mode) => switch (mode) {
  shadcn.ThemeMode.light => '亮色',
  shadcn.ThemeMode.dark => '暗色',
  shadcn.ThemeMode.system => '自动',
};
