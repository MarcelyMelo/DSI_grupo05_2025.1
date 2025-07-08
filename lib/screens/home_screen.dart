import 'package:dsi_projeto/screens/flashcard_screen.dart';
import 'package:dsi_projeto/screens/map_screen.dart';
import 'package:dsi_projeto/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:dsi_projeto/components/custom_bottom_navbar.dart';
import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:dsi_projeto/screens/pomodoro_screen.dart';
import 'package:dsi_projeto/features/schedule/schedule_controller.dart';
import 'package:dsi_projeto/features/schedule/models/task_model.dart';
import 'package:dsi_projeto/features/schedule/pages/edit_task_page.dart';
import 'package:dsi_projeto/features/schedule/widgets/monthly_view.dart';
import 'package:dsi_projeto/features/schedule/widgets/weekly_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; // Mudei para 0 para começar na primeira tela

  // Instância singleton do controller
  static final ScheduleController _controller = ScheduleController.instance;

  // Passa o controller para as páginas que precisam
  late final List<Widget> _pages = <Widget>[
    TaskListPage(controller: _controller), // Sua tela nova
    SchedulePage(controller: _controller),
    MapScreen(),
    PomodoroScreen(),
    FlashcardScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Sua TaskListPage redesenhada (com correção no método deleteTask)
class TaskListPage extends StatefulWidget {
  final ScheduleController controller;

  const TaskListPage({super.key, required this.controller});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> with TickerProviderStateMixin {
  ScheduleController get _controller => widget.controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Set<String> completedTasks = <String>{};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<Task> get todayTasks {
    return _controller.tasksForDate(DateTime.now());
  }

  String get todayDate {
    final now = DateTime.now();
    final weekdays = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${weekdays[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}';
  }

  void _toggleTaskCompletion(String taskId) {
    setState(() {
      if (completedTasks.contains(taskId)) {
        completedTasks.remove(taskId);
      } else {
        completedTasks.add(taskId);
      }
    });
  }

  void _deleteTask(Task task) {
  // CORREÇÃO: Use o método deleteTask que foi adicionado no controller
  _controller.deleteTask(task);
  setState(() {
    completedTasks.remove(task.id);
  });
  
  // Mostrar snackbar de confirmação
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Tarefa "${task.title}" removida'),
      backgroundColor: const Color(0xFF2E3A59),
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: const Color(0xFF6C7B95),
        onPressed: () {
          _controller.addTask(task);
          setState(() {});
        },
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              _buildTasksContent(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3A59),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.today_outlined,
                  color: Color(0xFF6C7B95),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hoje',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      todayDate,
                      style: const TextStyle(
                        color: Color(0xFF6C7B95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTasksCounter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksCounter() {
    final totalTasks = todayTasks.length;
    final completedCount = todayTasks.where((task) => completedTasks.contains(task.id)).length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: totalTasks > 0 
                  ? (completedCount == totalTasks ? Colors.green : const Color(0xFF6C7B95))
                  : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$completedCount/$totalTasks',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksContent() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF16213E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: todayTasks.isEmpty
            ? _buildEmptyState()
            : _buildTasksList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2E3A59),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Color(0xFF6C7B95),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Nenhuma tarefa para hoje',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Que tal adicionar uma nova?',
          style: TextStyle(
            color: Color(0xFF6C7B95),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      itemCount: todayTasks.length,
      itemBuilder: (context, index) {
        final task = todayTasks[index];
        final isCompleted = completedTasks.contains(task.id);
        
        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          onDismissed: (direction) {
            _deleteTask(task);
          },
          child: _buildTaskItem(task, isCompleted),
        );
      },
    );
  }

  Widget _buildTaskItem(Task task, bool isCompleted) {
    return GestureDetector(
      onTap: () => _navigateToEditTask(task),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isCompleted 
              ? const Color(0xFF2E3A59).withOpacity(0.7)
              : const Color(0xFF2E3A59),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted 
                ? Colors.green.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _toggleTaskCompletion(task.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? Colors.green : const Color(0xFF6C7B95),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: isCompleted ? const Color(0xFF6C7B95) : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted 
                            ? TextDecoration.lineThrough 
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: const Color(0xFF6C7B95),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Color(0xFF6C7B95),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (task.tag.isNotEmpty) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTagColor(task.tag).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTagColor(task.tag).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    task.tag,
                    style: TextStyle(
                      color: _getTagColor(task.tag),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'trabalho':
        return const Color(0xFF4CAF50);
      case 'estudo':
        return const Color(0xFF2196F3);
      case 'pessoal':
        return const Color(0xFFFF9800);
      case 'importante':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF6C7B95);
    }
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C7B95).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToCreateTask(),
        backgroundColor: const Color(0xFF6C7B95),
        elevation: 0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Future<void> _navigateToEditTask(Task task) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTaskPage(
          task: task,
          controller: _controller,
        ),
      ),
    );

    if (updated == true) {
      setState(() {});
    }
  }

  Future<void> _navigateToCreateTask() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTaskPage(controller: _controller),
      ),
    );
    
    if (created == true) {
      setState(() {});
    }
  }
}

// SchedulePage (mantém igual ao original)
class SchedulePage extends StatefulWidget {
  final ScheduleController controller;

  const SchedulePage({super.key, required this.controller});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ScheduleController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          WeeklyView(controller: _controller),
          MonthlyView(controller: _controller),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => EditTaskPage(
              controller: _controller,
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}