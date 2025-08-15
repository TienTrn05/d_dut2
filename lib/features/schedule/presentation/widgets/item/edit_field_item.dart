import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditFieldItem extends StatelessWidget {
  final String field;
  final TextEditingController controller;
  final String? hintText;
  final int? minLine;
  final int? maxLine;
  final bool hasError;
  const EditFieldItem(
      {super.key,
      required this.field,
      required this.controller,
      this.minLine = 1,
      this.maxLine = 7,
      this.hasError = false,
      this.hintText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(field,
                style: TextStyle(
                  fontFamily: GoogleFonts.notoSans().fontFamily,
                  fontSize: FontSizes.medium,
                  fontWeight: FontWeight.w500,
                )),
            if (hasError)
              Text("*",
                  style: TextStyle(
                      fontSize: FontSizes.medium, color: context.theme.red)),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          textInputAction: TextInputAction.done,
          controller: controller,
          cursorColor: context.theme.grey ?? Colors.grey,
          maxLines: maxLine,
          minLines: minLine,
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
          },
          style: TextStyle(
            fontSize: FontSizes.small,
            color: context.theme.grey ?? Colors.grey,
          ),
          decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              hintText: hintText,
              hintStyle: TextStyle(
                color: context.theme.grey ?? Colors.grey,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ],
    );
  }
}
