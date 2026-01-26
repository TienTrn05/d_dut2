import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationButton extends StatelessWidget {
  final int notificationCount;
  final Function()? onTap;
  const NotificationButton({
    super.key,
    required this.notificationCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: SvgPicture.asset(
                  Assets.icons.svg.solarBellBold,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            if (notificationCount > 0)
              Positioned(
                top: 0,
                right: 2,
                child: Container(
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 249, 132, 1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$notificationCount',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: FontSizes.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
