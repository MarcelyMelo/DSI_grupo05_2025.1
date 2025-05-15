import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLength;
  final int? maxValue;
  final ValueChanged<String>? onChanged;

  const TimeInputField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLength = 2,
    this.maxValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onChanged: (value) {
        if (maxValue != null && value.isNotEmpty) {
          final intValue = int.tryParse(value) ?? 0;
          if (intValue > maxValue!) {
            controller.text = maxValue.toString();
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          }
        }
        if (onChanged != null) {
          onChanged!(value);
        }
      },
    );
  }
}