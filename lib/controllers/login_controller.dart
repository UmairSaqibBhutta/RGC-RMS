import 'package:leadmanagementsystem/utils/dev_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/bottom_nav_screen.dart';
import 'package:leadmanagementsystem/forget_password/otp_screen.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/assignment_user_model.dart';
import 'package:leadmanagementsystem/models/login_model.dart';
import 'package:leadmanagementsystem/models/notification_model.dart';
import 'package:leadmanagementsystem/models/otp_model.dart';
import 'package:leadmanagementsystem/models/profile_model.dart';
import 'package:leadmanagementsystem/models/user_region_model.dart';
import 'package:leadmanagementsystem/screens/login_screen.dart';
import 'package:leadmanagementsystem/services/custom_get_request.dart';
import 'package:leadmanagementsystem/services/custom_post_request.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

class LoginController extends GetxController {
  var loginModel = LoginModel().obs;

  int? notificationCount = 0;

  bool otpLoading = false;

  OtpModel? otpModelData;

  ProfileData? profileData;

  List<AssignableUser> assignableUsersList = [];
  List<UserRegionData> userRegionData = [];
  List<NotificationData> notificationsList = [];

  bool emptyList = false;

  var loading = false.obs;

  bool loadingData = false;

  TextEditingController emailCont = TextEditingController();
  TextEditingController passCont = TextEditingController();

  Future<bool> loginFunction(BuildContext context) async {
    Map<String, dynamic> body = {
      "email": emailCont.text.trim(),
      "password": passCont.text.trim(),
      "fcmToken": fcmToken,
    };

    log('body---->$body');
    loading.value = true;

    try {
      var res =
          await postRequest.customPostRequest(url: ApiUrls.login, body: body);

      loading.value = false;

      loginModel.value = LoginModel.fromJson(res);

      final data = loginModel.value;

      log("login responce = $res");

      if (res['status'] != false) {
        // Get.to(const AdminHomePage());
        Get.to(const BottomNavScreen());

        log("loginModel.value.userData!.company = ${loginModel.value.userData?.company}");

        if (loginModel.value.userData != null) {
          loginStorage.setUserId(id: loginModel.value.userData!.sId!);
          loginStorage.setUserEmail(email: loginModel.value.userData!.email!);
          loginStorage.setUserRole(role: loginModel.value.userData!.role!);
          loginStorage.setUserName(fName: loginModel.value.userData!.name!);
          // loginStorage.setUserToken(
          //     token: loginModel.value.userData!.fcmToken!);
          loginStorage.setUserCompany(
              company: loginModel.value.userData!.company!);
          if (loginModel.value.userData != null &&
              loginModel.value.userData!.region != null) {
            loginStorage.setRegion(region: loginModel.value.userData!.region!);
          }
          return true;
        } else {
          return false;
        }
      } else {
        CustomSnackbar.error(res['message']);
        return false;
      }
    } catch (e) {
      loading.value = false;
      // Get.snackbar("Error", "Something went wrong. Please try again later.");
      return false;
    }
  }

  passwordChangeFunction(Map body) async {
    loadingData = true;
    update();

    var res =
        await postRequest.customPostRequest(url: 'changePassword', body: body);

    loadingData = false;
    update();

    if (res['status'] == true) {
      CustomSnackbar.success('Password changed successfully');
      Get.offAll(const LoginScreen());

      return true;
    } else {
      CustomSnackbar.error(res['message']);

      return false;
    }
  }

  /// to get the users lower than my role to whom i can assign project or task
  getMyAssignableUsers() async {
    var res = await getRequest.customGetRequest(
        apiPath: 'getAllUser/${loginStorage.getUserId()}');

    if (res['status'] != false) {
      AssignableUsersModel assingmentUserModel =
          AssignableUsersModel.fromJson(res);
      update();

      assignableUsersList = assingmentUserModel.data!;
    } else {
      return false;
    }
  }

  bool loaderData = false;

  /// get users roles higher than mine to request for update project.
  void getHigherRoleUsers() async {
    var res = await getRequest.customGetRequest(
        apiPath: 'getUsersByRole/${loginStorage.getUserRole()}');

    log('role--->${loginStorage.getUserRole()}');

    if (res['status'] != false) {
      UserRegionModel userRegionModel = UserRegionModel.fromJson(res);
      update();

      userRegionData = userRegionModel.data!;
    }
  }

  sendProjectUpdateNotification(String? reciverId, String? projectId,
      String? comment, String token, String? recieverName) async {
    loaderData = true;

    update();

    Map<String, dynamic> body = {
      'senderId': loginStorage.getUserId(),
      'recieverName': recieverName,
      'senderName': loginStorage.getUserName(),
      'recieverId': reciverId,
      'projectId': projectId,
      'comment': comment,
      'semderFcmToken': loginStorage.getUserToken(),
      'fcmToken': token,
    };

    log('body--->$body');

    var res = await postRequest.customPostRequest(
        url: 'sendNotification', body: body);

    loaderData = false;

    update();

    if (res['status'] != false) {
      CustomSnackbar.success(res['message']);

      return true;
    } else {
      return false;
    }
  }

  void getNotifications() async {
    var res = await getRequest.customGetRequest(
        apiPath: '${ApiUrls.getNotificaton}/${loginStorage.getUserId()}');

    if (res['status'] == true && (res['data'] as List).isEmpty) {
      emptyList = true;
      log('emptyList--->$emptyList');
      update();
    } else {
      emptyList = false;
      log('emptyList--->$emptyList');
      update();
      NotificationsModel notificationModel = NotificationsModel.fromJson(res);
      notificationsList = notificationModel.data ?? [];
      notificationCount = notificationModel.unreadCount;

      update();

      log('noticount---->$notificationCount');
    }
  }

  forgetPasswordService(String email) async {
    Map<String, dynamic> body = {'email': email};

    otpLoading = true;

    update();
    var res = await CustomPostRequest()
        .customPostRequest(url: 'forget-password', body: body);

    OtpModel otpModel = OtpModel.fromJson(res);

    otpModelData = otpModel;

    otpLoading = false;

    update();
    if (res['status'] != false) {
      CustomSnackbar.success(res['message']);

      Get.to(OtpScreen(email: email));

      return true;
    } else {
      CustomSnackbar.error(res['message']);
      return false;
    }
  }

  confirmPasswordService(Map body) async {
    loadingData = true;
    update();

    var res = await CustomPostRequest()
        .customPostRequest(url: 'reset-password', body: body);

    loadingData = false;
    update();

    if (res['status'] != false) {
      CustomSnackbar.success(res['message']);

      Get.off(const LoginScreen());

      return true;
    } else {
      CustomSnackbar.error('Failed');

      return false;
    }
  }

  getProfileService() async {
    var res = await CustomGetRequest().customGetRequest(
        apiPath: 'getUserProfile/${loginStorage.getUserId()}');

    if (res['status'] != false) {
      ProfileModel profileModel = ProfileModel.fromJson(res);

      profileData = profileModel.data;
      update();
    }
  }

  markReadNotification(String? notificationIds) async {
    Map<String, dynamic> body = {
      'notificationIds': [notificationIds]
    };

    log('body--->$body');

    var res = await CustomPostRequest()
        .customPostRequest(url: 'markNotificationsAsRead', body: body);

    getNotifications();

    if (res['status'] != false) {
      return true;
    } else {
      return false;
    }
  }
}
