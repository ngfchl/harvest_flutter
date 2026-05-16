import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'shad_text_field.dart';

class AppTextField extends StatelessWidget {
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
  final TextStyle? style;
  final List<shadcn.InputFeature>? features;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autoUnfocusOnSubmitted;

  const AppTextField({
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
    this.style,
    this.features,
    this.onChanged,
    this.onSubmitted,
    this.autoUnfocusOnSubmitted = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShadTextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      hintText: hintText,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: style,
      features: features ?? [],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autoUnfocusOnSubmitted: autoUnfocusOnSubmitted,
    );
  }
}
