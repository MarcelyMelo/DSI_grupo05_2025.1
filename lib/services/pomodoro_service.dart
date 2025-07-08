import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class TimerFirebaseModel {
  String id;
  String name;
  int duration;
  bool isPomodoro;
  int studyDuration;
  int breakDuration;
  int intervals;
  int completedIntervals;
  bool isStudyPhase;
  DateTime createdAt;
  DateTime updatedAt;

  TimerFirebaseModel({
    required this.id,
    required this.name,
    required this.duration,
    this.isPomodoro = false,
    this.studyDuration = 25 * 60,
    this.breakDuration = 5 * 60,
    this.intervals = 4,
    this.completedIntervals = 0,
    this.isStudyPhase = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration': duration,
      'isPomodoro': isPomodoro,
      'studyDuration': studyDuration,
      'breakDuration': breakDuration,
      'intervals': intervals,
      'completedIntervals': completedIntervals,
      'isStudyPhase': isStudyPhase,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TimerFirebaseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TimerFirebaseModel(
      id: documentId,
      name: map['name'] ?? '',
      duration: map['duration'] ?? 0,
      isPomodoro: map['isPomodoro'] ?? false,
      studyDuration: map['studyDuration'] ?? 25 * 60,
      breakDuration: map['breakDuration'] ?? 5 * 60,
      intervals: map['intervals'] ?? 4,
      completedIntervals: map['completedIntervals'] ?? 0,
      isStudyPhase: map['isStudyPhase'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  TimerFirebaseModel copyWith({
    String? id,
    String? name,
    int? duration,
    bool? isPomodoro,
    int? studyDuration,
    int? breakDuration,
    int? intervals,
    int? completedIntervals,
    bool? isStudyPhase,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimerFirebaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      isPomodoro: isPomodoro ?? this.isPomodoro,
      studyDuration: studyDuration ?? this.studyDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      intervals: intervals ?? this.intervals,
      completedIntervals: completedIntervals ?? this.completedIntervals,
      isStudyPhase: isStudyPhase ?? this.isStudyPhase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PomodoroService {
  static final PomodoroService _instance = PomodoroService._internal();
  factory PomodoroService() => _instance;
  PomodoroService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _timersCollection {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(_userId).collection('timers');
  }

  // Create a new timer
  Future<String> createTimer(TimerFirebaseModel timer) async {
    try {
      final now = DateTime.now();
      final timerData = timer.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      
      final docRef = await _timersCollection.add(timerData.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar cronômetro: $e');
    }
  }

  // Get all timers for the current user
  Future<List<TimerFirebaseModel>> getTimers() async {
    try {
      final querySnapshot = await _timersCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return TimerFirebaseModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar cronômetros: $e');
    }
  }

  // Get timers as stream (real-time updates)
  Stream<List<TimerFirebaseModel>> getTimersStream() {
    try {
      return _timersCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return TimerFirebaseModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      });
    } catch (e) {
      throw Exception('Erro ao escutar cronômetros: $e');
    }
  }

  // Update an existing timer
  Future<void> updateTimer(TimerFirebaseModel timer) async {
    try {
      final updatedTimer = timer.copyWith(updatedAt: DateTime.now());
      await _timersCollection.doc(timer.id).update(updatedTimer.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar cronômetro: $e');
    }
  }

  // Delete a timer
  Future<void> deleteTimer(String timerId) async {
    try {
      await _timersCollection.doc(timerId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar cronômetro: $e');
    }
  }

  // Update timer progress (for Pomodoro cycles)
  Future<void> updateTimerProgress({
    required String timerId,
    required int completedIntervals,
    required bool isStudyPhase,
    int? currentDuration,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'completedIntervals': completedIntervals,
        'isStudyPhase': isStudyPhase,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (currentDuration != null) {
        updateData['duration'] = currentDuration;
      }
      
      await _timersCollection.doc(timerId).update(updateData);
    } catch (e) {
      throw Exception('Erro ao atualizar progresso do cronômetro: $e');
    }
  }

  // Reset timer to initial state
  Future<void> resetTimer(String timerId) async {
    try {
      await _timersCollection.doc(timerId).update({
        'completedIntervals': 0,
        'isStudyPhase': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao resetar cronômetro: $e');
    }
  }

  // Get a specific timer by ID
  Future<TimerFirebaseModel?> getTimer(String timerId) async {
    try {
      final doc = await _timersCollection.doc(timerId).get();
      if (doc.exists) {
        return TimerFirebaseModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cronômetro: $e');
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _userId != null;

  // Get current user ID
  String? get currentUserId => _userId;

  // Create timer from your existing TimerModel
  static TimerFirebaseModel fromTimerModel({
    required String name,
    required int duration,
    bool isPomodoro = false,
    int studyDuration = 25 * 60,
    int breakDuration = 5 * 60,
    int intervals = 4,
    int completedIntervals = 0,
    bool isStudyPhase = true,
  }) {
    return TimerFirebaseModel(
      id: '', // Will be set by Firebase
      name: name,
      duration: duration,
      isPomodoro: isPomodoro,
      studyDuration: studyDuration,
      breakDuration: breakDuration,
      intervals: intervals,
      completedIntervals: completedIntervals,
      isStudyPhase: isStudyPhase,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Batch operations for better performance
  Future<void> batchUpdateTimers(List<TimerFirebaseModel> timers) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();
      
      for (final timer in timers) {
        final timerRef = _timersCollection.doc(timer.id);
        final updatedTimer = timer.copyWith(updatedAt: now);
        batch.update(timerRef, updatedTimer.toMap());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao atualizar cronômetros em lote: $e');
    }
  }

  // Delete multiple timers
  Future<void> batchDeleteTimers(List<String> timerIds) async {
    try {
      final batch = _firestore.batch();
      
      for (final timerId in timerIds) {
        final timerRef = _timersCollection.doc(timerId);
        batch.delete(timerRef);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar cronômetros em lote: $e');
    }
  }
}