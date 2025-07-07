import 'package:dsi_projeto/components/colors/appColors.dart';
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
      if (hasChanges == true) {
        setState(() {});
      }
    });
  }

  Future<void> _deleteCollection(Collection collection) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLogin,
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
      _loadCollections();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLogin,
      appBar: AppBar(
        title: const Text(
          'Flashcards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
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
      body: collections.isEmpty
          ? _buildEmptyState()
          : _buildCollectionsList(collections),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botões de criação - Layout minimalista
          Row(
            children: [
              Expanded(
                child: _buildCreateButton(
                  'Criar\nFlashcard',
                  Icons.add,
                  AppColors.blue,
                  () => _navigateToCreateFlashcard(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCreateButton(
                  'Criar\nColeção',
                  Icons.add,
                  AppColors.blue,
                  () => _navigateToCreateCollection(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
          Text(
            'Nenhuma coleção criada ainda',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsList(List<Collection> collections) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botões de criação no topo
          Row(
            children: [
              Expanded(
                child: _buildCreateButton(
                  'Criar\nFlashcard',
                  Icons.add,
                  AppColors.blue,
                  () => _navigateToCreateFlashcard(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCreateButton(
                  'Criar\nColeção',
                  Icons.add,
                  AppColors.blue,
                  () => _navigateToCreateCollection(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Lista de coleções com design minimalista
          Expanded(
            child: ListView.separated(
              itemCount: collections.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return _buildCollectionCard(collections[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
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

  Widget _buildCollectionCard(Collection collection) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLogin,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da coleção
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  collection.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.edit_outlined, color: Colors.white70),
                    onPressed: () => _navigateToEditCollection(collection),
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, color: Colors.white70),
                    onPressed: () => _deleteCollection(collection),
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${collection.flashcards.length} flashcards',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),

          // Preview dos flashcards
          if (collection.flashcards.isNotEmpty) ...[
            _buildFlashcardPreview(collection.flashcards.first),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _viewCollection(collection),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Ver todos os flashcards',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                'Nenhum flashcard ainda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlashcardPreview(Flashcard flashcard) {
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
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFlipped ? 'Resposta:' : 'Pergunta:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                isFlipped ? flashcard.answer : flashcard.question,
                key: ValueKey(isFlipped),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque para ${isFlipped ? 'ver pergunta' : 'ver resposta'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.4),
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
      setState(() {});
    });
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
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A1A1A),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: collection.flashcards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final flashcard = collection.flashcards[index];
              final cardKey =
                  '${flashcard.question}_${flashcard.answer}_$index';
              final isFlipped = _flippedCards[cardKey] ?? false;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _flippedCards[cardKey] = !isFlipped;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFlipped ? 'Resposta:' : 'Pergunta:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isFlipped ? flashcard.answer : flashcard.question,
                          key: ValueKey(isFlipped),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque para ${isFlipped ? 'ver pergunta' : 'ver resposta'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
