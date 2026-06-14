import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class ShadTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? label;
  final String? labelText;
  final String? helperText;
  final Widget? placeholder;
  final String? hintText;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final List<shadcn.InputFeature> features;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autoUnfocusOnSubmitted;

  const ShadTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.labelText,
    this.helperText,
    this.placeholder,
    this.hintText,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.style,
    this.decoration,
    this.padding,
    this.features = const [],
    this.validator,
    this.autovalidateMode,
    this.contextMenuBuilder,
    this.onChanged,
    this.onSubmitted,
    this.autoUnfocusOnSubmitted = true,
  });

  @override
  Widget build(BuildContext context) {
    if (validator != null) {
      return FormField<String>(
        initialValue: controller?.text ?? '',
        validator: validator,
        autovalidateMode: autovalidateMode,
        builder: (field) {
          return _withChrome(
            context,
            field: _field(
              context,
              onChangedOverride: (value) {
                field.didChange(value);
                onChanged?.call(value);
              },
            ),
            errorText: field.errorText,
          );
        },
      );
    }

    return _withChrome(context, field: _field(context));
  }

  Widget _withChrome(
    BuildContext context, {
    required Widget field,
    String? errorText,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final labelWidget =
        label ??
        (labelText == null
            ? null
            : Text(
                labelText!,
                style: theme.typography.small.copyWith(
                  color: cs.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ));

    if (labelWidget == null && helperText == null && errorText == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelWidget != null) ...[
          DefaultTextStyle.merge(
            style: theme.typography.small.copyWith(
              color: cs.foreground,
              fontWeight: FontWeight.w600,
            ),
            child: labelWidget,
          ),
          const SizedBox(height: 6),
        ],
        field,
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: 5),
          Text(
            helperText!,
            style: theme.typography.xSmall.copyWith(
              color: cs.mutedForeground.withValues(alpha: 0.86),
            ),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Text(
            errorText,
            style: theme.typography.xSmall.copyWith(color: cs.destructive),
          ),
        ],
      ],
    );
  }

  Widget _field(
    BuildContext context, {
    ValueChanged<String>? onChangedOverride,
  }) {
    return shadcn.TextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      hintText: hintText,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines ?? 1,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      style: style,
      decoration: decoration ?? _defaultDecoration(context),
      padding: padding,
      features: features,
      contextMenuBuilder:
          contextMenuBuilder ?? shadcn.TextField.defaultContextMenuBuilder,
      onChanged: onChangedOverride ?? onChanged,
      onSubmitted: (value) {
        onSubmitted?.call(value);
        if (autoUnfocusOnSubmitted) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
    );
  }

  BoxDecoration _defaultDecoration(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final baseColor = appSurfaceColor(context, cs.background);
    return BoxDecoration(
      color: enabled
          ? baseColor
          : Color.alphaBlend(
              cs.mutedForeground.withValues(alpha: 0.04),
              baseColor,
            ),
      borderRadius: BorderRadius.circular(theme.radiusMd),
      border: Border.all(
        color: enabled ? cs.input : cs.border.withValues(alpha: 0.65),
        width: 0.8,
      ),
    );
  }
}
