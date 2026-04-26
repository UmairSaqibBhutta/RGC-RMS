import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/controllers/location_controller.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/visit_report_model.dart';

class VisitController extends GetxController {
  /// Controllers
  final townPhaseCont = TextEditingController();
  final blockCont = TextEditingController();
  final siteCont = TextEditingController();
  final gcoCont = TextEditingController();
  final keyPNCont = TextEditingController();
  final keyPCCont = TextEditingController();
  final architectCont = TextEditingController();
  final callResultCont = TextEditingController();

  /// Loading
  bool isLoading = false;
  VisitReportModel? visitReportModel;
  List<VisitData> visitList = [];

  bool isReportLoading = false;

  /// ✅ Validation
  String? validate() {
    if (townPhaseCont.text.trim().isEmpty) {
      return "Town / Phase is required";
    }
    if (siteCont.text.trim().isEmpty) {
      return "Site is required";
    }
    if (keyPCCont.text.isNotEmpty && keyPCCont.text.length < 11) {
      return "Invalid phone number";
    }
    return null;
  }

  /// ✅ Create Visit
  Future<void> submitData() async {
    final error = validate();
    if (error != null) {
      customSnackBar("Error", error);
      return;
    }

    try {
      /// Start loading
      isLoading = true;
      update();

      /// Clean payload
      final Map<String, dynamic> body = {
        "userId": loginStorage.getUserId()!,
        "townPahse": townPhaseCont.text.trim(),
        if (blockCont.text.trim().isNotEmpty) "block": blockCont.text.trim(),
        "site": siteCont.text.trim(),
        if (gcoCont.text.trim().isNotEmpty) "gco": gcoCont.text.trim(),
        if (keyPNCont.text.trim().isNotEmpty) "keyPN": keyPNCont.text.trim(),
        if (keyPCCont.text.trim().isNotEmpty) "keyPC": keyPCCont.text.trim(),
        if (architectCont.text.trim().isNotEmpty)
          "architect": architectCont.text.trim(),
        if (callResultCont.text.trim().isNotEmpty)
          "callResult": callResultCont.text.trim(),
      };

      log("📤 Create Visit Payload: $body");

      final response = await postRequest.customPostRequest(
        url: ApiUrls.addNewVisitReport,
        body: body,
      );

      log("📥 API Response: $response");

      /// ❌ Handle failure properly
      if (response == null) {
        customSnackBar("Error", "No response from server");
        return;
      }

      if (response['success'] == false) {
        customSnackBar(
          "Error",
          response['message'] ?? "Failed to create visit",
        );
        return;
      }

      customSnackBar("Success", response['message'] ?? "Visit Report Added");
      clearForm();
      getVisitReports();
      Navigator.of(Get.context!).pop();
    } catch (e) {
      log("❌ Exception: $e");
      customSnackBar("Error", "Something went wrong");
    } finally {
      isLoading = false;
      update();
    }
  }

  void clearForm() {
    townPhaseCont.clear();
    blockCont.clear();
    siteCont.clear();
    gcoCont.clear();
    keyPNCont.clear();
    keyPCCont.clear();
    architectCont.clear();
    callResultCont.clear();
  }

  Future<void> checkInVisit({
    required String visitId,
    required LocationModel locationModel,
  }) async {
    try {
      // Start loading
      isLoading = true;
      update();

      final body = {
        "visitId": visitId,
        "time": locationModel.address,
        "lat": locationModel.lat,
        "long": locationModel.long,
      };

      log("📤 Check-In Body: $body");

      final response = await postRequest.customPostRequest(
        url: ApiUrls.visitCheckIn,
        body: body,
      );

      log("📥 Check-In Response: $response");

      if (response == null) {
        customSnackBar("Error", "No response from server");
        return;
      }

      if (response['success'] != true) {
        customSnackBar(
          "Error",
          response['message'] ?? "Check-In failed",
        );
        return;
      }

      customSnackBar("Success", "Checked In Successfully");

      // Refresh visits
      await getVisitReports();
    } catch (e) {
      log("❌ Check-In Exception: $e");
      customSnackBar("Error", "Something went wrong");
    } finally {
      // Ensure loading state is reset
      isLoading = false;
      update(); // This is critical to stop showing the loading spinner
    }
  }

  Future<void> checkOutVisit({
    required String visitId,
    required LocationModel locationModel,
  }) async {
    try {
      isLoading = true;
      update();

      final body = {
        "visitId": visitId,
        "time": locationModel.address,
        "lat": locationModel.lat,
        "long": locationModel.long,
      };

      log("📤 Check-Out Body: $body");

      final response = await postRequest.customPostRequest(
        url: ApiUrls.visitCheckOut,
        body: body,
      );

      log("📥 Check-Out Response: $response");

      if (response == null) {
        customSnackBar("Error", "No response from server");
        return;
      }

      if (response['success'] != true) {
        customSnackBar(
          "Error",
          response['message'] ?? "Check-Out failed",
        );
        return;
      }

      customSnackBar("Success", "Checked Out Successfully");

      /// 🔄 Refresh list
      await getVisitReports();
    } catch (e) {
      log("❌ Check-Out Exception: $e");
      customSnackBar("Error", "Something went wrong");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getVisitReports() async {
    try {
      isReportLoading = true;
      update();

      final response = await getRequest.customGetRequest(
        apiPath: ApiUrls.getNewVisitReport,
      );

      log("📥 Visit Reports Raw: $response");

      if (response == null) {
        customSnackBar("Error", "No response from server");
        return;
      }

      /// ✅ Parse Model
      visitReportModel = VisitReportModel.fromJson(response);

      /// ✅ Extract list safely
      visitList = visitReportModel?.data ?? [];

      log("✅ Parsed Visits Count: ${visitList.length}");

      /// Optional: Debug first item
      if (visitList.isNotEmpty) {
        log("📌 First Visit Site: ${visitList.first.site}");
        log("⏱ CheckOut: ${visitList.first.checkOut?.time}");
      }
    } catch (e) {
      log("❌ getVisitReports Exception: $e");
      customSnackBar("Error", "Failed to fetch visits");
    } finally {
      isReportLoading = false;
      update();
    }
  }
}
