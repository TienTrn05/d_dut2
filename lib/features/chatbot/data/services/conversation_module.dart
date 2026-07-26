import 'package:e_dut/common/utils/app_environment.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ConversationModule {
  @Named('chatbotConversationHost')
  String get chatbotConversationHost => "https://api.mcanswers.ai";
  @Named('chatbotConversationJwt')
  String get chatbotConversationJwt => AppEnvironment.chatbotConversationJwt;
  @Named('chatbotConversationAPIKey')
  String get chatbotConversationAPIKey => AppEnvironment.chatbotConversationAPIKey;
  @Named('chatbotConversationChatbotId')
  String get chatbotConversationChatbotId => "cmhcdmls100iukdfp9qgzasid";
}