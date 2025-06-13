import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;
  final double? minHeight;
  final double? value;

  const CustomLoadingIndicator({
    super.key,
    this.color,
    this.backgroundColor,
    this.minHeight,
    this.value,
  });

  // Factory constructor cho loading indicator mặc định của app
  factory CustomLoadingIndicator.primary({
    double? minHeight,
    double? value,
  }) {
    return CustomLoadingIndicator(
      color: const Color(0xFF0D99FF),
      backgroundColor: Colors.transparent,
      minHeight: minHeight ?? 2,
      value: value,
    );
  }

  // Factory constructor cho loading indicator dạng thin (thanh mỏng)
  factory CustomLoadingIndicator.thin({
    Color? color,
    double? value,
  }) {
    return CustomLoadingIndicator(
      color: color ?? const Color(0xFF0D99FF),
      backgroundColor: Colors.transparent,
      minHeight: 1,
      value: value,
    );
  }

  // Factory constructor cho loading indicator dạng thick (thanh dày)
  factory CustomLoadingIndicator.thick({
    Color? color,
    double? value,
  }) {
    return CustomLoadingIndicator(
      color: color ?? const Color(0xFF0D99FF),
      backgroundColor: Colors.grey.withAlpha(51),
      minHeight: 4,
      value: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      valueColor: color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
      backgroundColor: backgroundColor,
      minHeight: minHeight ?? 2,
    );
  }
}
