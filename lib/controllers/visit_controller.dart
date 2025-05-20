import 'dart:developer';

import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/admin_track_users.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/extensions/string_extensions.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/visit_detail_model.dart';

class VisitController extends GetxController {
  VisitReportModel? visitReportModel;
  VisitReportModel? visitReportAllModel;

  bool isLoading = false;

  updateLoading(bool value) {
    isLoading = value;
    update();
  }

  /// Add visit report to the server
  Future<bool> addvisit(Map<String, dynamic> body) async {
    log("Visit Report Body: ${body.toString()}");
    try {
      var responce = await postRequest.customPostRequest(
        url: ApiUrls.addVisit,
        body: body,
      );

      if (responce != null && responce['status'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Visit Report Error: ${e.toString()}");
      return false;
    }
  }

  /// Get visit reports
  Future<bool> getVisitReport(
      {String? userId,
      String? firstDate,
      String? lastDate,
      String? siteName}) async {
    String? id = userId;
    if (userId == null && loginStorage.getUserRole() == UserRole.CEO) {
      id = loginStorage.getUserId();
    }
    String url = "";
    if (firstDate != null ||
        lastDate != null ||
        userId != null ||
        siteName != null) {
      id ?? "";
      firstDate ?? "";
      lastDate ?? "";
      siteName ?? "";
      url =
          "${ApiUrls.getFilterReport}?userId=${id ?? ""}&startDate=${firstDate ?? ""}&endDate=${lastDate ?? ""}&siteName=${siteName ?? ""}";
    } else {
      id = loginStorage.getUserId();

      url = "${ApiUrls.getVisitReport}/$id";
    }
    try {
      updateLoading(true);
      var responce = await getRequest.customGetRequest(
        apiPath: url,
      );
      updateLoading(false);

      if (responce != null && responce['status'] == true) {
        visitReportModel = VisitReportModel.fromJson(responce);
        visitReportAllModel = visitReportModel;
        // if (firstDate != null && lastDate != null) {
        //   visitReportAllModel = VisitReportModel.fromJson(responce);
        // }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Get Visit Reports Error: ${e.toString()}");
      updateLoading(false);

      return false;
    }
  }

  /// Add visit report to the server
  Future<bool> addvisitReport(Map<String, dynamic> body) async {
    log("Visit Report Body: ${body.toString()}");
    try {
      var responce = await postRequest.customPostRequest(
        url: ApiUrls.addVisitReport,
        body: body,
      );

      if (responce != null && responce['status'] == true) {
        Get.snackbar("Success", "Visit report added successfully");
        return true;
      } else {
        Get.snackbar("Error", "Visit report could not be added");

        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Visit report could not be added");

      print("Visit Report Error: ${e.toString()}");
      return false;
    }
  }
}
