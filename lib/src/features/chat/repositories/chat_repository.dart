import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class ChatResponse {
  final int sessionId;
  final int messageId;
  final String reply;
  final int? tokensUsed;

  ChatResponse({
    required this.sessionId,
    required this.messageId,
    required this.reply,
    this.tokensUsed,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      sessionId: json['session_id'] as int,
      messageId: json['message_id'] as int,
      reply: json['reply'] as String,
      tokensUsed: json['tokens_used'] as int?,
    );
  }
}

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<String> sendMessage(String message) async {
    try {
      // AI inference can take up to 2 minutes on CPU servers — override the global 10s timeout
      final response = await _dio.post(
        '/api/chat',
        data: {'message': message},
        options: Options(receiveTimeout: const Duration(seconds: 120)),
      );
      
      // Handle different response types
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final chatResp = ChatResponse.fromJson(data);
        return chatResp.reply;
      } else if (data is String) {
        return data;
      }
      
      return 'Sorry, I could not process that.';
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        throw 'You have reached your free daily message limit. Please upgrade to Pro.';
      }
      // Log error for debugging
      print('Chat API error: ${e.response?.statusCode} - ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Failed to send message. Please try again.';
    } catch (e) {
      print('Chat error: $e');
      throw 'Failed to send message. Please try again.';
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(dioProvider));
});
