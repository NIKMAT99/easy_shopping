class FoundProduct {
  final String barcode;
  final String brand;
  final String name;
  final double price;
  final String? imageUrl; // Opzionale: per quando avrai le foto nel DB

  FoundProduct({
    required this.barcode,
    required this.brand,
    required this.name,
    required this.price,
    this.imageUrl,
  });
}

class PriceComparisonResult {
  final String supermarketName;
  final String address;
  final double distanceInMeters;
  final double totalCartPrice;
  final int missingItemsCount;
  final List<FoundProduct> foundProducts; // Ora salviamo i prodotti reali!

  PriceComparisonResult({
    required this.supermarketName,
    required this.address,
    required this.distanceInMeters,
    required this.totalCartPrice,
    required this.missingItemsCount,
    required this.foundProducts,
  });
}