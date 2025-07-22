import 'package:e_dut/features/course_registration/features/grade/utils/grade_utils.dart';
import 'package:flutter/material.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

import '../../data/models/grade.dart';

class GradeListTile extends StatelessWidget {
  final Grade grade;

  const GradeListTile({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final gradeColor = GradeUtils.getGradeColor(grade.letterGrade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                grade.courseName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSizes.small,
                ),
              ),
              // if (grade.letterGrade.isNotEmpty)
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: gradeColor.background),
                child: Text(
                  grade.letterGrade,
                  style: TextStyle(
                      color: gradeColor.text,
                      fontSize: FontSizes.small,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tín chỉ',
                    style: TextStyle(
                      color: context.theme.grey,
                      fontSize: FontSizes.small,
                    ),
                  ),
                  Text(
                    grade.credits.toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: FontSizes.small,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm thang 4',
                    style: TextStyle(
                      color: context.theme.grey,
                      fontSize: FontSizes.small,
                    ),
                  ),
                  Text(
                    grade.score4Scale.toStringAsFixed(1),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: FontSizes.small,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm thang 10',
                    style: TextStyle(
                      color: context.theme.grey,
                      fontSize: FontSizes.small,
                    ),
                  ),
                  Text(
                    grade.score10Scale.toStringAsFixed(1),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: FontSizes.small,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
