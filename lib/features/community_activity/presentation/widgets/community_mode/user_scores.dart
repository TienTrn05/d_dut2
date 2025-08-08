import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/activity_icon_path.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/academic_year_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_proof_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/cards/user_proof_card.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/search_text_field.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/custom/academic_year_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class UserScores extends StatefulWidget {
  const UserScores({super.key});

  @override
  State<UserScores> createState() => _UserScoresState();
}

class _UserScoresState extends State<UserScores> {
  List<UserProofModel> userScores = [];
  List<AcademicYearModel> _academicYears = [];

  bool _isAcademicYearsLoaded = false;

  int selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool sortAscending = false;
  void _loadAcademicYears() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthUserAuthenticated) {
      final accessToken = authState.accessToken;
      context.read<CommunityActivityBloc>().add(LoadAcademicYears(
            token: accessToken,
          ));
    }
  }

  void _loadScores(String academicYearId) {
    if (academicYearId.isEmpty) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUserAuthenticated) {
      final keyword = _searchController.text.trim();
      final accessToken = authState.accessToken;
      context.read<CommunityActivityBloc>().add(LoadUserScores(
            token: accessToken,
            keyword: keyword,
            academicYearId: academicYearId,
          ));
    }
  }

  void _loadScoresWithCurrentYear() {
    if (_academicYears.isNotEmpty && selectedIndex < _academicYears.length) {
      _loadScores(_academicYears[selectedIndex].id.toString());
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  List<UserProofModel> get filteredScores {
    final filtered = userScores;

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
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        BlocBuilder<CommunityActivityBloc, CommunityActivityState>(
            buildWhen: (previous, current) =>
                current is CommunityActivityLoading ||
                current is UserScoresLoaded ||
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
                if (state is UserScoresLoaded ||
                    state is CommunityActivityError) {
                  if (!completer.isCompleted) {
                    completer.complete();
                  }
                }
              });

              _loadScoresWithCurrentYear();

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
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _loadScores(_academicYears[selectedIndex]
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
                                current is UserScoresLoaded ||
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
                        SearchTextField(
                            controller: _searchController,
                            onFilterPressed: () {
                              setState(() {
                                sortAscending = !sortAscending;
                              });
                            },
                            iconUrl: sortAscending
                                ? 'assets/icons/svg/lucide_sort-asc.svg'
                                : 'assets/icons/svg/lucide_sort-desc.svg',
                            textColor: context.theme.grey ?? Colors.grey),
                        const SizedBox(height: 20),
                        BlocBuilder<CommunityActivityBloc,
                                CommunityActivityState>(
                            buildWhen: (previous, current) =>
                                current is UserScoresLoaded ||
                                current is CommunityActivityError,
                            builder: (context, state) {
                              if (state is UserScoresLoaded) {
                                userScores = state.userScores
                                    .where((proof) =>
                                        proof.userActivity.status ==
                                        UserActivityStatus.approved)
                                    .toList();
                                final totalScore = userScores.fold<int>(
                                  0,
                                  (sum, proof) =>
                                      sum + proof.userActivity.activity.score,
                                );

                                return Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.only(
                                          bottom: 4, right: 16),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: context.theme.grey ??
                                                      Colors.grey))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tổng điểm',
                                            style: TextStyle(
                                                fontSize: FontSizes.medium,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                ActivityIconPath.score,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Color(0XFFFFFF01),
                                                  BlendMode.srcIn,
                                                ),
                                                width: 13,
                                                height: 13,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                totalScore.toString(),
                                                style: TextStyle(
                                                    fontSize: FontSizes.medium,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: userScores.isNotEmpty
                                          ? filteredScores
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
                                                    ),
                                                  ))
                                              .toList()
                                          : [
                                              Center(
                                                  child: Text(
                                                      'Không có dữ liệu',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: context
                                                                  .theme.grey ??
                                                              Colors.grey)))
                                            ],
                                    )
                                  ],
                                );
                              } else if (state is CommunityActivityError) {
                                return Center(
                                    child: Text(
                                        'Không thể tải dữ liệu điểm của tôi',
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
                )),
          ),
        )
      ],
    ));
  }

  void _onSearchChanged() {
    if (_academicYears.isEmpty) return;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _loadScoresWithCurrentYear();
    });
  }

  void _nextAcademicYear(List<AcademicYearModel> yearList) {
    if (selectedIndex < yearList.length - 1) {
      setState(() {
        selectedIndex++;
      });
      _loadScores(yearList[selectedIndex].id);
    }
  }

  void _previousAcademicYear(List<AcademicYearModel> yearList) {
    if (selectedIndex > 0) {
      setState(() {
        selectedIndex--;
      });
      _loadScores(yearList[selectedIndex].id);
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
          });
          _loadScores(yearList[selectedIndex].id);
        }
      },
    );
  }
}
