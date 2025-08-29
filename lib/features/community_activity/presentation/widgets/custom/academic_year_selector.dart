import 'package:card_loading/card_loading.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/community_activity/data/model/academic_year_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AcademicYearSelector extends StatelessWidget {
  final List<AcademicYearModel> yearList;
  final AcademicYearModel currentYear;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onPickerSelected;
  const AcademicYearSelector(
      {super.key,
      required this.yearList,
      required this.currentYear,
      required this.onPrevious,
      required this.onNext,
      required this.onPickerSelected});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = yearList.indexWhere((y) => y.id == currentYear.id);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 24.0,
      children: [
        GestureDetector(
          onTap: onPrevious,
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        Expanded(
          child: InkWell(
            onTap: () => _showPicker(context, selectedIndex),
            borderRadius:
                BorderRadius.circular(4), // bo góc hiệu ứng ripple (nếu cần)
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                    4.0), // tạo vùng chạm lớn hơn, tránh chỉ dính vào text
                child: Center(
                  child: Text(
                    currentYear.name,
                    style: const TextStyle(
                      fontSize: FontSizes.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ),
        ),
        GestureDetector(
          onTap: onNext,
          child: const Icon(Icons.arrow_forward_ios_rounded),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context, int selectedIndex) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 200,
            child: CupertinoPicker(
              backgroundColor: Colors.transparent,
              itemExtent: 52,
              scrollController:
                  FixedExtentScrollController(initialItem: selectedIndex),
              onSelectedItemChanged: onPickerSelected,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withAlpha(30),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              children: yearList
                  .map((e) => Center(
                        child: Text(
                          e.name,
                          style: const TextStyle(
                            fontSize: FontSizes.large,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingAcademicYearSelector extends StatelessWidget {
  const LoadingAcademicYearSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 24.0,
      children: [
        Icon(Icons.arrow_back_ios_new_rounded),
        Expanded(
            child: SizedBox(
          width: double.infinity,
          child: CardLoading(
              height: 20,
              margin: EdgeInsets.only(bottom: 4),
              borderRadius: BorderRadius.circular(4)),
        )),
        Icon(Icons.arrow_forward_ios_rounded),
      ],
    );
  }
}
