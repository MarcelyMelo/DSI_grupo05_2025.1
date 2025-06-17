class Flashcard {
  final String question;
  final String answer;
  bool isKnown;

  Flashcard({
    required this.question,
    required this.answer,
    this.isKnown = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'isKnown': isKnown,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      question: map['question'],
      answer: map['answer'],
      isKnown: map['isKnown'] ?? false,
    );
  }
}