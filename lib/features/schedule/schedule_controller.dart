import 'package:dsi_projeto/services/task_services.dart';
import 'package:flutter/material.dart';
import 'models/task_model.dart';

class ScheduleController extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Construtor - carrega tarefas automaticamente
  ScheduleController() {
    loadTasks();
  }

  // Método para definir estado de loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Método para definir erro
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Carregar todas as tarefas do Firebase
  Future<void> loadTasks() async {
    _setLoading(true);
    _setError(null);

    try {
      _tasks = await FirebaseTaskService.getAllTasks();
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar tarefas: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Adicionar nova tarefa
  Future<void> addTask(Task task) async {
    _setLoading(true);
    _setError(null);

    try {
      await FirebaseTaskService.createTask(task);
      
      // Adiciona localmente também para resposta imediata
      _tasks.add(task);
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    } catch (e) {
      _setError('Erro ao adicionar tarefa: $e');
      // Remove da lista local se falhou no Firebase
      _tasks.removeWhere((t) => t.id == task.id);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar tarefa existente
  Future<void> updateTask(Task updatedTask) async {
    _setLoading(true);
    _setError(null);

    // Salva o estado anterior para rollback se necessário
    final oldTaskIndex = _tasks.indexWhere((t) => t.id == updatedTask.id);
    final oldTask = oldTaskIndex != -1 ? _tasks[oldTaskIndex] : null;

    try {
      await FirebaseTaskService.updateTask(updatedTask);
      
      // Atualiza localmente também
      if (oldTaskIndex != -1) {
        _tasks[oldTaskIndex] = updatedTask;
        _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao atualizar tarefa: $e');
      // Rollback se falhou
      if (oldTask != null && oldTaskIndex != -1) {
        _tasks[oldTaskIndex] = oldTask;
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Deletar tarefa
  Future<void> deleteTask(String taskId) async {
    _setLoading(true);
    _setError(null);

    // Salva a tarefa para rollback se necessário
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    final taskToDelete = taskIndex != -1 ? _tasks[taskIndex] : null;

    try {
      await FirebaseTaskService.deleteTask(taskId);
      
      // Remove localmente também
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao deletar tarefa: $e');
      // Rollback se falhou
      if (taskToDelete != null && taskIndex != -1) {
        _tasks.insert(taskIndex, taskToDelete);
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Marcar tarefa como concluída/pendente
  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    final newCompletionStatus = !task.isCompleted;

    // Atualiza localmente primeiro para resposta imediata
    _tasks[taskIndex] = task.copyWith(isCompleted: newCompletionStatus);
    notifyListeners();

    try {
      if (newCompletionStatus) {
        await FirebaseTaskService.markTaskAsCompleted(taskId);
      } else {
        await FirebaseTaskService.markTaskAsPending(taskId);
      }
    } catch (e) {
      _setError('Erro ao atualizar status da tarefa: $e');
      // Rollback se falhou
      _tasks[taskIndex] = task;
      notifyListeners();
    }
  }

  // Buscar tarefas por data específica
  Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      return await FirebaseTaskService.getTasksByDate(date);
    } catch (e) {
      _setError('Erro ao buscar tarefas por data: $e');
      return [];
    }
  }

  // MÉTODO ADICIONADO: tasksForDate (para compatibilidade com home_screen)
  List<Task> tasksForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _tasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Buscar tarefas por tag
  Future<List<Task>> getTasksByTag(String tag) async {
    try {
      return await FirebaseTaskService.getTasksByTag(tag);
    } catch (e) {
      _setError('Erro ao buscar tarefas por tag: $e');
      return [];
    }
  }

  // Buscar tarefas concluídas
  Future<List<Task>> getCompletedTasks() async {
    try {
      return await FirebaseTaskService.getCompletedTasks();
    } catch (e) {
      _setError('Erro ao buscar tarefas concluídas: $e');
      return [];
    }
  }

  // Buscar tarefas pendentes
  Future<List<Task>> getPendingTasks() async {
    try {
      return await FirebaseTaskService.getPendingTasks();
    } catch (e) {
      _setError('Erro ao buscar tarefas pendentes: $e');
      return [];
    }
  }

  // Método para recarregar tarefas (útil para pull-to-refresh)
  Future<void> refreshTasks() async {
    await loadTasks();
  }

  // Método para limpar erros
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Método para obter tarefas do dia atual (compatibilidade)
  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Método para obter tarefas em atraso
  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) => task.dueDate.isBefore(now) && !task.isCompleted).toList();
  }

  // Método para obter próximas tarefas
  List<Task> get upcomingTasks {
    final now = DateTime.now();
    return _tasks.where((task) => task.dueDate.isAfter(now) && !task.isCompleted).toList();
  }

  // Stream para escutar mudanças em tempo real (opcional)
  Stream<List<Task>> get tasksStream {
    return FirebaseTaskService.getTasksStream();
  }

  // Método para inicializar listener em tempo real (opcional)
  void startListeningToTasks() {
    FirebaseTaskService.getTasksStream().listen(
      (tasks) {
        _tasks = tasks;
        notifyListeners();
      },
      onError: (error) {
        _setError('Erro ao escutar mudanças: $error');
      },
    );
  }
}