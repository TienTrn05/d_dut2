import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import './notification_button.dart';

import '../../../../common/extensions/custom_theme_extension.dart';
import '../../../../common/extensions/font_sizes.dart';

class Header extends StatelessWidget {
  final String displayName;
  final String userPrincipalName;
  final bool isLoading;
  final Function()? onTap;

  const Header({
    super.key,
    required this.displayName,
    required this.userPrincipalName,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Container(
      width: double.infinity,
      height: 72,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: context.theme.primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 10, top: 16, bottom: 16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://www.udn.vn/Portals/0/3doan%20bk.jpg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        isLoading
                            ? Shimmer.fromColors(
                                baseColor: baseColor,
                                highlightColor: highlightColor,
                                child: Container(
                                  height: 14,
                                  width: 100,
                                  color: baseColor,
                                ),
                              )
                            : Text(
                                displayName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.notoSans().fontFamily,
                                  fontSize: FontSizes.large,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        isLoading
                            ? Shimmer.fromColors(
                                baseColor: baseColor,
                                highlightColor: highlightColor,
                                child: Container(
                                  height: 12,
                                  width: 140,
                                  color: baseColor,
                                ),
                              )
                            : Text(
                                userPrincipalName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.notoSans().fontFamily,
                                  fontSize: FontSizes.small,
                                  height: 1,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          NotificationButton(
            notificationCount: 2,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
