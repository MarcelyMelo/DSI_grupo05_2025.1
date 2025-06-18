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
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _isCompleted = false;
  bool _hasTag = false;
  bool _isAllDay = false;
  bool _shouldRepeat = false;
  String _repeatFrequency = 'Todos os dias';

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
      _hasTag = _selectedTag != 'Nenhuma' && _selectedTag!.isNotEmpty;
    } else {
      _selectedTag = 'Nenhuma';
      _selectedTagColor = tags['Nenhuma'];
      _hasTag = false;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Color(0xFF2D3748),
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
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Color(0xFF2D3748),
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
        _dueTime!.hour,
        _dueTime!.minute,
      );

      final tagToSave = (_hasTag && _selectedTag != 'Nenhuma') ? _selectedTag! : '';
      final tagColorToSave = (_hasTag && _selectedTag != 'Nenhuma') ? _selectedTagColor! : Colors.transparent;

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

  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color activeColor = const Color(0xFF4CAF50),
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? activeColor : const Color(0xFF4A5568),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A5568) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A202C),
      body: SafeArea(
        child: Column(
          children: [
            // Header com botões de ação
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão cancelar
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3748),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4A5568),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  // Título
                  Text(
                    widget.task == null ? 'Nova tarefa' : 'Editar tarefa',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  // Botão salvar
                  GestureDetector(
                    onTap: _saveTask,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo Título
                      Row(
                        children: [
                          const Text(
                            'Título:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A5568),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextFormField(
                                controller: _titleController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Nome qualquer',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 16,
                                  ),
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty) 
                                        ? 'Digite o título' : null,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Etiqueta (Tag)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Etiqueta:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _buildCustomSwitch(
                            value: _hasTag,
                            onChanged: (value) {
                              setState(() {
                                _hasTag = value;
                                if (!value) {
                                  _selectedTag = 'Nenhuma';
                                  _selectedTagColor = tags['Nenhuma'];
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      if (_hasTag) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A5568),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTag == 'Nenhuma' ? null : _selectedTag,
                              hint: const Text(
                                'Selecionar etiqueta',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 16,
                                ),
                              ),
                              dropdownColor: const Color(0xFF4A5568),
                              isExpanded: true,
                              items: tags.entries
                                  .where((entry) => entry.key != 'Nenhuma')
                                  .map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: entry.value,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        margin: const EdgeInsets.only(right: 12),
                                      ),
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedTag = val ?? 'Nenhuma';
                                  _selectedTagColor = val == null ? null : tags[val];
                                });
                              },
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Dia inteiro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dia inteiro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _buildCustomSwitch(
                            value: _isAllDay,
                            onChanged: (value) {
                              setState(() {
                                _isAllDay = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Repetir
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Repetir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _buildCustomSwitch(
                            value: _shouldRepeat,
                            onChanged: (value) {
                              setState(() {
                                _shouldRepeat = value;
                              });
                            },
                          ),
                        ],
                      ),

                      if (_shouldRepeat) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A5568),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _buildToggleButton(
                                text: 'Todos os dias',
                                isSelected: _repeatFrequency == 'Todos os dias',
                                onTap: () {
                                  setState(() {
                                    _repeatFrequency = 'Todos os dias';
                                  });
                                },
                              ),
                              _buildToggleButton(
                                text: 'Todas as semanas',
                                isSelected: _repeatFrequency == 'Todas as semanas',
                                onTap: () {
                                  setState(() {
                                    _repeatFrequency = 'Todas as semanas';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Data e Hora
                      Row(
                        children: [
                          // Data
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDueDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9AE6B4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _dueDate != null 
                                      ? '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}'
                                      : 'Selecionar data',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF1A202C),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Hora
                          if (!_isAllDay)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDueTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9AE6B4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _dueTime != null 
                                        ? _dueTime!.format(context)
                                        : 'Hora',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF1A202C),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Campo de detalhes
                      Container(
                        width: double.infinity,
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9AE6B4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const TextField(
                          maxLines: null,
                          expands: true,
                          style: TextStyle(
                            color: Color(0xFF1A202C),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Detalhes...',
                            hintStyle: TextStyle(
                              color: Color(0xFF4A5568),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}