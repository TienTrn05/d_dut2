import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class SearchBarCustom extends StatefulWidget {
  const SearchBarCustom({super.key});

  @override
  State<SearchBarCustom> createState() => _SearchBarCustomState();
}

class _SearchBarCustomState extends State<SearchBarCustom> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon:
            Icon(Icons.search, color: context.theme.grey),
        hintText: "Tìm kiếm...",
        hintStyle: TextStyle(color: context.theme.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color.fromRGBO(245, 245, 245, 1),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
