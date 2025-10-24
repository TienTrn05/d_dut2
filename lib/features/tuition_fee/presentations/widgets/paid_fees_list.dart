import 'package:flutter/material.dart';

import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';
import '../../data/models/paid_tuition_fee.dart';
import '../../utils/tuition_fee_helper.dart';

class PaidFeesList extends StatelessWidget {
  final List<PaidTuitionFee> paidFees;
  const PaidFeesList(this.paidFees, {super.key});

  @override
  Widget build(BuildContext context) {
    if (paidFees.isEmpty) {
      return const Text("Chưa có học phí đã nộp.");
    }
    return Column(
      children:
          paidFees.map((fee) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: const Color(0xFFF2F4F7),
              elevation: 0,
              child: ListTile(
                leading: Icon(
                  Icons.receipt_long,
                  color: context.theme.primaryColor,
                ),
                title: Text(
                  fee.note ?? '---',
                  style: const TextStyle(color: Colors.black, height: 1.1),
                ),
                subtitle: Text("Ngày nộp: ${TuitionFeeHelper.formatDate(fee.paymentDate)}"),
                trailing: Text(
                  TuitionFeeHelper.formatCurrency(fee.amountPaid),
                  style: TextStyle(
                    color: context.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.medium,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
