import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.iconUrl,
    required this.title,
    this.disabled = false,
    this.originIconColor = false,
    this.onTap,
  });

  final Function()? onTap;
  final String iconUrl;
  final String title;
  final bool disabled;
  final bool originIconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !disabled ? onTap : () {},
      child: Container(
        decoration: BoxDecoration(
          color: !disabled ? Colors.white : context.theme.lightGrey,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(64),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconUrl,
              width: 32,
              height: 32,
              colorFilter:
                  originIconColor
                      ? null
                      : ColorFilter.mode(
                        !disabled
                            ? context.theme.primaryColor!
                            : context.theme.grey!,
                        BlendMode.srcIn,
                      ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  // height: 35,
                  width: double.infinity,
                  child: Text(
                    title,
                    maxLines: 2,
                    style: TextStyle(
                      color:
                          !disabled
                              ? context.theme.primaryColor
                              : context.theme.grey,
                      fontSize: FontSizes.large,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5),
                disabled
                    ? SizedBox(
                      height: 20,
                      child: Text(
                        "Sắp ra mắt...",
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: FontSizes.small,
                          color:
                              !disabled
                                  ? context.theme.primaryColor
                                  : context.theme.grey,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
