import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';
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
        child: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
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

class CustomPickerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final List<String> data;
  final bool readOnly;
  final Function(dynamic, int)? onConfirm;
  final Function(dynamic, int)? onChanged;

  const CustomPickerField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.data,
    this.onConfirm,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isNotEmpty && controller.text.isEmpty) controller.text = data[0];
    return Stack(
      children: [
        CustomTextField(
          controller: controller,
          labelText: labelText,
          readOnly: readOnly,
        ),
        if (!readOnly)
          Positioned.fill(
            child: InkWell(
              onTap: () {
                Pickers.showSinglePicker(
                  context,
                  data: data,
                  selectData: controller.text,
                  pickerStyle: PickerStyle(
                    showTitleBar: true,
                    textSize: 14,
                    textColor: ShadTheme.of(context).colorScheme.foreground,
                    backgroundColor: ShadTheme.of(context).colorScheme.background,
                    headDecoration: BoxDecoration(color: ShadTheme.of(context).colorScheme.background),
                  ),
                  onConfirm: (p, position) {
                    controller.text = p;
                    onConfirm?.call(p, position);
                  },
                  onChanged: (p, position) {
                    controller.text = p;
                    onChanged?.call(p, position);
                  },
                );
              },
              child: Container(), // 空的容器占据整个触发 InkWell 的 onTap
            ),
          ),
      ],
    );
  }
}

class FullWidthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? labelColor;

  const FullWidthButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor, // 默认颜色为蓝色
    this.labelColor, // 默认颜色为蓝色
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // 圆角半径
              ),
              backgroundColor: backgroundColor ?? Colors.orange,
            ),
            child: Text(
              text,
              style: TextStyle(color: labelColor ?? Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}
