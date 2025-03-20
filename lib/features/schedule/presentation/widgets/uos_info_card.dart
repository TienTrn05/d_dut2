import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class UosInfoCard extends StatefulWidget {
  final String title;
  final Widget? child;

  const UosInfoCard({super.key, required this.title, this.child});

  @override
  State<UosInfoCard> createState() => _UosInfoCardState();
}

class _UosInfoCardState extends State<UosInfoCard> {
  bool isShowing = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromRGBO(245, 245, 245, 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              setState(() {
                isShowing = !isShowing;
              });
            },
            minWidth: double.infinity,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(
                      begin: 0, end: isShowing ? 0 : -1), // 1 tương đương 90 độ
                  duration: const Duration(milliseconds: 300),
                  builder: (context, double value, child) {
                    return Transform.rotate(
                      angle: value * (3.1415926535 / 2), // 90 độ = pi/2 radian
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded, // Chỉ dùng 1 icon
                        color: Colors.black,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: FontSizes.medium,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: (isShowing && widget.child != null)
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    child: Container(
                        padding: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ))),
                        child: widget.child),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
