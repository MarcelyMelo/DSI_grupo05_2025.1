import 'package:flutter/material.dart';
import 'time_input_field.dart';  // Adicione esta linha
import 'minute_second_input.dart';
class PomodoroTimeInputs extends StatelessWidget {
  final TextEditingController studyMinutesController;
  final TextEditingController studySecondsController;
  final TextEditingController breakMinutesController;
  final TextEditingController breakSecondsController;
  final TextEditingController intervalsController;
  final ValueChanged<int>? onStudyMinutesChanged;
  final ValueChanged<int>? onStudySecondsChanged;
  final ValueChanged<int>? onBreakMinutesChanged;
  final ValueChanged<int>? onBreakSecondsChanged;
  final ValueChanged<int>? onIntervalsChanged;

  const PomodoroTimeInputs({
    super.key,
    required this.studyMinutesController,
    required this.studySecondsController,
    required this.breakMinutesController,
    required this.breakSecondsController,
    required this.intervalsController,
    this.onStudyMinutesChanged,
    this.onStudySecondsChanged,
    this.onBreakMinutesChanged,
    this.onBreakSecondsChanged,
    this.onIntervalsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tempo de Foco:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        MinuteSecondInput(
          minutesController: studyMinutesController,
          secondsController: studySecondsController,
          onMinutesChanged: onStudyMinutesChanged,
          onSecondsChanged: onStudySecondsChanged,
        ),
        const SizedBox(height: 16),
        const Text('Tempo de Descanso:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        MinuteSecondInput(
          minutesController: breakMinutesController,
          secondsController: breakSecondsController,
          onMinutesChanged: onBreakMinutesChanged,
          onSecondsChanged: onBreakSecondsChanged,
        ),
        const SizedBox(height: 16),
        const Text('Quantidade de Intervalos:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TimeInputField(
          label: 'Intervalos',
          controller: intervalsController,
          maxLength: 2,
          onChanged: (value) {
            if (onIntervalsChanged != null) {
              onIntervalsChanged!(int.tryParse(value) ?? 4);
            }
          },
        ),
      ],
    );
  }
}