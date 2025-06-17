import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Get current logged user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = json.decode(userJson);
        return UserModel.fromJson(userMap);
      }

      // Return mock data if no user is stored (for testing)
      return _getMockUser();
    } catch (e) {
      throw Exception('Erro ao carregar dados do usuário: $e');
    }
  }

  // Save user data locally
  Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      throw Exception('Erro ao salvar dados do usuário: $e');
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não encontrado');
      }

      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
        profileImageUrl: profileImageUrl,
      );

      await saveUser(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  // Update study progress
  Future<UserModel> updateStudyProgress({
    required String userId,
    int? additionalStudyMinutes,
    int? completedActivities,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não encontrado');
      }

      final updatedUser = currentUser.copyWith(
        studyTimeInMinutes: additionalStudyMinutes != null
            ? currentUser.studyTimeInMinutes + additionalStudyMinutes
            : currentUser.studyTimeInMinutes,
        completedActivities:
            completedActivities ?? currentUser.completedActivities,
        lastLoginAt: DateTime.now(),
      );

      await saveUser(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Erro ao atualizar progresso: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  // Clear all user data
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_isLoggedInKey);
    } catch (e) {
      throw Exception('Erro ao limpar dados do usuário: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('Usuário não encontrado');
      }

      return {
        'studyTime': user.getFormattedStudyTime(),
        'completedActivities': user.completedActivities,
        'completionRate': user.completionRate,
        'totalActivities': user.totalActivities,
        'studyTimeInMinutes': user.studyTimeInMinutes,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // Mock user for testing (remove in production)
  UserModel _getMockUser() {
    return UserModel(
      id: 'mock_user_123',
      name: 'João Silva',
      email: 'joao.silva@email.com',
      studyTimeInMinutes: 4223, // 70h23min
      completedActivities: 55,
      totalActivities: 275, // This gives us 20% completion rate
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
    );
  }

  // Simulate login (replace with real authentication)
  Future<UserModel> login(String email, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation
      if (email.isNotEmpty && password.isNotEmpty) {
        final user = _getMockUser().copyWith(
          email: email,
          lastLoginAt: DateTime.now(),
        );

        await saveUser(user);
        return user;
      } else {
        throw Exception('Email e senha são obrigatórios');
      }
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  // Simulate registration (replace with real API)
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        studyTimeInMinutes: 0,
        completedActivities: 0,
        totalActivities: 0,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await saveUser(user);
      return user;
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }
}
