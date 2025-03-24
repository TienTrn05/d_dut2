import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class EditFieldItem extends StatelessWidget {
  final String field;
  final String value;
  final int? minLine;
  const EditFieldItem(
      {super.key, required this.field, required this.value, this.minLine = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(field, style: TextStyle(fontSize: FontSizes.medium)),
        const SizedBox(height: 4),
        TextField(
          // controller: value,
          cursorColor: context.theme.grey ?? Colors.grey,
          maxLines: 7,
          minLines: minLine,
          style: TextStyle(
            fontSize: FontSizes.medium,
            color: context.theme.grey ?? Colors.grey,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            // hintText: "Đường dẫn...",
            hintStyle: TextStyle(
              color: context.theme.grey ?? Colors.grey,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
