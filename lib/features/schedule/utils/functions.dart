import 'package:e_dut/features/schedule/data/model/schedule_item_model.dart';
import 'package:e_dut/features/schedule/data/model/study_shift_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Functions {
  static String getDayOfWeekStr(int dayOfWeek) {
    const days = [
      'Chủ nhật',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
    ];
    return days[dayOfWeek.clamp(0, 6)];
  }

  static bool setEquals(Set a, Set b) {
    return a.length == b.length && a.containsAll(b);
  }

  static Map<String, List<String>> analyzeStudyShifts(
      List<StudyShiftModel> shifts) {
    Map<int, Set<String>> weekToShifts = {};

    for (var shift in shifts) {
      String dayStr = getDayOfWeekStr(shift.dayOfWeek);
      String shiftStr =
          '$dayStr, ${shift.startPeriod}-${shift.endPeriod}, ${shift.room}';

      for (int week = shift.startWeek; week <= shift.endWeek; week++) {
        weekToShifts.putIfAbsent(week, () => <String>{});
        weekToShifts[week]!.add(shiftStr);
      }
    }

    List<int> sortedWeeks = weekToShifts.keys.toList()..sort();

    Map<String, List<String>> result = {};
    int? startWeek;
    int? previousWeek;
    Set<String>? previousShifts;

    for (var week in sortedWeeks) {
      var currentShifts = weekToShifts[week]!;

      // Kiểm tra: khác ca học HOẶC tuần không liền kề
      if (previousShifts == null ||
          !setEquals(previousShifts, currentShifts) ||
          (previousWeek != null && week != previousWeek + 1)) {
        if (startWeek != null && previousWeek != null) {
          result['$startWeek-$previousWeek'] = previousShifts!.toList();
        }
        startWeek = week;
      }

      previousWeek = week;
      previousShifts = currentShifts;
    }

    if (startWeek != null && previousWeek != null && previousShifts != null) {
      result['$startWeek-$previousWeek'] = previousShifts.toList();
    }

    return result;
  }

  static formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  static formatDateTime(DateTime dt) {
    return DateFormat('HH:mm, dd/MM/yyyy').format(dt);
  }

  static TimeOfDay parseTimeOfDay(String timeString) {
    final parts = timeString.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  static List<ScheduleItemModel> sortSchedulesByTime(
      List<ScheduleItemModel> schedules) {
    schedules.sort((a, b) {
      DateTime? timeA;
      DateTime? timeB;

      if (a.isExam) {
        timeA = a.examTime;
      } else if (a.startStudyTime != null) {
        try {
          timeA = DateFormat.Hms().parse(a.startStudyTime!);
        } catch (_) {
          timeA = null;
        }
      }

      if (b.isExam) {
        timeB = b.examTime;
      } else if (b.startStudyTime != null) {
        try {
          timeB = DateFormat.Hms().parse(b.startStudyTime!);
        } catch (_) {
          timeB = null;
        }
      }
      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1;
      if (timeB == null) return -1;

      return timeA.compareTo(timeB);
    });

    return schedules;
  }

  static int _getDaysFromMonday(DateTime date) {
    // DateTime.weekday: 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
    return (date.weekday - 1) % 7;
  }

  static String getWeekStringFromBase(DateTime selected, String noWeek,
      DateTime? baseDateForWeek, int? baseWeekNo) {
    if (baseDateForWeek != null && baseWeekNo != null) {
      // Tính số ngày từ thứ 2 đầu tuần của baseDate
      final baseMondayDays = _getDaysFromMonday(baseDateForWeek);
      final baseMondayDate =
          baseDateForWeek.subtract(Duration(days: baseMondayDays));

      // Tính số ngày từ thứ 2 đầu tuần của selected date
      final selectedMondayDays = _getDaysFromMonday(selected);
      final selectedMondayDate =
          selected.subtract(Duration(days: selectedMondayDays));

      // Tính số tuần chênh lệch giữa 2 ngày thứ 2
      final diffDays = selectedMondayDate.difference(baseMondayDate).inDays;
      final weekOffset = (diffDays / 7).round();
      final calculatedWeek = baseWeekNo + weekOffset;

      return "$calculatedWeek";
    }
    return noWeek;
  }
  // static int getSemesterOrder(String noSemester) {
  //   switch (noSemester.toLowerCase()) {
  //     case "1":
  //       return 1;
  //     case "2":
  //       return 2;
  //     case "hè":
  //       return 3;
  //     default:
  //       return 99; // fallback cho các trường hợp không xác định
  //   }
  // }

  // static int compareSemesters(SemesterModel a, SemesterModel b) {
  //   int startYearCompare = a.startYear.compareTo(b.startYear);
  //   if (startYearCompare != 0) return startYearCompare;

  //   int endYearCompare = a.endYear.compareTo(b.endYear);
  //   if (endYearCompare != 0) return endYearCompare;

  //   return getSemesterOrder(a.noSemester)
  //       .compareTo(getSemesterOrder(b.noSemester));
  // }
}
