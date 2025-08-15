import 'package:intl/intl.dart';

class Functions {
  static formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  static DateTime parseDateTime(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);

    if (!dateString.contains('Z') &&
        !dateString.contains('+') &&
        !dateString.contains('-', 10)) {
      parsedDate = DateTime.parse('${dateString}Z').toLocal();
    }

    return parsedDate;
  }
}
