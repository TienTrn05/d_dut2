import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/schedule/presentation/widgets/schedule_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/uos_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SemesterView extends StatefulWidget {
  const SemesterView({super.key});

  @override
  State<SemesterView> createState() => _SemesterViewState();
}

class _SemesterViewState extends State<SemesterView> {
  int selectedSemesterIndex = 0;
  final List<String> semesters = [
    "HỌC KÌ 2, 2025-2026",
    "HỌC KÌ 1, 2025-2026",
    "HỌC KÌ 2, 2024-2025",
    "HỌC KÌ 1, 2024-2025",
    "HỌC KÌ 2, 2023-2024",
  ];
  void _showPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
          // title: Text("Chọn học kì"),
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
                          e,
                          style: const TextStyle(
                              fontSize: FontSizes.medium,
                              fontWeight: FontWeight.bold,
                              height: 1.25),
                        )))
                    .toList(),
              ),
            )
          ]),
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
  Widget build(BuildContext context) {
    final String userType =
        context.read<AuthBloc>().state is AuthUserAuthenticated
            ? (context.read<AuthBloc>().state as AuthUserAuthenticated)
                .userData
                .userType
                .name
            : "Student";
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
                  onTap: _previousSemester,
                  child: Icon(Icons.arrow_back_ios_new_rounded)),
              GestureDetector(
                onTap: () => _showPicker(context),
                child: Text(
                  semesters[selectedSemesterIndex],
                  style: const TextStyle(
                      fontSize: FontSizes.medium, fontWeight: FontWeight.bold),
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
                ScheduleCard(
                  title: userType == "Student" ? "Lịch học" : "Lịch dạy",
                  child: Column(
                    children: [
                      DetailUnitOfStudyItem(
                        idSubject: '1024010.2420.21.11',
                        nameSubject: 'Lập trình di động',
                        credit: 2,
                        weekRange: '31-35',
                        time: 'Thứ 4, 1-3',
                        room: 'F109',
                        teacher: 'Đặng Thiên Bình',
                      ),
                      DetailUnitOfStudyItem(
                        idSubject: '1024010.2420.21.11',
                        nameSubject: 'Công nghệ phần mềm',
                        credit: 2,
                        weekRange: '31-35',
                        time: 'Thứ 4, 1-3',
                        room: 'F109',
                        teacher: 'Võ Đức Hoàng',
                      ),
                      DetailUnitOfStudyItem(
                        idSubject: '1024010.2420.21.11',
                        nameSubject: 'Cấu trúc dữ liệu & giải thuật',
                        credit: 3,
                        weekRange: '31-35',
                        time:
                            'Thứ 2,1-10,XP; Thứ 3,1-10,XP; Thứ 4,1-10,XP; Thứ 5,1-10,XP; Thứ 6,1-10,XP; Thứ 7,1-10,XP',
                        room: 'F109',
                        teacher: 'Đặng Thiên Bình',
                      ),
                      DetailUnitOfStudyItem(
                        idSubject: '1024010.2420.21.11',
                        nameSubject: 'PBL 05: Dự án Công nghệ phần mềm',
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
                ScheduleCard(
                  title: userType == "Student" ? "Lịch thi" : "Lịch coi thi",
                  isExam: true,
                  child: Column(
                    children: [
                      DetailUnitOfStudyItem(
                        idSubject: '1024010.2420.21.11',
                        nameSubject: 'Lập trình di động',
                        time: '7:00, 14/5/2025',
                        room: 'F207',
                        examShiftNo: '2C1',
                        examGroupNo: 'A',
                        isExam: true,
                      ),
                      DetailUnitOfStudyItem(
                        idSubject: '1024010.2420.21.11',
                        nameSubject: 'PBL 05: Dự án Công nghệ phần mềm',
                        isExam: true,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    ));
  }
}
