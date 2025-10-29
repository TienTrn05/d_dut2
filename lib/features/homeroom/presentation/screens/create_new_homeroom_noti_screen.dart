import 'package:flutter/material.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';
import '/common/widgets/dialog/custom_alert_dialog.dart' as dialog;

import '../../../schedule/presentation/widgets/item/edit_field_item.dart';
import '../../data/model/noti_model.dart';

class CreateNewHomeroomNotiScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String authToken;

  final Future<void> Function(NotiModel newNoti)? onAddNoti;

  const CreateNewHomeroomNotiScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.authToken,
    this.onAddNoti,
  });

  @override
  State<CreateNewHomeroomNotiScreen> createState() =>
      _CreateNewHomeroomNotiScreenState();
}

class _CreateNewHomeroomNotiScreenState
    extends State<CreateNewHomeroomNotiScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _addNotification() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      String truncatedTitle =
          title.length > 50 ? '${title.substring(0, 47)}...' : title;
      final newItem = NotiModel(
        id: "0",
        date: DateTime.now(),
        title: title,
        content: content,
      );

      dialog.CustomAlertDialog.showCustomDialog(
        context,
        'Lưu thông báo',
        'Bạn có chắc chắn muốn lưu thông báo: $truncatedTitle?',
        dialog.AlertDialogType.confirm,
        onConfirm: () async {
          if (widget.onAddNoti != null) {
            await widget.onAddNoti!(newItem);
          }
          if (mounted) Navigator.pop(context);
        },
        textConfirm: "Lưu",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.primaryColor ?? Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thêm thông báo mới",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.medium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _addNotification,
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
        leading: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                EditFieldItem(
                  field: "Tiêu đề",
                  controller: _titleController,
                  minLine: 1,
                  maxLine: 2,
                ),
                const SizedBox(height: 10),
                EditFieldItem(
                  field: "Nội dung",
                  controller: _contentController,
                  minLine: 7,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
