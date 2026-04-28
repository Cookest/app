class Recipe {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String? cuisine;
  final String? category;
  final String difficulty;
  final int totalTimeMin;
  final bool vegetarian;
  final bool vegan;
  final bool glutenFree;
  final bool dairyFree;
  final double? matchPct;
  final List<String>? images;
  final List<String>? ingredients;
  final List<String>? instructions;

  Recipe({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.cuisine,
    this.category,
    required this.difficulty,
    required this.totalTimeMin,
    required this.vegetarian,
    required this.vegan,
    required this.glutenFree,
    required this.dairyFree,
    this.matchPct,
    this.images,
    this.ingredients,
    this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      cuisine: json['cuisine'],
      category: json['category'],
      difficulty: json['difficulty'],
      totalTimeMin: json['total_time_min'],
      vegetarian: json['vegetarian'] ?? false,
      vegan: json['vegan'] ?? false,
      glutenFree: json['gluten_free'] ?? false,
      dairyFree: json['dairy_free'] ?? false,
      matchPct: (json['match_pct'] as num?)?.toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      ingredients: json['ingredients'] != null ? List<String>.from(json['ingredients']) : null,
      instructions: json['instructions'] != null ? List<String>.from(json['instructions']) : null,
    );
  }
}
