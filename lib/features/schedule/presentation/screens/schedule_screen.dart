import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:e_dut/features/schedule/bloc/schedule/schedule_bloc.dart';
import 'package:e_dut/features/schedule/bloc/timetable/timetable_bloc.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:e_dut/features/schedule/presentation/widgets/schedule_mode/day_mode.dart';
import 'package:e_dut/features/schedule/presentation/widgets/schedule_mode/semester_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isDayView = true;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => TimetableBloc(getIt.get<ScheduleRepository>())),
          BlocProvider(
              create: (_) => CalendarBloc(getIt.get<ScheduleRepository>())),
          BlocProvider(
              create: (_) => ScheduleBloc(getIt.get<ScheduleRepository>()))
        ],
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppbar(label: "Thời khóa biểu"),
          body: _isDayView ? const DayMode() : const SemesterMode(),
          floatingActionButton: Builder(
            builder: (context) => Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(2, 5),
                )
              ]),
              child: FloatingActionButton(
                elevation: 0,
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                backgroundColor: context.theme.primaryColor,
                shape: const CircleBorder(),
                child: const Icon(Icons.menu_rounded, color: Colors.white),
              ),
            ),
          ),
          endDrawer: Drawer(
              backgroundColor: Colors.white,
              child: Padding(
                padding:
                    EdgeInsets.only(left: 18, right: 18, top: 48, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Thời khóa biểu',
                        style: TextStyle(
                          fontSize: FontSizes.large,
                          height: 1,
                          fontWeight: FontWeight.bold,
                          color: context.theme.primaryColor ?? Colors.blue,
                        ),
                      ),
                    ),
                    Divider(color: context.theme.primaryColor),
                    SizedBox(height: 10),
                    _buildMenuItem(
                      'Theo học kì',
                      isSelected: !_isDayView,
                      onPressed: () {
                        setState(() {
                          _isDayView = false;
                        });
                        Navigator.pop(context); // Đóng drawer
                      },
                      context: context,
                    ),
                    SizedBox(height: 10),
                    _buildMenuItem(
                      'Theo ngày',
                      isSelected: _isDayView,
                      onPressed: () {
                        setState(() {
                          _isDayView = true;
                        });
                        Navigator.pop(context); // Đóng drawer
                      },
                      context: context,
                    ),
                  ],
                ),
              )),
        ));
  }

  Widget _buildMenuItem(String title,
      {bool isSelected = false,
      VoidCallback? onPressed,
      required BuildContext context}) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? context.theme.primaryColor ?? Colors.blue
                : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isSelected ? 2 : 0,
            padding: EdgeInsets.all(16)),
        child: Row(
          children: [
            SvgPicture.asset(
              title == "Theo học kì"
                  ? "assets/icons/svg/mdi_timeline-check-outline.svg"
                  : "assets/icons/svg/system-uicons_calendar-date.svg",
              colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : Colors.black, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            SizedBox(width: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                    fontSize: FontSizes.medium,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600),
              ),
            ),
          ],
        ));
  }
}
