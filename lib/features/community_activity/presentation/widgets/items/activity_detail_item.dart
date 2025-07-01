import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActivityDetailItem extends StatelessWidget {
  final String title;
  final String content;
  final String iconPath;

  const ActivityDetailItem({
    super.key,
    required this.title,
    required this.content,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: context.theme.lightGrey,
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(
                context.theme.grey ?? Colors.grey, BlendMode.srcIn),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: FontSizes.large,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: FontSizes.large,
                    color: context.theme.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
