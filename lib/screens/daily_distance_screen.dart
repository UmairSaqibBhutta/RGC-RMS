import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/daily_distance_controller.dart';
import 'package:leadmanagementsystem/controllers/location_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class DailyDistanceScreen extends StatefulWidget {
  const DailyDistanceScreen({super.key});

  @override
  State<DailyDistanceScreen> createState() => _DailyDistanceScreenState();
}

class _DailyDistanceScreenState extends State<DailyDistanceScreen> {
  late DailyDistanceController controller;
  final locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(DailyDistanceController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getTodayRecord();
    });
  }

  Future<void> _handleCheckIn() async {
    if (controller.hasCheckedOut) {
      Get.snackbar(
        "Day Closed",
        "You cannot check in again after checking out.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.info_outline, color: Colors.orange),
      );
      return;
    }

    final confirm = await _showConfirmDialog(
      title: "Check In",
      message: "Are you sure you want to check in?",
      confirmText: "Check In",
      confirmColor: Colors.green,
      icon: Icons.login,
    );
    if (confirm != true) return;

    final locationModel = await locationController.getCurrentAddress();
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

    await controller.checkIn(locationModel);
  }

  Future<void> _handleCheckOut() async {
    if (!controller.hasAnyCheckIn) {
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

    if (controller.hasCheckedOut) {
      Get.snackbar(
        "Already Checked Out",
        "You have already checked out for today.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.info_outline, color: Colors.orange),
      );
      return;
    }

    final confirm = await _showConfirmDialog(
      title: "Check Out",
      message: "Are you sure you want to check out? This will close your day.",
      confirmText: "Check Out",
      confirmColor: Colors.red,
      icon: Icons.logout,
    );
    if (confirm != true) return;

    final locationModel = await locationController.getCurrentAddress();
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

    await controller.checkOut(locationModel);
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
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Get.back(result: true),
            child:
                Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Daily Distance"),
      backgroundColor: Colors.grey.shade100,
      body: GetBuilder<DailyDistanceController>(
        builder: (cont) {
          if (cont.isRecordLoading) return showSpinkit();

          return RefreshIndicator(
            onRefresh: () => cont.getTodayRecord(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _distanceSummaryCard(cont),
                  const SizedBox(height: 20),
                  _actionButtons(cont),
                  const SizedBox(height: 20),
                  if (cont.hasAnyCheckIn) _checkInHistoryCard(cont),
                  if (cont.hasCheckedOut) ...[
                    const SizedBox(height: 12),
                    _checkOutHistoryCard(cont),
                    const SizedBox(height: 12),
                    _dayClosedBanner(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _distanceSummaryCard(DailyDistanceController cont) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.directions_car, size: 40, color: appColor),
            const SizedBox(height: 10),
            const Text(
              "Today's Distance",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              "${cont.totalDistanceKm.toStringAsFixed(2)} km",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: appColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statChip(
                  label: "Check Ins",
                  value: "${cont.todayRecord?.checkIns.length ?? 0}",
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                _statChip(
                  label: "Check Outs",
                  value: "${cont.todayRecord?.checkOuts.length ?? 0}",
                  color: Colors.red,
                ),
                const SizedBox(width: 10),
                _statChip(
                  label: "",
                  value: cont.hasCheckedOut
                      ? "Closed"
                      : cont.hasAnyCheckIn
                          ? "Active"
                          : "Not Started",
                  color: cont.hasCheckedOut
                      ? Colors.red
                      : cont.hasAnyCheckIn
                          ? Colors.green
                          : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(DailyDistanceController cont) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            label: "Check In",
            icon: Icons.login,
            color: Colors.green,
            isLoading: cont.isCheckInLoading,
            isDisabled: cont.hasCheckedOut,
            onTap: _handleCheckIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            label: "Check Out",
            icon: Icons.logout,
            color: Colors.red,
            isLoading: cont.isCheckOutLoading,
            isDisabled: cont.hasCheckedOut || !cont.hasAnyCheckIn,
            onTap: _handleCheckOut,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    final effectiveColor = isDisabled ? Colors.grey : color;

    return GestureDetector(
      onTap: isDisabled || isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: effectiveColor.withValues(alpha: 0.5), width: 1.5),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: effectiveColor.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                    ),
                  )
                : Icon(icon, size: 28, color: effectiveColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkInHistoryCard(DailyDistanceController cont) {
    final checkIns = cont.todayRecord!.checkIns;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.login, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  "Check In History (${checkIns.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...checkIns.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${i + 1}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.user != null && item.user!.name.isNotEmpty)
                            Text(
                              item.user!.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            item.time.isNotEmpty ? item.time : "-",
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (item.lat.isNotEmpty && item.long.isNotEmpty)
                            Text(
                              "Lat: ${item.lat}, Long: ${item.long}",
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black45),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _checkOutHistoryCard(DailyDistanceController cont) {
    final checkOuts = cont.todayRecord!.checkOuts;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.logout, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  "Check Out History (${checkOuts.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...checkOuts.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${i + 1}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.user != null && item.user!.name.isNotEmpty)
                            Text(
                              item.user!.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            item.time.isNotEmpty ? item.time : "-",
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (item.lat.isNotEmpty && item.long.isNotEmpty)
                            Text(
                              "Lat: ${item.lat}, Long: ${item.long}",
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black45),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _dayClosedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 16, color: Colors.red),
          SizedBox(width: 8),
          Text(
            "Day Closed — No further check-ins allowed",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
