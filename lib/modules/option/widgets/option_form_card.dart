import 'package:flutter/material.dart' hide Switch, Theme;
import 'package:harvest/core/theme/app_surface.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/shad_text_field.dart';

import '../model/option_model.dart';

// ══════════════════════════════════════════════════════════
//  字段定义
// ══════════════════════════════════════════════════════════

class FormFieldDef {
  final String key;
  final String label;
  final String? Function(OptionValue?) getValue;
  final int maxLines;
  final String? helperText;

  const FormFieldDef(
    this.key,
    this.label,
    this.getValue, {
    this.maxLines = 1,
    this.helperText,
  });
}

class SwitchFieldDef {
  final String key;
  final String label;
  final bool Function(OptionValue?) getValue;

  const SwitchFieldDef(this.key, this.label, this.getValue);
}

// ══════════════════════════════════════════════════════════
//  表单配置
// ══════════════════════════════════════════════════════════

class FormConfig {
  final String title;
  final IconData? icon;
  final List<FormFieldDef> textFields;
  final List<SwitchFieldDef> switchFields;
  final Widget Function(Map<String, TextEditingController> ctrls)? extraBuilder;
  final OptionValue Function(
    Map<String, TextEditingController> ctrls,
    Map<String, bool> switches,
    OptionValue current,
  )
  buildValue;

  const FormConfig({
    required this.title,
    required this.textFields,
    required this.buildValue,
    this.icon,
    this.switchFields = const [],
    this.extraBuilder,
  });
}

// ══════════════════════════════════════════════════════════
//  通用选项表单卡片
// ══════════════════════════════════════════════════════════

BorderRadius _optionCardRadius(BuildContext context, {String size = 'md'}) {
  final theme = shadcn.Theme.of(context);
  return switch (size) {
    'xs' => theme.borderRadiusXs,
    'sm' => theme.borderRadiusSm,
    'lg' => theme.borderRadiusLg,
    'xl' => theme.borderRadiusXl,
    _ => theme.borderRadiusMd,
  };
}

class _ActionButtonFrame extends StatelessWidget {
  final Widget child;

  const _ActionButtonFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return SizedBox(width: double.infinity, child: child);
    }

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
        child: child,
      ),
    );
  }
}

class OptionFormCard extends StatefulWidget {
  final String title;
  final String optionName;
  final Option? option;
  final IconData? icon;
  final List<FormFieldDef> textFields;
  final List<SwitchFieldDef> switchFields;
  final Widget Function(Map<String, TextEditingController> ctrls)? extraBuilder;
  final OptionValue Function(
    Map<String, TextEditingController> ctrls,
    Map<String, bool> switches,
    OptionValue current,
  )
  buildValue;
  final Future<bool> Function(Option option) onSave;
  final Future<void> Function(Option option)? onToggleActive;
  final VoidCallback? onSaved;

  const OptionFormCard({
    super.key,
    required this.title,
    required this.optionName,
    required this.textFields,
    required this.buildValue,
    required this.onSave,
    this.option,
    this.icon,
    this.switchFields = const [],
    this.extraBuilder,
    this.onToggleActive,
    this.onSaved,
  });

  @override
  State<OptionFormCard> createState() => _OptionFormCardState();
}

