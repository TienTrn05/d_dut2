import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/schedule/bloc/timetable/timetable_bloc.dart';
import 'package:e_dut/features/schedule/data/model/semester_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/cards/uos_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/items/uos_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/data/model/role_model.dart';

class SemesterMode extends StatefulWidget {
  const SemesterMode({super.key});

  @override
  State<SemesterMode> createState() => _SemesterModeState();
}

class _SemesterModeState extends State<SemesterMode> {
  int selectedSemesterIndex = 0;
  final List<SemesterModel> semesters = [];

  void _showPicker(BuildContext context, List<SemesterModel> semesters) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 52,
              scrollController: FixedExtentScrollController(
                  initialItem: selectedSemesterIndex),
              onSelectedItemChanged: (int index) {
                if (selectedSemesterIndex != index) {
                  setState(() {
                    selectedSemesterIndex = index;
                  });
                }
              },
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                background: Colors.lightBlue.withAlpha(30),
              ),
              children: semesters
                  .map((e) => Center(
                          child: Text(
                        'Học kỳ ${e.noSemester}, ${e.startYear}-${e.endYear}',
                        style: const TextStyle(
                            fontSize: FontSizes.medium,
                            fontWeight: FontWeight.bold,
                            height: 1.25),
                      )))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  void _previousSemester() {
    if (selectedSemesterIndex < semesters.length - 1) {
      setState(() {
        selectedSemesterIndex++;
      });
    }
  }

  void _nextSemester() {
    if (selectedSemesterIndex > 0) {
      setState(() {
        selectedSemesterIndex--;
      });
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
        child: Padding(
            padding: EdgeInsets.all(24),
            child: BlocBuilder<TimetableBloc, TimetableState>(
                builder: (context, state) {
              if (state is TimetableLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SemesterListLoaded) {
                final semesters = state.semesters;
                if (selectedSemesterIndex >= semesters.length) {
                  selectedSemesterIndex = 0;
                }
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GestureDetector(
                            onTap: _previousSemester,
                            child: Icon(Icons.arrow_back_ios_new_rounded)),
                        GestureDetector(
                          onTap: () => _showPicker(context, semesters),
                          child: Text(
                            'Học kỳ ${semesters[selectedSemesterIndex].noSemester}, ${semesters[selectedSemesterIndex].startYear}-${semesters[selectedSemesterIndex].endYear}',
                            style: const TextStyle(
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                            onTap: _nextSemester,
                            child: Icon(Icons.arrow_forward_ios_rounded)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          UosCard(
                            title: userRole == RoleModel.roleStudent
                                ? "Lịch học"
                                : "Lịch dạy",
                            child: Column(
                              children: [
                                UnitOfStudyItem(
                                  idSubject: '1024010.2420.21.11',
                                  nameSubject: 'Lập trình di động',
                                  credit: 2,
                                  weekRange: '31-35',
                                  time: 'Thứ 4, 1-3',
                                  room: 'F109',
                                  teacher: 'Đặng Thiên Bình',
                                ),
                                UnitOfStudyItem(
                                  idSubject: '1024010.2420.21.11',
                                  nameSubject: 'Công nghệ phần mềm',
                                  credit: 2,
                                  weekRange: '31-35',
                                  time: 'Thứ 4, 1-3',
                                  room: 'F109',
                                  teacher: 'Võ Đức Hoàng',
                                ),
                                UnitOfStudyItem(
                                  idSubject: '1024010.2420.21.11',
                                  nameSubject: 'Cấu trúc dữ liệu & giải thuật',
                                  credit: 3,
                                  weekRange: '31-35',
                                  time:
                                      'Thứ 2,1-10,XP; Thứ 3,1-10,XP; Thứ 4,1-10,XP; Thứ 5,1-10,XP; Thứ 6,1-10,XP; Thứ 7,1-10,XP',
                                  room: 'F109',
                                  teacher: 'Đặng Thiên Bình',
                                ),
                                UnitOfStudyItem(
                                  idSubject: '1024010.2420.21.11',
                                  nameSubject:
                                      'PBL 05: Dự án Công nghệ phần mềm',
                                  credit: 2,
                                  weekRange: '31-35',
                                  time: 'Thứ 4, 1-3',
                                  room: 'F109',
                                  teacher: 'Mai Văn Hà',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          UosCard(
                            title: userRole == RoleModel.roleStudent
                                ? "Lịch thi"
                                : "Lịch coi thi",
                            isExam: true,
                            child: Column(
                              children: [
                                UnitOfStudyItem(
                                  idSubject: '1024010.2420.21.11',
                                  nameSubject: 'Lập trình di động',
                                  time: '7:00, 14/5/2025',
                                  room: 'F207',
                                  examShiftNo: '2C1',
                                  examGroupNo: 'A',
                                  isExam: true,
                                ),
                                UnitOfStudyItem(
                                  idSubject: '1024010.2420.21.11',
                                  nameSubject:
                                      'PBL 05: Dự án Công nghệ phần mềm',
                                  isExam: true,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ))
                  ],
                );
              } else {
                return const Center(
                    child: Text('Không thể tải dữ liệu học kỳ.'));
              }
            })));
  }
}
