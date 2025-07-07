import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class UserService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = uid;
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  // Convert image file to base64 string
  Future<String?> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      // Check file size (recommend max 500KB for Firestore)
      if (bytes.length > 500000) {
        throw Exception('Imagem muito grande. Máximo 500KB permitido.');
      }
      return base64Encode(bytes);
    } catch (e) {
      print('Erro ao converter imagem: $e');
      throw Exception('Erro ao processar imagem: $e');
    }
  }

  // Convert web image bytes to base64 string
  String? _convertWebImageToBase64(Uint8List imageBytes) {
    try {
      // Check file size (recommend max 500KB for Firestore)
      if (imageBytes.length > 500000) {
        throw Exception('Imagem muito grande. Máximo 500KB permitido.');
      }
      return base64Encode(imageBytes);
    } catch (e) {
      print('Erro ao converter imagem web: $e');
      throw Exception('Erro ao processar imagem: $e');
    }
  }

  // Create or update user in Firebase
  Future<void> createOrUpdateUserInFirebase(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar usuário no Firebase: $e');
      throw Exception('Erro ao salvar usuário no Firebase: $e');
    }
  }

  // Get current logged user
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        UserModel? firebaseUser = await getUserById(currentUser.uid);

        if (firebaseUser == null) {
          firebaseUser = UserModel(
            id: currentUser.uid,
            name: currentUser.displayName ?? 'Usuário',
            email: currentUser.email ?? '',
            profileImageUrl:
                currentUser.photoURL, // Keep this for external URLs
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            studyTimeMinutes: 0,
            completedActivities: 0,
            completionRate: 0,
          );

          await createOrUpdateUserInFirebase(firebaseUser);
        }

        await saveUser(firebaseUser);
        return firebaseUser;
      }

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = json.decode(userJson);
        return UserModel.fromJson(userMap);
      }

      return null;
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      return null;
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
            ? currentUser.studyTimeMinutes + additionalStudyMinutes
            : currentUser.studyTimeMinutes,
        completedActivities:
            completedActivities ?? currentUser.completedActivities,
        lastLoginAt: DateTime.now(),
      );

      await createOrUpdateUserInFirebase(updatedUser);
      await saveUser(updatedUser);

      return updatedUser;
    } catch (e) {
      throw Exception('Erro ao atualizar progresso: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      return currentUser != null;
    } catch (e) {
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
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
        'studyTimeInMinutes': user.studyTimeMinutes,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // Sync user data from Firebase
  Future<UserModel?> syncUserFromFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final firebaseUser = await getUserById(currentUser.uid);
      if (firebaseUser != null) {
        await saveUser(firebaseUser);
      }
      return firebaseUser;
    } catch (e) {
      print('Erro ao sincronizar dados: $e');
      return null;
    }
  }

  // Updated updateUserProfile method - now stores base64 images
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    File? profileImageFile,
    Uint8List? webImageBytes,
    String? webImageName,
    String? profileImageUrl,
    bool removeImage = false,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw Exception('Usuário não autenticado');
      }
// Update Firebase Auth profile
      if (name != null) {
        await currentUser.updateDisplayName(name);
      }
// Don't update photoURL since we're using profileImageUrl in Firestore
      await currentUser.reload();

// Update Firebase Auth email if provided
      if (email != null && email != currentUser.email) {
        await currentUser.verifyBeforeUpdateEmail(email);
        await currentUser.reload();
      }
      UserModel? existingUser = await getUserById(userId);

      if (existingUser == null) {
        existingUser = UserModel(
          id: userId,
          name: currentUser.displayName ?? name ?? 'Usuário',
          email: currentUser.email ?? email ?? '',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          studyTimeMinutes: 0,
          completedActivities: 0,
          completionRate: 0,
        );
      }

      String? imageData = existingUser.profileImageUrl;

      // Handle image operations
      if (removeImage) {
        imageData = null;
      } else if (kIsWeb && webImageBytes != null) {
        // Convert web image to base64
        final base64String = _convertWebImageToBase64(webImageBytes);
        imageData = 'data:image/jpeg;base64,$base64String';
      } else if (!kIsWeb && profileImageFile != null) {
        // Convert mobile image to base64
        final base64String = await _convertImageToBase64(profileImageFile);
        imageData = 'data:image/jpeg;base64,$base64String';
      } else if (profileImageUrl != null) {
        // Use provided URL (for external images)
        imageData = profileImageUrl;
      }

      // Create updated user model
      final updatedUser = existingUser.copyWith(
        name: name,
        email: email,
        profileImageUrl: imageData,
        lastLoginAt: DateTime.now(),
      );

      // Save to Firebase
      await createOrUpdateUserInFirebase(updatedUser);

      // Update Firebase Auth profile
      if (name != null) {
        await currentUser.updateDisplayName(name);
        await currentUser.reload();
      }

      // Save locally for offline access
      await saveUser(updatedUser);
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }
}
