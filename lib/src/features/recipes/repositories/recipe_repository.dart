import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final Dio _dio;

  RecipeRepository(this._dio);

  Future<List<Recipe>> getRecipes({
    String? q,
    String? cuisine,
    String? category,
    bool? matchInventory,
    int page = 1,
  }) async {
    final response = await _dio.get('/api/recipes', queryParameters: {
      if (q != null) 'q': q,
      if (cuisine != null) 'cuisine': cuisine,
      if (category != null) 'category': category,
      if (matchInventory != null) 'match_inventory': matchInventory,
      'page': page,
      'per_page': 20,
    });
    
    final data = response.data;
    final List items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['data'] is List) {
      items = data['data'] as List;
    } else {
      items = [];
    }
    return items.map((r) => Recipe.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Recipe> getRecipe(String id) async {
    final response = await _dio.get('/api/recipes/$id');
    return Recipe.fromJson(response.data);
  }

  Future<void> createRecipe(Map<String, dynamic> data) async {
    try {
      await _dio.post('/api/recipes', data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        throw 'Creating recipes is a Pro feature. Please upgrade.';
      }
      throw e.response?.data['error'] ?? 'Failed to create recipe.';
    }
  }
}

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(dioProvider));
});
