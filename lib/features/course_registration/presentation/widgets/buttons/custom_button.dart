import 'package:flutter/material.dart';

import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: context.theme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      elevation: 0,
      highlightElevation: 0,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: FontSizes.medium,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
