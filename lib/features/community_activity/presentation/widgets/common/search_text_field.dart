import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterPressed;
  final String iconUrl;
  final Color textColor;
  final String hintText;
  const SearchTextField(
      {super.key,
      required this.controller,
      required this.onFilterPressed,
      required this.iconUrl,
      required this.textColor,
      this.hintText = "Tìm kiếm..."});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 16,
        color: textColor,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
        suffixIcon: IconButton(
          icon: SvgPicture.asset(
            iconUrl,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              textColor,
              BlendMode.srcIn,
            ),
          ),
          onPressed: onFilterPressed,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
