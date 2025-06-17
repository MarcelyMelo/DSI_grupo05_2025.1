import 'package:dsi_projeto/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:dsi_projeto/components/custom_bottom_navbar.dart'; // Importação correta
import 'package:dsi_projeto/components/colors/appColors.dart'; // Importação das cores
import 'package:dsi_projeto/screens/pomodoro_screen.dart';
import 'package:dsi_projeto/screens/map_screen.dart';
import 'package:dsi_projeto/features/schedule/schedule_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter'),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    TaskListPage(),
    SchedulePage(),
    MapScreen(),
    PomodoroScreen(), // Nova tela adicionada
    PlaceholderWidget(Colors.orange, "Perfil"),
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
      bottomNavigationBar: CustomBottomNavBar( // Agora deve ser reconhecido
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Widget para páginas não implementadas (placeholders)
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

// Sua página de lista de tarefas (mantida igual)
class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

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
        child: Column(
          children: [
            _buildTaskItem(
              task: "Reunião discutir cores do app de...",
              time: "01:16",
              tag: "#08",
            ),
            const SizedBox(height: 16),
            _buildTaskItem(
              task: "Ler o capítulo de requisitos de C1...",
              time: "06:38",
              tag: "#53",
            ),
            const SizedBox(height: 16),
            _buildTaskItem(
              task: "Enviar o artigo pra Gabriel",
              time: "02:35",
              tag: "#93 49",
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Adicionar novo item aqui
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