class LoyaltyCard {
  final String id;
  final String storeName;
  final String barcodeData;
  final String barcodeType;

  LoyaltyCard({
    required this.id,
    required this.storeName,
    required this.barcodeData,
    required this.barcodeType,
  });

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as String,
      storeName: json['store_name'] as String,
      barcodeData: json['barcode_data'] as String,
      barcodeType: json['barcode_type'] as String,
    );
  }
}