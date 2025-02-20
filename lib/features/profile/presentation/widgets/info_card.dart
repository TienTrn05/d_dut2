import 'package:flutter/material.dart';

class InfoCart extends StatefulWidget {
  final String title;
  final Widget? child;

  const InfoCart({super.key, required this.title, this.child});

  @override
  State<InfoCart> createState() => _InfoCartState();
}

class _InfoCartState extends State<InfoCart> with TickerProviderStateMixin {
  bool isShowing = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 5,
            spreadRadius: 2,
          )
        ],
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
            child: Row(
              children: [
                Icon(
                  isShowing
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
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
