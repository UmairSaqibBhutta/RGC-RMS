import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

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
        CustomSnackbar.success(
            "You have been logged out securely. See you soon!");

        return true;
      } else {
        CustomSnackbar.error("Something went wrong. Please try again.");

        return false;
      }
    } else {
      CustomSnackbar.error("Something went wrong. Please try again.");

      return false;
    }
  }
}
