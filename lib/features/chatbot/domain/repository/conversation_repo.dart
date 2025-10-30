import 'package:injectable/injectable.dart';

import '../../data/services/conversation_service.dart';

@injectable
class ConversationRepo {
  final ConversationService _conversationService;

  ConversationRepo({required ConversationService conversationService})
    : _conversationService = conversationService;

  /// Create new conversation
  Future<String?> createConversation() async {
    return _conversationService.createConversation();
  }

  /// Get list of conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    return _conversationService.getConversations();
  }

  /// Get detail by ID
  Future<Map<String, dynamic>?> getConversationDetail(String id) async {
    return _conversationService.getConversationDetail(id);
  }

  /// Delete conversation
  Future<bool> deleteConversation(String id) async {
    return _conversationService.deleteConversation(id);
  }

  /// Send message to chatbot
  Future<String?> sendMessage({
    required String conversationId,
    required String message,
    bool stream = false,
  }) async {
    return _conversationService.sendMessage(
      conversationId: conversationId,
      message: message,
    );
  }

  Future<void> sendMessageStream({
    required String conversationId,
    required String message,
    required Future Function(String partialText) onChunk,
  }) async {
    await _conversationService.sendMessageStream(
      conversationId: conversationId,
      message: message,
      onChunk: onChunk,
    );
  }
}
