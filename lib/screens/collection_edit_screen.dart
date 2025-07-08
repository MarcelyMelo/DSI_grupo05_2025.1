import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../models/flashcard.dart';
import '../services/collection_service.dart';

class CollectionEditPage extends StatefulWidget {
  final Collection collection;
  final CollectionService collectionService;

  const CollectionEditPage({
    super.key,
    required this.collection,
    required this.collectionService,
  });

  @override
  State<CollectionEditPage> createState() => _CollectionEditPageState();
}

class _CollectionEditPageState extends State<CollectionEditPage> {
  late TextEditingController _nameController;
  late List<Flashcard> _flashcards;
  late String _originalName;
  final TextEditingController _searchController = TextEditingController();
  List<Flashcard> _filteredFlashcards = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _originalName = widget.collection.name;
    _nameController = TextEditingController(text: widget.collection.name);
    _flashcards = List.from(widget.collection.flashcards);
    _filteredFlashcards = List.from(_flashcards);
    _searchController.addListener(_filterFlashcards);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _removeFlashcard(int index) async {
    // Get the actual flashcard from the original list
    final flashcardToRemove =
        _isSearching ? _filteredFlashcards[index] : _flashcards[index];
    final shouldRemove = await _showRemoveDialog();

    if (shouldRemove == true) {
      setState(() {
        _flashcards.remove(flashcardToRemove);
        _filteredFlashcards.remove(flashcardToRemove);
      });

      _updateCollectionInService();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flashcard removido da coleção'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<bool?> _showRemoveDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Remover Flashcard',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja remover este flashcard da coleção?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _filterFlashcards() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredFlashcards = List.from(_flashcards);
      } else {
        _filteredFlashcards = _flashcards.where((flashcard) {
          return flashcard.question
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              flashcard.answer
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
        }).toList();
      }
    });
  }

  void _updateCollectionInService() {
    // Remove a coleção antiga
    widget.collectionService.removeCollection(_originalName);

    // Adiciona a coleção atualizada
    final updatedCollection = Collection(
      name: _nameController.text,
      flashcards: _flashcards,
      createdAt: widget.collection.createdAt,
    );

    widget.collectionService.addCollection(updatedCollection);

    // Atualiza o nome original se foi alterado
    _originalName = _nameController.text;
  }

  Future<void> _saveChanges() async {
    try {
      // Validar nome
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O nome da coleção não pode estar vazio'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Atualizar coleção no service
      _updateCollectionInService();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alterações salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context)
            .pop(true); // Retorna true indicando que houve mudanças
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Limpar Tudo',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja remover todos os flashcards desta coleção?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      setState(() {
        _flashcards.clear();
        _filteredFlashcards.clear();
      });

      _updateCollectionInService();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos os flashcards foram removidos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2332),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 20),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _saveChanges,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 20),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo Nome
            // Campo Nome
            Row(
              children: [
                const Text(
                  'Nome:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

// Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar flashcards...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botão Limpar Tudo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _flashcards.isEmpty ? null : _clearAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A4A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Limpar tudo'),
              ),
            ),

            const SizedBox(height: 20),

            // Lista de Flashcards
            Expanded(
              child: _filteredFlashcards.isEmpty
                  ? Center(
                      child: _isSearching && _filteredFlashcards.isEmpty
                          ? const Text(
                              'Nenhum flashcard encontrado',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            )
                          : const Text(
                              'Nenhum flashcard nesta coleção',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: _filteredFlashcards.length,
                      itemBuilder: (context, index) {
                        final flashcard = _filteredFlashcards[index];
                        return FlashcardEditItem(
                          flashcard: flashcard,
                          onRemove: () => _removeFlashcard(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardEditItem extends StatelessWidget {
  final Flashcard flashcard;
  final VoidCallback onRemove;

  const FlashcardEditItem({
    super.key,
    required this.flashcard,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A90A4), // Cor azul dos cards da imagem
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Conteúdo do flashcard
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                flashcard.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Botão X para remover
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
