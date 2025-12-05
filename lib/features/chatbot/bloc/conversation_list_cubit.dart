import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/conversation.dart';
import '../domain/repository/chatbot_repo.dart';
import '../domain/repository/conversation_repo.dart';
import 'conversation_list_state.dart';

class ConversationListCubit extends Cubit<ConversationListState> {
  final ConversationRepo repo;
  final ChatbotRepo chatBotRepo;

  ConversationListCubit({required this.repo, required this.chatBotRepo})
    : super(const ConversationListState());

  Future<void> loadList() async {
    emit(state.copyWith(status: ConversationListStatus.loading));

    try {
      final chatBotList = await chatBotRepo.getChatBots();

      final conversations =
          chatBotList
              .map(
                (c) => Conversation(
                  chatbotId: c.id,
                  title: c.name,
                  id: c.id,
                  jwt: c.jwt,
                  messages: [],
                ),
              )
              .toList();
      emit(
        state.copyWith(
          status: ConversationListStatus.success,
          conversations: conversations,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConversationListStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  void selectConversation({required String chatbotId}) {
    emit(state.copyWith(selectedId: chatbotId));
  }

  Future<void> createNew() async {
    final id = await repo.createConversation();
    await loadList();
    emit(state.copyWith(selectedId: id));
  }
}
