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
  final String dateTime;
  final String lat;
  final String long;
  final String address;

  DailyDistanceEntry({
    this.sId,
    this.user,
    required this.dateTime,
    required this.lat,
    required this.long,
    required this.address,
  });

  factory DailyDistanceEntry.fromJson(Map<String, dynamic> json) {
    return DailyDistanceEntry(
      sId: json['_id']?.toString(),
      user: json['userId'] is Map<String, dynamic>
          ? DailyDistanceUser.fromJson(json['userId'] as Map<String, dynamic>)
          : null,
      dateTime: json['dateTime']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  DateTime? get parsedDateTime =>
      dateTime.isNotEmpty ? DateTime.tryParse(dateTime) : null;

  String get formattedTime {
    final dt = parsedDateTime;
    if (dt == null) return '-';
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute $period';
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

  DateTime? get date {
    for (final entry in [...checkIns, ...checkOuts]) {
      final dt = entry.parsedDateTime;
      if (dt != null) return dt;
    }
    return null;
  }

  bool get isToday {
    final d = date;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String get dateLabel {
    final d = date;
    if (d == null) return 'Unknown Date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  double get distanceKm {
    final points = [...checkIns, ...checkOuts];
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

  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;
}

class DailyDistanceController extends GetxController {
  bool isCheckInLoading = false;
  bool isCheckOutLoading = false;
  bool isRecordLoading = false;

  List<DailyDistanceRecord> allRecords = [];
  DailyDistanceRecord? todayRecord;

  bool get hasCheckedOut =>
      todayRecord != null && todayRecord!.checkOuts.isNotEmpty;

  bool get hasAnyCheckIn =>
      todayRecord != null && todayRecord!.checkIns.isNotEmpty;

  List<DailyDistanceRecord> get historyRecords =>
      allRecords.where((r) => !r.isToday).toList()
        ..sort((a, b) {
          final da = a.date;
          final db = b.date;
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });

  double get totalDistanceKm => todayRecord?.distanceKm ?? 0.0;

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
      if (data is List) {
        allRecords = data
            .map((e) =>
                DailyDistanceRecord.fromJson(e as Map<String, dynamic>))
            .toList();

        DailyDistanceRecord? found;
        for (final r in allRecords) {
          if (r.isToday) {
            found = r;
            break;
          }
        }
        todayRecord = found;
      } else {
        allRecords = [];
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
        "address": locationModel.address,
        "dateTime": DateTime.now().toIso8601String(),
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
        "dateTime": DateTime.now().toIso8601String(),
        "lat": locationModel.lat,
        "long": locationModel.long,
        "address": locationModel.address,
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
