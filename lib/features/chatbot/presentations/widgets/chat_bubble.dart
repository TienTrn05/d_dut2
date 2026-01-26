import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '/common/extensions/custom_theme_extension.dart';

import '../../data/models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message? message;
  final bool isLoading;

  const ChatBubble({super.key, this.message, this.isLoading = false})
    : assert(
        message != null || isLoading,
        'Either message or isLoading must be provided',
      );

  @override
  Widget build(BuildContext context) {
    final isUser = message?.isUser ?? false;

    if (isLoading) {
      return _buildBotLoadingBubble(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser) const SizedBox(width: 16),
          if (!isUser) _buildAvatar(context, isLoading: false),
          if (!isUser) const SizedBox(width: 12),

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
              ),
              child: Text(
                message!.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: FontSizes.medium,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotLoadingBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(context, isLoading: true),
          const SizedBox(width: 12),

          /// Loading bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: context.theme.lightGrey,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Text(
                'Bot đang nhập...',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: FontSizes.medium,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, {required bool isLoading}) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child:
              isLoading
                  ? CupertinoActivityIndicator(
                    radius: 8,
                    color: context.theme.primaryColor,
                  )
                  : SvgPicture.asset(
                    Assets.icons.svg.chatbotIcon,
                    width: 20,
                    height: 20,
                  ),
        ),
      ],
    );
  }
}
