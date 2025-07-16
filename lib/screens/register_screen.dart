import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:dsi_projeto/components/textfield_register.dart';
import 'package:flutter/material.dart';

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
  
  bool _isLoading = false;

  Future<void> registrarConta() async {
    // Validate form first
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      _showSnackBar("Preencha todos os campos", Colors.red);
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      _showSnackBar("E-mail inválido", Colors.red);
      return;
    }

    if (senha.length < 6) {
      _showSnackBar("Senha deve ter pelo menos 6 caracteres", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Update display name in Auth
      await credential.user?.updateDisplayName(nome);

      // Create user document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'name': nome,
        'email': email,
        'photoURL': null, // Will be added later in edit profile
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Success
      _showSnackBar("Conta criada com sucesso!", Colors.green);

      // Navigate to login after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.popAndPushNamed(context, "/login");
        }
      });

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'A senha é muito fraca.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Este e-mail já está em uso.';
          break;
        case 'invalid-email':
          errorMessage = 'E-mail inválido.';
          break;
        default:
          errorMessage = 'Erro ao criar conta: ${e.message}';
      }
      _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      _showSnackBar('Erro inesperado: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E3A3F), // Fundo azul escuro
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                
                // Botão de voltar
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: _isLoading ? null : () {
                    Navigator.popAndPushNamed(context, "/login");
                  },
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título e subtítulo centralizados
                      Column(
                        children: [
                          Text(
                            "Criar conta",
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Preencha seus dados para começar",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),

                      // Campo Nome
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2A4B52),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: nomeController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Seu nome completo",
                            hintStyle: TextStyle(color: Colors.white60),
                            prefixIcon: Icon(Icons.person_outline, color: Colors.white60),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Campo E-mail
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2A4B52),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Seu e-mail",
                            hintStyle: TextStyle(color: Colors.white60),
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.white60),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Campo Senha
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2A4B52),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: senhaController,
                          style: TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Sua senha",
                            hintStyle: TextStyle(color: Colors.white60),
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.white60),
                            suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.white60),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),

                      // Botão Criar conta
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : registrarConta,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00C896), // Verde
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : Text(
                                  "Criar conta",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Link para login
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.popAndPushNamed(context, "/login");
                          },
                          child: Text(
                            'Já tem uma conta? Entrar',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),

                      // Linha separadora
                      Container(
                        height: 1,
                        color: Colors.white30,
                        margin: EdgeInsets.symmetric(horizontal: 40),
                      ),
                      SizedBox(height: 8),
                      
                      // Texto "termos"
                      Text(
                        'termos',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Termos e condições
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF2A4B52),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Ao criar uma conta, você concorda com nossos ',
                              ),
                              TextSpan(
                                text: 'Termos de Serviço',
                                style: TextStyle(
                                  color: Color(0xFF4A9EFF),
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navegar para tela de termos
                                  },
                              ),
                              TextSpan(
                                text: ' e ',
                              ),
                              TextSpan(
                                text: 'Política de Privacidade',
                                style: TextStyle(
                                  color: Color(0xFF4A9EFF),
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navegar para tela de política de privacidade
                                  },
                              ),
                              TextSpan(
                                text: '.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}