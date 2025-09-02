import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/launchers_helper.dart';
import 'package:leadmanagementsystem/controllers/attendance_controller.dart';
import 'package:leadmanagementsystem/screens/attendance/working_hours_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class UserAttendanceScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserAttendanceScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserAttendanceScreen> createState() => _UserAttendanceScreenState();
}

class _UserAttendanceScreenState extends State<UserAttendanceScreen> {
  final AttendanceController attendanceCont = Get.put(AttendanceController());
  final currentDate = DateTime.now();
  int? selectedMonth;
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        selectedMonth = currentDate.month;
        selectedYear = currentDate.year;
        fetchAttendance();
      },
    );
  }

  void fetchAttendance() {
    attendanceCont.getEmployeeAttendance(
      userId: widget.userId,
      monthNumber: selectedMonth?.toString(),
      year: selectedYear?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Attendance: ${widget.userName}", action: [
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () {
            Get.to(() => UserWorkingHoursScreen(
                  // id: widget.userId,
                  userName: widget.userName,
                  attendanceList: attendanceCont.userAttendance,
                ));
          },
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedMonth = value);
                        fetchAttendance();
                      }
                    },
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(
                            DateFormat.MMMM().format(DateTime(0, index + 1))),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedYear = value);
                        fetchAttendance();
                      }
                    },
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GetBuilder<AttendanceController>(
                builder: (controller) {
                  final data = controller.userAttendance;

                  if (controller.attendanceLoading) {
                    return showSpinkit();
                  }

                  if (data.isEmpty) {
                    return const Center(
                      child: Text("No check-in / out yet",
                          style: TextStyle(fontSize: 16)),
                    );
                  }

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final attendance = data[index];
                      final dateTime =
                          DateTime.parse(attendance.dateTime!).toLocal();
                      final formattedTime =
                          DateFormat('hh:mm a').format(dateTime);
                      final formattedDate =
                          DateFormat('dd MMM yyyy').format(dateTime);

                      final isCheckIn =
                          attendance.attendanceType == checkInString;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            isCheckIn
                                ? CupertinoIcons
                                    .person_crop_circle_fill_badge_checkmark
                                : CupertinoIcons.person_crop_circle_badge_xmark,
                            color: isCheckIn ? appColor : Colors.redAccent,
                            size: 28,
                          ),
                          title: Text(
                            "${isCheckIn ? 'Check-In' : 'Check-Out'} • $formattedTime",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCheckIn ? appColor : Colors.redAccent,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(attendance.location ?? ''),
                              const SizedBox(height: 2),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(CupertinoIcons.location_solid,
                                color: appColor),
                            onPressed: () {
                              if (attendance.lat!.isNotEmpty &&
                                  attendance.long!.isNotEmpty) {
                                UrlLauncherHelper.openMap(
                                  latitude: double.parse(attendance.lat!),
                                  longitude: double.parse(attendance.long!),
                                );
                              } else {
                                Get.snackbar("Error", "Location not available");
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
