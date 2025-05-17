import 'dart:developer';

import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
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
      {String? userId, String? firstDate, String? lastDate}) async {
    String? id = userId ?? loginStorage.getUserId();
    String url = "";
    if (firstDate != null && lastDate != null) {
      url =
          "${ApiUrls.getFilterReport}/$id?startDate=$firstDate&endDate=$lastDate";
    } else {
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
        if (firstDate != null && lastDate != null) {
          visitReportAllModel = VisitReportModel.fromJson(responce);
        }
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
