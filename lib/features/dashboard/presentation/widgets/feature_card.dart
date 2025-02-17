import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';

class FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const FeatureCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(icon, size: 32, color: context.theme.primaryColor),
          const SizedBox(height: 16),
          Column(
            children: [
              SizedBox(
                height: 35,
                child: Text(
                  title,
                  maxLines: 2,
                  style: TextStyle(
                      color: context.theme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 30,
                child: Text(
                  subtitle,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(116, 116, 116, 1),
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
