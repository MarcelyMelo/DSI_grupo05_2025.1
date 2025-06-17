import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/collection.dart';
import '../models/flashcard.dart';
import '../services/collection_service.dart';

class CreateFlashcardScreen extends StatefulWidget {
  final CollectionService collectionService;

  const CreateFlashcardScreen({super.key, required this.collectionService});

  @override
  _CreateFlashcardScreenState createState() => _CreateFlashcardScreenState();
}

class _CreateFlashcardScreenState extends State<CreateFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  
  Collection? _selectedCollection;
  Color _selectedColor = Colors.blue;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _createFlashcard() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCollection == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione uma coleção'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newFlashcard = Flashcard(
        question: _questionController.text,
        answer: _answerController.text,
      );

      // Adiciona o flashcard à coleção selecionada
      widget.collectionService.addFlashcardToCollection(
        _selectedCollection!.name,
        newFlashcard,
      );

      // Debug
      print('Flashcard criado para coleção: ${_selectedCollection!.name}');
      print('Pergunta: ${_questionController.text}');
      print('Resposta: ${_answerController.text}');

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flashcard adicionado à coleção "${_selectedCollection!.name}"!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2A2A2A),
        child: Container(
          width: 380,
          height: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Selecionar Cor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ColorPicker(
                  pickerColor: _selectedColor,
                  onColorChanged: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  colorPickerWidth: 280,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  paletteType: PaletteType.hsvWithHue,
                  portraitOnly: true,
                  showLabel: false,
                  pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DD0E1),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collections = widget.collectionService.getAllCollections();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Criar flashcard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView( // Adiciona scroll para evitar overflow
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown para selecionar coleção
              const Text(
                'Adicionar a coleção',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Collection>(
                    value: _selectedCollection,
                    hint: const Text(
                      'Selecione uma coleção',
                      style: TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: const Color(0xFF2A2A2A),
                    isExpanded: true,
                    items: collections.map((collection) {
                      return DropdownMenuItem<Collection>(
                        value: collection,
                        child: Text(
                          collection.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (Collection? value) {
                      setState(() {
                        _selectedCollection = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Seletor de cor
              const Text(
                'Selecionar cor:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 3),
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Campo de pergunta
              const Text(
                'Pergunta:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DD0E1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4DD0E1)),
                ),
                child: TextFormField(
                  controller: _questionController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Digite sua pergunta aqui...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma pergunta';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Campo de resposta
              const Text(
                'Resposta:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DD0E1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4DD0E1)),
                ),
                child: TextFormField(
                  controller: _answerController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Digite sua resposta aqui...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma resposta';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Botão de criar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createFlashcard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A5F4F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Criar Flashcard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20), // Espaço extra no final
            ],
          ),
        ),
      ),
    );
  }
}