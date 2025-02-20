import 'package:flutter/material.dart';

class CubeGridLoading extends StatefulWidget {
  final Color? backgroundColor;

  const CubeGridLoading({super.key, this.backgroundColor});

  @override
  State<CubeGridLoading> createState() => _CubeGridLoadingState();
}

class _CubeGridLoadingState extends State<CubeGridLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  final int gridCount = 4;
  final double gridItemSize = 20;
  final double gridSpacing = 2;

  final List<List<int>> sequence = [
    [0],
    [1, 4],
    [2, 5, 8],
    [3, 6, 9, 12],
    [7, 10, 13],
    [11, 14],
    [15]
  ];

  final List<Color> colors = [
    Color(0xFFd4aee0),
    Color(0xFF8975b4),
    Color(0xFF64518a),
    Color(0xFF565190),
    Color(0xFF44abac),
    Color(0xFF2ca7d8),
    Color(0xFF1482ce),
    Color(0xFF05597c),
    Color(0xFFb2dd57),
    Color(0xFF57c443),
    Color(0xFF05b853),
    Color(0xFF19962e),
    Color(0xFFfdc82e),
    Color(0xFFfd9c2e),
    Color(0xFFd5385a),
    Color(0xFF911750),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    // Lặp xuôi rồi ngược
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward(); // Bắt đầu animation

    _animations = List.generate(gridCount * gridCount, (index) {
      int step = sequence.indexWhere((list) => list.contains(index));
      return Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (step / sequence.length).clamp(0.0, 1.0),
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = gridItemSize * gridCount + gridSpacing * (gridCount - 1);

    return Container(
      color: widget.backgroundColor ?? Colors.black.withAlpha(80),
      child: Center(
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Icon nằm dưới Grid
              Image.asset(
                "assets/icons/icon.png",
                width: totalSize + 3,
                height: totalSize + 3,
              ),

              // Grid ở trên
              SizedBox(
                width: totalSize,
                height: totalSize,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCount,
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
                    ),
                    itemCount: gridCount * gridCount,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _animations[index],
                        builder: (context, child) {
                          return Opacity(
                            opacity: _animations[index].value,
                            child: Container(
                              color: colors[index % colors.length],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
