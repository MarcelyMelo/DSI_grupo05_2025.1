import 'package:flutter/material.dart';
import 'package:dsi_projeto/components/time_inputs/minute_second_input.dart';
import 'package:dsi_projeto/components/time_inputs/pomodoro_time_inputs.dart';

class CreateTimerScreen extends StatefulWidget {
  const CreateTimerScreen({super.key});

  @override
  State<CreateTimerScreen> createState() => _CreateTimerScreenState();
}

class _CreateTimerScreenState extends State<CreateTimerScreen> {
  final TextEditingController _timerNameController = TextEditingController();
  final TextEditingController _studyMinutesController = TextEditingController(text: '25');
  final TextEditingController _studySecondsController = TextEditingController(text: '0');
  final TextEditingController _breakMinutesController = TextEditingController(text: '5');
  final TextEditingController _breakSecondsController = TextEditingController(text: '0');
  final TextEditingController _intervalsController = TextEditingController(text: '4');
  final TextEditingController _minutesController = TextEditingController(text: '25');
  final TextEditingController _secondsController = TextEditingController(text: '0');

  bool _isPomodoro = false;

  @override
  void dispose() {
    _timerNameController.dispose();
    _studyMinutesController.dispose();
    _studySecondsController.dispose();
    _breakMinutesController.dispose();
    _breakSecondsController.dispose();
    _intervalsController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  bool _validateTimeInput(String minutes, String seconds) {
    final mins = int.tryParse(minutes) ?? 0;
    final secs = int.tryParse(seconds) ?? 0;

    if (mins < 0 || secs < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valores não podem ser negativos'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return false;
    }

    if (secs >= 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Segundos devem ser menores que 60'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return false;
    }

    if (mins == 0 && secs == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duração não pode ser zero'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return false;
    }

    return true;
  }

  void _saveTimer() {
    if (_isPomodoro) {
      if (!_validateTimeInput(_studyMinutesController.text, _studySecondsController.text)) {
        return;
      }

      final breakMinutes = int.tryParse(_breakMinutesController.text) ?? 5;
      final breakSeconds = int.tryParse(_breakSecondsController.text) ?? 0;

      if (!_validateTimeInput(breakMinutes.toString(), breakSeconds.toString())) {
        return;
      }

      final result = {
        'name': _timerNameController.text,
        'duration': (int.parse(_studyMinutesController.text) * 60) + int.parse(_studySecondsController.text),
        'isPomodoro': true,
        'studyDuration': (int.parse(_studyMinutesController.text) * 60) + int.parse(_studySecondsController.text),
        'breakDuration': (breakMinutes * 60) + breakSeconds,
        'intervals': int.tryParse(_intervalsController.text) ?? 4,
      };

      Navigator.pop(context, result);
    } else {
      if (!_validateTimeInput(_minutesController.text, _secondsController.text)) {
        return;
      }

      final result = {
        'name': _timerNameController.text,
        'duration': (int.parse(_minutesController.text) * 60) + int.parse(_secondsController.text),
        'isPomodoro': false,
      };

      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF34495E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Criar Cronômetro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: _saveTimer,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do Cronômetro
            const Text(
              'Nome do Cronômetro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF34495E),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _timerNameController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Digite o nome do cronômetro',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(
                    Icons.timer_outlined,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 30),

            // Modo Pomodoro
            const Text(
              'Modo Pomodoro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF34495E),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      _isPomodoro ? Icons.psychology : Icons.timer,
                      color: _isPomodoro ? const Color(0xFF3498DB) : Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPomodoro ? 'Pomodoro Ativo' : 'Cronômetro Simples',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isPomodoro 
                                ? 'Ciclos de foco e descanso'
                                : 'Contagem regressiva simples',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPomodoro,
                      onChanged: (value) {
                        setState(() {
                          _isPomodoro = value;
                        });
                      },
                      activeColor: const Color(0xFF3498DB),
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Configurações de Tempo
            if (_isPomodoro) ...[
              const Text(
                'Configurações Pomodoro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PomodoroTimeInputs(
                    studyMinutesController: _studyMinutesController,
                    studySecondsController: _studySecondsController,
                    breakMinutesController: _breakMinutesController,
                    breakSecondsController: _breakSecondsController,
                    intervalsController: _intervalsController,
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'Duração Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 254, 254, 255),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: MinuteSecondInput(
                    minutesController: _minutesController,
                    secondsController: _secondsController,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF27AE60).withOpacity(0.3),
                ),
                onPressed: _saveTimer,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Salvar Cronômetro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}