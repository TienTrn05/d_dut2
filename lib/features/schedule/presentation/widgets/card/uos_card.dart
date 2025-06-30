import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class UosCard extends StatefulWidget {
  final String title;
  final bool isExam;
  final Widget? child;
  const UosCard(
      {super.key, required this.title, this.child, this.isExam = false});

  @override
  State<UosCard> createState() => _UosCardState();
}

class _UosCardState extends State<UosCard> {
  bool isShowing = true;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              setState(() {
                isShowing = !isShowing;
              });
            },
            minWidth: double.infinity,
            padding: EdgeInsets.all(0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: widget.isExam
                        ? context.theme.red ?? Colors.red
                        : context.theme.primaryColor ?? Colors.blue,
                    thickness: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: FontSizes.medium,
                    fontWeight: FontWeight.bold,
                    color: widget.isExam
                        ? context.theme.red ?? Colors.red
                        : context.theme.primaryColor ?? Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                TweenAnimationBuilder(
                  tween: Tween<double>(
                      begin: 0, end: isShowing ? 0 : -1), // 1 tương đương 90 độ
                  duration: const Duration(milliseconds: 300),
                  builder: (context, double value, child) {
                    return Transform.rotate(
                      angle: -value * (3.1415926535 / 2), // 90 độ = pi/2 radian
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded, // Chỉ dùng 1 icon
                        color: widget.isExam
                            ? context.theme.red ?? Colors.red
                            : context.theme.primaryColor ?? Colors.blue,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: widget.isExam
                        ? context.theme.red ?? Colors.red
                        : context.theme.primaryColor ?? Colors.blue,
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: (isShowing && widget.child != null)
                ? Container(
                    padding: EdgeInsets.only(top: 8), child: widget.child)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
