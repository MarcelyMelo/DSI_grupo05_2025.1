import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dsi_projeto/components/colors/appColors.dart';

class EditTimerScreen extends StatefulWidget {
  final String currentName;
  final bool isPomodoro;
  final int currentStudyMinutes;
  final int currentStudySeconds;
  final int currentBreakMinutes;
  final int currentBreakSeconds;
  final int currentIntervals;

  const EditTimerScreen({
    super.key,
    required this.currentName,
    required this.isPomodoro,
    required this.currentStudyMinutes,
    required this.currentStudySeconds,
    required this.currentBreakMinutes,
    required this.currentBreakSeconds,
    required this.currentIntervals,
  });

  @override
  State<EditTimerScreen> createState() => _EditTimerScreenState();
}

class _EditTimerScreenState extends State<EditTimerScreen> {
  late TextEditingController _nameController;
  late TextEditingController _studyMinutesController;
  late TextEditingController _studySecondsController;
  late TextEditingController _breakMinutesController;
  late TextEditingController _breakSecondsController;
  late TextEditingController _intervalsController;
  late bool _isPomodoro;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _studyMinutesController = TextEditingController(text: widget.currentStudyMinutes.toString());
    _studySecondsController = TextEditingController(text: widget.currentStudySeconds.toString());
    _breakMinutesController = TextEditingController(text: widget.currentBreakMinutes.toString());
    _breakSecondsController = TextEditingController(text: widget.currentBreakSeconds.toString());
    _intervalsController = TextEditingController(text: widget.currentIntervals.toString());
    _isPomodoro = widget.isPomodoro;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studyMinutesController.dispose();
    _studySecondsController.dispose();
    _breakMinutesController.dispose();
    _breakSecondsController.dispose();
    _intervalsController.dispose();
    super.dispose();
  }

    bool _validateInputs() {
  // Validação do nome
  if (_nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Digite um nome para o cronômetro')));
    return false;
  }

  // Validação dos tempos
  final studyMins = int.tryParse(_studyMinutesController.text) ?? 0;
  final studySecs = int.tryParse(_studySecondsController.text) ?? 0;
  
  if (studyMins < 0 || studySecs < 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Valores não podem ser negativos')));
    return false;
  }
  
  if (studySecs >= 60) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Segundos devem ser menores que 60')));
    return false;
  }
  
  if (studyMins == 0 && studySecs == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duração não pode ser zero')));
    return false;
  }

  if (_isPomodoro) {
    final breakMins = int.tryParse(_breakMinutesController.text) ?? 0;
    final breakSecs = int.tryParse(_breakSecondsController.text) ?? 0;
    final intervals = int.tryParse(_intervalsController.text) ?? 0;

    if (breakMins < 0 || breakSecs < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valores de descanso não podem ser negativos')));
      return false;
    }
    
    if (breakSecs >= 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Segundos de descanso devem ser menores que 60')));
      return false;
    }
    
    if (intervals <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deve haver pelo menos 1 intervalo')));
      return false;
    }
  }

  return true;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        title: const Text('Editar Cronômetro', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () {
              if (_validateInputs()) {
                Navigator.pop(context, {
                  'name': _nameController.text,
                  'isPomodoro': _isPomodoro,
                  'studyMinutes': int.parse(_studyMinutesController.text),
                  'studySeconds': int.parse(_studySecondsController.text),
                  'breakMinutes': int.parse(_breakMinutesController.text),
                  'breakSeconds': int.parse(_breakSecondsController.text),
                  'intervals': int.parse(_intervalsController.text),
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Cronômetro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Modo Pomodoro'),
              value: _isPomodoro,
              onChanged: (value) => setState(() => _isPomodoro = value),
            ),
            if (_isPomodoro) ...[
              const SizedBox(height: 20),
              const Text('Tempo de Foco:', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _studyMinutesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Minutos',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _studySecondsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Segundos',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Tempo de Descanso:', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _breakMinutesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Minutos',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _breakSecondsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Segundos',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _intervalsController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: const InputDecoration(
                  labelText: 'Quantidade de Intervalos',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              const Text('Duração Total:', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _studyMinutesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Minutos',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _studySecondsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Segundos',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}