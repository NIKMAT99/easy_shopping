import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../models/loyalty_card.dart';
import '../providers/shopping_provider.dart';
import 'scanner_screen.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  Future<void> _scanAndAddCard(BuildContext context, WidgetRef ref) async {
    // 1. Apri lo scanner
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    if (result == null || !context.mounted) return;

    // 2. Chiedi il nome del supermercato tramite dialog
    final nameController = TextEditingController();
    final storeName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Associa supermercato'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Es. Esselunga, Conad...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Salva'),
          ),
        ],
      ),
    );

    if (storeName != null && storeName.isNotEmpty) {
      // 3. Salva su Supabase
      ref.read(supabaseServiceProvider).addLoyaltyCard(
        storeName,
        result['data'],
        result['type'],
      );
    }
  }

  // Converte il formato stringa in un tipo compatibile con barcode_widget
  Barcode _getBarcodeType(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'code128': return Barcode.code128();
      case 'ean13': return Barcode.ean13();
      case 'ean8': return Barcode.ean8();
      case 'qr': return Barcode.qrCode();
      default: return Barcode.code128(); // Fallback generico
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(loyaltyCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Carte Fedeltà')),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text('Nessuna carta salvata.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(card.storeName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 20),
                      BarcodeWidget(
                        barcode: _getBarcodeType(card.barcodeType),
                        data: card.barcodeData,
                        width: double.infinity,
                        height: 100,
                        errorBuilder: (context, error) =>
                            Center(child: Text('Formato non supportato: ${card.barcodeType}')),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Errore: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scanAndAddCard(context, ref),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Aggiungi Carta'),
      ),
    );
  }
}