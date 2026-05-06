import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

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
    for (var c in _ctrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(cs),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(height: 0.5, color: cs.border),
                        _buildBody(cs),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FColors cs) {
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
                color: cs.foreground.withOpacity(0.6),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.option != null && widget.onToggleActive != null)
              GestureDetector(
                onTap: _handleToggleActive,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    _isActive ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: _isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: cs.foreground.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(FColors cs) {
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
                      style: TextStyle(
                        color: cs.foreground.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  FTextField(
                    controller: _ctrls[f.key],
                    hint: f.label,
                    maxLines: f.maxLines,
                  ),
                  if (f.helperText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        f.helperText!,
                        style: TextStyle(
                          color: cs.foreground.withOpacity(0.35),
                          fontSize: 11,
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
                      style: TextStyle(color: cs.foreground, fontSize: 13),
                    ),
                  ),
                  FSwitch(
                    value: _switches[s.key] ?? false,
                    onChange: (v) => setState(() => _switches[s.key] = v),
                  ),
                ],
              ),
            ),
          ),
          // ── 额外组件 ──
          if (widget.extraBuilder != null) widget.extraBuilder!(_ctrls),
          // ── 保存按钮 ──
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FButton(
              onPress: _saving ? null : _handleSave,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('保存'),
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
                        color: cs.foreground.withOpacity(0.6),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: cs.foreground,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: cs.foreground.withOpacity(0.4),
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
