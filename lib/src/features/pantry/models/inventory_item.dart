class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String location; // fridge, pantry, freezer
  final DateTime? expiryDate;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.location,
    this.expiryDate,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'pcs',
      location: (json['location'] ?? json['storage_location'])?.toString() ?? 'pantry',
      expiryDate: json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date'].toString()) : null,
    );
  }
}
