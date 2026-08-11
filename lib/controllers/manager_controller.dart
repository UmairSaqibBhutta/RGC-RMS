import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/bottom_nav_screen.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/common_model.dart';
import 'package:leadmanagementsystem/models/users_list_model.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

class ManagerController extends GetxController {
  bool getManagersLoading = false;
  bool addManagersLoading = false;
  bool editManagersLoading = false;

  List<UserData> managersData = [];

  updateGetManagersLoading(bool value) {
    getManagersLoading = value;
    update();
  }

  updateAddManagersLoading(bool value) {
    addManagersLoading = value;
    update();
  }

  Future getManagers() async {
    updateGetManagersLoading(true);

    var responce = await getRequest.customGetRequest(
        apiPath: ApiUrls.getUsersListByRoleName);
    updateGetManagersLoading(false);

    if (responce != null) {
      UsersListModel model = UsersListModel.fromJson(responce);

      managersData = model.data!;

      update();
    } else {
      updateGetManagersLoading(false);
    }
  }

  Future<void> addManager(Map body) async {
    updateAddManagersLoading(true);

    // await Future.delayed(Duration(seconds: 3));
    var responce =
        await postRequest.customPostRequest(url: ApiUrls.addUser, body: body);
    log("addManager responce = $responce");

    if (responce != null) {
      updateAddManagersLoading(false);

      CommonResponse model = CommonResponse.fromJson(responce);

      if (model.status == true) {
        // getManagers();

        CustomSnackbar.success(model.message);

        Get.offAll(const BottomNavScreen());
      } else {
        CustomSnackbar.error(model.message);
      }

      // Get.back();
    } else {
      updateAddManagersLoading(false);
    }
  }

  Future editProjectManager(Map<String, dynamic> body) async {
    editManagersLoading = true;
    update();

    var res =
        await postRequest.customPostRequest(url: 'editManager', body: body);
    editManagersLoading = false;
    update();

    if (res['status'] == true) {
      update();

      await getManagers();

      Get.back();

      CustomSnackbar.success('User updated successfully');

      return true;
    } else {
      return false;
    }
  }

  deleteFunction(String? userId, BuildContext context) async {
    Map<String, dynamic> body = {'userId': userId};

    var res =
        await postRequest.customPostRequest(url: 'deleteUser', body: body);

    if (res['status'] != false) {
      await getManagers();
      await projectsController.getProjects(context);

      Get.back();

      CustomSnackbar.success('User deleted successfully');

      return true;
    } else {
      return false;
    }
  }
}
