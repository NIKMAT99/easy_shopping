import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Aggiungi questo import
import '../providers/shopping_provider.dart';
import '../services/ocr_service.dart'; // Aggiungi questo import

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false; // Per mostrare un caricamento durante l'OCR

  Future<void> _scanShoppingList() async {
    // 1. Scatta la foto
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) return; // L'utente ha annullato

    setState(() => _isProcessing = true);

    try {
      // 2. Elabora l'immagine con ML Kit
      final ocrService = OcrService();
      final extractedItems = await ocrService.processImage(image.path);
      ocrService.dispose();

      // 3. Aggiungi i prodotti estratti allo stato di Riverpod
      if (extractedItems.isNotEmpty) {
        for (String item in extractedItems) {
          await ref.read(supabaseServiceProvider).addItem(item);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Trovati ${extractedItems.length} prodotti!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nessun testo rilevato. Riprova.')),
          );
        }
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListAsync = ref.watch(shoppingListProvider);
    final supabaseService = ref.read(supabaseServiceProvider);
    final shoppingList = ref.watch(shoppingListProvider);
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('La mia spesa')),
      body: shoppingListAsync.when(
        data: (shoppingList) {
          if (shoppingList.isEmpty) {
            return const Center(child: Text('La tua lista è vuota'));
          }
          return ListView.builder(
            itemCount: shoppingList.length,
            itemBuilder: (context, index) {
              final item = shoppingList[index];
              return CheckboxListTile(
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.isBought ? TextDecoration.lineThrough : null,
                  ),
                ),
                value: item.isBought,
                // Usiamo direttamente il servizio Supabase per le azioni
                onChanged: (_) => supabaseService.toggleItemState(item.id, item.isBought),
                secondary: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => supabaseService.removeItem(item.id),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore: $error')),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "ocr_btn",
            onPressed: _isProcessing ? null : _scanShoppingList,
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "add_btn",
            // _showAddDialog rimane lo stesso del blocco precedente
            onPressed: () => _showAddDialog(context, ref, textController),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi prodotto'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Es. Latte, Pane...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(supabaseServiceProvider).addItem(controller.text);
                controller.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }
}