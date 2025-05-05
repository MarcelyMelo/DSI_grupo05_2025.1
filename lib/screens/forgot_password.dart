import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:dsi_projeto/components/colors/loginScreen/textfield_login.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String? successMessage;
  String? errorMessage;

  void enviarEmailRecuperacao() {
    String email = emailController.text.trim();

    // Regex simples para validação de e-mail
    final bool emailValido = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);

    if (email.isEmpty) {
      setState(() {
        successMessage = null;
        errorMessage = "O campo de e-mail está vazio";
      });
    } else if (!emailValido) {
      setState(() {
        successMessage = null;
        errorMessage = "Formato de e-mail inválido";
      });
    } else if (email == "teste@email.com") {
      setState(() {
        successMessage = "Link de recuperação enviado para $email";
        errorMessage = null;
      });
    } else {
      setState(() {
        successMessage = null;
        errorMessage = "E-mail não encontrado";
      });
    }

    if (successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage!),
          backgroundColor: Colors.green,
        ),
      );
    } else if (errorMessage != null) {
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
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 150),
            Text(
              'Recuperar senha',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              'Informe seu e-mail para enviar um link de recuperação',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: MyTextField(
                controller: emailController,
                hintText: "E-mail",
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: enviarEmailRecuperacao,
                  child: Text("Enviar"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, "/login");
              },
              child: Text(
                "Voltar para login",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
