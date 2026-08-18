import 'package:leadmanagementsystem/utils/dev_log.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/controllers/location_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/visit_report_model.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

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

  /// Single visit report detail
  VisitData? visitDetail;
  bool isVisitDetailLoading = false;

  /// Pagination
  int _visitPage = 1;
  int _visitTotalPages = 1;
  bool isLoadingMoreVisits = false;
  static const int _limit = 10;

  /// âœ… Validation
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

  /// âœ… Create Visit
  Future<void> submitData() async {
    final error = validate();
    if (error != null) {
      CustomSnackbar.error(error);
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

      log("ðŸ“¤ Create Visit Payload: $body");

      final response = await postRequest.customPostRequest(
        url: ApiUrls.addNewVisitReport,
        body: body,
      );

      log("ðŸ“¥ API Response: $response");

      /// âŒ Handle failure properly
      if (response == null) {
        CustomSnackbar.error("No response from server");
        return;
      }

      if (response['success'] == false) {
        CustomSnackbar.error(
          response['message'] ?? "Failed to create visit",
        );
        return;
      }

      CustomSnackbar.success(response['message'] ?? "Visit Report Added");
      clearForm();
      getVisitReports();
      Navigator.of(Get.context!).pop();
    } catch (e) {
      log("âŒ Exception: $e");
      CustomSnackbar.error("Something went wrong");
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

      log("ðŸ“¤ Check-In Body: $body");

      final response = await postRequest.customPostRequest(
        url: ApiUrls.visitCheckIn,
        body: body,
      );

      log("ðŸ“¥ Check-In Response: $response");

      if (response == null) {
        CustomSnackbar.error("No response from server");
        return;
      }

      if (response['success'] != true) {
        CustomSnackbar.error(
          response['message'] ?? "Check-In failed",
        );
        return;
      }

      CustomSnackbar.success("Checked In Successfully");

      // Refresh visits
      await getVisitReports();
    } catch (e) {
      log("âŒ Check-In Exception: $e");
      CustomSnackbar.error("Something went wrong");
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

      log("ðŸ“¤ Check-Out Body: $body");

      final response = await postRequest.customPostRequest(
        url: ApiUrls.visitCheckOut,
        body: body,
      );

      log("ðŸ“¥ Check-Out Response: $response");

      if (response == null) {
        CustomSnackbar.error("No response from server");
        return;
      }

      if (response['success'] != true) {
        CustomSnackbar.error(
          response['message'] ?? "Check-Out failed",
        );
        return;
      }

      CustomSnackbar.success("Checked Out Successfully");

      /// ðŸ”„ Refresh list
      await getVisitReports();
    } catch (e) {
      log("âŒ Check-Out Exception: $e");
      CustomSnackbar.error("Something went wrong");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getVisitReports() async {
    try {
      _visitPage = 1;
      isReportLoading = true;
      update();

      final response = await getRequest.customGetRequest(
        apiPath:
            "${ApiUrls.getNewVisitReport}/${loginStorage.getUserId()!}?page=$_visitPage&limit=$_limit",
      );

      log("ðŸ“¥ Visit Reports Raw: $response");

      if (response == null) {
        CustomSnackbar.error("No response from server");
        return;
      }

      /// âœ… Parse Model
      visitReportModel = VisitReportModel.fromJson(response);
      _visitTotalPages = visitReportModel?.pagination?.totalPages ?? 1;

      /// âœ… Extract list safely
      visitList = visitReportModel?.data ?? [];

      log("âœ… Parsed Visits Count: ${visitList.length}, Total Pages: $_visitTotalPages");

      if (visitList.isNotEmpty) {
        log("ðŸ“Œ First Visit Site: ${visitList.first.site}");
        log("â± CheckOut: ${visitList.first.checkOut?.time}");
      }
    } catch (e) {
      log("âŒ getVisitReports Exception: $e");
      CustomSnackbar.error("Failed to fetch visits");
    } finally {
      isReportLoading = false;
      update();
    }
  }

  /// âœ… Fetch a single visit report's full details
  Future<VisitData?> getVisitDetail(String visitId) async {
    try {
      isVisitDetailLoading = true;
      visitDetail = null;
      update();

      final response = await getRequest.customGetRequest(
        apiPath: "${ApiUrls.getVisitReportDetail}/$visitId",
      );

      log("ðŸ“¥ Visit Detail Raw: $response");

      if (response == null || response['status'] != true) {
        return null;
      }

      final model = VisitReportDetailModel.fromJson(response);
      visitDetail = model.data;

      return visitDetail;
    } catch (e) {
      log("âŒ getVisitDetail Exception: $e");
      return null;
    } finally {
      isVisitDetailLoading = false;
      update();
    }
  }

  /// loader for the "add follow up" action on the visit report details screen
  bool followUpLoader = false;

  /// Adds a follow up note (with an optional image) to a visit report via
  /// `/follow-up-visit-report`.
  Future<bool> addVisitReportFollowUp({
    required String visitReportId,
    required String text,
    File? image,
  }) async {
    try {
      followUpLoader = true;
      update();

      final res = await postRequest.customMultipartPost(
        url: ApiUrls.followUpVisitReport,
        fields: {
          'visit_report_id': visitReportId,
          'text': text,
          'user_id': loginStorage.getUserId() ?? '',
        },
        file: image,
      );

      if (res == null) {
        CustomSnackbar.error('No response from server');
        return false;
      }

      if (res['status'] == false || res['success'] == false) {
        final message = res['message'];
        CustomSnackbar.error(
            message is String && message.isNotEmpty
                ? message
                : 'Failed to add follow up');
        return false;
      }

      final message = res['message'];
      CustomSnackbar.success(message is String && message.isNotEmpty
          ? message
          : 'Follow up added successfully');
      return true;
    } catch (e) {
      log('addVisitReportFollowUp Exception: $e');
      CustomSnackbar.error('Something went wrong');
      return false;
    } finally {
      followUpLoader = false;
      update();
    }
  }

  Future<void> loadMoreVisits() async {
    if (_visitPage >= _visitTotalPages || isLoadingMoreVisits) return;

    _visitPage++;
    isLoadingMoreVisits = true;
    update();

    try {
      final response = await getRequest.customGetRequest(
        apiPath:
            "${ApiUrls.getNewVisitReport}/${loginStorage.getUserId()!}?page=$_visitPage&limit=$_limit",
      );

      if (response != null) {
        final moreModel = VisitReportModel.fromJson(response);
        final moreList = moreModel.data ?? [];
        visitList = [...visitList, ...moreList];
        log("âœ… Loaded More Visits: ${moreList.length}, Page: $_visitPage");
      }
    } catch (e) {
      log("âŒ loadMoreVisits Exception: $e");
    } finally {
      isLoadingMoreVisits = false;
      update();
    }
  }
}
