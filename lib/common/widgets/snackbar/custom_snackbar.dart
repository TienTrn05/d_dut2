import 'package:flutter/material.dart';

enum AlertType {
  success,
  notice,
  warning,
  error,
}

class CustomSnackbar {
  static void showSnackBar(
    BuildContext context,
    String title,
    String message,
    AlertType alertType,
  ) {
    final snackBar = SnackBar(
      content: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getColor(alertType),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _getIcon(alertType),
            SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            /// Nút đóng (X)
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: SizedBox(
                  width: 44,
                  height: 44,
                  child:
                      Icon(Icons.clear_rounded, color: Colors.black, size: 28)),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Icon _getIcon(AlertType type, {double size = 28}) {
    switch (type) {
      case AlertType.error:
        return Icon(Icons.error, size: size);
      case AlertType.warning:
        return Icon(Icons.warning_rounded, size: size);
      case AlertType.notice:
        return Icon(Icons.info, size: size);
      case AlertType.success:
        return Icon(Icons.check_circle_rounded, size: size);
    }
  }

  static Color _getColor(AlertType type) {
    switch (type) {
      case AlertType.error:
        return Color(0xFFFFB7B8);
      case AlertType.warning:
        return Color(0xFFFAE7C7);
      case AlertType.notice:
        return Color(0xFFB2E7F5);
      case AlertType.success:
        return Color(0xFFB8F8C4);
    }
  }
}
