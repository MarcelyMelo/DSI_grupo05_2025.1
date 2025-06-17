import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../schedule_controller.dart';

class TaskForm extends StatefulWidget {
  final ScheduleController controller;
  final VoidCallback onTaskAdded;
  final Task? taskToEdit;  // Nova tarefa opcional para edição

  const TaskForm({
    Key? key,
    required this.controller,
    required this.onTaskAdded,
    this.taskToEdit,
  }) : super(key: key);

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedTag;
  Color? _selectedTagColor;

  final Map<String, Color> tags = {
    'Estudo': Colors.blue,
    'Trabalho': Colors.red,
    'Pessoal': Colors.green,
  };

  @override
  void initState() {
    super.initState();

    // Se estiver editando, preencher com dados da tarefa
    if (widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController = TextEditingController(text: task.title);
      _descriptionController = TextEditingController(text: task.description ?? '');
      _selectedDate = task.dueDate;
      _selectedTime = TimeOfDay(hour: task.dueDate.hour, minute: task.dueDate.minute);
      _selectedTag = task.tag;
      _selectedTagColor = task.tagColor;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma data')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um horário')),
      );
      return;
    }
    if (_selectedTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma tag')),
      );
      return;
    }

    final dueDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (widget.taskToEdit != null) {
      // Edição
      final updatedTask = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        dueDate: dueDate,
        tag: _selectedTag!,
        tagColor: _selectedTagColor!,
      );
      widget.controller.updateTask(updatedTask);
    } else {
      // Criação
      final newTask = Task(
        id: DateTime.now().toIso8601String(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        dueDate: dueDate,
        tag: _selectedTag!,
        tagColor: _selectedTagColor!,
      );
      widget.controller.addTask(newTask);
    }

    widget.onTaskAdded();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? 'Selecione a data'
                        : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Selecionar'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedTime == null
                        ? 'Selecione o horário'
                        : 'Horário: ${_selectedTime!.format(context)}'),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Selecionar'),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tag *'),
                value: _selectedTag,
                items: tags.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: e.value,
                                margin: const EdgeInsets.only(right: 8),
                              ),
                              Text(e.key),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTag = val;
                    _selectedTagColor = val == null ? null : tags[val];
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione uma tag';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}