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
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getColor(alertType),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _getIcon(alertType),
            SizedBox(width: 10),
            Container(
              width: 1,
              height: 44,
              color: Colors.black,
            ),
            SizedBox(width: 10),
            Expanded(
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
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
                child: Icon(Icons.close, color: Colors.black, size: 26)),
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

  static Icon _getIcon(AlertType type) {
    switch (type) {
      case AlertType.error:
        return Icon(Icons.error);
      case AlertType.warning:
        return Icon(Icons.warning);
      case AlertType.notice:
        return Icon(Icons.info);
      case AlertType.success:
        return Icon(Icons.check_circle);
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
