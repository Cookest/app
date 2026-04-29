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
    await _dio.post('/api/meal-plans/generate', data: {});
  }

  Future<void> completeSlot(String planId, String slotId) async {
    await _dio.put('/api/meal-plans/$planId/slots/$slotId/complete');
  }

  Future<void> setFlex(String planId, String slotId, String flexType) async {
    await _dio.put('/api/meal-plans/$planId/slots/$slotId/flex', data: {'flex_type': flexType});
  }

  Future<void> swapRecipe(String planId, String slotId, String recipeId) async {
    await _dio.put('/api/meal-plans/$planId/slots/$slotId', data: {'recipe_id': recipeId});
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
