import 'package:injectable/injectable.dart';

@module
abstract class ConversationModule {
  @Named('chatbotConversationHost')
  String get chatbotConversationHost => "http://171.244.46.201:8080";
  @Named('chatbotConversationJwt')
  String get chatbotConversationJwt => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNtZzdxY2J2MzAwMTd4bmk2N29mMnN2b24iLCJlbWFpbCI6ImRvbnRsb29rbWVwbHNAZ21haWwuY29tIiwiaWF0IjoxNzYwMDgxMDk5LCJleHAiOjE3NjI2NzMwOTl9.2pben-I_kDaUYkchynYQDQgUrV0-x8HwxCwGQ0r8kTw";
  @Named('chatbotConversationAPIKey')
  String get chatbotConversationAPIKey => "3lTZgSpjgCSYH2nL17dqbt0q3lolCnO35H2uxf7gkhDyRvV7iO7LTSvsxdo1ErwI";
  @Named('chatbotConversationChatbotId')
  String get chatbotConversationChatbotId => "cmgkj1m26000c14lcvzlds075";
}