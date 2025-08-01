import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/common/widgets/modal/bottom_modal.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/academic_year_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/cards/user_activity_card.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/pagination.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/search_text_field.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/custom/academic_year_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class UserActivities extends StatefulWidget {
  final String authToken;
  const UserActivities({super.key, required this.authToken});

  @override
  State<UserActivities> createState() => _UserActivitiesState();
}

class _UserActivitiesState extends State<UserActivities> {
  List<UserActivityModel> userActivites = [];
  List<AcademicYearModel> _academicYears = [];
  bool _isAcademicYearsLoaded = false;

  int _currentPage = 1;
  int _totalPages = 1;

  int selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Map<String, String>> sortFields = [
    {"key": "startDate", "label": "Ngày bắt đầu"},
    {"key": "endDate", "label": "Ngày kết thúc"},
    {"key": "score", "label": "Điểm số"}
  ];
  String selectedSortField = "startDate";
  bool _isSortFieldVisible = false;
  bool sortAscending = false;

  Set<String> selectedStateFilters = {};

  dynamic _getSortValue(UserActivityModel activity) {
    switch (selectedSortField) {
      case 'startDate':
        return activity.activity.startDate;
      case 'endDate':
        return activity.activity.endDate;
      case 'score':
        return activity.activity.score;
      default:
        return ''; // fallback
    }
  }

  void _loadAcademicYears() {
    context.read<CommunityActivityBloc>().add(LoadAcademicYears(
          token: widget.authToken,
        ));
  }

  void _loadActivities(int pageNumber, String academicYearId) {
    if (academicYearId.isEmpty) {
      return;
    }

    final keyword = _searchController.text.trim();
    final Set<String> statusSet = selectedStateFilters.map((e) => e).toSet();
    final String? selectedStatus =
        statusSet.isNotEmpty ? statusSet.join(',') : null;

    context.read<CommunityActivityBloc>().add(LoadUserActivities(
        token: widget.authToken,
        keyword: keyword,
        pageNumber: pageNumber,
        academicYearId: academicYearId,
        status: selectedStatus));
    setState(() {
      _currentPage = pageNumber;
    });
  }

  void _loadActivitiesWithCurrentYear(int pageNumber) {
    if (_academicYears.isNotEmpty && selectedIndex < _academicYears.length) {
      _loadActivities(pageNumber, _academicYears[selectedIndex].id.toString());
    }
  }

