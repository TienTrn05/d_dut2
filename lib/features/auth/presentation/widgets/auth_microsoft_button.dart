import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthMicrosoftButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final Function()? onPressed;

  const AuthMicrosoftButton({
    super.key,
    required this.text,
    this.enabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MaterialButton(
          onPressed: onPressed,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
                  style: GoogleFonts.notoSans(
                    color: Color(0xFF0048FF),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                "assets/icons/svg/logo_dut.svg",
                width: 28,
                height: 28,
              ),
            ],
          ),
        );
      },
    );
  }
}
