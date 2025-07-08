import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/collection.dart';
import '../models/flashcard.dart';
import '../services/collection_service.dart';

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

class FlipCard extends StatefulWidget {
  final String front;
  final String back;
  final bool isKnown;
  final VoidCallback onStatusToggle;

  const FlipCard({
    Key? key,
    required this.front,
    required this.back,
    required this.isKnown,
    required this.onStatusToggle,
  }) : super(key: key);

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isShowingFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (!_controller.isAnimating) {
      if (isShowingFront) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      isShowingFront = !isShowingFront;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingFrontSide = _animation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value * math.pi),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isShowingFrontSide
                        ? [Colors.blue[400]!, Colors.blue[600]!]
                        : widget.isKnown
                            ? [Colors.green[400]!, Colors.green[600]!]
                            : [Colors.orange[400]!, Colors.orange[600]!],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isShowingFrontSide
                            ? Icons.help_outline
                            : Icons.lightbulb_outline,
                        size: 48,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      SizedBox(height: 24),
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateY(isShowingFrontSide ? 0 : math.pi),
                        child: Text(
                          isShowingFrontSide ? widget.front : widget.back,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 24),
                      if (!isShowingFrontSide) ...[
                        // Status toggle button (only on answer side)
                        ElevatedButton.icon(
                          onPressed: widget.onStatusToggle,
                          icon: Icon(
                            widget.isKnown
                                ? Icons.check_circle
                                : Icons.help_outline,
                            color: Colors.white,
                          ),
                          label: Text(
                            widget.isKnown ? 'Eu sei!' : 'Não sei',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isShowingFrontSide
                              ? 'Toque para ver a resposta'
                              : 'Toque para ver a pergunta',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
