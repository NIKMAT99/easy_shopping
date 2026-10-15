import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/loyalty_card.dart';
import '../models/price_comparison.dart';
import '../models/shopping_item.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;
  final String _table = 'shopping_list';

  // Ottiene la lista in tempo reale
  Stream<List<ShoppingItem>> getShoppingListStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => ShoppingItem.fromJson(json)).toList());
  }

  // Aggiunge un nuovo elemento
  Future<void> addItem(String name) async {
    await _supabase.from(_table).insert({
      'name': name,
      'quantity': 1,
      'is_bought': false,
    });
  }

  // Aggiorna lo stato (comprato/non comprato)
  Future<void> toggleItemState(String id, bool currentState) async {
    await _supabase
        .from(_table)
        .update({'is_bought': !currentState})
        .eq('id', id);
  }

  // Rimuove un elemento
  Future<void> removeItem(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }

  Stream<List<LoyaltyCard>> getLoyaltyCardsStream() {
    return _supabase
        .from('loyalty_cards')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => LoyaltyCard.fromJson(json)).toList());
  }

  // Salva una nuova carta fedeltà
  Future<void> addLoyaltyCard(String storeName, String barcodeData, String barcodeType) async {
    await _supabase.from('loyalty_cards').insert({
      'store_name': storeName,
      'barcode_data': barcodeData,
      'barcode_type': barcodeType,
    });
  }

// Metodo per confrontare i prezzi interrogando la view 'price_comparison'
  Future<List<PriceComparisonResult>> compareCart(List<String> itemsToSearch) async {
    double totalTigros = 0.0;
    double totalCoop = 0.0;
    List<FoundProduct> productsTigros = [];
    List<FoundProduct> productsCoop = [];
    int missingTigros = 0;
    int missingCoop = 0;

    for (String item in itemsToSearch) {
      final response = await _supabase
          .from('price_comparison')
          .select()
          .ilike('product_name', '%$item%')
          .limit(1);

      if (response.isNotEmpty) {
        final match = response.first;
        final String barcode = match['barcode'] ?? '';
        final String brand = match['brand'] ?? 'Sconosciuto';
        final String name = match['product_name'] ?? item;

        // Controllo Tigros
        final priceTigros = match['price_tigros'];
        if (priceTigros != null) {
          double p = (priceTigros as num).toDouble();
          totalTigros += p;
          productsTigros.add(FoundProduct(barcode: barcode, brand: brand, name: name, price: p));
        } else {
          missingTigros++;
        }

        // Controllo Coop
        final priceCoop = match['price_coop'];
        if (priceCoop != null) {
          double p = (priceCoop as num).toDouble();
          totalCoop += p;
          productsCoop.add(FoundProduct(barcode: barcode, brand: brand, name: name, price: p));
        } else {
          missingCoop++;
        }

      } else {
        missingTigros++;
        missingCoop++;
      }
    }

    List<PriceComparisonResult> results = [
      PriceComparisonResult(
        supermarketName: 'Tigros',
        address: 'Punto vendita Tigros',
        distanceInMeters: 2500.0, // Esempio: 2.5km (da calcolare con Geolocator in futuro)
        totalCartPrice: totalTigros,
        missingItemsCount: missingTigros,
        foundProducts: productsTigros,
      ),
      PriceComparisonResult(
        supermarketName: 'Coop',
        address: 'Punto vendita Coop',
        distanceInMeters: 4200.0, // Esempio: 4.2km
        totalCartPrice: totalCoop,
        missingItemsCount: missingCoop,
        foundProducts: productsCoop,
      ),
    ];

    // Nascondi i supermercati che sono fuori dal raggio o che non hanno nessun prodotto
    results.removeWhere((store) => store.foundProducts.isEmpty);
    results.sort((a, b) => a.totalCartPrice.compareTo(b.totalCartPrice));

    return results;
  }
}