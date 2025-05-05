import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:flutter/material.dart';
import '../components/colors/loginScreen/textfield_login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  void registrarConta() {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Preencha todos os campos"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("E-mail inválido"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Senha deve ter pelo menos 6 caracteres"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Sucesso (mock)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Conta criada com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );

    // Redireciona para tela de login após 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      Navigator.popAndPushNamed(context, "/login");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Cadastrar Conta",
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    MyTextField(
                      controller: nomeController,
                      hintText: "Nome",
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: MyTextField(
                        controller: emailController,
                        isEmail: true,
                        hintText: "E-mail",
                      ),
                    ),
                    MyTextField(
                      controller: senhaController,
                      isPassword: true,
                      hintText: "Senha",
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: registrarConta,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Cadastrar"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
