import 'package:equatable/equatable.dart';
import 'message.dart';

class Conversation extends Equatable {
  final String id;
  final String title;
  final List<Message> messages;

  const Conversation({
    required this.id,
    required this.title,
    this.messages = const [],
  });

  Conversation copyWith({
    String? id,
    String? title,
    List<Message>? messages,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      title: map['title'] as String,
      messages: (map['messages'] as List)
          .map((m) => Message.fromMap(m))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, title, messages];
}
