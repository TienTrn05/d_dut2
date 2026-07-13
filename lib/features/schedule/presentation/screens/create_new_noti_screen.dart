import 'package:flutter/material.dart';

import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';
import '/common/widgets/appbar/custom_appbar.dart';
import '/common/widgets/dialog/custom_alert_dialog.dart' as dialog;

import '../../data/model/noti_model.dart';
import '../widgets/item/edit_field_item.dart';

class CreateNewNotiScreen extends StatefulWidget {
  final String idUos;
  final String subjectName;
  final String authToken;

  final Future<void> Function(NotiModel newNoti)? onAddNoti;

  const CreateNewNotiScreen({
    super.key,
    required this.idUos,
    required this.subjectName,
    required this.authToken,
    this.onAddNoti,
  });

  @override
  State<CreateNewNotiScreen> createState() => _CreateNewNotiScreenState();
}

class _CreateNewNotiScreenState extends State<CreateNewNotiScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
  }

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
            await widget.onAddNoti!(newItem); // gọi callback ra ngoài
          }
          if (mounted) Navigator.pop(context); // đóng màn hình
        },
        textConfirm: "Lưu",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        label: "Thêm thông báo mới",
        showNotificationButton: false,
        child: MaterialButton(
          onPressed: _addNotification,
          color: Colors.white,
          padding: EdgeInsets.all(0),
          minWidth: 60,
          height: 30,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Text(
            "Đăng",
            style: TextStyle(
              color: context.theme.primaryColor,
              fontSize: FontSizes.medium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              EditFieldItem(
                field: "Tiêu đề",
                hintText: "Tiêu đề",
                controller: _titleController,
                minLine: 1,
                maxLine: 2,
              ),
              const SizedBox(height: 10),
              EditFieldItem(
                field: "Nội dung",
                hintText: "Nội dung thông báo",
                controller: _contentController,
                minLine: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
