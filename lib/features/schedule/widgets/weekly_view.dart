import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../schedule_controller.dart';
import '../pages/edit_task_page.dart';
import 'monthly_view.dart';

class WeeklyView extends StatefulWidget {
  final ScheduleController controller;

  const WeeklyView({super.key, required this.controller});

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> with TickerProviderStateMixin {
  int selectedDayIndex = DateTime.now().weekday - 1;
  bool isWeeklyView = true;
  DateTime currentWeekStart = DateTime.now();
  
  late AnimationController _tabAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _tabAnimation;
  late Animation<double> _listAnimation;

  final List<String> weekDays = const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  final List<String> fullWeekDays = const [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 
    'Sexta-feira', 'Sábado', 'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _tabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tabAnimationController, curve: Curves.easeInOut),
    );
    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut),
    );
    
    // Initialize current week start
    _updateCurrentWeekStart();
    
    _tabAnimationController.forward();
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _tabAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  void _updateCurrentWeekStart() {
    final now = DateTime.now();
    currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  List<Task> get tasksForSelectedDay {
    final selectedDate = currentWeekStart.add(Duration(days: selectedDayIndex));
    
    return widget.controller.tasks.where((task) {
      return task.dueDate.year == selectedDate.year &&
          task.dueDate.month == selectedDate.month &&
          task.dueDate.day == selectedDate.day;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void _changeWeek(bool isNext) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: isNext ? 7 : -7));
    });
    
    _listAnimationController.reset();
    _listAnimationController.forward();
  }

  void _switchView() {
    _tabAnimationController.reverse().then((_) {
      setState(() {
        isWeeklyView = !isWeeklyView;
      });
      _tabAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50), // Fundo escuro como na segunda imagem
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isWeeklyView 
              ? _buildWeeklyView()
              : MonthlyView(controller: widget.controller),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF34495E), // Cor mais escura e sutil
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderTitle(),
          const SizedBox(height: 24),
          _buildViewToggle(),
          if (isWeeklyView) ...[
            const SizedBox(height: 24),
            _buildWeekNavigation(),
            const SizedBox(height: 20),
            _buildDaySelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_rounded,
          color: Colors.white,
          size: 32,
        ),
        const SizedBox(width: 12),
        const Text(
          'Agenda',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF95A5A6).withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getCurrentDateString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return AnimatedBuilder(
      animation: _tabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _tabAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF95A5A6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF95A5A6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isWeeklyView) _switchView();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isWeeklyView ? const Color(0xFFF5F6FA) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isWeeklyView ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_week_rounded,
                            color: isWeeklyView ? const Color(0xFF2C3E50) : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Semanal',
                            style: TextStyle(
                              color: isWeeklyView ? const Color(0xFF2C3E50) : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isWeeklyView) _switchView();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !isWeeklyView ? const Color(0xFFF5F6FA) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: !isWeeklyView ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_view_month_rounded,
                            color: !isWeeklyView ? const Color(0xFF2C3E50) : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mensal',
                            style: TextStyle(
                              color: !isWeeklyView ? const Color(0xFF2C3E50) : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _changeWeek(false),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF95A5A6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF95A5A6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        Text(
          _getWeekRangeString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: () => _changeWeek(true),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF95A5A6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF95A5A6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedDayIndex;
          final dayDate = currentWeekStart.add(Duration(days: index));
          final hasTasksForDay = widget.controller.tasks.any((task) =>
              task.dueDate.year == dayDate.year &&
              task.dueDate.month == dayDate.month &&
              task.dueDate.day == dayDate.day);
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDayIndex = index;
              });
              _listAnimationController.reset();
              _listAnimationController.forward();
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFFF5F6FA)
                    : const Color(0xFF95A5A6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? null : Border.all(
                  color: const Color(0xFF95A5A6).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekDays[index],
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF2C3E50) : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayDate.day.toString(),
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF2C3E50) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (hasTasksForDay) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2C3E50) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyView() {
    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _listAnimation.value)),
          child: Opacity(
            opacity: _listAnimation.value,
            child: tasksForSelectedDay.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.event_available_rounded,
              size: 64,
              color: const Color(0xFF95A5A6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma tarefa para ${fullWeekDays[selectedDayIndex]}',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF95A5A6),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Que tal adicionar uma nova?',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF95A5A6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasksForSelectedDay.length,
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOutCubic,
                child: _buildTaskCard(tasksForSelectedDay[index], index),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF34495E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '${tasksForSelectedDay.length} ${tasksForSelectedDay.length == 1 ? 'TAREFA' : 'TAREFAS'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              fullWeekDays[selectedDayIndex],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _editTask(task),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA), // Fundo claro como na segunda imagem
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskHeader(task),
                const SizedBox(height: 20),
                _buildTaskTime(task),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildTaskDescription(task),
                ],
                const SizedBox(height: 16),
                _buildTaskFooter(task),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader(Task task) {
    return Row(
      children: [
        Expanded(
          child: Text(
            task.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50), // Texto escuro
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF95A5A6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.edit_rounded,
            color: Color(0xFF2C3E50),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTime(Task task) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF95A5A6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.access_time_rounded,
            color: Color(0xFF2C3E50),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDescription(Task task) {
    return Text(
      task.description!,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF95A5A6),
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTaskFooter(Task task) {
    return Row(
      children: [
        if (task.tag.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF95A5A6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.tag,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (task.isCompleted)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF95A5A6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF2C3E50),
              size: 16,
            ),
          ),
      ],
    );
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
                   'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${now.day} ${months[now.month - 1]}';
  }

  String _getWeekRangeString() {
    final endDate = currentWeekStart.add(const Duration(days: 6));
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
                   'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    
    if (currentWeekStart.month == endDate.month) {
      return '${currentWeekStart.day} - ${endDate.day} ${months[currentWeekStart.month - 1]}';
    } else {
      return '${currentWeekStart.day} ${months[currentWeekStart.month - 1]} - ${endDate.day} ${months[endDate.month - 1]}';
    }
  }

  Future<void> _editTask(Task task) async {
    final updated = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditTaskPage(
          task: task,
          controller: widget.controller,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );

    if (updated == true) {
      setState(() {});
      _listAnimationController.reset();
      _listAnimationController.forward();
    }
  }

  Color _getDefaultCardColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'urgente':
        return const Color(0xFFFF6B6B);
      case 'importante':
        return const Color(0xFFFF9F43);
      case 'estudo':
        return const Color(0xFF4ECDC4);
      case 'trabalho':
        return const Color(0xFF667EEA);
      case 'pessoal':
        return const Color(0xFF26DE81);
      case 'projeto':
        return const Color(0xFF45B7D1);
      case 'sociologia':
        return const Color(0xFF4ECDC4);
      case 'scrum':
        return const Color(0xFF667EEA);
      case 'protótipo':
        return const Color(0xFF45B7D1);
      default:
        return const Color(0xFF95A5A6);
    }
  }
}