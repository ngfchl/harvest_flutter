import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';

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
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
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
  final List<TextInputFormatter> inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.inputFormatters = const [],
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 13, color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.white70),
        contentPadding: const EdgeInsets.all(0),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0x19000000)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0x16000000)),
        ),
      ),
    );
  }
}

class CustomPortField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const CustomPortField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final int value = int.parse(newValue.text);
            if (value < 1 || value > 65535) {
              return oldValue;
            }
            return newValue;
          } catch (e) {
            return oldValue;
          }
        }),
        LengthLimitingTextInputFormatter(5), // 限制长度为5位数字
      ],
    );
  }
}

class CustomPickerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final List<String> data;
  final Function(dynamic, int)? onConfirm;
  final Function(dynamic, int)? onChanged;

  const CustomPickerField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.data,
    this.onConfirm,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomTextField(
          controller: controller,
          labelText: labelText,
        ),
        Positioned.fill(
          child: InkWell(
            onTap: () {
              Pickers.showSinglePicker(
                context,
                data: data,
                selectData: controller.text,
                pickerStyle: PickerStyle(
                  textSize: 14,
                ),
                onConfirm: (p, position) {
                  controller.text = p;
                  onConfirm?.call(p, position);
                },
                onChanged: (p, position) {
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
