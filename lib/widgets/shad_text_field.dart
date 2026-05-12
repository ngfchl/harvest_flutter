import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class ShadTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
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
  final List<shadcn.InputFeature> features;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autoUnfocusOnSubmitted;

  const ShadTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.hintText,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.style,
    this.features = const [],
    this.onChanged,
    this.onSubmitted,
    this.autoUnfocusOnSubmitted = true,
  });

  @override
  Widget build(BuildContext context) {
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
      features: features,
      onChanged: onChanged,
      onSubmitted: (value) {
        onSubmitted?.call(value);
        if (autoUnfocusOnSubmitted) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
    );
  }
}
