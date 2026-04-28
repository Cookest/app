class MealPlan {
  final String id;
  final List<MealSlot> slots;
  final Map<String, dynamic>? nutritionSummary;

  MealPlan({required this.id, required this.slots, this.nutritionSummary});

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      slots: (json['slots'] as List).map((s) => MealSlot.fromJson(s)).toList(),
      nutritionSummary: json['nutrition'],
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
      id: json['id'],
      dayOfWeek: json['day_of_week'],
      mealType: json['meal_type'],
      isFlex: json['is_flex'],
      flexType: json['flex_type'],
      isCompleted: json['is_completed'],
      servings: json['servings'],
      recipe: json['recipe'] != null ? RecipeSummary.fromJson(json['recipe']) : null,
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
      id: json['id'],
      name: json['name'],
      cuisine: json['cuisine'],
      totalTimeMin: json['total_time_min'],
      difficulty: json['difficulty'],
    );
  }
}
