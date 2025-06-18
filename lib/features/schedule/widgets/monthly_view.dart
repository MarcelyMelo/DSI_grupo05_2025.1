import 'package:flutter/material.dart';
import '../schedule_controller.dart';
import '../pages/edit_task_page.dart';

class MonthlyView extends StatelessWidget {
  final ScheduleController controller;

  const MonthlyView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final int startWeekday = firstDayOfMonth.weekday; // 1 = Monday

    // Cria a grade de dias (com nulls para os espaços em branco)
    final List<DateTime?> calendarDays = List.generate(
      startWeekday - 1 + daysInMonth,
      (index) {
        if (index < startWeekday - 1) return null;
        return DateTime(now.year, now.month, index - startWeekday + 2);
      },
    );

    return Column(
      children: [
        // Cabeçalho com os dias da semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Grade de dias com tarefas
        Expanded(
          child: GridView.builder(
            itemCount: calendarDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final date = calendarDays[index];

              if (date == null) {
                return const SizedBox(); // espaço em branco
              }

              final tasksThisDay = controller.tasks.where((task) =>
                  task.dueDate.year == date.year &&
                  task.dueDate.month == date.month &&
                  task.dueDate.day == date.day).toList();

              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${date.day}', style: const TextStyle(fontWeight: FontWeight.bold)),

                    // Tarefas do dia
                    ...tasksThisDay.map((task) => GestureDetector(
                          onTap: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTaskPage(task: task, controller: controller),
                              ),
                            );
                            if (updated == true) {
                              (context as Element).markNeedsBuild();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: task.tagColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task.title,
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}