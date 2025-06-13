import 'package:flutter/material.dart';

import './common_colors.dart';

extension ExtendedTheme on BuildContext {
  CustomThemeExtension get theme =>
      Theme.of(this).extension<CustomThemeExtension>()!;
}

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color? primaryColor;
  final Color? lightBlue;
  final Color? mediumLightBlue;
  final Color? red;
  final Color? grey;

  static const lightMode = CustomThemeExtension(
      primaryColor: CommonColors.primaryColor,
      lightBlue: CommonColors.lightBlueColor,
      mediumLightBlue: CommonColors.mediumLightBlueColor,
      red: CommonColors.redColor,
      grey: CommonColors.greyColor);

  static const darkMode = CustomThemeExtension(
      primaryColor: CommonColors.primaryColor,
      lightBlue: CommonColors.lightBlueColor,
      mediumLightBlue: CommonColors.mediumLightBlueColor,
      red: CommonColors.redColor,
      grey: CommonColors.greyColor);

  const CustomThemeExtension({this.primaryColor, this.lightBlue, this.mediumLightBlue, this.red, this.grey});

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? primaryColor,
    Color? lightBlue,
    Color? mediumLightBlue,
    Color? red,
    Color? grey,
  }) {
    return CustomThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      lightBlue: lightBlue ?? this.lightBlue,
      mediumLightBlue: mediumLightBlue ?? this.mediumLightBlue,
      red: red ?? this.red,
      grey: grey ?? this.grey,
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
      lightBlue: Color.lerp(lightBlue, other.lightBlue, t),
      mediumLightBlue: Color.lerp(mediumLightBlue, other.mediumLightBlue, t),
      red: Color.lerp(red, other.red, t),
      grey: Color.lerp(grey, other.grey, t),
    );
  }
}
