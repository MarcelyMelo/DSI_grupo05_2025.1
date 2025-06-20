import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  UserModel? _user;
  User? _firebaseUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Pegar o usuário atual do Firebase Auth
      _firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (_firebaseUser != null) {
        print('UID do usuário: ${_firebaseUser!.uid}');
        print('Email: ${_firebaseUser!.email}');
        print('Nome (displayName): ${_firebaseUser!.displayName}');
        
        // Carregar dados completos do usuário do Firestore
        _user = await _userService.getUserById(_firebaseUser!.uid);
        
        // Se não encontrou no Firestore, criar um usuário básico com dados do Auth
        if (_user == null && _firebaseUser != null) {
          _user = UserModel(
            id: _firebaseUser!.uid,
            name: _firebaseUser!.displayName ?? 'Usuário',
            email: _firebaseUser!.email ?? '',
            // Valores padrão para campos que podem não existir
            studyTimeMinutes: 0,
            completedActivities: 0,
            completionRate: 0,
          );
        }
        
        // Ouvir mudanças no estado de autenticação
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null) {
            print('Estado de autenticação mudou: ${user.uid}');
            // Se o usuário mudou, recarregar dados
            if (_firebaseUser?.uid != user.uid) {
              _loadUserData();
            }
          } else {
            // Usuário deslogou, redirecionar para login
            print('Usuário deslogado');
            // Navigator.of(context).pushReplacementNamed('/login');
          }
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() {
        _isLoading = false;
      });
      // Mostrar erro para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para pegar informações específicas do provedor
  Map<String, String> _getProviderInfo() {
    if (_firebaseUser == null) return {};
    
    Map<String, String> providerInfo = {};
    
    for (final providerProfile in _firebaseUser!.providerData) {
      // ID do provedor (google.com, apple.com, password, etc.)
      final provider = providerProfile.providerId;
      
      // UID específico do provedor
      final uid = providerProfile.uid;
      
      // Nome, email e foto do perfil
      final name = providerProfile.displayName;
      final emailAddress = providerProfile.email;
      final profilePhoto = providerProfile.photoURL;
      
      providerInfo[provider] = 'Nome: $name, Email: $emailAddress';
      
      print('Provedor: $provider');
      print('UID do provedor: $uid');
      print('Nome: $name');
      print('Email: $emailAddress');
      print('Foto: $profilePhoto');
    }
    
    return providerInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF34495E),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : _buildProfileContent(),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    // Se não há usuário logado
    if (_firebaseUser == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum usuário logado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with edit button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Editar perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (_user != null) {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: _user!),
                      ),
                    );

                    // Reload user data if profile was updated
                    if (result == true) {
                      _loadUserData();
                    }
                  }
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Profile Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    shape: BoxShape.circle,
                    image: _firebaseUser?.photoURL != null
                        ? DecorationImage(
                            image: NetworkImage(_firebaseUser!.photoURL!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _firebaseUser?.photoURL == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        )
                      : null,
                ),

                const SizedBox(height: 24),

                // Welcome text
                const Text(
                  'Bem-vindo(a)!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 8),

                // User name - prioriza dados do Firestore, depois Firebase Auth
                Text(
                  _user?.name ?? _firebaseUser?.displayName ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Email do usuário
                const SizedBox(height: 4),
                Text(
                  _firebaseUser?.email ?? 'Email não disponível',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF95A5A6),
                  ),
                ),

                const SizedBox(height: 40),

                // Stats section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Study hours card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Horas Estudadas',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7F8C8D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _user?.getFormattedStudyTime() ?? '0h00min',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bottom stats row
                      Row(
                        children: [
                          // Activities completed
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Atividades\nrealizadas',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7F8C8D),
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_user?.completedActivities ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Completion rate
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Taxa de\nconclusão atual',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7F8C8D),
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_user?.completionRate ?? 0}%',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}