import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class SearchBarCustom extends StatefulWidget {
  const SearchBarCustom({super.key});

  @override
  State<SearchBarCustom> createState() => _SearchBarCustomState();
}

class _SearchBarCustomState extends State<SearchBarCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.theme.lightGrey ?? Color(0xffFAFAFA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: context.theme.grey),
          hintText: "Tìm kiếm...",
          hintStyle: TextStyle(color: context.theme.grey),
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: FontSizes.medium),
      ),
    );
  }
}
