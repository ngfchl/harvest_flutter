import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final double size;
  final double fontSize;
  final double subtitleFontSize;
  final double? scale;
  final Widget? leading;
  final Widget? label;
  final EdgeInsetsGeometry? contentPadding;
  final void Function(bool)? onChanged;

  const SwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.size = 32,
    this.fontSize = 14,
    this.subtitleFontSize = 8,
    this.scale = 0.75,
    this.leading,
    this.label,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          color: ShadTheme.of(context).colorScheme.foreground,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            )
          : null,
      leading: leading,
      contentPadding: contentPadding,
      trailing: Transform.scale(
        scale: scale,
        child: ShadSwitch(
          value: value,
          onChanged: onChanged,
          label: label,
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode; // ✅ 新增
  final String? labelText;
  final String? hintText;
  final String? prefixText;
  final Widget? prefixIcon;
  final String? suffixText;
  final Widget? suffixIcon;
  final Widget? suffix;
  final Widget? prefix;
  final String? helperText;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final bool readOnly;
  final bool obscureText;
  final ScrollPhysics? scrollPhysics;
  final BoxConstraints? constraints;
  final Function(String)? onChanged;
  final Function()? onTap;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? helperStyle;
  final TextStyle? prefixStyle;
  final TextStyle? suffixStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.focusNode,
    this.inputFormatters = const [],
    this.maxLines = 1,
    this.keyboardType,
    this.helperText,
    this.hintText,
    this.prefixText,
    this.prefixIcon,
    this.suffixText,
    this.suffixIcon,
    this.suffix,
    this.prefix,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.validator,
    this.maxLength,
    this.constraints,
    this.textStyle,
    this.labelStyle,
    this.helperStyle,
    this.prefixStyle,
    this.suffixStyle,
    this.hintStyle,
    this.contentPadding,
    this.scrollPhysics = const NeverScrollableScrollPhysics(),
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    var scheme = ShadTheme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: TextFormField(
        autofocus: autofocus,
        controller: controller,
        focusNode: focusNode,
        // ✅ 必须加上
        onChanged: onChanged,
        maxLength: maxLength,
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        maxLines: maxLines,
        readOnly: readOnly,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        scrollPhysics: scrollPhysics,
        style: textStyle ?? TextStyle(fontSize: 15, color: scheme.foreground),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: labelStyle ?? TextStyle(fontSize: 12, color: scheme.foreground),
          contentPadding: contentPadding??const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.foreground.withOpacity(0.2)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.foreground.withOpacity(0.5)),
          ),
          constraints: constraints,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          fillColor: Colors.transparent,
          helperText: helperText,
          prefixText: prefixText,
          prefixIcon: prefixIcon,
          helperMaxLines: 3,
          suffixText: suffixText,
          suffixIcon: suffixIcon,
          hintText: hintText,
          suffix: suffix,
          prefix: prefix,
          helperStyle: helperStyle ?? TextStyle(fontSize: 12, color: scheme.foreground),
          prefixStyle: prefixStyle ?? TextStyle(fontSize: 12, color: scheme.foreground),
          suffixStyle: suffixStyle ?? TextStyle(fontSize: 12, color: scheme.foreground),
          hintStyle: hintStyle ?? TextStyle(fontSize: 12, color: scheme.foreground),
        ),
      ),
    );
  }
}

class CustomPortField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool readOnly;

  const CustomPortField({
    super.key,
    required this.controller,
    required this.labelText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      readOnly: readOnly,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final int value = int.parse(newValue.text);
            if (value < 0 || value > 65535 && newValue.text.isNotEmpty) {
              return oldValue;
            }
          } catch (e) {
            if (newValue.text.isNotEmpty) {
              return oldValue;
            }
          }
          return newValue;
        }),
        LengthLimitingTextInputFormatter(5), // 限制长度为5位数字
      ],
    );
  }
}

class CustomNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool readOnly;

  const CustomNumberField({
    super.key,
    required this.controller,
    required this.labelText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}
