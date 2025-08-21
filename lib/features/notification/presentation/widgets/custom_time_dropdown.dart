import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTimeDropdown extends StatefulWidget {
  const CustomTimeDropdown({super.key});

  @override
  State<CustomTimeDropdown> createState() => _CustomTimeDropdownState();
}

class _CustomTimeDropdownState extends State<CustomTimeDropdown> {
  final List<String> _options = [
    '24 giờ',
    '12 giờ',
    '1 giờ',
    '30 phút',
    '15 phút',
  ];
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = '30 phút';
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      elevation: 2,
      borderRadius: BorderRadius.circular(8.0),
      color: context.theme.lightBlue,
      offset: const Offset(0, 48),
      menuPadding: EdgeInsets.all(8),
      onSelected: (String value) {
        setState(() {
          _selectedValue = value;
        });
      },
      style: ButtonStyle(
        enableFeedback: false,
      ),
      itemBuilder: (BuildContext context) {
        return _options.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Center(
              child: Text(
                choice,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              "assets/icons/svg/solar_bell-bold.svg",
              width: 18,
              height: 18,
              colorFilter:
                  ColorFilter.mode(context.theme.grey!, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              'Trước',
              style: TextStyle(
                color: context.theme.grey,
                fontSize: 16,
              ),
            ),
            Container(
              height: 20,
              width: 1,
              color: context.theme.grey,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            Text(
              _selectedValue,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
      ),
    );
  }
}