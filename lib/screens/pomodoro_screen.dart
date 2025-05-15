import 'package:flutter/material.dart';
import 'package:dsi_projeto/components/colors/appColors.dart';
import 'dart:async'; // Adicione esta linha
import 'package:flutter/services.dart';
import 'package:dsi_projeto/screens/edit_timer_screen.dart';
import 'package:flutter/material.dart';
import 'package:dsi_projeto/components/time_inputs/time_input_field.dart';
import 'package:dsi_projeto/components/time_inputs/minute_second_input.dart';
import 'package:dsi_projeto/components/time_inputs/pomodoro_time_inputs.dart';
class TimerModel {
  final String name;
  int duration;
  bool isRunning;
  Timer? timer;
  final bool isPomodoro;
  final int studyDuration;
  final int breakDuration;
  final int intervals;
  int completedIntervals;
  bool isStudyPhase;

  TimerModel({
    required this.name,
    required this.duration,
    this.isRunning = false,
    this.timer,
    this.isPomodoro = false,
    this.studyDuration = 25 * 60,
    this.breakDuration = 5 * 60,
    this.intervals = 4,
    this.completedIntervals = 0,
    this.isStudyPhase = true,
  });

  void start(void Function() onTick) {
    timer?.cancel();
    isRunning = true;
    timer = Timer.periodic(const Duration(seconds: 1), (_) => onTick());
  }

  void stop() {
    timer?.cancel();
    isRunning = false;
  }

  void reset() {
    stop();
    duration = isPomodoro ? studyDuration : duration;
    isStudyPhase = true;
    completedIntervals = 0;
  }

  void dispose() {
    timer?.cancel();
  }
}
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final List<TimerModel> _timers = [];
  final TextEditingController _timerNameController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController(text: '25');
  final TextEditingController _secondsController = TextEditingController(text: '0');
// Não esqueça de limpar no método dispose
@override
void dispose() {
  for (var timer in _timers) {
    timer.timer?.cancel();
  }
  _timerNameController.dispose();
  _minutesController.dispose();
  _secondsController.dispose();
  super.dispose();
}
bool _validateTimeInput(String minutes, String seconds) {
  final mins = int.tryParse(minutes) ?? 0;
  final secs = int.tryParse(seconds) ?? 0;
  

  
  if (mins < 0 || secs < 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Valores não podem ser negativos')));
    return false;
  }
  
  if (secs >= 60) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Segundos devem ser menores que 60')));
    return false;
  }
  
  if (mins == 0 && secs == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duração não pode ser zero')));
    return false;
  }

  
  
  return true;
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1C1E),
        title: const Text("Adicionar cronômetro", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
            onPressed: () => _showAddTimerDialog(context),
          ),
        ],
        elevation: 4,
      ),
      body: Container(
        color: Colors.grey[100],
        child: _timers.isEmpty
            ? const Center(
                child: Text(
                  'Nenhum cronômetro adicionado',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _timers.length,
                itemBuilder: (context, index) {
                  return _buildTimerCard(_timers[index], index);
                },
              ),
      ),
    );
  }


Widget _buildTimerCard(TimerModel timer, int index) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( // Adiciona um Row aqui
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded( // Expanded agora está dentro de uma Row, corretamente
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timer.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (timer.isPomodoro) ...[
                      const SizedBox(height: 4),
                      Text(
                        timer.isStudyPhase ? '⏳ Fase: Foco' : '☕ Fase: Descanso',
                        style: TextStyle(
                          color: timer.isStudyPhase ? Colors.green : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Intervalos: ${timer.completedIntervals}/${timer.intervals}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 24),
                onPressed: () => _editTimer(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                onPressed: () => _removeTimer(index),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Tempo: ${_formatDuration(timer.duration)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: timer.isRunning ? Colors.green : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botão Iniciar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: timer.isRunning ? Colors.grey : Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: timer.isRunning ? null : () => _startTimer(index),
                child: const Text('Iniciar', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              
              // Botão Parar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: timer.isRunning ? Colors.red : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: timer.isRunning ? () => _stopTimer(index) : null,
                child: const Text('Parar', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              
              // Novo Botão Reiniciar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: !timer.isRunning ? Colors.orange : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: !timer.isRunning ? () => _resetTimer(index) : null,
                child: const Text('Reiniciar', style: TextStyle(color: Colors.white)),
              ),
        

            ],
          ),
        ],
      ),
    ),
  );
}

