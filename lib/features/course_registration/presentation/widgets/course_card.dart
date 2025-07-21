import 'package:flutter/material.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

import '../../data/models/course.dart';

class CourseCard extends StatefulWidget {
  final Course course;
  final Widget? child;

  const CourseCard({super.key, required this.course, this.child});

  @override
  State<CourseCard> createState() => _CourseCartState();
}

class _CourseCartState extends State<CourseCard> with TickerProviderStateMixin {
  bool isShowing = false;

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
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            color: Color(0xFFF5F5F5),
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${widget.course.id} ',
                            style: TextStyle(
                              fontSize: FontSizes.medium - 1,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF747474),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.fiber_manual_record,
                            size: 6,
                            color: Color(0xFF747474),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.course.credits} tín chỉ',
                            style: TextStyle(
                              fontSize: FontSizes.medium - 1,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF747474),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.course.courseName,
                        style: TextStyle(
                          fontSize: FontSizes.large,
                          fontWeight: FontWeight.bold,
                          color: context.theme.primaryColor,
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
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    child: Container(
                        padding: EdgeInsets.only(top: 8), child: widget.child),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
