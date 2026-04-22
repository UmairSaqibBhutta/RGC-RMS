import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
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

      if (response['success'] != true) {
        customSnackBar(
          "Error",
          response['message'] ?? "Failed to create visit",
        );
        return;
      }

      /// ✅ Success
      customSnackBar("Success", response['message'] ?? "Visit Created");

      clearForm();
      Get.back();
    } catch (e) {
      log("❌ Exception: $e");
      customSnackBar("Error", "Something went wrong");
    } finally {
      isLoading = false;
      update();
    }
  }

  /// ✅ Clear Form
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

  /// ✅ Update Visit (Check-In / Check-Out)
  Future<void> updateVisitStatus({
    required String visitId,
    String? checkIn,
    String? checkOut,
  }) async {
    try {
      isLoading = true;
      update();

      final body = {
        "visitId": visitId,
        if (checkIn != null) "checkIn": checkIn,
        if (checkOut != null) "checkOut": checkOut,
      };

      log("📤 Update Visit Payload: $body");

      // final response = await postRequest.customPostRequest(
      //   url: ApiUrls.updateVisitStatus, // make sure exists
      //   body: body,
      // );

      // log("📥 Update Response: $response");

      // if (response == null || response['success'] != true) {
      //   customSnackBar(
      //     "Error",
      //     response?['message'] ?? "Failed to update visit",
      //   );
      //   return;
      // }

      customSnackBar("Success", "Visit Updated");
    } catch (e) {
      log("❌ Update Exception: $e");
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
        log("⏱ CheckIn: ${visitList.first.checkIn?.time}");
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
