import 'flashcard.dart';

class Collection {
  final String name;
  final List<Flashcard> flashcards;
  final DateTime createdAt;

  Collection({
    required this.name,
    List<Flashcard>? flashcards,
    DateTime? createdAt,
  })  : flashcards = flashcards ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Método para converter para Map (útil para persistência)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'flashcards': flashcards.map((card) => card.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Método para criar a partir de um Map
  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      name: map['name'],
      flashcards: (map['flashcards'] as List)
          .map((cardMap) => Flashcard.fromMap(cardMap))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}