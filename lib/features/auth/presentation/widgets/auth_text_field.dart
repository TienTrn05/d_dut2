import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/extensions/custom_theme_extension.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final Widget prefixIcon;
  final Color? iconColor;
  final bool obscureText;
  final bool enabledSuffixIcon;
  final TextInputType? keyboardType;
  final bool enabled;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onShowPasswordChanged;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.iconColor,
    this.obscureText = false,
    this.enabledSuffixIcon = false,
    this.keyboardType,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.onShowPasswordChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
          // fontFamily: GoogleFonts.notoSans().fontFamily,
          fontSize: 14,
          height: 1),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      cursorColor: iconColor,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: enabledSuffixIcon
            ? IconButton(
                icon: SvgPicture.asset(
                  obscureText
                      ? "assets/icons/svg/solar_eye-broken-lock.svg"
                      : "assets/icons/svg/solar_eye-broken.svg",
                  colorFilter: ColorFilter.mode(
                      obscureText
                          ? (context.theme.grey ?? Colors.grey)
                          : (context.theme.primaryColor ?? Colors.blue),
                      BlendMode.srcIn),
                ),
                onPressed: onShowPasswordChanged,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(
          color: context.theme.grey ?? Colors.grey,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
