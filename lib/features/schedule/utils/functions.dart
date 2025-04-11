import 'package:e_dut/features/schedule/data/model/study_shift_model.dart';
import 'package:intl/intl.dart';

class Functions {
  static String getDayOfWeekStr(int dayOfWeek) {
    const days = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật'
    ];
    return days[(dayOfWeek - 1).clamp(0, 6)];
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

  static formatDateTime(DateTime dt) {
    return DateFormat('HH:mm, dd/MM/yyyy').format(dt);
  }
}
