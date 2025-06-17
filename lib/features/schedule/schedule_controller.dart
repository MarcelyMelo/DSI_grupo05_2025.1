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

  // Remova a factory, já que usaremos instance para acessar
  // factory ScheduleController() {
  //   return _instance;
  // }

  // Getter imutável para tarefas
  List<Task> get tasks => List.unmodifiable(_tasks);

  void addTask(Task task) {
    _tasks.add(task);
  }

  void removeTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  void completeTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = true;
    }
  }

  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((task) =>
      task.dueDate.year == date.year &&
      task.dueDate.month == date.month &&
      task.dueDate.day == date.day).toList();
  }
}