import 'package:flutter/material.dart';
import 'time_input_field.dart';

class MinuteSecondInput extends StatelessWidget {
  final String minutesLabel;
  final String secondsLabel;
  final TextEditingController minutesController;
  final TextEditingController secondsController;
  final ValueChanged<int>? onMinutesChanged;
  final ValueChanged<int>? onSecondsChanged;

  const MinuteSecondInput({
    super.key,
    this.minutesLabel = 'Minutos',
    this.secondsLabel = 'Segundos',
    required this.minutesController,
    required this.secondsController,
    this.onMinutesChanged,
    this.onSecondsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TimeInputField(
            label: minutesLabel,
            controller: minutesController,
            maxLength: 3,
            onChanged: (value) {
              if (onMinutesChanged != null) {
                onMinutesChanged!(int.tryParse(value) ?? 0);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TimeInputField(
            label: secondsLabel,
            controller: secondsController,
            maxValue: 59,
            onChanged: (value) {
              if (onSecondsChanged != null) {
                onSecondsChanged!(int.tryParse(value) ?? 0);
              }
            },
          ),
        ),
      ],
    );
  }
}