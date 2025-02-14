import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AuthMicrosoftButton extends StatelessWidget {
  final String text;
  bool enabled;
  Function()? onPressed;

  AuthMicrosoftButton({super.key, required this.text, this.enabled = true, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16),
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Bo góc 8px
        side: BorderSide(
          color: Color.fromRGBO(19, 61, 135, 1),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      highlightElevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Color.fromRGBO(19, 61, 135, 1),
              fontSize: 16,
            ),
          ),
          SizedBox(width: 12),
          Image.asset(
            'assets/icons/mdi_microsoft.png',
            width: 24,
            height: 24,
          ),
        ],
      ),
    );
  }
}
