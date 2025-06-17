import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String tag;
  final Color tagColor;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.tag,
    required this.tagColor,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? tag,
    Color? tagColor,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      tag: tag ?? this.tag,
      tagColor: tagColor ?? this.tagColor,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}