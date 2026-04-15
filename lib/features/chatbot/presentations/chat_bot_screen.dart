import 'package:auto_route/auto_route.dart';
import 'package:dartx/dartx.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '/gen/assets.gen.dart';
import '/core/data/local/storage.dart';
import '/common/extensions/font_sizes.dart';
import '/common/utils/getit_utils.dart';
import '/common/widgets/errors/error_view.dart';
import '/common/extensions/custom_theme_extension.dart';

import '../bloc/conversation_list_cubit.dart';
import '../bloc/conversation_list_state.dart';
import '../bloc/conversation_cubit.dart';
import '../bloc/conversation_state.dart';
import '/features/chatbot/domain/repository/chatbot_repo.dart';
import '/features/chatbot/domain/repository/conversation_repo.dart';
import './widgets/chat_bubble.dart';

@RoutePage()
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
    var widthScreen = MediaQuery.sizeOf(context).width;

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

          // Show loading indicator
          if (state.status == ConversationStatus.loading) {
            return Scaffold(
              appBar: CustomAppbar(
                label: "Chat Bot",
                showNotificationButton: false,
                child: Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                        ),
                        tooltip: 'Open conversations',
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                ),
              ),
              backgroundColor: context.theme.lightBlue,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // Show error state with retry
          if (state.status == ConversationStatus.error) {
            return Scaffold(
              appBar: CustomAppbar(
                label: "Chat Bot",
                showNotificationButton: false,
              ),
              backgroundColor: context.theme.lightBlue,
              body: ErrorView(
                message:
                    state.errorMessage ??
                    "Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.",
                errorType: ErrorType.internalError,
                onRetry: cubit.loadConversation,
              ),
            );
          }

          // Normal conversation UI
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
                  appBar: CustomAppbar(
                    label: conv != null ? conv.title : "Trợ lý dDUT",
                    showNotificationButton: false,
                    child: Builder(
                      builder:
                          (context) => IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                            ),
                            tooltip: 'Open conversations',
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          ),
                    ),
                  ),
                  backgroundColor: context.theme.lightBlue,
                  endDrawer: Drawer(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phòng ban',
                              style: TextStyle(
                                fontSize: FontSizes.large,
                                fontWeight: FontWeight.bold,
                                color: context.theme.primaryColor,
                              ),
                            ),
                            Divider(color: context.theme.primaryColor),
                            BlocBuilder<
                              ConversationListCubit,
                              ConversationListState
                            >(
                              builder: (context, state) {
                                if (state.status ==
                                    ConversationListStatus.loading) {
                                  return CircularProgressIndicator();
                                }

                                final sortedConversations = List.from(
                                  state.conversations,
                                )..sort(
                                  (a, b) => a.title.toLowerCase().compareTo(
                                    b.title.toLowerCase(),
                                  ),
                                );

                                return Expanded(
                                  child: ListView.builder(
                                    itemCount: sortedConversations.length,
                                    itemBuilder: (_, index) {
                                      final conv = sortedConversations[index];
                                      final selected =
                                          conv.id == state.selectedId;

                                      return Column(
                                        children: [
                                          _buildMenuItem(
                                            conv.title,
                                            isSelected: selected,
                                            onPressed: () {
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

                                              Navigator.pop(
                                                context,
                                              ); // đóng drawer
                                            },
                                            context: context,
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Expanded(
                          child:
                              messages.isEmpty
                                  ? BlocBuilder<
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
                                            if (conv == null)
                                              SvgPicture.asset(
                                                Assets.images.chatbotHero,
                                                width: widthScreen * 6 / 10,
                                              ),
                                            if (conv == null)
                                              const SizedBox(height: 20),
                                            Text(
                                              conv != null
                                                  ? "Chào bạn! Trợ lý ảo\n ${conv.title} đã sẵn sàng."
                                                  : "Chào mừng đến với\n"
                                                      "Trợ lý ảo BKĐN!",
                                              style: TextStyle(
                                                fontSize:
                                                    conv != null
                                                        ? FontSizes.extraLarge +
                                                            2
                                                        : FontSizes.extraLarge +
                                                            6,
                                                color: Color(0xff263238),
                                                fontWeight: FontWeight.bold,
                                                height:
                                                    conv != null ? 1.5 : 1.14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              conv != null
                                                  ? "Tôi có thể thông tin gì đến bạn?"
                                                  : "Tôi có thể giúp gì cho bạn hôm nay?",
                                              style: TextStyle(
                                                fontSize: FontSizes.medium,
                                                color: context.theme.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            if (state.selectedId == null)
                                              Column(
                                                children: [
                                                  const SizedBox(height: 20),
                                                  MaterialButton(
                                                    onPressed: () {
                                                      Scaffold.of(
                                                        context,
                                                      ).openEndDrawer();
                                                    },
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 12,
                                                          horizontal: 16,
                                                        ),
                                                    color:
                                                        context
                                                            .theme
                                                            .primaryColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      spacing: 10,
                                                      children: [
                                                        SvgPicture.asset(
                                                          Assets
                                                              .icons
                                                              .svg
                                                              .biChatDotsFill,
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                Colors.white,
                                                                BlendMode.srcIn,
                                                              ),
                                                          width: 24,
                                                          height: 24,
                                                        ),
                                                        Text(
                                                          "Bắt đầu trò chuyện",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                FontSizes
                                                                    .medium,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                  : ListView.builder(
                                    controller: _scrollController,
                                    itemCount:
                                        messages.length +
                                        (_isLoading &&
                                                (messages.isEmpty ||
                                                    messages.last.isUser)
                                            ? 1
                                            : 0),
                                    itemBuilder: (context, index) {
                                      if (_isLoading &&
                                          index == messages.length) {
                                        return const ChatBubble(
                                          isLoading: true,
                                        );
                                      }
                                      return ChatBubble(
                                        message: messages[index],
                                      );
                                    },
                                  ),
                        ),
                        BlocBuilder<
                          ConversationListCubit,
                          ConversationListState
                        >(
                          builder: (context, state) {
                            if (state.selectedId == null) {
                              return SizedBox.shrink();
                            }
                            return _buildInputArea(context);
                          },
                        ),
                      ],
                    ),
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
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _inputFocusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: "Nhập tin nhắn...",
                    hintStyle: TextStyle(color: context.theme.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
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
                child: Icon(Ionicons.ios_send, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title, {
    bool isSelected = false,
    VoidCallback? onPressed,
    required BuildContext context,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? context.theme.primaryColor : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        padding: EdgeInsets.all(16),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: FontSizes.medium,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
