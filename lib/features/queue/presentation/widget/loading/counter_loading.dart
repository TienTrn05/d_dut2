import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class CounterLoading extends StatefulWidget {
  const CounterLoading({super.key});

  @override
  State<CounterLoading> createState() => _CounterLoadingState();
}

class _CounterLoadingState extends State<CounterLoading>
    with SingleTickerProviderStateMixin {
  bool isShowing = true;
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(children: [_buildHeader(context), _buildContent(context)]),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return MaterialButton(
      onPressed: () => setState(() => isShowing = !isShowing),
      minWidth: double.infinity,
      padding: EdgeInsets.only(
        top: 16,
        right: 16,
        left: 16,
        bottom: isShowing ? 10 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 8,
            children: [
              _buildRotatingArrow(),
              _ShimmerBox(
                animation: _animation,
                height: FontSizes.medium,
                width: 80,
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              _ShimmerBox(animation: _animation, height: 10, width: 10),
              _ShimmerBox(
                animation: _animation,
                height: FontSizes.small,
                width: 60,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingArrow() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isShowing ? 0 : -1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * (3.1415926535 / 2),
          child: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child:
          isShowing
              ? Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFECECEC))),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  spacing: 16,
                  children: [
                    // Current serving placeholder
                    Column(
                      children: [
                        Text(
                          "-",
                          style: TextStyle(
                            color: context.theme.grey,
                            fontSize: FontSizes.small + 1,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.theme.primaryColor,
                            fontSize: FontSizes.large * 3,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    // Waiting tickets shimmer
                    Column(
                      spacing: 8,
                      children: List.generate(
                        3,
                        (_) => _ShimmerBox(
                          animation: _animation,
                          height: 48,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}

// Reusable shimmer widget
class _ShimmerBox extends StatelessWidget {
  final Animation<double> animation;
  final double height;
  final double width;

  const _ShimmerBox({
    required this.animation,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + animation.value, -0.5),
              end: Alignment(1.0 + animation.value, 0.5),
              transform: const GradientRotation(30 * 3.14159 / 180),
            ),
          ),
        );
      },
    );
  }
}
