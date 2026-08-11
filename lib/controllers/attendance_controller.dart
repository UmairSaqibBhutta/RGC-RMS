import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/today_attendance_model.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

class AttendanceController extends GetxController {
  bool attendanceLoading = false;

  List<AttendanceData> todayAttendance = [];

  /// will be used by hr to check single user attendance
  List<AttendanceData> userAttendance = [];

  updateAttendance(bool value) {
    attendanceLoading = value;
    update();
  }

  Future<bool> markAttendance(Map body) async {
    log('Attendance Body: $body');

    updateAttendance(true);

    try {
      var res = await postRequest.customPostRequest(
          url: ApiUrls.markAttendance, body: body);
      updateAttendance(false);

      if (res['status'] == true) {
        CustomSnackbar.success(res['message']);
        return true;
      } else {
        CustomSnackbar.error(res['message']);
        return false;
      }
    } catch (e) {
      updateAttendance(false);

      CustomSnackbar.error('Something went wrong. Please try again later.');
      return false;
    }
  }

  void getTodayAttendance() async {
    try {
      alertDialogueWithLoader(Get.context);
      var res = await getRequest.customGetRequest(
          apiPath: "${ApiUrls.getTodayAttendance}/${loginStorage.getUserId()}");

      if (res['status'] == true) {
        todayAttendance = TodayAttendanceModel.fromJson(res).data ?? [];
        Navigator.of(Get.context!).pop();
        update();
      } else {
        CustomSnackbar.error(res['message']);
        todayAttendance = [];
        Navigator.of(Get.context!).pop();

        update();
      }
    } catch (e) {
      CustomSnackbar.error('Something went wrong. Please try again later.');
      todayAttendance = [];
      Navigator.of(Get.context!).pop();

      update();
    }
  }

  Future<void> getEmployeeAttendance(
      {required String userId, String? year, String? monthNumber}) async {
    try {
      alertDialogueWithLoader(Get.context);
      getRequest
          .customGetRequest(
              apiPath:
                  "${ApiUrls.singleUserAttendance}/$userId?month=$monthNumber&year=$year")
          .then((res) {
        if (res['status'] == true) {
          userAttendance = TodayAttendanceModel.fromJson(res).data ?? [];
          Navigator.of(Get.context!).pop();
          update();
        } else {
          CustomSnackbar.error(res['message']);
          userAttendance = [];
          Navigator.of(Get.context!).pop();

          update();
        }
      });
    } catch (e) {
      CustomSnackbar.error('Something went wrong. Please try again later.');
      userAttendance = [];
      Navigator.of(Get.context!).pop();

      update();
    }
  }
}
