import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterPressed;
  final String iconUrl;
  final Color textColor;
  final String hintText;
  final bool isFilterActive;

  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.onFilterPressed,
    required this.iconUrl,
    required this.textColor,
    this.hintText = "Tìm kiếm...",
    this.isFilterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isFilterActive ? (context.theme.primaryColor ?? textColor) : textColor;

    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 16, color: textColor),
      cursorColor: context.theme.grey ?? Colors.grey,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.theme.lightGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 16, color: textColor),
        suffixIcon: IconButton(
          icon: SvgPicture.asset(
            iconUrl,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
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
