import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:dsi_projeto/components/time_inputs/minute_second_input.dart';

class EditTimerScreen extends StatefulWidget {
  final String currentName;
  final bool isPomodoro;
  final int currentStudyMinutes;
  final int currentStudySeconds;
  final int currentBreakMinutes;
  final int currentBreakSeconds;
  final int currentIntervals;
  final int currentMinutes;
  final int currentSeconds;

  const EditTimerScreen({
    super.key,
    required this.currentName,
    required this.isPomodoro,
    required this.currentStudyMinutes,
    required this.currentStudySeconds,
    required this.currentBreakMinutes,
    required this.currentBreakSeconds,
    required this.currentIntervals,
    required this.currentMinutes,
    required this.currentSeconds,
  });

  @override
  State<EditTimerScreen> createState() => _EditTimerScreenState();
}

class _EditTimerScreenState extends State<EditTimerScreen> {
  late TextEditingController _nameController;
  late TextEditingController _studyMinutesController;
  late TextEditingController _studySecondsController;
  late TextEditingController _breakMinutesController;
  late TextEditingController _breakSecondsController;
  late TextEditingController _intervalsController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;
  late bool _isPomodoro;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _studyMinutesController = TextEditingController(text: widget.currentStudyMinutes.toString());
    _studySecondsController = TextEditingController(text: widget.currentStudySeconds.toString());
    _breakMinutesController = TextEditingController(text: widget.currentBreakMinutes.toString());
    _breakSecondsController = TextEditingController(text: widget.currentBreakSeconds.toString());
    _intervalsController = TextEditingController(text: widget.currentIntervals.toString());
    _minutesController = TextEditingController(text: widget.currentMinutes.toString());
    _secondsController = TextEditingController(text: widget.currentSeconds.toString());
    _isPomodoro = widget.isPomodoro;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studyMinutesController.dispose();
    _studySecondsController.dispose();
    _breakMinutesController.dispose();
    _breakSecondsController.dispose();
    _intervalsController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    // Validação do nome
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o cronômetro')));
      return false;
    }

    // Validação genérica para todos os campos de tempo
    bool validateTime(int minutes, int seconds, String fieldName) {
      if (minutes < 0 || seconds < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Valores de $fieldName não podem ser negativos')));
        return false;
      }
      
      if (seconds >= 60) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Segundos de $fieldName devem ser menores que 60')));
        return false;
      }
      
      if (minutes == 0 && seconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Duração de $fieldName não pode ser zero')));
        return false;
      }
      return true;
    }

    // Validação dos tempos
    if (_isPomodoro) {
      final studyMins = int.tryParse(_studyMinutesController.text) ?? 0;
      final studySecs = int.tryParse(_studySecondsController.text) ?? 0;
      final breakMins = int.tryParse(_breakMinutesController.text) ?? 0;
      final breakSecs = int.tryParse(_breakSecondsController.text) ?? 0;
      final intervals = int.tryParse(_intervalsController.text) ?? 0;

      if (!validateTime(studyMins, studySecs, 'foco')) return false;
      if (!validateTime(breakMins, breakSecs, 'descanso')) return false;
      
      if (intervals <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deve haver pelo menos 1 intervalo')));
        return false;
      }
    } else {
      final mins = int.tryParse(_minutesController.text) ?? 0;
      final secs = int.tryParse(_secondsController.text) ?? 0;
      if (!validateTime(mins, secs, 'temporizador')) return false;
    }

    return true;
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A4B52),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white60),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStyledSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A4B52),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          'Modo Pomodoro',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        value: _isPomodoro,
        onChanged: (value) => setState(() => _isPomodoro = value),
        activeColor: Color(0xFF00C896),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E3A3F),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E3A3F),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar Cronômetro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Color(0xFF00C896)),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Nome do Cronômetro'),
            _buildStyledTextField(
              controller: _nameController,
              hintText: 'Digite o nome do cronômetro',
              icon: Icons.timer,
            ),
            
            const SizedBox(height: 24),
            
            _buildStyledSwitch(),
            
            const SizedBox(height: 24),
            
            if (_isPomodoro) ...[
              _buildSectionTitle('Tempo de Foco'),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2A4B52),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: MinuteSecondInput(
                  minutesController: _studyMinutesController,
                  secondsController: _studySecondsController,
                ),
              ),
              
              const SizedBox(height: 20),
              
              _buildSectionTitle('Tempo de Descanso'),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2A4B52),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: MinuteSecondInput(
                  minutesController: _breakMinutesController,
                  secondsController: _breakSecondsController,
                ),
              ),
              
              const SizedBox(height: 20),
              
              _buildSectionTitle('Quantidade de Intervalos'),
              _buildStyledTextField(
                controller: _intervalsController,
                hintText: 'Número de intervalos',
                icon: Icons.repeat,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
            ] else ...[
              _buildSectionTitle('Duração Total'),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2A4B52),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: MinuteSecondInput(
                  minutesController: _minutesController,
                  secondsController: _secondsController,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Botão de Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C896),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Salvar Alterações',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    if (!_validateInputs()) return;

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'isPomodoro': _isPomodoro,
      'studyMinutes': int.parse(_studyMinutesController.text),
      'studySeconds': int.parse(_studySecondsController.text),
      'breakMinutes': int.parse(_breakMinutesController.text),
      'breakSeconds': int.parse(_breakSecondsController.text),
      'intervals': int.parse(_intervalsController.text),
      'minutes': int.parse(_minutesController.text),
      'seconds': int.parse(_secondsController.text),
    });
  }
}