class ShoppingItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final bool isChecked;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.isChecked,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit']?.toString() ?? 'pcs',
      isChecked: json['is_checked'] as bool? ?? false,
    );
  }
}
