import 'package:flutter/material.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

import '../../../data/models/course_section.dart';
import '../../../presentation/widgets/buttons/custom_button.dart';
import 'widgets/course_section_info_item.dart';

class CourseSectionDialog {
  static void showCustomDialog(
    BuildContext context,
    CourseSection courseSection,
    Function()? onRegister,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: context.theme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          courseSection.courseName,
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        minWidth: 16,
                        height: 16,
                        padding: const EdgeInsets.all(0),
                        shape: const CircleBorder(),
                        elevation: 0,
                        highlightElevation: 0,
                        color: Colors.white,
                        child: Icon(
                          Icons.close,
                          color: context.theme.primaryColor,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    CourseSectionInfoItem(
                      title: "Mã lớp h.phần",
                      content: courseSection.courseSectionCodeSplited,
                    ),
                    CourseSectionInfoItem(
                      title: "Số tín chỉ",
                      content: '3',
                    ),
                    CourseSectionInfoItem(
                      title: "Giảng viên",
                      content: courseSection.lecturer.fullName,
                    ),
                    CourseSectionInfoItem(
                      title: "Tuần học",
                      content: courseSection.studyWeeks,
                    ),
                    CourseSectionInfoItem(
                      title: "Thời khóa biểu",
                      content: courseSection.schedule,
                    ),
                    CourseSectionInfoItem(
                      title: "Số lượng",
                      content:
                          "${courseSection.registeredCount}/${courseSection.capacity}",
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          text: "Đăng ký",
                          disabled: !courseSection.canRegister,
                          onPressed: onRegister,
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
