import '../data/models/conversation.dart';

enum ConversationListStatus { initial, loading, success, error }

class ConversationListState {
  final ConversationListStatus status;
  final List<Conversation> conversations;
  final String? selectedId;
  final String? error;

  const ConversationListState({
    this.status = ConversationListStatus.initial,
    this.conversations = const [],
    this.selectedId,
    this.error,
  });

  ConversationListState copyWith({
    ConversationListStatus? status,
    List<Conversation>? conversations,
    String? selectedId,
    String? error,
  }) {
    return ConversationListState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      selectedId: selectedId ?? this.selectedId,
      error: error ?? this.error,
    );
  }
}
