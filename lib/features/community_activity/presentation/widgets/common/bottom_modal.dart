import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart' show FontSizes;
import 'package:flutter/material.dart';

class BottomModal extends StatefulWidget {
  final String title;
  final Widget? child;
  final String? mainActionText;
  final VoidCallback mainAction;
  final bool enabledMainAction;
  final String? onCloseText;
  final VoidCallback? onClose;
  final double heightFactor;
  final bool isLoading;

  const BottomModal({
    super.key,
    required this.title,
    this.child,
    this.mainActionText,
    required this.mainAction,
    this.enabledMainAction = true,
    this.onCloseText,
    this.onClose,
    this.heightFactor = 0.6,
    this.isLoading = false,
  });

  @override
  State<BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModal> {
  void _handleClose(BuildContext context) {
    widget.onClose?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: widget.heightFactor,
            child: Column(
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: widget.child ?? const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleClose(context),
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
                        child: Text(
                          widget.onCloseText ?? 'Hủy',
                          style: TextStyle(
                            color: context.theme.primaryColor ?? Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizes.medium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed:
                            widget.enabledMainAction ? widget.mainAction : null,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
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
                        child: Text(
                          widget.mainActionText ?? 'Lưu',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizes.medium,
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
        ),
        if (widget.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: CircularProgressIndicator(
                    color: context.theme.primaryColor ?? Colors.blue),
              ),
            ),
          ),
      ],
    );
  }
}
