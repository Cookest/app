import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/meal_plan.dart';

class MealPlanRepository {
  final Dio _dio;

  MealPlanRepository(this._dio);

  Future<MealPlan?> getCurrentPlan() async {
    try {
      final response = await _dio.get('/api/meal-plans/current');
      if (response.data == null) return null;
      return MealPlan.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> generatePlan() async {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - DateTime.monday));
    final weekStart =
        '${monday.year.toString().padLeft(4, '0')}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

    await _dio.post('/api/meal-plans/generate', data: {
      'week_start': weekStart,
    });
  }

  Future<void> completeSlot(String planId, String slotId) async {
    await _dio.put('/api/meal-plans/$planId/slots/$slotId/complete');
  }

  Future<void> setFlex(String planId, String slotId, String flexType) async {
    await _dio.put('/api/meal-plans/$planId/slots/$slotId/flex', data: {'flex_type': flexType});
  }

  /// Assign a recipe to a slot.
  ///
  /// - If [slotId] is a real numeric DB id → PUT (update existing row)
  /// - Otherwise (synthesised placeholder like "1_breakfast") → POST (create new row)
  Future<void> swapRecipe(
    String planId,
    String slotId,
    String recipeId, {
    int? dayOfWeek,
    String? mealType,
    int? servings,
  }) async {
    final recipeIdInt = int.tryParse(recipeId);
    if (recipeIdInt == null) {
      throw 'Invalid recipe id: $recipeId';
    }

    final slotIdInt = int.tryParse(slotId);

    if (slotIdInt != null) {
      // Existing DB row — update it
      await _dio.put(
        '/api/meal-plans/$planId/slots/$slotId',
        data: {'recipe_id': recipeIdInt},
      );
    } else {
      // Synthesised placeholder — create a new slot
      if (dayOfWeek == null || mealType == null) {
        throw 'dayOfWeek and mealType are required when creating a new slot';
      }
      await _dio.post(
        '/api/meal-plans/$planId/slots',
        data: {
          'recipe_id': recipeIdInt,
          'day_of_week': dayOfWeek,
          'meal_type': mealType,
          if (servings != null) 'servings': servings,
        },
      );
    }
  }

  Future<Map<String, dynamic>> getNutrition(String planId) async {
    final response = await _dio.get('/api/meal-plans/$planId/nutrition');
    return response.data;
  }
}


final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepository(ref.watch(dioProvider));
});

final currentMealPlanProvider = FutureProvider<MealPlan?>((ref) async {
  return ref.watch(mealPlanRepositoryProvider).getCurrentPlan();
});
