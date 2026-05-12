class InventoryItem {
  final String id;
  final int ingredientId;
  final String name; // ingredient_name or custom_name
  final double quantity;
  final String unit;
  final String location; // fridge, pantry, freezer
  final DateTime? expiryDate;
  final int? daysUntilExpiry;
  final bool expiryWarning;

  InventoryItem({
    required this.id,
    required this.ingredientId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.location,
    this.expiryDate,
    this.daysUntilExpiry,
    this.expiryWarning = false,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final name = (json['custom_name'] ?? json['ingredient_name'] ?? json['name'])?.toString() ?? '';
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      ingredientId: (json['ingredient_id'] as num?)?.toInt() ?? 0,
      name: name,
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      unit: json['unit']?.toString() ?? 'pcs',
      location: (json['storage_location'] ?? json['location'])?.toString() ?? 'pantry',
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
      daysUntilExpiry: (json['days_until_expiry'] as num?)?.toInt(),
      expiryWarning: json['expiry_warning'] == true,
    );
  }
}

class IngredientSuggestion {
  final int id;
  final String name;
  final String? category;

  IngredientSuggestion({required this.id, required this.name, this.category});

  factory IngredientSuggestion.fromJson(Map<String, dynamic> json) {
    return IngredientSuggestion(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString(),
    );
  }
}

class RecipeSuggestion {
  final int recipeId;
  final String name;
  final String slug;
  final String? primaryImageUrl;
  final int? totalTimeMin;
  final String? difficulty;
  final int ingredientsHave;
  final int ingredientsTotal;
  final int matchPct;

  RecipeSuggestion({
    required this.recipeId,
    required this.name,
    required this.slug,
    this.primaryImageUrl,
    this.totalTimeMin,
    this.difficulty,
    required this.ingredientsHave,
    required this.ingredientsTotal,
    required this.matchPct,
  });

  factory RecipeSuggestion.fromJson(Map<String, dynamic> json) {
    return RecipeSuggestion(
      recipeId: (json['recipe_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      primaryImageUrl: json['primary_image_url']?.toString(),
      totalTimeMin: (json['total_time_min'] as num?)?.toInt(),
      difficulty: json['difficulty']?.toString(),
      ingredientsHave: (json['ingredients_have'] as num?)?.toInt() ?? 0,
      ingredientsTotal: (json['ingredients_total'] as num?)?.toInt() ?? 1,
      matchPct: (json['match_pct'] as num?)?.toInt() ?? 0,
    );
  }
}

class DetectedGroceryItem {
  final String name;
  double quantity;
  String unit;
  final String? category;
  String storageLocation;
  bool selected;

  DetectedGroceryItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
    required this.storageLocation,
    this.selected = true,
  });

  factory DetectedGroceryItem.fromJson(Map<String, dynamic> json) {
    return DetectedGroceryItem(
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit']?.toString() ?? 'pcs',
      category: json['category']?.toString(),
      storageLocation: json['storage_location']?.toString() ?? 'pantry',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'storage_location': storageLocation,
      };
}

