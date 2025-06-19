import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/community_activity/bloc/all_activities/all_activities_bloc.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/cards/activity_card.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/custom/date_picker.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/bottom_modal.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/loading_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AllActivities extends StatefulWidget {
  final String authToken;
  const AllActivities({super.key, required this.authToken});

  @override
  State<AllActivities> createState() => _AllActivitiesState();
}

class _AllActivitiesState extends State<AllActivities> {
  bool _isInitialized = false;
  final TextEditingController _searchController = TextEditingController();

  DateTime? endDateFilter;
  final List<String> scopes = [
    "Tất cả",
    "ĐH Đà Nẵng",
    "ĐH Bách khoa",
    "Khoa",
  ];

  String selectedFilter = "Tất cả";
  Set<String> selectedStateFilters = {};
  DateTime? startDateFilter;
  final List<String> stateFilters = [
    "Đã đăng ký",
    "Mở đăng ký",
    "Hoàn thành",
    "Đã đầy",
    "Hết hạn đăng ký"
  ];

  RangeValues _currentRange = const RangeValues(0, 30);

  final List<String> categoryFilters = [
    "Lĩnh vực công tác xã hội, tình nguyện, nhân đạo, từ thiện",
    "Lĩnh vực các hoạt động mang tính học thuật",
    "Công tác giáo dục",
    "Tổ chức phong trào hành động cách mạng của thanh niên",
    "Các chương trình đồng hành với thanh niên",
    "Công tác quốc tế thanh niên",
    "Công tác xây dựng tổ chức Đoàn, mở rộng mặt trận đoàn kết"
  ];
  Set<String> selectedCategoryFilters = {};
  bool _isCategoryListVisible = false;

