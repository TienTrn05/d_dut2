import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:flutter/material.dart';

class HomeroomItem extends StatelessWidget {
  final String name;
  final String numStudent;
  const HomeroomItem({super.key, required this.name, required this.numStudent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.detailHomeRoom);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.25,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "$numStudent sinh viên",
              style: TextStyle(
                fontSize: FontSizes.small,
                fontWeight: FontWeight.normal,
                color: Colors.black,
                height: 1.25,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
