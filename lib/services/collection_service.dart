import '../models/collection.dart';
import '../models/flashcard.dart';
import 'firestore_service.dart';

class CollectionService {
  final FirestoreService _firestoreService = FirestoreService();
  List<Collection> _collections = [];
  bool _isLoading = false;

  // Getter para verificar se está carregando
  bool get isLoading => _isLoading;

  // Getter para as coleções em cache
  List<Collection> get collections => List.unmodifiable(_collections);

  // ========== MÉTODOS PARA COLEÇÕES ==========

  // Inicializar e carregar dados do Firestore
  Future<void> initialize() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    if (!_firestoreService.isUserAuthenticated) {
      _collections = [];
      return;
    }

    _isLoading = true;
    try {
      _collections = await _firestoreService.getAllCollections();
    } catch (e) {
      print('Erro ao inicializar CollectionService: $e');
      _collections = [];
    } finally {
      _isLoading = false;
    }
  }

  // Adicionar uma nova coleção
  Future<void> addCollection(Collection collection) async {
    try {
      await _firestoreService.addCollection(collection);

      // Atualizar cache local
      _collections.add(collection);
      _collections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Erro ao adicionar coleção: $e');
    }
  }

  // Remover uma coleção pelo nome
  Future<void> removeCollection(String name) async {
    try {
      await _firestoreService.removeCollection(name);

      // Atualizar cache local
      _collections.removeWhere((collection) => collection.name == name);
    } catch (e) {
      throw Exception('Erro ao remover coleção: $e');
    }
  }

  // Obter todas as coleções (do cache ou Firestore)
  Future<List<Collection>> getAllCollections() async {
    if (_collections.isEmpty && !_isLoading) {
      await initialize();
    }
    return List.unmodifiable(_collections);
  }

  // Obter coleções de forma síncrona (do cache)
  List<Collection> getAllCollectionsSync() {
    return List.unmodifiable(_collections);
  }

  // Obter uma coleção pelo nome
  Collection? getCollectionByName(String name) {
    try {
      return _collections.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  // Obter uma coleção pelo nome do Firestore
  Future<Collection?> getCollectionByNameFromFirestore(String name) async {
    try {
      final collection = await _firestoreService.getCollectionByName(name);

      // Atualizar no cache se encontrou
      if (collection != null) {
        final index = _collections.indexWhere((c) => c.name == name);
        if (index != -1) {
          _collections[index] = collection;
        } else {
          _collections.add(collection);
          _collections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      }

      return collection;
    } catch (e) {
      throw Exception('Erro ao buscar coleção: $e');
    }
  }

  // Atualizar nome de uma coleção
  Future<void> updateCollectionName(String oldName, String newName) async {
    try {
      await _firestoreService.updateCollectionName(oldName, newName);

      // Atualizar cache local
      final collection = _collections.firstWhere((c) => c.name == oldName);
      final index = _collections.indexOf(collection);
      if (index != -1) {
        final updatedCollection = Collection(
          name: newName,
          flashcards: collection.flashcards,
          createdAt: collection.createdAt,
        );
        _collections[index] = updatedCollection;
      }
    } catch (e) {
      throw Exception('Erro ao atualizar nome da coleção: $e');
    }
  }

  // ========== MÉTODOS PARA FLASHCARDS ==========

  // Adicionar um flashcard a uma coleção
  Future<void> addFlashcardToCollection(
      String collectionName, Flashcard flashcard) async {
    try {
      await _firestoreService.addFlashcardToCollection(
          collectionName, flashcard);

      // Atualizar cache local
      final collection =
          _collections.firstWhere((c) => c.name == collectionName);
      collection.flashcards.add(flashcard);
    } catch (e) {
      throw Exception('Erro ao adicionar flashcard: $e');
    }
  }

  // Remover um flashcard de uma coleção
  Future<void> removeFlashcardFromCollection(
      String collectionName, int flashcardIndex) async {
    try {
      await _firestoreService.removeFlashcardFromCollection(
          collectionName, flashcardIndex);

      // Atualizar cache local
      final collection =
          _collections.firstWhere((c) => c.name == collectionName);
      if (flashcardIndex >= 0 &&
          flashcardIndex < collection.flashcards.length) {
        collection.flashcards.removeAt(flashcardIndex);
      }
    } catch (e) {
      throw Exception('Erro ao remover flashcard: $e');
    }
  }

  // Limpar todos os flashcards de uma coleção
  Future<void> clearCollectionFlashcards(String collectionName) async {
    try {
      await _firestoreService.clearCollectionFlashcards(collectionName);

      // Atualizar cache local
      final collection =
          _collections.firstWhere((c) => c.name == collectionName);
      collection.flashcards.clear();
    } catch (e) {
      throw Exception('Erro ao limpar flashcards: $e');
    }
  }

  // Atualizar status de um flashcard
  Future<void> updateFlashcardStatus(
      String collectionName, int flashcardIndex, bool isKnown) async {
    try {
      await _firestoreService.updateFlashcardStatus(
          collectionName, flashcardIndex, isKnown);

      // Atualizar cache local
      final collection =
          _collections.firstWhere((c) => c.name == collectionName);
      if (flashcardIndex >= 0 &&
          flashcardIndex < collection.flashcards.length) {
        collection.flashcards[flashcardIndex].isKnown = isKnown;
      }
    } catch (e) {
      throw Exception('Erro ao atualizar status do flashcard: $e');
    }
  }

  // Atualizar uma coleção completa (usado na edição)
  Future<void> updateCollection(
      String oldName, Collection updatedCollection) async {
    try {
      // Se o nome mudou, usar o método específico
      if (oldName != updatedCollection.name) {
        await updateCollectionName(oldName, updatedCollection.name);
      }

      // Atualizar flashcards - remover todos e adicionar os novos
      await clearCollectionFlashcards(updatedCollection.name);

      for (final flashcard in updatedCollection.flashcards) {
        await _firestoreService.addFlashcardToCollection(
            updatedCollection.name, flashcard);
      }

      // Atualizar cache local
      final index = _collections.indexWhere(
          (c) => c.name == oldName || c.name == updatedCollection.name);
      if (index != -1) {
        _collections[index] = updatedCollection;
      }
    } catch (e) {
      throw Exception('Erro ao atualizar coleção: $e');
    }
  }

  // ========== MÉTODOS UTILITÁRIOS ==========

  // Recarregar dados do Firestore
  Future<void> refresh() async {
    await initialize();
  }

  // Stream para escutar mudanças em tempo real
  Stream<List<Collection>> get collectionsStream {
    return _firestoreService.collectionsStream();
  }

  // Obter estatísticas do usuário
  Future<Map<String, int>> getUserStats() async {
    return await _firestoreService.getUserStats();
  }

  // Verificar se o usuário está autenticado
  bool get isUserAuthenticated => _firestoreService.isUserAuthenticated;

  // Limpar cache (útil para logout)
  void clearCache() {
    _collections.clear();
    _isLoading = false;
  }

  // Método para adicionar dados de exemplo (apenas para desenvolvimento)
  Future<void> addSampleData() async {
    if (!isUserAuthenticated) return;

    try {
      // Verificar se já existem coleções
      final existingCollections = await getAllCollections();
      if (existingCollections.isNotEmpty) return;

      // Adicionar coleções de exemplo
      final sampleCollections = [
        Collection(
          name: 'Matemática',
          flashcards: [
            Flashcard(question: '2 + 2', answer: '4'),
            Flashcard(question: '5 × 3', answer: '15'),
            Flashcard(question: '10 ÷ 2', answer: '5'),
            Flashcard(question: '7 + 8', answer: '15'),
          ],
        ),
        Collection(
          name: 'Geografia',
          flashcards: [
            Flashcard(question: 'Capital do Brasil', answer: 'Brasília'),
            Flashcard(
                question: 'Maior país da América do Sul', answer: 'Brasil'),
            Flashcard(question: 'Capital da França', answer: 'Paris'),
          ],
        ),
        Collection(
          name: 'Inglês',
          flashcards: [
            Flashcard(question: 'Hello em português', answer: 'Olá'),
            Flashcard(question: 'Book em português', answer: 'Livro'),
            Flashcard(question: 'Water em português', answer: 'Água'),
          ],
        ),
      ];

      for (final collection in sampleCollections) {
        await addCollection(collection);
      }
    } catch (e) {
      print('Erro ao adicionar dados de exemplo: $e');
    }
  }
}
