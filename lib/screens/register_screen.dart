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
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                AppColors.blue,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão de voltar alinhado à esquerda
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Colors.black,
                      onPressed: _isLoading ? null : () {
                        Navigator.popAndPushNamed(context, "/login");
                      },
                    ),
                  ),

                  // Título e subtítulo alinhados à esquerda
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Inscreva-se",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Adicione seu nome, e-mail e senha",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Campos do formulário
                  TextFieldRegister(
                    controller: nomeController,
                    hintText: "Seu nome",
                  ),
                  SizedBox(height: 16),
                  TextFieldRegister(
                    controller: emailController,
                    isEmail: true,
                    hintText: "Seu e-mail",
                  ),
                  SizedBox(height: 16),
                  TextFieldRegister(
                    controller: senhaController,
                    isPassword: true,
                    hintText: "Sua senha",
                  ),
                  SizedBox(height: 30),

                  // Botão de inscrição
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : registrarConta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              "Inscreva-se",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Link para login - CENTRALIZADO
                  Center(
                    child: TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.popAndPushNamed(context, "/login");
                      },
                      child: Text(
                        'Já tem uma conta? Entrar',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Termos e condições
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'Ao continuar com os serviços acima, você concorda com os ',
                        ),
                        TextSpan(
                          text: 'Termos de Serviço',
                          style: TextStyle(
                            color: AppColors.black,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navegar para tela de termos
                            },
                        ),
                        TextSpan(
                          text:
                              ', aceitando o repasse de todos os seus bens para o nome da empresa e com a ',
                        ),
                        TextSpan(
                          text: 'Política de Privacidade',
                          style: TextStyle(
                            color: AppColors.black,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}