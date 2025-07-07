import 'package:dsi_projeto/screens/flashcard_screen.dart';
import 'package:dsi_projeto/screens/map_screen.dart';
import 'package:dsi_projeto/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:dsi_projeto/components/custom_bottom_navbar.dart'; // Importação correta
import 'package:dsi_projeto/components/colors/appColors.dart'; // Importação das cores
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
  int _selectedIndex = 5;

  // Instância singleton do controller
  static final ScheduleController _controller = ScheduleController.instance;

  // Passa o controller para as páginas que precisam
  late final List<Widget> _pages = <Widget>[
    TaskListPage(controller: _controller),
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
        // Agora deve ser reconhecido
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;
  final String text;

  const PlaceholderWidget(this.color, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

// TaskListPage ajustado para receber controller
class TaskListPage extends StatefulWidget {
  final ScheduleController controller;

  const TaskListPage({super.key, required this.controller});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  ScheduleController get _controller => widget.controller;

  List<Task> get todayTasks {
    return _controller.tasksForDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        title: const Text(
          'Hoje',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: todayTasks.isEmpty
            ? const Center(
                child: Text(
                  'Nenhuma tarefa para hoje.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : ListView.builder(
                itemCount: todayTasks.length,
                itemBuilder: (context, index) {
                  final task = todayTasks[index];
                  return GestureDetector(
                    onTap: () async {
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
                    },
                    child: _buildTaskItem(
                      task: task.title,
                      time:
                          '${task.dueDate.hour}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                      tag: task.tag,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditTaskPage(controller: _controller),
            ),
          );
          if (created == true) {
            setState(() {}); // Atualiza a lista de tarefas
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskItem({
    required String task,
    required String time,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle_outlined, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SchedulePage ajustado para receber controller
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
