import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/schedule_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/calendar_month.dart';
import 'package:e_dut/features/schedule/presentation/widgets/selection_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final List<Map<String, dynamic>> scheduleItems = [
  {
    'idSubject': '1024010.2420.21.12',
    'subject': 'Lập trình di động',
    'time': '7:00, xuất 2C1, nhóm A',
    'room': 'F109',
    'isExam': true,
  },
  {
    'idSubject': '1024010.2420.21.13',
    'subject': 'Hệ điều hành',
    'time': '9:00 - 11:50',
    'room': 'F207',
    'isExam': false,
  },
  {
    'idSubject': '1024010.2420.21.13',
    'subject': 'Hệ điều hành',
    'time': '9:00 - 11:50',
    'room': 'F207',
    'isExam': true,
  },
  {
    'idSubject': '1024010.2420.21.13',
    'subject': 'Hệ điều hành',
    'time': '9:00 - 11:50',
    'room': 'F207',
    'isExam': false,
  },
  {
    'idSubject': '1024010.2420.21.13',
    'subject': 'Hệ điều hành',
    'time': '9:00 - 11:50',
    'room': 'F207',
    'isExam': false,
  },
];

class DayView extends StatefulWidget {
  const DayView({super.key});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  Set<String> selectedOptions = {'isStudy', 'isExam'};

  void handleSelectionChanged(Set<String> newSelection) {
    setState(() {
      selectedOptions = newSelection;
    });
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
    // debugPrint("userType: $userType");
    List<Map<String, dynamic>> filteredItems = scheduleItems.where((item) {
      if (selectedOptions.contains('isStudy') && !item['isExam']) {
        return true;
      }
      if (selectedOptions.contains('isExam') && item['isExam']) {
        return true;
      }
      return false;
    }).toList();
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalendarCustom(),
          SizedBox(height: 20),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'Tuần 32, 22/01/2025',
                style: TextStyle(
                  fontSize: FontSizes.medium,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              SelectionButton(
                studyLabel: userRole == RoleModel.roleStudent ? "Lịch học" : "Lịch dạy",
                examLabel: userRole == RoleModel.roleStudent ? "Lịch thi" : "Lịch coi thi",
                onSelectionChanged: handleSelectionChanged,
              ),
            ],
          ),
          SizedBox(height: 10),

          // Danh sách các ScheduleItem
          if (filteredItems.isEmpty)
            Center(
              child: Text("Hiện không có lịch nào",
                  style: TextStyle(
                      fontSize: FontSizes.medium,
                      fontWeight: FontWeight.w600,
                      color: context.theme.grey ?? Colors.grey)),
            )
          else
            Column(
              children: filteredItems.map((item) {
                return ScheduleItem(
                  idSubject: item['idSubject'],
                  subject: item['subject'],
                  time: item['time'],
                  room: item['room'],
                  isExam: item['isExam'],
                );
              }).toList(),
            ),

          SizedBox(height: 40), // Khoảng cách cuối cùng
        ],
      ),
    );
  }
}
