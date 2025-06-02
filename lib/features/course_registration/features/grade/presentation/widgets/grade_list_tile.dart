import 'package:flutter/material.dart';

import '../../data/models/grade.dart';

class GradeListTile extends StatelessWidget {
  final Grade grade;

  const GradeListTile({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(grade.courseName),
      subtitle:
          Text('Học kỳ: ${grade.semesterCode} • Số tín chỉ: ${grade.credits}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Thang 10: ${grade.score10Scale.toStringAsFixed(1)}'),
          Text('Thang 4: ${grade.score4Scale.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
