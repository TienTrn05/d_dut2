import 'package:flutter/material.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

import '../../data/models/grade.dart';

class GradeListTile extends StatelessWidget {
  final Grade grade;

  const GradeListTile({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -4),
      title: Text(
        grade.courseName,
        style: TextStyle(
          color: context.theme.primaryColor,
          fontSize: FontSizes.large,
        ),
      ),
      subtitle: Text(
        'Số tín chỉ: ${grade.credits}',
        style: TextStyle(
          color: context.theme.grey,
          fontSize: FontSizes.small,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Thang 10: ${grade.score10Scale.toStringAsFixed(1)}',
            style: TextStyle(
              color: Colors.black,
              fontSize: FontSizes.small - 1,
            ),
          ),
          Text(
            'Thang 4: ${grade.score4Scale.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.black,
              fontSize: FontSizes.small - 1,
            ),
          ),
        ],
      ),
    );
  }
}
