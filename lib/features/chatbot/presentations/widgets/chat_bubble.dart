import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '/common/extensions/custom_theme_extension.dart';

import '../../data/models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser) const SizedBox(width: 16),
          if (!isUser)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: SvgPicture.asset(
                Assets.icons.svg.chatbotIcon,
                width: 20,
                height: 20,
              ),
            ),
          if (!isUser) const SizedBox(width: 8),

          /// Chat bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? context.theme.primaryColor
                        : context.theme.lightGrey,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                  topLeft:
                      isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(0),
                  topRight:
                      isUser
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 18,
              backgroundColor: context.theme.primaryColor,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          if (!isUser) const SizedBox(width: 16),
        ],
      ),
    );
  }
}
