import 'package:flutter/material.dart';

import './common_colors.dart';

extension ExtendedTheme on BuildContext {
  CustomThemeExtension get theme =>
      Theme.of(this).extension<CustomThemeExtension>()!;
}

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color? primaryColor;
  final Color? lightBlue;
  final Color? red;
  final Color? grey;

  static const lightMode = CustomThemeExtension(
      primaryColor: CommonColors.primaryColor,
      lightBlue: CommonColors.lightBlueColor,
      red: CommonColors.redColor,
      grey: CommonColors.greyColor);

  static const darkMode = CustomThemeExtension(
      primaryColor: CommonColors.primaryColor,
      lightBlue: CommonColors.lightBlueColor,
      red: CommonColors.redColor,
      grey: CommonColors.greyColor);

  const CustomThemeExtension({this.primaryColor, this.lightBlue, this.red, this.grey});

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? primaryColor,
  }) {
    return CustomThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
      covariant ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
    );
  }
}
