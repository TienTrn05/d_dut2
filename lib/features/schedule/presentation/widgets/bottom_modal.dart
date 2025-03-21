import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class BottomModal extends StatefulWidget {
  final String title;
  final Widget? child;
  final VoidCallback mainAction;

  const BottomModal({
    super.key,
    required this.title,
    this.child,
    required this.mainAction,
  });

  @override
  State<BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModal> {
  void resetValues() {
    // Nếu có TextEditingController, bạn reset chúng ở đây
    // controller1.clear();
    // controller2.clear();

    Navigator.pop(context); // Đóng modal
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Đẩy lên khi bàn phím hiện
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 500, // Chiều cao tối thiểu là 100
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              (widget.child != null)
                  ? Container(
                      padding: EdgeInsets.only(top: 8), child: widget.child)
                  : const SizedBox(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: OutlinedButton(
                    style: ButtonStyle(
                      side: WidgetStateProperty.all(BorderSide(
                          color: context.theme.primaryColor ?? Colors.blue,
                          width: 2)),
                      padding: WidgetStateProperty.all(EdgeInsets.all(16)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () => resetValues(),
                    child: Center(
                      child: Text(
                        "Hủy",
                        style: TextStyle(
                            color: context.theme.primaryColor ?? Colors.blue,
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
                          context.theme.primaryColor ?? Colors.blue,
                        ),
                        padding: WidgetStateProperty.all(EdgeInsets.all(16)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: widget.mainAction,
                      child: Center(
                        child: Text(
                          "Lưu",
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
              const SizedBox(height: 20),
            ],
          ),
        ));
  }
}
