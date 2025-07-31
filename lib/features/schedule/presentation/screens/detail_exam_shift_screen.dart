import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/bloc/uos_detail/uos_detail_bloc.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/student_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/card/uos_info_card.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailExamShiftScreen extends StatefulWidget {
  final String idExamShift;
  final String examShiftName;
  const DetailExamShiftScreen(
      {super.key, required this.idExamShift, required this.examShiftName});

  @override
  State<DetailExamShiftScreen> createState() => _DetailExamShiftScreenState();
}

class _DetailExamShiftScreenState extends State<DetailExamShiftScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _currentPage = 1;
  int _totalPages = 1;

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      final keyword = _searchController.text.trim();

      setState(() {
        _currentPage = 1;
      });

      context.read<UosDetailBloc>().add(
            LoadExamShiftDetail(
              idExamShift: widget.idExamShift,
              keyword: keyword,
              pageNumber: 1,
            ),
          );
    });
  }

  List<Widget> _buildPageButtons() {
    List<Widget> buttons = [];

    void addPageButton(int i) {
      buttons.add(
        InkWell(
          onTap: () {
            if (i != _currentPage) {
              setState(() {
                _currentPage = i;
              });
              context.read<UosDetailBloc>().add(LoadExamShiftDetail(
                    idExamShift: widget.idExamShift,
                    keyword: _searchController.text.trim(),
                    pageNumber: _currentPage,
                  ));
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  i == _currentPage ? context.theme.primaryColor : Colors.white,
              border: Border.all(
                color: i == _currentPage
                    ? context.theme.primaryColor ?? Colors.blue
                    : context.theme.grey ?? Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$i',
              style: TextStyle(
                color: i == _currentPage ? Colors.white : Colors.black,
                fontWeight:
                    i == _currentPage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    void addEllipsis() {
      buttons.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: const Text(
            "...",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (_totalPages <= 5) {
      for (int i = 1; i <= _totalPages; i++) {
        addPageButton(i);
      }
      return buttons;
    }

    // Luôn hiển thị trang đầu tiên
    addPageButton(1);

    // Nếu cần dấu "..." giữa trang đầu và các trang tiếp theo
    if (_currentPage > 3) {
      addEllipsis();
    }

    // Hiển thị current -1, current, current +1 (nếu hợp lệ)
    for (int i = _currentPage - 1; i <= _currentPage + 1; i++) {
      if (i > 1 && i < _totalPages) {
        addPageButton(i);
      }
    }

    // Nếu cần dấu "..." trước trang cuối
    if (_currentPage < _totalPages - 2) {
      addEllipsis();
    }

    // Luôn hiển thị trang cuối
    addPageButton(_totalPages);

    return buttons;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppbar(label: "Thông tin chi tiết ca thi"),
          body: Column(
            children: [
              BlocBuilder<UosDetailBloc, UosDetailState>(
                buildWhen: (previous, current) =>
                    current is UosDetailLoading ||
                    current is ExamShiftDetailLoaded ||
                    current is UosDetailError,
                builder: (context, state) {
                  if (state is UosDetailLoading) {
                    return CustomLoadingIndicator.primary();
                  }
                  return const SizedBox.shrink();
                },
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      spacing: 10,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.examShiftName,
                            style: TextStyle(
                              fontSize: FontSizes.extraLarge,
                              fontWeight: FontWeight.bold,
                              color: context.theme.primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          // height: 32,
                          color: Colors.white,
                          child: TabBar.secondary(
                            labelColor: Colors.white,
                            unselectedLabelColor: context.theme.grey,
                            indicator: BoxDecoration(
                              color: context.theme.primaryColor,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                            dividerColor: context.theme.primaryColor,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 13.0,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            // labelPadding:
                            //     EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            tabs: [
                              Tab(text: "Thông tin"),
                              Tab(text: "Danh sách sinh viên"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Tab 1: Thông tin
                              BlocBuilder<UosDetailBloc, UosDetailState>(
                                buildWhen: (prev, curr) =>
                                    curr is ExamShiftDetailLoaded ||
                                    curr is UosDetailLoading ||
                                    curr is UosDetailError,
                                builder: (context, state) {
                                  if (state is UosDetailLoading) {
                                    return const Center();
                                  } else if (state is ExamShiftDetailLoaded) {
                                    final examShiftDetail =
                                        state.examShiftDetail;

                                    return RefreshIndicator(
                                      color: context.theme.primaryColor,
                                      backgroundColor: Colors.white,
                                      onRefresh: () async {
                                        context.read<UosDetailBloc>().add(
                                              LoadExamShiftDetail(
                                                idExamShift: widget.idExamShift,
                                                keyword: _searchController.text
                                                    .trim(),
                                                pageNumber: 1,
                                              ),
                                            );
                                      },
                                      child: SingleChildScrollView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        child: Column(
                                          children: [
                                            UosInfoCard(
                                              title: 'Thông tin chung',
                                              child: Column(
                                                children: [
                                                  InfoItem(
                                                    field: "Mã ca thi",
                                                    value: examShiftDetail
                                                        .examShift.examCode,
                                                  ),
                                                  InfoItem(
                                                    field: "Thời gian làm bài",
                                                    value: examShiftDetail
                                                                .examShift
                                                                .examDate !=
                                                            null
                                                        ? Functions
                                                            .formatDateTime(
                                                                examShiftDetail
                                                                    .examShift
                                                                    .examDate!)
                                                        : "",
                                                  ),
                                                  InfoItem(
                                                    field: "Phòng",
                                                    value: examShiftDetail
                                                        .examShift.room,
                                                  ),
                                                  InfoItem(
                                                    field: "Xuất",
                                                    value: examShiftDetail
                                                        .examShift.noExamShift,
                                                  ),
                                                  InfoItem(
                                                    field: "Dạng đề",
                                                    value: examShiftDetail
                                                        .examShift.examFormat,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            UosInfoCard(
                                              title: 'Cán bộ coi thi',
                                              child: Column(
                                                children: examShiftDetail
                                                    .examSupervisors
                                                    .asMap()
                                                    .entries
                                                    .map((entry) => InfoItem(
                                                          field:
                                                              "Cán bộ ${entry.key + 1}",
                                                          value:
                                                              "${entry.value.noTeacher} - ${entry.value.teacherName}",
                                                        ))
                                                    .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return Center(
                                      child: Text("Không có dữ liệu ca thi",
                                          style: TextStyle(
                                              color: context.theme.grey ??
                                                  Colors.grey)));
                                },
                              ),

                              // Tab 2: Danh sách sinh viên
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchBarCustom(
                                    controller: _searchController,
                                    onChanged: (_) => _onSearchChanged(),
                                  ),
                                  BlocBuilder<UosDetailBloc, UosDetailState>(
                                    buildWhen: (prev, curr) =>
                                        curr is ExamShiftDetailLoaded ||
                                        curr is UosDetailError,
                                    builder: (context, state) {
                                      if (state is ExamShiftDetailLoaded) {
                                        final listStudents = state.listStudents;
                                        final totalItems = listStudents
                                            .studentsPaged.totalItems;
                                        final pageSize =
                                            listStudents.studentsPaged.pageSize;
                                        _totalPages =
                                            (totalItems / pageSize).ceil();

                                        if (listStudents
                                            .studentsPaged.items.isEmpty) {
                                          return const Center(
                                            child: Text(
                                              'Không có dữ liệu danh sách sinh viên',
                                              style: TextStyle(
                                                fontSize: FontSizes.medium,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                          );
                                        }

                                        return Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10),
                                                child: Text(
                                                  "Sinh viên (${listStudents.studentQuantity})",
                                                  style: TextStyle(
                                                    fontSize: FontSizes.medium,
                                                    color: context.theme.grey,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: RefreshIndicator(
                                                  color: context
                                                      .theme.primaryColor,
                                                  backgroundColor: Colors.white,
                                                  onRefresh: () async {
                                                    context
                                                        .read<UosDetailBloc>()
                                                        .add(
                                                          LoadExamShiftDetail(
                                                            idExamShift: widget
                                                                .idExamShift,
                                                            keyword:
                                                                _searchController
                                                                    .text
                                                                    .trim(),
                                                            pageNumber: 1,
                                                          ),
                                                        );
                                                  },
                                                  child: SingleChildScrollView(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    child: Column(
                                                      children: [
                                                        ListView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemCount:
                                                              listStudents
                                                                  .studentsPaged
                                                                  .items
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final student =
                                                                listStudents
                                                                    .studentsPaged
                                                                    .items[index];
                                                            return StudentItem(
                                                              name: student
                                                                  .studentName,
                                                              mail: student
                                                                  .noStudent,
                                                            );
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children:
                                                              _buildPageButtons(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return const Center(
                                        child: Text(
                                            "Không có dữ liệu danh sách sinh viên"),
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )),
              )
            ],
          )),
    );
  }
}
