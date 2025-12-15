import 'package:injectable/injectable.dart';

@module
abstract class ChatbotModule {
  @Named('chatBotDataPath')
  String get chatBotDataPath => "assets/data/chatbots.json";
}