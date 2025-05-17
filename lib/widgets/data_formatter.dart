import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(String dateTimeString) {
    // Parse the input string to a DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Format the DateTime object to the desired format
    String formattedDate = DateFormat('d MMM y, h:mm a').format(dateTime);

    return formattedDate;
  }


    static String formatDate(String dateString) {
    // Parse the input string to a DateTime object
    DateTime dateTime = DateTime.parse(dateString);

    // Format the DateTime object to the desired format
    String formattedDate = DateFormat('d MMM y').format(dateTime);

    return formattedDate;
  }
}
