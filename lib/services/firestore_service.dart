import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/collection.dart';
import '../models/flashcard.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obter o ID do usuário atual
  String? get _currentUserId => _auth.currentUser?.uid;

  // Referência para as coleções do usuário atual
  CollectionReference? get _userCollectionsRef {
    if (_currentUserId == null) return null;
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('collections');
  }

  // ========== MÉTODOS PARA COLEÇÕES ==========

  // Adicionar uma nova coleção
  Future<void> addCollection(Collection collection) async {
    if (_userCollectionsRef == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      await _userCollectionsRef!.doc(collection.name).set({
        'name': collection.name,
        'createdAt': collection.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Adicionar flashcards se existirem
      if (collection.flashcards.isNotEmpty) {
        final batch = _firestore.batch();
        final flashcardsRef =
            _userCollectionsRef!.doc(collection.name).collection('flashcards');

        for (int i = 0; i < collection.flashcards.length; i++) {
          final flashcard = collection.flashcards[i];
          batch.set(flashcardsRef.doc(), {
            'question': flashcard.question,
            'answer': flashcard.answer,
            'isKnown': flashcard.isKnown,
            'createdAt': DateTime.now().toIso8601String(),
            'order': i,
          });
        }
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Erro ao adicionar coleção: $e');
    }
  }

  // Obter todas as coleções do usuário
  Future<List<Collection>> getAllCollections() async {
    if (_userCollectionsRef == null) {
      return [];
    }

    try {
      final querySnapshot = await _userCollectionsRef!.get();
      final List<Collection> collections = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Obter flashcards desta coleção
        final flashcards = await _getFlashcardsForCollection(doc.id);

        collections.add(Collection(
          name: data['name'],
          flashcards: flashcards,
          createdAt: DateTime.parse(data['createdAt']),
        ));
      }

      // Ordenar por data de criação (mais recente primeiro)
      collections.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return collections;
    } catch (e) {
      throw Exception('Erro ao carregar coleções: $e');
    }
  }

  // Obter uma coleção específica
  Future<Collection?> getCollectionByName(String name) async {
    if (_userCollectionsRef == null) return null;

    try {
      final doc = await _userCollectionsRef!.doc(name).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final flashcards = await _getFlashcardsForCollection(name);

      return Collection(
        name: data['name'],
        flashcards: flashcards,
        createdAt: DateTime.parse(data['createdAt']),
      );
    } catch (e) {
      throw Exception('Erro ao carregar coleção: $e');
    }
  }

  // Remover uma coleção
  Future<void> removeCollection(String name) async {
    if (_userCollectionsRef == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final batch = _firestore.batch();

      // Remover todos os flashcards da coleção
      final flashcardsRef =
          _userCollectionsRef!.doc(name).collection('flashcards');

      final flashcardsSnapshot = await flashcardsRef.get();
      for (final doc in flashcardsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Remover a coleção
      batch.delete(_userCollectionsRef!.doc(name));

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao remover coleção: $e');
    }
  }

  // Atualizar uma coleção (renomear)
  Future<void> updateCollectionName(String oldName, String newName) async {
    if (_userCollectionsRef == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Obter a coleção atual
      final oldDoc = await _userCollectionsRef!.doc(oldName).get();
      if (!oldDoc.exists) {
        throw Exception('Coleção não encontrada');
      }

      final data = oldDoc.data() as Map<String, dynamic>;

      // Criar nova coleção com o novo nome
      await _userCollectionsRef!.doc(newName).set({
        'name': newName,
        'createdAt': data['createdAt'],
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Copiar todos os flashcards
      final oldFlashcardsRef =
          _userCollectionsRef!.doc(oldName).collection('flashcards');
      final newFlashcardsRef =
          _userCollectionsRef!.doc(newName).collection('flashcards');

      final flashcardsSnapshot = await oldFlashcardsRef.get();
      final batch = _firestore.batch();

      for (final doc in flashcardsSnapshot.docs) {
        batch.set(newFlashcardsRef.doc(), doc.data());
      }

      await batch.commit();

      // Remover a coleção antiga
      await removeCollection(oldName);
    } catch (e) {
      throw Exception('Erro ao atualizar nome da coleção: $e');
    }
  }

  // ========== MÉTODOS PARA FLASHCARDS ==========

  // Obter flashcards de uma coleção
  Future<List<Flashcard>> _getFlashcardsForCollection(
      String collectionName) async {
    if (_userCollectionsRef == null) return [];

    try {
      final flashcardsRef =
          _userCollectionsRef!.doc(collectionName).collection('flashcards');

      final querySnapshot =
          await flashcardsRef.orderBy('order', descending: false).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Flashcard(
          question: data['question'],
          answer: data['answer'],
          isKnown: data['isKnown'] ?? false,
        );
      }).toList();
    } catch (e) {
      // Se não existe o campo 'order', tenta sem ordenação
      try {
        final flashcardsRef =
            _userCollectionsRef!.doc(collectionName).collection('flashcards');

        final querySnapshot = await flashcardsRef.get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Flashcard(
            question: data['question'],
            answer: data['answer'],
            isKnown: data['isKnown'] ?? false,
          );
        }).toList();
      } catch (e2) {
        throw Exception('Erro ao carregar flashcards: $e2');
      }
    }
  }

  // Adicionar flashcard a uma coleção
  Future<void> addFlashcardToCollection(
      String collectionName, Flashcard flashcard) async {
    if (_userCollectionsRef == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Verificar se a coleção existe
      final collectionDoc =
          await _userCollectionsRef!.doc(collectionName).get();
      if (!collectionDoc.exists) {
        throw Exception('Coleção não encontrada');
      }

      // Obter o próximo número de ordem
      final flashcardsRef =
          _userCollectionsRef!.doc(collectionName).collection('flashcards');

      final snapshot = await flashcardsRef.get();
      final nextOrder = snapshot.docs.length;

      // Adicionar o flashcard
      await flashcardsRef.add({
        'question': flashcard.question,
        'answer': flashcard.answer,
        'isKnown': flashcard.isKnown,
        'createdAt': DateTime.now().toIso8601String(),
        'order': nextOrder,
      });

      // Atualizar a data de modificação da coleção
      await _userCollectionsRef!.doc(collectionName).update({
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar flashcard: $e');
    }
  }

  // Remover flashcard de uma coleção
  Future<void> removeFlashcardFromCollection(
      String collectionName, int flashcardIndex) async {
    if (_userCollectionsRef == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final flashcardsRef =
          _userCollectionsRef!.doc(collectionName).collection('flashcards');

      final querySnapshot =
          await flashcardsRef.orderBy('order', descending: false).get();

      if (flashcardIndex >= 0 && flashcardIndex < querySnapshot.docs.length) {
        await querySnapshot.docs[flashcardIndex].reference.delete();

        // Atualizar a data de modificação da coleção
        await _userCollectionsRef!.doc(collectionName).update({
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao remover flashcard: $e');
    }
  }

  // Limpar todos os flashcards de uma coleção
  Future<void> clearCollectionFlashcards(String collectionName) async {
    if (_userCollectionsRef == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final flashcardsRef =
          _userCollectionsRef!.doc(collectionName).collection('flashcards');

      final querySnapshot = await flashcardsRef.get();
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Atualizar a data de modificação da coleção
      await _userCollectionsRef!.doc(collectionName).update({
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao limpar flashcards: $e');
    }
  }

  // Atualizar status de um flashcard (conhecido/não conhecido)
  Future<void> updateFlashcardStatus(
      String collectionName, int flashcardIndex, bool isKnown) async {
    if (_userCollectionsRef == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final flashcardsRef =
          _userCollectionsRef!.doc(collectionName).collection('flashcards');

      final querySnapshot =
          await flashcardsRef.orderBy('order', descending: false).get();

      if (flashcardIndex >= 0 && flashcardIndex < querySnapshot.docs.length) {
        await querySnapshot.docs[flashcardIndex].reference.update({
          'isKnown': isKnown,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao atualizar flashcard: $e');
    }
  }

  // ========== MÉTODOS UTILITÁRIOS ==========

  // Stream para escutar mudanças nas coleções em tempo real
  Stream<List<Collection>> collectionsStream() {
    if (_userCollectionsRef == null) {
      return Stream.value([]);
    }

    return _userCollectionsRef!.snapshots().asyncMap((snapshot) async {
      final List<Collection> collections = [];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final flashcards = await _getFlashcardsForCollection(doc.id);

        collections.add(Collection(
          name: data['name'],
          flashcards: flashcards,
          createdAt: DateTime.parse(data['createdAt']),
        ));
      }

      collections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return collections;
    });
  }

  // Verificar se o usuário está autenticado
  bool get isUserAuthenticated => _currentUserId != null;

  // Obter estatísticas do usuário
  Future<Map<String, int>> getUserStats() async {
    if (_userCollectionsRef == null) {
      return {'collections': 0, 'flashcards': 0, 'knownFlashcards': 0};
    }

    try {
      final collections = await getAllCollections();
      int totalFlashcards = 0;
      int knownFlashcards = 0;

      for (final collection in collections) {
        totalFlashcards += collection.flashcards.length;
        knownFlashcards += collection.flashcards.where((f) => f.isKnown).length;
      }

      return {
        'collections': collections.length,
        'flashcards': totalFlashcards,
        'knownFlashcards': knownFlashcards,
      };
    } catch (e) {
      return {'collections': 0, 'flashcards': 0, 'knownFlashcards': 0};
    }
  }
}
