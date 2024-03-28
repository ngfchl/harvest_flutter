import 'package:flutter/services.dart';

class RangeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      double parsedValue = double.parse(newValue.text);
      if (parsedValue >= min && parsedValue <= max) {
        return newValue;
      }
    } catch (e) {
      // Do nothing if the input can't be parsed to a double
    }

    // If the input is outside the valid range, return the old value
    return oldValue;
  }
}
