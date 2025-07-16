import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:dsi_projeto/components/textfield_login.dart';
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
          content: Text(
            successMessage!,
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (errorMessage != null) {
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
      backgroundColor: Color(0xFF1A2332), // Cor de fundo escura consistente
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // Header com botão de voltar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2A3441).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.popAndPushNamed(context, "/login");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Espaço flexível para centralizar conteúdo
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Título principal
                        Text(
                          'Esqueceu sua senha?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 12),
                        
                        // Subtítulo
                        Text(
                          'Para redefinir sua senha, por favor, insira seu endereço de e-mail.',
                          style: TextStyle(
                            color: Color(0xFF8B9AAF),
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 48),
                        
                        // Campo de e-mail customizado
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF2A3441).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFF3A4753).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: emailController,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "Seu e-mail",
                              hintStyle: TextStyle(
                                color: Color(0xFF8B9AAF),
                                fontSize: 16,
                              ),
                              prefixIcon: Container(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF8B9AAF),
                                  size: 20,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 32),
                        
                        // Botão de enviar
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF00D4AA),
                                Color(0xFF00B794),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF00D4AA).withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: enviarEmailRecuperacao,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Enviar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Link para voltar ao login
                        TextButton(
                          onPressed: () {
                            Navigator.popAndPushNamed(context, "/login");
                          },
                          child: Text(
                            "Já tem uma conta? Entrar",
                            style: TextStyle(
                              color: Color(0xFF8B9AAF),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}