import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/common/extensions/custom_theme_extension.dart';

class CustomLoading extends StatelessWidget {
  final String message;
  final double size;
  final Color? color;

  const CustomLoading({super.key, this.message = "", this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitFadingCircle(
              color: color ?? context.theme.primaryColor,
              size: size,
            ),
            SizedBox(height: 10.0),
            Text(
              message,
              style: TextStyle(
                color: color ?? context.theme.primaryColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}