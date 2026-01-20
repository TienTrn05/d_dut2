import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradeButton extends StatelessWidget {
  final Function()? onTap;
  const GradeButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: SvgPicture.asset(
            Assets.icons.svg.mageGoals,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            width: 28,
            height: 28,
          ),
        ),
      ),
    );
  }
}
