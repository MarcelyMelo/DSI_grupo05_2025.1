import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../schedule_controller.dart';
import '../pages/edit_task_page.dart';

class MonthlyView extends StatefulWidget {
  final ScheduleController controller;

  const MonthlyView({super.key, required this.controller});

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  bool showTaskModal = false;

  List<Task> get tasksForSelectedDay {
    return widget.controller.tasks.where((task) {
      return task.dueDate.year == selectedDate.year &&
          task.dueDate.month == selectedDate.month &&
          task.dueDate.day == selectedDate.day;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Calendário
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header do calendário
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                          });
                        },
                        icon: const Icon(Icons.chevron_left, size: 28),
                        color: const Color(0xFF6B7280),
                      ),
                      Text(
                        _getMonthYearString(currentMonth),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D29),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                          });
                        },
                        icon: const Icon(Icons.chevron_right, size: 28),
                        color: const Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
                
                // Dias da semana
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Grid do calendário
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildCalendarGrid(),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Modal de tarefas
        if (showTaskModal)
          _buildTaskModal(),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final DateTime firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final int daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final int startWeekday = firstDayOfMonth.weekday % 7; // Ajuste para domingo = 0

    final List<DateTime?> calendarDays = [];
    
    // Adicionar espaços em branco no início
    for (int i = 0; i < startWeekday; i++) {
      calendarDays.add(null);
    }
    
    // Adicionar dias do mês
    for (int day = 1; day <= daysInMonth; day++) {
      calendarDays.add(DateTime(currentMonth.year, currentMonth.month, day));
    }

    return GridView.builder(
      itemCount: calendarDays.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final date = calendarDays[index];

        if (date == null) {
          return const SizedBox();
        }

        final isSelected = date.day == selectedDate.day && 
                          date.month == selectedDate.month && 
                          date.year == selectedDate.year;
        
        final isToday = date.day == DateTime.now().day && 
                       date.month == DateTime.now().month && 
                       date.year == DateTime.now().year;

        final tasksThisDay = widget.controller.tasks.where((task) =>
            task.dueDate.year == date.year &&
            task.dueDate.month == date.month &&
            task.dueDate.day == date.day).toList();

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
              if (tasksThisDay.isNotEmpty) {
                showTaskModal = true;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected 
                  ? Border.all(color: const Color(0xFF2196F3), width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? Colors.white 
                        : isToday 
                            ? const Color(0xFF2196F3)
                            : const Color(0xFF1A1D29),
                  ),
                ),
                if (tasksThisDay.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white 
                          : const Color(0xFF34D399),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskModal() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showTaskModal = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent modal from closing when tapping inside
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header do modal
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tarefas do Dia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                showTaskModal = false;
                              });
                            },
                            icon: const Icon(Icons.close, color: Color(0xFF2C3E50)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Conteúdo do modal
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Data selecionada
                        Text(
                          _getSelectedDateString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1D29),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Lista de tarefas
                        if (tasksForSelectedDay.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Nenhuma tarefa para este dia',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ...tasksForSelectedDay.map((task) => _buildTaskItem(task)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Horário
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              '${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Título da tarefa
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1D29),
              ),
            ),
          ),
          
          // Ícone de edição
          GestureDetector(
            onTap: () async {
              setState(() {
                showTaskModal = false;
              });
              
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
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getSelectedDateString() {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${selectedDate.day} de ${months[selectedDate.month - 1]} ${selectedDate.year}';
  }
}