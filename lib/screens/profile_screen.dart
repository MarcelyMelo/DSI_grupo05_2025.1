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
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
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

  // Build profile image widget with proper handling of base64 and external URLs
  Widget _buildProfileImage() {
    // Priority: Firestore user image > Firebase Auth image > default icon

    // First, check if user has a profile image in Firestore
    if (_user?.profileImageUrl != null) {
      if (_user!.hasBase64Image) {
        // Display base64 image from Firestore
        final imageBytes = _user!.imageBytes;
        if (imageBytes != null) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Erro ao carregar imagem base64: $error');
                  return const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  );
                },
              ),
            ),
          );
        }
      } else if (_user!.hasExternalImage) {
        // Display external URL image from Firestore
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              _user!.profileImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Erro ao carregar imagem externa: $error');
                return const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                );
              },
            ),
          ),
        );
      }
    }

    // Fallback to Firebase Auth photo if no Firestore image
    if (_firebaseUser?.photoURL != null) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            _firebaseUser!.photoURL!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Erro ao carregar foto do Firebase Auth: $error');
              return const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              );
            },
          ),
        ),
      );
    }

    // Default avatar if no image is available
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.white,
      ),
    );
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

        // MAIN CHANGE: Use Flexible instead of Expanded and SingleChildScrollView
        Flexible(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Avatar - Made smaller to save space
                  _buildProfileImage(),

                  const SizedBox(height: 20),

                  // Welcome text
                  const Text(
                    'Bem-vindo(a)!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // User name - prioriza dados do Firestore, depois Firebase Auth
                  Text(
                    _user?.name ?? _firebaseUser?.displayName ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 16,
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

                  const SizedBox(height: 24),

                  // Stats section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Study hours card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
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
                                  fontSize: 24,
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
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
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
                                        fontSize: 20,
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
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
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
                                        fontSize: 20,
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

                  // Add bottom padding to ensure content doesn't touch the bottom
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
