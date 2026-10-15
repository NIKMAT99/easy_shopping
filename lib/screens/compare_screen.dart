import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/location_service.dart';
import '../providers/shopping_provider.dart';
import '../models/price_comparison.dart';
import 'store_detail_screen.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final TextEditingController _addressController = TextEditingController();
  Position? _currentPosition;
  double _searchRadius = 5.0;
  bool _isLoading = false;

  // Dichiariamo esplicitamente il tipo corretto qui
  List<PriceComparisonResult> _results = [];

  @override
  void initState() {
    super.initState();
    _addressController.text = "Usa la mia posizione attuale";
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      _currentPosition = await LocationService().getCurrentLocation();
      setState(() {
        _addressController.text = "Posizione GPS acquisita";
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateSavings() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un indirizzo o usa il GPS')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _results.clear();
    });

    final shoppingListState = ref.read(shoppingListProvider);
    List<String> itemsToSearch = [];
    if (shoppingListState.hasValue) {
      itemsToSearch = shoppingListState.value!
          .where((item) => !item.isBought)
          .map((item) => item.name)
          .toList();
    }

    if (itemsToSearch.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La tua lista della spesa è vuota!')),
      );
      return;
    }

    try {
      // Otteniamo il servizio
      final supabaseService = ref.read(supabaseServiceProvider);

      // Chiamata tipizzata correttamente
      final List<PriceComparisonResult> dbResults = await supabaseService.compareCart(itemsToSearch);

      setState(() {
        _results = dbResults;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calcola il Risparmio')),
      body: Column(
        children: [
          // HEADER DI RICERCA
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Indirizzo di partenza',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _useCurrentLocation,
                      icon: const Icon(Icons.my_location),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text('Raggio massimo: ${_searchRadius.toInt()} km',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _searchRadius,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '${_searchRadius.toInt()} km',
                  onChanged: (value) => setState(() => _searchRadius = value),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _calculateSavings,
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.calculate),
                    label: const Text('Trova il prezzo migliore'),
                  ),
                )
              ],
            ),
          ),

          // LISTA DEI RISULTATI
          Expanded(
            child: _results.isEmpty
                ? Center(
              child: Text(
                'Imposta la zona e scopri dove conviene fare la spesa',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                // store è ora correttamente riconosciuto come PriceComparisonResult
                final store = _results[index];
                final isBestPrice = index == 0;

                final distanceText = store.distanceInMeters < 1000
                    ? '${store.distanceInMeters.toStringAsFixed(0)} m'
                    : '${(store.distanceInMeters / 1000).toStringAsFixed(1)} km';

                return Card(
                  elevation: isBestPrice ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isBestPrice ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // builder riconosce store senza errori
                          builder: (context) => StoreDetailScreen(store: store),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isBestPrice)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('MIGLIOR PREZZO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                store.supermarketName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '€${store.totalCartPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isBestPrice ? Colors.green[700] : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(Icons.shopping_cart_checkout, size: 16, color: Colors.blue[700]),
                              const SizedBox(width: 6),
                              // foundProducts viene riconosciuto dal compiler
                              Text(
                                'Trovati ${store.foundProducts.length} prodotti su ${store.foundProducts.length + store.missingItemsCount}',
                                style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('${store.address} • a $distanceText', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (store.missingItemsCount > 0)
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text('${store.missingItemsCount} mancanti',
                                        style: const TextStyle(color: Colors.orange, fontSize: 12)),
                                  ],
                                )
                              else
                                const Text('Tutti i prodotti trovati!', style: TextStyle(color: Colors.green, fontSize: 12)),

                              const Row(
                                children: [
                                  Text('Vedi prodotti', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  Icon(Icons.chevron_right, color: Colors.green),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}