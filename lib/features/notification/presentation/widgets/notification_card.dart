import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';

class NotificationCard extends StatelessWidget {
  final String date;
  final String title;
  final String content;
  final bool isRead;
  final bool canDel;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.date,
    required this.title,
    required this.content,
    this.isRead = true,
    this.canDel = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(top: 0, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isRead ? context.theme.lightBlue : context.theme.lightGrey,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    date,
                    style: TextStyle(
                      color: context.theme.red ?? Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: FontSizes.medium,
                    ),
                  ),
                ),
                if (canDel)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: SvgPicture.asset(
                        Assets.icons.svg.mynauiDeleteSolid,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FontSizes.medium,
              ),
            ),
            SizedBox(height: 5),
            Html(
              data: content,
              onLinkTap: (url, attributes, element) async {
                if (url != null && await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  CustomSnackbar.showSnackBar(
                    context,
                    "Không thể mở liên kết",
                    " Liên kết không hợp lệ hoặc không thể mở.",
                    AlertType.error,
                  );
                }
              },
              style: {
                "body": Style(
                  fontSize: FontSize(FontSizes.medium),
                  color: context.theme.grey,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
