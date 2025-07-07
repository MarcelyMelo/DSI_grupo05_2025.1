import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../models/flashcard.dart';
import '../services/collection_service.dart';
import 'create_collection_screen.dart';
import 'create_flashcard_screen.dart';
import 'collection_edit_screen.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final CollectionService _collectionService = CollectionService();
  // Add this line after line 16 (after _collectionService declaration):
  final Map<String, bool> _flippedCards = {};

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    await _collectionService.initialize();
    setState(() {});
  }

  /*
  void _addSampleData() {
    _collectionService.addCollection(
      Collection(
        name: 'Matemática',
        flashcards: [
          Flashcard(question: '2 + 2', answer: '4'),
          Flashcard(question: '5 × 3', answer: '15'),
          Flashcard(question: '10 ÷ 2', answer: '5'),
          Flashcard(question: '7 + 8', answer: '15'),
        ],
      ),
    );
    
    _collectionService.addCollection(
      Collection(
        name: 'Geografia',
        flashcards: [
          Flashcard(question: 'Capital do Brasil', answer: 'Brasília'),
          Flashcard(question: 'Maior país da América do Sul', answer: 'Brasil'),
          Flashcard(question: 'Capital da França', answer: 'Paris'),
        ],
      ),
    );

    _collectionService.addCollection(
      Collection(
        name: 'Inglês',
        flashcards: [
          Flashcard(question: 'Hello em português', answer: 'Olá'),
          Flashcard(question: 'Book em português', answer: 'Livro'),
          Flashcard(question: 'Water em português', answer: 'Água'),
        ],
      ),
    );
  }*/

  void _navigateToEditCollection(Collection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionEditPage(
          collection: collection,
          collectionService: _collectionService,
        ),
      ),
    ).then((hasChanges) {
      // Atualiza a tela se houve mudanças
      if (hasChanges == true) {
        setState(() {});
      }
    });
  }

  Future<void> _deleteCollection(Collection collection) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Excluir Coleção',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja excluir a coleção "${collection.name}"?\n\nTodos os flashcards serão perdidos.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      _collectionService.removeCollection(collection.name);
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coleção "${collection.name}" excluída'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collections = _collectionService.getAllCollectionsSync();
    if (collections.isEmpty && !_collectionService.isLoading) {
      // Show loading indicator or call initialize again
      _loadCollections();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Fundo escuro como na imagem
      appBar: AppBar(
        title: const Text(
          'Flashcards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
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
            // Botões de criação - Layout similar à imagem
            Row(
              children: [
                Expanded(
                  child: _buildCreateButton(
                    'Criar\nFlashcard',
                    Icons.add,
                    const Color(0xFF2A5F4F), // Verde escuro
                    () => _navigateToCreateFlashcard(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCreateButton(
                    'Criar\nColeção',
                    Icons.add,
                    const Color(0xFF2A5F4F), // Verde escuro
                    () => _navigateToCreateCollection(context),
                  ),
                ),
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

  void _navigateToCreateCollection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCollectionScreen(
          collectionService: _collectionService,
        ),
      ),
    ).then((_) {
      // Atualiza a tela quando voltar da criação
      setState(() {});
    });
  }

  Widget _buildCreateButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionSection(Collection collection) {
    // Cores diferentes para cada coleção
    final colors = [
      const Color(0xFF4A90E2), // Azul
      const Color(0xFF7ED321), // Verde
      const Color(0xFFBD10E0), // Roxo
      const Color(0xFFF5A623), // Laranja
      const Color(0xFFD0021B), // Vermelho
    ];

    final colorIndex = collection.name.hashCode % colors.length;
    final collectionColor = colors[colorIndex.abs()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da coleção
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: collectionColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                collection.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _navigateToEditCollection(collection),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _deleteCollection(collection),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grid de flashcards (similar à imagem)
        _buildFlashcardsGrid(collection.flashcards, collectionColor),
      ],
    );
  }

  Widget _buildFlashcardsGrid(List<Flashcard> flashcards, Color color) {
    // Mostra no máximo 6 flashcards por coleção
    final displayCards = flashcards.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: displayCards.length,
      itemBuilder: (context, index) {
        return _buildFlashcardTile(displayCards[index], color);
      },
    );
  }

  Widget _buildFlashcardTile(Flashcard flashcard, Color color) {
    final cardKey = '${flashcard.question}_${flashcard.answer}';
    final isFlipped = _flippedCards[cardKey] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _flippedCards[cardKey] = !isFlipped;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                isFlipped ? flashcard.answer : flashcard.question,
                key: ValueKey(isFlipped),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCreateFlashcard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateFlashcardScreen(
          collectionService: _collectionService,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _viewCollection(Collection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            title: Text(
              collection.name,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A1A1A),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: collection.flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = collection.flashcards[index];
              return Card(
                color: const Color(0xFF2A2A2A),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    flashcard.question,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    flashcard.answer,
                    style: TextStyle(color: Colors.white70),
                  ),
                  //onTap: () => _showFlashcardDetails(flashcard),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
