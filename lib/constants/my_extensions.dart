extension DateTimeExtensions on DateTime {
  bool get isToday {
    final date = DateTime.now();
    return year == date.year && month == date.month && day == date.day;
  }
}
