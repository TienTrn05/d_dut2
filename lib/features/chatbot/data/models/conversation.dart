import 'package:equatable/equatable.dart';
import 'message.dart';

class Conversation extends Equatable {
  final String id;
  final String chatbotId; 
  final String title;
  final String jwt;
  final List<Message> messages;

  const Conversation({
    required this.id,
    required this.chatbotId,
    required this.title,
    this.jwt = "",
    this.messages = const [],
  });

  Conversation copyWith({
    String? id,
    String? chatbotId,
    String? title,
    String? jwt,
    List<Message>? messages,
  }) {
    return Conversation(
      id: id ?? this.id,
      chatbotId: chatbotId ?? this.chatbotId,
      title: title ?? this.title,
      jwt: jwt ?? this.jwt,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatbotId': chatbotId,
      'title': title,
      'jwt': jwt,
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      chatbotId: map['chatbotId'] as String,
      title: map['title'] as String,
      jwt: "",
      messages: (map['messages'] as List)
          .map((m) => Message.fromMap(m))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, title, chatbotId, jwt, messages];
}
