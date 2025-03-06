import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class SelectionButton extends StatefulWidget {
  // final Function(Set<String>) onSelectionChanged;
  const SelectionButton({super.key});

  @override
  State<SelectionButton> createState() => _SelectionButtonState();
}

class _SelectionButtonState extends State<SelectionButton> {
  Set<String> selectedOptions = {'isStudy', 'isExam'};

  void toggleSelection(String option) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option); // Bỏ chọn nếu đã chọn trước đó
      } else {
        selectedOptions.add(option); // Chọn nếu chưa được chọn
      }
      // widget.onSelectionChanged(selectedOptions);
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
          child: const Text("Lịch học",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
          child: const Text("Lịch thi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }
}
