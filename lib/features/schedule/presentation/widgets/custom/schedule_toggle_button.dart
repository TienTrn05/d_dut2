import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class ScheduleToggleButton extends StatefulWidget {
  final String studyLabel;
  final String examLabel;
  final Function(Set<String>) onSelectionChanged;
  const ScheduleToggleButton(
      {super.key,
      required this.studyLabel,
      required this.examLabel,
      required this.onSelectionChanged});

  @override
  State<ScheduleToggleButton> createState() => _ScheduleToggleButtonState();
}

class _ScheduleToggleButtonState extends State<ScheduleToggleButton> {
  Set<String> selectedOptions = {'isStudy', 'isExam'};

  void toggleSelection(String option) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option); // Bỏ chọn nếu đã chọn trước đó
      } else {
        selectedOptions.add(option); // Chọn nếu chưa được chọn
      }
      widget.onSelectionChanged(selectedOptions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: () => toggleSelection('isStudy'),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: selectedOptions.contains('isStudy')
                ? context.theme.primaryColor ?? Colors.blue
                : Color.fromRGBO(245, 245, 245, 1),
            foregroundColor: selectedOptions.contains('isStudy')
                ? Colors.white
                : Color(0xFF747474),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          child: Text(widget.studyLabel,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: FontSizes.small)),
        ),
        const SizedBox(width: 4),
        FilledButton(
          onPressed: () => toggleSelection('isExam'),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: selectedOptions.contains('isExam')
                ? context.theme.red ?? Colors.red
                : Color.fromRGBO(245, 245, 245, 1),
            foregroundColor: selectedOptions.contains('isExam')
                ? Colors.white
                : Color(0xFF747474),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          child: Text(widget.examLabel,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: FontSizes.small)),
        ),
      ],
    );
  }
}
