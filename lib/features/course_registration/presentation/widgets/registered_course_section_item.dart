import 'package:flutter/material.dart';

import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';
import '../../data/models/registered_course_section.dart';
import '../../presentation/widgets/buttons/custom_button.dart';

class RegisteredCourseSectionItem extends StatelessWidget {
  final RegisteredCourseSection courseSection;
  final Function()? onDetail;

  const RegisteredCourseSectionItem({
    super.key,
    required this.courseSection,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                courseSection.courseSectionCodeSplited,
                style: TextStyle(
                  fontSize: FontSizes.medium - 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'SL: ${courseSection.registeredCount}/${courseSection.capacity}',
                style: TextStyle(fontSize: FontSizes.medium - 1),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseSection.courseName,
                    style: TextStyle(
                      fontSize: FontSizes.large,
                      fontWeight: FontWeight.bold,
                      color: context.theme.primaryColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    'Thời khóa biểu: ${courseSection.schedule}',
                    style: TextStyle(
                      fontSize: FontSizes.medium - 1,
                      color: Color(0xFF747474),
                      height: 1.5,
                    ),
                  ),
                ],
              )),
              CustomButton(
                text: "Chi tiết",
                onPressed: onDetail,
              ),
            ],
          )
        ],
      ),
    );
  }
}
