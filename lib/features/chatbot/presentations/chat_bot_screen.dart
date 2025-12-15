import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/local/storage.dart';
import '/common/extensions/font_sizes.dart';
import '../bloc/conversation_list_cubit.dart';
import '../bloc/conversation_list_state.dart';
import '/common/utils/getit_utils.dart';
import '/common/widgets/errors/error_view.dart';
import '/common/extensions/custom_theme_extension.dart';

import '../bloc/conversation_cubit.dart';
import '../bloc/conversation_state.dart';
import './widgets/chat_bubble.dart';
import './widgets/chat_bot_appbar.dart';
import '/features/chatbot/domain/repository/chatbot_repo.dart';
import '/features/chatbot/domain/repository/conversation_repo.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _scrollToBottom();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
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
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => ConversationListCubit(
                repo: getIt<ConversationRepo>(),
                chatBotRepo: getIt<ChatbotRepo>(),
              )..loadList(),
        ),
        BlocProvider(
          create:
              (context) => ConversationCubit(
                conversationRepo: getIt<ConversationRepo>(),
              ),
        ),
      ],
      child: BlocConsumer<ConversationCubit, ConversationState>(
        listener: (context, state) {
          if (state.status == ConversationStatus.success) {
            // Khi load xong, cuộn xuống cuối
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
            );
          }

          // Nếu có tin nhắn mới thì cũng cuộn xuống cuối
          if (state.conversation?.messages.isNotEmpty == true) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
            );
          }
        },
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
              drawer: Drawer(
                backgroundColor: context.theme.lightBlue,
                child: BlocBuilder<
                  ConversationListCubit,
                  ConversationListState
                >(
                  builder: (context, state) {
                    if (state.status == ConversationListStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Phòng ban",
                              style: TextStyle(
                                color: context.theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: FontSizes.large,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.conversations.length,
                              itemBuilder: (_, index) {
                                final conv = state.conversations[index];
                                final selected = conv.id == state.selectedId;

                                return ListTile(
                                  title: Text(conv.title),
                                  selected: selected,
                                  onTap: () {
                                    context
                                        .read<ConversationListCubit>()
                                        .selectConversation(
                                          chatbotId: conv.chatbotId,
                                        );

                                    final convId =
                                        Storage.getConversationIdByChatbot(
                                          conv.chatbotId,
                                        );

                                    context
                                        .read<ConversationCubit>()
                                        .loadConversationByChatbotId(
                                          conv.chatbotId,
                                          convId,
                                          conv.jwt,
                                        );

                                    Navigator.pop(context); // đóng drawer
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              body: ErrorView(
                message:
                    state.errorMessage ??
                    "Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.",
                onRetry: cubit.loadConversation,
              ),
            );
          }

          // ✅ 3️⃣ Normal conversation UI
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.translucent,
            child: BlocBuilder<ConversationListCubit, ConversationListState>(
              builder: (context, conversationListState) {
                final conv = conversationListState.conversations
                    .firstOrNullWhere(
                      (c) => c.chatbotId == conversationListState.selectedId,
                    );

                return Scaffold(
                  appBar: ChatBotAppbar(
                    label: conv != null ? conv.title : "Trợ lý ảo BKĐN",
                  ),
                  backgroundColor: context.theme.lightBlue,
                  drawer: Drawer(
                    backgroundColor: context.theme.lightBlue,
                    child: BlocBuilder<
                      ConversationListCubit,
                      ConversationListState
                    >(
                      builder: (context, state) {
                        if (state.status == ConversationListStatus.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return SafeArea(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  "Phòng ban",
                                  style: TextStyle(
                                    color: context.theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: FontSizes.large,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: state.conversations.length,
                                  itemBuilder: (_, index) {
                                    final conv = state.conversations[index];
                                    final selected =
                                        conv.id == state.selectedId;

                                    return ListTile(
                                      title: Text(conv.title),
                                      selected: selected,
                                      onTap: () {
                                        context
                                            .read<ConversationListCubit>()
                                            .selectConversation(
                                              chatbotId: conv.chatbotId,
                                            );

                                        final convId =
                                            Storage.getConversationIdByChatbot(
                                              conv.chatbotId,
                                            );

                                        context
                                            .read<ConversationCubit>()
                                            .loadConversationByChatbotId(
                                              conv.chatbotId,
                                              convId,
                                              conv.jwt,
                                            );

                                        Navigator.pop(context); // đóng drawer
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child:
                            messages.isEmpty
                                ? Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: BlocBuilder<
                                    ConversationListCubit,
                                    ConversationListState
                                  >(
                                    builder: (context, state) {
                                      final conv = state.conversations
                                          .firstOrNullWhere(
                                            (c) =>
                                                c.chatbotId == state.selectedId,
                                          );

                                      return SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              conv != null
                                                  ? "Xin chào bạn, tôi là ${conv.title}.\nTôi có thể giúp gì cho bạn?"
                                                  : "Tôi là AI hỗ trợ phòng đào tạo BKĐN.\n"
                                                      "Tôi có thể giúp gì cho bạn hôm nay?",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black.withOpacity(
                                                  0.7,
                                                ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            if (state.selectedId == null)
                                              Column(
                                                children: [
                                                  const SizedBox(height: 12),
                                                  MaterialButton(
                                                    onPressed: () {
                                                      Scaffold.of(
                                                        context,
                                                      ).openDrawer();
                                                    },
                                                    color:
                                                        context
                                                            .theme
                                                            .primaryColor,
                                                    elevation: 0,
                                                    focusElevation: 0,
                                                    hoverElevation: 0,
                                                    highlightElevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      "Chat ngay!",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            FontSizes.large,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      );
                                    },
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
                      BlocBuilder<ConversationListCubit, ConversationListState>(
                        builder: (context, state) {
                          if (state.selectedId == null) {
                            return SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              Divider(
                                height: 1,
                                color: context.theme.lightGrey,
                              ),
                              _buildInputArea(context),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

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
                  focusNode: _inputFocusNode,
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
