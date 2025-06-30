import 'package:intl/intl.dart';

class Functions {
  static formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }
}