  void _showFilterModal(BuildContext context) {
    Set<String> localSelectedState = {...selectedStateFilters};
    Set<String> localSelectedCategory = {...selectedCategoryFilters};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        // Dùng biến local để thay đổi trong modal

        return StatefulBuilder(builder: (modalContext, setModalState) {
          _searchController.addListener(() => setModalState(() {}));

          return BottomModal(
            title: "Bộ lọc",
            mainAction: () {
              // Cập nhật state chính khi xác nhận
              setState(() {
                selectedStateFilters = localSelectedState;
                selectedCategoryFilters = localSelectedCategory;
              });
              Navigator.pop(modalContext);
            },
            onClose: () {
              setModalState(() {
                localSelectedState.clear();
                localSelectedCategory.clear();
                startDateFilter = null;
                endDateFilter = null;
                _currentRange = const RangeValues(0, 30);
                _isCategoryListVisible = false; // giá trị mặc định
              });
            },
            heightFactor: 0.9,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height *
                        0.9, // Giới hạn chiều cao modal
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _stateFilter(localSelectedState, setModalState),
                      const SizedBox(height: 24),
                      _dateFilter(setModalState),
                      const SizedBox(height: 24),
                      _gradeFilter(setModalState),
                      const SizedBox(height: 24),
                      _categoryFilter(localSelectedCategory, setModalState),
                    ],
                  ),
                );
              },
            ),
          );
        });
      },
    ).whenComplete(() {
      selectedStateFilters = localSelectedState;
      selectedCategoryFilters = localSelectedCategory;
      _isCategoryListVisible = false;
    });
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
          children: stateFilters.map((label) {
            final bool isSelected = localSelectedState.contains(label);
            return TextButton(
                onPressed: () {
                  setModalState(() {
                    if (isSelected) {
                      localSelectedState.remove(label);
                    } else {
                      localSelectedState.add(label);
                    }
                  });
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: FontSizes.small),
                  backgroundColor: isSelected
                      ? context.theme.primaryColor
                      : context.theme.lightGrey,
                  foregroundColor:
                      isSelected ? Colors.white : context.theme.grey,
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
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                  ],
                ));
          }).toList(),
        ),
      ],
    );
  }

  void _updateCurrentDate(DateTime newValue, bool isStart) {
    setState(() {
      if (isStart) {
        startDateFilter = newValue;
        if (endDateFilter != null && newValue.isAfter(endDateFilter!)) {
          endDateFilter = null;
        }
      } else {
        endDateFilter = newValue;
      }
    });
  }

  Widget _dateFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ngày diễn ra",
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDateButton(true, setModalState)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SvgPicture.asset(
                "assets/icons/svg/uiw_swap-right.svg",
                width: 13,
                height: 13,
                colorFilter: ColorFilter.mode(
                    context.theme.grey ?? Colors.grey, BlendMode.srcIn),
              ),
            ),
            Expanded(child: _buildDateButton(false, setModalState)),
          ],
        )
      ],
    );
  }

  Widget _buildDateButton(bool isStart, StateSetter setModalState) {
    final DateTime? selectedDate = isStart ? startDateFilter : endDateFilter;
    final String defaultText = isStart ? "Ngày bắt đầu" : "Ngày kết thúc";

    return TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
            fontWeight: FontWeight.w400, fontSize: FontSizes.small),
        backgroundColor: context.theme.lightGrey,
        foregroundColor: context.theme.grey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => DatePicker(
            initDate: selectedDate ??
                (isStart ? DateTime.now() : startDateFilter ?? DateTime.now()),
            onValueChange: (date) =>
                {_updateCurrentDate(date, isStart), setModalState(() {})},
            minSelectableDate: isStart ? null : startDateFilter,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedDate == null
                ? defaultText
                : DateFormat('dd/MM/yyyy').format(selectedDate),
          ),
          Icon(
            Icons.calendar_month,
            color: context.theme.grey,
          )
        ],
      ),
    );
  }

  Widget _gradeFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Điểm",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              "0",
              style: TextStyle(
                fontFamily: GoogleFonts.notoSans().fontFamily,
                fontSize: FontSizes.small,
                color: context.theme.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
                child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: context.theme.primaryColor,
                inactiveTrackColor: context.theme.lightGrey,
                thumbColor: context.theme.primaryColor,
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
                tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 0),
                overlayColor: Colors.grey.shade300,
                showValueIndicator: ShowValueIndicator.always,
                valueIndicatorColor: context.theme.lightGrey,
                valueIndicatorTextStyle: TextStyle(
                    color: context.theme.grey, fontSize: FontSizes.small),
              ),
              child: RangeSlider(
                values: _currentRange,
                min: 0,
                max: 30,
                divisions: 30,
                labels: RangeLabels(
                  _currentRange.start.round().toString(),
                  _currentRange.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setModalState(() {
                    _currentRange = values;
                  });
                },
              ),
            )),
            Text(
              "30",
              style: TextStyle(
                fontFamily: GoogleFonts.notoSans().fontFamily,
                color: context.theme.grey,
                fontSize: FontSizes.small,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _categoryFilter(
      Set<String> localSelectedCategory, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phân loại",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
            onTap: () {
              setModalState(() {
                _isCategoryListVisible = !_isCategoryListVisible;
              });
            },
            child: Container(
                width: double.infinity,
                height: 88,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: context.theme.lightGrey),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 24), // để tránh trùng với icon
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: localSelectedCategory.map((label) {
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: context.theme.lightBlue,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: context.theme.primaryColor,
                                        fontSize: FontSizes.small,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        localSelectedCategory.remove(label);
                                      });
                                    },
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 12,
                                      color: context.theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.theme.grey,
                      ),
                    ),
                  ],
                ))),
        if (_isCategoryListVisible)
          _buildCategoryList(localSelectedCategory, setModalState),
      ],
    );
  }

  Widget _buildCategoryList(
      Set<String> localSelectedCategory, StateSetter setModalState) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: context.theme.lightGrey,
          borderRadius: BorderRadius.circular(4)),
      child: SingleChildScrollView(
        child: Column(
          children:
              buildCategoryFilterButtons(localSelectedCategory, setModalState),
        ),
      ),
    );
  }

  List<Widget> buildCategoryFilterButtons(
      Set<String> localSelectedCategory, StateSetter setModalState) {
    List<Widget> widgets = [];

    for (int i = 0; i < categoryFilters.length; i++) {
      final label = categoryFilters[i];
      final bool isSelected = localSelectedCategory.contains(label);

      widgets.add(
        TextButton(
          onPressed: () {
            setModalState(() {
              if (isSelected) {
                localSelectedCategory.remove(label);
              } else {
                localSelectedCategory.add(label);
              }
            });
          },
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
                fontWeight: FontWeight.w400, fontSize: FontSizes.small),
            backgroundColor:
                isSelected ? context.theme.lightBlue : context.theme.lightGrey,
            foregroundColor:
                isSelected ? context.theme.primaryColor : context.theme.grey,
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, softWrap: true)),
              if (isSelected)
                Icon(Icons.check, color: context.theme.primaryColor, size: 12),
            ],
          ),
        ),
      );

      // Thêm SizedBox nếu không phải phần tử cuối
      if (i != categoryFilters.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_isInitialized) {
  //     _bloc = context.read<AllActivitiesBloc>();
  //     _bloc.add(LoadActivities(
  //       token: widget.authToken,
  //       keyword: _searchController.text.trim(),
  //     ));
  //     _isInitialized = true;
  //   }
  // }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bloc = context.read<AllActivitiesBloc>();
        bloc.add(LoadActivities(
          token: widget.authToken,
          keyword: _searchController.text.trim(),
        ));
      });
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllActivitiesBloc, AllActivitiesState>(
        builder: (context, state) {
      if (state is AllActivitiesLoading) {
        return CustomLoadingIndicator.primary();
      } else if (state is AllActivitiesLoaded) {
        return _buildContent(state.activities);
      } else {
        return const Center(
            child: Text('Không thể tải dữ liệu hoạt động cộng đồng'));
      }
    });
  }

  Widget _buildContent(List<ActivityModel> state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: scopes.map((label) {
                  final bool isSelected = selectedFilter == label;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = label;
                        });
                      },
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        backgroundColor: isSelected
                            ? context.theme.primaryColor
                            : Colors.white,
                        foregroundColor:
                            isSelected ? Colors.white : context.theme.grey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(label),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ...state.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ActivityCard(activity: activity),
                )),
          ],
        ),
      ),
    );
  }
}
