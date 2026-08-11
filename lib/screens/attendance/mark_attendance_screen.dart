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
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';
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
        CustomSnackbar.error("Location service is required to proceed.");
        return;
      }

      // ✅ Exit the function and ask user to try again manually
      CustomSnackbar.info("Location service enabled. Please try again.");
      return;
    }

    _permissionGranted = await location!.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location!.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        CustomSnackbar.error("Location permission denied.");
        return;
      }
    }

    alertDialogueWithLoader(context);

    _locationData = await location!.getLocation();

    if (_locationData == null) {
      Navigator.of(context).pop();
      CustomSnackbar.error("Location data unavailable.");
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
    final effectiveColor = isDisabled ? const Color(0xFF9CA3AF) : color;
    return GestureDetector(
      onTap: isButton && !isDisabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Container(
          width: Get.width * .45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled
                  ? const Color(0xFFE5E7EB)
                  : effectiveColor.withValues(alpha: 0.3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: effectiveColor, size: 18),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: isDisabled
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF374151),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: effectiveColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                ),
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
                  "Today's Records",
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: attendanceCont.todayAttendance.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.clock,
                                  size: 40, color: Color(0xFFD1D5DB)),
                              SizedBox(height: 8),
                              Text(
                                "No records yet",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: attendanceCont.todayAttendance.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: Color(0xFFF3F4F6)),
                          itemBuilder: (context, index) {
                            final attendance =
                                attendanceCont.todayAttendance[index];
                            final time = DateTime.parse(attendance.dateTime!);
                            final t = time.toLocal();
                            final paktime = DateFormat('hh:mm a').format(t);
                            final isCheckIn =
                                attendance.attendanceType == checkInString;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isCheckIn
                                      ? appColor.withValues(alpha: 0.1)
                                      : const Color(0xFFEF4444)
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isCheckIn
                                      ? CupertinoIcons.arrow_down_circle
                                      : CupertinoIcons.arrow_up_circle,
                                  color: isCheckIn
                                      ? appColor
                                      : const Color(0xFFEF4444),
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                paktime,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              subtitle: Text(
                                attendance.location ?? "",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  CupertinoIcons.map_pin,
                                  color: Color(0xFF9CA3AF),
                                  size: 18,
                                ),
                                onPressed: () {
                                  if (attendance.lat!.isNotNullOrEmpty &&
                                      attendance.long!.isNotNullOrEmpty) {
                                    UrlLauncherHelper.openMap(
                                        latitude: double.parse(attendance.lat!),
                                        longitude:
                                            double.parse(attendance.long!));
                                  } else {
                                    CustomSnackbar.error(
                                        "Location not available");
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
