import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AuthTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool obscureText;
  TextInputType? keyboardType;
  final bool enabled;
  Function(String)? onChanged;
  Function(String)? onSubmitted;

  AuthTextField({
    super.key,
    required this.hintText,
    this.prefixIcon = Icons.person,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        prefixIcon: Icon(
          prefixIcon,
          color: Color.fromRGBO(19, 61, 135, 1),
        ),
        suffixIcon: hintText == "Mật khẩu"
            ? Icon(
                Icons.visibility,
                color: Color.fromRGBO(19, 61, 135, 1),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
