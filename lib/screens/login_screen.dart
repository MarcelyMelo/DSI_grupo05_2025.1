import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:dsi_projeto/components/icons/icon_login.dart';
import 'package:dsi_projeto/components/signin_button.dart';
import 'package:dsi_projeto/components/textfield_login.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  String? errorMessage;

  void fazerLogin() {
    String email = emailController.text.trim();
    String senha = senhaController.text;

    // Mock simples: e-mail e senha fixos
    if (email == "teste@email.com" && senha == "123456") {
      Navigator.popAndPushNamed(context, "/home");
    } else {
      setState(() {
        errorMessage = "E-mail ou senha incorretos";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage!,
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLogin,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 10), // Espaço mínimo no topo

              // Logo e texto
              Column(
                children: [
                  FocaIcon(),
                  SizedBox(height: 8), // Espaço reduzido
                  Text(
                    'Organize sua vida e rotina de estudos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15), // Espaço reduzido
                  Text(
                    'Entrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Espaço reduzido

              // Campos do formulário
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    MyTextField(
                      controller: emailController,
                      hintText: "Seu e-mail",
                    ),
                    SizedBox(height: 12), // Espaço reduzido
                    MyTextField(
                      controller: senhaController,
                      isPassword: true,
                      hintText: "Sua senha",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // Espaço reduzido

              // Botão de acesso
              MySignInButton(
                onTap: fazerLogin,
              ),
              SizedBox(height: 12), // Espaço reduzido

              // Link "Esqueci minha senha"
              TextButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, "/forgotPassword");
                },
                child: Text(
                  "Esqueci minha senha",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 15), // Espaço reduzido

              // Seção de cadastro
              Column(
                children: [
                  Text(
                    'Ainda não tem uma conta?',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 4), // Espaço reduzido
                  GestureDetector(
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/register");
                    },
                    child: Text(
                      'Inscreva-se',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10), // Espaço mínimo no final
            ],
          ),
        ),
      ),
    );
  }
}