String _formatDuration(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

void _showAddTimerDialog(BuildContext context) {
  bool isPomodoro = false;
  final studyMinutesController = TextEditingController(text: '25');
  final studySecondsController = TextEditingController(text: '0');
  final breakMinutesController = TextEditingController(text: '5');
  final breakSecondsController = TextEditingController(text: '0');
  final intervalsController = TextEditingController(text: '4');
  final minutesController = TextEditingController(text: '25');
  final secondsController = TextEditingController(text: '0');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Adicionar Novo Cronômetro'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _timerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Cronômetro',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Modo Pomodoro', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Switch(
                        value: isPomodoro,
                        onChanged: (value) {
                          setState(() {
                            isPomodoro = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (isPomodoro) ...[
                    const SizedBox(height: 16),
                    PomodoroTimeInputs(
                      studyMinutesController: studyMinutesController,
                      studySecondsController: studySecondsController,
                      breakMinutesController: breakMinutesController,
                      breakSecondsController: breakSecondsController,
                      intervalsController: intervalsController,
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    const Text('Duração total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    MinuteSecondInput(
                      minutesController: minutesController,
                      secondsController: secondsController,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // if (_timerNameController.text.isEmpty) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text('Digite um nome para o cronômetro')));
                  //   return;
                  // }

                  if (isPomodoro) {
                    final breakMinutes = int.tryParse(breakMinutesController.text) ?? 5;
                    final breakSeconds = int.tryParse(breakSecondsController.text) ?? 0;
                    
                    if (!_validateTimeInput(breakMinutes.toString(), breakSeconds.toString())) return;
                    
                    _addTimer(
                      _timerNameController.text, // Pode estar vazio, será tratado
                      (int.parse(studyMinutesController.text) * 60) + int.parse(studySecondsController.text),
                      isPomodoro: true,
                      studyDuration: (int.parse(studyMinutesController.text) * 60) + int.parse(studySecondsController.text),
                      breakDuration: (breakMinutes * 60) + breakSeconds,
                      intervals: int.tryParse(intervalsController.text) ?? 4,
                    );
                  } else {
                    if (!_validateTimeInput(minutesController.text, secondsController.text)) return;
                    
                    _addTimer(
                      _timerNameController.text, // Pode estar vazio, será tratado
                      (int.parse(minutesController.text) * 60) + int.parse(secondsController.text),
                      isPomodoro: false,
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Adicionar'),
              ),

            ],
          );
        },
      );
    },
  ).then((_) {
    // Limpar os controladores quando o diálogo for fechado
    studyMinutesController.dispose();
    studySecondsController.dispose();
    breakMinutesController.dispose();
    breakSecondsController.dispose();
    intervalsController.dispose();
    minutesController.dispose();
    secondsController.dispose();
  });
}


void _addTimer(
  String name,
  int duration, {
  bool isPomodoro = false,
  int studyDuration = 1500,
  int breakDuration = 300,
  int intervals = 4,
}) {
  // Gerar nome padrão se estiver vazio
  String finalName = name.trim();
  if (finalName.isEmpty) {
    final baseName = isPomodoro ? 'Pomodoro' : 'Temporizador';
    int counter = 1;
    
    // Encontrar o próximo número disponível
    while (_timers.any((t) => t.name == '$baseName$counter')) {
      counter++;
    }
    
    finalName = '$baseName$counter';
  }

  setState(() {
    _timers.add(TimerModel(
      name: finalName,
      duration: isPomodoro ? studyDuration : duration,
      isPomodoro: isPomodoro,
      studyDuration: studyDuration,
      breakDuration: breakDuration,
      intervals: intervals,
    ));
  });
  
  _timerNameController.clear();
  _minutesController.clear();
  _secondsController.clear();
}

void _resetTimer(int index) {
  setState(() {
    _timers[index].timer?.cancel();
    _timers[index].isRunning = false;
    
    if (_timers[index].isPomodoro) {
      // Resetar para os valores iniciais do Pomodoro
      _timers[index].duration = _timers[index].studyDuration;
      _timers[index].isStudyPhase = true;
      _timers[index].completedIntervals = 0;
    } else {
      // Resetar cronômetro simples para a duração original
      _timers[index].duration = _timers[index].studyDuration;
    }
  });
}
void _removeTimer(int index) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remover cronômetro?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            _timers[index].timer?.cancel();
            setState(() => _timers.removeAt(index));
            Navigator.pop(context);
          },
          child: const Text('Remover', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void _editTimer(int index) async {
  final timer = _timers[index];
  
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditTimerScreen(
        currentName: timer.name,
        isPomodoro: timer.isPomodoro,
        currentStudyMinutes: timer.studyDuration ~/ 60,
        currentStudySeconds: timer.studyDuration % 60,
        currentBreakMinutes: timer.breakDuration ~/ 60,
        currentBreakSeconds: timer.breakDuration % 60,
        currentIntervals: timer.intervals,
        // Adicionar estes novos parâmetros para manter o tempo atual
        currentMinutes: timer.duration ~/ 60,
        currentSeconds: timer.duration % 60,
      ),
    ),
  );

  if (result != null && result is Map) {
    setState(() {
      // Atualizar tanto a duração atual quanto as configurações do Pomodoro
      final newDuration = (result['minutes'] * 60) + result['seconds'];
      
      _timers[index] = TimerModel(
        name: result['name'],
        duration: newDuration,
        isPomodoro: result['isPomodoro'],
        studyDuration: (result['studyMinutes'] * 60) + result['studySeconds'],
        breakDuration: (result['breakMinutes'] * 60) + result['breakSeconds'],
        intervals: result['intervals'],
        isRunning: timer.isRunning,
        timer: timer.timer,
        completedIntervals: timer.completedIntervals,
        isStudyPhase: timer.isStudyPhase,
      );
    });
  }
}

