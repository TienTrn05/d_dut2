import 'package:flutter/material.dart';

class TicketLoading extends StatefulWidget {
  const TicketLoading({super.key});

  @override
  State<TicketLoading> createState() => _TicketLoadingState();
}

class _TicketLoadingState extends State<TicketLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          height: 122,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Color(0xFFE0E0E0), Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _animation.value, -0.5), // Nghiêng 30 độ
              end: Alignment(1.0 + _animation.value, 0.5),
              transform: GradientRotation(30 * 3.14159 / 180), // 30 độ
            ),
          ),
        );
      },
    );
  }
}
