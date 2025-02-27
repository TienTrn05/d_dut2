import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class AuthButton extends StatelessWidget {
  final String text;
  Color fillColor;
  Function()? onPressed;

  AuthButton({super.key, required this.text, this.fillColor = Colors.blue, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: fillColor,
      padding: EdgeInsets.symmetric(vertical: 16),
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      highlightElevation: 0,
      child: Text(text,
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.notoSans().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          )),
    );
  }
}
