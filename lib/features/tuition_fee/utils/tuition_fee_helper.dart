import 'package:intl/intl.dart';

class TuitionFeeHelper {
  static String formatDate(DateTime? date) {
    if (date == null) return "---";
    try {
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return "---";
    }
  }

  static String formatCurrency(num? amount) {
    if (amount == null) return "0 ₫";
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0, // bỏ phần thập phân
    );
    return formatter.format(amount);
  }
}
