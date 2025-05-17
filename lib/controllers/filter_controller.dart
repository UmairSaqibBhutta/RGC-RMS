import 'package:get/get.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/project_model.dart';

class FilterController extends GetxController {
  RxBool loading = false.obs;
  RxBool visible = false.obs;

  RxBool expand = false.obs;

  var projectData = <ProjectData>[].obs;

  getProjectsFilter(String? projectManager, String? status, String? budget,
      String? projectName, String? company) async {
    loading.value = true;

    var res = await getRequest.customGetRequest(
        apiPath:
            'filterProjects?projectManager=${projectManager ?? ''}&status=${status ?? ''}&budget=${budget ?? ''}&name=${projectName ?? ''}&company=${company ?? loginStorage.getUserCompany()}');

    if (res['status'] != false) {
      ProjectModel projectModel = ProjectModel.fromJson(res);
      loading.value = false;

      visible.value = true;

      projectData.value = projectModel.projectData ?? [];

      print('val--->${projectData.value}');
    } else {
      return false;
    }
  }
}
