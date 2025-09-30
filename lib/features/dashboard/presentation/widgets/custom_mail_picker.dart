import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_launcher/open_mail_launcher.dart';

class CustomMailAppPicker {
  static Future<MailApp?> showCustomMailAppPicker({
    required BuildContext context,
    required List<MailApp> mailApps,
    String? title,
    String? cancelText,
  }) async {
    if (mailApps.isEmpty) return null;
    if (mailApps.length == 1) return mailApps.first;

    return showDialog<MailApp>(
      context: context,
      builder: (BuildContext context) {
        return CustomMailAppPickerDialog(
          mailApps: mailApps,
          title: title,
          cancelText: cancelText,
        );
      },
    );
  }
}

class CustomMailAppPickerDialog extends StatelessWidget {
  final List<MailApp> mailApps;
  final String? title;
  final String? cancelText;

  const CustomMailAppPickerDialog({
    super.key,
    required this.mailApps,
    this.title,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // 👈 custom màu nền
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 👈 bo góc
      ),
      title: Text(
        title ?? 'Chọn ứng dụng Email',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: context.theme.primaryColor, // 👈 màu title
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              mailApps.map((mailApp) {
                return ListTile(
                  leading:
                      mailApp.icon != null
                          ? Image.memory(
                            Uri.parse(mailApp.icon!).data!.contentAsBytes(),
                            width: 32,
                            height: 32,
                            errorBuilder:
                                (_, __, ___) => const Icon(Icons.email),
                          )
                          : const Icon(Icons.email),
                  title: Text(mailApp.name),
                  subtitle: mailApp.isDefault ? const Text('Mặc định') : null,
                  onTap: () => Navigator.of(context).pop(mailApp),
                );
              }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            cancelText ?? 'Đóng',
            style: TextStyle(color: context.theme.primaryColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
