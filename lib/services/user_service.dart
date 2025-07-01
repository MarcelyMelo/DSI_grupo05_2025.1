import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import 'dart:typed_data'; // Add this import
import 'package:flutter/foundation.dart'; // Add this import

class UserService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(
              'users') // Corrigido: deve ser 'users' para coincidir com as regras
          .doc(uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Adiciona o ID se não estiver presente nos dados
        data['id'] = uid;
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  // Create or update user in Firebase
  Future<void> createOrUpdateUserInFirebase(UserModel user) async {
    try {
      await _firestore
          .collection('users') // Corrigido: deve ser 'users'
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar usuário no Firebase: $e');
      throw Exception('Erro ao salvar usuário no Firebase: $e');
    }
  }

  // Upload profile image to Firebase Storage
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Remove a imagem anterior se existir
      try {
        final oldRef =
            _storage.ref().child('profile_images').child('$userId.jpg');
        await oldRef.delete();
      } catch (e) {
        // Ignorar erro se a imagem não existir
        print('Imagem anterior não encontrada ou já removida: $e');
      }

      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  // Delete profile image from Firebase Storage
  Future<void> deleteProfileImage(String userId) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      await ref.delete();
    } catch (e) {
      print('Erro ao deletar imagem do perfil: $e');
      // Não lança exceção pois a imagem pode não existir
    }
  }

  // Get current logged user (try Firebase first, then local storage)
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Try to get from Firebase first
        UserModel? firebaseUser = await getUserById(currentUser.uid);

        // If not found in Firebase, create from Auth data
        if (firebaseUser == null) {
          firebaseUser = UserModel(
            id: currentUser.uid,
            name: currentUser.displayName ?? 'Usuário',
            email: currentUser.email ?? '',
            profileImageUrl: currentUser.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            studyTimeMinutes: 0,
            completedActivities: 0,
            completionRate: 0,
          );

          // Save to Firebase for future use
          await createOrUpdateUserInFirebase(firebaseUser);
        }

        // Save locally and return
        await saveUser(firebaseUser);
        return firebaseUser;
      }

      // If no Firebase user, try local storage
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

      // Save to Firebase
      await createOrUpdateUserInFirebase(updatedUser);

      // Save locally
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

  // Sync user data from Firebase (useful for refreshing data)
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

  // Add this method to handle web image uploads
  Future<String?> uploadProfileImageWeb(
      String userId, Uint8List imageBytes, String fileName) async {
    try {
      // Remove the old image if it exists
      try {
        final oldRef =
            _storage.ref().child('profile_images').child('$userId.jpg');
        await oldRef.delete();
      } catch (e) {
        print('Imagem anterior não encontrada ou já removida: $e');
      }

      final ref = _storage.ref().child('profile_images').child('$userId.jpg');

      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId, 'originalName': fileName},
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem (web): $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

// Updated updateUserProfile method
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    File? profileImageFile,
    Uint8List? webImageBytes, // New parameter for web
    String? webImageName, // New parameter for web
    String? profileImageUrl,
    bool removeImage = false,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw Exception('Usuário não autenticado');
      }

      // Get current user data from Firebase
      UserModel? existingUser = await getUserById(userId);

      // If user doesn't exist in Firestore, create a basic one
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

      String? imageUrl = existingUser.profileImageUrl;

      // Handle image operations
      if (removeImage) {
        // Remove image
        if (imageUrl != null) {
          await deleteProfileImage(userId);
        }
        imageUrl = null;
      } else if (kIsWeb && webImageBytes != null) {
        // Upload web image
        imageUrl = await uploadProfileImageWeb(
            userId, webImageBytes, webImageName ?? 'profile.jpg');
      } else if (!kIsWeb && profileImageFile != null) {
        // Upload mobile image
        imageUrl = await uploadProfileImage(userId, profileImageFile);
      } else if (profileImageUrl != null) {
        // Use provided URL
        imageUrl = profileImageUrl;
      }

      // Create updated user model
      final updatedUser = existingUser.copyWith(
        name: name,
        email: email,
        profileImageUrl: imageUrl,
        lastLoginAt: DateTime.now(),
      );

      // Save to Firebase
      await createOrUpdateUserInFirebase(updatedUser);

      // Update Firebase Auth profile
      if (name != null || imageUrl != existingUser.profileImageUrl) {
        await currentUser.updateDisplayName(name ?? currentUser.displayName);
        await currentUser.updatePhotoURL(imageUrl);
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
