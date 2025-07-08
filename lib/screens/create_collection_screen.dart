import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../services/collection_service.dart';

class CreateCollectionScreen extends StatefulWidget {
  final CollectionService collectionService;

  const CreateCollectionScreen({super.key, required this.collectionService});

  @override
  _CreateCollectionScreenState createState() => _CreateCollectionScreenState();
}

class _CreateCollectionScreenState extends State<CreateCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCollection() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newCollection = Collection(
          name: _nameController.text,
        );

        // Adiciona a coleção ao service
        await widget.collectionService.addCollection(newCollection);

        // Debug para verificar se foi adicionada
        print('Coleção criada: ${_nameController.text}');
        final collections = await widget.collectionService.getAllCollections();
        print('Total de coleções: ${collections.length}');

        // Volta para a tela anterior
        Navigator.pop(context, "/flashcards");

        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Coleção "${_nameController.text}" criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Mostra mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar coleção: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLogin, // Tema escuro consistente
      appBar: AppBar(
        title: const Text(
          'Criar Nova Coleção',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.backgroundLogin,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome da Coleção',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createCollection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue, // Cor do botão
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Criar Coleção',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
