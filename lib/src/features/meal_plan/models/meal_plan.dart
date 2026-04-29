class MealPlan {
  final String id;
  final List<MealSlot> slots;
  final Map<String, dynamic>? nutritionSummary;

  MealPlan({required this.id, required this.slots, this.nutritionSummary});

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id']?.toString() ?? '',
      slots: (json['slots'] as List? ?? [])
          .map((s) => MealSlot.fromJson(s as Map<String, dynamic>))
          .toList(),
      nutritionSummary: json['nutrition'] as Map<String, dynamic>?,
    );
  }
}

class MealSlot {
  final String id;
  final int dayOfWeek; // 0=Mon...6=Sun
  final String mealType; // breakfast/lunch/dinner/snack
  final bool isFlex;
  final String? flexType;
  final bool isCompleted;
  final int servings;
  final RecipeSummary? recipe;

  MealSlot({
    required this.id,
    required this.dayOfWeek,
    required this.mealType,
    required this.isFlex,
    this.flexType,
    required this.isCompleted,
    required this.servings,
    this.recipe,
  });

  factory MealSlot.fromJson(Map<String, dynamic> json) {
    return MealSlot(
      id: json['id']?.toString() ?? '',
      dayOfWeek: json['day_of_week'] as int? ?? 0,
      mealType: json['meal_type']?.toString() ?? 'dinner',
      isFlex: json['is_flex'] as bool? ?? false,
      flexType: json['flex_type']?.toString(),
      isCompleted: json['is_completed'] as bool? ?? false,
      servings: (json['servings'] ?? json['servings_override']) as int? ?? 2,
      recipe: json['recipe'] != null ? RecipeSummary.fromJson(json['recipe'] as Map<String, dynamic>) : null,
    );
  }
}

class RecipeSummary {
  final String id;
  final String name;
  final String? cuisine;
  final int totalTimeMin;
  final String difficulty;

  RecipeSummary({
    required this.id,
    required this.name,
    this.cuisine,
    required this.totalTimeMin,
    required this.difficulty,
  });

  factory RecipeSummary.fromJson(Map<String, dynamic> json) {
    return RecipeSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled Recipe',
      cuisine: json['cuisine']?.toString(),
      totalTimeMin: json['total_time_min'] as int? ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'medium',
    );
  }
}
