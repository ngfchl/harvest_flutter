import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../core/theme/theme_presets.dart';
import '../../../core/theme/theme_provider.dart';

void showThemeDialog(BuildContext context) {
  shadcn.showDialog(
    context: context,
    builder: (_) => const ThemeDialog(),
  );
}

class ThemeDialog extends ConsumerWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;

    return shadcn.AlertDialog(
      title: Text(
        '主题设置',
        style: theme.typography.large.copyWith(
          color: cs.foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
      padding: EdgeInsets.all(tokens.size(16)),
      trailing: shadcn.IconButton.ghost(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(shadcn.LucideIcons.x, size: tokens.iconMd),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.dialogWidth, maxHeight: tokens.dialogHeight),
        child: SizedBox(
          width: tokens.dialogWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(
                  context,
                  title: '明暗模式',
                  child: Wrap(
                    spacing: tokens.size(4),
                    runSpacing: tokens.size(8),
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      _modeButton(context, ref, shadcn.ThemeMode.light, shadcn.LucideIcons.sun, '亮色'),
                      _modeButton(context, ref, shadcn.ThemeMode.dark, shadcn.LucideIcons.moon, '暗色'),
                      _modeButton(context, ref, shadcn.ThemeMode.system, shadcn.LucideIcons.monitorCog, '自动'),
                    ],
                  ),
                ),
                _section(
                  context,
                  title: '基础色',
                  child: _idOptions(
                    context,
                    options: AppThemeOptions.baseSchemes,
                    selected: current.baseScheme,
                    labelBuilder: (option) => _baseLabel(option.id),
                    onSelected: notifier.setBaseScheme,
                  ),
                ),
                _section(
                  context,
                  title: '强调色',
                  child: Wrap(
                    spacing: tokens.size(10),
                    runSpacing: tokens.size(10),
                    children: [
                      for (final option in AppThemeOptions.accents)
                        _accentSwatch(
                          context,
                          label: _accentLabel(option.id),
                          color: option.value ??
                              AppThemeOptions.colorScheme(
                                current.baseScheme,
                                'base',
                                current.mode == shadcn.ThemeMode.dark,
                              ).primary,
                          selected: current.accent == option.id,
                          onTap: () => notifier.setAccent(option.id),
                        ),
                    ],
                  ),
                ),
                _section(
                  context,
                  title: '圆角',
                  child: _valueOptions<double>(
                    context,
                    options: AppThemeOptions.radiusOptions,
                    selected: current.radius,
                    labelBuilder: (option) => '${_radiusLabel(option.id)} ${option.value}',
                    onSelected: notifier.setRadius,
                  ),
                ),
                _section(
                  context,
                  title: '密度',
                  child: _idOptions(
                    context,
                    options: AppThemeOptions.densities,
                    selected: current.density,
                    labelBuilder: (option) => _densityLabel(option.id),
                    onSelected: notifier.setDensity,
                  ),
                ),
                _section(
                  context,
                  title: '缩放',
                  child: _valueOptions<double>(
                    context,
                    options: AppThemeOptions.scalingOptions,
                    selected: current.scaling,
                    labelBuilder: (option) => '${_scalingLabel(option.id)} ${option.value}',
                    onSelected: notifier.setScaling,
                  ),
                ),
                _section(
                  context,
                  title: '表面透明度',
                  child: _valueOptions<double>(
                    context,
                    options: AppThemeOptions.surfaceOpacityOptions,
                    selected: current.surfaceOpacity,
                    labelBuilder: (option) => '${_surfaceOpacityLabel(option.id)} ${option.value}',
                    onSelected: notifier.setSurfaceOpacity,
                  ),
                ),
                _section(
                  context,
                  title: '表面模糊',
                  child: _valueOptions<double>(
                    context,
                    options: AppThemeOptions.surfaceBlurOptions,
                    selected: current.surfaceBlur,
                    labelBuilder: (option) => '${_surfaceBlurLabel(option.id)} ${option.value}',
                    onSelected: notifier.setSurfaceBlur,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        shadcn.Button.outline(
          onPressed: notifier.reset,
          child: const Text('恢复默认'),
        ),
        shadcn.Button.primary(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return Padding(
      padding: tokens.edgeOnly(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.small.copyWith(
              color: cs.mutedForeground,
              fontWeight: FontWeight.w800,
            ),
          ),
          tokens.vGap(8),
          child,
        ],
      ),
    );
  }

  Widget _idOptions<T>(
    BuildContext context, {
    required List<AppThemeOption<T>> options,
    required String selected,
    required String Function(AppThemeOption<T> option) labelBuilder,
    required ValueChanged<String> onSelected,
  }) {
    final tokens = _ThemeDialogTokens.of(context);
    return Wrap(
      spacing: tokens.size(2),
      runSpacing: tokens.size(8),
      children: [
        for (final option in options)
          _optionChip(
            context,
            label: labelBuilder(option),
            selected: selected == option.id,
            onTap: () => onSelected(option.id),
          ),
      ],
    );
  }

  Widget _valueOptions<T>(
    BuildContext context, {
    required List<AppThemeOption<T>> options,
    required T selected,
    required String Function(AppThemeOption<T> option) labelBuilder,
    required ValueChanged<T> onSelected,
  }) {
    final tokens = _ThemeDialogTokens.of(context);
    return Wrap(
      spacing: tokens.size(8),
      runSpacing: tokens.size(8),
      children: [
        for (final option in options)
          _optionChip(
            context,
            label: labelBuilder(option),
            selected: selected == option.value,
            onTap: () => onSelected(option.value),
          ),
      ],
    );
  }

  Widget _optionChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return shadcn.Button(
      onPressed: onTap,
      style: selected ? shadcn.ButtonVariance.primary : shadcn.ButtonVariance.secondary,
      child: Text(label, style: theme.typography.xSmall.copyWith(color: selected ? cs.primaryForeground : cs.foreground, fontWeight: FontWeight.w700)),
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
    return shadcn.Tooltip(
      tooltip: (_) => Text(label),
      child: shadcn.IconButton.outline(
        onPressed: onTap,
        icon: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? cs.foreground : cs.border,
              width: selected ? tokens.size(2) : tokens.hairline,
            ),
          ),
          child: SizedBox.square(dimension: tokens.size(16)),
        ),
      ),
    );
  }

  Widget _modeButton(
    BuildContext context,
    WidgetRef ref,
    shadcn.ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final current = ref.watch(themeNotifierProvider);
    final selected = current.mode == mode;
    return shadcn.Button(
      onPressed: () => ref.read(themeNotifierProvider.notifier).setMode(mode),
      style: selected ? shadcn.ButtonVariance.primary : shadcn.ButtonVariance.secondary,
      leading: Icon(icon),
      child: Text(label),
    );
  }
}

