import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/extensions/custom_theme_extension.dart';

class NotificationCard extends StatelessWidget {
  final String date;
  final String title;
  final String content;
  final bool isRead;
  final bool canDel;

  const NotificationCard({
    super.key,
    required this.date,
    required this.title,
    required this.content,
    this.isRead = true,
    this.canDel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      color: isRead ? Color(0xffF5F5F5) : Color(0xffE4EDF4),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(date,
                      style: TextStyle(
                          color: context.theme.red ?? Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizes.medium)),
                ),
                if (canDel)
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/svg/mynaui_delete_solid.svg",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  )
              ],
            ),
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
