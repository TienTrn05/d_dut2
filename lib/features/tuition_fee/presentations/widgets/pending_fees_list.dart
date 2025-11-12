import 'package:flutter/material.dart';

import '/common/extensions/custom_theme_extension.dart';
import '/common/extensions/font_sizes.dart';

import '../../data/models/pending_tuition_fee.dart';
import '../../utils/tuition_fee_helper.dart';

class PendingFeesList extends StatefulWidget {
  final List<PendingTuitionFee> pendingFees;
  const PendingFeesList(this.pendingFees, {super.key});

  @override
  State<PendingFeesList> createState() => _PendingFeesListState();
}

class _PendingFeesListState extends State<PendingFeesList> {
  bool isShowing = true;

  @override
  Widget build(BuildContext context) {
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
                  "Học phí sinh viên cần nộp",
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
                      child:
                          widget.pendingFees.isNotEmpty
                              ? Column(
                                children:
                                    widget.pendingFees.map((fee) {
                                      return Card(
                                        margin: EdgeInsets.only(
                                          bottom:
                                              fee == widget.pendingFees.last
                                                  ? 0
                                                  : 16,
                                        ),
                                        color: const Color(0xFFFAFAFA),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Đợt ${fee.paymentRound}",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize:
                                                            FontSizes.medium,
                                                      ),
                                                    ),
                                                    Text(
                                                      fee.note ??
                                                          "Không có ghi chú",
                                                      style: TextStyle(
                                                        color:
                                                            context.theme.grey,
                                                        fontSize:
                                                            FontSizes.small,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                TuitionFeeHelper.formatCurrency(
                                                  fee.amount,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: FontSizes.large,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              )
                              : Text(
                                "Không có học phí cần nộp",
                                textAlign: TextAlign.center,
                              ),
                    )
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
