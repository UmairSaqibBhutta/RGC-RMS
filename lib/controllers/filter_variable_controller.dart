import 'package:get/get.dart';

class FilterVariableController extends GetxController {
  bool expand = false;

  onChanged() {
    expand = !expand;
    update();
  }
}
