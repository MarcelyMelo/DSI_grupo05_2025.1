import 'package:flutter/material.dart';
import '../models/task_model.dart';

class WeeklyView extends StatefulWidget {
  final List<Task> allTasks; // Recebe todas as tarefas da semana (ou do controller)

  const WeeklyView({Key? key, required this.allTasks}) : super(key: key);

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> {
  int selectedDayIndex = DateTime.now().weekday - 1; // 0 = seg, 6 = dom
  final List<String> weekDays = const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  // Retorna tarefas do dia selecionado
  List<Task> get tasksForSelectedDay {
    DateTime today = DateTime.now();
    // Ajustar a data para o dia da semana selecionado (mesmo semana atual)
    DateTime selectedDate = today.subtract(Duration(days: today.weekday - 1 - selectedDayIndex));

    return widget.allTasks.where((task) {
      return task.dueDate.year == selectedDate.year &&
          task.dueDate.month == selectedDate.month &&
          task.dueDate.day == selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Seletor de dias da semana no topo
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekDays.length,
            itemBuilder: (context, index) {
              bool isSelected = index == selectedDayIndex;
              return GestureDetector(
                onTap: () => setState(() => selectedDayIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      weekDays[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Lista de tarefas do dia selecionado
        Expanded(
          flex: 2,
          child: tasksForSelectedDay.isEmpty
              ? const Center(child: Text('Nenhuma tarefa para este dia'))
              : ListView.builder(
                  itemCount: tasksForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final task = tasksForSelectedDay[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(
                        'Entrega: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} '
                        '${task.dueDate.hour}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                      ),
                      leading: CircleAvatar(backgroundColor: task.tagColor),
                    );
                  },
                ),
        ),

        const SizedBox(height: 8),

        // Grade horária do dia selecionado com indicação das tarefas
        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: 12, // blocos de horário (ex: 8h às 20h)
            itemBuilder: (context, hourIndex) {
              int hour = 8 + hourIndex;
              // Tarefas que começam nesta hora no dia selecionado
              final tasksThisHour = tasksForSelectedDay.where((task) => task.dueDate.hour == hour).toList();

              return Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      height: 60,
                      color: Colors.grey[200],
                      child: Stack(
                        children: [
                          Center(child: Text('$hour:00')),
                          ...tasksThisHour.map((task) => Positioned(
                                left: 40,
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: task.tagColor.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    task.title,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}