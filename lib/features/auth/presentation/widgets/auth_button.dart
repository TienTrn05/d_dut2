import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AuthButton extends StatelessWidget {
  final String text;
  Function()? onPressed;

  AuthButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Color.fromRGBO(19, 61, 135, 1),
      padding: EdgeInsets.symmetric(vertical: 16),
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      highlightElevation: 0,
      child: Text(text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          )),
    );
  }
}
