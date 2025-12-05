import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../models/chatbot.dart';
import '/common/utils/logger.dart';

@injectable
class ChatbotService {
  final String _chatBotDataPath;

  ChatbotService(
    @Named('chatBotDataPath') String chatBotDataPath,
  ) : _chatBotDataPath = chatBotDataPath;

  Future<List<Chatbot>> getChatBots() async {
    try {
      // Load file JSON dưới dạng string
      final jsonString = await rootBundle.loadString(_chatBotDataPath);

      // Decode JSON
      final data = json.decode(jsonString);

      // Parse vào List<Chatbot>
      final bots = (data['chatbots'] as List)
          .map((e) => Chatbot(
                id: e['id'],
                name: e['name'],
                jwt: e['jwt']
              ))
          .toList();

      return bots;
    } catch (e) {
      logger.e("Error loading chatbots");
      rethrow;
    }
  }
}