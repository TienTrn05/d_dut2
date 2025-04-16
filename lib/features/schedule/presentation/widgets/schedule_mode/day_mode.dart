import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/bloc/schedule/schedule_bloc.dart';
import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/items/schedule_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/calendar_custom.dart';
import 'package:e_dut/features/schedule/presentation/widgets/schedule_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DayMode extends StatefulWidget {
  const DayMode({super.key});

  @override
  State<DayMode> createState() => _DayModeState();
}

class _DayModeState extends State<DayMode> {
  Set<String> selectedOptions = {'isStudy', 'isExam'};
  List<ScheduleItemModel> schedules = [];
  DateTime selectedDay = DateTime.now();

  void handleSelectionChanged(Set<String> newSelection) {
    setState(() {
      selectedOptions = newSelection;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   context
  //       .read<ScheduleBloc>()
  //       .add(LoadSchedulesByDate(inputDate: selectedDay));
  // }

  @override
  Widget build(BuildContext context) {
    final String userRole =
        context.read<AuthBloc>().state is AuthUserAuthenticated
            ? (context.read<AuthBloc>().state as AuthUserAuthenticated)
                .userData
                .role
                .name
            : RoleModel.roleStudent;
    List<ScheduleItemModel> filteredItems = schedules.where((item) {
      if (selectedOptions.contains('isStudy') && !item.isExam) {
        return true;
      }
      if (selectedOptions.contains('isExam') && item.isExam) {
        return true;
      }
      return false;
    }).toList();
    return BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
      if (state is SchedulesLoaded) {
        setState(() {
          selectedDay = state.selectedDay;
          schedules = state.schedules;
        });
      }
    }, builder: (context, state) {
      return Column(
        children: [
          SizedBox(
            height: 2,
            child: state is ScheduleLoading
                ? LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0D99FF),
                    ),
                    backgroundColor: Colors.transparent,
                    minHeight: 2,
                  )
                : SizedBox.shrink(), // không hiển thị gì nếu không loading
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalendarCustom(),
                SizedBox(height: 20),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 4,
                  children: [
                    Text(
                      "Tuần 32, ${DateFormat('dd/MM/yyyy').format(selectedDay)}",
                      style: TextStyle(
                        fontSize: FontSizes.medium,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    ScheduleToggleButton(
                      studyLabel: userRole == RoleModel.roleStudent
                          ? "Lịch học"
                          : "Lịch dạy",
                      examLabel: userRole == RoleModel.roleStudent
                          ? "Lịch thi"
                          : "Lịch coi thi",
                      onSelectionChanged: handleSelectionChanged,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (state is ScheduleLoading)
                  Center()
                else
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: filteredItems.map((item) {
                      return ScheduleItem(
                        idSubject: item.idUnitOfStudy,
                        subject: item.subjectName,
                        time: item.isExam
                            ? "${DateFormat.Hm().format(item.examTime!)}, xuất ..., nhóm ..."
                            : "${item.startStudyTime!.substring(0, 5)} - ${item.endStudyTime!.substring(0, 5)}",
                        room: item.room,
                        isExam: item.isExam,
                      );
                    }).toList(),
                  ),

                SizedBox(height: 40), // Khoảng cách cuối cùng
              ],
            ),
          ))
        ],
      );
    });
  }
}
