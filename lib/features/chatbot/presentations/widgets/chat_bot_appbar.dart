import 'package:flutter/material.dart';
import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

class ChatBotAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  const ChatBotAppbar({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.theme.primaryColor ?? Colors.blue,
      elevation: 0,
      leading: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: FontSizes.medium,
        ),
      ),
      centerTitle: true,

      // 🧭 Drawer Button (on the right)
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            tooltip: 'Open conversations',
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
