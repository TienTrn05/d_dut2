import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:e_dut/features/schedule/bloc/schedule/schedule_bloc.dart';
import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/schedule_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/calendar_custom.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/schedule_toggle_button.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DayMode extends StatefulWidget {
  const DayMode({super.key});

  @override
  State<DayMode> createState() => _DayModeState();
}

class _DayModeState extends State<DayMode> {
  Set<String> selectedOptions = {'isStudy', 'isExam'};
  List<ScheduleItemModel> schedules = [];
  DateTime selectedDay = DateTime.now();
  String noWeek = "";
  DateTime? baseDateForWeek;
  int? baseWeekNo;

  void handleSelectionChanged(Set<String> newSelection) {
    setState(() {
      selectedOptions = newSelection;
    });
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;

    final String userRole =
        authState is AuthUserAuthenticated ? authState.userData.role.name : '';
    context.read<ScheduleBloc>().add(LoadSchedulesByDate(
          inputDate: selectedDay,
          isTeacher: userRole == RoleModel.roleTeacher,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<ScheduleBloc, ScheduleState>(listener: (context, state) {
            if (state is SchedulesLoaded) {
              setState(() {
                selectedDay = state.selectedDay;
                noWeek = state.noWeek;
                schedules = state.schedules;

                if (baseDateForWeek == null) {
                  baseDateForWeek = state.selectedDay;
                  baseWeekNo =
                      int.tryParse(state.noWeek.replaceAll(RegExp(r'\D'), ''));
                }
              });
            }
          }),
          BlocListener<CalendarBloc, CalendarState>(
              listener: (context, state) {})
        ],
        child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
          final String userRole = authState is AuthUserAuthenticated
              ? authState.userData.role.name
              : '';
          return BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (builder, scheduleState) {
            return BlocBuilder<CalendarBloc, CalendarState>(
                builder: (builder, calendarState) {
              final isLoading = scheduleState is ScheduleLoading ||
                  calendarState is CalendarLoading;

              List<ScheduleItemModel> filteredItems = schedules.where((item) {
                if (selectedOptions.contains('isStudy') && !item.isExam) {
                  return true;
                }
                if (selectedOptions.contains('isExam') && item.isExam) {
                  return true;
                }
                return false;
              }).toList();

              return Column(
                children: [
                  SizedBox(
                    height: 2,
                    child: isLoading
                        ? CustomLoadingIndicator.primary()
                        : SizedBox.shrink(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CalendarCustom(),
                          SizedBox(height: 20),
                          _buildHeaderSection(userRole),
                          SizedBox(height: 10),
                          _buildScheduleContent(scheduleState, filteredItems),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  )
                ],
              );
            });
          });
        }));
  }

  Widget _buildHeaderSection(String userRole) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 4,
      children: [
        (noWeek.isNotEmpty && baseDateForWeek != null && baseWeekNo != null)
            ? Text(
                "Tuần ${Functions.getWeekStringFromBase(selectedDay, noWeek, baseDateForWeek, baseWeekNo)}, ${DateFormat('dd/MM/yyyy').format(selectedDay)}",
                style: TextStyle(
                  fontSize: FontSizes.medium,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              )
            : SizedBox.shrink(),
        ScheduleToggleButton(
          studyLabel:
              userRole == RoleModel.roleTeacher ? "Lịch dạy" : "Lịch học",
          examLabel:
              userRole == RoleModel.roleTeacher ? "Lịch coi thi" : "Lịch thi",
          onSelectionChanged: handleSelectionChanged,
        ),
      ],
    );
  }

  Widget _buildScheduleContent(
      ScheduleState scheduleState, List<ScheduleItemModel> filteredItems) {
    if (scheduleState is ScheduleLoading) {
      return Center();
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Text(
          isSameDay(selectedDay, DateTime.now())
              ? "Hôm nay không có lịch nào"
              : "Không có lịch nào trong ngày này",
          style: TextStyle(
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w600,
            color: context.theme.grey ?? Colors.grey,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredItems.map((item) {
        return ScheduleItem(
          idUos: (item.idUnitOfStudy ?? item.idExamShift)!,
          subject: item.subjectName,
          time: item.isExam
              ? "${DateFormat.Hm().format(item.examTime!)}, xuất ${item.noExamShift}, nhóm ${item.noExamGroup}"
              : "${item.startStudyTime!.substring(0, 5)} - ${item.endStudyTime!.substring(0, 5)}",
          room: item.room,
          isExam: item.isExam,
        );
      }).toList(),
    );
  }
}
