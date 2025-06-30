import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tab/uos_info_tab.dart';
import 'package:flutter/material.dart';

class DetailUnitOfStudy extends StatelessWidget {
  final String idUos;

  const DetailUnitOfStudy({super.key, required this.idUos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(label: "Thông tin chi tiết học phần"),
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
