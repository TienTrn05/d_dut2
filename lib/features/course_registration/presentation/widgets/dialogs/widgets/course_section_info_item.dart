import 'package:flutter/material.dart';

import '../../../../../../common/extensions/font_sizes.dart';

class CourseSectionInfoItem extends StatelessWidget {
  final String title;
  final String content;
  final bool isBoldTitle;
  final bool isBoldContent;

  const CourseSectionInfoItem({
    super.key,
    required this.title,
    required this.content,
    this.isBoldTitle = false,
    this.isBoldContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$title:',
              style: TextStyle(
                fontSize: FontSizes.medium,
                color: Color(0xFF747474),
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              content,
              style: TextStyle(
                fontSize: FontSizes.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
