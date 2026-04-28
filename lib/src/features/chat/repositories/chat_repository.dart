import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<String> sendMessage(String message) async {
    try {
      final response = await _dio.post('/api/chat', data: {'message': message});
      return response.data['response'] ?? 'Sorry, I could not process that.';
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        throw 'You have reached your free daily message limit. Please upgrade to Pro.';
      }
      throw e.response?.data['error'] ?? 'Failed to send message.';
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(dioProvider));
});
