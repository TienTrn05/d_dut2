import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/gen/assets.gen.dart';

class LoadingRow extends StatefulWidget {
  const LoadingRow({super.key});

  @override
  State<LoadingRow> createState() => _LoadingRowState();
}

class _LoadingRowState extends State<LoadingRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
          width: 16,
          child: RotationTransition(
            turns: _controller,
            child: SvgPicture.asset(
              Assets.icons.svg.streamlineUltimateLoadingBold,
              color: context.theme.primaryColor,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text("Bot đang nhập...", style: TextStyle(color: context.theme.grey)),
      ],
    );
  }
}
