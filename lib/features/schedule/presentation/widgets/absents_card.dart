import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class AbsentsCard extends StatelessWidget {
  final bool isTeacher;
  final List<String> absentDates;
  const AbsentsCard(
      {super.key, this.isTeacher = true, required this.absentDates});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Các buổi vắng',
                  style: TextStyle(
                      fontSize: FontSizes.extraLarge,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (absentDates.isNotEmpty)
                  Flexible(
                      child: ListView.builder(
                    shrinkWrap: true,
                    // physics: const BouncingScrollPhysics(),
                    itemCount: absentDates.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            absentDates[index],
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: FontSizes.medium),
                          ),
                        ),
                      ),
                    ),
                  ))
                else
                  Text(
                    'Không có buổi vắng nào',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: FontSizes.medium,
                        color: context.theme.grey ?? Colors.grey),
                  )
              ],
            ),
          )),
    );
  }
}
