import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../common/extensions/custom_theme_extension.dart';

class FeatureCardSkeleton extends StatelessWidget {
  const FeatureCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // circle container
          Shimmer.fromColors(
            baseColor: context.theme.primaryColor ?? Colors.blue,
            highlightColor: Colors.white,
            child: SvgPicture.asset(
              "assets/icons/svg/mage_goals.svg",
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.black.withAlpha(20),
                highlightColor: Colors.blue[50]!,
                child: SizedBox(
                  height: 35,
                  child: Text(
                    "Đang tải...",
                    maxLines: 2,
                    style: TextStyle(
                        color: context.theme.primaryColor,
                        fontSize: FontSizes.large,
                        fontWeight: FontWeight.bold,
                        height: 1),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ],
      ),
    );
  }
}
