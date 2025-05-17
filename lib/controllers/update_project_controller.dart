import 'package:get/get.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/update_project_model.dart';

class UpdateProjectController extends GetxController {
  ProjectUpdateModel? projectUpdateModel;

  getProjectById(String? projectId) async {
    var res =
        await getRequest.customGetRequest(apiPath: 'getProjectById/$projectId');

    if (res['status'] != false) {
      ProjectUpdateModel projectData = ProjectUpdateModel.fromJson(res);
      projectUpdateModel = projectData;

      update();
    }
  }
}
