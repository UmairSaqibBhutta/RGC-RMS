import 'dart:developer';

import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/leaves_model.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

class LeavesController extends GetxController {
  bool addLeaveLoader = false;
  bool getLeavesLoader = false;
  List<LeaveData> leavesList = [];
  num remainingLeaves = 0;

  updateGetLeavesLoading(bool loading) {
    getLeavesLoader = loading;
    update();
  }

  updateAddLeaveLoading(bool loading) {
    addLeaveLoader = loading;
    update();
  }

  getLeaves() async {
    updateGetLeavesLoading(true);
    try {
      var responce = await getRequest.customGetRequest(
          apiPath: "${ApiUrls.getLeaves}/${loginStorage.getUserId()}");
      updateGetLeavesLoading(false);

      LeavesModel leaves = LeavesModel.fromJson(responce);

      if (responce["status"] == true) {
        remainingLeaves = leaves.remainingLeaves ?? 0;
        leavesList = leaves.data ?? [];
      } else {
        leavesList = [];
      }
    } catch (e) {
      updateGetLeavesLoading(false);
      leavesList = [];

      log("someting went wrong = ${e.toString()}");
    }
  }

  Future<bool> addLeave(Map body) async {
    log("body in addLeave = $body");
    updateAddLeaveLoading(true);
    try {
      var responce = await postRequest.customPostRequest(
        body: body,
        url: ApiUrls.addLeave,
      );
      updateAddLeaveLoading(false);

      if (responce["status"] == true) {
        CustomSnackbar.success("Leave added successfully");
        return true;
      } else {
        CustomSnackbar.error("Leave could not be added");
        return false;
      }
    } catch (e) {
      updateAddLeaveLoading(false);
      CustomSnackbar.error("Leave could not be added");

      log("someting went wrong = ${e.toString()}");
      return false;
    }
  }

  Future<bool> adminLeaveActions(Map body) async {
    var responce = await postRequest.customPostRequest(
        url: ApiUrls.adminLeaveActions, body: body);
    if (responce != null) {
      if (responce["status"] == true) {
        CustomSnackbar.success("Leave updated successfully");
        return true;
      } else {
        CustomSnackbar.error("Leave could not be updated");
        return false;
      }
    } else {
      CustomSnackbar.error("Leave could not be updated");
      return false;
    }
  }
}
