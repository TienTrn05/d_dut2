import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthMicrosoftButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final Color color;
  final Function()? onPressed;

  const AuthMicrosoftButton({
    super.key,
    required this.text,
    this.enabled = true,
    this.color = Colors.blue,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MaterialButton(
          onPressed: onPressed,
          color: color,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          highlightElevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max, // Giữ nội dung vừa đủ
            children: [
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.notoSans().fontFamily,
                    fontSize: FontSizes.medium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              // const SizedBox(width: 8),
              // SvgPicture.asset(
              //   "assets/icons/svg/mdi_microsoft.svg",
              //   colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              // ),
            ],
          ),
        );
      },
    );
  }
}
