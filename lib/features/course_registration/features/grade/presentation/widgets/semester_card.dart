import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/course_registration/features/grade/utils/grade_utils.dart';
import 'package:flutter/material.dart';

class SemesterCard extends StatefulWidget {
  final String semesterCode;
  final Widget? child;
  const SemesterCard({super.key, required this.semesterCode, this.child});

  @override
  State<SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<SemesterCard> {
  bool isShowing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              setState(() {
                isShowing = !isShowing;
              });
            },
            minWidth: double.infinity,
            padding: EdgeInsets.all(16.0),
            color: context.theme.lightBlue,
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: isShowing
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        GradeUtils.getSemesterStr(widget.semesterCode),
                        style: TextStyle(
                          fontSize: FontSizes.medium,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TweenAnimationBuilder(
                  tween: Tween<double>(
                      begin: 0, end: isShowing ? 0 : -1), // 1 tương đương 90 độ
                  duration: const Duration(milliseconds: 300),
                  builder: (context, double value, child) {
                    return Transform.rotate(
                      angle: value * (3.1415926535), // 90 độ = pi/2 radian
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded, // Chỉ dùng 1 icon
                        color: Colors.black,
                        size: 24,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: (isShowing && widget.child != null)
                ? Container(
                    padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                        color: context.theme.lightGrey,
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16))),
                    child: widget.child)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
