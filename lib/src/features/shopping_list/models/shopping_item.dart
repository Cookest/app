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
      id: json['id'],
      name: json['name'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      isChecked: json['is_checked'] ?? false,
    );
  }
}
