import 'package:dsi_projeto/services/pomodoro_service.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Adicione esta linha
import 'package:dsi_projeto/screens/edit_timer_screen.dart';
import 'package:dsi_projeto/components/time_inputs/minute_second_input.dart';
import 'package:dsi_projeto/components/time_inputs/pomodoro_time_inputs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dsi_projeto/screens/CreateTimerScreen.dart';

class TimerModel {
  String name; // Removido final
  int duration;
  bool isRunning;
  Timer? timer;
  bool isPomodoro;
  int studyDuration; // Removido final
  int breakDuration; // Removido final
  int intervals; // Removido final
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
    if (isPomodoro) {
      duration = isStudyPhase ? studyDuration : breakDuration;
    } else {
      duration =
          studyDuration; // Para timers normais, studyDuration armazena o tempo inicial
    }
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
  final List<TimerFirebaseModel> _firebaseTimers = [];
  final PomodoroService _pomodoroService = PomodoroService();

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.timer?.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

  // Load timers from Firebase
  Future<void> _loadTimers() async {
    try {
      if (_pomodoroService.isAuthenticated) {
        final timers = await _pomodoroService.getTimers();
        setState(() {
          _firebaseTimers.clear();
          _firebaseTimers.addAll(timers);
          _syncFirebaseToLocal();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar cronômetros: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  // Sync Firebase timers to local TimerModel list
  void _syncFirebaseToLocal() {
    _timers.clear();
    for (final firebaseTimer in _firebaseTimers) {
      _timers.add(TimerModel(
        name: firebaseTimer.name,
        duration: firebaseTimer.duration,
        isPomodoro: firebaseTimer.isPomodoro,
        studyDuration: firebaseTimer.studyDuration,
        breakDuration: firebaseTimer.breakDuration,
        intervals: firebaseTimer.intervals,
        completedIntervals: firebaseTimer.completedIntervals,
        isStudyPhase: firebaseTimer.isStudyPhase,
      ));
    }
  }

  Future<void> _navigateToCreateTimer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTimerScreen(),
      ),
    );

    if (result != null && result is Map) {
  final name = result['name'] ?? '';
  final duration = result['duration'] ?? 0;
  final isPomodoro = result['isPomodoro'] ?? false;
  final studyDuration = result['studyDuration'] ?? duration;
  final breakDuration = result['breakDuration'] ?? 300;
  final intervals = result['intervals'] ?? 4;

  if (duration == 0 && !isPomodoro) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Duração inválida para temporizador!"),
        backgroundColor: Color(0xFFE74C3C),
      ),
    );
    return;
  }

  await _addTimer(
    name,
    duration,
    isPomodoro: isPomodoro,
    studyDuration: studyDuration,
    breakDuration: breakDuration,
    intervals: intervals,
  );
}

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
      backgroundColor: const Color(0xFF2C3E50), // Fundo escuro azul-acinzentado
      appBar: AppBar(
        backgroundColor: const Color(0xFF34495E),
        elevation: 0,
        title: const Text(
          "Cronômetros",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Removido o botão de adicionar do AppBar
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTimer(),
        backgroundColor: const Color(0xFF3498DB),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: _timers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum cronômetro criado',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no botão + para adicionar seu primeiro cronômetro',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _timers.length,
              itemBuilder: (context, index) {
                return _buildTimerCard(_timers[index], index);
              },
            ),
    );
  }

  Widget _buildTimerCard(TimerModel timer, int index) {
    return Dismissible(
      key: Key('timer_${index}_${timer.name}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              'Deletar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF34495E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Confirmar exclusão',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'Tem certeza que deseja deletar "${timer.name}"?',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF95A5A6)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Deletar',
                    style: TextStyle(color: Color(0xFFE74C3C)),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _timers[index].timer?.cancel();
        final removedTimer = _timers[index];

        setState(() {
          _timers.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timer "${removedTimer.name}" removido'),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFF34495E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Desfazer',
              textColor: const Color(0xFF3498DB),
              onPressed: () {
                setState(() {
                  _timers.insert(index, removedTimer);
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF34495E),
          borderRadius: BorderRadius.circular(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timer.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (timer.isPomodoro) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: timer.isStudyPhase
                                  ? const Color(0xFF27AE60).withOpacity(0.2)
                                  : const Color(0xFF3498DB).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              timer.isStudyPhase
                                  ? '⏳ Fase: Foco'
                                  : '☕ Fase: Descanso',
                              style: TextStyle(
                                color: timer.isStudyPhase
                                    ? const Color(0xFF27AE60)
                                    : const Color(0xFF3498DB),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intervalos: ${timer.completedIntervals}/${timer.intervals}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3498DB).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF3498DB),
                            size: 20,
                          ),
                        ),
                        onPressed: () => _editTimer(index),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFE74C3C),
                            size: 20,
                          ),
                        ),
                        onPressed: () => _removeTimer(index),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _formatDuration(timer.duration),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: timer.isRunning
                        ? const Color(0xFF27AE60)
                        : Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    label: 'Iniciar',
                    icon: Icons.play_arrow,
                    color: const Color(0xFF27AE60),
                    isEnabled: !timer.isRunning,
                    onPressed: () => _startTimer(index),
                  ),
                  _buildActionButton(
                    label: 'Parar',
                    icon: Icons.pause,
                    color: const Color(0xFFE74C3C),
                    isEnabled: timer.isRunning,
                    onPressed: () => _stopTimer(index),
                  ),
                  _buildActionButton(
                    label: 'Reiniciar',
                    icon: Icons.refresh,
                    color: const Color(0xFFF39C12),
                    isEnabled: !timer.isRunning,
                    onPressed: () => _resetTimer(index),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 90,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color : const Color(0xFF95A5A6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: isEnabled ? 3 : 0,
        ),
        onPressed: isEnabled ? onPressed : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
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

  // Updated _addTimer method to save to Firebase
  Future<void> _addTimer(
    String name,
    int duration, {
    bool isPomodoro = false,
    int studyDuration = 1500,
    int breakDuration = 300,
    int intervals = 4,
  }) async {
    String finalName = name.trim();
    if (finalName.isEmpty) {
      final baseName = isPomodoro ? 'Pomodoro' : 'Temporizador';
      int counter = 1;

      while (_timers.any((t) => t.name == '$baseName$counter')) {
        counter++;
      }

      finalName = '$baseName$counter';
    }

    try {
      if (_pomodoroService.isAuthenticated) {
        final firebaseTimer = PomodoroService.fromTimerModel(
          name: finalName,
          duration: isPomodoro ? studyDuration : duration,
          isPomodoro: isPomodoro,
          studyDuration: isPomodoro ? studyDuration : duration,
          breakDuration: breakDuration,
          intervals: intervals,
        );

        final timerId = await _pomodoroService.createTimer(firebaseTimer);

        setState(() {
          _timers.add(TimerModel(
            name: finalName,
            duration: isPomodoro ? studyDuration : duration,
            isPomodoro: isPomodoro,
            studyDuration: isPomodoro ? studyDuration : duration,
            breakDuration: breakDuration,
            intervals: intervals,
          ));

          _firebaseTimers.add(firebaseTimer.copyWith(id: timerId));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cronômetro "$finalName" criado com sucesso!'),
            backgroundColor: const Color(0xFF27AE60),
          ),
        );
      } else {
        setState(() {
          _timers.add(TimerModel(
            name: finalName,
            duration: isPomodoro ? studyDuration : duration,
            isPomodoro: isPomodoro,
            studyDuration: isPomodoro ? studyDuration : duration,
            breakDuration: breakDuration,
            intervals: intervals,
          ));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar cronômetro: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  void _resetTimer(int index) {
    setState(() {
      _timers[index].timer?.cancel();
      _timers[index].isRunning = false;

      if (_timers[index].isPomodoro) {
        _timers[index].duration = _timers[index].isStudyPhase
            ? _timers[index].studyDuration
            : _timers[index].breakDuration;
        _timers[index].isStudyPhase = true;
        _timers[index].completedIntervals = 0;
      } else {
        _timers[index].duration = _timers[index].studyDuration;
      }
    });
  }

  // Updated _removeTimer method to delete from Firebase
  Future<void> _removeTimer(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF34495E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Remover cronômetro?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF95A5A6)),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                _timers[index].timer?.cancel();

                if (_pomodoroService.isAuthenticated &&
                    index < _firebaseTimers.length) {
                  await _pomodoroService.deleteTimer(_firebaseTimers[index].id);
                  _firebaseTimers.removeAt(index);
                }

                setState(() => _timers.removeAt(index));
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cronômetro removido com sucesso!'),
                    backgroundColor: Color(0xFF27AE60),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao remover cronômetro: $e'),
                    backgroundColor: const Color(0xFFE74C3C),
                  ),
                );
              }
            },
            child: const Text(
              'Remover',
              style: TextStyle(color: Color(0xFFE74C3C)),
            ),
          ),
        ],
      ),
    );
  }

  // Updated _editTimer method to update Firebase
  Future<void> _editTimer(int index) async {
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
          currentMinutes: timer.duration ~/ 60,
          currentSeconds: timer.duration % 60,
        ),
      ),
    );

    if (result != null && result is Map) {
      try {
        setState(() {
          _timers[index].name = result['name'];
          _timers[index].studyDuration =
              (result['studyMinutes'] * 60) + result['studySeconds'];
          _timers[index].breakDuration =
              (result['breakMinutes'] * 60) + result['breakSeconds'];
          _timers[index].intervals = result['intervals'];

          if (_timers[index].isPomodoro) {
            _timers[index].duration = _timers[index].isStudyPhase
                ? _timers[index].studyDuration
                : _timers[index].breakDuration;
          } else {
            _timers[index].duration =
                (result['minutes'] * 60) + result['seconds'];
          }

          if (_timers[index].isRunning) {
            _timers[index].stop();
            _startTimer(index);
          }
        });

        // Update Firebase
        if (_pomodoroService.isAuthenticated &&
            index < _firebaseTimers.length) {
          final updatedFirebaseTimer = _firebaseTimers[index].copyWith(
            name: result['name'],
            studyDuration:
                (result['studyMinutes'] * 60) + result['studySeconds'],
            breakDuration:
                (result['breakMinutes'] * 60) + result['breakSeconds'],
            intervals: result['intervals'],
            duration: _timers[index].duration,
          );

          await _pomodoroService.updateTimer(updatedFirebaseTimer);
          _firebaseTimers[index] = updatedFirebaseTimer;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar cronômetro: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  // Helper method to update Firebase progress
  Future<void> _updateFirebaseProgress(int index) async {
    try {
      if (_pomodoroService.isAuthenticated && index < _firebaseTimers.length) {
        await _pomodoroService.updateTimerProgress(
          timerId: _firebaseTimers[index].id,
          completedIntervals: _timers[index].completedIntervals,
          isStudyPhase: _timers[index].isStudyPhase,
          currentDuration: _timers[index].duration,
        );
      }
    } catch (e) {
      // Don't show error to user for progress updates
      debugPrint('Error updating Firebase progress: $e');
    }
  }

  // Updated _startTimer method to sync progress with Firebase
  void _startTimer(int index) {
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
                  _timers[index].completedIntervals++;

                  // Update Firebase progress
                  _updateFirebaseProgress(index);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Intervalo ${_timers[index].completedIntervals} completado!'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF34495E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );

                  if (_timers[index].completedIntervals >=
                      _timers[index].intervals) {
                    _stopTimer(index);
                    _showCompletionDialog(context);
                  } else {
                    _timers[index].isStudyPhase = false;
                    _timers[index].duration = _timers[index].breakDuration;
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hora de focar novamente!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF34495E),
                    ),
                  );
                  _timers[index].isStudyPhase = true;
                  _timers[index].duration = _timers[index].studyDuration;
                }
              });
            } else {
              _stopTimer(index);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cronômetro finalizado!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF34495E),
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
          backgroundColor: const Color(0xFF34495E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '🎉 Pomodoro Completo!',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Todos os intervalos foram concluídos com sucesso!',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF3498DB)),
              ),
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