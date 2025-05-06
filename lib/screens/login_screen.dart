import 'package:dsi_projeto/components/colors/appColors.dart';
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
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.green,
                AppColors.blue,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 100),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.black,
                    onPressed: () {
                      Navigator.popAndPushNamed(context, "/login");
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          )),
                      Text(
                        'Adicione seu e-mail e senha',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: MyTextField(
                        controller: emailController,
                        hintText: "Seu e-mail",
                      ),
                    ),
                    MyTextField(
                      controller: senhaController,
                      isPassword: true,
                      hintText: "Sua senha",
                    ),
                  ],
                ),
              ),
              MySignInButton(
                onTap: fazerLogin,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.popAndPushNamed(context, "/forgotPassword");
                    },
                    child: Text(
                      "Esqueci minha senha",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não é membro?',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/register");
                    },
                    child: Text(
                      'Crie sua conta agora',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
