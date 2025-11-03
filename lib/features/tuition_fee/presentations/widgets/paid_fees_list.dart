import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '/common/extensions/font_sizes.dart';
import '/common/extensions/custom_theme_extension.dart';
import '/gen/assets.gen.dart';

import '../../data/models/paid_tuition_fee.dart';
import '../../utils/tuition_fee_helper.dart';

class PaidFeesList extends StatefulWidget {
  final List<PaidTuitionFee> paidFees;
  const PaidFeesList(this.paidFees, {super.key});

  @override
  State<PaidFeesList> createState() => _PaidFeesListState();
}

class _PaidFeesListState extends State<PaidFeesList> {
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
                  "Học phí đã nộp trong kỳ",
                  style: const TextStyle(
                    fontSize: FontSizes.large,
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
                          widget.paidFees.isNotEmpty
                              ? Column(
                                children:
                                    widget.paidFees.map((fee) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            fee == widget.paidFees.last
                                                ? 16
                                                : 0,
                                          ),
                                          border:
                                              fee != widget.paidFees.last
                                                  ? const Border(
                                                    bottom: BorderSide(
                                                      color: Color(0xFFECECEC),
                                                    ),
                                                  )
                                                  : null,
                                        ),
                                        child: Card(
                                          color: Colors.transparent,
                                          elevation: 0,
                                          margin: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: Container(
                                              width: 32,
                                              height: 32,
                                              padding: EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFB8F8C4),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(999),
                                                ),
                                              ),
                                              child: SvgPicture.asset(
                                                Assets
                                                    .icons
                                                    .svg
                                                    .mingcuteCheckFill,
                                                color: Colors.black,
                                                width: 16,
                                                height: 16,
                                              ),
                                            ),
                                            title: Text(
                                              fee.note ?? '---',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: FontSizes.medium,
                                                color: Colors.black,
                                                height: 1.2,
                                              ),
                                            ),
                                            subtitle: Text(
                                              TuitionFeeHelper.formatDate(
                                                fee.paymentDate,
                                              ),
                                              style: TextStyle(
                                                color: context.theme.grey,
                                                fontSize: FontSizes.small,
                                                height: 1.1,
                                              ),
                                            ),
                                            trailing: Text(
                                              TuitionFeeHelper.formatCurrency(
                                                fee.amountPaid,
                                              ),
                                              style: TextStyle(
                                                color:
                                                    context.theme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: FontSizes.medium,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              )
                              : Text(
                                "Chưa có học phí đã nộp",
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
