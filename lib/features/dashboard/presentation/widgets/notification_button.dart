import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class NotificationButton extends StatelessWidget {
  final int notificationCount;
  final Function()? onTap;
  const NotificationButton({super.key, required this.notificationCount, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Iconify(
                Mdi.bell,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          if (notificationCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
