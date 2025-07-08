import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String tag;
  final Color tagColor;
  bool isCompleted;
  final bool isAllDay;
  final bool shouldRepeat;
  final String repeatFrequency;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.tag,
    required this.tagColor,
    this.isCompleted = false,
    this.isAllDay = false,
    this.shouldRepeat = false,
    this.repeatFrequency = 'Daily',
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? tag,
    Color? tagColor,
    bool? isCompleted,
    bool? isAllDay,
    bool? shouldRepeat,
    String? repeatFrequency,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      tag: tag ?? this.tag,
      tagColor: tagColor ?? this.tagColor,
      isCompleted: isCompleted ?? this.isCompleted,
      isAllDay: isAllDay ?? this.isAllDay,
      shouldRepeat: shouldRepeat ?? this.shouldRepeat,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
    );
  }

  // Método para facilitar a serialização/desserialização
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'tag': tag,
      'tagColor': tagColor.value,
      'isCompleted': isCompleted,
      'isAllDay': isAllDay,
      'shouldRepeat': shouldRepeat,
      'repeatFrequency': repeatFrequency,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      tag: map['tag'],
      tagColor: Color(map['tagColor']),
      isCompleted: map['isCompleted'],
      isAllDay: map['isAllDay'] ?? false,
      shouldRepeat: map['shouldRepeat'] ?? false,
      repeatFrequency: map['repeatFrequency'] ?? 'Daily',
    );
  }

  // Helper para verificar se a tarefa está atrasada
  bool get isOverdue {
    return !isCompleted && dueDate.isBefore(DateTime.now());
  }

  // Helper para formatar a data de vencimento
  String get formattedDueDate {
    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }
}