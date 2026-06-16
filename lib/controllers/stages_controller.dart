import 'dart:developer';

import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/stages_model.dart';

class StagesController extends GetxController {
  var mainStages = <MainStageData>[].obs;
  var subStages = <SubStageData>[].obs;
  var loading = false.obs;
  var addLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getMainStages();
    getSubStages();
  }

  Future<void> getMainStages() async {
    try {
      loading.value = true;
      var response =
          await getRequest.customGetRequest(apiPath: ApiUrls.getMainStage);
      loading.value = false;

      if (response != null && response['status'] == true) {
        final model = MainStagesModel.fromJson(response);
        mainStages.value = model.data;
      } else {
        mainStages.clear();
      }
    } catch (e) {
      loading.value = false;
      log('getMainStages error: $e');
    }
    update();
  }

  Future<void> getSubStages() async {
    try {
      var response =
          await getRequest.customGetRequest(apiPath: ApiUrls.getSubStage);

      if (response != null && response['status'] == true) {
        final model = SubStagesModel.fromJson(response);
        subStages.value = model.data;
      } else {
        subStages.clear();
      }
    } catch (e) {
      log('getSubStages error: $e');
    }
    update();
  }

  Future<bool> addMainStage(
      {required String title, required int stageNo}) async {
    try {
      addLoading.value = true;
      var response = await postRequest.customPostRequest(
        url: ApiUrls.addMainStage,
        body: {'title': title, 'stage_no': stageNo},
      );
      addLoading.value = false;

      if (response != null && response['status'] == true) {
        Get.snackbar('Success', 'Main stage added successfully');
        await getMainStages();
        return true;
      } else {
        Get.snackbar('Error',
            response?['message']?.toString() ?? 'Failed to add main stage');
        return false;
      }
    } catch (e) {
      addLoading.value = false;
      log('addMainStage error: $e');
      Get.snackbar('Error', e.toString());
      return false;
    }
  }

  Future<bool> addSubStage(
      {required String mainStageId, required String title}) async {
    try {
      addLoading.value = true;
      var response = await postRequest.customPostRequest(
        url: ApiUrls.addSubStage,
        body: {'main_stage_id': mainStageId, 'title': title},
      );
      addLoading.value = false;

      if (response != null && response['status'] == true) {
        Get.snackbar('Success', 'Sub stage added successfully');
        await getSubStages();
        return true;
      } else {
        Get.snackbar('Error',
            response?['message']?.toString() ?? 'Failed to add sub stage');
        return false;
      }
    } catch (e) {
      addLoading.value = false;
      log('addSubStage error: $e');
      Get.snackbar('Error', e.toString());
      return false;
    }
  }

  String getMainStageTitle(String mainStageId) {
    final match = mainStages.firstWhereOrNull((s) => s.id == mainStageId);
    return match?.title ?? 'Unknown';
  }
}
