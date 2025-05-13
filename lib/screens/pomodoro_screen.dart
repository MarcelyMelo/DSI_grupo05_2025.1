import 'package:flutter/material.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Pomodoro", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Tela de Pomodoro',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
