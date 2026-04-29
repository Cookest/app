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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled Recipe',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      cuisine: json['cuisine']?.toString(),
      category: json['category']?.toString(),
      difficulty: json['difficulty']?.toString() ?? 'medium',
      totalTimeMin: json['total_time_min'] as int? ?? 0,
      vegetarian: json['vegetarian'] as bool? ?? false,
      vegan: json['vegan'] as bool? ?? false,
      glutenFree: json['gluten_free'] as bool? ?? false,
      dairyFree: json['dairy_free'] as bool? ?? false,
      matchPct: (json['match_pct'] as num?)?.toDouble(),
      images: json['images'] != null
          ? (json['images'] as List).map((e) => e?.toString() ?? '').toList()
          : null,
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List).map((e) => e?.toString() ?? '').toList()
          : null,
      instructions: json['instructions'] != null
          ? (json['instructions'] as List).map((e) => e?.toString() ?? '').toList()
          : null,
    );
  }
}
