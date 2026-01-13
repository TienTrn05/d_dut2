import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/queue/data/models/counter_queue_model.dart';
import 'package:flutter/material.dart';

class QueueInfoCard extends StatefulWidget {
  final String title;
  final CounterQueueModel? counter;
  final Widget? child;
  const QueueInfoCard({
    super.key,
    required this.title,
    this.counter,
    this.child,
  });

  @override
  State<QueueInfoCard> createState() => _QueueInfoCardState();
}

class _QueueInfoCardState extends State<QueueInfoCard> {
  bool isShowing = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFECECEC)),
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
            padding: EdgeInsets.only(
              top: 16,
              right: 16,
              left: 16,
              bottom: isShowing ? 10 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: isShowing ? 0 : -1),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, double value, child) {
                        return Transform.rotate(
                          angle: value * (3.1415926535 / 2),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black,
                            size: 28,
                          ),
                        );
                      },
                    ),
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
                if (widget.counter != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 8,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color:
                              widget.counter!.sessionStatus == 1
                                  ? context.theme.green
                                  : context.theme.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        widget.counter!.sessionStatus == 1
                            ? 'Sẵn sàng phục vụ'
                            : 'Chỉ phục vụ hàng đợi',
                        style: TextStyle(
                          color: context.theme.grey,
                          fontSize: FontSizes.small,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                isShowing
                    ? Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFECECEC)),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: widget.child,
                    )
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
