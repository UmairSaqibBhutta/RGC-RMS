import 'dart:developer';
import 'dart:math' hide log;

import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/controllers/location_controller.dart';
import 'package:leadmanagementsystem/main.dart';

class DailyDistanceUser {
  final String name;
  final String email;
  final String role;

  DailyDistanceUser({
    required this.name,
    required this.email,
    required this.role,
  });

  factory DailyDistanceUser.fromJson(Map<String, dynamic> json) {
    return DailyDistanceUser(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

class DailyDistanceEntry {
  final String? sId;
  final DailyDistanceUser? user;
  final String time;
  final String lat;
  final String long;

  DailyDistanceEntry({
    this.sId,
    this.user,
    required this.time,
    required this.lat,
    required this.long,
  });

  factory DailyDistanceEntry.fromJson(Map<String, dynamic> json) {
    return DailyDistanceEntry(
      sId: json['_id']?.toString(),
      user: json['userId'] is Map<String, dynamic>
          ? DailyDistanceUser.fromJson(json['userId'] as Map<String, dynamic>)
          : null,
      time: json['time']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
    );
  }
}

class DailyDistanceRecord {
  final String? sId;
  final List<DailyDistanceEntry> checkIns;
  final List<DailyDistanceEntry> checkOuts;

  DailyDistanceRecord({
    this.sId,
    required this.checkIns,
    required this.checkOuts,
  });

  factory DailyDistanceRecord.fromJson(Map<String, dynamic> json) {
    return DailyDistanceRecord(
      sId: json['_id']?.toString(),
      checkIns: (json['checkIn'] as List<dynamic>? ?? [])
          .map((e) => DailyDistanceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      checkOuts: (json['checkOut'] as List<dynamic>? ?? [])
          .map((e) => DailyDistanceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyDistanceController extends GetxController {
  bool isCheckInLoading = false;
  bool isCheckOutLoading = false;
  bool isRecordLoading = false;

  DailyDistanceRecord? todayRecord;

  bool get hasCheckedOut =>
      todayRecord != null && todayRecord!.checkOuts.isNotEmpty;

  bool get hasAnyCheckIn =>
      todayRecord != null && todayRecord!.checkIns.isNotEmpty;

  double get totalDistanceKm {
    if (todayRecord == null) return 0.0;

    final List<DailyDistanceEntry> points = [
      ...todayRecord!.checkIns,
      ...todayRecord!.checkOuts,
    ];

    if (points.length < 2) return 0.0;

    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      final lat1 = double.tryParse(points[i].lat) ?? 0;
      final lon1 = double.tryParse(points[i].long) ?? 0;
      final lat2 = double.tryParse(points[i + 1].lat) ?? 0;
      final lon2 = double.tryParse(points[i + 1].long) ?? 0;
      total += _haversineKm(lat1, lon1, lat2, lon2);
    }
    return total;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  Future<void> getTodayRecord() async {
    try {
      isRecordLoading = true;
      update();

      final response = await getRequest.customGetRequest(
        apiPath: "${ApiUrls.getDailyDistance}/${loginStorage.getUserId()}",
      );

      log("📥 Daily Distance Record: $response");

      if (response == null || response['status'] != true) return;

      final data = response['data'];
      if (data is List && data.isNotEmpty) {
        todayRecord =
            DailyDistanceRecord.fromJson(data[0] as Map<String, dynamic>);
      } else {
        todayRecord = null;
      }
    } catch (e) {
      log("❌ getTodayRecord Exception: $e");
    } finally {
      isRecordLoading = false;
      update();
    }
  }

  Future<void> checkIn(LocationModel locationModel) async {
    try {
      isCheckInLoading = true;
      update();

      final body = {
        "userId": loginStorage.getUserId(),
        "time": locationModel.address,
        "lat": locationModel.lat,
        "long": locationModel.long,
      };

      log("📤 Daily CheckIn Body: $body");

      final response = await postRequest.customPostRequest(
        url: ApiUrls.dailyDistanceCheckIn,
        body: body,
      );

      log("📥 Daily CheckIn Response: $response");

      if (response == null) {
        Get.snackbar("Error", "No response from server");
        return;
      }

      if (response['success'] != true && response['status'] != true) {
        Get.snackbar("Error", response['message'] ?? "Check-In failed");
        return;
      }

      Get.snackbar("Checked In", "Location recorded successfully.");
      await getTodayRecord();
    } catch (e) {
      log("❌ Daily CheckIn Exception: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isCheckInLoading = false;
      update();
    }
  }

  Future<void> checkOut(LocationModel locationModel) async {
    try {
      isCheckOutLoading = true;
      update();

      final body = {
        "userId": loginStorage.getUserId(),
        "time": locationModel.address,
        "lat": locationModel.lat,
        "long": locationModel.long,
      };

      log("📤 Daily CheckOut Body: $body");

      final response = await postRequest.customPostRequest(
        url: ApiUrls.dailyDistanceCheckOut,
        body: body,
      );

      log("📥 Daily CheckOut Response: $response");

      if (response == null) {
        Get.snackbar("Error", "No response from server");
        return;
      }

      if (response['success'] != true && response['status'] != true) {
        Get.snackbar("Error", response['message'] ?? "Check-Out failed");
        return;
      }

      Get.snackbar("Checked Out", "Day closed successfully.");
      await getTodayRecord();
    } catch (e) {
      log("❌ Daily CheckOut Exception: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isCheckOutLoading = false;
      update();
    }
  }
}
