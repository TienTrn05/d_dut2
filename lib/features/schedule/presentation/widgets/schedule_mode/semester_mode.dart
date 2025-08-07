import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/schedule/bloc/timetable/timetable_bloc.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_exam_shift_pair_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_item_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/card/uos_card.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/uos_item.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../auth/data/model/role_model.dart';

class SemesterMode extends StatefulWidget {
  const SemesterMode({super.key});

  @override
  State<SemesterMode> createState() => _SemesterModeState();
}

class _SemesterModeState extends State<SemesterMode> {
  int selectedIndex = 0;

  void _showPicker(BuildContext context, List<SemesterModel> semesterList) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  backgroundColor: Colors.transparent,
                  itemExtent: 52,
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (int index) {
                    if (selectedIndex != index) {
                      setState(() {
                        selectedIndex = index;
                      });
                      final authState = context.read<AuthBloc>().state;

                      final String userRole = authState is AuthUserAuthenticated
                          ? authState.userData.role.name
                          : '';
                      final String authToken =
                          authState is AuthUserAuthenticated
                              ? authState.accessToken
                              : '';
                      context.read<TimetableBloc>().add(
                            LoadListUOSBySemester(
                                idSemester: semesterList[index].idSemester,
                                selectedIndex: index,
                                isTeacher: userRole == RoleModel.roleTeacher,
                                authToken: authToken),
                          );
                    }
                  },
                  selectionOverlay: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.withAlpha(30),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  children: semesterList
                      .map((e) => Center(
                            child: Text(
                              'Học kỳ ${e.noSemester}, ${e.startYear}-${e.endYear}',
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
            ],
          ),
        ),
      ),
    );
  }

  void _nextSemester(List<SemesterModel> semesterList) {
    if (selectedIndex < semesterList.length - 1) {
      setState(() {
        selectedIndex++;
      });
      final authState = context.read<AuthBloc>().state;

      final String userRole = authState is AuthUserAuthenticated
          ? authState.userData.role.name
          : '';

      final String authToken =
          authState is AuthUserAuthenticated ? authState.accessToken : '';

      context.read<TimetableBloc>().add(
            LoadListUOSBySemester(
                idSemester: semesterList[selectedIndex].idSemester,
                selectedIndex: selectedIndex,
                isTeacher: userRole == RoleModel.roleTeacher,
                authToken: authToken),
          );
    }
  }

  void _previousSemester(List<SemesterModel> semesterList) {
    if (selectedIndex > 0) {
      setState(() {
        selectedIndex--;
      });
      final authState = context.read<AuthBloc>().state;

      final String userRole = authState is AuthUserAuthenticated
          ? authState.userData.role.name
          : '';
      final String authToken =
          authState is AuthUserAuthenticated ? authState.accessToken : '';

      context.read<TimetableBloc>().add(
            LoadListUOSBySemester(
                idSemester: semesterList[selectedIndex].idSemester,
                selectedIndex: selectedIndex,
                isTeacher: userRole == RoleModel.roleTeacher,
                authToken: authToken),
          );
    }
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;

    final String userRole =
        authState is AuthUserAuthenticated ? authState.userData.role.name : '';

    final String authToken =
        authState is AuthUserAuthenticated ? authState.accessToken : '';

    context.read<TimetableBloc>().add(LoadListSemesters(
        isTeacher: userRole == RoleModel.roleTeacher, authToken: authToken));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final String userRole = authState is AuthUserAuthenticated
              ? authState.userData.role.name
              : '';

          final String authToken =
              authState is AuthUserAuthenticated ? authState.accessToken : '';

          return BlocConsumer<TimetableBloc, TimetableState>(
            listener: (context, state) {
              if (state is TimetableDataLoaded) {
                selectedIndex = state.selectedIndex;
              }

              if (state is TimetableError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is TimetableLoading) {
                return CustomLoadingIndicator.primary();
              } else if (state is TimetableDataLoaded) {
                return RefreshIndicator(
                    color: context.theme.primaryColor,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      final completer = Completer<void>();

                      // Listen để biết khi nào refresh hoàn tất
                      final subscription =
                          context.read<TimetableBloc>().stream.listen((state) {
                        if (state is TimetableDataLoaded ||
                            state is TimetableError) {
                          if (!completer.isCompleted) {
                            completer.complete();
                          }
                        }
                      });

                      // Trigger refresh
                      context.read<TimetableBloc>().add(LoadListSemesters(
                          isTeacher: userRole == RoleModel.roleTeacher,
                          authToken: authToken));

                      // Đợi cho đến khi có kết quả
                      await completer.future.timeout(
                        Duration(seconds: 30),
                        onTimeout: () {
                          // Handle timeout nếu cần
                        },
                      );

                      subscription.cancel();
                    },
                    child: _buildContent(state, userRole));
              } else {
                return const Center(
                    child: Text('Không thể tải dữ liệu học kỳ.'));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(TimetableDataLoaded state, String userRole) {
    final semesterList = state.semesters;
    final listUOS = state.listUOS;

    if (selectedIndex >= semesterList.length) {
      selectedIndex = 0;
    }

    final currentSemester = semesterList[selectedIndex];

    return Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSemesterSelector(semesterList, currentSemester),
            const SizedBox(height: 20),
            listUOS.isNotEmpty
                ? _buildUOSContent(listUOS, userRole)
                : Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/svg/undraw_no-data.svg",
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(height: 16),
                          Text("Hiện chưa có dữ liệu cho học kỳ này",
                              style: TextStyle(
                                  fontSize: FontSizes.medium,
                                  fontWeight: FontWeight.w600,
                                  color: context.theme.grey ?? Colors.grey)),
                        ],
                      ),
                    ),
                  ),
          ],
        ));
  }

  Widget _buildSemesterSelector(
      List<SemesterModel> semesterList, SemesterModel currentSemester) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _previousSemester(semesterList),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        GestureDetector(
          onTap: () => _showPicker(context, semesterList),
          child: Text(
            'Học kỳ ${currentSemester.noSemester}, ${currentSemester.startYear}-${currentSemester.endYear}',
            style: const TextStyle(
              fontSize: FontSizes.medium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _nextSemester(semesterList),
          child: const Icon(Icons.arrow_forward_ios_rounded),
        ),
      ],
    );
  }

  Widget _buildUOSContent(List<UosItemModel> listUOS, String userRole) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildStudyScheduleCard(listUOS, userRole),
            const SizedBox(height: 20),
            _buildExamScheduleCard(listUOS, userRole),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyScheduleCard(List<UosItemModel> listUOS, String userRole) {
    return UosCard(
      title: userRole == RoleModel.roleStudent ? "Lịch học" : "Lịch dạy",
      child: Column(
        children: [
          for (int i = 0; i < listUOS.length; i++)
            // Only show UOS items that have valid idUnitOfStudy and noUOS
            if (listUOS[i].idUnitOfStudy?.isNotEmpty == true &&
                listUOS[i].noUOS?.isNotEmpty == true) ...[
              UnitOfStudyItem(
                idUos: listUOS[i].idUnitOfStudy,
                noUOS: listUOS[i].noUOS!,
                nameSubject: listUOS[i].subjectName!,
                credit: listUOS[i].credit,
                timetable: Functions.analyzeStudyShifts(listUOS[i].studyShifts),
                teacher: userRole == RoleModel.roleStudent
                    ? listUOS[i].teacherName
                    : null,
              ),
              if (i < listUOS.length - 1 &&
                  // Check if there are more valid items after current index
                  listUOS.skip(i + 1).any((uos) =>
                      uos.idUnitOfStudy?.isNotEmpty == true &&
                      uos.noUOS?.isNotEmpty == true))
                const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  Widget _buildExamScheduleCard(List<UosItemModel> listUOS, String userRole) {
    final allExamShifts = <UosExamShiftPairModel>[];
    final seenExamShiftIds = <String>{};

    for (final uos in listUOS) {
      if (uos.examShifts.isNotEmpty) {
        for (final examShift in uos.examShifts) {
          final isValidExamShift = examShift.idExamShift.isNotEmpty;
          if (isValidExamShift) {
            final id = examShift.idExamShift;
            if (!seenExamShiftIds.contains(id)) {
              seenExamShiftIds.add(id);
              allExamShifts
                  .add(UosExamShiftPairModel(uos: uos, examShift: examShift));
            }
          }
        }
      }
    }

    allExamShifts.sort((a, b) {
      if (a.examShift.examDate == null && b.examShift.examDate == null)
        return 0;
      if (a.examShift.examDate == null) return 1;
      if (b.examShift.examDate == null) return -1;
      return a.examShift.examDate!.compareTo(b.examShift.examDate!);
    });

    return UosCard(
        title: userRole == RoleModel.roleTeacher ? "Lịch coi thi" : "Lịch thi",
        isExam: true,
        child: allExamShifts.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: allExamShifts.map((pair) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UnitOfStudyItem(
                        idUos: pair.uos.idUnitOfStudy,
                        noUOS: pair.uos.noUOS!,
                        nameSubject: pair.uos.subjectName!,
                        room: pair.uos.subjectName,
                        examShift: pair.examShift,
                        isExam: true,
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              )
            : Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  userRole == RoleModel.roleTeacher
                      ? "Hiện chưa có lịch coi thi"
                      : "Hiện chưa có lịch thi",
                  style: TextStyle(color: Colors.grey),
                ),
              ));
  }
}
