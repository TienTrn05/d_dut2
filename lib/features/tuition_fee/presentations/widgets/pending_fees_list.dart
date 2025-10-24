import 'package:flutter/material.dart';

import '../../../../common/extensions/font_sizes.dart';
import '../../data/models/pending_tuition_fee.dart';
import '../../utils/tuition_fee_helper.dart';

class PendingFeesList extends StatelessWidget {
  final List<PendingTuitionFee> pendingFees;
  const PendingFeesList(this.pendingFees, {super.key});

  @override
  Widget build(BuildContext context) {
    if (pendingFees.isEmpty) {
      return const Text("Không có học phí cần nộp.");
    }
    return Column(
      children:
          pendingFees.map((fee) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: const Color(0xFFF2F4F7),
              elevation: 0,
              child: ListTile(
                title: Text(
                  "Đợt ${fee.paymentRound}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: FontSizes.medium + 1,
                  ),
                ),
                subtitle: Text(fee.note ?? "Không có ghi chú"),
                trailing: Text(
                  TuitionFeeHelper.formatCurrency(fee.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: FontSizes.medium,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
