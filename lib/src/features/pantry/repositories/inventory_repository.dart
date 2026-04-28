import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/inventory_item.dart';

class InventoryRepository {
  final Dio _dio;

  InventoryRepository(this._dio);

  Future<List<InventoryItem>> getInventory() async {
    final response = await _dio.get('/api/inventory');
    return (response.data as List).map((i) => InventoryItem.fromJson(i)).toList();
  }

  Future<void> addItem(Map<String, dynamic> data) async {
    await _dio.post('/api/inventory', data: data);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    await _dio.put('/api/inventory/$id', data: data);
  }

  Future<void> deleteItem(String id) async {
    await _dio.delete('/api/inventory/$id');
  }

  Future<int> getExpiringCount() async {
    try {
      final response = await _dio.get('/api/inventory/expiring');
      return (response.data as List).length;
    } catch (_) {
      return 0;
    }
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(dioProvider));
});

final expiringCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(inventoryRepositoryProvider).getExpiringCount();
});

final inventoryListProvider = FutureProvider<List<InventoryItem>>((ref) async {
  return ref.watch(inventoryRepositoryProvider).getInventory();
});

