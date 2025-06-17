import 'package:flutter/material.dart';
import 'widgets/weekly_view.dart';
import 'widgets/monthly_view.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        children: const [
          WeeklyView(),
          MonthlyView(),
        ],
      ),
    );
  }
}