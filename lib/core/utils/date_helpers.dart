import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static String categorizeDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else if (date.isAfter(sevenDaysAgo)) {
      return 'Previous 7 Days';
    } else {
      return 'Older';
    }
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  static String formatSecondsToMinutes(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
