import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:dsi_projeto/components/icons/icon_login.dart';
import 'package:dsi_projeto/components/signin_button.dart';
import 'package:dsi_projeto/components/textfield_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  String? errorMessage;
  bool isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text,
      );
      
      if (mounted) {
        Navigator.popAndPushNamed(context, "/home");
      }
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      
      if (mounted) {
        setState(() {
          errorMessage = message;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFFE53E3E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return "Nenhum usuário encontrado para esse e-mail";
      case 'wrong-password':
        return "Senha incorreta";
      case 'invalid-email':
        return "E-mail inválido";
      case 'user-disabled':
        return "Usuário desativado";
      case 'too-many-requests':
        return "Muitas tentativas. Tente novamente mais tarde";
      default:
        return "Erro ao fazer login. Tente novamente";
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E3A4F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF2D4B5A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFFE2E8F0),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF64748B),
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFE53E3E), width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFE53E3E), width: 2),
          ),
          filled: true,
          fillColor: Color(0xFF1E3A4F),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : fazerLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              )
            : Text(
                "Entrar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF122530),
              Color(0xFF0F1F2B),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 40),

                      // Logo e texto principal
                      Column(
                        children: [
                          // Logo sem container ao redor
                          FocaIcon(),
                          SizedBox(height: 32),
                          Text(
                            'Bem-vindo de volta!',
                            style: TextStyle(
                              color: Color(0xFFF1F5F9),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Organize sua vida e rotina de estudos',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      SizedBox(height: 48),

                      // Campos do formulário
                      Column(
                        children: [
                          _buildTextField(
                            controller: emailController,
                            hintText: "Seu e-mail",
                            icon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu e-mail';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Por favor, insira um e-mail válido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: senhaController,
                            hintText: "Sua senha",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua senha';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 32),

                      // Botão de login
                      _buildLoginButton(),

                      SizedBox(height: 20),

                      // Link "Esqueci minha senha"
                      TextButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, "/forgotPassword");
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          "Esqueci minha senha",
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFF334155),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "ou",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFF334155),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32),

                      // Seção de cadastro
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E3A4F).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF334155),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Ainda não tem uma conta?',
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.popAndPushNamed(context, "/register");
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Color(0xFF64748B), width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    color: Color(0xFFF1F5F9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}