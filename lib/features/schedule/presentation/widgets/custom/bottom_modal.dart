import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class BottomModal extends StatefulWidget {
  final String title;
  final Widget? child;
  final VoidCallback mainAction;
  final bool enabledMainAction;
  final VoidCallback? onClose;
  final double heightFactor;

  const BottomModal(
      {super.key,
      required this.title,
      this.child,
      required this.mainAction,
      this.enabledMainAction = true,
      this.onClose,
      this.heightFactor = 0.6});

  @override
  State<BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModal> {
  void resetValues() {
    widget.onClose?.call();
    Navigator.pop(context); // Đóng modal
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * widget.heightFactor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (widget.child != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: widget.child,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: ButtonStyle(
                      side: WidgetStateProperty.all(
                        BorderSide(
                          color: context.theme.primaryColor ?? Colors.blue,
                          width: 2,
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: resetValues,
                    child: Center(
                      child: Text(
                        "Hủy",
                        style: TextStyle(
                          color: context.theme.primaryColor ?? Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return context.theme.grey?.withAlpha(40) ??
                                Colors.grey.withAlpha(40);
                          }
                          return context.theme.primaryColor ?? Colors.blue;
                        },
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed:
                        widget.enabledMainAction ? widget.mainAction : null,
                    child: const Center(
                      child: Text(
                        "Lưu",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
