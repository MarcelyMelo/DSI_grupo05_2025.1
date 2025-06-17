import 'package:flutter/material.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  // Dados de exemplo (substitua por seus dados reais)
  final List<Collection> collections = [
    Collection(
      title: 'Matemática',
      flashcards: [
        'SÁ BAI-BA',
        'SÁ BAI-BA-BA',
        'BU SIN VALIDAD',
        'BAI-BA-BA',
      ],
      color: Colors.blue,
    ),
    Collection(
      title: 'Geografia',
      flashcards: [
        'BIA BIA BIA BIA',
        'BIA BIA BIA BIA',
        'BIA BIA BIA BIA',
      ],
      color: Colors.green,
    ),
    Collection(
      title: 'História',
      flashcards: [
        'Revolução Francesa',
        'Guerra Mundial',
        'Descobrimento do Brasil',
      ],
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar busca
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botões de criação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCreateButton(
                  'Criar Flashcard',
                  Icons.note_add,
                  Colors.blue,
                  () => _navigateToCreateFlashcard(context),
                ),
                _buildCreateButton('Criar Coleção', Icons.folder, Colors.green,
                    () => Navigator.pushNamed(context, "/createCollection")),
              ],
            ),
            const SizedBox(height: 24),

            // Lista de coleções
            Expanded(
              child: ListView.separated(
                itemCount: collections.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return _buildCollectionSection(collections[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ));
  }

  Widget _buildCollectionSection(Collection collection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Ícone de coleção com cor personalizada
            Icon(Icons.folder, color: collection.color),
            const SizedBox(width: 8),
            // Título da coleção
            Text(
              collection.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Botão para ver todos
            TextButton(
              onPressed: () => _viewCollection(collection),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Lista horizontal de flashcards
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: collection.flashcards.length,
            itemBuilder: (context, index) {
              return _buildFlashcardPreview(
                  collection.flashcards[index], collection.color);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcardPreview(String content, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCreateFlashcard(BuildContext context) {
    Navigator.pushNamed(context, '/create_flashcard');
  }

  void _viewCollection(Collection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(collection.title)),
          body: Center(child: Text('Detalhes da coleção ${collection.title}')),
        ),
      ),
    );
  }
}

// Modelo de dados para coleções
class Collection {
  final String title;
  final List<String> flashcards;
  final Color color;

  Collection({
    required this.title,
    required this.flashcards,
    this.color = Colors.blue, // Cor padrão
  });
}
