import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

enum AlertType { confirm, delete }

class CustomAlertDialog {
  static void showCustomDialog(
    BuildContext context,
    String title,
    String message,
    AlertType alertType, {
    String? textConfirm,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getColor(alertType, context).withAlpha(10)),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getColor(alertType, context).withAlpha(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: _getIcon(alertType, context),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: FontSizes.large,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: FontSizes.medium,
                      color: context.theme.grey,
                      fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: OutlinedButton(
                      style: ButtonStyle(
                        side: WidgetStateProperty.all(BorderSide(
                            color: _getColor(alertType, context), width: 2)),
                        padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onCancel != null) {
                          onCancel();
                        }
                      },
                      child: Center(
                        child: Text(
                          "Hủy",
                          style: TextStyle(
                              color: _getColor(alertType, context),
                              fontWeight: FontWeight.bold,
                              fontSize: FontSizes.medium),
                        ),
                      ),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            _getColor(alertType, context),
                          ),
                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12)),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (onConfirm != null) {
                            onConfirm();
                          }
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text(
                            textConfirm ?? "Xác nhận",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: FontSizes.medium),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  static Icon _getIcon(AlertType type, BuildContext context,
      {double size = 28}) {
    Color iconColor = _getColor(type, context);
    switch (type) {
      case AlertType.confirm:
        return Icon(Icons.info_outline_rounded, color: iconColor, size: size);
      case AlertType.delete:
        return Icon(Icons.delete_outline, color: iconColor, size: size);
    }
  }

  static Color _getColor(AlertType type, BuildContext context) {
    switch (type) {
      case AlertType.confirm:
        return context.theme.primaryColor ?? Colors.blue;
      case AlertType.delete:
        return context.theme.red ?? Colors.red;
    }
  }
}
