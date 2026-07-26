import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

class PLOItem extends StatelessWidget {
  final String ploName;
  final double ploScore;

  const PLOItem({super.key, required this.ploName, required this.ploScore});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  ploName,
                  style: TextStyle(
                    color: context.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.medium,
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  ploScore.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.medium,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color:
                  (ploScore == 0
                      ? const Color(0xFFFAE6E6)
                      : const Color(0xFFDCFCE7)),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              (ploScore == 0
                  ? Assets.icons.svg.ciWarning
                  : Assets.icons.svg.mingcuteCheckFill),
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  int getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width > 900) return 5; // web
    if (width > 600) return 4; // tablet
    return 3; // mobile
  }
}
