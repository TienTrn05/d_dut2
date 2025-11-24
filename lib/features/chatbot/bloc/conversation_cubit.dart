import 'package:e_dut/core/data/local/storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/utils/logger.dart';

import '../data/models/conversation.dart';
import '../data/models/message.dart';
import '../domain/repository/conversation_repo.dart';
import 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final ConversationRepo conversationRepo;

  ConversationCubit({required this.conversationRepo})
    : super(const ConversationState());

  /// Load user's single chatbot conversation
  Future<void> loadConversation() async {
    emit(state.copyWith(status: ConversationStatus.loading));

    try {
      // 🧠 1️⃣ Try to get existing conversation ID from local storage
      String? conversationId = Storage.chatBotConversationId;

      Map<String, dynamic>? messagesData;

      // 🔹 2️⃣ If exists → get its detail
      if (conversationId.isNotEmpty) {
        messagesData = await conversationRepo.getConversationDetail(
          conversationId,
        );
      }

      // 🔹 3️⃣ If not found or invalid → create a new one
      if (messagesData == null) {
        conversationId = await conversationRepo.createConversation();

        if (conversationId == null) {
          emit(
            state.copyWith(
              status: ConversationStatus.error,
              errorMessage:
                  "Không thể tạo cuộc hội thoại mới. Vui lòng thử lại sau.",
            ),
          );
          return;
        }

        // Save to local storage for future sessions
        await Storage.setChatBotConversationId(conversationId);
      }

      // 🔹 4️⃣ Parse messages
      final messagesList = messagesData?['messages'] as List<dynamic>? ?? [];
      final messages =
          messagesList
              .map(
                (m) => Message(
                  text: m['content'] ?? '',
                  isUser: (m['role'] as String?)?.toLowerCase() == 'user',
                ),
              )
              .toList();

      // 🔹 5️⃣ Emit conversation state
      emit(
        state.copyWith(
          status: ConversationStatus.success,
          conversation: Conversation(
            id: conversationId,
            title: "Trợ lý dDUT",
            messages: messages,
          ),
        ),
      );
    } catch (e, stack) {
      logger.e("❌ Error loading conversation: $e\n$stack");
      String message;

      if (e.toString().contains("SocketException")) {
        message = "Không thể kết nối mạng. Vui lòng kiểm tra kết nối Internet.";
      } else if (e.toString().contains("TimeoutException")) {
        message = "Kết nối đến máy chủ bị gián đoạn. Hãy thử lại sau.";
      } else if (e.toString().contains("401")) {
        message = "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.";
      } else {
        message = "Đã xảy ra lỗi không xác định. Vui lòng thử lại.";
      }

      emit(
        state.copyWith(status: ConversationStatus.error, errorMessage: message),
      );
    }
  }

  Future<void> loadConversationById(String conversationId) async {
    emit(state.copyWith(status: ConversationStatus.loading));

    try {
      final messagesData =
          await conversationRepo.getConversationDetail(conversationId);

      final messagesList =
          messagesData?['messages'] as List<dynamic>? ?? [];

      final messages = messagesList
          .map((m) => Message(
                text: m['content'] ?? '',
                isUser: m['role'] == 'user',
              ))
          .toList();

      emit(state.copyWith(
        status: ConversationStatus.success,
        conversation: Conversation(
          id: conversationId,
          title: messagesData?['title'] ?? "Untitled",
          messages: messages,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ConversationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Send a message to the bot
  Future<void> sendMessage(String text) async {
    final conv = state.conversation;
    if (text.trim().isEmpty || conv == null) return;

    // ✉️ Add user message immediately
    final userMsg = Message(text: text, isUser: true);
    var updatedConv = conv.copyWith(messages: [...conv.messages, userMsg]);
    emit(state.copyWith(conversation: updatedConv));

    try {
      var botMsg = Message(text: '', isUser: false);

      await conversationRepo.sendMessageStream(
        conversationId: conv.id,
        message: text,
        onChunk: (partialText) async {
          botMsg = botMsg.copyWith(additionalText: partialText);

          await Future.delayed(const Duration(milliseconds: 100));

          // ✅ Check trước khi emit
          if (!isClosed) {
            emit(
              state.copyWith(
                conversation: updatedConv.copyWith(
                  messages: [...updatedConv.messages, botMsg],
                ),
              ),
            );
          }
        },
      );
    } catch (e, stack) {
      logger.e("❌ Error in sendMessage: $e\n$stack");

      if (!isClosed) {
        emit(
          state.copyWith(
            status: ConversationStatus.error,
            errorMessage: "Đã xảy ra lỗi không xác định. Vui lòng thử lại.",
          ),
        );
      }
    }
  }

  /// Start a completely new conversation (optional reset)
  Future<void> newConversation() async {
    try {
      final id = await conversationRepo.createConversation();
      if (id == null) throw Exception("Failed to create new conversation");

      await Storage.setChatBotConversationId(id);

      emit(
        state.copyWith(
          conversation: Conversation(id: id, title: "New Chat", messages: []),
          status: ConversationStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConversationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
