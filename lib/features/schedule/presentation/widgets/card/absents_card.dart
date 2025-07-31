import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbsentsCard extends StatelessWidget {
  final bool isTeacher;
  final String? name;
  final String? mail;
  final List<DateTime> absentDates;
  const AbsentsCard(
      {super.key,
      this.isTeacher = true,
      this.name,
      this.mail,
      required this.absentDates});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (name?.isNotEmpty == true && mail?.isNotEmpty == true)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name!,
                                style: TextStyle(
                                  fontSize: FontSizes.medium,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true, // Cho phép xuống hàng
                                overflow: TextOverflow.visible, // Không cắt chữ
                              ),
                              Text(
                                mail!,
                                style: TextStyle(
                                  fontSize: FontSizes.small,
                                ),
                                softWrap: true, // Cho phép xuống hàng
                                overflow: TextOverflow.visible, // Không cắt chữ
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // const SizedBox(height: 10),
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
                            DateFormat('dd/MM/yyyy').format(absentDates[index]),
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
                  ),
                const SizedBox(
                  height: 10,
                ),
                Divider(color: context.theme.primaryColor ?? Colors.blue),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Các buổi vắng',
                  style: TextStyle(
                      fontSize: FontSizes.extraLarge,
                      fontWeight: FontWeight.w900,
                      color: context.theme.primaryColor ?? Colors.blue),
                ),
              ],
            ),
          )),
    );
  }
}
