import '../data/models/conversation.dart';

enum ConversationStatus { initial, loading, success, error }

class ConversationState {
  final ConversationStatus status;
  final Conversation? conversation;
  final String? errorMessage;

  const ConversationState({
    this.status = ConversationStatus.initial,
    this.conversation,
    this.errorMessage,
  });

  ConversationState copyWith({
    ConversationStatus? status,
    Conversation? conversation,
    String? errorMessage,
  }) {
    return ConversationState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
