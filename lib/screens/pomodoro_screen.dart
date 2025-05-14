import 'package:flutter/material.dart';
import 'package:dsi_projeto/components/colors/appColors.dart';
import 'dart:async'; // Adicione esta linha
import 'package:flutter/services.dart';
import 'package:dsi_projeto/screens/edit_timer_screen.dart';
import 'package:flutter/material.dart';

class TimerModel {
  String name;
  int duration; // em segundos
  bool isRunning;
  Timer? timer;
  bool isPomodoro;
  int studyDuration; // Duração do estudo (em segundos)
  int breakDuration; // Duração do descanso (em segundos)
  int intervals; // Quantidade de intervalos
  int completedIntervals; // Intervalos completados
  bool isStudyPhase; // Se está na fase de estudo

  TimerModel({
    required this.name,
    required this.duration,
    this.isRunning = false,
    this.timer,
    this.isPomodoro = false,
    this.studyDuration = 25 * 60, // 25 minutos padrão
    this.breakDuration = 5 * 60, // 5 minutos padrão
    this.intervals = 4, // 4 intervalos padrão
    this.completedIntervals = 0,
    this.isStudyPhase = true,
  });
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
  int studyMinutes = 25;
  int studySeconds = 0;
  int breakMinutes = 5;
  int breakSeconds = 0;
  int intervals = 4;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          var textField = TextField(
                            keyboardType: TextInputType.number,
                              inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3), // Para limitar a 2 dígitos
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Minutos',
                            ),
                            onChanged: (value) {
                              breakMinutes = int.tryParse(value) ?? 5;
                            },
                          );
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
                    ),
                      autofocus: true, // Adicione esta linha
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Modo Pomodoro'),
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
                    const Text('Tempo de Foco:'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                              inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3), // Para limitar a 2 dígitos
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Minutos',
                            ),
                            onChanged: (value) {
                              studyMinutes = int.tryParse(value) ?? 25;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                              inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2), // Para limitar a 2 dígitos
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Segundos',
                            ),
                            onChanged: (value) {
                              studySeconds = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Tempo de descanso:'),
                    Row(
                      children: [
                        Expanded(
                          child: textField,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                              inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2), // Para limitar a 2 dígitos
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Segundos',
                            ),
                            onChanged: (value) {
                              breakSeconds = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                        inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2), // Para limitar a 2 dígitos
                            ],
                      decoration: const InputDecoration(
                        labelText: 'Quantidade de intervalos',
                      ),
                      onChanged: (value) {
                        intervals = int.tryParse(value) ?? 4;
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    const Text('Duração total:'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minutesController,
                            keyboardType: TextInputType.number,
                              inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3), // Para limitar a 2 dígitos
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Minutos',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _secondsController,
                            keyboardType: TextInputType.number,
                              inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2), // Para limitar a 2 dígitos
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Segundos',
                            ),
                          ),
                        ),
                      ],
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
    if (_timerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o cronômetro')));
      return;
    }

    if (isPomodoro) {
      if (!_validateTimeInput(breakMinutes.toString(), breakSeconds.toString())) return;
      
      _addTimer(
        _timerNameController.text,
        (studyMinutes * 60) + studySeconds,
        isPomodoro: true,
        studyDuration: (studyMinutes * 60) + studySeconds,
        breakDuration: (breakMinutes * 60) + breakSeconds,
        intervals: intervals,
      );
    } else {
      if (!_validateTimeInput(_minutesController.text, _secondsController.text)) return;
      
      _addTimer(
        _timerNameController.text,
        (int.parse(_minutesController.text) * 60) + int.parse(_secondsController.text),
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
  );
}
void _addTimer(
  String name,
  int duration, {
  bool isPomodoro = false,
  int studyDuration = 1500,
  int breakDuration = 300,
  int intervals = 4,
}) {
  setState(() {
    _timers.add(TimerModel(
      name: name,
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
      ),
    ),
  );

  if (result != null && result is Map) {
    setState(() {
      _timers[index] = TimerModel(
        name: result['name'],
        duration: timer.isPomodoro 
            ? (result['studyMinutes'] * 60) + result['studySeconds']
            : (result['studyMinutes'] * 60) + result['studySeconds'],
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

