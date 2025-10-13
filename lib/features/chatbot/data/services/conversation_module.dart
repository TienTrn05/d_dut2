import 'package:e_dut/common/utils/app_environment.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ConversationModule {
  @Named('chatbotConversationHost')
  String get chatbotConversationHost => "http://171.244.46.201:8080";
  @Named('chatbotConversationJwt')
  String get chatbotConversationJwt => AppEnvironment.chatbotConversationJwt;
  @Named('chatbotConversationAPIKey')
  String get chatbotConversationAPIKey => AppEnvironment.chatbotConversationAPIKey;
  @Named('chatbotConversationChatbotId')
  String get chatbotConversationChatbotId => "cmgkj1m26000c14lcvzlds075";
}