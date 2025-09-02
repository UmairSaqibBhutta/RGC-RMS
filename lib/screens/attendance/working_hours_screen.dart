import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/models/today_attendance_model.dart';

class UserWorkingHoursScreen extends StatefulWidget {
  final String userName;
  final List<AttendanceData> attendanceList;

  const UserWorkingHoursScreen({
    super.key,
    required this.userName,
    required this.attendanceList,
  });

  @override
  _UserWorkingHoursScreenState createState() => _UserWorkingHoursScreenState();
}

class _UserWorkingHoursScreenState extends State<UserWorkingHoursScreen> {
  late Map<String, List<AttendanceData>> grouped;
  late Map<String, bool> dayStatus;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late List<AttendanceData> _selectedDayRecords;

  late DateTime _firstDay;
  late DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    _setFirstAndLastDay(_focusedDay);

    grouped = _groupAttendanceRecords();
    dayStatus = _calculateDayStatus();
    _selectedDayRecords = _getRecordsForDay(_selectedDay);
  }

  // Set first and last day based on the focused day (current month)
  void _setFirstAndLastDay(DateTime focusedDay) {
    _firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    _lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);
  }

  // Group the attendance data by date
  Map<String, List<AttendanceData>> _groupAttendanceRecords() {
    final Map<String, List<AttendanceData>> grouped = {};
    for (var record in widget.attendanceList) {
      final dateKey = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(record.dateTime ?? ''));
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(record);
    }
    return grouped;
  }

  // Calculate the work status for each day (Green for 8+ hours, Red for less)
  Map<String, bool> _calculateDayStatus() {
    final Map<String, bool> dayStatus = {};
    grouped.forEach((date, records) {
      final checkIns =
          records.where((e) => e.attendanceType == checkInString).toList();
      final checkOuts =
          records.where((e) => e.attendanceType == checkOutString).toList();

      if (checkIns.isNotEmpty && checkOuts.isNotEmpty) {
        final inTime = DateTime.parse(checkIns.first.dateTime!);
        final outTime = DateTime.parse(checkOuts.last.dateTime!);
        final duration = outTime.difference(inTime);
        dayStatus[date] =
            duration.inHours >= 8; // Mark as green if 8 hours or more
      } else {
        dayStatus[date] = false; // Red if incomplete
      }
    });
    return dayStatus;
  }

  // Get records for a selected day
  List<AttendanceData> _getRecordsForDay(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return grouped[dateKey] ?? [];
  }

  // Handle day selection from calendar
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _selectedDayRecords = _getRecordsForDay(selectedDay);
      _focusedDay = focusedDay; // Update focusedDay when a day is selected
    });
  }

  // Handle month changed (left/right scroll)
  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _setFirstAndLastDay(focusedDay);
      grouped = _groupAttendanceRecords();
      dayStatus = _calculateDayStatus();
      _selectedDayRecords = _getRecordsForDay(focusedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Working Hours: ${widget.userName}"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: _firstDay, // Start of the month
              lastDay: _lastDay, // End of the month
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: _onDaySelected,
              onPageChanged: _onPageChanged, // Listen to scroll event
              calendarStyle: CalendarStyle(
                selectedTextStyle: const TextStyle(color: Colors.white),
                selectedDecoration: const BoxDecoration(
                  color: appColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  shape: BoxShape.circle,
                ),
                defaultDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
              ),
              eventLoader: (day) {
                final dateKey = DateFormat('yyyy-MM-dd').format(day);
                return dayStatus[dateKey] == true
                    ? [Colors.green] // green dot for completed work
                    : dayStatus[dateKey] == false
                        ? [Colors.red] // red dot for incomplete work
                        : [];
              },
            ),
            const SizedBox(height: 16),
            _selectedDayRecords.isEmpty
                ? const Center(child: Text("No records for selected day"))
                : Expanded(
                    child: ListView(
                      children: [
                        // Expandable UI for each day
                        ExpansionTile(
                          title: Text(
                            "Day: ${DateFormat('dd MMM yyyy').format(_selectedDay)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dayStatus[DateFormat('yyyy-MM-dd')
                                          .format(_selectedDay)] ==
                                      true
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ),
                          leading: Icon(
                            dayStatus[DateFormat('yyyy-MM-dd')
                                        .format(_selectedDay)] ==
                                    true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: dayStatus[DateFormat('yyyy-MM-dd')
                                        .format(_selectedDay)] ==
                                    true
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                          children: [
                            ListTile(
                              title: Text(
                                  "Total Working Hours: ${_calculateWorkingHours(_selectedDayRecords)}"),
                            ),
                            ListTile(
                              title: Text(
                                  "Total Check-ins: ${_selectedDayRecords.where((e) => e.attendanceType == checkInString).length}"),
                            ),
                            ListTile(
                              title: Text(
                                  "Total Check-outs: ${_selectedDayRecords.where((e) => e.attendanceType == checkOutString).length}"),
                            ),
                            const Divider(thickness: 1),
                            // Show all check-ins and check-outs for the day
                            ..._selectedDayRecords.map((entry) {
                              final time = DateFormat('hh:mm a').format(
                                  DateTime.parse(entry.dateTime ?? "")
                                      .toLocal());
                              return ListTile(
                                title: Text(
                                    "${entry.attendanceType ?? ''} - $time"),
                                subtitle: Text(
                                    entry.location ?? 'Location not recorded'),
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Calculate total working hours for the selected day
  String _calculateWorkingHours(List<AttendanceData> records) {
    final checkIns = records
        .where((e) => e.attendanceType == checkInString)
        .toList()
      ..sort((a, b) =>
          DateTime.parse(a.dateTime!).compareTo(DateTime.parse(b.dateTime!)));

    final checkOuts = records
        .where((e) => e.attendanceType == checkOutString)
        .toList()
      ..sort((a, b) =>
          DateTime.parse(a.dateTime!).compareTo(DateTime.parse(b.dateTime!)));

    if (checkIns.isNotEmpty && checkOuts.isNotEmpty) {
      final inTime = DateTime.parse(checkIns.first.dateTime!);
      final outTime = DateTime.parse(checkOuts.last.dateTime!);
      final duration = outTime.difference(inTime);
      return "${duration.inHours}h ${duration.inMinutes % 60}m";
    }

    return "Incomplete";
  }
}
