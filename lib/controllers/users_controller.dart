import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/bottom_nav_screen.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/common_model.dart';
import 'package:leadmanagementsystem/models/users_list_model.dart';

class UsersController extends GetxController {
  bool getUsersLoading = false;
  bool addUsersLoading = false;
  bool editUsersLoading = false;

  List<UserData> usersData = [];

  updateGetUsersLoading(bool value) {
    getUsersLoading = value;
    update();
  }

  updateAddUsersLoading(bool value) {
    addUsersLoading = value;
    update();
  }

  Future getUsers() async {
    updateGetUsersLoading(true);

    var responce = await getRequest.customGetRequest(
        apiPath: ApiUrls.getUsersListByRoleName);
    updateGetUsersLoading(false);

    if (responce != null) {
      UsersListModel model = UsersListModel.fromJson(responce);

      usersData = model.data!;

      update();
    } else {
      updateGetUsersLoading(false);
    }
  }

  Future<void> addUser(Map body) async {
    updateAddUsersLoading(true);

    log("add user body = $body");

    // await Future.delayed(Duration(seconds: 3));
    var responce =
        await postRequest.customPostRequest(url: ApiUrls.addUser, body: body);
    log("addManager responce = $responce");

    if (responce != null) {
      updateAddUsersLoading(false);

      CommonResponse model = CommonResponse.fromJson(responce);

      if (model.status == true) {
        // getManagers();

        Get.snackbar("Success", model.message);

        Get.offAll(const BottomNavScreen());
      } else {
        Get.snackbar("Error", model.message);
      }

      // Get.back();
    } else {
      updateAddUsersLoading(false);
    }
  }

  Future editUser(Map<String, dynamic> body) async {
    editUsersLoading = true;
    update();

    var res =
        await postRequest.customPostRequest(url: 'editManager', body: body);
    editUsersLoading = false;
    update();

    if (res['status'] == true) {
      update();

      await getUsers();

      Get.back();

      Get.snackbar('Success', 'User updated successfully');

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
      await getUsers();
      await projectsController.getProjects(context);

      Get.back();

      Get.snackbar('Success', 'User deleted successfully');

      return true;
    } else {
      return false;
    }
  }
}
