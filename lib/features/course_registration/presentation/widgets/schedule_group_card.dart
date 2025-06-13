import 'package:flutter/material.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

class ScheduleGroupCard extends StatefulWidget {
  final String scheduleGroup;
  final Widget? child;

  const ScheduleGroupCard({super.key, required this.scheduleGroup, this.child});

  @override
  State<ScheduleGroupCard> createState() => _ScheduleGroupCardState();
}

class _ScheduleGroupCardState extends State<ScheduleGroupCard> with TickerProviderStateMixin {
  bool isShowing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            color: Color(0xFFF5F5F5),
            elevation: 0,
            highlightElevation: 0,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhóm ${widget.scheduleGroup}',
                        style: TextStyle(
                          fontSize: FontSizes.extraLarge,
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
                        padding: EdgeInsets.only(top: 8),
                        
                        child: widget.child),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
