import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/location_controller.dart';
import 'package:leadmanagementsystem/controllers/visit_controller.dart';
import 'package:leadmanagementsystem/models/visit_report_model.dart';
import 'package:leadmanagementsystem/screens/add_visit_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({super.key});

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  late VisitController controller;
  final locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(VisitController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getVisitReports();
    });
  }

  CheckIn? _latestCheckIn(dynamic visit) {
    if (visit.checkIn == null || visit.checkIn!.isEmpty) return null;
    return visit.checkIn!.last;
  }

  bool _hasAnyCheckIn(dynamic visit) {
    return visit.checkIn != null && visit.checkIn!.isNotEmpty;
  }

  bool _hasCheckedOut(dynamic visit) {
    return visit.checkOut?.time != null && visit.checkOut!.time!.isNotEmpty;
  }

  String _locationText(dynamic location) {
    if (location == null) return "";

    final lat = location.lat;
    final long = location.long;

    if (lat == null || long == null) return "";

    return "Lat: $lat, Long: $long";
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  double _calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371;

    final double dLat = _degreeToRadian(lat2 - lat1);
    final double dLon = _degreeToRadian(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat1)) *
            cos(_degreeToRadian(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _calculateTotalCoveredDistanceKm(dynamic visit) {
    final List<CheckIn> checkIns = visit.checkIn ?? [];

    final List<dynamic> points = [];

    for (final item in checkIns) {
      if (item.lat != null && item.long != null) {
        points.add(item);
      }
    }

    if (visit.checkOut?.lat != null && visit.checkOut?.long != null) {
      points.add(visit.checkOut);
    }

    if (points.length < 2) return 0.0;

    double totalDistance = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _calculateDistanceKm(
        lat1: double.parse(points[i].lat!),
        lon1: double.parse(points[i].long!),
        lat2: double.parse(points[i + 1].lat!),
        lon2: double.parse(points[i + 1].long!),
      );
    }

    return totalDistance;
  }

  Future<void> _handleCheckIn(dynamic visit) async {
    if (_hasCheckedOut(visit)) {
      Get.snackbar(
        "Visit Closed",
        "You cannot check in again after checkout.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.info_outline, color: Colors.orange),
      );
      return;
    }

    final confirm = await _showConfirmDialog(
      title: "Check In",
      message: "Are you sure you want to check in for this visit?",
      confirmText: "Check In",
      confirmColor: Colors.green,
      icon: Icons.login,
    );

    if (confirm != true) return;

    try {
      final LocationModel? locationModel =
          await locationController.getCurrentAddress();

      if (locationModel == null) {
        Get.snackbar(
          "Location Error",
          "Unable to get your current location. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      await controller.checkInVisit(
        visitId: visit.sId,
        locationModel: locationModel,
      );

      Get.snackbar(
        "Checked In ✅",
        "Location recorded successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to check in: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    }
  }

  Future<void> _handleCheckOut(dynamic visit) async {
    if (!_hasAnyCheckIn(visit)) {
      Get.snackbar(
        "Check In First",
        "Please check in before checking out.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.warning_amber, color: Colors.orange),
      );
      return;
    }

    if (_hasCheckedOut(visit)) {
      Get.snackbar(
        "Already Checked Out",
        "You have already checked out for this visit.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.info_outline, color: Colors.orange),
      );
      return;
    }

    final confirm = await _showConfirmDialog(
      title: "Check Out",
      message: "Are you sure you want to check out from this visit?",
      confirmText: "Check Out",
      confirmColor: Colors.red,
      icon: Icons.logout,
    );

    if (confirm != true) return;

    try {
      final LocationModel? locationModel =
          await locationController.getCurrentAddress();

      if (locationModel == null) {
        Get.snackbar(
          "Location Error",
          "Unable to get your current location. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      await controller.checkOutVisit(
        visitId: visit.sId,
        locationModel: locationModel,
      );

      Get.snackbar(
        "Checked Out ✅",
        "Visit closed successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
        icon: const Icon(Icons.check_circle, color: Colors.blue),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to check out: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: confirmColor),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: confirmColor)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(const AddVisitScreen()),
        backgroundColor: appColor,
        child: const Icon(Icons.add),
      ),
      appBar: mAppbar("Visit Reports"),
      backgroundColor: Colors.grey.shade100,
      body: GetBuilder<VisitController>(
        builder: (cont) {
          if (cont.isReportLoading) return showSpinkit();

          if (cont.visitList.isEmpty) {
            return const Center(child: Text("No Visits Found"));
          }

          return RefreshIndicator(
            onRefresh: () => cont.getVisitReports(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cont.visitList.length,
              itemBuilder: (context, index) {
                final visit = cont.visitList[index];

                final CheckIn? latestCheckIn = _latestCheckIn(visit);
                final bool hasAnyCheckIn = _hasAnyCheckIn(visit);
                final bool hasCheckedOut = _hasCheckedOut(visit);
                final bool isVisitClosed = hasCheckedOut;
                final double totalDistanceKm =
                    _calculateTotalCoveredDistanceKm(visit);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (visit.userDetail != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: appColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "${visit.userDetail?.name ?? ""} (${visit.userDetail?.role ?? ""})",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: appColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _row("Site", visit.site),
                        _row("Town/Phase", visit.townPahse),
                        _row("Block", visit.block),
                        const SizedBox(height: 10),
                        _row("GCO", visit.gco),
                        _row("Key Person", visit.keyPN),
                        _row("Contact", visit.keyPC),
                        _row("Architect", visit.architect),
                        const SizedBox(height: 10),
                        _row("Call Result", visit.callResult),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _timeBox(
                                title: "Check In",
                                time: latestCheckIn?.time,
                                location: _locationText(latestCheckIn),
                                icon: Icons.login,
                                isDone: hasAnyCheckIn,
                                isClosed: isVisitClosed,
                                doneText: hasAnyCheckIn
                                    ? "Latest: ${latestCheckIn?.time ?? "-"}"
                                    : null,
                                onTap: isVisitClosed
                                    ? null
                                    : () => _handleCheckIn(visit),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _timeBox(
                                title: "Check Out",
                                time: visit.checkOut?.time,
                                location: _locationText(visit.checkOut),
                                icon: Icons.logout,
                                isDone: hasCheckedOut,
                                isClosed: isVisitClosed,
                                doneText: hasCheckedOut
                                    ? "Closed: ${visit.checkOut?.time ?? "-"}"
                                    : null,
                                onTap: isVisitClosed
                                    ? null
                                    : () => _handleCheckOut(visit),
                              ),
                            ),
                          ],
                        ),
                        if (visit.checkIn != null && visit.checkIn!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _checkInHistory(visit.checkIn!),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _distanceBox(totalDistanceKm),
                        ),
                        if (isVisitClosed)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Visit Closed",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _distanceBox(double totalDistanceKm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 6),
          Text(
            "Distance Covered: ${totalDistanceKm.toStringAsFixed(2)} km",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkInHistory(List<CheckIn> checkIns) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Check In History (${checkIns.length})",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          ...checkIns.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${index + 1}. ",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.time ?? "-",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _row(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value != null && value.isNotEmpty ? value : "-",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBox({
    required String title,
    required String? time,
    String? location,
    required IconData icon,
    required bool isDone,
    required bool isClosed,
    String? doneText,
    VoidCallback? onTap,
  }) {
    final bool isEnabled = onTap != null && !isClosed;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isClosed
              ? Colors.grey.shade200
              : isDone
                  ? Colors.green.shade50
                  : isEnabled
                      ? Colors.blue.shade50
                      : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isClosed
                ? Colors.grey.shade400
                : isDone
                    ? Colors.green
                    : isEnabled
                        ? Colors.blue.shade300
                        : Colors.grey.shade300,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isClosed
                  ? Colors.grey
                  : isDone
                      ? Colors.green
                      : isEnabled
                          ? Colors.blue
                          : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              isClosed && !isDone
                  ? "Closed"
                  : isDone
                      ? doneText ?? time ?? "-"
                      : isEnabled
                          ? "Tap to $title"
                          : "Not Marked",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: isClosed
                    ? Colors.grey.shade700
                    : isDone
                        ? Colors.green
                        : isEnabled
                            ? Colors.blue
                            : Colors.black54,
              ),
            ),
            if (isDone && location != null && location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  location,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
