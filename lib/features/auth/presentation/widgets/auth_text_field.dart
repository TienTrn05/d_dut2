import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final dynamic prefixIcon; // Có thể là IconData hoặc AssetImage
  final Color? iconColor;
  final TextEditingController controller;
  final bool obscureText;
  final bool enabledSuffixIcon;
  final TextInputType? keyboardType;
  final bool enabled;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const AuthTextField({
    super.key,
    required this.hintText,
    this.prefixIcon = Icons.person,
    this.iconColor,
    required this.controller,
    this.obscureText = false,
    this.enabledSuffixIcon = false,
    this.keyboardType,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        prefixIcon: prefixIcon is String
            ? Padding(
                padding: const EdgeInsets.all(12.0), // Căn chỉnh icon
                child: Image.asset(
                  prefixIcon,
                  width: 20,
                  height: 20,
                  color: iconColor, // Có thể đổi màu icon nếu cần
                ),
              )
            : Icon(
                prefixIcon,
                color: iconColor,
              ),
        suffixIcon: enabledSuffixIcon
            ? Image.asset(
                'assets/icons/solar_eye-broken.png',
                width: 20,
                height: 20,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
