import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../core/theme/theme_presets.dart';
import '../../../core/theme/theme_provider.dart';

void showThemeDialog(BuildContext context) {
  shadcn.showDialog(context: context, builder: (_) => const ThemeDialog());
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
      padding: EdgeInsets.symmetric(horizontal: tokens.panelHorizontalPadding, vertical: tokens.panelVerticalPadding),
      content: SizedBox(
        width: tokens.dialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: tokens.dialogHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: tokens.closeSlotSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '主题设置',
                      textAlign: TextAlign.center,
                      style: theme.typography.large.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
                    ),
                    Positioned(
                      right: 0,
                      child: shadcn.IconButton.ghost(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(shadcn.LucideIcons.x, size: tokens.iconMd),
                      ),
                    ),
                  ],
                ),
              ),
              tokens.vGap(8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                    _section(
                      context,
                      title: '明暗模式',
                      child: Wrap(
                        spacing: tokens.size(6),
                        runSpacing: tokens.size(6),
                        alignment: WrapAlignment.center,
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
                      child: _baseOptions(context, selected: current.baseScheme, onSelected: notifier.setBaseScheme),
                    ),
                    _section(
                      context,
                      title: '强调色',
                      child: Wrap(
                        spacing: tokens.size(6),
                        runSpacing: tokens.size(8),
                        alignment: WrapAlignment.center,
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
                      child: _themeSlider(
                        context,
                        value: current.radius,
                        min: 0,
                        max: 1.5,
                        display: current.radius.toStringAsFixed(2),
                        onChanged: notifier.setRadius,
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
                      child: _themeSlider(
                        context,
                        value: current.scaling,
                        min: 0.85,
                        max: 1.15,
                        display: current.scaling.toStringAsFixed(2),
                        onChanged: notifier.setScaling,
                      ),
                    ),
                    _section(
                      context,
                      title: '表面透明度',
                      child: _themeSlider(
                        context,
                        value: current.surfaceOpacity,
                        min: 0.7,
                        max: 1.0,
                        display: current.surfaceOpacity.toStringAsFixed(2),
                        onChanged: notifier.setSurfaceOpacity,
                      ),
                    ),
                    _section(
                      context,
                      title: '表面模糊',
                      child: _themeSlider(
                        context,
                        value: current.surfaceBlur,
                        min: 0,
                        max: 12,
                        display: current.surfaceBlur.toStringAsFixed(1),
                        onChanged: notifier.setSurfaceBlur,
                      ),
                    ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: shadcn.Button.outline(
                      onPressed: notifier.reset,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, {required String title, required Widget child}) {
    final tokens = _ThemeDialogTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    return Padding(
      padding: tokens.edgeOnly(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.typography.small.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w800),
            ),
            tokens.vGap(8),
            Center(child: child),
          ],
        ),
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
      spacing: tokens.size(6),
      runSpacing: tokens.size(6),
      alignment: WrapAlignment.center,
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

  Widget _baseOptions(BuildContext context, {required String selected, required ValueChanged<String> onSelected}) {
    final tokens = _ThemeDialogTokens.of(context);
    final options = AppThemeOptions.baseSchemes;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tokens.baseOptionsWidth),
      child: Wrap(
        spacing: tokens.size(6),
        runSpacing: tokens.size(8),
        alignment: WrapAlignment.center,
        children: [
          for (final option in options)
            SizedBox(
              width: tokens.baseButtonWidth,
              child: _baseSchemeButton(
                context,
                option: option,
                selected: selected == option.id,
                onTap: () => onSelected(option.id),
              ),
            ),
        ],
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
    final color = AppThemeOptions.colorScheme(option.id, 'base', cs.brightness == Brightness.dark).primary;
    final background = selected ? color : cs.secondary;
    final foreground = selected
        ? ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black
        : cs.foreground;
    return shadcn.Tooltip(
      tooltip: (_) => Text(_baseLabel(option.id)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: tokens.size(32),
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: tokens.size(6)),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(tokens.theme.radiusSm),
            border: Border.all(
              color: selected ? color : cs.border.withValues(alpha: 0.75),
              width: tokens.hairline,
            ),
          ),
          child: Text(
            _baseLabel(option.id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tokens.theme.typography.xSmall.copyWith(color: foreground, fontWeight: FontWeight.w800),
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
            width: tokens.size(46),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: tokens.size(6), vertical: tokens.size(3)),
            decoration: BoxDecoration(
              color: cs.secondary,
              borderRadius: BorderRadius.circular(theme.radiusSm),
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
      style: selected
          ? const shadcn.ButtonStyle.primary(size: shadcn.ButtonSize.small, density: shadcn.ButtonDensity.dense)
          : const shadcn.ButtonStyle.secondary(size: shadcn.ButtonSize.small, density: shadcn.ButtonDensity.dense),
      child: Text(
        label,
        style: theme.typography.xSmall.copyWith(
          color: selected ? cs.primaryForeground : cs.foreground,
          fontWeight: FontWeight.w700,
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
    return shadcn.Tooltip(
      tooltip: (_) => Text(label),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: tokens.size(28),
          height: tokens.size(28),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? cs.foreground : cs.border,
              width: selected ? tokens.size(2) : tokens.hairline,
            ),
          ),
          child: Container(
            width: tokens.size(18),
            height: tokens.size(18),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _modeButton(BuildContext context, WidgetRef ref, shadcn.ThemeMode mode, IconData icon, String label) {
    final tokens = _ThemeDialogTokens.of(context);
    final current = ref.watch(themeNotifierProvider);
    final selected = current.mode == mode;
    return shadcn.Button(
      onPressed: () => ref.read(themeNotifierProvider.notifier).setMode(mode),
      style: selected
          ? const shadcn.ButtonStyle.primary(size: shadcn.ButtonSize.small, density: shadcn.ButtonDensity.dense)
          : const shadcn.ButtonStyle.secondary(size: shadcn.ButtonSize.small, density: shadcn.ButtonDensity.dense),
      leading: Icon(icon, size: tokens.iconSm),
      child: Text(label, style: tokens.theme.typography.xSmall.copyWith(fontWeight: FontWeight.w700)),
    );
  }
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

  double get iconMd => font(16);

  double get iconSm => font(13);

  double get closeSlotSize => size(32);

  double get panelHorizontalPadding => 16.0;

  double get panelVerticalPadding => mediaSize.width < 420 ? 10.0 : 16.0;

  double get dialogWidth {
    final maxWidth = (mediaSize.width - 16).clamp(280.0, 640.0).toDouble();
    return 560.0.clamp(280.0, maxWidth).toDouble();
  }

  double get dialogHeight {
    final maxHeight = (mediaSize.height - 96).clamp(360.0, 760.0).toDouble();
    return 620.0.clamp(360.0, maxHeight).toDouble();
  }

  double get baseOptionsWidth => dialogWidth;

  double get baseButtonWidth => 78.0.clamp(64.0, 96.0).toDouble();

  double get sliderWidth => dialogWidth;

  double get sliderThumbPadding => size(8).clamp(6.0, 10.0).toDouble();

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
