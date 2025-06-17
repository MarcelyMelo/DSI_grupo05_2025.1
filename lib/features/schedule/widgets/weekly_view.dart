import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../schedule_controller.dart';
import '../pages/edit_task_page.dart';

class WeeklyView extends StatefulWidget {
  final ScheduleController controller;

  const WeeklyView({Key? key, required this.controller}) : super(key: key);

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> {
  int selectedDayIndex = DateTime.now().weekday - 1;
  final List<String> weekDays = const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

 List<Task> get tasksForSelectedDay {
  DateTime today = DateTime.now();
  DateTime selectedDate = today.subtract(Duration(days: today.weekday - 1 - selectedDayIndex));

  return widget.controller.tasks.where((task) {
    return task.dueDate.year == selectedDate.year &&
        task.dueDate.month == selectedDate.month &&
        task.dueDate.day == selectedDate.day;
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Seletor de dias da semana
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

        // Lista de tarefas com botão de completar e navegação para edição
        Expanded(
          flex: 2,
          child: tasksForSelectedDay.isEmpty
              ? const Center(child: Text('Nenhuma tarefa para este dia'))
              : ListView.builder(
                  itemCount: tasksForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final task = tasksForSelectedDay[index];
                    return InkWell(
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTaskPage(task: task, controller: widget.controller),
                          ),
                        );

                        if (updated == true) {
                          setState(() {});
                        }
                      },
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: task.isCompleted ? Colors.green : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              widget.controller.completeTask(task.id);
                            });
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Text(
                          'Entrega: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} '
                          '${task.dueDate.hour}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: CircleAvatar(backgroundColor: task.tagColor),
                      ),
                    );
                  },
                ),
        ),

        const SizedBox(height: 8),

        // Grade de horários
        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, hourIndex) {
              int hour = 8 + hourIndex;
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