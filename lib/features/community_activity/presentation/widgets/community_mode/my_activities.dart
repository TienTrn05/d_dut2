import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/common/widgets/modal/bottom_modal.dart';
import 'package:e_dut/features/community_activity/bloc/all_activities/all_activities_bloc.dart';
import 'package:e_dut/features/community_activity/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MyActivities extends StatefulWidget {
  const MyActivities({super.key});

  @override
  State<MyActivities> createState() => _MyActivitiesState();
}

class _MyActivitiesState extends State<MyActivities> {
  final TextEditingController _searchController = TextEditingController();

  bool _isSortFieldVisible = false;
  bool sortAscending = false;
  List<Map<String, String>> sortFields = [
    {"key": "startDate", "label": "Ngày bắt đầu"},
    {"key": "endDate", "label": "Ngày kết thúc"},
    {"key": "score", "label": "Điểm số"}
  ];
  String selectedSortField = "startDate";

  Set<String> selectedStateFilters = {};
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        BlocBuilder<AllActivitiesBloc, AllActivitiesState>(
          buildWhen: (previous, current) =>
              current is AllActivitiesLoading || current is AllActivitiesLoaded,
          builder: (context, state) {
            if (state is AllActivitiesLoading) {
              return CustomLoadingIndicator.primary();
            }
            return const SizedBox.shrink();
          },
        ),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: FontSizes.medium,
                  color: context.theme.grey,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: "Tìm kiếm ...",
                  hintStyle: TextStyle(
                    fontSize: FontSizes.medium,
                    color: context.theme.grey,
                  ),
                  suffixIcon: IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/svg/tabler_filter-search.svg",
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        context.theme.grey ?? Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => _showFilterModal(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ))
      ],
    ));
  }

  void _showFilterModal(BuildContext context) {
    Set<String> localSelectedState = {...selectedStateFilters};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (modalContext, setModalState) {
          _searchController.addListener(() => setModalState(() {}));

          return BottomModal(
            title: "Sắp xếp và lọc",
            mainAction: () {
              setState(() {
                selectedStateFilters = localSelectedState;
              });

              Navigator.pop(modalContext);
            },
            onClose: () {
              setModalState(() {
                localSelectedState.clear();
              });

              setState(() {
                selectedStateFilters.clear();
              });
            },
            heightFactor: 0.9,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sortField(setModalState),
                  const SizedBox(height: 24),
                  _stateFilter(localSelectedState, setModalState),
                ],
              ),
            ),
          );
        });
      },
    ).whenComplete(() {
      selectedStateFilters = localSelectedState;
    });
  }

  Widget _sortField(StateSetter setModalState) {
    final selectedFieldLabel =
        sortFields.firstWhere((f) => f['key'] == selectedSortField)['label'] ??
            "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sắp xếp",
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _isSortFieldVisible = !_isSortFieldVisible;
                      });
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: context.theme.lightGrey,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedFieldLabel,
                            style: TextStyle(
                              color: context.theme.grey,
                              fontSize: FontSizes.small,
                            ),
                          ),
                          Icon(
                            _isSortFieldVisible
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: context.theme.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isSortFieldVisible)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.theme.lightGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: buildSortFieldButtons(setModalState),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              height: 48,
              child: TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
                  backgroundColor:
                      WidgetStateProperty.all(context.theme.lightGrey),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(const Size(48, 48)),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                onPressed: () {
                  setModalState(() {
                    sortAscending = !sortAscending;
                  });
                },
                child: SvgPicture.asset(
                  sortAscending
                      ? "assets/icons/svg/lucide_sort-asc.svg"
                      : "assets/icons/svg/lucide_sort-desc.svg",
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _stateFilter(
      Set<String> localSelectedState, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trạng thái",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: Constant.activityStatusKeys.map((statusKey) {
            final bool isSelected = localSelectedState.contains(statusKey);
            final style = Constant.activityStatusStyles[statusKey];
            final label = style?.label ?? statusKey;

            return TextButton(
              onPressed: () {
                setModalState(() {
                  if (isSelected) {
                    localSelectedState.remove(statusKey);
                  } else {
                    localSelectedState.add(statusKey);
                  }
                });
              },
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w400, fontSize: FontSizes.small),
                backgroundColor: isSelected
                    ? context.theme.primaryColor
                    : context.theme.lightGrey,
                foregroundColor: isSelected ? Colors.white : context.theme.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  List<Widget> buildSortFieldButtons(StateSetter setModalState) {
    return sortFields.map((field) {
      final isSelected = selectedSortField == field['key'];
      return GestureDetector(
        onTap: () {
          setModalState(() {
            selectedSortField = field['key']!;
            _isSortFieldVisible = false;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.theme.lightBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            field['label'] ?? '',
            style: TextStyle(
              color: context.theme.grey,
              fontSize: FontSizes.small,
            ),
          ),
        ),
      );
    }).toList();
  }
}
