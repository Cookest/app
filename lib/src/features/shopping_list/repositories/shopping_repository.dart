import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/shopping_item.dart';

class ShoppingRepository {
  final Dio _dio;

  ShoppingRepository(this._dio);

  Future<List<ShoppingItem>> getShoppingList() async {
    final response = await _dio.get('/api/shopping-list');
    final data = response.data;
    final List items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['items'] is List) {
      items = data['items'] as List;
    } else {
      items = [];
    }
    return items.map((i) => ShoppingItem.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<void> syncFromPlan() async {
    await _dio.post('/api/shopping-list/sync', data: {});
  }

  Future<void> addItem(String name, double quantity, String unit) async {
    await _dio.post('/api/shopping-list/items', data: {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    });
  }

  Future<void> toggleCheck(String id, bool isChecked) async {
    await _dio.patch('/api/shopping-list/items/$id/check', data: {
      'is_checked': isChecked,
    });
  }

  Future<void> deleteItem(String id) async {
    await _dio.delete('/api/shopping-list/items/$id');
  }

  Future<Map<String, dynamic>> getPrices() async {
    // Pro feature
    final response = await _dio.get('/api/shopping-list/prices');
    return response.data;
  }

  Future<Map<String, dynamic>> optimize() async {
    // Pro feature
    final response = await _dio.get('/api/shopping-list/optimize');
    return response.data;
  }
}

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository(ref.watch(dioProvider));
});

final shoppingListProvider = FutureProvider<List<ShoppingItem>>((ref) async {
  return ref.watch(shoppingRepositoryProvider).getShoppingList();
});
