import 'package:flutter/material.dart';

import '../../../../common/extensions/font_sizes.dart';
import '../../data/models/tuition_fee_by_subject.dart';
import '../../utils/tuition_fee_helper.dart';

class SubjectFeesList extends StatelessWidget {
  final List<TuitionFeeBySubject> subjectFees;
  const SubjectFeesList(this.subjectFees, {super.key});

  @override
  Widget build(BuildContext context) {
    if (subjectFees.isEmpty) {
      return const Text("Không có dữ liệu học phí theo lớp học phần.");
    }

    // 🧮 Tính tổng
    final totalCredits = subjectFees.fold<int>(
      0,
      (sum, item) => sum + (item.credits),
    );
    final totalTuition = subjectFees.fold<num>(
      0,
      (sum, item) => sum + (item.tuitionFee),
    );
    final totalSubjects = subjectFees.length;

    return Column(
      children: [
        // 🧾 Thẻ tổng hợp
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF2A74BD),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tổng học phí",
                      style: TextStyle(
                        fontSize: FontSizes.large,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildSummaryItem("Môn học", totalSubjects.toString()),
                        const SizedBox(width: 16),
                        _buildSummaryItem("Tín chỉ", totalCredits.toString()),
                      ],
                    ),
                  ],
                ),
                Text(
                  TuitionFeeHelper.formatCurrency(totalTuition),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.medium,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 📚 Danh sách chi tiết từng học phần
        ...subjectFees.map((fee) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: const Color(0xFFF2F4F7),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fee.className,
                          style: const TextStyle(
                            fontSize: FontSizes.large,
                            color: Color(0xFF2A74BD),
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tín chỉ',
                                style: TextStyle(
                                  fontSize: FontSizes.small - 1,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'CLC',
                                style: TextStyle(
                                  fontSize: FontSizes.small - 1,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fee.credits.toString(),
                                style: const TextStyle(
                                  fontSize: FontSizes.small + 1,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                fee.classType ? "" : "✓",
                                style: const TextStyle(
                                  fontSize: FontSizes.small + 1,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    TuitionFeeHelper.formatCurrency(fee.tuitionFee),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSizes.small + 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: FontSizes.small,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.small + 1,
          ),
        ),
      ],
    );
  }
}