class _OptionFormCardState extends State<OptionFormCard> {
  late final Map<String, TextEditingController> _ctrls;
  late final Map<String, bool> _switches;
  late bool _isActive;
  late bool _expanded;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.option?.value;
    _expanded = false;
    _isActive = widget.option?.isActive ?? true;
    _ctrls = {
      for (var f in widget.textFields)
        f.key: TextEditingController(text: f.getValue(v) ?? ''),
    };
    _switches = {for (var s in widget.switchFields) s.key: s.getValue(v)};
  }

  @override
  void dispose() {
    for (var c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typography = theme.typography;
    return AppSurfaceContainer(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: appSurfaceColor(context, cs.card),
      borderRadius: _optionCardRadius(context),
      child: ClipRRect(
        borderRadius: _optionCardRadius(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, cs, typography),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(height: 0.5, color: cs.border),
                        _buildBody(context, cs, typography),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    shadcn.ColorScheme cs,
    shadcn.Typography typography,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 18,
                color: cs.foreground.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                widget.title,
                style: typography.small.copyWith(
                  color: cs.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.option != null && widget.onToggleActive != null)
              GestureDetector(
                onTap: _handleToggleActive,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    _isActive
                        ? shadcn.LucideIcons.badgeCheck
                        : shadcn.LucideIcons.circleOff,
                    size: 18,
                    color: _isActive ? cs.primary : cs.destructive,
                  ),
                ),
              ),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                shadcn.LucideIcons.chevronDown,
                size: 20,
                color: cs.foreground.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    shadcn.ColorScheme cs,
    shadcn.Typography typography,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 文本字段 ──
          ...widget.textFields.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      f.label,
                      style: typography.xSmall.copyWith(
                        color: cs.mutedForeground,
                      ),
                    ),
                  ),
                  ShadTextField(
                    controller: _ctrls[f.key],
                    hintText: f.label,
                    maxLines: f.maxLines,
                    onSubmitted: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  if (f.helperText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        f.helperText!,
                        style: typography.xSmall.copyWith(
                          color: cs.mutedForeground.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // ── 开关 ──
          ...widget.switchFields.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.label,
                      style: typography.small.copyWith(color: cs.foreground),
                    ),
                  ),
                  shadcn.Switch(
                    value: _switches[s.key] ?? false,
                    onChanged: (v) => setState(() => _switches[s.key] = v),
                  ),
                ],
              ),
            ),
          ),
          // ── 额外组件 ──
          if (widget.extraBuilder != null) widget.extraBuilder!(_ctrls),
          // ── 保存按钮 ──
          const SizedBox(height: 6),
          _ActionButtonFrame(
            child: shadcn.Button.primary(
              onPressed: _saving ? null : _handleSave,
              alignment: Alignment.center,
              child: Center(
                child: _saving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: shadcn.CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primaryForeground,
                        ),
                      )
                    : const Text('保存', textAlign: TextAlign.center),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggleActive() async {
    if (widget.option == null || widget.onToggleActive == null) return;
    setState(() => _isActive = !_isActive);
    await widget.onToggleActive!(
      Option(
        id: widget.option!.id,
        name: widget.option!.name,
        value: widget.option!.value,
        isActive: _isActive,
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    try {
      final current = widget.option?.value ?? const OptionValue();
      final newValue = widget.buildValue(_ctrls, _switches, current);
      final option = Option(
        id: widget.option?.id,
        name: widget.optionName,
        value: newValue,
        isActive: _isActive,
      );
      final success = await widget.onSave(option);
      if (mounted) {
        setState(() => _saving = false);
        if (success) {
          Toast.success('保存成功');
          if (widget.option == null) {
            widget.onSaved?.call();
          } else {
            setState(() => _expanded = false);
          }
        } else {
          Toast.error('保存失败');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        Toast.error('保存失败: $e');
      }
    }
  }
}

// ══════════════════════════════════════════════════════════
//  通用可展开卡片（用于特殊表单）
// ══════════════════════════════════════════════════════════

class ExpandableCard extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget? leading;
  final Widget Function(VoidCallback collapse) builder;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.builder,
    this.icon,
    this.leading,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typography = theme.typography;
    return AppSurfaceContainer(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: appSurfaceColor(context, cs.card),
      borderRadius: _optionCardRadius(context),
      child: ClipRRect(
        borderRadius: _optionCardRadius(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 10),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 18,
                        color: cs.foreground.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        style: typography.small.copyWith(
                          color: cs.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        shadcn.LucideIcons.chevronDown,
                        size: 20,
                        color: cs.foreground.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(height: 0.5, color: cs.border),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: widget.builder(
                            () => setState(() => _expanded = false),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
