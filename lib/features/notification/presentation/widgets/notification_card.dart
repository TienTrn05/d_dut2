import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

import '../../../../common/extensions/custom_theme_extension.dart';

class NotificationCard extends StatelessWidget {
  final String date;
  final String title;
  final String content;

  const NotificationCard({
    super.key,
    required this.date,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Color(0xffE4EDF4),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date,
                style: TextStyle(
                    color: Color(0xFFCC0102),
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.medium)),
            SizedBox(height: 5),
            Text(title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: FontSizes.medium,
                )),
            SizedBox(height: 5),
            Text(content,
                style: TextStyle(
                  fontSize: FontSizes.medium,
                  color: context.theme.grey,
                )),
          ],
        ),
      ),
    );
  }
}
