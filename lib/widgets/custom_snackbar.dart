import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  /// Generic method
  static void show(String message, AnimatedSnackBarType type) {
    AnimatedSnackBar.material(
      message,
      type: type,
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      duration: const Duration(seconds: 3),
    ).show(Get.context!);
  }

  static void success(String message) {
    show(message, AnimatedSnackBarType.success);
  }

  static void error(String message) {
    show(message, AnimatedSnackBarType.error);
  }

  static void warning(String message) {
    show(message, AnimatedSnackBarType.warning);
  }

  static void info(String message) {
    show(message, AnimatedSnackBarType.info);
  }
}
