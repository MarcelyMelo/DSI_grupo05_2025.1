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

class _MonthlyViewState extends State<MonthlyView> with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  bool showTaskModal = false;
  late AnimationController _modalAnimationController;
  late AnimationController _calendarAnimationController;
  late Animation<double> _modalSlideAnimation;
  late Animation<double> _modalFadeAnimation;
  late Animation<double> _calendarFadeAnimation;

  List<Task> get tasksForSelectedDay {
    return widget.controller.tasks.where((task) {
      return task.dueDate.year == selectedDate.year &&
          task.dueDate.month == selectedDate.month &&
          task.dueDate.day == selectedDate.day;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  void initState() {
    super.initState();
    _modalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _calendarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _modalSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _modalAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _modalFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modalAnimationController,
      curve: Curves.easeOut,
    ));
    
    _calendarFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _calendarAnimationController,
      curve: Curves.easeOut,
    ));
    
    _calendarAnimationController.forward();
  }

  @override
  void dispose() {
    _modalAnimationController.dispose();
    _calendarAnimationController.dispose();
    super.dispose();
  }

  void _showTaskModal() {
    setState(() {
      showTaskModal = true;
    });
    _modalAnimationController.forward();
  }

  void _hideTaskModal() {
    _modalAnimationController.reverse().then((_) {
      setState(() {
        showTaskModal = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _calendarFadeAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Calendar
                  Expanded(
                    child: _buildCalendar(),
                  ),
                ],
              ),
            ),
          ),
          
          // Task Modal
          if (showTaskModal) _buildTaskModal(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Month Button
          GestureDetector(
            onTap: () {
              setState(() {
                currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
              });
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF334155),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
            ),
          ),
          
          // Month/Year Display
          Column(
            children: [
              Text(
                _getMonthYearString(currentMonth),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_getTaskCountForMonth()} tarefas este mês',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          
          // Next Month Button
          GestureDetector(
            onTap: () {
              setState(() {
                currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
              });
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF334155),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Weekdays Header
          _buildWeekdaysHeader(),
          
          const SizedBox(height: 20),
          
          // Calendar Grid
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdaysHeader() {
    const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) => 
        Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        )
      ).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final DateTime firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final int daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final int startWeekday = firstDayOfMonth.weekday % 7;

    final List<DateTime?> calendarDays = [];
    
    // Add empty spaces for days before the first day
    for (int i = 0; i < startWeekday; i++) {
      calendarDays.add(null);
    }
    
    // Add days of the month
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
            });
            if (tasksThisDay.isNotEmpty) {
              _showTaskModal();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF3B82F6)
                  : isToday 
                      ? const Color(0xFF3B82F6).withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isToday && !isSelected 
                  ? Border.all(color: const Color(0xFF3B82F6), width: 2)
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
                            ? const Color(0xFF3B82F6)
                            : Colors.white,
                  ),
                ),
                if (tasksThisDay.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < tasksThisDay.length && i < 3; i++)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white 
                                : _getPriorityColor(tasksThisDay[i]),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
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
      onTap: _hideTaskModal,
      child: AnimatedBuilder(
        animation: _modalAnimationController,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.5 * _modalFadeAnimation.value),
            child: Center(
              child: Transform.translate(
                offset: Offset(0, 50 * _modalSlideAnimation.value),
                child: Opacity(
                  opacity: _modalFadeAnimation.value,
                  child: GestureDetector(
                    onTap: () {}, // Prevent modal from closing when tapping inside
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      constraints: const BoxConstraints(
                        maxHeight: 600,
                        maxWidth: 400,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Modal Header
                          _buildModalHeader(),
                          
                          // Modal Content
                          Flexible(
                            child: _buildModalContent(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tarefas do Dia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getSelectedDateString(),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _hideTaskModal,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: tasksForSelectedDay.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              shrinkWrap: true,
              itemCount: tasksForSelectedDay.length,
              itemBuilder: (context, index) {
                return _buildTaskItem(tasksForSelectedDay[index], index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF64748B),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma tarefa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Você não tem tarefas agendadas para este dia',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: index == tasksForSelectedDay.length - 1 ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF475569),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Task Status & Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getPriorityColor(task),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getPriorityColor(task),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Task Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (task.tag.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: task.tagColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: task.tagColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Edit Button
          GestureDetector(
            onTap: () async {
              _hideTaskModal();
              
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(Task task) {
    if (task.tagColor != Colors.transparent) {
      return task.tagColor;
    }
    return const Color(0xFF3B82F6);
  }

  int _getTaskCountForMonth() {
    return widget.controller.tasks.where((task) {
      return task.dueDate.year == currentMonth.year &&
          task.dueDate.month == currentMonth.month;
    }).length;
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