import 'package:flutter/material.dart';
import '../models/price_comparison.dart'; // Assicurati di importare i modelli corretti

class StoreDetailScreen extends StatelessWidget {
  final PriceComparisonResult store;

  const StoreDetailScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettagli ${store.supermarketName}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: store.foundProducts.length,
        itemBuilder: (context, index) {
          final product = store.foundProducts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            child: ExpansionTile(
              // Intestazione del prodotto
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(product.brand),
              trailing: Text(
                '€${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
              ),
              childrenPadding: const EdgeInsets.all(16.0),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              // Contenuto espanso (Prodotti Simili)
              children: [
                const Divider(),
                const Text(
                  'Alternative Simili:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildSimilarProductMock(context, 'Marca Bianca', 'Alternativa economica', product.price * 0.8),
                _buildSimilarProductMock(context, 'Marca Premium', 'Alternativa di marca', product.price * 1.3),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Totale: €${store.totalCartPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Indicazioni stradali in apertura...')),
                  );
                },
                icon: const Icon(Icons.directions),
                label: const Text('Andiamo!'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget di supporto per simulare le alternative
  Widget _buildSimilarProductMock(BuildContext context, String brand, String name, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12)),
                Text(brand, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text('€${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sostituito nella lista!')),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Sostituisci', style: TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }
}