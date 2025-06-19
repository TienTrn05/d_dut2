import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/notification_button.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tab/uos_info_tab.dart';
import 'package:flutter/material.dart';

class DetailUnitOfStudy extends StatelessWidget {
  final String idUos;

  const DetailUnitOfStudy({super.key, required this.idUos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: context.theme.primaryColor ?? Colors.blue,
        elevation: 0, // Xóa bóng dưới AppBar
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Quay lại màn hình trước
            },
          ),
        ),
        title: Text(
          'Thông tin chi tiết học phần',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.medium,
          ),
        ),
        centerTitle: true,
        actions: [
          NotificationButton(
            notificationCount: 2,
            onTap: () => {Navigator.of(context).pushNamed(Routes.notification)},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lập trình di động',
              style: TextStyle(
                fontSize: FontSizes.extraLarge,
                fontWeight: FontWeight.bold,
                height: 1.25,
                color: context.theme.primaryColor ?? Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: UosInfoTab(
              idUos: idUos,
            ))
          ],
        ),
      ),
    );
  }
}
