import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/main.dart';

class DrawersController extends GetxController {
  bool isLoading = false;

  updateLoading(bool loading) {
    isLoading = loading;
  }

  doLogout() async {
    updateLoading(true);
    var responce = await getRequest.customGetRequest(
        apiPath: "${ApiUrls.logout}/${loginStorage.getUserId()}");
    updateLoading(false);

    if (responce != null) {
      if (responce["status"] == true) {
        customSnackBar("Logout Successful",
            "You have been logged out securely. See you soon!");

        return true;
      } else {
        customSnackBar(
            "Logout Failed", "Something went wrong. Please try again.");

        return false;
      }
    } else {
      customSnackBar(
          "Logout Failed", "Something went wrong. Please try again.");

      return false;
    }
  }
}
