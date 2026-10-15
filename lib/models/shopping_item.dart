class ShoppingItem {
  final String id;
  final String name;
  final int quantity;
  final bool isBought;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.isBought = false,
  });

  // Metodo per convertire il JSON di Supabase in un oggetto Dart
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 1,
      isBought: json['is_bought'] as bool? ?? false,
    );
  }

  // Metodo per inviare l'oggetto a Supabase
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, -> Spesso l'ID è generato automaticamente dal DB (UUID)
      'name': name,
      'quantity': quantity,
      'is_bought': isBought,
    };
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    bool? isBought,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
    );
  }
}