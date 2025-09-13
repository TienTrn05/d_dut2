import 'package:flutter/material.dart';

class MicrosoftLoading extends StatefulWidget {
  const MicrosoftLoading({super.key});

  @override
  State<MicrosoftLoading> createState() => _MicrosoftLoadingState();
}

class _MicrosoftLoadingState extends State<MicrosoftLoading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Image.asset(
            "assets/icons/logo_full.png",
            width: 280,
            height: 280,
          ),
        ),
      ),
    );
  }
}
