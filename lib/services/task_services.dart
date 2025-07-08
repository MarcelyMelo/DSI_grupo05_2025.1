import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../features/schedule/models/task_model.dart';

class FirebaseTaskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referência para a coleção de tarefas do usuário atual
  static CollectionReference? get _tasksCollection {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('tasks');
    }
    return null;
  }

  // Criar uma nova tarefa
  static Future<void> createTask(Task task) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      await collection.doc(task.id).set(task.toMap());
    } catch (e) {
      throw Exception('Erro ao criar tarefa: $e');
    }
  }

  // Buscar todas as tarefas do usuário
  static Future<List<Task>> getAllTasks() async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      final QuerySnapshot snapshot = await collection
          .orderBy('dueDate', descending: false)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: $e');
    }
  }

  // Buscar uma tarefa específica por ID
  static Future<Task?> getTaskById(String taskId) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      final DocumentSnapshot doc = await collection.doc(taskId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar tarefa: $e');
    }
  }

  // Atualizar uma tarefa existente
  static Future<void> updateTask(Task task) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      await collection.doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar tarefa: $e');
    }
  }

  // Deletar uma tarefa
  static Future<void> deleteTask(String taskId) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      await collection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar tarefa: $e');
    }
  }

  // Buscar tarefas por data específica
  static Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      // Início e fim do dia
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final QuerySnapshot snapshot = await collection
          .where('dueDate', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('dueDate', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas por data: $e');
    }
  }

  // Buscar tarefas por tag
  static Future<List<Task>> getTasksByTag(String tag) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      final QuerySnapshot snapshot = await collection
          .where('tag', isEqualTo: tag)
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas por tag: $e');
    }
  }

  // Buscar tarefas concluídas
  static Future<List<Task>> getCompletedTasks() async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      final QuerySnapshot snapshot = await collection
          .where('isCompleted', isEqualTo: true)
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas concluídas: $e');
    }
  }

  // Buscar tarefas pendentes
  static Future<List<Task>> getPendingTasks() async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      final QuerySnapshot snapshot = await collection
          .where('isCompleted', isEqualTo: false)
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas pendentes: $e');
    }
  }

  // Marcar tarefa como concluída
  static Future<void> markTaskAsCompleted(String taskId) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      await collection.doc(taskId).update({'isCompleted': true});
    } catch (e) {
      throw Exception('Erro ao marcar tarefa como concluída: $e');
    }
  }

  // Marcar tarefa como pendente
  static Future<void> markTaskAsPending(String taskId) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) throw Exception('Usuário não autenticado');

      await collection.doc(taskId).update({'isCompleted': false});
    } catch (e) {
      throw Exception('Erro ao marcar tarefa como pendente: $e');
    }
  }

  // Stream para escutar mudanças em tempo real
  static Stream<List<Task>> getTasksStream() {
    final collection = _tasksCollection;
    if (collection == null) {
      return Stream.empty();
    }

    return collection
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromMap(data);
      }).toList();
    });
  }

  // Stream para escutar mudanças por data
  static Stream<List<Task>> getTasksByDateStream(DateTime date) {
    final collection = _tasksCollection;
    if (collection == null) {
      return Stream.empty();
    }

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return collection
        .where('dueDate', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('dueDate', isLessThanOrEqualTo: endOfDay.toIso8601String())
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromMap(data);
      }).toList();
    });
  }
}