import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:dsi_projeto/components/colors/loginScreen/signin_button.dart';
import 'package:dsi_projeto/components/colors/loginScreen/textfield_login.dart';
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
        backgroundColor: AppColors.black,
        body: Column(
          children: [
            SizedBox(height: 150),
            Text(
              'Bem-vindo de volta, sentimos sua falta',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: MyTextField(
                      controller: emailController,
                      hintText: "E-mail",
                    ),
                  ),
                  MyTextField(
                    controller: senhaController,
                    isPassword: true,
                    hintText: "Senha",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                  )
                ],
              ),
            ),
            MySignInButton(
              onTap: fazerLogin,
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
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
    );
  }
}
