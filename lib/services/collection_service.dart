import '../models/collection.dart';
import '../models/flashcard.dart';

class CollectionService {
  final List<Collection> _collections = [];

  // Adiciona uma nova coleção
  void addCollection(Collection collection) {
    _collections.add(collection);
  }

  // Remove uma coleção pelo ID
  void removeCollection(String name) {
    _collections.removeWhere((collection) => collection.name == name);
  }

  // Obtém todas as coleções
  List<Collection> getAllCollections() {
    return List.unmodifiable(_collections);
  }

  // Adiciona um flashcard a uma coleção
  void addFlashcardToCollection(String collectionName, Flashcard flashcard) {
    final collection = _collections.firstWhere((c) => c.name == collectionName);
    collection.flashcards.add(flashcard);
  }

  // ... outros métodos conforme necessário
}