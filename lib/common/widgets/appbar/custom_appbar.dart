import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/notification_button.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final bool showNotificationButton;
  final Widget? child;
  const CustomAppbar({
    super.key,
    required this.label,
    this.showNotificationButton = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.theme.primaryColor ?? Colors.blue,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
      actions: [
        if (showNotificationButton)
          NotificationButton(
            notificationCount: 0,
            onTap: () => {Navigator.of(context).pushNamed(Routes.notification)},
          ),
        if (child != null)
          Padding(padding: const EdgeInsets.only(right: 16), child: child!),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
