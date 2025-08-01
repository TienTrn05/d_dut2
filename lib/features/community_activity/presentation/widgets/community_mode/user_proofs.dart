import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart'
    show CustomLoadingIndicator;
import 'package:e_dut/common/widgets/modal/bottom_modal.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/user_proof_status.dart';
import 'package:e_dut/features/community_activity/data/model/academic_year_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/cards/user_proof_card.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/pagination.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/search_text_field.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/custom/academic_year_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProofs extends StatefulWidget {
  const UserProofs({super.key});

  @override
  State<UserProofs> createState() => _UserProofsState();
}

class _UserProofsState extends State<UserProofs> {
  List<UserProofModel> userProofs = [];
  List<AcademicYearModel> _academicYears = [];
  bool _isAcademicYearsLoaded = false;

  int _currentPage = 1;
  int _totalPages = 1;

  int selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool sortAscending = false;
  Set<String> selectedStateFilters = {};
  void _loadAcademicYears() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthUserAuthenticated) {
      final accessToken = authState.accessToken;
      context.read<CommunityActivityBloc>().add(LoadAcademicYears(
            token: accessToken,
          ));
    }
  }

  void _loadProofs(int pageNumber, String academicYearId) {
    if (academicYearId.isEmpty) {
      return;
    }
    final authState = context.read<AuthBloc>().state;
    final Set<String> statusSet = selectedStateFilters.map((e) => e).toSet();
    final String? selectedStatus =
        statusSet.isNotEmpty ? statusSet.join(',') : null;
    if (authState is AuthUserAuthenticated) {
      final keyword = _searchController.text.trim();
      final accessToken = authState.accessToken;
      context.read<CommunityActivityBloc>().add(LoadUserProofs(
          token: accessToken,
          keyword: keyword,
          pageNumber: pageNumber,
          academicYearId: academicYearId,
          status: selectedStatus));
      setState(() {
        _currentPage = pageNumber;
      });
    }
  }

  void _loadProofsWithCurrentYear(int pageNumber) {
    if (_academicYears.isNotEmpty && selectedIndex < _academicYears.length) {
      _loadProofs(pageNumber, _academicYears[selectedIndex].id.toString());
    }
  }

  List<UserProofModel> get filteredProofs {
    final filtered = userProofs;

    filtered.sort((a, b) {
      final aValue = a.userActivity.activity.score;
      final bValue = b.userActivity.activity.score;

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
                current is UserProofsLoaded ||
                current is AcademicYearsLoaded ||
                current is CommunityActivityError,
            builder: (context, state) {
              if (state is CommunityActivityLoading) {
                return CustomLoadingIndicator.primary();
              }
              return const SizedBox.shrink();
            }),
        Expanded(
          child: RefreshIndicator(
            color: context.theme.primaryColor,
            backgroundColor: Colors.white,
            onRefresh: () async {
              final completer = Completer<void>();

              // Listen để biết khi nào refresh hoàn tất
              final subscription =
                  context.read<CommunityActivityBloc>().stream.listen((state) {
                if (state is UserProofsLoaded ||
                    state is CommunityActivityError) {
                  if (!completer.isCompleted) {
                    completer.complete();
                  }
                }
              });

              _loadProofsWithCurrentYear(_currentPage);

              // Đợi cho đến khi có kết quả
              await completer.future.timeout(
                Duration(seconds: 30),
              );

              subscription.cancel();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      kToolbarHeight - // nếu có AppBar
                      100,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocListener<CommunityActivityBloc,
                          CommunityActivityState>(
                        listener: (context, state) {
                          if (state is AcademicYearsLoaded) {
                            // Cập nhật danh sách academic years
                            _academicYears = state.academicYears;
                            final now = DateTime.now();
                            final index = _academicYears.indexWhere((year) =>
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
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _loadProofs(
                                    1,
                                    _academicYears[selectedIndex]
                                        .id
                                        .toString());
                              });
                            }
                          }
                        },
                        child: BlocBuilder<CommunityActivityBloc,
                            CommunityActivityState>(
                          buildWhen: (previous, current) =>
                              current is AcademicYearsLoaded ||
                              current is UserProofsLoaded ||
                              current is CommunityActivityError,
                          builder: (context, state) {
                            if (_academicYears.isNotEmpty) {
                              return _buildAcademicYearSelector(_academicYears);
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SearchTextField(
                          controller: _searchController,
                          onFilterPressed: () => _showFilterModal(context),
                          iconUrl: 'assets/icons/svg/tabler_filter-search.svg',
                          textColor: context.theme.grey ?? Colors.grey),
                      const SizedBox(height: 20),
                      BlocBuilder<CommunityActivityBloc,
                              CommunityActivityState>(
                          buildWhen: (previous, current) =>
                              current is UserProofsLoaded ||
                              current is CommunityActivityError,
                          builder: (context, state) {
                            if (state is UserProofsLoaded) {
                              userProofs = state.userProofs.proofs;
                              return Column(children: [
                                Column(
                                  children: userProofs.isNotEmpty
                                      ? filteredProofs.isNotEmpty
                                          ? filteredProofs
                                              .map((proof) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: UserProofCard(
                                                      nameActivity: proof
                                                          .userActivity
                                                          .activity
                                                          .name,
                                                      score: proof.userActivity
                                                          .activity.score,
                                                      status: proof
                                                          .userActivity.status,
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                Routes
                                                                    .detailUserProof,
                                                                arguments:
                                                                    proof);
                                                      },
                                                    ),
                                                  ))
                                              .toList()
                                          : [
                                              Center(
                                                  child: Text(
                                                      'Không tìm thấy minh chứng nào phù hợp với tiêu chí tìm kiếm.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: context
                                                                  .theme.grey ??
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
                                if (userProofs.isNotEmpty) _buildPageButtons()
                              ]);
                            } else if (state is CommunityActivityError) {
                              return Center(
                                  child: Text(
                                      'Không thể tải dữ liệu minh chứng của tôi',
                                      style: TextStyle(
                                          color: context.theme.grey ??
                                              Colors.grey)));
                            } else {
                              return const SizedBox.shrink();
                            }
                          })
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    ));
  }

  void _onSearchChanged() {
    if (_academicYears.isEmpty) return;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _loadProofsWithCurrentYear(1);
    });
  }

  void _nextAcademicYear(List<AcademicYearModel> yearList) {
    if (selectedIndex < yearList.length - 1) {
      setState(() {
        selectedIndex++;
      });
      _loadProofs(1, yearList[selectedIndex].id);
    }
  }

  void _previousAcademicYear(List<AcademicYearModel> yearList) {
    if (selectedIndex > 0) {
      setState(() {
        selectedIndex--;
      });
      _loadProofs(1, yearList[selectedIndex].id);
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
          _loadProofs(1, yearList[selectedIndex].id);
        }
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
              _loadProofsWithCurrentYear(1);
            },
            onCloseText: "Đặt lại",
            onClose: () {
              setModalState(() {
                localSelectedState.clear();
                sortAscending = false;
              });

              setState(() {
                selectedStateFilters.clear();
              });
              _loadProofsWithCurrentYear(1);
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
    });
  }

  Widget _sortField(StateSetter setModalState) {
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
              child: Container(
                height: 48,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: context.theme.lightGrey,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Điểm số',
                      style: TextStyle(
                        color: context.theme.grey,
                        fontSize: FontSizes.small,
                      ),
                    ),
                  ],
                ),
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
          children: UserProofStatus.keys.map((statusKey) {
            final bool isSelected = localSelectedState.contains(statusKey);
            final style = UserProofStatus.styles[statusKey];
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

  Widget _buildPageButtons() {
    return Pagination(
      currentPage: _currentPage,
      totalPages: _totalPages,
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
        _loadProofsWithCurrentYear(_currentPage);
      },
    );
  }
}
