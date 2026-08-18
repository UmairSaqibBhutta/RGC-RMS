import 'package:leadmanagementsystem/utils/dev_log.dart';

import 'package:get/get.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/project_model.dart';

class FilterController extends GetxController {
  RxBool loading = false.obs;
  RxBool visible = false.obs;

  RxBool expand = false.obs;

  var filteredProjectDataList = <ProjectData>[].obs;

  getProjectsFilter(String? projectManager, String? status, String? budget,
      String? projectName, String? company) async {
    loading.value = true;

    var res = await getRequest.customGetRequest(
        apiPath:
            'filterProjects?projectManager=${projectManager ?? ''}&status=${status ?? ''}&budget=${budget ?? ''}&name=${projectName ?? ''}&company=${company ?? loginStorage.getUserCompany()}');
    log("filtered projects response: $res");
    if (res['status'] != false) {
      loading.value = false;
      visible.value = true;

      List jsonProject = res["projectData"];

      filteredProjectDataList.value = jsonProject
          .map((e) => ProjectData.fromJson(e as Map<String, dynamic>))
          .toList();

      log("filtered projects length: ${filteredProjectDataList.length}");
    } else {
      return false;
    }
  }
}
