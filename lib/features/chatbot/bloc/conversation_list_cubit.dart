import 'package:e_dut/features/chatbot/data/models/conversation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repository/conversation_repo.dart';
import 'conversation_list_state.dart';

class ConversationListCubit extends Cubit<ConversationListState> {
  final ConversationRepo repo;

  ConversationListCubit({required this.repo})
    : super(const ConversationListState());

  Future<void> loadList() async {
    emit(state.copyWith(status: ConversationListStatus.loading));

    try {
      final listRaw = await repo.getConversations() as List<dynamic>? ?? [];
      final list =
          listRaw
              .map((m) => Conversation(id: m["id"], title: m["name"]))
              .toList();
      emit(
        state.copyWith(
          status: ConversationListStatus.success,
          conversations: list,
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

  void selectConversation(String id) {
    emit(state.copyWith(selectedId: id));
  }

  Future<void> createNew() async {
    final id = await repo.createConversation();
    await loadList();
    emit(state.copyWith(selectedId: id));
  }
}
