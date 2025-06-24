import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/common/widgets/modal/bottom_modal.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/cards/user_activity_card.dart';
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
  bool _isInitialized = false;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      final keyword = _searchController.text.trim();
      context.read<CommunityActivityBloc>().add(
            LoadUserActivities(
              token: widget.authToken,
              keyword: keyword,
            ),
          );
    });
  }

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

  List<UserActivityModel> get filteredActivities {
    final filtered = userActivites.where((activity) {
      final matchStatus = selectedStateFilters.isEmpty ||
          selectedStateFilters.contains(activity.status);
      return matchStatus;
    }).toList();

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
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bloc = context.read<CommunityActivityBloc>();
        bloc.add(LoadUserActivities(
          token: widget.authToken,
          keyword: _searchController.text.trim(),
        ));
      });
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
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
              current is UserActivitiesLoaded,
          builder: (context, state) {
            if (state is CommunityActivityLoading) {
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
              BlocBuilder<CommunityActivityBloc, CommunityActivityState>(
                buildWhen: (previous, current) =>
                    current is UserActivitiesLoaded ||
                    current is CommunityActivityError,
                builder: (context, state) {
                  if (state is UserActivitiesLoaded) {
                    userActivites = state.activities;
                    return Column(
                      children: filteredActivities
                          .map((activity) => UserActivityCard(
                                userActivity: activity,
                                keyword: _searchController.text.trim(),
                              ))
                          .toList(),
                    );
                  } else if (state is CommunityActivityError) {
                    return const Center(
                        child:
                            Text('Không thể tải dữ liệu hoạt động cộng đồng'));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
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
            mainActionText: "Áp dụng",
            mainAction: () {
              setState(() {
                selectedStateFilters = localSelectedState;
              });

              Navigator.pop(modalContext);
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