void _startTimer(int index) {
  // Parar qualquer timer que já esteja rodando neste Pomodoro
  if (!_timers[index].isRunning && _timers[index].isPomodoro) {
    if (_timers[index].completedIntervals >= _timers[index].intervals) {
      _resetTimer(index);
    }
  }

  _timers[index].timer?.cancel();

  setState(() {
    _timers[index].isRunning = true;
    _timers[index].timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_timers[index].duration > 0) {
          setState(() {
            _timers[index].duration--;
          });
        } else {
          if (_timers[index].isPomodoro) {
            setState(() {
              if (_timers[index].isStudyPhase) {
                // Terminou um período de estudo
                _timers[index].completedIntervals++;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Intervalo ${_timers[index].completedIntervals} completado!'),
                    duration: const Duration(seconds: 2),
                  ),
                );

                if (_timers[index].completedIntervals >= _timers[index].intervals) {
                  // Todos os intervalos completos
                  _stopTimer(index);
                  _showCompletionDialog(context);
                } else {
                  // Iniciar descanso
                  _timers[index].isStudyPhase = false;
                  _timers[index].duration = _timers[index].breakDuration;
                }
              } else {
                // Terminou um período de descanso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hora de focar novamente!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                // Iniciar próximo estudo
                _timers[index].isStudyPhase = true;
                _timers[index].duration = _timers[index].studyDuration;
              }
            });
          } else {
            // Cronômetro simples terminou
            _stopTimer(index);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cronômetro finalizado!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
    );
  });
}

void _showCompletionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('🎉 Pomodoro Completo!'),
        content: const Text('Todos os intervalos foram concluídos com sucesso!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
void _stopTimer(int index) {
  setState(() {
    _timers[index].timer?.cancel();
    _timers[index].isRunning = false; 
  });
}


}

