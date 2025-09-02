import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/launchers_helper.dart';
import 'package:leadmanagementsystem/controllers/attendance_controller.dart';
import 'package:leadmanagementsystem/extensions/string_extensions.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  bool isCheckedOut = false;
  DateTime? checkOutTime;

  loc.Location? location = loc.Location();
  bool _serviceEnabled = false;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;

  List<Map<String, dynamic>> checkIns = [];

  final attendanceCont = Get.put(AttendanceController());

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        attendanceCont.getTodayAttendance();
      },
    );
  }

  @override
  dispose() {
    super.dispose();
    attendanceCont.dispose();
  }

  Future<void> markAttendance({required String attendanceType}) async {
    _serviceEnabled = await location!.serviceEnabled();
    if (!_serviceEnabled) {
      bool requested = await location!.requestService();
      if (!requested) {
        Get.snackbar("Error", "Location service is required to proceed.",
            backgroundColor: whiteColor);
        return;
      }

      // ✅ Exit the function and ask user to try again manually
      Get.snackbar("Notice", "Location service enabled. Please try again.");
      return;
    }

    _permissionGranted = await location!.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location!.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        Get.snackbar("Error", "Location permission denied.",
            backgroundColor: whiteColor);
        return;
      }
    }

    alertDialogueWithLoader(context);

    _locationData = await location!.getLocation();

    if (_locationData == null) {
      Navigator.of(context).pop();
      Get.snackbar("Error", "Location data unavailable.");
      return;
    }

    List<geoCoding.Placemark> placemarks =
        await geoCoding.placemarkFromCoordinates(
      _locationData!.latitude!,
      _locationData!.longitude!,
    );

    Map<String, dynamic> checkInOutRecord = {
      "attendanceType": attendanceType,
      "userId": loginStorage.getUserId(),
      // "dateTime": DateTime.now().toIso8601String(),//! use server time and convert it to local for  use
      "location":
          "${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}",
      "lat": _locationData!.latitude,
      "long": _locationData!.longitude,
    };

    bool isCheckedIn = await attendanceCont.markAttendance(checkInOutRecord);
    Navigator.of(context).pop();

    if (isCheckedIn) {
      attendanceCont.getTodayAttendance();
    }
  }

  Widget _buildAttendanceCard({
    required IconData icon,
    required String title,
    required String time,
    required String subtitle,
    required Color color,
    bool isButton = false,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isButton && !isDisabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: Get.width * .9,
          height: 170,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDisabled
                  ? [Colors.grey, Colors.grey.shade400]
                  : [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: 2,
                offset: Offset(2, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: mAppbar("Today Attendance", action: [
        // IconButton(
        //   icon: const Icon(CupertinoIcons.clock_fill),
        //   onPressed: () {
        //     Get.to(() => AttendanceHistoryScreen());
        //   },
        // )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GetBuilder(
          init: attendanceCont,
          builder: (AttendanceController controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    _buildAttendanceCard(
                      icon: CupertinoIcons.clock_fill,
                      title: "Check In",
                      time: "Tap to Check-In",
                      subtitle: "Multiple check-ins allowed",
                      color: appColor,
                      isButton: true,
                      onTap: () =>
                          markAttendance(attendanceType: checkInString),
                      // isDisabled: attendanceCont.todayAttendance
                      //     .any((e) => e.attendanceType == checkOutString
                      //     ),
                    ),
                    _buildAttendanceCard(
                      icon: CupertinoIcons.square_arrow_right_fill,
                      title: "Check Out",
                      time: "Tap to Check-Out",
                      subtitle: "Multiple check-outs allowed",
                      color: appColor,
                      isButton: true,
                      onTap: () =>
                          markAttendance(attendanceType: checkOutString),
                      isDisabled: attendanceCont.todayAttendance.isEmpty,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Today's Check-In / Out Records",
                  style: TextStyle(
                    color: appColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: attendanceCont.todayAttendance.isEmpty
                      ? const Center(
                          child: Text(
                            "No check-in / out yet",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: attendanceCont.todayAttendance.length,
                          itemBuilder: (context, index) {
                            final attendance =
                                attendanceCont.todayAttendance[index];
                            final time = DateTime.parse(attendance.dateTime!);
                            DateTime t = time.toLocal();
                            final paktime = DateFormat('hh:mm a').format(t);
                            return ListTile(
                              title: Text(
                                paktime,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(attendance.location ?? ""),
                              trailing: IconButton(
                                icon: Icon(
                                  CupertinoIcons.location_solid,
                                  color:
                                      attendance.attendanceType == checkInString
                                          ? appColor
                                          : Colors.redAccent,
                                ),
                                onPressed: () {
                                  if (attendance.lat!.isNotNullOrEmpty &&
                                      attendance.long!.isNotNullOrEmpty) {
                                    UrlLauncherHelper.openMap(
                                        latitude: double.parse(attendance.lat!),
                                        longitude:
                                            double.parse(attendance.long!));
                                  } else {
                                    Get.snackbar(
                                        "Error", "Location not available");
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
