import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset(
              "assets/icons/svg/flowbite_search-outline.svg",
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: "Tìm kiếm...",
          hintStyle: TextStyle(
            color: context.theme.grey ?? Colors.grey,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(999),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
      style: TextStyle(fontSize: FontSizes.large),
    );
  }
}
