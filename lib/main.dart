import 'package:dsi_projeto/screens/forgot_password.dart';
import 'package:dsi_projeto/screens/home_screen.dart';
import 'package:dsi_projeto/screens/login_screen.dart';
import 'package:dsi_projeto/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:dsi_projeto/screens/pomodoro_screen.dart'; // 🔹 adicione essa linha

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/forgotPassword': (context) => const ForgotPasswordScreen(),
          '/pomodoro': (context) => const PomodoroScreen(), // 🔹 nova rota

        },
        home: const LoginScreen());
  }
}
