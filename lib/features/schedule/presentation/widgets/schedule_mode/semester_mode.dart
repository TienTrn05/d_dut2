import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/schedule/bloc/timetable/timetable_bloc.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/card/uos_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/loading_progress_bar.dart';
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
                      context.read<TimetableBloc>().add(
                            LoadListUOSBySemester(
                              idSemester: semesterList[index].idSemester,
                              selectedIndex: index,
                            ),
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
      context.read<TimetableBloc>().add(
            LoadListUOSBySemester(
              idSemester: semesterList[selectedIndex].idSemester,
              selectedIndex: selectedIndex,
            ),
          );
    }
  }

  void _previousSemester(List<SemesterModel> semesterList) {
    if (selectedIndex > 0) {
      setState(() {
        selectedIndex--;
      });
      context.read<TimetableBloc>().add(
            LoadListUOSBySemester(
              idSemester: semesterList[selectedIndex].idSemester,
              selectedIndex: selectedIndex,
            ),
          );
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<TimetableBloc>().add(LoadListSemesters());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final String userRole = authState is AuthUserAuthenticated
              ? authState.userData.role.name
              : '';

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
                return _buildContent(state, userRole);
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
                    // padding: EdgeInsets.all(8.0),
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
                  )),
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

  Widget _buildUOSContent(List listUOS, String userRole) {
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

  Widget _buildStudyScheduleCard(List listUOS, String userRole) {
    return UosCard(
      title: userRole == RoleModel.roleStudent ? "Lịch học" : "Lịch dạy",
      child: Column(
        children: [
          for (int i = 0; i < listUOS.length; i++) ...[
            UnitOfStudyItem(
              idUos: listUOS[i].idUnitOfStudy,
              noUOS: listUOS[i].noUOS,
              nameSubject: listUOS[i].subjectName,
              credit: listUOS[i].credit,
              timetable: Functions.analyzeStudyShifts(listUOS[i].studyShifts),
              teacher: listUOS[i].teacherName,
            ),
            if (i < listUOS.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildExamScheduleCard(List listUOS, String userRole) {
    return UosCard(
      title: userRole == RoleModel.roleTeacher ? "Lịch coi thi" : "Lịch thi",
      isExam: true,
      child: listUOS.any((uos) => uos.examShift != null)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < listUOS.length; i++)
                  if (listUOS[i].examShift != null) ...[
                    UnitOfStudyItem(
                      idUos: listUOS[i].idUnitOfStudy,
                      noUOS: listUOS[i].noUOS,
                      nameSubject: listUOS[i].subjectName,
                      room: listUOS[i].subjectName,
                      examShift: listUOS[i].examShift,
                      isExam: true,
                    ),
                    if (i < listUOS.length - 1 &&
                        listUOS.sublist(i + 1).any((e) => e.examShift != null))
                      const SizedBox(height: 10),
                  ],
              ],
            )
          : const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Hiện chưa có lịch thi",
                style: TextStyle(color: Colors.grey),
              ),
            ),
    );
  }
}
