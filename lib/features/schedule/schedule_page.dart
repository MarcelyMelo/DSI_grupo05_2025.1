import 'package:flutter/material.dart';
import 'widgets/weekly_view.dart';
import 'widgets/monthly_view.dart';
import 'schedule_controller.dart';
import 'widgets/task_form.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScheduleController _controller = ScheduleController();

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
      appBar: AppBar(
        title: const Text('Agenda'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semanal'),
            Tab(text: 'Mensal'),
          ],
        ),
      ),
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
            builder: (context) => TaskForm(
              controller: _controller,
              onTaskAdded: () {
                setState(() {}); // atualiza a UI para refletir a nova tarefa
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}