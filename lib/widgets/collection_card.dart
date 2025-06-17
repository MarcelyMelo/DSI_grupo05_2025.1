import 'package:flutter/material.dart';
import '../models/collection.dart';

class CollectionCard extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(collection.name),
        subtitle: Text('${collection.flashcards.length} flashcards'),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}