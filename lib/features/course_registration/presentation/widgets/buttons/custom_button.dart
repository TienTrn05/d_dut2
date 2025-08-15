import 'package:flutter/material.dart';

import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool disabled;
  final Function()? onPressed;

  const CustomButton({
    super.key,
    required this.text,
    this.disabled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: disabled ? null : onPressed,
      color: context.theme.primaryColor,
      disabledColor: context.theme.grey!.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
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
