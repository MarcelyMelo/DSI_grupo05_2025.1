import 'package:flutter/material.dart';
import '../schedule_controller.dart';
import '../models/task_model.dart';

class EditTaskPage extends StatefulWidget {
  final Task? task;
  final ScheduleController controller;

  const EditTaskPage({super.key, this.task, required this.controller});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late final ScheduleController _controller;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _isCompleted = false;
  bool _hasTag = false;
  bool _isAllDay = false;
  bool _shouldRepeat = false;
  String _repeatFrequency = 'Daily';

  String? _selectedTag;
  Color? _selectedTagColor;

  final Map<String, Color> tags = {
    'None': Colors.transparent,
    'Study': const Color(0xFF4299E1),
    'Work': const Color(0xFFF56565),
    'Personal': const Color(0xFF48BB78),
  };

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate ?? DateTime.now();
    _dueTime = TimeOfDay(
      hour: widget.task?.dueDate.hour ?? TimeOfDay.now().hour,
      minute: widget.task?.dueDate.minute ?? TimeOfDay.now().minute,
    );
    _isCompleted = widget.task?.isCompleted ?? false;
    _isAllDay = widget.task?.isAllDay ?? false;
    _shouldRepeat = widget.task?.shouldRepeat ?? false;
    _repeatFrequency = widget.task?.repeatFrequency ?? 'Daily';

    if (widget.task != null && tags.containsKey(widget.task!.tag)) {
      _selectedTag = widget.task!.tag;
      _selectedTagColor = tags[_selectedTag];
      _hasTag = _selectedTag != 'None' && _selectedTag!.isNotEmpty;
    } else {
      _selectedTag = 'None';
      _selectedTagColor = tags['None'];
      _hasTag = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF48BB78),
              onPrimary: Colors.white,
              surface: const Color(0xFF2D3748),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF48BB78),
              onPrimary: Colors.white,
              surface: const Color(0xFF2D3748),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
        _isAllDay ? 0 : _dueTime!.hour,
        _isAllDay ? 0 : _dueTime!.minute,
      );

      final tagToSave = (_hasTag && _selectedTag != 'None') ? _selectedTag! : '';
      final tagColorToSave = (_hasTag && _selectedTag != 'None') ? _selectedTagColor! : Colors.transparent;

      if (widget.task == null) {
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: dueDateTime,
          tag: tagToSave,
          tagColor: tagColorToSave,
          isAllDay: _isAllDay,
          shouldRepeat: _shouldRepeat,
          repeatFrequency: _repeatFrequency,
        );
        _controller.addTask(newTask);
      } else {
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: dueDateTime,
          tag: tagToSave,
          tagColor: tagColorToSave,
          isCompleted: _isCompleted,
          isAllDay: _isAllDay,
          shouldRepeat: _shouldRepeat,
          repeatFrequency: _repeatFrequency,
        );
        _controller.updateTask(updatedTask);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A202C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task == null ? 'New Task' : 'Edit Task',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF48BB78),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              Text(
                'Title',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Enter task title',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Please enter a title'
                          : null,
                ),
              ),
              const SizedBox(height: 24),

              // Tag Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tag',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Switch(
                    value: _hasTag,
                    onChanged: (value) {
                      setState(() {
                        _hasTag = value;
                        if (!value) {
                          _selectedTag = 'None';
                          _selectedTagColor = tags['None'];
                        }
                      });
                    },
                    activeColor: const Color(0xFF48BB78),
                  ),
                ],
              ),
              if (_hasTag) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: tags.entries
                      .where((entry) => entry.key != 'None')
                      .map((entry) => ChoiceChip(
                            label: Text(entry.key),
                            selected: _selectedTag == entry.key,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTag = selected ? entry.key : 'None';
                                _selectedTagColor = selected ? entry.value : tags['None'];
                              });
                            },
                            selectedColor: entry.value.withOpacity(0.2),
                            backgroundColor: const Color(0xFF2D3748),
                            labelStyle: TextStyle(
                              color: _selectedTag == entry.key
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _selectedTag == entry.key
                                    ? entry.value
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDueDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D3748),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _dueDate != null
                                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                      : 'Select date',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Icon(Icons.calendar_today,
                                    color: Color(0xFF48BB78)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!_isAllDay)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDueTime(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3748),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dueTime != null
                                        ? _dueTime!.format(context)
                                        : 'Select time',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Icon(Icons.access_time,
                                      color: Color(0xFF48BB78)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // All day switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All day',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Switch(
                    value: _isAllDay,
                    onChanged: (value) {
                      setState(() {
                        _isAllDay = value;
                      });
                    },
                    activeColor: const Color(0xFF48BB78),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Repeat options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Repeat',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Switch(
                    value: _shouldRepeat,
                    onChanged: (value) {
                      setState(() {
                        _shouldRepeat = value;
                      });
                    },
                    activeColor: const Color(0xFF48BB78),
                  ),
                ],
              ),
              if (_shouldRepeat) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3748),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Daily',
                              style: TextStyle(color: Colors.white)),
                          value: 'Daily',
                          groupValue: _repeatFrequency,
                          onChanged: (value) {
                            setState(() {
                              _repeatFrequency = value!;
                            });
                          },
                          activeColor: const Color(0xFF48BB78),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Weekly',
                              style: TextStyle(color: Colors.white)),
                          value: 'Weekly',
                          groupValue: _repeatFrequency,
                          onChanged: (value) {
                            setState(() {
                              _repeatFrequency = value!;
                            });
                          },
                          activeColor: const Color(0xFF48BB78),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Description
              Text(
                'Description',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Add description (optional)...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Complete task (only shown when editing)
              if (widget.task != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Complete Task',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Switch(
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                      activeColor: const Color(0xFF48BB78),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}