import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';
import '/gen/assets.gen.dart';

import '../../data/models/tuition_fee_by_subject.dart';
import '../../utils/tuition_fee_helper.dart';

class SubjectFeesList extends StatefulWidget {
  final List<TuitionFeeBySubject> subjectFees;
  const SubjectFeesList(this.subjectFees, {super.key});

  @override
  State<SubjectFeesList> createState() => _SubjectFeesListState();
}

class _SubjectFeesListState extends State<SubjectFeesList> {
  bool isShowing = true;

  @override
  Widget build(BuildContext context) {
    final totalCredits = widget.subjectFees.fold<int>(
      0,
      (sum, item) => sum + (item.credits),
    );
    final totalTuition = widget.subjectFees.fold<num>(
      0,
      (sum, item) => sum + (item.tuitionFee),
    );
    final totalSubjects = widget.subjectFees.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFECECEC)),
      ),
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              setState(() {
                isShowing = !isShowing;
              });
            },
            minWidth: double.infinity,
            padding: EdgeInsets.only(
              top: 16,
              right: 16,
              left: 16,
              bottom: isShowing ? 10 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(
                    begin: 0,
                    end: isShowing ? 0 : -1,
                  ), // 1 tương đương 90 độ
                  duration: const Duration(milliseconds: 300),
                  builder: (context, double value, child) {
                    return Transform.rotate(
                      angle: value * (3.1415926535 / 2), // 90 độ = pi/2 radian
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded, // Chỉ dùng 1 icon
                        color: Colors.black,
                        size: 28,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  "Học phí lớp học phần",
                  style: const TextStyle(
                    fontSize: FontSizes.medium,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                isShowing
                    ? Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFECECEC)),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          // 🧾 Thẻ tổng hợp
                          Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: const Color(0xFFE7F1F9),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tổng",
                                        style: TextStyle(
                                          fontSize: FontSizes.large,
                                          color: Color(0xFF263238),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _buildSummaryItem(
                                            "Môn học",
                                            totalSubjects.toString(),
                                          ),
                                          const SizedBox(width: 16),
                                          _buildSummaryItem(
                                            "Tín chỉ",
                                            totalCredits.toString(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    TuitionFeeHelper.formatCurrency(
                                      totalTuition,
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF2A74BD),
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSizes.large,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 📚 Danh sách chi tiết từng học phần
                          ...widget.subjectFees.map((fee) {
                            return Card(
                              margin: EdgeInsets.only(
                                bottom: fee == widget.subjectFees.last ? 0 : 16,
                              ),
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Color(0xFFECECEC)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fee.className,
                                            style: const TextStyle(
                                              fontSize: FontSizes.large,
                                              color: Color(0xFF263238),
                                              fontWeight: FontWeight.w600,
                                              height: 1.1,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                '${fee.credits.toString()} tín chỉ',
                                                style: TextStyle(
                                                  fontSize: FontSizes.small,
                                                  color: context.theme.grey,
                                                ),
                                              ),
                                              !fee.classType
                                                  ? Row(
                                                    children: [
                                                      const SizedBox(width: 4),
                                                      SvgPicture.asset(
                                                        Assets
                                                            .icons
                                                            .svg
                                                            .lucideDot,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'CLC',
                                                        style: TextStyle(
                                                          fontSize:
                                                              FontSizes.small,
                                                          color:
                                                              context
                                                                  .theme
                                                                  .grey,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                  : const SizedBox.shrink(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      TuitionFeeHelper.formatCurrency(
                                        fee.tuitionFee,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: FontSizes.medium,
                                        color: Color(0xFF263238),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    )
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(color: Colors.grey, fontSize: FontSizes.small),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF263238),
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.small,
          ),
        ),
      ],
    );
  }
}
