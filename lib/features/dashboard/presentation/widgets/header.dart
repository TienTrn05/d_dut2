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
  final Function()? onHeaderTap;
  final Function()? onTap;

  const Header({
    super.key,
    required this.displayName,
    required this.userPrincipalName,
    this.onHeaderTap,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: MaterialButton(
        onPressed: onHeaderTap,
        minWidth: double.infinity,
        height: 72,
        padding: const EdgeInsets.all(0),
        color: context.theme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        hoverElevation: 0,
        disabledElevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 10,
                  top: 16,
                  bottom: 16,
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: ClipOval(
                        child:
                            userPrincipalName.endsWith("@sv1.dut.udn.vn")
                                ? Image.network(
                                  'https://cb.dut.udn.vn/ImageSV/${userPrincipalName.substring(3, 5)}/${userPrincipalName.substring(0, 9)}.jpg',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default_avatar.jpg',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                                : Image.asset(
                                  'assets/images/default_avatar.jpg',
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
                                  height: 1.25,
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
                                  height: 1.5,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            NotificationButton(notificationCount: 0, onTap: onTap),
          ],
        ),
      ),
    );
  }
}