  List<UserActivityModel> get filteredActivities {
    final filtered = userActivites;

    filtered.sort((a, b) {
      final aValue = _getSortValue(a);
      final bValue = _getSortValue(b);

      if (sortAscending) {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAcademicYearsLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Load academic years đầu tiên
        _loadAcademicYears();
      });
      _isAcademicYearsLoaded = true;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        BlocBuilder<CommunityActivityBloc, CommunityActivityState>(
          buildWhen: (previous, current) =>
              current is CommunityActivityLoading ||
              current is UserActivitiesLoaded ||
              current is AcademicYearsLoaded ||
              current is CommunityActivityError,
          builder: (context, state) {
            if (state is CommunityActivityLoading) {
              return CustomLoadingIndicator.primary();
            }
            return const SizedBox.shrink();
          },
        ),
        Expanded(
            child: RefreshIndicator(
                color: context.theme.primaryColor,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  final completer = Completer<void>();

                  final subscription = context
                      .read<CommunityActivityBloc>()
                      .stream
                      .listen((state) {
                    if (state is UserActivitiesLoaded ||
                        state is CommunityActivityError) {
                      if (!completer.isCompleted) {
                        completer.complete();
                      }
                    }
                  });

                  // Refresh với academic year hiện tại
                  _loadActivitiesWithCurrentYear(_currentPage);

                  await completer.future.timeout(
                    const Duration(seconds: 30),
                    onTimeout: () {},
                  );

                  subscription.cancel();
                },
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            kToolbarHeight -
                            100,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Academic Year Selector - hiển thị khi đã load được academic years
                            BlocListener<CommunityActivityBloc,
                                CommunityActivityState>(
                              listener: (context, state) {
                                if (state is AcademicYearsLoaded) {
                                  // Cập nhật danh sách academic years
                                  _academicYears = state.academicYears;
                                  final now = DateTime.now();
                                  final index = _academicYears.indexWhere(
                                      (year) =>
                                          now.isAfter(year.startDate) &&
                                          now.isBefore(year.endDate));

                                  setState(() {
                                    // Nếu tìm thấy thì dùng index đó, nếu không thì lấy năm học cuối cùng
                                    selectedIndex = index != -1
                                        ? index
                                        : _academicYears.length - 1;
                                  });

                                  // Load activities với academic year đầu tiên
                                  if (_academicYears.isNotEmpty) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _loadActivities(
                                          1,
                                          _academicYears[selectedIndex]
                                              .id
                                              .toString());
                                    });
                                  }
                                } else if (state is UserActivitiesLoaded) {
                                  // Cập nhật academic years nếu có trong response
                                  if (state.academicYears.isNotEmpty) {
                                    _academicYears = state.academicYears;
                                  }

                                  // Cập nhật pagination info
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    final totalItems =
                                        state.pagedActivities.total;
                                    final pageSize =
                                        int.parse(state.pagedActivities.limit);
                                    final total =
                                        (totalItems / pageSize).ceil();
                                    if (_totalPages != total) {
                                      setState(() {
                                        _totalPages = total;
                                      });
                                    }
                                  });
                                }
                              },
                              child: BlocBuilder<CommunityActivityBloc,
                                  CommunityActivityState>(
                                buildWhen: (previous, current) =>
                                    current is AcademicYearsLoaded ||
                                    current is UserActivitiesLoaded ||
                                    current is CommunityActivityError,
                                builder: (context, state) {
                                  if (_academicYears.isNotEmpty) {
                                    return _buildAcademicYearSelector(
                                        _academicYears);
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Search Field - chỉ hoạt động khi đã có academic years
                            SearchTextField(
                              controller: _searchController,
                              onFilterPressed: () => _showFilterModal(context),
                              iconUrl:
                                  'assets/icons/svg/tabler_filter-search.svg',
                              textColor: context.theme.grey ??
                                  const Color.fromARGB(255, 75, 62, 62),
                            ),

                            const SizedBox(height: 20),

                            // Activities List
                            BlocBuilder<CommunityActivityBloc,
                                CommunityActivityState>(
                              buildWhen: (previous, current) =>
                                  current is UserActivitiesLoaded ||
                                  current is CommunityActivityError,
                              builder: (context, state) {
                                if (state is UserActivitiesLoaded) {
                                  userActivites =
                                      state.pagedActivities.activities;
                                  final Set<String> statusSet =
                                      selectedStateFilters
                                          .map((e) => e)
                                          .toSet();
                                  final String? selectedStatus =
                                      statusSet.isNotEmpty
                                          ? statusSet.join(',')
                                          : null;
                                  return Column(children: [
                                    Column(
                                      children: userActivites.isNotEmpty
                                          ? filteredActivities.isNotEmpty
                                              ? filteredActivities
                                                  .map((activity) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10),
                                                        child: UserActivityCard(
                                                          userActivity:
                                                              activity,
                                                          keyword:
                                                              _searchController
                                                                  .text
                                                                  .trim(),
                                                          academicYearId:
                                                              _academicYears[
                                                                      selectedIndex]
                                                                  .id,
                                                          status:
                                                              selectedStatus,
                                                          pageNumber:
                                                              _currentPage,
                                                          onRefresh: () {
                                                            _loadActivitiesWithCurrentYear(
                                                                _currentPage);
                                                          },
                                                        ),
                                                      ))
                                                  .toList()
                                              : [
                                                  Center(
                                                      child: Text(
                                                          'Không tìm thấy hoạt động nào phù hợp với tiêu chí tìm kiếm.',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: context
                                                                      .theme
                                                                      .grey ??
                                                                  Colors.grey)))
                                                ]
                                          : [
                                              Center(
                                                  child: Text(
                                                'Không có dữ liệu',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: context.theme.grey ??
                                                        Colors.grey),
                                              ))
                                            ],
                                    ),
                                    if (userActivites.isNotEmpty)
                                      _buildPageButtons()
                                  ]);
                                } else if (state is CommunityActivityError) {
                                  return const Center(
                                    child: Text(
                                      'Không thể tải dữ liệu hoạt động cộng đồng',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: FontSizes.medium,
                                      ),
                                    ),
                                  );
                                } else if (_academicYears.isEmpty) {
                                  return Center(
                                    child: Text('Đang tải danh sách năm học...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: context.theme.grey ??
                                                Colors.grey)),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ))))
      ],
    ));
  }

  void _onSearchChanged() {
    // Chỉ search khi đã có academic years
    if (_academicYears.isEmpty) return;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _loadActivitiesWithCurrentYear(1);
    });
  }

  Widget _buildPageButtons() {
    return Pagination(
      currentPage: _currentPage,
      totalPages: _totalPages,
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
        _loadActivitiesWithCurrentYear(_currentPage);
      },
    );
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
          return BottomModal(
            title: "Sắp xếp và lọc",
            mainActionText: "Áp dụng",
            mainAction: () {
              setState(() {
                selectedStateFilters = localSelectedState;
              });

              Navigator.pop(modalContext);

              _loadActivitiesWithCurrentYear(1);
            },
            onCloseText: "Đặt lại",
            onClose: () {
              setModalState(() {
                localSelectedState.clear();
                selectedSortField = sortFields.first['key']!;
                sortAscending = false;
                _isSortFieldVisible = false;
              });

              setState(() {
                selectedStateFilters.clear();
              });

              _loadActivitiesWithCurrentYear(1);
            },
            heightFactor: 0.7,
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
      _isSortFieldVisible = false;
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
          children: UserActivityStatus.activityStatusKeys.map((statusKey) {
            final bool isSelected = localSelectedState.contains(statusKey);
            final style = UserActivityStatus.activityStatusStyles[statusKey];
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

  void _nextAcademicYear(List<AcademicYearModel> yearList) {
    if (selectedIndex < yearList.length - 1) {
      setState(() {
        selectedIndex++;
      });
      _loadActivities(1, yearList[selectedIndex].id);
    }
  }

  void _previousAcademicYear(List<AcademicYearModel> yearList) {
    if (selectedIndex > 0) {
      setState(() {
        selectedIndex--;
      });
      _loadActivities(1, yearList[selectedIndex].id);
    }
  }

  Widget _buildAcademicYearSelector(List<AcademicYearModel> yearList) {
    return AcademicYearSelector(
      yearList: yearList,
      currentYear: yearList[selectedIndex],
      onPrevious: () => _previousAcademicYear(yearList),
      onNext: () => _nextAcademicYear(yearList),
      onPickerSelected: (index) {
        if (selectedIndex != index) {
          setState(() {
            selectedIndex = index;
            _currentPage = 1;
          });
          _loadActivities(1, yearList[selectedIndex].id);
        }
      },
    );
  }
}
