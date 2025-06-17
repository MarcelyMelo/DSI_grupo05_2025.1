import 'package:flutter/material.dart';

class CreateCollectionScreen extends StatefulWidget {
  const CreateCollectionScreen({super.key});

  @override
  State<CreateCollectionScreen> createState() => _CreateCollectionScreenState();
}

class _CreateCollectionScreenState extends State<CreateCollectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedFlashcards = [];
  bool _isCreating = false;

  // Lista de flashcards existentes (exemplo)
  final List<Flashcard> _existingFlashcards = [
    Flashcard(id: '1', frontText: 'SÁ BAI-BA', backText: 'Resposta 1'),
    Flashcard(id: '2', frontText: 'SÁ BAI-BA-BA', backText: 'Resposta 2'),
    Flashcard(id: '3', frontText: 'BU SIN VALIDAD', backText: 'Resposta 3'),
    Flashcard(id: '4', frontText: 'BAI-BA-BA', backText: 'Resposta 4'),
    Flashcard(id: '5', frontText: 'BIA BIA BIA BIA', backText: 'Resposta 5'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar coleção'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createCollection,
            child: const Text(
              'CRIAR',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para o nome da coleção
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Título da seção de flashcards existentes
            const Text(
              'Adicionar cartões já existentes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Lista de flashcards existentes
            Expanded(
              child: ListView.builder(
                itemCount: _existingFlashcards.length,
                itemBuilder: (context, index) {
                  final flashcard = _existingFlashcards[index];
                  final isSelected = _selectedFlashcards.contains(flashcard.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      title: Text(flashcard.frontText),
                      subtitle: Text(flashcard.backText),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedFlashcards.add(flashcard.id);
                          } else {
                            _selectedFlashcards.remove(flashcard.id);
                          }
                        });
                      },
                      secondary: Icon(
                        Icons.note,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botões inferiores
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CANCELAR'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createCollection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'CRIAR',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCollection() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, insira um nome para a coleção')),
      );
      return;
    }

    setState(() => _isCreating = true);

    // Simular processo de criação (em um app real, aqui seria sua chamada API)
    await Future.delayed(const Duration(seconds: 1));

    // Retornar à tela anterior com os dados da nova coleção
    if (!mounted) return;
    Navigator.pop(context, {
      'name': name,
      'flashcardIds': _selectedFlashcards,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class Flashcard {
  final String id;
  final String frontText;
  final String backText;

  Flashcard({
    required this.id,
    required this.frontText,
    required this.backText,
  });
}
