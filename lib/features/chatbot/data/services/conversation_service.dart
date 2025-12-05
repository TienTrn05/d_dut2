import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '/common/utils/logger.dart';

@injectable
class ConversationService {
  final Dio _dio;
  final String _apiKey;
  final String _chatbotId;

  ConversationService(
    @Named('chatbotConversationHost') String host,
    @Named('chatbotConversationJwt') String jwt,
    @Named('chatbotConversationAPIKey') String apiKey,
    @Named('chatbotConversationChatbotId') String chatbotId,
  ) : _apiKey = apiKey,
      _chatbotId = chatbotId,
      _dio = Dio(
        BaseOptions(
          baseUrl: host,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    // ✅ Automatically add JWT to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // if (options.path.contains('/api/conversations')) {
          //   options.headers['Authorization'] = 'Bearer $jwt';
          // }
          return handler.next(options);
        },
        onError: (e, handler) {
          logger.e('❌ Dio Error [${e.response?.statusCode}]: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // 🧱 1. Create new conversation
  Future<String?> createConversation() async {
    try {
      final res = await _dio.post(
        '/api/conversations',
        data: {'chatbot_id': _chatbotId},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;
        return data['id'] ?? data['data']['id'];
      }
    } on DioException catch (e) {
      logger.e('❌ Failed to create conversation: ${e.response?.data}');
    }
    return null;
  }

  Future<String?> createConversationByChatbotId(
    String chatbotId,
    String jwt,
  ) async {
    try {
      final res = await _dio.post(
        '/api/conversations',
        data: {'chatbot_id': chatbotId},
        options: Options(headers: {"Authorization": "Bearer $jwt"}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;
        return data['id'] ?? data['data']['id'];
      }
    } on DioException catch (e) {
      logger.e('❌ Failed to create conversation: ${e.response?.data}');
    }
    return null;
  }

  // 📋 2. Get list of conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final res = await _dio.get('/api/conversations');
      if (res.statusCode == 200) {
        final data = res.data;

        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          logger.w('Unexpected data format: $data');
        }
      }
    } on DioException catch (e) {
      logger.e('❌ Failed to fetch conversations: ${e.response?.data}');
    }
    return [];
  }

  // 🔍 3. Get detail by ID
  Future<Map<String, dynamic>?> getConversationDetail(
    String id,
    String jwt,
  ) async {
    try {
      final res = await _dio.get(
        '/api/conversations/$id',
        options: Options(headers: {"Authorization": "Bearer $jwt"}),
      );
      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(res.data["data"] ?? res.data);
      }
    } on DioException catch (e) {
      logger.e('❌ Failed to fetch conversation detail: ${e.response?.data}');
    }
    logger.w('Failed to fetch conversation detail: $id');
    return null;
  }

  // 🗑️ 4. Delete conversation
  Future<bool> deleteConversation(String id) async {
    try {
      final res = await _dio.delete('/api/conversations/$id');
      return res.statusCode == 200 || res.statusCode == 204;
    } on DioException catch (e) {
      logger.e('❌ Failed to delete conversation: ${e.response?.data}');
    }
    return false;
  }

  // 💬 5. Send message to chatbot
  Future<String?> sendMessage({
    required String conversationId,
    required String message,
    bool stream = false,
  }) async {
    try {
      final res = await _dio.post(
        '/ai/chat',
        options: Options(headers: {'x-api-key': _apiKey}),
        data: {
          'message': message,
          'chatbot_id': _chatbotId,
          'conversation_id': conversationId,
          'stream': stream,
        },
      );

      if (res.statusCode == 200) {
        final data = res.data;
        return data;
      }
    } on DioException catch (e) {
      logger.e('❌ Failed to send message: ${e.response?.data}');
    }
    return null;
  }

  Future<void> sendMessageStream({
    required String conversationId,
    required String message,
    required Future Function(String partialText) onChunk,
  }) async {
    try {
      final response = await _dio.post<ResponseBody>(
        '/ai/chat',
        options: Options(
          headers: {'x-api-key': _apiKey},
          responseType: ResponseType.stream,
        ),
        data: {
          'message': message,
          'chatbot_id': _chatbotId,
          'conversation_id': conversationId,
          'stream': true,
        },
      );

      await for (var chunk in response.data!.stream.cast<List<int>>().transform(
        utf8.decoder,
      )) {
        await onChunk(chunk);
      }
    } on DioException catch (e) {
      logger.e('❌ Stream error: ${e.response?.data}');
    }
  }
}
