import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, {String symbol = 'RWF'}) {
    final formatter = NumberFormat.currency(
      symbol: '$symbol ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  static String shortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
