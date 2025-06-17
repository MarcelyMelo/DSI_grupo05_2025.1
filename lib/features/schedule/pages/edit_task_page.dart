import 'package:flutter/material.dart';
import '../../schedule/models/task_model.dart';
import '../../schedule/schedule_controller.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  final ScheduleController controller;

  const EditTaskPage({
    Key? key,
    required this.task,
    required this.controller,
  }) : super(key: key);

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedTag;
  late Color _selectedTagColor;

  final Map<String, Color> availableTags = {
    'Estudo': Colors.blue,
    'Trabalho': Colors.green,
    'Lazer': Colors.orange,
    'Saúde': Colors.purple,
    'Outros': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _selectedDate = widget.task.dueDate;
    _selectedTag = widget.task.tag;
    _selectedTagColor = widget.task.tagColor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate,
      tag: _selectedTag,
      tagColor: _selectedTagColor,
    );

    widget.controller.updateTask(updatedTask);
    Navigator.pop(context, true);
  }

  Widget _buildTagSelector() {
    return Column(
      children: availableTags.entries.map((entry) {
        bool isSelected = entry.key == _selectedTag;
        return ListTile(
          title: Text(entry.key),
          leading: CircleAvatar(backgroundColor: entry.value),
          trailing: isSelected ? const Icon(Icons.check, color: Colors.black) : null,
          onTap: () {
            setState(() {
              _selectedTag = entry.key;
              _selectedTagColor = entry.value;
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Tarefa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );

                if (selectedDate != null) {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );

                  if (selectedTime != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    });
                  }
                }
              },
              child: const Text('Escolher data e hora'),
            ),
            const SizedBox(height: 16),
            const Text('Selecionar Tag'),
            const SizedBox(height: 8),
            _buildTagSelector(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
