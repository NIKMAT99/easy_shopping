import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty_card.dart';
import '../models/shopping_item.dart';
import '../services/supabase_service.dart';

// Provider per istanziare il servizio
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// StreamProvider che ascolta i cambiamenti del database in tempo reale
final shoppingListProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getShoppingListStream();
});

final loyaltyCardsProvider = StreamProvider<List<LoyaltyCard>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getLoyaltyCardsStream();
});