import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/schedule/bloc/timetable/timetable_bloc.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/cards/uos_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/items/uos_item.dart';
import 'package:e_dut/features/schedule/utils/functions.dart';
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
      builder: (_) => CupertinoActionSheet(
        actions: [
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              backgroundColor: Colors.white,
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
                          idSemester: semesterList[selectedIndex].idSemester,
                          selectedIndex: selectedIndex,
                        ),
                      );
                }
              },
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                background: Colors.lightBlue.withAlpha(30),
              ),
              children: semesterList
                  .map((e) => Center(
                        child: Text(
                          'Học kỳ ${e.noSemester}, ${e.startYear}-${e.endYear}',
                          style: const TextStyle(
                            fontSize: FontSizes.medium,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          )
        ],
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
    final String userRole =
        context.read<AuthBloc>().state is AuthUserAuthenticated
            ? (context.read<AuthBloc>().state as AuthUserAuthenticated)
                .userData
                .role
                .name
            : RoleModel.roleStudent;

    return SafeArea(
      child: BlocConsumer<TimetableBloc, TimetableState>(
        //BlocConsumer: dùng bloc đã được cấp từ trước để listen + build UI -> không tạo bloc mới
        listener: (context, state) {
          if (state is TimetableDataLoaded) {
            // Nếu muốn cập nhật selectedIndex ở đây (ví dụ từ event), bạn có thể gán vào biến trong State
            // hoặc cập nhật setState nếu cần render gì đó nhẹ ở ngoài build
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
            return LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF0D99FF),
              ),
              backgroundColor: Colors.transparent,
              minHeight: 2,
            );
          } else if (state is TimetableDataLoaded) {
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
                    Row(
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
                    ),
                    const SizedBox(height: 20),
                    listUOS.isNotEmpty
                        ? Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  UosCard(
                                    title: userRole == RoleModel.roleStudent
                                        ? "Lịch học"
                                        : "Lịch dạy",
                                    child: Column(
                                      children: listUOS
                                          .map((uos) => UnitOfStudyItem(
                                                idUnitOfStudy:
                                                    uos.idUnitOfStudy,
                                                noUOS: uos.noUOS,
                                                nameSubject: uos.subjectName,
                                                credit: uos.credit,
                                                timetable: Functions
                                                    .analyzeStudyShifts(
                                                        uos.studyShifts),

                                                // timetable:
                                                //     Functions.analyzeStudyShifts([
                                                //   StudyShiftModel(
                                                //       dayOfWeek: 3,
                                                //       startPeriod: 1,
                                                //       endPeriod: 3,
                                                //       startWeek: 1,
                                                //       endWeek: 9,
                                                //       room: "E201A"),
                                                //   StudyShiftModel(
                                                //       dayOfWeek: 3,
                                                //       startPeriod: 1,
                                                //       endPeriod: 3,
                                                //       startWeek: 16,
                                                //       endWeek: 32,
                                                //       room: "E201A"),
                                                // ]),

                                                // timetable:
                                                //     Functions.analyzeStudyShifts([
                                                //   StudyShiftModel(
                                                //       dayOfWeek: 1,
                                                //       startPeriod: 1,
                                                //       endPeriod: 3,
                                                //       startWeek: 3,
                                                //       endWeek: 18,
                                                //       room: "E201A"),
                                                //   StudyShiftModel(
                                                //       dayOfWeek: 2,
                                                //       startPeriod: 1,
                                                //       endPeriod: 3,
                                                //       startWeek: 3,
                                                //       endWeek: 19,
                                                //       room: "E201A"),
                                                //   StudyShiftModel(
                                                //       dayOfWeek: 3,
                                                //       startPeriod: 1,
                                                //       endPeriod: 3,
                                                //       startWeek: 3,
                                                //       endWeek: 19,
                                                //       room: "E201A"),
                                                // ]),
                                                teacher: uos.teacherName,
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  UosCard(
                                    title: userRole == RoleModel.roleStudent
                                        ? "Lịch thi"
                                        : "Lịch coi thi",
                                    isExam: true,
                                    child: listUOS.any(
                                            (uos) => uos.examShifts.isNotEmpty)
                                        ? Column(
                                            children: listUOS
                                                .where((uos) =>
                                                    uos.examShifts.isNotEmpty)
                                                .map((uos) => UnitOfStudyItem(
                                                      idUnitOfStudy:
                                                          uos.idUnitOfStudy,
                                                      noUOS: uos.noUOS,
                                                      nameSubject:
                                                          uos.subjectName,
                                                      room: uos.subjectName,
                                                      examShifts:
                                                          uos.examShifts,
                                                      isExam: true,
                                                    ))
                                                .toList(),
                                          )
                                        : const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Hiện chưa có lịch thi",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          )
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
                                Text("Hiện chưa có học phần nào",
                                    style: TextStyle(
                                        fontSize: FontSizes.medium,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            context.theme.grey ?? Colors.grey)),
                              ],
                            ),
                          )),
                  ],
                ));
          } else {
            return const Center(child: Text('Không thể tải dữ liệu học kỳ.'));
          }
        },
      ),
    );
  }
}
