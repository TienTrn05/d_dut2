import 'package:injectable/injectable.dart';

import '../../data/models/chatbot.dart';
import '../../data/services/chatbot_service.dart';

@injectable
class ChatbotRepo {
  final ChatbotService _chatbotService;

  ChatbotRepo({required ChatbotService chatbotService})
    : _chatbotService = chatbotService;

  /// Get chatbots
  Future<List<Chatbot>> getChatBots() async {
    return _chatbotService.getChatBots();
  }
}