import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final double size;
  final void Function(bool)? onChanged;

  const SwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: ShadTheme.of(context).colorScheme.foreground,
        ),
      ),
      trailing: Transform.scale(
        scale: 0.5,
        child: ShadSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode; // ✅ 新增
  final String labelText;
  final String? prefixText;
  final Widget? prefixIcon;
  final String? suffixText;
  final Widget? suffixIcon;
  final String? helperText;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final bool readOnly;
  final bool obscureText;
  final Function(String)? onChanged;
  final Function()? onTap;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.focusNode, // ✅ 新增
    this.inputFormatters = const [],
    this.maxLines = 1,
    this.keyboardType,
    this.helperText,
    this.prefixText,
    this.prefixIcon,
    this.suffixText,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.validator,
    this.maxLength,
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
        validator: validator,
        maxLines: maxLines,
        readOnly: readOnly,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        style: TextStyle(fontSize: 13, color: scheme.foreground),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 12, color: scheme.foreground),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0x19000000)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0x16000000)),
          ),
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          fillColor: Colors.transparent,
          helperText: helperText,
          prefixText: prefixText,
          prefixIcon: prefixIcon,
          suffixText: suffixText,
          suffixIcon: suffixIcon,
          helperStyle: TextStyle(fontSize: 12, color: scheme.foreground),
          prefixStyle: TextStyle(fontSize: 12, color: scheme.foreground),
          suffixStyle: TextStyle(fontSize: 12, color: scheme.foreground),
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
