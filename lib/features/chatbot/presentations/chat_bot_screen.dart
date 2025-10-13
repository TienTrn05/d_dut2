import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/features/chatbot/domain/repository/conversation_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/custom_theme_extension.dart';
import '../bloc/conversation_cubit.dart';
import '../bloc/conversation_state.dart';
import './widgets/chat_bubble.dart';
import './widgets/chat_bot_appbar.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context, String text) {
    if (text.trim().isEmpty) return;

    final cubit = context.read<ConversationCubit>();
    setState(() => _isLoading = true);

    cubit.sendMessage(text).then((_) {
      setState(() => _isLoading = false);
      _scrollToBottom();
    });
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ConversationCubit(conversationRepo: getIt<ConversationRepo>())
                ..loadConversation(),
      child: BlocBuilder<ConversationCubit, ConversationState>(
        builder: (context, state) {
          final cubit = context.read<ConversationCubit>();
          final messages = state.conversation?.messages ?? [];

          // 🟡 1️⃣ Show loading indicator
          if (state.status == ConversationStatus.loading) {
            return Scaffold(
              appBar: ChatBotAppbar(label: "Chat Bot"),
              backgroundColor: context.theme.lightBlue,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // 🔴 2️⃣ Show error state with retry
          if (state.status == ConversationStatus.error) {
            return Scaffold(
              appBar: ChatBotAppbar(label: "Chat Bot"),
              backgroundColor: context.theme.lightBlue,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Không thể tải cuộc hội thoại 😢",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent.shade200,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage ?? "Đã xảy ra lỗi không xác định.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.theme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => cubit.loadConversation(),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          "Thử lại",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // ✅ 3️⃣ Normal conversation UI
          return Scaffold(
            appBar: ChatBotAppbar(
              label: state.conversation?.title ?? "Trợ lý ảo BKĐN",
            ),
            backgroundColor: context.theme.lightBlue,
            body: Column(
              children: [
                Expanded(
                  child:
                      messages.isEmpty
                          ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                "Tôi là AI hỗ trợ phòng đào tạo BKĐN.\n"
                                "Tôi có thể giúp gì cho bạn hôm nay?",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                          : ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            padding: const EdgeInsets.all(6),
                            itemBuilder:
                                (context, index) =>
                                    ChatBubble(message: messages[index]),
                          ),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text("Bot đang nhập..."),
                      ],
                    ),
                  ),
                Divider(height: 1, color: context.theme.grey),
                _buildInputArea(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildDrawer(BuildContext context, ConversationState state) {
  //   final cubit = context.read<ConversationCubit>();

  //   return Drawer(
  //     backgroundColor: Colors.white,
  //     child: SafeArea(
  //       child: Column(
  //         children: [
  //           DrawerHeader(
  //             margin: EdgeInsets.zero,
  //             padding: const EdgeInsets.all(16),
  //             child: Row(
  //               children: [
  //                 const CircleAvatar(
  //                   radius: 28,
  //                   backgroundColor: Colors.blueAccent,
  //                   child: Icon(Icons.smart_toy, color: Colors.white, size: 28),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: Text(
  //                     "Conversations",
  //                     style: TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                       color: context.theme.primaryColor,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const Divider(),
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: state.conversations.length,
  //               itemBuilder: (context, index) {
  //                 final convo = state.conversations[index];
  //                 final selected = convo.id == state.selectedConversation?.id;

  //                 return ListTile(
  //                   leading: Icon(
  //                     Icons.chat_bubble_outline,
  //                     color:
  //                         selected
  //                             ? context.theme.primaryColor
  //                             : Colors.grey.shade600,
  //                   ),
  //                   title: Text(
  //                     convo.title,
  //                     style: TextStyle(
  //                       fontWeight:
  //                           selected ? FontWeight.bold : FontWeight.normal,
  //                       color:
  //                           selected
  //                               ? context.theme.primaryColor
  //                               : Colors.black87,
  //                     ),
  //                   ),
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     cubit.selectConversation(convo);
  //                   },
  //                 );
  //               },
  //             ),
  //           ),
  //           const Divider(height: 1),
  //           Padding(
  //             padding: const EdgeInsets.all(12),
  //             child: ElevatedButton.icon(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: context.theme.primaryColor,
  //                 minimumSize: const Size.fromHeight(48),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //               ),
  //               icon: const Icon(Icons.add, color: Colors.white),
  //               label: const Text(
  //                 "New Conversation",
  //                 style: TextStyle(color: Colors.white, fontSize: 16),
  //               ),
  //               onPressed: () {
  //                 cubit.createConversation();
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildInputArea(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: context.theme.lightBlue,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(context, _textController.text),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.primaryColor!.withAlpha(64),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
