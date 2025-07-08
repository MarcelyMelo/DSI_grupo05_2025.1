import 'package:dsi_projeto/screens/flashcard_collection_screen.dart';
import 'package:dsi_projeto/services/collection_service.dart';
import 'package:flutter/material.dart';
import '../models/collection.dart';

class CollectionCard extends StatelessWidget {
  final Collection collection;
  final CollectionService collectionService;

  const CollectionCard({
    Key? key,
    required this.collection,
    required this.collectionService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.folder,
          color: Colors.blue[600],
          size: 32,
        ),
        title: Text(
          collection.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${collection.flashcards.length} flashcards'),
            if (collection.flashcards.isNotEmpty) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${collection.flashcards.where((f) => f.isKnown).length} conhecidos',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to the flashcard collection screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardCollectionScreen(
                collection: collection,
                collectionService: collectionService,
              ),
            ),
          );
        },
      ),
    );
  }
}
