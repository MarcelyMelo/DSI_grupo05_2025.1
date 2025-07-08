import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/collection.dart';
import '../models/flashcard.dart';
import '../services/collection_service.dart';
import '../widgets/flipcard.dart';

class FlashcardCollectionScreen extends StatefulWidget {
  final Collection collection;
  final CollectionService collectionService;

  const FlashcardCollectionScreen({
    Key? key,
    required this.collection,
    required this.collectionService,
  }) : super(key: key);

  @override
  State<FlashcardCollectionScreen> createState() =>
      _FlashcardCollectionScreenState();
}

class _FlashcardCollectionScreenState extends State<FlashcardCollectionScreen> {
  PageController _pageController = PageController();
  int currentIndex = 0;
  late List<Flashcard> flashcards;

  @override
  void initState() {
    super.initState();
    flashcards = widget.collection.flashcards;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextCard() {
    if (currentIndex < flashcards.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousCard() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Method to mark flashcard as known/unknown
  Future<void> _toggleFlashcardStatus(int index) async {
    try {
      final flashcard = flashcards[index];
      final newStatus = !flashcard.isKnown;

      // Update in the service
      await widget.collectionService.updateFlashcardStatus(
        widget.collection.name,
        index,
        newStatus,
      );

      // Update local state
      setState(() {
        flashcards[index].isKnown = newStatus;
      });

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Marcado como conhecido!' : 'Marcado como desconhecido',
          ),
          duration: Duration(seconds: 1),
          backgroundColor: newStatus ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.collection.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Show progress in app bar
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                '${currentIndex + 1}/${flashcards.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: flashcards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.style,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum flashcard encontrado',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress indicator
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currentIndex + 1} de ${flashcards.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 4,
                        child: LinearProgressIndicator(
                          value: (currentIndex + 1) / flashcards.length,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                        ),
                      ),
                    ],
                  ),
                ),
                // Flashcard viewer
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemCount: flashcards.length,
                    itemBuilder: (context, index) {
                      final flashcard = flashcards[index];
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: FlipCard(
                          front: flashcard.question,
                          back: flashcard.answer,
                          isKnown: flashcard.isKnown,
                          onStatusToggle: () => _toggleFlashcardStatus(index),
                        ),
                      );
                    },
                  ),
                ),
                // Navigation buttons
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: currentIndex > 0 ? _previousCard : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, size: 20),
                            SizedBox(width: 8),
                            Text('Anterior'),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: currentIndex < flashcards.length - 1
                            ? _nextCard
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Próximo'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
