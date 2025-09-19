import 'dart:async';
import 'package:flutter/material.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';

enum AlertType {
  success,
  notice,
  warning,
  error,
}

class ContainerSnackbar extends StatefulWidget {
  final String title;
  final String message;
  final AlertType alertType;
  final Duration duration;
  final VoidCallback? onClose; // callback để parent biết khi nào alert đóng

  const ContainerSnackbar({
    super.key,
    required this.title,
    required this.message,
    required this.alertType,
    this.duration = const Duration(seconds: 10),
    this.onClose,
  });

  @override
  State<ContainerSnackbar> createState() => _ContainerSnackbarState();
}

class _ContainerSnackbarState extends State<ContainerSnackbar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Set timer tự tắt
    _timer = Timer(widget.duration, () {
      if (mounted) {
        widget.onClose?.call(); // báo parent đóng
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getColor(widget.alertType),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _getIcon(widget.alertType),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(
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
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: FontSizes.medium,
                    ),
                  ),
                  Text(
                    widget.message,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: FontSizes.medium,
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
              widget.onClose?.call();
            },
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.clear_rounded, color: Colors.black, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Icon _getIcon(AlertType type, {double size = 28}) {
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

  Color _getColor(AlertType type) {
    switch (type) {
      case AlertType.error:
        return const Color(0xFFFFB7B8);
      case AlertType.warning:
        return const Color(0xFFFAE7C7);
      case AlertType.notice:
        return const Color(0xFFB2E7F5);
      case AlertType.success:
        return const Color(0xFFB8F8C4);
    }
  }
}
