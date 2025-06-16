import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../common/extensions/custom_theme_extension.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard(
      {super.key,
      required this.iconUrl,
      required this.title,
      required this.subtitle,
      this.onTap});

  final Function()? onTap;
  final String iconUrl;
  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(64),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(2, 2)
            )
        ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconUrl,
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  child: Text(
                    title,
                    maxLines: 2,
                    style: TextStyle(
                        color: context.theme.primaryColor,
                        fontSize: FontSizes.large,
                        fontWeight: FontWeight.bold,
                        height: 1),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: FontSizes.small,
                      color: Color.fromRGBO(116, 116, 116, 1),
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
