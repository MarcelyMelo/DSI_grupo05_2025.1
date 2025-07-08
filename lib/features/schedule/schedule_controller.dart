import 'models/task_model.dart';

class ScheduleController {
  // Instância única privada estática
  static final ScheduleController _instance = ScheduleController._internal();

  // Getter público para acesso à instância única
  static ScheduleController get instance => _instance;

  // Lista privada de tarefas
  final List<Task> _tasks = [];

  // Construtor nomeado privado para criar a instância
  ScheduleController._internal();

  // Getter imutável para tarefas
  List<Task> get tasks => List.unmodifiable(_tasks);

  // Método para adicionar tarefa
  void addTask(Task task) {
    _tasks.add(task);
  }

  // Método para remover tarefa por ID (mantém o método original)
  void removeTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
  }

  // NOVO: Método para remover tarefa por objeto Task
  // Este método é usado no home_screen.dart na função _deleteTask
  void deleteTask(Task task) {
    _tasks.remove(task);
  }

  // ALTERNATIVA: Sobrecarga do método removeTask para aceitar Task
  void removeTaskByObject(Task task) {
    _tasks.remove(task);
  }

  // Método para atualizar tarefa
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  // Método para marcar tarefa como completa
  void completeTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = true;
    }
  }

  // Método para alternar o estado de completude de uma tarefa
  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    }
  }

  // Método para obter tarefas de uma data específica
  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((task) =>
      task.dueDate.year == date.year &&
      task.dueDate.month == date.month &&
      task.dueDate.day == date.day).toList();
  }

  // Método para obter tarefas de hoje
  List<Task> get todayTasks {
    final today = DateTime.now();
    return tasksForDate(today);
  }

  // Método para obter tarefas pendentes
  List<Task> get pendingTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  // Método para obter tarefas completadas
  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  // Método para limpar todas as tarefas
  void clearAllTasks() {
    _tasks.clear();
  }

  // Método para obter tarefa por ID
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Método para obter total de tarefas
  int get totalTasks => _tasks.length;

  // Método para obter tarefas por tag
  List<Task> getTasksByTag(String tag) {
    return _tasks.where((task) => task.tag.toLowerCase() == tag.toLowerCase()).toList();
  }

  // Método para obter tarefas de uma semana específica
  List<Task> getTasksForWeek(DateTime startOfWeek) {
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return _tasks.where((task) => 
      task.dueDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
      task.dueDate.isBefore(endOfWeek)
    ).toList();
  }

  // Método para obter tarefas de um mês específico
  List<Task> getTasksForMonth(DateTime month) {
    return _tasks.where((task) =>
      task.dueDate.year == month.year &&
      task.dueDate.month == month.month
    ).toList();
  }
}