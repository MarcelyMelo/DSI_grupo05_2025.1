import 'package:dsi_projeto/screens/create_collection_screen.dart';
import 'package:dsi_projeto/screens/flashcard_screen.dart';
import 'package:dsi_projeto/screens/forgot_password.dart';
import 'package:dsi_projeto/screens/home_screen.dart';
import 'package:dsi_projeto/screens/login_screen.dart';
import 'package:dsi_projeto/screens/profile_screen.dart';
import 'package:dsi_projeto/screens/register_screen.dart';
import 'package:dsi_projeto/services/collection_service.dart';
import 'package:flutter/material.dart';
import 'package:dsi_projeto/screens/pomodoro_screen.dart'; // 🔹 adicione essa linha
import 'package:dsi_projeto/screens/map_screen.dart'; // 🔹 adicione essa linha
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dsi_projeto/screens/pomodoro_screen.dart'; 
import 'package:dsi_projeto/screens/map_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/forgotPassword': (context) => const ForgotPasswordScreen(),
          '/pomodoro': (context) => const PomodoroScreen(),
          '/flashcards': (context) => const FlashcardScreen(),
          '/createCollection': (context) =>
              CreateCollectionScreen(collectionService: CollectionService()),
          '/profile': (context) => const ProfileScreen(),
          '/map': (context) => const MapScreen(),
        },
        home: LoginScreen());
  }
}