class _ThemeDialogTokens {
  final shadcn.ThemeData theme;
  final shadcn.ColorScheme cs;
  final double densityScale;
  final double textScale;

  _ThemeDialogTokens._({
    required this.theme,
    required this.cs,
    required this.densityScale,
    required this.textScale,
  });

  factory _ThemeDialogTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityScale = ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(0.55, 1.45);
    final textScale = theme.scaling.clamp(0.86, 1.30);
    return _ThemeDialogTokens._(
      theme: theme,
      cs: theme.colorScheme,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  double get hairline => size(0.5).clamp(0.5, 1.0);

  double get iconMd => font(16);

  double get dialogWidth => size(560).clamp(320.0, 640.0);

  double get dialogHeight => size(620).clamp(420.0, 760.0);

  EdgeInsets edgeOnly({num left = 0, num top = 0, num right = 0, num bottom = 0}) => EdgeInsets.only(
        left: size(left),
        top: size(top),
        right: size(right),
        bottom: size(bottom),
      );

  SizedBox vGap(num value) => SizedBox(height: size(value));
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

String _radiusLabel(String id) => switch (id) {
      'sharp' => '直角',
      'subtle' => '轻微',
      'default' => '默认',
      'rounded' => '圆润',
      'pill' => '胶囊',
      _ => id,
    };

String _densityLabel(String id) => switch (id) {
      'compact' => '紧凑',
      'reduced' => '收紧',
      'default' => '默认',
      'spacious' => '宽松',
      _ => id,
    };

String _scalingLabel(String id) => switch (id) {
      'compact' => '紧凑',
      'default' => '默认',
      'large' => '放大',
      _ => id,
    };

String _surfaceOpacityLabel(String id) => switch (id) {
      'solid' => '实色',
      'frosted' => '磨砂',
      'translucent' => '半透明',
      'ghosted' => '轻透',
      _ => id,
    };

String _surfaceBlurLabel(String id) => switch (id) {
      'none' => '无',
      'soft' => '柔和',
      'medium' => '中等',
      'strong' => '强烈',
      _ => id,
    };
