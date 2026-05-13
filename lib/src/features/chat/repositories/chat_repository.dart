import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class ChatApiResponse {
  final int sessionId;
  final int messageId;
  final String reply;
  final int? tokensUsed;
  final List<String> actionsTaken;

  const ChatApiResponse({
    required this.sessionId,
    required this.messageId,
    required this.reply,
    this.tokensUsed,
    this.actionsTaken = const [],
  });

  factory ChatApiResponse.fromJson(Map<String, dynamic> json) {
    return ChatApiResponse(
      sessionId: json['session_id'] as int,
      messageId: json['message_id'] as int,
      reply: json['reply'] as String,
      tokensUsed: json['tokens_used'] as int?,
      actionsTaken: (json['actions_taken'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  /// Send a message, optionally continuing an existing session.
  /// AI inference on CPU can take up to 2 minutes — receive timeout is 120s.
  Future<ChatApiResponse> sendMessage(
    String message, {
    int? sessionId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'message': message,
          if (sessionId != null) 'session_id': sessionId,
        },
        options: Options(receiveTimeout: const Duration(seconds: 120)),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChatApiResponse.fromJson(data);
      }
      return ChatApiResponse(
        sessionId: sessionId ?? 0,
        messageId: 0,
        reply: data is String ? data : 'Sorry, I could not process that.',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        throw 'You have reached your free daily message limit. Please upgrade to Pro.';
      }
      final errData = e.response?.data;
      final msg = errData is Map ? errData['error'] : null;
      throw msg ?? 'Failed to send message. Please try again.';
    } catch (_) {
      throw 'Failed to send message. Please try again.';
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(dioProvider));
});
