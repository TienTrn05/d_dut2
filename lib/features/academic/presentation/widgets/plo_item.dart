import 'package:flutter/material.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

class PLOItem extends StatelessWidget {
  final String ploName;
  final double ploScore;

  const PLOItem({super.key, required this.ploName, required this.ploScore});

  @override
  Widget build(BuildContext context) {
    double width =
        (MediaQuery.of(context).size.width - 100) / getCrossAxisCount(context);

    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.theme.lightBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ploName,
            style: TextStyle(
              color: context.theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: FontSizes.medium,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.theme.green,
            ),
            alignment: Alignment.center,
            child: Text(
              ploScore.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: FontSizes.medium,
              ),
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
