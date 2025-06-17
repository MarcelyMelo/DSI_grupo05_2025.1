import 'package:flutter/material.dart';
import '../schedule_controller.dart';
import '../models/task_model.dart';

class EditTaskPage extends StatefulWidget {
  final Task? task;
  final ScheduleController controller;

  const EditTaskPage({Key? key, this.task, required this.controller}) : super(key: key);

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late final ScheduleController _controller;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _isCompleted = false;

  // Novo: Tag selecionada e cor associada
  String? _selectedTag;
  Color? _selectedTagColor;

  // Tags disponíveis e cores associadas
  final Map<String, Color> tags = {
    'Nenhuma': Colors.transparent,
    'Estudo': Colors.blue,
    'Trabalho': Colors.red,
    'Pessoal': Colors.green,
  };

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _dueDate = widget.task?.dueDate ?? DateTime.now();
    _dueTime = TimeOfDay(
      hour: widget.task?.dueDate.hour ?? TimeOfDay.now().hour,
      minute: widget.task?.dueDate.minute ?? TimeOfDay.now().minute,
    );
    _isCompleted = widget.task?.isCompleted ?? false;

    // Inicializa a tag selecionada e a cor, ou 'Nenhuma' se tag não estiver no mapa
    if (widget.task != null && tags.containsKey(widget.task!.tag)) {
      _selectedTag = widget.task!.tag;
      _selectedTagColor = tags[_selectedTag];
    } else {
      _selectedTag = 'Nenhuma';
      _selectedTagColor = tags['Nenhuma'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectDueTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final dueDateTime = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime!.hour,
        _dueTime!.minute,
      );

      final tagToSave = _selectedTag == 'Nenhuma' ? '' : _selectedTag!;
      final tagColorToSave = _selectedTag == 'Nenhuma' ? Colors.transparent : _selectedTagColor!;

      if (widget.task == null) {
        // Criar nova tarefa
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          tag: tagToSave,
          tagColor: tagColorToSave,
          dueDate: dueDateTime,
          isCompleted: _isCompleted,
        );
        _controller.addTask(newTask);
      } else {
        // Atualizar tarefa existente
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          tag: tagToSave,
          tagColor: tagColorToSave,
          dueDate: dueDateTime,
          isCompleted: _isCompleted,
        );
        _controller.updateTask(updatedTask);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _controller.removeTask(widget.task!.id);
                Navigator.pop(context, true);
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título *'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Digite o título' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tag (opcional)'),
                value: _selectedTag,
                items: tags.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: entry.value,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTag = val;
                    _selectedTagColor = val == null ? null : tags[val];
                  });
                },
                // validator: null, // Não obrigatório
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data de Vencimento'),
                subtitle: Text(
                    _dueDate != null ? '${_dueDate!.toLocal()}'.split(' ')[0] : ''),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDueDate(context),
              ),
              ListTile(
                title: const Text('Hora de Vencimento'),
                subtitle:
                    Text(_dueTime != null ? _dueTime!.format(context) : ''),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectDueTime(context),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Concluído'),
                value: _isCompleted,
                onChanged: (val) {
                  setState(() {
                    _isCompleted = val ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task == null ? 'Criar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}