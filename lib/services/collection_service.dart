import '../models/collection.dart';
import '../models/flashcard.dart';

class CollectionService {
  final List<Collection> _collections = [];

  // Adiciona uma nova coleção
  void addCollection(Collection collection) {
    _collections.add(collection);
  }

  // Remove uma coleção pelo nome
  void removeCollection(String name) {
    _collections.removeWhere((collection) => collection.name == name);
  }

  // Obtém todas as coleções
  List<Collection> getAllCollections() {
    return List.unmodifiable(_collections);
  }

  // Obtém uma coleção pelo nome
  Collection? getCollectionByName(String name) {
    try {
      return _collections.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  // Adiciona um flashcard a uma coleção
  void addFlashcardToCollection(String collectionName, Flashcard flashcard) {
    final collection = _collections.firstWhere((c) => c.name == collectionName);
    collection.flashcards.add(flashcard);
  }

  // Remove um flashcard de uma coleção
  void removeFlashcardFromCollection(String collectionName, int flashcardIndex) {
    final collection = _collections.firstWhere((c) => c.name == collectionName);
    if (flashcardIndex >= 0 && flashcardIndex < collection.flashcards.length) {
      collection.flashcards.removeAt(flashcardIndex);
    }
  }

  // Atualiza uma coleção (nome e flashcards)
  void updateCollection(String oldName, Collection updatedCollection) {
    final index = _collections.indexWhere((c) => c.name == oldName);
    if (index != -1) {
      _collections[index] = updatedCollection;
    }
  }

  // Limpa todos os flashcards de uma coleção
  void clearCollectionFlashcards(String collectionName) {
    final collection = _collections.firstWhere((c) => c.name == collectionName);
    collection.flashcards.clear();
  }

  // Atualiza o nome de uma coleção
  void updateCollectionName(String oldName, String newName) {
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
  }
}