import 'package:auto_route/auto_route.dart';
import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/bloc/uos_detail/uos_detail_bloc.dart';
import 'package:e_dut/features/schedule/data/model/role/student_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/students_exam_shift_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/search_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/student_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/card/uos_info_card.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/utils/getit_utils.dart';
import '../../domain/repository/schedule_repo.dart';

@RoutePage()
class DetailExamShiftScreen extends StatefulWidget {
  final String authToken;
  final String idExamShift;
  final String examShiftName;
  const DetailExamShiftScreen({
    super.key,
    required this.idExamShift,
    required this.examShiftName,
    required this.authToken,
  });

  @override
  State<DetailExamShiftScreen> createState() => _DetailExamShiftScreenState();
}

class _DetailExamShiftScreenState extends State<DetailExamShiftScreen> {
  StudentsExamShiftModel? examShiftWithStudents;
  List<StudentModel> filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchKeyword = '';
  bool _isDataInitialized = false;

  void _onSearchChanged() {
    final keyword = _searchController.text.trim();
    _currentSearchKeyword = keyword; // Store current keyword
    _performSearch();
  }

  List<StudentModel> searchVietnamese(
    List<StudentModel> students,
    String keyword,
  ) {
    if (keyword.isEmpty) return List.from(students);

    final pattern = Functions.buildVietnamesePattern(keyword.toLowerCase());
    final regex = RegExp(pattern, caseSensitive: false);

    return students.where((student) {
      final name = student.studentName.toLowerCase();
      final no = student.noStudent.toLowerCase();

      return regex.hasMatch(name) || regex.hasMatch(no);
    }).toList();
  }

  void _performSearch() {
    if (examShiftWithStudents == null) return;

    setState(() {
      filteredStudents = searchVietnamese(
        examShiftWithStudents!.students,
        _currentSearchKeyword,
      );
    });
  }

  void _initializeStudentsList(StudentsExamShiftModel newData) {
    examShiftWithStudents = newData;
    filteredStudents = searchVietnamese(
      newData.students,
      _currentSearchKeyword,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => UosDetailBloc(getIt.get<ScheduleRepository>())..add(
            LoadExamShiftDetail(
              idExamShift: widget.idExamShift,
              authToken: widget.authToken,
            ),
          ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppbar(label: "Thông tin chi tiết ca thi"),
          body: Column(
            children: [
              BlocBuilder<UosDetailBloc, UosDetailState>(
                buildWhen:
                    (previous, current) =>
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
                        color: Colors.white,
                        child: TabBar.secondary(
                          labelColor: Colors.white,
                          unselectedLabelColor: context.theme.grey,
                          indicator: BoxDecoration(
                            color: context.theme.primaryColor,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
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
                          tabs: [
                            Tab(text: "Thông tin"),
                            Tab(text: "Danh sách sinh viên"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: ClampingScrollPhysics(),
                          children: [
                            // Tab 1: Thông tin
                            BlocBuilder<UosDetailBloc, UosDetailState>(
                              buildWhen:
                                  (prev, curr) =>
                                      curr is ExamShiftDetailLoaded ||
                                      curr is UosDetailLoading ||
                                      curr is UosDetailError,
                              builder: (context, state) {
                                if (state is UosDetailLoading) {
                                  return const Center();
                                } else if (state is ExamShiftDetailLoaded) {
                                  final examShiftDetail = state.examShiftDetail;

                                  return RefreshIndicator(
                                    color: context.theme.primaryColor,
                                    backgroundColor: Colors.white,
                                    onRefresh: () async {
                                      final authState =
                                          context.read<AuthBloc>().state;
                                      final String authToken =
                                          authState is AuthUserAuthenticated
                                              ? authState.accessToken
                                              : '';
                                      context.read<UosDetailBloc>().add(
                                        LoadExamShiftDetail(
                                          idExamShift: widget.idExamShift,
                                          authToken: authToken,
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
                                                  value:
                                                      examShiftDetail
                                                          .examShift
                                                          .examCode,
                                                ),
                                                InfoItem(
                                                  field: "Thời gian làm bài",
                                                  value:
                                                      examShiftDetail
                                                                  .examShift
                                                                  .examDate !=
                                                              null
                                                          ? Functions.formatDateTime(
                                                            examShiftDetail
                                                                .examShift
                                                                .examDate!,
                                                          )
                                                          : "",
                                                ),
                                                InfoItem(
                                                  field: "Phòng",
                                                  value:
                                                      examShiftDetail
                                                          .examShift
                                                          .room,
                                                ),
                                                InfoItem(
                                                  field: "Xuất",
                                                  value:
                                                      examShiftDetail
                                                          .examShift
                                                          .noExamShift,
                                                ),
                                                InfoItem(
                                                  field: "Dạng đề",
                                                  value:
                                                      examShiftDetail
                                                          .examShift
                                                          .examFormat,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          UosInfoCard(
                                            title: 'Cán bộ coi thi',
                                            child: Column(
                                              children:
                                                  examShiftDetail
                                                      .examSupervisors
                                                      .asMap()
                                                      .entries
                                                      .map(
                                                        (entry) => InfoItem(
                                                          field:
                                                              "Cán bộ ${entry.key + 1}",
                                                          value:
                                                              "${entry.value.noTeacher} - ${entry.value.teacherName}",
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return Center(
                                  child: Text(
                                    "Không có dữ liệu ca thi",
                                    style: TextStyle(
                                      color: context.theme.grey ?? Colors.grey,
                                    ),
                                  ),
                                );
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
                                  buildWhen:
                                      (prev, curr) =>
                                          curr is ExamShiftDetailLoaded ||
                                          curr is UosDetailError,
                                  builder: (context, state) {
                                    if (state is ExamShiftDetailLoaded) {
                                      final newData =
                                          state.examShiftWithStudents;

                                      // Only initialize if data changed or not initialized yet
                                      if (!_isDataInitialized ||
                                          examShiftWithStudents != newData) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              _initializeStudentsList(newData);
                                              setState(() {
                                                _isDataInitialized = true;
                                              });
                                            });
                                      }

                                      return Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Text(
                                                "Sinh viên (${examShiftWithStudents?.studentQuantity ?? 0})",
                                                style: TextStyle(
                                                  fontSize: FontSizes.medium,
                                                  color: context.theme.grey,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: RefreshIndicator(
                                                color:
                                                    context.theme.primaryColor,
                                                backgroundColor: Colors.white,
                                                onRefresh: () async {
                                                  final authState =
                                                      context
                                                          .read<AuthBloc>()
                                                          .state;
                                                  final String authToken =
                                                      authState
                                                              is AuthUserAuthenticated
                                                          ? authState
                                                              .accessToken
                                                          : '';
                                                  context
                                                      .read<UosDetailBloc>()
                                                      .add(
                                                        LoadExamShiftDetail(
                                                          idExamShift:
                                                              widget
                                                                  .idExamShift,
                                                          authToken: authToken,
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
                                                            filteredStudents
                                                                .length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          final student =
                                                              filteredStudents[index];

                                                          return StudentItem(
                                                            name:
                                                                student
                                                                    .studentName,
                                                            mail:
                                                                student
                                                                    .noStudent,
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(height: 8),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                          ],
                                        ),
                                      );
                                    }

                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: Text(
                                          'Không có dữ liệu danh sách sinh viên',
                                          style: TextStyle(
                                            fontSize: FontSizes.medium,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
